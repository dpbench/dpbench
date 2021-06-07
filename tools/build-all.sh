#!/bin/bash

cd -P $(dirname $0)
BIN="${PWD%/*}/bin"

success=()
failure=()
for i in */*/build.sh; do
	dir=${i%/build.sh}
	echo;echo "### Entering $dir";echo
	if command $i; then
		success=(${success[@]} $dir)
	else
		echo "*** Failed to build ${dir##*/} ***"
		failure=(${failure[@]} $dir)
	fi
done

echo "### done"
echo

if [ ${#failure[@]} -gt 0 ]; then
	echo "Errors were met in the following directories:"
	for i in ${failure[@]}; do
		echo "  $i"
	done
	echo
fi

if [ ${#success[*]} -gt 0 ]; then
	echo "The following directories were successfully built:"
	for i in ${success[@]}; do
		echo "  $i"
	done
	echo "The resulting binaries should now be in $BIN/"
fi
