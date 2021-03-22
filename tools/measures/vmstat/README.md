# Introduction

vmstat.sh is a simple wrapper on top of the universal `vmstat` utility. It will
run it over a specified period and will prepend the current time in front of
each line.

By default it simply runs `vmstat -n 1`. With `-D` or `-d` it will prepend the
current time (either relative to the start of the command with `-D`, or absolute
since UNIX epoch with `-d`). If an extra argument is passed, it is considered
as the maximum run time before quitting. This is convenient to limit a test's
duration.

Example:

```
$ ~/dpbench/bin/vmstat.sh -d 125
1616401618 procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
1616401618  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
1616401618  1  0 703912 1200424 1173832 7641732    1    4    14    54    2    3  8  3 89  0  0
1616401619  0  0 703912 1199416 1173832 7641732    0    0     0     0 1630 3182  0  0 100  0  0
1616401620  0  0 703912 1199416 1173832 7641732    0    0     0     0 1613 3055  0  0 100  0  0
(...)
1616401741  1  0 703912 1199416 1173832 7641732    0    0     0     0 1678 3203  0  0 99  0  0
1616401742  1  0 703912 1199164 1173832 7641732    0    0     0     0 2203 4649  0  1 99  0  0
1616401743  0  0 703912 1199164 1173832 7641732    0    0     0     0 2141 4614  0  1 99  0  0
$
```

# Usage

It is suggested to use the absolute date format and longer periods than the one
used by the test session, and to start it slightly before the load generation
tools, in order to detect any unexpected activity (swapping, IRQ storms,
background CPU consumption, stolen CPU cycles, etc).

Depending on the tests, it can make sense to graph `us+sy` separately. Note that
it is not uncommon to see totals that reach 101% when adding multiple fields,
due to numeric rounding in vmstat output (e.g. 45.5 may be rounded up to 46 and
54.5 may be rounded up to 55), so please be careful never to produce values
calculated using `100-id-us-sy` for example, as this could result in -1.

On network-intensive tests, graphing interrupts (the `in` column) can help
explain sudden CPU usage variations which can result from adaptive interrupt
mitigation mechanisms implemented in hardware and/or network drivers. Most
often, the softirq work will be reported as part of the system activity (`sy`
column) but for network processing the calls are so short that most often it
will appear as almost zero until the softirqs cannot leave, resulting in a
sudden jump from almost 0 to 100%. In this case, the user/system distribution
may also observe brutal changes. These are not caused by the tools but are a
consequence of the limited accuracy of internal timing measurements.

Important variations on blocks in/out `bi/bo` indicate disk activity. If the
proxy or tools being tested are not expected to perfom disk accesses, this
column almost always indicates a parasitic activity, which can result from
from logging, log rotation, file-system indexing or background package updates.

Most of the time these metrics will be needed to learn how to stabilize a
platform or to justify unexplainable variations on some metrics and their
impact (or lack of). However once the platform acts predictably it's common not
to bother graphing these metrics. Regardless it is still recommended to
continue to collect them as they are quite inexpensive and having them handy
afterward often helps explain strange variations.

Clients and servers are often believed to be immune from background activity
but the are not necessarily, and can also be subject to network trouble. It's
also not uncommon for them to leak memory and start causing some swapping which
degrades the measurements. As such, running vmstat on the whole chain is highly
recommended, it at least to confirm that everything went as expected.


# Installing vmstat.sh

There is nothing to build, just to copy. Just enter:

```sh
$ ./build.sh
```

The `vmstat.sh` executable should appear into the `bin` subdirectory at the top
of the project. The only dependencies are the regular `vmstat` utility and the
either the GNU `awk` or `mawk` commands for `systime()`, which are available
about everywhere.
