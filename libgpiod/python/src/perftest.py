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
        numtests = 1000000
        print("Test set")
        line = self.chip.get_line(line)
        line.request(consumer=sys.argv[0][:-3], type=gpiod.LINE_REQ_DIR_OUT)
        count = 0
        start = time.time()
        while count < numtests:
            line.set_value(1)         
            count += 1
        end = time.time()
        elapsed = end - start
        print(numtests / elapsed)
        print("Test get")
        line.release()
        line.request(consumer=sys.argv[0][:-3], type=gpiod.LINE_REQ_DIR_IN)
        count = 0
        start = time.time()
        while count < numtests:
            line.get_value()         
            count += 1
        end = time.time()
        elapsed = end - start
        print(numtests / elapsed)
        line.release()
        self.chip.close()


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--chip", help="GPIO chip number (default '/dev/gpiochip0')", type=str, default="/dev/gpiochip0")
    parser.add_argument("--line", help="GPIO line number (default 203 IOG11 on NanoPi Duo)", type=int, default=203)
    args = parser.parse_args()
    obj = ledtest(args.chip)
    obj.main(args.line)

