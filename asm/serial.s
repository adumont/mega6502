; Assembly code template
; help: https://cc65.github.io/doc/ca65.html

.pc02 ; 65C02 mode

.segment  "CODE"

.include  "fpga.inc"

.define SERIAL_STAT $2010
.define SERIAL_DATA $2011

.define RDRFBIT #%00001000  ; Receive Data Buffer Full bit

.export   _init

_init:
    cli ; clear the interrupt-disable bit so the processor will respond to interrupts
    cld ; and clear the D flag
    ldx #$FF
    txs

_start:
    jsr getc
    bcc _start
    jsr putc
    jmp _start

;-------------------------------------------------------------------------------
;-- getc: Retrieve character from Serial Buffer
;-- Character,if any, will be placed in Accumulator
;-- Carry set if data has been retrieved, cleared if we got nothing
;-------------------------------------------------------------------------------

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

;-------------------------------------------------------------------------------
;-- putc: Retrieve character from Serial Buffer
;-- Character,if any, will be placed in Accumulator
;-- Carry set if data has been retrieved, cleared if we got nothing
;-------------------------------------------------------------------------------

putc:
	sta SERIAL_DATA   ; Actually send the character to serial buffer
    rts