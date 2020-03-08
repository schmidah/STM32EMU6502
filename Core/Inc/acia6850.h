#ifndef ACIA6850_H_
#define ACIA6850_H_

#include <stdint.h>

#define ACIA_IN_BUFF_SIZE	( 256 )

extern uint8_t input[ACIA_IN_BUFF_SIZE];
extern uint16_t input_index;

uint8_t read6850(uint16_t address);
void write6850(uint16_t address, uint8_t value);

#endif
