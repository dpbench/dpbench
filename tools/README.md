# Tools

All tools can be used as long as their corner cases are identified,
their impact observed, and either removed or explained in reports.

Most tools are packaged with common operating systems, but some still require
to be built by hand, and for this reason a build procedure is provided here
for some of them. An easy way to build them all at once is to execute the
`build-all.sh` script from the `tools` directory, which will deliver all
binaries into `bin` under the top directory.

## Client side (load generator)

Please see the [clients subdirectory](clients/) to find some pre-packaged clients.

Common problems:

  - **rate aggregation / stats collection**: sometimes a metric will
      be collected a bit too early or too late and may appear too
      large or too small. Typical issues cause a hole followed by the
      double value. These should typically be removed by hand if this
      happens ;

  - **lack of slow-start phase**: the tool tries to create all
      connections instantly and observes an initial erratic
      phase. This usually doesn't last long but measurements during
      that phase must be eliminated ;

  - **file descriptor limitations**: some tools require manual
      adjustments to go beyond the 1024 file descriptors limit per
      process, and some will behave randomly over such a limit ; this
      needs to be validated as the utility could very well only
      measure its own limits ;

  - **CPU usage**: some tools are more efficient than others for
      short-lived connections, others are more efficient on large
      objects, and it is common for some tools to be usable within a
      certain test range but not for all tests. As CPU increases on
      the load generator, the measurements become much less accurate
      and even the load can become irregular. This must be monitored
      and addressed, either by combining different tools or by using
      more machines ;

  - **inaccuracies in traffic limitation**: few tools are able to
      rate-limit their traffic, and even then it it technically
      difficult to remain accurate at high rates. Some tools which do
      not support such features can at least be adjusted to implement
      a delay (called "think time") after each response, but for high
      rates this delay has to be extremely small and becomes so much
      inaccurate that it causes important load variations. Often the
      only solution in this case is to spread the traffic over
      multiple machines.

  - **bottleneck in the network stack**: running tests inside VMs or
      containers can sometimes be appealing but more often than not
      these introduces packet rate and connection rate bottlenecks in
      the communication with the host. Most common issues include
      significant connection rate diminution over time due to stateful
      processing of NAT, failures to create new connections past a
      certain number or when source ports wrap around, and small
      packet losses forcing the tested device to heavily
      retransmit. As much as possible, tests must be performed in
      well-known, validated environments where this never happens.


The issues above affect most if not all tools and/or their
environment. It is not always possible to address them nor to work
around them. However these issues must be identified and well
understood. If they are not too common, sometimes a failed test may
need to be performed again. If they are unavoidable but do not
significantly degrade the test, at least they should be mentioned on
the report with an explanation of what happens and why it's considered
as not dramatic. For example, it is perfectly possible to indicate
below a load graph "the short drop every 60s corresponds to the
network stack on the client flushing its outdated sessions tables and
is not part of the measurement".

All such issues will affect the average values but not all the
values. This is why it is crucial to measure the load at least every
second and to graph a few metrics to verify that everything works as
desired. It is unfortunate that there are still a number of tools
which do not report periodic values, so when using them the
measurements need to be retrieved elsewhere (tested product or network
traffic for example). As long as the graph shows a plateau, even with
accidents in it that can all be explained, the plateau can become an
acceptable value.

Some clients are available as git submodules under the "client"
subdirectory. In order to use them, just enter the directory and run
"./build.sh", they will be downloaded and installed locally.


## Server side (load sink)

Please see the [servers subdirectory](servers/) to find some pre-packaged servers.

For most proxies, most servers with calibrated object sizes will work
fine but they need to be tested first with the desired client tool. An
important element to keep in mind is that the server must present the
highest regularity. Logging must absolutely be disabled for example so
that there is no timing artefact caused by log rotation nor disk
flushes. Tests run from the desired client directly on the server
should show that at the targetted load, the server will be below 80%
of its maximum capacity.

Some servers are designed specifically for the purpose of
testing. They are usually easier to use and faster than real servers,
but can also face other limitations, which need to be verified before
choosing them.

