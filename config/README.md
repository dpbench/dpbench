# Introduction

This directory will list a number of generic or specific configurations
suitable for different proxies and different use cases or topologies.

The naming scheme is the following:

    <product_name>-<topology>-<variant>.<extension>

The product name corresponds to the proxy product.

The topology corresponds to different setups:
  - `forwarder` : pass the traffic to one server
  - `cluster` : installed as a load-balancing reverse proxy in front of 4 servers
  - `edge` : includes some TLS-offloading and some protection rules
  - `apigw` : might be optimized to run close to the client and reach multiple services

In addition to this, several variants may be provided, they will depend on the
products' capabilities and their ability to better adapt to the environment.
For each deployment, at least one variant called `basic` must be present and
should correspond to what a new user would start with (i.e. no excessive tuning
nor complex rules that require a deep look into the documentation). Other
variants may include "cache", "compressed", "optimized" etc.

Such configurations are meant to be easily adaptable to the test environment,
and may be post-processed by scripts from the [scripts/](../scripts/)
directory.
