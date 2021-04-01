#!/bin/bash

PAST_TIMESTAMP=$(date +%y%m%d%H%M --date '1 week ago')
CURRENT_TIMESTAMP=$(date +%y%m%d%H%M)

touch -t ${PAST_TIMESTAMP} ./tmp/_.js ./tmp/memo.txt ./tmp/old.js ./tmp.html
touch -t ${CURRENT_TIMESTAMP} ./tmp/todo.html
rm -rf ./backup/*
