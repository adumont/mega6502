; Write text to LCD connected to the VIA 6522
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

.define   E    %10000000
.define   RW   %01000000
.define   RS   %00100000

_init:
    cli ; clear the interrupt-disable bit so the processor will respond to interrupts
    cld ; and clear the D flag

_start:

    ; set port B to all output
    lda #%11111111
    sta DDRB

    ; set top 3 pins of port A to output
    lda #%11100000
    sta DDRA

    lda #%00111000  ; set 8bit mode, 2 line display , 5x8 font
    jsr lcd_instruction

    lda #%00000001  ; Clear display
    jsr lcd_instruction

    lda #%00000010  ; Return Home
    jsr lcd_instruction

    lda #%00001110  ; Display ON, Cursor ON, Blink OFF
    jsr lcd_instruction

    lda #%00000110  ; Cursor Increment, no display shift
    jsr lcd_instruction

    jsr inlineprt
    .asciiz "Homebrew 6502"

    ldx #1
    jsr lcd_gotoline

    jsr inlineprt
    .asciiz "2021.03.31"

    ldx #3
    jsr lcd_gotoline

    jsr inlineprt
    .asciiz "Thx followers!"

loop:
    jmp loop

delay:              ; jsr delay: 6 cycles
    ldx #$00        ; 2 cycles
    ldy #$1         ; 2 cycles

:   inx             ; 2 cycles \        \
    bne :-          ; 3 cycles / x 256   \ x 16
    dey             ; 2 cycles, -1*      / 
    bne :-          ; 3 cycles          / (* because bne=3 when branching, 2 otherwise)
                    ; -1 cycle * 
    rts             ; 6 cycles

lcd_wait:
    pha
    lda #%00000000  ; Port B is input
    sta DDRB
lcdbusy:
    lda #RW         ; Read
    sta PORTA

    lda #(RW | E)
    sta PORTA

    lda PORTB
    and #%10000000
    bne lcdbusy

    lda #RW
    sta PORTA

    lda #%11111111  ; Port B is output
    sta DDRB

    pla
    rts    

lcd_gotoline:
    ; assume line in X (0-3)
    lda LCD_LINES_ADDR,x
    ORA #%10000000   ; set bit 7 (Set DDRAM address cmd)
    jsr lcd_instruction

lcd_instruction:
    jsr lcd_wait
    sta PORTB
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    lda #E         ; Set E bit to send instruction
    sta PORTA
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    rts

print_char:
    jsr lcd_wait
    sta PORTB
    lda #RS         ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)   ; Set E bit to send instruction
    sta PORTA
    lda #RS         ; Clear E bits
    sta PORTA
    rts

; ----------------------------------------------------------------------------
; -- inline print:
; -- string is right after the jsr call in the code
inlineprt:
    stx SAVE_X
    sty SAVE_Y
    sta SAVE_A

    pla                 ; jsr saved its PC+2 to stack,
    sta z:ADDR          ; we retrieve it and save to ADDR in ZP
    pla                 ; (string will be at ADDR+3)
    sta z:ADDR+1

    ldy #$00

    ; retrieve next char of string
@nxt_char:
    inc z:ADDR          ; we increment ADDR LO
    bne @get_char
    inc z:ADDR+1        ; we increment ADDR HI

@get_char:
    lda (ADDR),y        ; get the string's char in A
    beq @end            ; if 00 we end,
    jsr print_char      ; else we print char
    jmp @nxt_char

@end:
    lda z:ADDR+1          ; restore PC HI on stack
    pha
    lda z:ADDR            ; restore PC LO on stack
    pha
    ; restore registers
    ldx SAVE_X
    ldy SAVE_Y
    lda SAVE_A

    rts


; ----------------------------------------------------------------------------
.RODATA
MSG:    .asciiz "Hello world"

LCD_LINES_ADDR: .byte $00, $40, $14, $54

; ----------------------------------------------------------------------------
; reserve space for global variables

.ZEROPAGE
ADDR:    .res    2   ; // NOTICE remember to use z:ADDR to force zeropage addressing.

.DATA
SAVE_A:  .res    1
SAVE_X:  .res    1
SAVE_Y:  .res    1