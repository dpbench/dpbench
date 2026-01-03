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
	m=$((1 << (c & 31)))
	b=( )
	b[$((c/32))]=$m

	# count number of blocks and commas
	blocks=$(< /proc/irq/$irq/smp_affinity)
	set -- ${blocks//,/ }
	blocks=$#

	out=""
	blk=$((blocks - 1))
	while [ $blk -ge 0 ]; do
		out="${out}$(printf "%08x" ${b[$blk]:-0})"
		[ $blk -eq 0 ] || out="${out},"
		((blk--))
	done
	echo "$out" > /proc/irq/$irq/smp_affinity
	(( i++ ))
done
