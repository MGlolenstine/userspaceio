# -*- coding: utf-8 -*-
# Copyright (c) 2018 Steven P. Goldsmith
# See LICENSE.md for details.

"""
Simple LED blink
-------------
Using the NanoPi Duo connect a 220Ω resistor to ground, then the resistor to
the cathode (the short pin) of the LED. Connect the anode (the long pin) of the
LED to line 203 (IOG11).
"""

import sys, time, gpiod
from argparse import *


class ledtest:
    
    def __init__(self, chip):
        """Initialize GPIO chip.
        """         
        self.chip = gpiod.Chip(chip, gpiod.Chip.OPEN_BY_PATH)
    
    def main(self, line):
        """Turn LED on and off.
        """
        print("Name: %s, label: %s, lines: %d" % (self.chip.name(), self.chip.label(), self.chip.num_lines()))
        line = self.chip.get_line(line)
        line.request(consumer=sys.argv[0][:-3], type=gpiod.LINE_REQ_DIR_OUT)
        count = 0
        while count < 10:
            line.set_value(1)         
            print("\nLED on")
            time.sleep(1)
            # LED off
            line.set_value(0)
            print("LED off")
            time.sleep(1)
            count += 1
        line.release()
        self.chip.close()


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--chip", help="GPIO chip number (default '/dev/gpiochip0')", type=str, default="/dev/gpiochip0")
    parser.add_argument("--line", help="GPIO line number (default 203 IOG11 on NanoPi Duo)", type=int, default=203)
    args = parser.parse_args()
    obj = ledtest(args.chip)
    obj.main(args.line)
