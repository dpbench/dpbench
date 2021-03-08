#!/bin/bash

# shows each CPU core's frequency on the same line every second, forever
while echo $(sed -ne 's,^cpu MHz.*: ,,p' /proc/cpuinfo); do sleep 1; done
