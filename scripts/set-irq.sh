#!/bin/bash

nic="$1"; cpu="$2"; fcpu="$3"
if [ -z "$nic" -o -z "$cpu" ]; then
	echo "Usage: ${0##*/} <nic> <nbcpu> [<firstcpu>]"
	exit 1
fi

if [ "$cpu" -lt 1 ]; then
	echo "The number of CPU must be at least 1"
	exit 1
fi

if [ -z "$fcpu" ]; then
	nproc=$(nproc 2>/dev/null)
	if [ -z "$nproc" ]; then
		nproc=$(grep -wc ^processor /proc/cpuinfo 2>/dev/null)
	fi

	if [ -z "$nproc" ]; then
		echo "Could not determine the number of CPUs, please either set the first cpu or install the nproc utility."
		exit 1
	fi
	fcpu=$((nproc - cpu))
fi

if [ $((fcpu + cpu - 1)) -gt 255 ]; then
	echo "Supporting 256 CPUs max."
	exit 1
fi

# Note: some NICs may need a regex here, it's supported as well.
irqs=( $(grep -w "$nic" /proc/interrupts | cut -f1 -d:) )
if [ ${#irqs[@]} -lt 1 ]; then
	echo "NIC name not found in /proc/interrupts"
	exit 1
fi

i=0;
for irq in ${irqs[@]}; do
	c=$((i % cpu + fcpu))
	b0=0; b1=0; b2=0; b3=0; b4=0; b5=0; b6=0; b7=0
	if [ $c -lt 32 ]; then
		b0=$((1 << (c & 31)))
	elif [ $c -lt 64 ]; then
		b1=$((1 << (c & 31)))
	elif [ $c -lt 96 ]; then
		b2=$((1 << (c & 31)))
	elif [ $c -lt 128 ]; then
		b3=$((1 << (c & 31)))
	elif [ $c -lt 160 ]; then
		b4=$((1 << (c & 31)))
	elif [ $c -lt 192 ]; then
		b5=$((1 << (c & 31)))
	elif [ $c -lt 224 ]; then
		b6=$((1 << (c & 31)))
	elif [ $c -lt 256 ]; then
		b7=$((1 << (c & 31)))
	else
		echo "Warning: ignoring CPU out of range [0..255]: $c"
	fi

	# count number of blocks and commas
	blocks=$(< /proc/irq/254/smp_affinity)
	set -- ${blocks//,/ /}
	blocks=$#

	out=""
	[ $blocks -le 7 ] || out="${out}$(printf "%08x," $b7)"
	[ $blocks -le 6 ] || out="${out}$(printf "%08x," $b6)"
	[ $blocks -le 5 ] || out="${out}$(printf "%08x," $b5)"
	[ $blocks -le 4 ] || out="${out}$(printf "%08x," $b4)"
	[ $blocks -le 3 ] || out="${out}$(printf "%08x," $b3)"
	[ $blocks -le 2 ] || out="${out}$(printf "%08x," $b2)"
	[ $blocks -le 1 ] || out="${out}$(printf "%08x," $b1)"
	[ $blocks -le 0 ] || out="${out}$(printf "%08x" $b0)"

	echo "$out" > /proc/irq/$irq/smp_affinity
	(( i++ ))
done
