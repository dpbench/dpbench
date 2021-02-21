# Tools

All tools can be used as long as their corner cases are identified, their impact observed, and either removed or explained in reports.

## Client side (load generator)

Common problems:
  - rate aggregation / stats collection: sometimes a metric will be collected a bit too early or too late and may appear too large or too small. Typical issues cause a hole followed by the double value. These should typically be removed by hand if this happens ;
  - lack of slow-start phase: the tool tries to create all connections instantly and observes an initial erratic phase. This usually doesn't last long but measurements during that phase must be eliminated ;
  - file descriptor limitations: some tools require manual adjustments to go beyond the 1024 file descriptors limit per process, and some will behave randomly over such a limit ; this needs to be validated as the utility could very well only measure its own limits ;
  - CPU usage: some tools are more efficient than others for short-lived connections, others are more efficient on large objects, and it is common for some tools to be usable within a certain test range but not for all tests. As CPU increases on the load generator, the measurements become much less accurate and even the load can become irregular. This must be monitored and addressed, either by combining different tools or by using more machines ;
  - inaccuracies in traffic limitation: few tools are able to rate-limit their traffic, and even then it it technically difficult to remain accurate at high rates. Some tools which do not support such features can at least be adjusted to implement a delay (called "think time") after each response, but for high rates this delay has to be extremely small and becomes so much inaccurate that it causes important load variations. Often the only solution in this case is to spread the traffic over multiple machines.
  - bottleneck in the network stack: running tests inside VMs or containers can sometimes be appealing but more often than not these introduces packet rate and connection rate bottlenecks in the communication with the host. Most common issues include significant connection rate diminution over time due to stateful processing of NAT, failures to create new connections past a certain number or when source ports wrap around, and small packet losses forcing the tested device to heavily retransmit. As much as possible, tests must be performed in well-known, validated environments where this never happens.

The issues above affect most if not all tools and/or their environment. It is not always possible to address them nor to work around them. However these issues must be identified and well understood. If they are not too common, sometimes a failed test may need to be performed again. If they are unavoidable but do not significantly degrade the test, at least they should be mentioned on the report with an explanation of what happens and why it's considered as not dramatic. For example, it is perfectly possible to indicate below a load graph "the short drop every 60s corresponds to the network stack on the client flushing its outdated sessions tables and is not part of the measurement".

All such issues will affect the average values but not all the values. This is why it is crucial to measure the load at least every second and to graph a few metrics to verify that everything works as desired. It is unfortunate that there are still a number of tools which do not report periodic values, so when using them the measurements need to be retrieved elsewhere (tested product or network traffic for example). As long as the graph shows a plateau, even with accidents in it that can all be explained, the plateau can become an acceptable value.


## Server side (load sink)

For most proxies, most servers with calibrated object sizes will work fine but they need to be tested first with the desired client tool. An important elements to keep in mind is that the server must present the highest regularity. Logging must absolutely be disabled for example so that there is no timing artefact caused by log rotation nor disk flushes. Tests run from the desired client directly on the server should show that at the targetted load, the server will be below 80% of its maximum capacity.

Some servers are designed specifically for the purpose of testing. They are usually easier to use and faster than real servers, but can also face other limitations, which need to be verified before choosing them.

In any case, despite very appealing and easy in appearance, the server and the proxy should not be left running on the same machine because their co-existence can completely ruin the test due for example to double the number of local sockets, or competition for running on certain CPUs.

## Links to various clients:

## Links to various servers:

