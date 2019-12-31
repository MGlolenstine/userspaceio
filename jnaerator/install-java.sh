#!/bin/sh
#
# Install and configure Oracle JDK 8 for Ubuntu/Debian. If JDK was already
# installed with this script then it will be replaced.
# 

# Get architecture
arch=$(uname -m)

# Temp dir for downloads, etc.
tmpdir="$HOME/temp"

# stdout and stderr for commands logged
logfile="$PWD/install-java.log"
rm -f $logfile

# Simple logger
log(){
	timestamp=$(date +"%m-%d-%Y %k:%M:%S")
	echo "$timestamp $1"
	echo "$timestamp $1" >> $logfile 2>&1
}

# JDK archive stuff
javahome=/usr/lib/jvm/jdk1.8.0
# ARM 32
if [ "$arch" = "armv7l" ]; then
	jdkurl="https://cdn.azul.com/zulu-embedded/bin/zulu8.42.0.195-ca-jdk1.8.0_232-linux_aarch32hf.tar.gz"
	jnaplatform="https://github.com/java-native-access/jna/raw/master/lib/native/linux-arm.jar"
# ARM 64
elif [ "$arch" = "aarch64" ]; then
	jdkurl="https://cdn.azul.com/zulu-embedded/bin/zulu8.42.0.195-ca-jdk1.8.0_232-linux_aarch64.tar.gz"
	jnaplatform="https://github.com/java-native-access/jna/raw/master/lib/native/linux-aarch64.jar"
# X86_32
elif [ "$arch" = "i586" ] || [ "$arch" = "i686" ]; then
	jdkurl="https://cdn.azul.com/zulu/bin/zulu8.42.0.23-ca-jdk8.0.232-linux_i686.tar.gz"
	jnaplatform="https://github.com/java-native-access/jna/raw/master/lib/native/linux-x86.jar"
# X86_64	
elif [ "$arch" = "x86_64" ]; then
    jdkurl="https://cdn.azul.com/zulu/bin/zulu8.42.0.23-ca-jdk8.0.232-linux_x64.tar.gz"
	jnaplatform="https://github.com/java-native-access/jna/raw/master/lib/native/linux-x86-64.jar"
fi
jdkarchive=$(basename "$jdkurl")

# JNA jar (4.5.1 causes UnsatisfiedLinkError)
jnajar="repo1.maven.org/maven2/net/java/dev/jna/jna/5.5.0/jna-5.5.0.jar"

log "Installing Java"

# Remove temp dir
log "Removing temp dir $tmpdir"
rm -rf "$tmpdir" >> $logfile 2>&1
mkdir -p "$tmpdir" >> $logfile 2>&1

# Install Zulu Java JDK
log "Downloading $jdkarchive to $tmpdir"
wget -q --directory-prefix=$tmpdir "$jdkurl" >> $logfile 2>&1
log "Extracting $jdkarchive to $tmpdir"
tar -xf "$tmpdir/$jdkarchive" -C "$tmpdir" >> $logfile 2>&1
log "Removing $javahome"
rm -rf "$javahome" >> $logfile 2>&1
# Remove .gz
filename="${jdkarchive%.*}"
# Remove .tar
filename="${filename%.*}"
mkdir -p /usr/lib/jvm >> $logfile 2>&1
log "Moving $tmpdir/$filename to $javahome"
mv "$tmpdir/$filename" "$javahome" >> $logfile 2>&1
update-alternatives --quiet --install "/usr/bin/java" "java" "$javahome/bin/java" 1 >> $logfile 2>&1
update-alternatives --quiet --install "/usr/bin/javac" "javac" "$javahome/bin/javac" 1 >> $logfile 2>&1
# See if JAVA_HOME exists and if not add it to /etc/environment
if grep -q "JAVA_HOME" /etc/environment; then
	log "JAVA_HOME already exists"
else
	# Add JAVA_HOME to /etc/environment
	log "Adding JAVA_HOME to /etc/environment"
	echo "JAVA_HOME=$javahome" >> /etc/environment
	. /etc/environment
	log "JAVA_HOME = $JAVA_HOME"
fi

log "Downloading JNA jars..."
rm -f jna*.jar linux*.jar >> $logfile 2>&1
wget $jnajar >> $logfile 2>&1
wget $jnaplatform >> $logfile 2>&1
$javahome/bin/jar xf $(basename "$jnaplatform") libjnidispatch.so >> $logfile 2>&1
chmod a+x libjnidispatch.so >> $logfile 2>&1
sudo mv libjnidispatch.so /usr/local/lib >> $logfile 2>&1

# Clean up
log "Removing $tmpdir"
rm -rf "$tmpdir"  >> $logfile 2>&1