In any case, despite very appealing and easy in appearance, the server
and the proxy should not be left running on the same machine because
their co-existence can completely ruin the test due for example to
double the number of local sockets, or competition for running on
certain CPUs.


## Reporting (graphs)

Please see the [reporting subdirectory](reporting/) to find some
pre-packaged graph suites.

Reporting is extremely important as it allows to visually spot something that
does not work as it should. Any single test should be graphed, this is a time
saver as it allows to immediately fix an issue and restart it instead of
executing hundreds of tests on an incorrect setup and having to redo them all.

Different tools provide different output formats and may need to be graphed
differently. Plenty of utilities are suited to the task but usually what takes
time is to adapt the graphs to make them easily reproducible.

The purpose of what is in the "reporting" directory is to provide quickly
reproducible graphs for various tools' outputs, and to make them easily
adaptable to different needs.

Among the well-known utilities, [gnuplot](http://www.gnuplot.info/) is
indisputably the most versatile and most widely used one as virtually every
published scientific graph comes from it. It is packaged and available on
all operating systems with multiple output drivers including SVG and PNG, and
is easy to tailor for a wide spectrum of needs. It is not always easy to start
with due to its rich feature set, thus some working scripts are provided for
it in the [reporting/gunplot](reporting/gnuplot) subdirectory, hoping that
they can be used as-is and also serve as templates to write new ones.

There is also a wide choice of dynamic graph tools which work in browsers.
These can be convenient during the tests, to monitor that everything works as
expected but many of them will make automation complicated, especially when it
comes to assembling multiple metrics.


## Links to various clients:

| Name | License | HTTP | SSL | Ramp-up/Stop | Stop on | Rate limiting | Periodic reports | Stats | Notes |
|------|---------|------|-----|--------------|---------|---------------|------------------|-------|-------|
|[h1load](https://github.com/wtarreau/h1load)| MIT     | 1.1  | Yes | Both         | duration,req count,none|per-request,none| Yes (per-second) | cps, rps, avg TTFB/TTLB, percentiles |self pre-heating phase for accurate ramp-up|
|[h2load](https://github.com/nghttp2/nghttp2)| MIT     | 1.1,2| Yes | Ramp-up      | duration,req count | connections,none | %-done only | avg bps/rps, min/max/mean/sd time |supports HTTP/1.1 pipelining, HTTP/1.1 not always reliable on very large objects|
|[hey](https://github.com/rakyll/hey) | Apache  | 1.1,2| Yes | no           | duration,req count | yes | no              | percentiles | supports proxies and compression; requires a recent Go toolchain |
|[httperf](https://github.com/httperf/httperf)|GPLv2   | 1.0,1.1  | Yes | no       | req count | yes         | no               | min/avg/max/stddev time, avg bps/rps|Requires lots of arguments|
|[httpress](https://github.com/virtuozzo/httpress) | BSD-3 | 1.1  | Yes | no           | req count | no          | %-done only      | avg rps,bps,time | SSL support requires GNUTLS |
|[wrk](https://github.com/wg/wrk)| Apache  | 1.1  | Yes | no           | duration | no | no | avg bps/rps, avg/max/std-dev time |LuaJit mandatory (no ARM64 support)|
|[wrk2](https://github.com/giltene/wrk2)  | Apache  | 1.1  | Yes | no           | duration | mandatory | no | avg bps/rps, avg/max/std-dev time, corrected percentiles |LuaJit mandatory (no ARM64 support)|


## Links to various servers:

| Name | License | HTTP | SSL | Object size choice | Response time choice | Stats | POST draining | Notes |
|------|---------|------|-----|-------------|---------------|-------|---------------|-------|
|[httpterm](https://github.com/wtarreau/httpterm)| GPLv2 | 1.1/1.0/0.9 | No  | per-request | per-request | per-response | ~16kB max | Configured by URI. Supports chunking, caching, random data, random sizes |
|[nginx](https://nginx.org/)| BSD-2 | 2.0/1.1/1.0/0.9 | Yes | per-file | no | no | via buffering | Omni-present and often sufficient for max-rps/max-bw. Check default tuning and disable logging however |
