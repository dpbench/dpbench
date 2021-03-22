#!/bin/sh

cd -P $(dirname $0)
BIN="${PWD%/*/*/*}/bin"

chmod +x vmstat.sh
if mkdir -p "$BIN" && cp -v vmstat.sh "$BIN"/; then
  echo
  echo "Done! The vmstat.sh executable is now in $BIN"
  exit 0
else
  echo
  echo "Failed! Please try to fix errors and start again, or copy the"
  echo "'vmstat.sh' executable into $BIN/"
  exit 1
fi
