#!/bin/bash

nproc=$(nproc 2>/dev/null)
if [ -z "$nproc" ]; then
	nproc=$(grep -wc ^processor /proc/cpuinfo 2>/dev/null)
fi

if [ -z "$nproc" ]; then
	echo "Could not determine the number of CPUs, please install the nproc utility"
	exit 1
fi

nic="$1"; cpu="$2"
if [ -z "$nic" -o -z "$cpu" ]; then
	echo "Usage: ${0##*/} <nic> <nbcpu>"
	exit 1
fi

if [ "$cpu" -lt 1 ]; then
	echo "The number of CPU must be at least 1"
	exit 1
fi

irqs=( $(grep -w "$nic" /proc/interrupts | cut -f1 -d:) )
if [ ${#irqs[@]} -lt 1 ]; then
	echo "NIC name not found in /proc/interrupts"
	exit 1
fi

for i in ${irqs[@]}; do
	b=$((1 << (nproc - 1 - (i % cpu))))
	bl=$((b & 0xffffffff))
	bh=$(((b >> 32) & 0xffffffff))
	printf "%x,%x\n" $bh $bl > /proc/irq/$i/smp_affinity
done
