# -*- coding: utf-8 -*-
# Copyright (c) 2018 Steven P. Goldsmith
# See LICENSE.md for details.

"""
LED test 
-------------

Access Linux userspace sysfs LEDs.
"""

import time
from argparse import *
from cffi import FFI
from libperiphery import libperipheryled


class sysled:
    
    def __init__(self):
        """Create library and ffi interfaces.
        """         
        self.led = libperipheryled.libperipheryled()
        self.lib = self.led.lib
        self.ffi = self.led.ffi
        
    def main(self, device):
        """FLash system LED on/off.
        """         
        handle = self.led.open(device)
        count = 0
        while count < 10:
            self.led.setBrightness(handle, 1)       
            print("\nLED on")
            time.sleep(1)
            # LED off
            self.led.setBrightness(handle, 0)       
            print("LED off")
            time.sleep(1)
            count += 1
        self.led.close(handle)

        
if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--device", help="LED device name (default 'nanopi:green:pwr')", type=str, default="nanopi:green:pwr")
    args = parser.parse_args()    
    obj = sysled()
    obj.main(args.device)
