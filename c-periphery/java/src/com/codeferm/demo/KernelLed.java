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
		int rc = lib.led_open(handle, "nanopi:green:pwr");
		System.out.println(rc);
		lib.led_close(handle);
		lib.led_free(handle);
	}
}
