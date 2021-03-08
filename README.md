# Presentation

**dpbench** is a dataplane benchmark suite trying to cover all aspects of running a benchmark on a low-level component which is usually sensitive to system tuning and test methodology, in order to help users establish trustable results that they can use to size their production, to optimize their architecture for a better user experience, or to figure their margin before the users experience suffers.

# Quick setup for the impatient
A quick shortcut to build all provided tools for those already accustomed to the project is the following:

```sh
$ git clone https://github.com/dpbench/dpbench
$ cd dpbench
$ git submodule init && git submodule update
$ ./tools/build-all.sh
$ ls -l bin
```

# Motivations

In an all-connected world, the responsiveness of online services has reached a very high importance. Users of applications and web site visitors are not willing to wait anymore, they open multiple tabs in parallel from their search engine's first results, and start by visiting the first rendered one. While it seems that in 2021 this aspect of user experience is now well understood by site operators, they don't always have all the knobs to act on. Most of the time the focus is placed on application components and databases, but rarely on what is often considered as being part of the infrastructure. Worse, such low-level components are nowadays way more sollicitated than their application server counter parts, sometimes seeing 10 to 100 times more requests, which results in a much stronger impact on the overall response time.

And there's an explanation to this. The infrastructure components are usually chosen to scale a lot, and are deployed with a significant margin. Most web site operators are very comfortable deploying 100 application servers behind a single pair of load balancers, knowing this last one was designed for this purpose and that its programming model allows it to scale way beyond the application servers. As such, by applying a large margin on resource usage, they often feel safe for a long time.

But there is a limit to everything, and that limit is not always the CPU usage. Is there anything worse than hearing a journalist on the radio mention something cool about your web site, just to discover that the hundreds of thousands of excess visitors just made it collapse and that thanks to their preferred search engine they found their product on your competitors' site ? There is no way you'll recover from such a missed opportunity.

For this reason, running benchmarks on infrastructure components such as load balancing proxies is critically important to guarantee trouble-free long term operations. Most users are pretty much aware of this, but properly doing so usually requires a much wider background on technical stuff than what is often required to deploy such components, which explains why so many published benchmarks contradict each other, while most commonly being run in good faith. Indeed, it's not that the people who run them are dishonest, it's just that they overlook a number of important factors that affect the results' reliability, among which the test conditions, the client, the server, the operating system, the network limitations, parasitic processes, etc. The tools involved have their own limitations and bugs, that are often acceptable once known, but their users need at least to be aware of them.

The dpbench project aims at helping everyone run tests under the most relevant conditions for their use case, by proposing a proven methodology with explanations of the reasons for certain steps, and a check list of a number of important points to validate before, during, and after the tests. The ultimate goal is to be able to figure the safe operating area and the remaining margin, in parallel to delivering clean graphs to appease the boss without having to spend one week chasing system settings. A number of the points mentioned here are directly transposable into production and may help users avoid dangerous limitations that they probably ignore and that are just silently waiting for more traffic to be discovered.

# Project organization

The project is organized in folders, each of which will come with a general index, and links to some specific entries related to certain products/environments/tools:
  - [howtos](howtos/): explains how to proceed at the various steps of running a benchmark
  - [issues](issues/): enumerates a number of well-known issues met in benchmarks and/or production, how to detect them, how to address them when possible, how to work around them if possible, or how to correct for them and/or to mention them in the results; this is quite product-centric.
  - [tuning](tuning/): some optimized settings for various operating systems and/or use cases, with explanations
  - [config](config/): pre-made configurations for various products in different topologies or use cases, avoiding the blank page syndrom at the beginning of a benchmark campaign
  - [results](results/): some results shared by users, versioned, dated, with all required platform details
  - [scripts](scripts/): scripts that help setting up a benchmark environment, collect, aggregate and process results
  - [tools](tools/): links to various tools that are commonly helpful or needed to run benchmarks, with known limitations
  - bin: executables from locally built embedded tools

Please start with [howtos/](howtos/).
