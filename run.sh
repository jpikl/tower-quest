#!/bin/sh

LOVE=/usr/bin/love

print_and_exec() {
  echo "Executing: " "$@"
  "$@"
}

if [ -x $LOVE ]; then
  print_and_exec $LOVE . "$@"
else
  echo "No $LOVE executable found"
  echo "Download and install LOVE 2d from https://love2d.org"
fi
