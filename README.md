![Title](images/title.png)

User Space IO is Python 3 and Java 8 bindings for Linux user space GPIO, SPI,
I2C, PWM, MMIO, LED and Serial interfaces. Using best of breed user space C libraries
provides a cross platform solution to SBC development. Primarly User Space IO
will be targeting [Armbian](https://www.armbian.com), but the scripts should
work with most Ubuntu/Debian distributions. Demo applications are included that
illustrate how to leverage the bindings.

The idea is to have consistent APIs across C, Python and JVM languages without
having to use hacked up RPi.GPIO or Wiring Pi implementations for each distinct
SBC model. The possibility of using other JVM based languages such as Groovy,
Kotlin, Scala, etc. opens up language opprtunties that do not currently exist
in the IoT space.

### SBC configuration
* If you are using Armbian then use `armbian-config` or edit `/boot/armbianEnv.txt`
to configure various devices. User space devices are exposed through /dev or
/sys. Verify the device is showing up prior to trying demo programs.
* If you are not using Armbian then you will need to know how to configure
devices to be exposed to user space for your Linux distribution and SBC model.
Check each log to be sure there were no errors after running install.sh. Submit
a PR if you would like a different distribution supported. Conditionals can be
added to the current scripts to handle different detectable distributions. 
* You need kernel 4.8 or greater to use libgpiod.
* You need kernel 4.16 or greater to use non-root access for PWM.
* I have tested NanoPi Duo v1.1 for 32 bit and NanoPi Neo 2 Plus for 64 bit using
the latest Armbian release. The ability to switch seemlessly between 32 and 64
bit platforms gives you a wide range of SBC choices.

### Python bindings notes
[CFFI](https://cffi.readthedocs.io/en/latest) is used to create the Python 3
bindings.

### Java bindings notes
[JNAerator](https://github.com/nativelibs4java/JNAerator) is used to create
Java bindings from the C header files. I added some post generation patching
(see java-bindings.sh) to fix a couple of issues with the generated code.
**Note:** JNAerator fails on ARMv8 (64 bit) with "architecture word width
mismatch" because there is no ARMv8 version of the native library libbridj.so.
This is not an issue since the Java bytecode compiled on ARMv7 works without
the need to recompile. The wrapper script skips the JNAerator steps and just
compiles the demos with the precompiled jars included in the project.

If you get the following error:
```
There is an incompatible JNA native library installed on this system
Expected: 1.2.3
Found:    4.5.6
```

See [issue](https://github.com/sbt/io/issues/110) on Github. Basically you can add JVM arg
`-Djna.nosys=true`.

## Download project
* `cd ~/`
* `git clone --depth 1 https://github.com/sgjava/userspaceio.git`

## Install script
* `cd ~/userspaceio`
* `./install.sh`
* Check various log files if you have issues running the demo code. Something
could have gone wrong during the build/bindings generation processes.

## Non-root access
If you want to access devices without root do the following (you can try udev
rules instead if you wish):
* `sudo usermod -a -G dialout username` (Use a non-root username)
* `sudo groupadd usio username`
* `sudo usermod -a -G usio username` (Use a non-root username)
* `sudo gpiodetect` (Note chip names to add below for libgpiod access)
* `ls /dev/spidev*` (Note SPI channels below)
* `ls /dev/i2c*` (Note i2c devices below)
* `sudo nano /etc/rc.local`
<pre><code>chown -R root:usio /dev/gpiochip0
chmod -R ug+rw /dev/gpiochip0
chown -R root:usio /dev/gpiochip1
chmod -R ug+rw /dev/gpiochip1
chown -R root:usio /dev/i2c-0
chmod -R ug+rw /dev/i2c-0
chown -R root:usio /dev/spidev1.0
chmod -R ug+rw /dev/spidev1.0
chown -R root:usio /sys/devices/platform/leds/leds
chmod -R ug+rw /sys/devices/platform/leds/leds</code></pre>

## libgpiod
[libgpiod](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/tree/README)
is a C library and tools for interacting with the linux GPIO character device.
Since linux 4.8 the GPIO sysfs interface is deprecated. User space should use
the character device instead. libgpiod encapsulates the ioctl calls and data
structures behind a straightforward API.

**v1.4.x branch is used since master requires >= 5.5.0 kernel.**

Edit [install.sh](https://github.com/sgjava/userspaceio/blob/master/libgpiod/install.sh) as
needed.
* Change branch to master or other branch. 

#### How pins are mapped
This is based on testing on a NanoPi Duo. gpiochip0 starts at 0 and gpiochip1
start at 352. Consider the following table:

|Name                           |Chip Name |Line|sysfs|
| ----------------------------- | -------- | -- | --- |
|DEBUG_TX(UART_TXD0)/GPIOA4     |gpiochip0 | 004|  004|
|DEBUG_RX(UART_RXD0)/GPIOA5/PWM0|gpiochip0 | 005|  005|
|I2C0_SCL/GPIOA11               |gpiochip0 | 011|  011|
|I2C0_SDA/GPIOA12               |gpiochip0 | 012|  012|
|UART3_TX/SPI1_CS/GPIOA13       |gpiochip0 | 013|  013|
|UART3_RX/SPI1_CLK/GPIOA14      |gpiochip0 | 014|  014|
|UART3_RTS/SPI1_MOSI/GPIOA15    |gpiochip0 | 015|  015|
|UART3_CTS/SPI1_MISO/GPIOA16    |gpiochip0 | 016|  016|
|UART1_TX/GPIOG6                |gpiochip0 | 198|  198|
|UART1_RX/GPIOG7                |gpiochip0 | 199|  199|
|GPIOG11                        |gpiochip0 | 203|  203|
|ON BOARD BUTTON                |gpiochip1 | 003|  355|
|GPIOL11/IR-RX                  |gpiochip1 | 011|  363|

So basically you just need to know the starting number for each chip and realize
libgpiod always starts at 0 and calculate the offset. Thus gpiochip1 starts at
352 and the on board button is at 355, so 355 - 352 = 3 for libgpiod.

#### Python bindings
libgpiod includes Python bindings, so CFFI is not used.

To run demos:
* `alias python=python3`
* `export PYTHONPATH=/usr/local/lib/python3.6/site-packages`
* `cd ~/userspaceio/libgpiod/python/src`
* `python ledtest.py --chip /dev/gpiochip0 --line 203` to run LED test after wiring up to
line 203 (GPIOG11) on NanoPi Duo (the default). 

#### Java bindings
To run demos:
* `cd ~/userspaceio/libgpiod/java`
* `java -Djava.library.path=/usr/local/lib -cp ../../jnaerator/jna-5.5.0.jar:../../jnaerator/jnaerator-runtime.jar:libgpiod.jar:demo.jar com.codeferm.demo.LedTest /dev/gpiochip0 203`
to run LED test after wiring up to line 203 (GPIOG11) on NanoPi Duo (the default). 

## c-periphery
[c-periphery](https://github.com/vsergeev/c-periphery) is used to provide SPI,
I2C, MMIO and Serial interfaces. I did not use the GPIO because it is based on the
oudated sysfs interface. Helper methods were added to the objects to remove some
repetitive operations (i.e. building I2C messages to read/write registers).

#### Python bindings
To run demos:
* `alias python=python3`
* `cd ~/userspaceio/c-periphery/python/src`
* `python spiloopback.py  --device /dev/spidev1.0 --maxSpeed 500000` to run
SPI loop back on NanoPi Duo (the default). Use a jumper wire between MI and MO. 

#### Java bindings
To run demos:
* `cd ~/userspaceio/c-periphery/java`
* `java -Djava.library.path=/usr/local/lib -cp ../../jnaerator/jna-5.5.0.jar:../../jnaerator/jnaerator-runtime.jar:libperiphery.jar:demo.jar com.codeferm.demo.Mpu6050`
to run Triple Axis Accelerometer & Gyro MPU-6050 sensor example. 

## pwmio
I wasn't able to find a good C library that handled hardware PWM, so I worte one
based on /sys/class/pwm. Your SBC must support hardware PWM and be exposed to
the kernel via /sys/class/pwm.

[![LED flash video](images/ledflash.mp4.png)](https://youtu.be/K4PbIpPA1dg)

#### Python bindings
To run demos:
* `cd ~/userspaceio/pwmio/python/src`
* `sudo python3 ledflash.py  --device 0 --pwm 0` to run
I wired up the LED to the PWM pin. 

#### Java bindings
To run demos:
* `cd ~/userspaceio/pwmio/java`
* `sudo java -Djava.library.path=/usr/local/lib -cp ../../jnaerator/jna-5.5.0.jar:../../jnaerator/jnaerator-runtime.jar:libpwmio.jar:demo.jar com.codeferm.demo.LedFlash`
to make LED flash and increase intensity. 

### References
* [libgpiod](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/tree/README)
* [c-periphery](https://github.com/vsergeev/c-periphery)
* [Learn More About Linux’s New GPIO User Space Subsystem & Libgpiod](https://www.cnx-software.com/2017/11/03/learn-more-about-linuxs-new-gpio-user-space-subsystem-libgpiod)
