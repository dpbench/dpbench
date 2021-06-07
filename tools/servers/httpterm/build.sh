#!/bin/bash

cd -P $(dirname $0)
BIN="${PWD%/*/*/*}/bin"

run() {
  echo "  RUN   $*"
  command "$@"
}

if [ ! -e "source/Makefile" ]; then
  echo "httpterm source not found in 'source', trying to update submodule"
  run git submodule update source
  if [ ! -e "source/Makefile" ]; then
    echo "Couldn't retrieve usable httpterm source. Please try to fix the condition"
    echo "and run 'git submodule update source' from this directory."
    exit 1
  fi
fi

nproc=$(nproc 2>/dev/null)
[ -n "$nproc" -a -z "${nproc##[0-9]*}" ] || nproc=1

cd source
if make -j$nproc && mkdir -p "$BIN" && cp -v httpterm "$BIN"/; then
  make clean
  cd ..
  echo
  echo "Done! The httpterm executable is now in $BIN"
  exit 0
else
  echo
  echo "Failed! Please try to fix build errors and start again, or copy the"
  echo "'httpterm' executable into $BIN/"
  exit 1
fi
