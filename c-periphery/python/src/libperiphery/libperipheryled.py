# -*- coding: utf-8 -*-
# Copyright (c) 2020 Steven P. Goldsmith
# See LICENSE.md for details.

"""
libperipheryled CFFI interface for LED access
-------------

LED wrapper functions for Linux userspace sysfs LEDs.
Helper methods added to handle repetitive operations.

To get LED names use:

cd /sys/class/leds
ls -1F
"""

from cffi import FFI


class libperipheryled:

    def __init__(self):
        self.ffi = FFI()
        # Specify each C function, struct and constant you want a Python binding for
        # Copy-n-paste with minor edits
        self.ffi.cdef("""
        enum led_error_code {
            LED_ERROR_ARG       = -1,
            LED_ERROR_OPEN      = -2,
            LED_ERROR_QUERY     = -3,
            LED_ERROR_IO        = -4,
            LED_ERROR_CLOSE     = -5,
        };
        
        struct led_handle {
            char name[64];
            unsigned int max_brightness;
        
            struct {
                int c_errno;
                char errmsg[96];
            } error;
        };              
        
        typedef struct led_handle led_t;
        
        led_t *led_new(void);
        
        int led_open(led_t *led, const char *name);
        
        int led_read(led_t *led, bool *value);
        
        int led_write(led_t *led, bool value);
        
        int led_close(led_t *led);
        
        void led_free(led_t *led);
        
        int led_get_brightness(led_t *led, unsigned int *brightness);
        
        int led_get_max_brightness(led_t *led, unsigned int *max_brightness);
        
        int led_set_brightness(led_t *led, unsigned int brightness);
        
        int led_name(led_t *led, char *str, size_t len);
        
        int led_tostring(led_t *led, char *str, size_t len);
        
        int led_errno(led_t *led);
        
        const char *led_errmsg(led_t *led);
        """)
        self.lib = self.ffi.dlopen("/usr/local/lib/libperipheryled.so")

    def open(self, device):
        """Open LED device and return handle.
        """
        handle = self.lib.led_new()
        if self.lib.led_open(handle, device.encode('utf-8')) < 0:
            raise RuntimeError(self.ffi.string(self.lib.led_errmsg(handle)).decode('utf-8'))
        return handle

    def close(self, handle):
        """Close I2C device.
        """
        if self.lib.led_close(handle) < 0:
            raise RuntimeError(self.ffi.string(self.lib.led_errmsg(handle)).decode('utf-8'))
        else:
            self.lib.i2c_free(handle)
        
    def setBrightness(self, handle, value):
        """Write value to led brightness register.
        """
        # Transfer a transaction with one I2C message
        if self.lib.led_set_brightness(handle, value) < 0:
            raise RuntimeError(self.ffi.string(self.lib.led_errmsg(handle)).decode('utf-8'))
