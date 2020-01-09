package com.codeferm.demo;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

import com.sun.jna.NativeLong;
import com.sun.jna.Pointer;

import gpiod.GpiodLibrary;
import gpiod.gpiod_chip;
import gpiod.gpiod_line;
import gpiod.timespec;

/**
 * HC-SR501 sensor example using contextless event loop to implement blocking
 * callback. This uses two GPIO devices for the Duo.
 * 
 * Monitor rising edge (motion detected) and falling edge (no motion). If LED is
 * wired up then motion detection lights LED.
 * 
 * Copyright (c) 2018 Steven P. Goldsmith See LICENSE.md for details.
 */

public class Hcsr501 {

	public static void main(String args[]) throws InterruptedException {
		String device0 = "/dev/gpiochip0";
		String device1 = "/dev/gpiochip1";
		int hcsr501LineNum = 11;
		int ledLineNum = 203;
		// See if there are args to parse
		if (args.length > 0) {
			// GPIO device (default "/dev/gpiochip1")
			device1 = args[0];
			// GPIO line number (default 11 IRRX on NanoPi Duo)
			hcsr501LineNum = Integer.parseInt(args[1]);
			// GPIO device (default "/dev/gpiochip0")
			device0 = args[2];
			// GPIO line number (default 203 IOG11 on NanoPi Duo)
			ledLineNum = Integer.parseInt(args[3]);
		}
		// Use class name for consumer
		final String consumer = Hcsr501.class.getSimpleName();
		// Load library
		final GpiodLibrary lib = GpiodLibrary.INSTANCE;
		final gpiod_chip chip = lib.gpiod_chip_open(device0);
		gpiod_line line = lib.gpiod_chip_get_line(chip, ledLineNum);
		lib.gpiod_line_request_output(line, consumer, 0);
		// Timestamp formatter
		final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm:ss");
		// Use lambda for callback
		final GpiodLibrary.gpiod_ctxless_event_handle_cb func = (int evtype, int offset, timespec timeSpec,
				Pointer data) -> {
			int rc = GpiodLibrary.GPIOD_CTXLESS_EVENT_CB_RET_ERR;
			if (evtype == GpiodLibrary.GPIOD_CTXLESS_EVENT_CB_TIMEOUT) {
				rc = GpiodLibrary.GPIOD_CTXLESS_EVENT_CB_RET_STOP;
				System.out.println("Timed out");
			} else {
				rc = GpiodLibrary.GPIOD_CTXLESS_EVENT_CB_RET_OK;
				final LocalDateTime date = LocalDateTime
						.ofInstant(Instant.ofEpochMilli(timeSpec.tv_sec.longValue() * 1000), ZoneId.systemDefault());
				if (evtype == GpiodLibrary.GPIOD_CTXLESS_EVENT_CB_RISING_EDGE) {
					System.out.println(String.format("Motion detected %s", date.format(formatter)));
					// LED on
					lib.gpiod_line_set_value(line, 1);
				} else {
					System.out.println(String.format("No motion       %s", date.format(formatter)));
					// LED off
					lib.gpiod_line_set_value(line, 0);
				}
			}
			return rc;
		};
		System.out.println("HC-SR501 motion detector, timeout in 30 seconds\n");
		// Blocking poll until timeout, note gpiod_simple_event_poll_cb is passed as a
		// NULL
		if (lib.gpiod_ctxless_event_loop(device1, hcsr501LineNum, (byte) 0, consumer,
				new timespec(new NativeLong(30), new NativeLong(0)), null, func, null) != 0) {
			System.out.println("gpiod_simple_event_loop error, check chip and line values");
		}
		// LED off
		lib.gpiod_line_set_value(line, 0);
		lib.gpiod_line_release(line);
		lib.gpiod_chip_close(chip);
	}
}
