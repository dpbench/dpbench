#!/bin/sh

cd -P $(dirname $0)

run() {
  echo "  RUN   $*"
  command "$@"
}

if [ ! -e "source/Makefile" ]; then
  echo "h1load source not found in 'source', trying to update submodule"
  run git submodule update source
  if [ ! -e "source/Makefile" ]; then
    echo "Couldn't retrieve usable h1load source. Please try to fix the condition"
    echo "and run 'git submodule update source' from this directory."
    exit 1
  fi
fi

nproc=$(nproc 2>/dev/null)
[ -n "$nproc" -a -z "${nproc##[0-9]*}" ] || nproc=1

cd source
if make -j$nproc && mkdir -p ../bin && cp -v h1load ../bin/; then
  make clean
  cd ..
  echo
  echo "Done! The h1load executable is now in $PWD/bin"
  exit 0
else
  echo
  echo "Failed! Please try to fix build errors and start again, or copy the"
  echo "'h1load' executable into bin/"
  exit 1
fi

