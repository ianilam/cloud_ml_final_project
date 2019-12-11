#!/usr/bin/expect -f
set timeout -1
set basedir [lindex $argv 0];

spawn $basedir/y-cruncher/y-cruncher

expect "option:"

# Benchmark pi
send -- "0\r"

expect "option:"

# 25,000,000 digits of pi
send -- "1\r"

expect "Validation File:"

interact
