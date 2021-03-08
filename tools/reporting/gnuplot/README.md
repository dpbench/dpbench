# Introduction

This directory offers a collection of gnuplot scripts that will convert one or
multiple client's and monitoring tools' output into comprehensive graphs.

The naming tries to be self-descriptive, with the client name being used as
the first word, then an enumeration of the reported metrics and possibly some
variants.

All these scripts indicate their usage syntax when started with no argument.

These files should be easy to adapt to other tools by simply switching a few
columns in the `plot` directives.


# Installation

If gnuplot is not yet installed on your system, it will likely be available
after these commands:

Debian, Ubuntu:
```sh
$ sudo apt install -y gnuplot
```

CentOS, RedHat:
```sh
$ sudo yum install gnuplot
```

Fedora:
```sh
$ sudo dnf install gnuplot
```

MacOS:
```sh
$ brew install gnuplot
```

Check that the install went well (the version may vary depending on the operating systems):
```
$ gnuplot --version
gnuplot 5.4 patchlevel 0
```
