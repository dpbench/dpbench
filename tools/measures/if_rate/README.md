# Introduction

if_rate is a very simple utility capable of returning both the bit rate and the
packet rate in each direction of an arbitrary list of network devices, at a
specified interval. The output format is suitable for graphing and contains the
absolute date to ease synchronization with other metrics sources.

By default it displays a self-refreshing table of all interfaces which is handy
for live monitoring. The refresh interval may be specified in seconds as the
first numeric argument on the command line:

```
Averages for the last 1000 msec
+----------------------------------------------------------------------+
| IF      |Input                         |Output                       |
+----------------------------------------------------------------------+
| lo      |      0.0 kbps|      0.0 pk/s||      0.0 kbps|      0.0 pk/s|
| eth0    |      0.0 kbps|      0.0 pk/s||      0.0 kbps|      0.0 pk/s|
| wlan0   |      1.6 kbps|      2.2 pk/s||      1.0 kbps|      1.1 pk/s|
| bond0   |      0.0 kbps|      0.0 pk/s||      0.0 kbps|      0.0 pk/s|
+----------------------------------------------------------------------+
```

By default, all interfaces are monitored. It is possible to restrict the output
to a specific list of interfaces by listing them after `-i`.

The line-mode is enabled by passing the `-l` argument:

```
$ if_rate -l -i eth0 -i eth1 1
#   time   eth0(ikb ipk okb opk) eth1(ikb ipk okb opk)
1616399469 41.6 56.6 42.3 55.5  6.7 17.7 16.1 19.9
1616399470 48.1 72.2 48.7 73.3  16.1 38.8 24.3 34.4
1616399471 35.9 44.4 35.8 44.4  4.6 9.9 13.2 14.4
1616399472 13.6 19.9 12.0 17.7  5.1 11.1 6.4 9.9
1616399473 17.0 25.5 14.6 23.3  5.8 14.4 8.2 12.2

```

The first line indicates the column contents and interface ordering. Please
note that interfaces appear on the output in the same order as they appear in
/proc/net/dev and not on the command-line order. The first column contains the
local date since UNIX epoch. Then for each interface, the columns appear in
this order:
  - ikb: incoming kilobits per second averaged over last measurement period
  - ipk: incoming packets per second averaged over last measurement period
  - okb: outgoing kilobits per second averaged over last measurement period
  - opk: outgoing packets per second averaged over last measurement period


# Building if_rate

Just enter:

```sh
$ ./build.sh
```

If everything goes well (it should), an `if_rate` executable should appear into
the `bin` subdirectory at the top of the project. There are very few
dependencies (basically only the libc) so very often it's possible to just scp
the binary to remote machines booted over the network or live USB sticks.
