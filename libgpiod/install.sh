#!/bin/sh
#
# Install libgpiod on Armbian mainline.
#
# Run in the libgpiod dir of the userspaceio project.
#

# Git repo
libgpiodurl="https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git"
# Branch (master currently required >= 5.5.0 kernel)
branch="v1.4.x"

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

# Temp dir for downloads, etc.
tmpdir="$HOME/temp"

log "Installing libgpiod"

# See if project already exists
if [ ! -d "$curdir/../../libgpiod" ]; then
	# Check for Armbian
	if [ -e "/etc/armbian-release" ]; then
		# We're dealing with Armbian
        log "Armbian detected"
		. /etc/armbian-release 
		# Build kernel header package name
		if [ -z "$BRANCH" ]
		then
			package="linux-headers-$LINUXFAMILY"
		else
			package="linux-headers-$BRANCH-$LINUXFAMILY"
		fi
	else
		# Not armbian. Assume release and family from uname are correct.
        log "Armbian not detected"
		package="linux-headers-`uname -r`"
	fi
	# Check if package exists
	if apt-cache search "$package" | grep "$package"
	then	
        log "$package found"
        kerver=$(uname -r)
		log "Installing Linux headers $package"
		sudo apt-get install -y $package >> $logfile 2>&1
	else
        log "$package not found, you must install correct kernel headers"
        exit 1
	fi
	log "Installing required build packages"
	sudo apt-get install -y libtool pkg-config autoconf-archive python3-dev >> $logfile 2>&1
	# Move to home dir
	cd $curdir/../../ >> $logfile 2>&1
	log "Cloning libgpiod $branch"
	git clone -b $branch $libgpiodurl >> $logfile 2>&1
	cd libgpiod >> $logfile 2>&1
	# Add header file missing from Linux user space includes
	mkdir -p $curdir/include/linux >> $logfile 2>&1
	cp /usr/src/linux-headers-$kerver/include/linux/compiler_types.h $curdir/include/linux/. >> $logfile 2>&1	
	log "Running autogen"
	export PYTHON_VERSION=3
	./autogen.sh --enable-tools=yes --enable-bindings-python --prefix=/usr/local CFLAGS="-I/usr/src/linux-headers-$kerver/include/uapi -I$curdir/include" >> $logfile 2>&1
	log "Running make"
	make >> $logfile 2>&1
	log "Make install"
	sudo make install >> $logfile 2>&1
	sudo ldconfig >> $logfile 2>&1
fi

log "Done"
