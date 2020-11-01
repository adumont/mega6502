.segment  "CODE"

.include  "fpga.inc"

.export   _init

.import   copydata

.debuginfo      +       ; Generate debug info

_init:
; init routine
    cli ; clear the interrupt-disable bit so the processor will respond to interrupts
    cld ; and clear the D flag

    jsr copydata

_start:
    lda #0
    sta quotient
    sta remainder

; show arguments on GPIO
    lda dividend
    sta GPIO_DATA

    lda divisor
    sta GPIO_DATA

; Division, 8-bit / 8-bit = 8-bit quotient, 8-bit remainder (unsigned)
; http://6502org.wikidot.com/software-math-intdiv
    lda #0
    ldx #8
    asl dividend
@loop:
    rol
    cmp divisor
    bcc @nosbc
    sbc divisor
@nosbc:
    rol dividend
    dex
    bne @loop

    sta remainder
    lda dividend
    sta quotient
   
; rts
   

; show results on GPIO
    lda quotient
    sta GPIO_DATA

    lda remainder
    sta GPIO_DATA

    brk

.segment  "RODATA"

.segment  "DATA"
dividend:  .byte $64
divisor:   .byte $09
quotient:  .byte $00
remainder: .byte $00
