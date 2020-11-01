.segment  "CODE"

.export _init

.import copydata

.define GPIO $1000

_init:
  jsr copydata
  lda VAR1
  sta GPIO
 
loop:
  lda GPIO ; read gpio input port
  sta VAR1 ; store to VAR1 in ram
  sta GPIO ; write to leds
  jmp loop

.segment "DATA"

VAR1: .byte $ff
