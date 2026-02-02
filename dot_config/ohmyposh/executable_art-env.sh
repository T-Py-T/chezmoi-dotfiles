#!/usr/bin/env bash

if [ -f service.json ] &&  which art &> /dev/null; then
  (art envs --output=plain | cut -d'-' -f1 | sort | uniq | paste -s -d, -) 2>/dev/null
fi
