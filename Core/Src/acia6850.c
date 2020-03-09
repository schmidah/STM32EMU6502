#include <stdbool.h>

#include "acia6850.h"
#include "usbd_cdc_if.h"

// Motorola MC6850 Asynchronous Communications Interface Adapter (ACIA) emulation

// http://www.cpcwiki.eu/index.php/6850_ACIA_chip
// http://www.cpcwiki.eu/imgs/3/3f/MC6850.pdf
//

#define ACIAControl 0
#define ACIAStatus 0
#define ACIAData 1

// "MC6850 Data Register (R/W) Data can be read when Status.Bit0=1, and written when Status.Bit1=1."
#define RDRF (1 << 0)
#define TDRE (1 << 1)


uint8_t input[ACIA_IN_BUFF_SIZE] = {0};
uint16_t input_index = 0;
uint16_t input_processed_index = 0;

uint8_t read6850(uint16_t address) {
	switch(address & 1) {
		case ACIAStatus: {
            // Always writable
            uint8_t flags = TDRE;

            // Readable if there is pending user input data which wasn't read
            if (input_processed_index != input_index) flags |= RDRF;

            return flags;
			break;
        }
		case ACIAData: {
            char data = input[input_processed_index++];
            input_processed_index %= sizeof(input);

            return data;
			break;
        }
		default:
            break;
	}

	return 0xff;
}

void write6850(uint16_t address, uint8_t value) {
	switch(address & 1) {
		case ACIAControl:
            // TODO: decode baudrate, mode, break control, interrupt
			break;

		case ACIAData:
			{
				uint8_t buf[1];
				buf[0] = value;

				while( CDC_Transmit_FS( buf, sizeof(buf) ) == USBD_BUSY );
			}
			break;

		default:
            break;
	}
}



