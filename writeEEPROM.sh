#!/bin/bash
file="$1"
./vasm6502_oldstyle -c02 -Fbin -dotdir "$file" && 
hexdump a.out &&
# brew install minipro
minipro -p AT28C256 -w a.out
rm a.out