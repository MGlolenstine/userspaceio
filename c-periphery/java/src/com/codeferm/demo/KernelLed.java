package com.codeferm.demo;

import java.util.concurrent.TimeUnit;
import com.sun.jna.ptr.PointerByReference;
import peripheryled.PeripheryledLibrary;

/**
 * 
 * Copyright (c) 2018 Steven P. Goldsmith See LICENSE.md for details.
 */

public class KernelLed {

	public static void main(String args[]) throws InterruptedException {
		// Load JNA library
		final PeripheryledLibrary lib = PeripheryledLibrary.INSTANCE;
		final PointerByReference handle = lib.led_new();
		lib.led_open(handle, "nanopi:green:pwr");
		for (int i = 0; i < 10; i++) {
			// LED on
			System.out.println("\nLED on");
			lib.led_set_brightness(handle, 1);
			TimeUnit.SECONDS.sleep(1);
			// LED off
			lib.led_set_brightness(handle, 0);
			System.out.println("LED off");
			TimeUnit.SECONDS.sleep(1);
		}
		lib.led_close(handle);
	}
}
