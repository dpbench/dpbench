# Introduction

This directory contains a few scripts that are useful at different steps of
the benchmark.

## `run-timed.sh`
This script executes a command, prefixes each line with the current time
(relative to start or absolute), enforces a timeout and sends the output
both to stdout and to a file whose name is composed of the metric name,
the node name and the test name/number. In addition a similar file with
an extension `.cmd` will recall the whole command.

This utility is useful to start load generators and collect their output,
to run `vmstat` to get continuous CPU/irq/memory monitoring, and to run
various other line-oriented monitoring commands.

The absolute date (`-d`) allows to leave some margin at the beginning and
the end of the tests to assemble files from multiple nodes at the end and
graph their activities. Please pay attention to NTP synchronization,
especially after a crashed machine has to be rebooted!

Example: collect CPU/memory/interrupt usages for 3 minutes

```sh
$ ./scripts/run-timed.sh -d -t 180 cpu proxy1 test13-64kB -- vmstat 1
Output will be sent to cpu-proxy1-test13-64kB.out and the command to cpu-proxy1-test13-64kB.cmd.
### Starting at Mon Mar  8 19:19:59 CET 2021, redirecting to cpu-proxy1-test13-64kB.out ###
1615227599 procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
1615227599  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
1615227599  1  0 900036 4229436 1804916 4190052    1    3    14    52    2    0  8  3 89  0  0
1615227600  0  0 900036 4229436 1804916 4190060    0    0     0     0  988 3766  0  1 99  0  0
1615227601  0  0 900036 4229436 1804916 4190060    0    0     0     0 1162 4089  0  1 99  0  0
1615227602  0  0 900036 4229436 1804916 4190060    0    0     0     0 1181 3377  0  1 99  0  0
1615227603  0  0 900036 4229436 1804916 4190060    0    0     0    52 1030 3129  0  1 98  1  0
1615227604  1  0 900036 4229436 1804916 4190060    0    0     0     0  603 2425  0  0 99  0  0
1615227605  0  0 900036 4229436 1804920 4190060    0    0     0    48 1025 3851  0  1 98  1  0
```
