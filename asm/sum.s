

    pha         ; save A
    txa         ; \
    pha         ; / save X

    lda #$3     ; push 3 on the stack
    pha

    lda #$6     ; put 6 in A

    tsx         ;\
    inx         ; | X <= SP++
    txs         ;/ 

    clc         ;
    adc $100,x  ; add what is in sp to A

    sta $0222   ; store A in $0222

    pla         ; 
    tax         ; restore saved X
    pla         ; restore saved A
