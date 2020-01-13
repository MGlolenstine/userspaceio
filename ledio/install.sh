#!/bin/sh
#
# Install pwmio.
#
# Run in the pwmio dir of the userspaceio project.
#

# Get current directory
curdir=$PWD

# stdout and stderr for commands logged
logfile="$curdir/install.log"
rm -f $logfile

# Simple logger
log(){
	timestamp=$(date +"%m-%d-%Y %k:%M:%S")
	echo "$timestamp $1"
	echo "$timestamp $1" >> $logfile 2>&1
}

log "Installing ledio"
cd $curdir/c >> $logfile 2>&1

# Clean up
rm -f *.o *.so ledtest 2>&1

# Compile pwmio as shared library
gcc -c -Wall -O2 -fPIC src/ledio.c 2>&1

# Link objects
ld -shared ledio.o -o libledio.so 2>&1

# Deploy shared library
sudo cp libledio.so /usr/local/lib/. 2>&1

# Compile test program
gcc -c -Wall -O2 -fPIC src/ledtest.c 2>&1

# Link
gcc ledtest.o -lledio -o ledtest 2>&1

sudo ldconfig 2>&1

log "Done"
