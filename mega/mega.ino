// some bit manipulation macros
#define SET(x,y) x |= (1 << y)
#define CLEAR(x,y) x &= ~(1<< y)
#define TOGGLE(x,y) (x ^= (1<<y))
#define READ(x,y) ((0u == (x & (1<<y)))?0u:1u)

// define the pins
#define CLOCK_PIN   PORTB,7     // if you change this be sure to change the SET(DDRB,7) below
#define RESET_N_PIN PORTB,6     // if you change this be sure to change the SET(DDRB,6) below
#define RWB_PIN     PINH,5      // digital Pin 8
#define SYNC_PIN     PINH,6     // digital Pin 9

// artifice to use the pins macros in previous bit manipulation macros
// see https://stackoverflow.com/questions/64630809/how-to-define-a-macro-of-two-tokens-in-cpp/
#define _SET(x)    SET(x)
#define _CLEAR(x)  CLEAR(x)
#define _TOGGLE(x) TOGGLE(x)
#define _READ(x)   READ(x)

#define CLOCK_LOW  _CLEAR(CLOCK_PIN)
#define CLOCK_HIGH _SET(CLOCK_PIN)

#define RESET_N_LOW  _CLEAR(RESET_N_PIN)
#define RESET_N_HIGH _SET(RESET_N_PIN)

#define RWB _READ(RWB_PIN) // PH5 ( OC4C ) Digital pin 8 (PWM)

#define DIR_IN      0x00
#define DIR_OUT     0xFF
#define DATA_DIR    DDRL
#define ADDR_H_DIR  DDRC
#define ADDR_L_DIR  DDRA

#define DATA_OUT    PORTL
#define DATA_IN     PINL
#define ADDR_H      PINC
#define ADDR_L      PINA
#define ADDR        ((unsigned int) (ADDR_H << 8 | ADDR_L))

word uP_ADDR = 0;
byte uP_DATA = 0;

#define DELAY 0

#include "mmap.h"

char tmp[100];

byte serial_stat_reg = 0x00;

void setup() {
  Serial.begin(115200);
  // Set directions
  DATA_DIR   = DIR_IN;
  ADDR_H_DIR = DIR_IN;
  ADDR_L_DIR = DIR_IN;

  // port F in ($2000)
  DDRF = DIR_IN;
  // port K out ($2000)
  DDRK = DIR_OUT;

  SET(DDRB,7); // PB7 output, clock
  SET(DDRB,6); // PB6 output, reset

  Serial.println("Resetting...");
  RESET_N_LOW;    // we force a reset of the 6502
  delay(DELAY);

  CLOCK_HIGH; delay(DELAY); CLOCK_LOW; delay(DELAY);
  CLOCK_HIGH; delay(DELAY); CLOCK_LOW; delay(DELAY);
  CLOCK_HIGH; delay(DELAY); CLOCK_LOW; delay(DELAY);
  
//  DATA_DIR = DIR_OUT;
//  DATA_OUT = 0xEA;

  RESET_N_HIGH;   // clear reset 6502

  Serial.println("starting...");
  //setupTimer1();
}

void loop() {
  // toggle clock
  _TOGGLE(CLOCK_PIN);

  // rising clock
  if( _READ(CLOCK_PIN) ) 
  ////////////////////////////////////////////////////////////
  // CLOCK HIGH
  {

    uP_ADDR = ADDR;
  
    if (RWB) 
    ////////////////////////////////////////////////////////////
    // 6502 READ
    {
      // RWB = HIGH => READ: 6502 reading from Data Bus,
      // check if it's a memory range driven by the Arduino Mega
      // we should only drive the data bus (DATA_DIR = DIR_OUT)
      // iff we own the range addressed

      if ( uP_ADDR == 0x2000 ) {
        DATA_DIR = DIR_OUT;
        DATA_OUT = PINF;
      }
      // Serial Buffer
      else if ( uP_ADDR == SERIAL_STAT ) {
        DATA_DIR = DIR_OUT;
        DATA_OUT = serial_stat_reg;
      }
      else if ( uP_ADDR == SERIAL_DATA ) {
        if ( READ(serial_stat_reg, 3) ) {
          DATA_DIR = DIR_OUT;
          DATA_OUT = Serial.read();
        }
      }
      // ROM001
      else if ( (ROM001_START <= uP_ADDR) && (uP_ADDR <= ROM001_END) ) {
          DATA_DIR = DIR_OUT;
          DATA_OUT = pgm_read_byte_near( rom_bin + (uP_ADDR - ROM001_START));
      }
      // RAM
      else if ( (RAM_START <= uP_ADDR) && (uP_ADDR <= RAM_END) ) {
          DATA_DIR = DIR_OUT;
          DATA_OUT = RAM[uP_ADDR - RAM_START];
      }

    } else 
    ////////////////////////////////////////////////////////////
    // 6502 WRITE
    {  
      // RWB = LOW => Write: 6502 writting to Data Bus, we read

      if ( uP_ADDR == 0x2000 ) {
        PORTK = DATA_IN;
      }
      // Serial Buffer
      else if ( uP_ADDR == SERIAL_DATA ) {
        char c = DATA_IN; // data passed by 6502 to be written to Serial buffer
        Serial.write(c);
      }
      // RAM?
      else if ( (uP_ADDR <= RAM_END) && (RAM_START <= uP_ADDR) ) {
        RAM[uP_ADDR - RAM_START] = DATA_IN;
      } 
      else
      // RAM002?
      if ( (uP_ADDR <= RAM002_END) && (RAM002_START <= uP_ADDR) ) {
        RAM002[uP_ADDR - RAM002_START] = DATA_IN;
      }
      else
      // RAM003?
      if ( (uP_ADDR <= RAM003_END) && (RAM003_START <= uP_ADDR) ) {
        RAM002[uP_ADDR - RAM003_START] = DATA_IN;
      }
      
    }
    
    // dump info on serial
    //dumpInfo();

  } else 
  ////////////////////////////////////////////////////////////
  // CLOCK LOW
  {
    DATA_DIR = DIR_IN;
  }
  delay(DELAY);


  // ABOVE THIS SHOULD GO TO INTERUPT ISR...

  // ------------------------
  
  // this below should stay in loop()

  if (Serial.available()) {
    SET(serial_stat_reg, 3);
  } else {
    CLEAR(serial_stat_reg, 3);
  }


}

ISR(TIMER1_COMPA_vect) {

}

void dumpInfo() {
  sprintf(tmp, "%0.4X %0.2X %s %d\n", uP_ADDR, (RWB ? DATA_OUT : DATA_IN ), (RWB ? "r" : "W" ), _READ(SYNC_PIN) );
  Serial.write(tmp);
}

void setupTimer1() {
  // http://www.arduinoslovakia.eu/application/timer-calculator
  
  noInterrupts();
  // Clear registers
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1 = 0;

  // 100 Hz (16000000/((624+1)*256))
  OCR1A = 624;
  // CTC
  TCCR1B |= (1 << WGM12);
  // Prescaler 256
  TCCR1B |= (1 << CS12);
  // Output Compare Match A Interrupt Enable
  TIMSK1 |= (1 << OCIE1A);
  interrupts();
}
