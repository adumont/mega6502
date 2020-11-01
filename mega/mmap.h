//Overview of memory map:
// main 1KB RAM                               0x000-0x3FF
// available for 4K RAM expansion             0x0400-13FF
// I/O and timer of 6530-003, free for user   0x1700-0x173F
// I/O and timer of 6530-002, used by KIM     0x1740-0x177F
// RAM from 6530-003                          0x1780-0x17BF, free for user
// RAM from 6530-002                          0x17C0-0x17FF, free for user except 0x17E7-0x17FF
// rom003 is                                  0x1800-0x1BFF
// rom002 is                                  0x1C00-0x1FFF

// note that above 8K map is replicated 8 times to fill 64K, and that rom002 contains used addresses for:
//               FFFA, FFFB - NMI Vector
//               FFFC, FFFD - RST Vector
//               FFFE, FFFF - IRQ Vector
// --> so emulator should mirror the 8K memory map at least to the upper 8K block.

// Keyboard/LED(1) or TTY(0).
// If we decide to support LED/Keyboard in the future...
#define USE_KEYBOARD_LED 0


// MEMORY LAYOUT
// 1K + 4K MEMORY
#define RAM_START   0x0000
#define RAM_END     0x13FF
byte    RAM[RAM_END-RAM_START+1];

// 6530-003 I/O and timer of, free for user 0x1700-0x173F

// 6530-003 RAM, 64 bytes
#define RAM003_START   0x1780
#define RAM003_END     0x17BF
byte    RAM003[RAM003_END-RAM003_START+1];

// I/O and timer of 6530-002, free for user 0x1740-0x177F

// 6530-002 RAM, 64 bytes
#define RAM002_START   0x17C0
#define RAM002_END     0x17FF
byte    RAM002[RAM002_END-RAM002_START+1];

// ROMs (Monitor + Basic)
#define ROM003_START   0x1800
#define ROM003_END     0x1BFF
#define ROM002_START   0x1C00
#define ROM002_END     0x1FFF

// custom program, includes VECTORS
#define ROM001_START   0xF000
#define ROM001_END     0xFFFF

#include "rom.h"
