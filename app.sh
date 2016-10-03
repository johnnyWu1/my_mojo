#!/bin/sh
echo "begin start"
sh qq.sh & 
p1=$!
sh weixin.sh &
p2=$!
echo "begin..."
# perl ./qq.pl
wait $p1 && wait $p2