#!/usr/bin/env sh

path="$1"
name="$(basename "$path")"

mkdir -v -p tmp
bundle exec uspec "$path" > "tmp/$name.output" 2>&1 &
pid=$!
sleep 1
kill $pid
cat "tmp/$name.output"
rm -v "tmp/$name.output"
