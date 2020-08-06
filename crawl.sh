#!/bin/bash
MOSS_NUMBER="0/9857549407492"
MOSS_PREFIX=http://moss.stanford.edu/results/$MOSS_NUMBER

get() {
    wget -O - "$MOSS_PREFIX/$1" | sed -e "s,$MOSS_PREFIX,.,g" > "$1"
}

get index.html

for i in {0..249} ; do
    get "match$i.html"
    get "match$i-0.html"
    get "match$i-1.html"
    get "match$i-top.html"
done;
