package com.codeferm.demo;

import java.util.concurrent.TimeUnit;

import gpiod.GpiodLibrary;
import gpiod.gpiod_chip;
import gpiod.gpiod_line;

/**
 * Using the NanoPi Duo connect a 220Ω resistor to ground, then the resistor to
 * the cathode (the short pin) of the LED. Connect the anode (the long pin) of
 * the LED to line 203 (IOG11).
 * 
 * See images/ledtest.jpg for schematic.
 * 
 * Copyright (c) 2018 Steven P. Goldsmith See LICENSE.md for details.
 */

public class LedTest {

	public static void main(String args[]) throws InterruptedException {
		String device = "/dev/gpiochip0";
		int lineNum = 203;
		// See if there are args to parse
		if (args.length > 0) {
			// GPIO device (default "/dev/gpiochip0")
			device = args[0];
			// GPIO line number (default 203 IOG11 on NanoPi Duo)
			lineNum = Integer.parseInt(args[1]);
		}
		// Use to debug if JNA cannot find shared library
		System.setProperty("jna.debug_load", "false");
		System.setProperty("jna.debug_load.jna", "false");
		// Use class name for consumer
		final String consumer = LedTest.class.getSimpleName();
		// Load library
		final GpiodLibrary lib = GpiodLibrary.INSTANCE;
		final gpiod_chip chip = lib.gpiod_chip_open(device);
		// Verify the chip was opened
		if (chip != null) {
			final gpiod_line line = lib.gpiod_chip_get_line(chip, lineNum);
			// Verify we have line
			if (line != null) {
				// This will set line for output and set initial value (LED off)
				if (lib.gpiod_line_request_output(line, consumer, 0) == 0) {
					for (int i = 0; i < 10; i++) {
						// LED on
						System.out.println("\nLED on");
						lib.gpiod_line_set_value(line, 1);
						TimeUnit.SECONDS.sleep(1);
						// LED off
						lib.gpiod_line_set_value(line, 0);
						System.out.println("LED off");
						TimeUnit.SECONDS.sleep(1);
					}
				} else {
					System.out.println(String.format("Unable to set line %d to output", lineNum));
				}
				lib.gpiod_line_release(line);
			} else {
				System.out.println(String.format("Unable to get line %d", lineNum));
			}
			lib.gpiod_chip_close(chip);
		} else {
			System.out.println(String.format("Unable to open chip %d", device));
		}
	}
}
