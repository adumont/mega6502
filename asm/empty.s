; Assembly code template
; help: https://cc65.github.io/doc/ca65.html

.pc02 ; 65C02 mode

.segment  "CODE"

.include  "fpga.inc"

.export   _init

.import   copydata ; keep if we use DATA segment only

_init:
    cli ; clear the interrupt-disable bit so the processor will respond to interrupts
    cld ; and clear the D flag

    jsr copydata ; keep if we use DATA segment only

_start:
    ; PROGRAM GOES HERE!


; Constants macros can go here. several way to define them:
VAL1 = $2000
.define   VAL2 $1000

.segment  "RODATA"
; constant in memory can go here

.segment  "DATA"
var1:  .byte $64
var2:  .byte %00000001
var3:  .word $ffff