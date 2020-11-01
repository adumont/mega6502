.segment  "CODE"

.include  "fpga.inc"

.export   _init

_init:

loop:
    lda $2000 ; read port L
    sta $2000 ; save to port K
    jmp loop
