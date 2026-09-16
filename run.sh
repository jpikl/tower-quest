#!/usr/bin/env sh

print_and_exec() {
  echo "Executing: " "$@"
  "$@"
}

if command -v love >/dev/null; then
  print_and_exec love . "$@"
else
  echo "No 'love' executable found"
  echo "Download and install LOVE 2d from https://love2d.org"
fi
