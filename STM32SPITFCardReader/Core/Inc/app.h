/*
 * app.h
 *
 *  Created on: Jan 21, 2023
 *      Author: TK
 */

#ifndef INC_APP_H_
#define INC_APP_H_

#include <stdio.h>
#include <string.h>

#include "stm32f4xx_hal.h"

#include "sdcard_spi.h"

void APP_init();

void APP_main();

#endif /* INC_APP_H_ */
