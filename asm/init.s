.segment  "CODE"

.include  "fpga.inc"

.export   _init

_init:

loop:
    lda GPIO_DATA
    sta GPIO_DATA
    jmp loop
