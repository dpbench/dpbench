# Introduction

httpterm is a benchmark-oriented HTTP server. Its behavior and contents are
adjusted by the request. This means that the server can be started on a port
and forgotten, everything can then be controlled from the client.

The most commonly used features are:
  - arbitrary size responses
  - arbitrary wait time before responding
  - single-byte chunks to stress parsers
  - enable/disable body length advertisement
  - compressible/non-compressible responses
  - cacheable/non-cacheable responses
  - force keep-alive/close after response
  - wait for some body before responding
  - respond using small TCP segments
  - support for random ranges on all parameters above

# Starting httpterm

httpterm only requires one (or several) listening ports, optionally addresses
to be started. It is important to think about increasing the default file
descriptor limit to the number of desired connections using `ulimit -n` before
starting it.

httpterm defaults to a single process, but it uses `SO_REUSEPORT` to allow
multiple processes to run in parallel each with their own socket. It is also
possible to write a configuration file to enable multi-processing but nobody
does this noawadays as this is cumbersome.

httpterm is light on resource and can coexist with network interrupts on most
systems. However if the network interrupts are only delivered to a subset of
CPUs, then it is preferable to use only the remaining CPUs for httpterm, as
the CPU usage might be high on the ones getting the interrupts. Example:

```sh
# start 12 processes on CPUs 12..23 listening on port 8000
$ ulimit -n 100000
$ for i in {1..12}; do taskset -c 12-23 ./bin/httpterm -D -L :8000; done
```

On a developer's machine, usually httpterm uses much less CPU than a proxy
and a bit less than a load generator, so it often makes sense to bind it
only to half of the threads and cores that it will share with the client,
and leave the other ones entirely available to the proxy, so that it is
possible to reproducibly test a proxy on a single machine:

```sh
# bind httpterm on the two threads of cores 2 and 3
$ ulimit -n 100000
$ for i in {1..4}; do taskset -c 2,3,6,7 ./bin/httpterm -D -L :8000; done
# then use taskset -c 2,3,6,7 with 4 threads for the client
# and use taskset -c 0,1,4,5 with 4 threads for the proxy.
```


# Using httpterm

In case of doubt, a `GET /?` request on the listening port will remind the
syntax:

```sh
$ curl 0:8000/?
HTTPTerm-1.7.9 - 2020/06/28
All integer argument values are in the form [digits]*[kmgr] (r=random(0..1)).
The following arguments are supported to override the default objects :
 - /?s=<size>        return <size> bytes.
                     E.g. /?s=20k
 - /?r=<retcode>     present <retcode> as the HTTP return code.
                     E.g. /?r=404
 - /?c=<cache>       set the return as not cacheable if <1.
                     E.g. /?c=0
 - /?C=<close>       force the response to use close if >0.
                     E.g. /?C=1
 - /?K=<keep-alive>  force the response to use keep-alive if >0.
                     E.g. /?K=1
 - /?b=<bodylen>     advertise the body length in content-length if >0.
                     E.g. /?b=0
 - /?B=<maxbody>     read no more than this amount of body before responding.
                     E.g. /?B=10000
 - /?t=<time>        wait <time> milliseconds before responding.
                     E.g. /?t=500
 - /?k=<enable>      Enable transfer encoding chunked with 1 byte chunks if >0.
 - /?S=<enable>      Disable use of splice() to send data if <1.
 - /?R=<enable>      Enable sending random data if >0 (disables splicing).
 - /?p=<size>        Make pieces no larger than this if >0 (disables splicing).

Note that those arguments may be cumulated on one line separated by a set of
delimitors among [&?,;/] :
 -  GET /?s=20k&c=1&t=700&K=30r HTTP/1.0
 -  GET /?r=500?s=0?c=0?t=1000 HTTP/1.0
```

Thus, through a proxy forwarding local port 8001 to local port 8000, one could
do request 50kB objects:

```sh
$ taskset -c 2,3,6,7 clients/wrk2/bin/wrk2 -c 100 -d 5 -t 4 -R 100000 http://127.0.0.1:8001/?s=50k
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.42ms  840.95us   9.56ms   85.89%
    Req/Sec       -nan      -nan   0.00      0.00%
  493907 requests in 5.00s, 23.61GB read
Requests/sec:  98782.94
Transfer/sec:      4.72GB
```

Maintaining connections active 50% of the time by waiting 10ms on the server then 10ms on the client:

```sh
$ taskset -c 2,3,6,7 clients/h1load/bin/h1load -c 2000 -d 5 -t 4 -T 10 http://127.0.0.1:8001/?t=10
#     time conns tot_conn  tot_req      tot_bytes    err  cps  rps  bps   ttfb
         1  2000     2000    95524       12304411      0 2k00 95k5 98M4 10.46m
         2  2000     2000   193587       24925635      0 0.00 97k9 100M 10.27m
         3  2000     2000   291028       37472359      0 0.00 97k3 100M 10.34m
         4  2000     2000   388519       50025474      0 0.00 97k3 100M 10.38m
         5  2000     2000   485691       62543417      0 0.00 97k0 100M 10.45m
         6  2000     2000   583615       75148490      0 0.00 97k8 100M    -
         7     0     2000   584688       75287106      0 0.00 1k07 1M10    -
```

Responses will also provide some information about the request and response
(size and timing):

```sh
$ curl -i 0:8000/?s=100/t=10
HTTP/1.1 200
Content-length: 100
X-req: size=81, time=0 ms
X-rsp: id=dummy, code=200, cache=1, size=100, time=10 ms (10 real)

.123456789.123456789.123456789.123456789.12345678
.123456789.123456789.123456789.123456789.12345678
```


# Known limitations

httpterm was forked from an ancient HAProxy version (its readme still speaks
about haproxy). It does support a config file and may even load-balance
between objects featuring different properties, but this is rarely used. Due
to this ancestry, it keeps similar principles in that `-D` is mandatory to
make it fork into the background, and that it's sensitive to the setting of
`ulimit -n`, which causes it to quickly use a lot of CPU when too low
(`accept()` fails to allocate an fd and tries again). It does have a 10
seconds client timeout by default (which may be changed via a config file) and
will drain POST requests up to ~16kB. Its pipelining abilities are limited
(though not useful behind a proxy), and it will use more CPU when its number
of connections increase because it verifies changes on all of them. This is
not noticeable up to a few thousand concurrent connections per process
however. It is optimal not to run more than one per CPU and per port.
