#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include "ledio.h"

int main(void) {
	int rc, i;

	/* Flash onboard power LED */
	for (i = 1; i < 10; i += 1) {
		rc = led_set_brightness("nanopi\:green\:pwr", 1);
		printf("Led on = %d\n", rc);
		// Sleep for a second
		usleep(1000000);
		rc = led_set_brightness("nanopi\:green\:pwr", 0);
		printf("Led off = %d\n", rc);
		// Sleep for a second
		usleep(1000000);
	}
	return 0;
}
