; Counter, increment a byte in RAM and output on port A
; with a delay loop, so that we can see the effect using led.
;
; help: https://cc65.github.io/doc/ca65.html

.pc02 ; 65C02 mode

.segment  "CODE"

.export   _init

; VIA $6000
.define   VIA       $6000 ; 6522 VIA Versative Interface Adapter
.define   PORTB    VIA+$0 ; Output register for I/O Port B
.define   PORTA    VIA+$1 ; Output register for I/O Port A, with handshaking
.define   DDRB     VIA+$2 ; I/O port B Data Direction register (1=output, 0=input)
.define   DDRA     VIA+$3 ; I/O port A Data Direction register (1=output, 0=input)
.define   T1CNTLO  VIA+$4 ; \ Read Timer 1 Counter LO/HI byte / Write to Timer 1 Latch LO/HI byte
.define   T1CNTHI  VIA+$5 ; /
.define   T1LATLO  VIA+$6 ; \ Access Timer 1 Latch LO/HI byte
.define   T1LATHI  VIA+$7 ; /
.define   T2LO     VIA+$8 ; Read Timer 2 LO byte & reset counter interrupt. Write LO Timer 2 but does't reset interrupt
.define   T2HI     VIA+$9 ; Access Timer 2 HI byte, reset counter interrupt on write
.define   VIA_SR   VIA+$A ; Serial I/O Shift register
.define   VIA_ACR  VIA+$B ; Auxialiary Control register
.define   VIA_PCR  VIA+$C ; Peripheral Control register
.define   VIA_IFR  VIA+$D ; Interrupt Flag register
.define   VIA_IER  VIA+$E ; Interrupt Enable register
.define   PORTANO  VIA+$F ; Output register for I/O Port A, without handshaking

_init:
    cli ; clear the interrupt-disable bit so the processor will respond to interrupts
    cld ; and clear the D flag

_start:

    ; set port A to all output
    lda #%11111111
    sta DDRA

    lda #$00
    sta $00

loop:
    lda $00
    sta PORTA

    jsr delay

    inc $00

    jmp loop

delay:              ; jsr delay: 6 cycles
    ldx #$00        ; 2 cycles
    ldy #$10        ; 2 cycles

:   inx             ; 2 cycles \        \
    bne :-          ; 3 cycles / x 256   \ x 16
    dey             ; 2 cycles, -1*      / 
    bne :-          ; 3 cycles          / (* because bne=3 when branching, 2 otherwise)
                    ; -1 cycle * 
    rts             ; 6 cycles