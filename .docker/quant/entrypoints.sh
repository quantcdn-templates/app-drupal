#!/bin/bash

# This script will be the default ENTRYPOINT for all children docker images.

if [ -d /quant/entrypoints ]; then
  for i in /quant/entrypoints/*; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

exec "$@"