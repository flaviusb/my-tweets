#!/bin/bash

touch tweets.txt
thedate=`date +%a\ %b\ %d\ %Y\ %X\ GMT%z\ \(%Z\)`»
echo $thedate
(tmpfile=`mktemp` && { echo "${thedate}
$1" | cat - tweets.txt > $tmpfile && mv $tmpfile tweets.txt; } )
echo "cd ~ && pwd && . ./.bashrc && cd code/tweets && git pull && coffee post.coffee \"$1\" && byeloblog.ik" | ssh flaviusb@flaviusb.net
