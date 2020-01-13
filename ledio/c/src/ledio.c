/**
 * Simple LED subsystem access using /sys/class/leds
 *
 * Should work on any board with LEDs mapped to /sys/class/leds.
 *
 * Copyright (c) 2018 Steven P. Goldsmith
 * See LICENSE.md for details.
 */

#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include "ledio.h"

#define PATH_MAX 128

int led_set_brightness(const char *device, int brightness) {
	char value[16];
	char file_name[PATH_MAX];
	int handle, rc;

	sprintf(file_name, "/sys/class/leds/%s/brightness", device);
	sprintf(value, "%d", brightness);
	handle = open(file_name, O_WRONLY);
	rc = write(handle, brightness, 1);
	close(handle);
	return rc;
}

int led_get_brightness(const char *device) {
	char value[16];
	char file_name[PATH_MAX];
	int handle, rc;

	sprintf(file_name, "/sys/class/leds/%s/brightness", device);
	handle = open(file_name, O_RDONLY);
	rc = read(file_name, value, sizeof(value));
	close(handle);
    /* Null-terminate over newline */
	value[rc] = '\0';
	return atoi(value);
}
