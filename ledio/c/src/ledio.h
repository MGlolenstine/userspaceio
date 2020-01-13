/**
 * Simple LED subsystem access using /sys/class/leds
 *
 * Should work on any board with LEDs mapped to /sys/class/leds.
 *
 * Copyright (c) 2018 Steven P. Goldsmith
 * See LICENSE.md for details.
 */

/**
 * @brief Open PWM device.
 * @param device Number after /sys/class/pwm/pwmchip.
 * @return bytes written (1) or < 0 error.
 */
int led_set_brightness(const char *device, int brightness);

/**
 * @brief Close PWM device.
 * @param device Number after /sys/class/pwm/pwmchip.
 * @return bytes written (1) or < 0 error.
 */
int led_get_brightness(const char *device);
