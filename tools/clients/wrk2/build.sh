#!/bin/bash

cd -P $(dirname $0)
BIN="${PWD%/*/*/*}/bin"

run() {
  echo "  RUN   $*"
  command "$@"
}

if [ ! -e "source/Makefile" ]; then
  echo "wrk2 source not found in 'source', trying to update submodule"
  run git submodule update source
  if [ ! -e "source/Makefile" ]; then
    echo "Couldn't retrieve usable wrk2 source. Please try to fix the condition"
    echo "and run 'git submodule update source' from this directory."
    exit 1
  fi
fi

nproc=$(nproc 2>/dev/null)
[ -n "$nproc" -a -z "${nproc##[0-9]*}" ] || nproc=1

cd source
if make -j$nproc && mkdir -p "$BIN" && cp -v wrk "$BIN"/wrk2; then
  make clean
  cd ..
  echo
  echo "Done! The wrk2 executable is now in $BIN"
  exit 0
else
  echo
  echo "Failed! Please try to fix build errors and start again, or copy the"
  echo "'wrk' executable into $BIN/wrk2"
  exit 1
fi
