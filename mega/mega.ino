#define SET(x,y) x |= (1 << y)
#define CLEAR(x,y) x &= ~(1<< y)
#define TOGGLE(x,y) (x ^= (1<<y))
#define READ(x,y) ((0u == (x & (1<<y)))?0u:1u)

#define CLOCK_LOW  CLEAR(PORTB,7)
#define CLOCK_HIGH SET(PORTB,7)

#define RESET_N_LOW  CLEAR(PORTB,6)
#define RESET_N_HIGH SET(PORTB,6)

#define RWB READ(PINH,5) // PH5 ( OC4C ) Digital pin 8 (PWM)

#define DIR_IN  0x00
#define DIR_OUT 0xFF
#define DATA_DIR   DDRL
#define ADDR_H_DIR DDRC
#define ADDR_L_DIR DDRA

#define DATA_OUT PORTL
#define DATA_IN  PINL
#define ADDR_H   PINC
#define ADDR_L   PINA
#define ADDR     ((unsigned int) (ADDR_H << 8 | ADDR_L))

word uP_ADDR = 0;
byte uP_DATA = 0;

#define DELAY 250

#include "mmap.h"

char tmp[100];

void setup() {
  Serial.begin(115200);
  // Set directions
  DATA_DIR   = DIR_IN;
  ADDR_H_DIR = DIR_IN;
  ADDR_L_DIR = DIR_IN;

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
  TOGGLE(PORTB,7);

  // rising clock
  if( READ(PORTB,7) ) { // CLock high

    uP_ADDR = ADDR;
  
    if (RWB) { // RWB = HIGH => READ: 6502 reading from Data Bus, we write!
      // change DATA port to output to 6502:
      DATA_DIR = DIR_OUT;

      if( uP_ADDR == 0xfffc ) { 
        DATA_OUT = 0xCC; 
      } else if( uP_ADDR == 0xfffd ) {
        DATA_OUT = 0xDD;
      } else {
        DATA_OUT = 0xEA;
      }

      sprintf(tmp, "-- A=%0.4X D=%0.2X %s\n", uP_ADDR, DATA_OUT, (RWB ? "r" : "W" ) );
      
    } else {  // RWB = LOW => Write: 6502 writting to Data Bus, we read

      sprintf(tmp, "-- A=%0.4X D=%0.2X %s\n", uP_ADDR, DATA_IN, (RWB ? "r" : "W" ) );
      
    }
    
    Serial.write(tmp);

  } else { // Clock low
    DATA_DIR = DIR_IN;
  }
  delay(DELAY);
}


ISR(TIMER1_COMPA_vect) {

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
