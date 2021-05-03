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
.define   T1CL     VIA+$4 ; \ Read Timer 1 Counter LO/HI byte / Write to Timer 1 Latch LO/HI byte
.define   T1CH     VIA+$5 ; /
.define   T1LL     VIA+$6 ; \ Access Timer 1 Latch LO/HI byte
.define   T1LH     VIA+$7 ; /
.define   T2CL     VIA+$8 ; Read Timer 2 LO byte & reset counter interrupt. Write LO Timer 2 but does't reset interrupt
.define   T2CH     VIA+$9 ; Access Timer 2 HI byte, reset counter interrupt on write
.define   SR       VIA+$A ; Serial I/O Shift register
.define   ACR      VIA+$B ; Auxialiary Control register
.define   PCR      VIA+$C ; Peripheral Control register
.define   IFR      VIA+$D ; Interrupt Flag register
.define   IER      VIA+$E ; Interrupt Enable register
.define   PORTA0   VIA+$F ; Output register for I/O Port A, without handshaking

.define   E    %10000000
.define   RW   %01000000
.define   RS   %00100000

; ACIA $4200
.define   ACIA         $4200 ; 
.define   ACIA_DATA  ACIA+$0 ; 
.define   ACIA_STAT  ACIA+$1 ; 
.define   ACIA_CMD   ACIA+$2 ; 
.define   ACIA_CTRL  ACIA+$3 ; 

; 6551
.struct sACIA            ; Asynchronous Communications Interface Adapter
    .org    $4200
    DATA    .byte
    STATUS  .byte
    CMD     .byte       ; Command register
    CTRL    .byte       ; Control register
.endstruct


_init:
    cli ; clear the interrupt-disable bit so the processor will respond to interrupts
    cld ; and clear the D flag

_start:

    ; set VIA port B to all output
    lda #%11111111
    sta DDRB

    ; set VIA top 3 pins of port A to output
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
    .asciiz "Alex's Homebrew 6502"

    ldx #1
    jsr lcd_gotoline

    jsr inlineprt
    .asciiz "  6551 serial demo"

    ; ldx #3
    ; jsr lcd_gotoline

    ; jsr inlineprt
    ; .asciiz "Thx followers!"

; ACIA setup

    stz ACIA_STAT       ; Programmed reset ACIA (data in A is "don't care")

    ; stz ACIA_CTRL       ; 16x EXTERNAL CLOCK, External Receiver Clock, 8 data word length, 1 stop bit

    lda #%00011110      ; SBR: 9600, RCS: baud rate
    sta ACIA_CTRL

    lda #%00001011     ; set specific modes and functions:
                        ;   no parity, no echo, no Tx interrupt
                        ;   no Rx interrupt, enable Tx/Rx
    sta ACIA_CMD

    stz COUNTER

loop:
    jsr acia_receive_char

    sta z:CHAR          ; save char in CHAR

    ldx #3
    jsr lcd_gotoline

    lda z:CHAR          ; restore char
    jsr print_char      ; print char on LCD

    lda #' '
    jsr print_char      ; print space on LCD

    lda z:CHAR          ; restore char
    jsr PrintByte       ; print char as hexadecimal on LCD

    inc COUNTER

    lda #' '
    jsr print_char      ; print space on LCD

    lda COUNTER
    jsr PrintByte       ; print char as hexadecimal on LCD

    ; echo back the char received
    lda z:CHAR          ; restore char
    jsr acia_send_char

    jmp loop


PrintByte:
    PHA             ; Save A for LSD.
    LSR
    LSR
    LSR             ; MSD to LSD position.
    LSR
    JSR PRHEX       ; Output hex digit.
    PLA             ; Restore A.
                    ; Falls through into PRHEX routine

; Print nybble as one hex digit.
; Taken from Woz Monitor PRHEX routine ($FFE5).
; Pass byte in A
; Registers changed: A
PRHEX:
    AND #$0F        ; Mask LSD for hex print.
    ORA #'0'        ; Add "0".
    CMP #$3A        ; Digit?
    BCC PrintChar   ; Yes, output it.
    ADC #$06        ; Add offset for letter.
                    ; Falls through into PrintChar routine

; Output a character
; Pass byte in A
; Registers changed: none
PrintChar:
    PHP             ; Save status
    PHA             ; Save A as it may be changed
    JSR print_char
    PLA             ; Restore A
    PLP             ; Restore status
    RTS             ; Return.


acia_send_char:
    pha
:   lda ACIA_STAT       ; wait for TX empty
    and #%00010000      ; Bit 4: Transmitter Data Register Empty?
    beq :-              ; 0 - Not Empty, repeat
    pla                 ; restore char

    sta ACIA_DATA       ; send char
    rts

acia_receive_char:
:   lda ACIA_STAT       ; wait for RX full
    and #%00001000      ; Bit 3: Receiver Data Register Full?
    beq :-              ; 0 - Not Full, repeat
    lda ACIA_DATA       ; read char
    rts

delay:              ; jsr delay: 6 cycles
    ldx #$00        ; 2 cycles
    ldy #$40        ; 2 cycles

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
CHAR:    .res    1

; for variables we want to have initialized, and be able to modify later. Requires copydata.s!
; for reserving space only, use .BSS
.DATA

.BSS
SAVE_A:  .res    1
SAVE_X:  .res    1
SAVE_Y:  .res    1
COUNTER: .res    1
