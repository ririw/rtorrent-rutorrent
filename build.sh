#!/bin/bash
set -e
set -x
docker build $1 $2 -t "ririw/rtorrent-rutorrent" .

