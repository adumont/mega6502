; Assembly code template
; help: https://cc65.github.io/doc/ca65.html
; 
.pc02 ; 65C02 mode

.segment  "CODE"

.include  "fpga.inc"

.define SERIAL_STAT $2010
.define SERIAL_DATA $2011

.define RDRFBIT #%00001000  ; Receive Data Buffer Full bit

; Constants

.define LF $0a  ; Line Feed
.define CR $0d  ; Carriage Return
.define SP $20  ; Space

.export   _init

; ----------------------------------------------------------------------------
_init:
    cli ; clear the interrupt-disable bit so the processor will respond to interrupts
    cld ; and clear the D flag
    ldx #$FF
    txs
    ldx #$00

; ----------------------------------------------------------------------------
_start:

; print a string saved in RODATA
:
    lda MSG,x
    beq :+
    jsr putc
    inx
    jmp :-
:   
    jsr newline

; print a string inlined (right after the jsr!)
    jsr inlineprt
    .asciiz "Welcome to Mega6502"

    jsr newline

; print some hex bytes values
    ldx #$1F
:   txa
    jsr prt_hex
    jsr prt_space
    dex
    bne :-
    txa
    jsr prt_hex
    jsr newline

; ----------------------------------------------------------------------------
; -- Loop that read chars and simply print them...
; ----------------------------------------------------------------------------
loop:
    jsr getc
    bcc loop
    cmp #CR
    beq @cr
    jsr putc
    jmp loop
@cr:
    jsr newline
    jmp loop


; ----------------------------------------------------------------------------
; -- getc: Retrieve character from Serial Buffer
; -- Character,if any, will be placed in Accumulator
; -- Carry set if data has been retrieved, cleared if we got nothing
; ----------------------------------------------------------------------------
getc:
    lda SERIAL_STAT   ; Get status from serial buffer
    and RDRFBIT       ; Mask to keep only RDRFBIT
    beq @empty        ; Nothing to read
    lda SERIAL_DATA   ; Get data from serial buffer
    sec               ; Set Carry if we got somehing
    rts               ; Job done, return
@empty:
    clc               ; We gor norhing, clear Carry
    rts               ; Job done, return

; ----------------------------------------------------------------------------
; -- print a hex byte found in accumulator A
prt_hex:
    pha                 ; save A
    lsr
    lsr
    lsr
    lsr                 ; A is the HI nibble
    jsr prt_nibble
  
    pla                 ; 2nd nibble (LO)
    ; continues into prt_nibble

; ----------------------------------------------------------------------------
; -- print a nibble found in accumulator A
prt_nibble:
    and #$0F            ; keep LO nibble only (0-15)
    cmp #$0a            ;
    bcs @over10
    ; here 0-9:
    clc
    adc #'0'
    jmp @putc
@over10:
    clc
    adc #$37            ; $37 = 'A'-10
@putc:
    ; continues into putc

; ----------------------------------------------------------------------------
; -- putc: Retrieve character from Serial Buffer
; -- Character,if any, will be placed in Accumulator
; -- Carry set if data has been retrieved, cleared if we got nothing
; ----------------------------------------------------------------------------
putc:
	sta SERIAL_DATA   ; Actually send the character to serial buffer
    rts

; ----------------------------------------------------------------------------
; -- Print a newline \n\r
newline:
    lda #LF
    jsr putc
    lda #CR
    jsr putc
    rts

; ----------------------------------------------------------------------------
prt_space:
    lda #SP
    jsr putc
    rts
; ----------------------------------------------------------------------------
; -- inline print:
; -- string is right after the jsr call in the code
inlineprt:
    stx SAVE_X
    sty SAVE_Y
    sta SAVE_A

    pla                 ; jsr saved it's PC+2 to stack,
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
    jsr putc            ;  else we print char
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

; ----------------------------------------------------------------------------
; reserve space for global variables

.ZEROPAGE
ADDR:   .res    2   ; remember to use z:ADDR to force zeropage addressing.

.DATA
SAVE_A:  .res     1
SAVE_X:  .res     1
SAVE_Y:  .res     1