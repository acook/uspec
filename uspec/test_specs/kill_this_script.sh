#!/usr/bin/env sh

command_exists() { command -v "$1" 1>&- 2>&-; }

THISDIR="$(realpath "$(dirname "$0")")"
ROOTDIR="$(realpath "$THISDIR/../..")"

path="$1"
name="$(basename "$path")"

if ! [ -f "$path" ]; then
  echo "file not found: $path"
  exit 255
fi

mkdir -v -p tmp
if command_exists bundle; then
  bundle exec "$ROOTDIR/bin/uspec" "$path" > "tmp/$name.output" 2>&1 &
else
  "$ROOTDIR/bin/uspec" "$path" > "tmp/$name.output" 2>&1 &
fi

pid=$!
sleep 1
kill --verbose $pid
cat "tmp/$name.output"
rm -v "tmp/$name.output"
