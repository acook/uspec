#!/usr/bin/env sh

THISDIR="$(realpath "$(dirname "$0")")"
ROOTDIR="$(realpath "$THISDIR/../..")"

path="$1"
name="$(basename "$path")"

mkdir -v -p tmp
bundle exec "$ROOTDIR/bin/uspec" "$path" > "tmp/$name.output" 2>&1 &
pid=$!
sleep 1
kill $pid
cat "tmp/$name.output"
rm -v "tmp/$name.output"
