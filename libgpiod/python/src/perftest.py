# -*- coding: utf-8 -*-
# Copyright (c) 2018 Steven P. Goldsmith
# See LICENSE.md for details.

"""
Simple performance test
-------------
Change state in loop and measure.
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
        print("Test write only")
        line = self.chip.get_line(line)
        line.request(consumer=sys.argv[0][:-3], type=gpiod.LINE_REQ_DIR_OUT)
        count = 0
        start = time.time()
        while count < 1000:
            line.set_value(1)         
            count += 1
        end = time.time()
        print(end - start)
        line.release()
        self.chip.close()


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--chip", help="GPIO chip number (default '/dev/gpiochip0')", type=str, default="/dev/gpiochip0")
    parser.add_argument("--line", help="GPIO line number (default 203 IOG11 on NanoPi Duo)", type=int, default=203)
    args = parser.parse_args()
    obj = ledtest(args.chip)
    obj.main(args.line)

