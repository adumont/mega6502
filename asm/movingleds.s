.segment  "CODE"

.include  "fpga.inc"

.define   LEDS $1000    ;  GPIO out data register location

.export   _init

_init:
; init routine, we initialize SP to $ff
    ldx #$ff
    txs
; and clear the D flag
    cld

    lda #$01
    sta LEDS
    ldx #$00

left:
    cpx #$07
    beq right
    asl
    sta LEDS
    inx
    jmp left

right:
    cpx #$00
    beq left
    lsr
    sta LEDS
    dex
    jmp right