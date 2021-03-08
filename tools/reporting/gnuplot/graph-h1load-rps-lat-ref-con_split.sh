#!/bin/bash

# This script will read two load output files from h1load and produce two-axis
# graphs showing the request per second, the measured latency and optionally
# the reference latency if a reference file is passed, and will plot the
# injected load on a separate graph. This is meant to be used with a main
# worker and a reference measure bypassing the DUT to eliminate the measurement
# noise. The default output will be a PNG file under the same name but with the
# extension replaced with ".png".
#

# show usage with $1=command name and optional exit code in $2
usage() {
  echo "Usage: ${1##*/} [-h|--help] [-t title] [-r reffile] [-o outfile] <runfile>"
  echo "   -h --help      display this help"
  echo "   -o outfile     output PNG file (default: same as runfile with .png)"
  echo "   -r reffile     h1load output from the reference monitor"
  echo "   -t title       set the graph's title"
  echo "   runfile        h1load output from the main worker"
  echo
  echo "If no title is set and the file name contains a colon, then everything between"
  echo "the first colon and the last dot (if any) will be used as the graph's title."
  echo "Otherwise the title passed with -t will be used for all files if not empty,"
  echo "otherwise the file's name without what follows the last dot will be used."
  exit $2
}


out=""; ref=""
while [ -n "$1" -a -z "${1##-*}" ]; do
  if [ "$1" = "-t" ]; then
    title="$2"
    shift; shift
  elif [ "$1" = "-o" ]; then
    out="$2"
    shift; shift
  elif [ "$1" = "-r" ]; then
    ref="$2"
    shift; shift
  elif [ "$1" = "-h" -o "$1" = "--help" ]; then
    usage "$0" 0
  else
    usage "$0" 1
  fi
done

if [ $# -eq 0 ]; then
  usage "$0" 1
fi

run="$1"
if [ -z "$out" ]; then
  out=${run%.*}.png
fi

t="${run##*/}"  
if [ -n "$t" -a -z "${t##*:*}" ]; then
  title="${t#*:}"
  title="${name%.*}"
elif [ -z "$title" ]; then
  title="${t%.*}"
fi

gnuplot << EOF
  #set terminal png font courbi 9 size 800,400
  set terminal pngcairo size 800,400 background rgb "#f0f0f0"
  #set terminal pngcairo size 800,400 background rgb "#404040"
  set style fill transparent solid 0.15 noborder
  set output "${out%.*}.png"
  set grid lt 0 lw 1 ls 1 lc rgb "#d0d0d0"

  autorange(x)=(scale=(x<=10?1:(10**(int(log10(x)-1)))), x/scale<=20?step=2:x/scale<=50?step=5:step=10, int((x-0.0001)/scale/step+1)*step*scale)

  stats "$run" using 1 nooutput; min_time_run=STATS_min
  min_time_ref=min_time_run
  ${ref:+stats '$ref' using 1 nooutput; min_time_ref=STATS_min}
  x_offset=(min_time_run < min_time_ref) ? min_time_run : min_time_ref

  stats "$run" using 1:2 nooutput
  conmax=STATS_max_y
  conmaxr=autorange(conmax)

  stats "$run" using 1:9 nooutput
  rpsmax=STATS_max_y
  rpsmaxr=autorange(rpsmax)

  stats "$run" using 1:12 nooutput
  latmax=STATS_max_y
  latmaxr=autorange(latmax)

  set size 1,1
  set multiplot
  set lmargin 12
  set rmargin 12

  set size 1,0.67
  set origin 0,0.34
  set title "$title"
  set format x ""
  set bmargin 0

  set yrange [0:]
  set ytics nomirror
  set y2range [0:]
  set y2tics 200
  #set key inside bottom center box
  #set key outside bottom center horizontal spacing 1.5 reverse Left samplen 3 spacing 2
  set key inside top center horizontal spacing 1.5 reverse Left samplen 3 spacing 0.6 maxcols 3 maxrows 1
  set format y "%.0f"
  set format y2 "%.0f"

  set ylabel "Requests per second"
  set y2label "Latency (microseconds)"

  set y2range[latmaxr/100:latmaxr*1.09]
  set y2tics latmaxr/10

  set yrange[rpsmaxr/100:rpsmaxr*1.09]
  set ytics rpsmaxr/10

  # reminder on LT: 1=magenta, 2=green, 3=light blue, 4=dark yellow, 5=light yellow, 6=dark blue, 7=red, 8=black
  plot \
    "$run" using (\$1-x_offset):12 with filledcurves x1 notitle axis x1y2 lt 1, \
    ${ref:+'$ref' using (\$1-x_offset):12 with filledcurves x1 notitle axis x1y2 lt 7,} \
    "$run" using (\$1-x_offset):9  with filledcurves x1 notitle lt 2, \
    "$run" using (\$1-x_offset):9  with lines title "Req/s" lt 2 lw 2, \
    ${ref:+'$ref' using (\$1-x_offset):12 with lines title 'Direct lat.' axis x1y2 lt 7 lw 1,} \
    "$run" using (\$1-x_offset):12 with lines title "Latency" axis x1y2 lt 1 lw 2 \

  unset title
  set size 1,0.34
  set origin 0,0
  set xtics
  set format x "% h"
  unset bmargin
  set tmargin 0
  set yrange [conmaxr/100:conmaxr*1.19]
  set ytics conmaxr/5.0
  unset y2range
  unset y2tics

  set xlabel "Run time (seconds)" offset 0,0.5
  set ylabel "Load"
  unset y2label
  set key inside center center horizontal spacing 1.5 reverse Left samplen 3 spacing 1.2 opaque box
  
  plot \
    "$run" using (\$1-x_offset):2  with filledcurves x1 notitle lt 3, \
    "$run" using (\$1-x_offset):2  with lines title sprintf("Concurrent connections (peak=%d)",conmax) lt 3 lw 2
  unset multiplot
EOF
