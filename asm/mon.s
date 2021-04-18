
	*= $8000

ADDR	.= $0A		; 2 bytes, an address
IN 	.= $0200	; here we'll store up to 15 byte
			; for the command

loop:	
	LDA #'?'
	JSR putc
	LDA #' '
	JSR putc

	JSR getline
	
	CMP #$1B	; ESC
	BEQ cmd_esc
	
	CMP #$0d ; LF
	BEQ cmd_return
	
	JMP make_upper

put_newline:
	; output a CR+LF
	LDA #$0a ; CR
	JSR putc
	LDA #$0d ; LF
	JSR putc
	JMP loop

cmd_esc:
	; here we do whatever to handle an ESC
	lda #'E'
	JSR putc
	lda #'S'
	JSR putc
	lda #'C'
	JSR putc
	
	JMP put_newline

cmd_return:
	; here we do whatever to handle a RETURN
	
	CPX #0	; user has just hit return again?
	BNE x_over_4
	
	INC ADDR	; ADDR++
	BNE skip_inc_hi
	INC ADDR+1
	; JSR print_addr
skip_inc_hi:
	LDA ADDR+1
	JSR print_byte
	LDA ADDR
	JSR print_byte
	
	JMP show_value	; show val at ADDR
	
x_over_4:
	CPX #4
	BMI err_not_enough_char
	
	JSR scan_ascii_addr
	; address in ADDR

show_value:
	LDA #':'
	JSR putc

	LDY #0
	LDA (ADDR),y
	
	PHA	; save A for 2nd nibble
	LSR	; here we shift right
	LSR	; to get HI nibble
	LSR
	LSR
	JSR nibble_value_to_asc
	JSR putc

	PLA
	AND #$0F ; LO nibble
	JSR nibble_value_to_asc
	JSR putc
	
	JMP put_newline
	
err_not_enough_char:
	JMP loop


print_byte:
	PHA	; save A for 2nd nibble
	LSR	; here we shift right
	LSR	; to get HI nibble
	LSR
	LSR
	JSR nibble_value_to_asc
	JSR putc

	PLA
	AND #$0F ; LO nibble
	JSR nibble_value_to_asc
	JSR putc
	RTS
	
make_upper:	
	PHA	 ; save char
	AND #$df ; make upper case
	
test_r:	CMP #'R'
	BNE test_w
is_r:
	JSR putc
	lda #'o'
	JSR putc
	lda #'k'
	JSR putc
	jmp loop

test_w:	CMP #'W'
	BNE unkn
is_w:
	JSR putc
	lda #'O'
	JSR putc
	lda #'K'
	JSR putc
	jmp loop

unkn:	
	PLA 	 ; restore char
	JSR putc
		
	JMP loop
	
	
getc:	
	LDA IO_AREA+4
	BEQ getc
	RTS

putc:
	STA IO_AREA+1
	RTS

getline:
	LDX #0
next:	
	JSR getc

	CMP #$0D	; LF (enter)?
	BEQ eol

	CMP #$1B 	; ESC	
	BEQ eol

	CMP #$08 	; Backspace	
	BEQ backspace

	CMP #'9'+1
	BMI skip_uppercase
	AND #$DF 	; make upper case
skip_uppercase:
	STA IN+1,x	; save in buffer
	
	CPX #$0F	; x=15 -> end line
	BEQ eol
	
	INX
	JSR putc	; echo char
	JMP next	; wait for next

backspace:
	CPX #0
	BEQ next
	DEX
	JSR putc	; echo char
	JMP next

eol:
	STX IN
	RTS

nibble_asc_to_value:
; converts a char representing a hex-digit (nibble)
; into the corresponding hex value
	CMP #$41
	BMI less
	SBC #$37
less:
	AND #$0F
	RTS

nibble_value_to_asc:
	CMP #$0A
	BCC skip
	ADC #$66
skip:
	EOR #$30
	RTS

scan_ascii_addr:
	LDX #4
	
	LDA IN,X	; load char into A
	JSR nibble_asc_to_value
	
	STA ADDR
	
	DEX
	LDA IN,X	; load char into A
	JSR nibble_asc_to_value
	ASL
	ASL
	ASL
	ASL
	ORA ADDR
	STA ADDR
	
	DEX
	LDA IN,X	; load char into A
	JSR nibble_asc_to_value
	
	STA ADDR+1
	
	DEX
	LDA IN,X	; load char into A
	JSR nibble_asc_to_value
	ASL
	ASL
	ASL
	ASL
	ORA ADDR+1
	STA ADDR+1
	RTS

msg	.BYTE "Canceled", 0
