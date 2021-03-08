# Introduction

h1load is a simple load generator which focuses on performance and accuracy.
It is event-driven (epoll only) but uses threads to ease data collection, rate
limiting and synchronization. It uses short batches to preserve the finest
accuracy in measurements, and takes care of pre-allocating the system
resources on startup to avoid erratic measures caused by system allocating
resources on the fly in the middle of the run. Just like vmstat, it reports
real-time activity metrics so that it is possible to gauge if the setup is
stable or not, and to stop the test to fix it instead of waiting for the end.
It has been tested up to 100 Gbps and ~6 million requests per second on 8-core
machines, so it is expected to be usable both for the worker instances and for
the reference instances.


# Building h1load

Just enter:

```sh
$ ./build.sh
```

If everything goes well (it should), an `h1load` executable should appear into
the `bin` subdirectory. There are very few dependencies (basically only the
libc) so very often it's possible to just scp the binary to remote machines
booted over the network or live USB sticks.


# Starting h1load

For routine tests, h1load maybe started with just an IP address and a port, it
will then constantly send `GET /` requests to the server located there over a
single connection. The number of concurrent connections may be set using `-c`,
the maximum total number of requests with `-n`, the maximum number of requests
per second with `-R`, the maximum total run time with `-d`, the number of
threads to use with `-t`. It is possible to pass some headers with `-H` and to
specify a slow ramp-up of X seconds using `-s <ramp-up-time>`. The output
format is the human-friendly one by default (uses units) but may be changed to
the large one using `-ll`. Percentiles by default are not collected unless
`-P` is added. Adding `-e` is recommended as it will make it immediately stop
at the first error. Example:

```sh
$ ./bin/h1load -c 10 -n 40000 -R 10000 http://127.0.0.1:8000/
#     time conns tot_conn  tot_req      tot_bytes    err  cps  rps  bps   ttfb
         1    10       10    17934        2259784      0 10.0 17k9 18M0 79.69u
         2    10       10    27974        3524824      0 0.00 10k0 10M1 122.7u
         3    10       10    37967        4783942      0 0.00 9k98 10M0 125.5u
         4     0       10    40000        5040119      0 0.00 2k03 2M04 104.1u
```

The scripts provided here make use of the richer `-ll -P` output format, and
can graph the number of concurrent connections which is growing up during the
slow ramp-up, so it is recommended to set a large enough value to `-s` to have
the time to observe the effects of the ramp-up on the graphs. Usually 10 to 60
seconds provide useful results. If the utility is launched in parallel to
other monitoring tools (which is recommended), or even in parallel to other
instances running on other clients, it is better to run it for a certain
duration than with just a number of requests, otherwise not all instances will
stop at the same moment and the final load may be chaotic and difficult to
reliably aggregate.

Setting `ulimit -n` to a value larger than the number of concurrent
connections is necessary (otherwise errors will stop the test). Using taskset
may be necessary if network interrupts are not evenly distributed. The report
is sent to the standard output and is updated every second. It is recommended
to pipe it to `tee` to constantly monitor the activity, and stop the test if
anything goes wrong:

```sh
$ ulimit -n 10000
$ taskset -c 0-11 ./bin/h1load -e -ll -P -t 12 -s 30 -d 120 -c 2400 http://172.32.33.34:8000/ | tee test2m1200.out
```

# Using the report

A script `scripts/split-report.sh` is provided to split the two parts of the
report between the runtime load report and the percentile report. Both files
will be usable to produce graphs (see the reporting directory for this).

