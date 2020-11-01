.segment  "CODE"

.include  "fpga.inc"

.export   _init

.debuginfo      +       ; Generate debug info

_init:
; init routine, we initialize SP to $ff
    cli ; clear the interrupt-disable bit in the processor status register so the processor will respond to interrupts
    ldx #$ff
    txs
; and clear the D flag
    cld

_start:
    lda ro_dividend
    sta dividend
    sta GPIO_DATA

    lda ro_divisor
    sta divisor
    sta GPIO_DATA

    lda #0
    sta GPIO_DATA

; Division routine by Aaron Baugher
; https://www.youtube.com/watch?v=WZTy4ET3j9A&list=PLXtNAWgA0fU7VxotiZuKh9zbfXNtJ3dWF&index=4
_division:
    ldx #8
    lda #0
    sta quotient
    sta remainder

@loop:

    asl dividend
    rol

    cmp divisor

    php
    rol quotient
    plp

    bcc @nosbc
    
    sec
    sbc divisor

@nosbc:

    dex
    bne @loop

    sta remainder
   
; show results on GPIO
    lda quotient
    sta GPIO_DATA

    lda remainder
    sta GPIO_DATA

    brk

.segment  "RODATA"
ro_dividend:  .byte $64
ro_divisor:   .byte $09

.segment  "DATA"
dividend:  .byte $00
divisor:   .byte $00
quotient:  .byte $00
remainder: .byte $00
