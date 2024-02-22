#!/usr/bin/env sh

command_exists() { command -v "$1" 1>&- 2>&-; }

THISDIR="$(realpath "$(dirname "$0")")"
ROOTDIR="$(realpath "$THISDIR/../..")"

path="$1"

if ! [ -f "$path" ]; then
  echo "file not found: $path"
  exit 255
fi

if command_exists bundle; then
  echo running with bundler
  bundle exec "$ROOTDIR/bin/uspec" "$path" 2>&1 &
  pid="$!"
else
  echo running directly
  "$ROOTDIR/bin/uspec" "$path" 2>&1 &
  pid="$!"
fi

sleep 1
kill "$pid"
