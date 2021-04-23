
	*= $8000

ADDR	.= $FE		; 2 bytes, an address

BYTE	.= $0300
LEN 	.= $0200	; Length of CMD
CMD	.= $0201	; CMD string

RES_vec
    	CLD             ; clear decimal mode
    	LDX #$FF
    	TXS             ; set the stack pointer

loop:	
	LDA #'?'
	JSR putc
	LDA #' '
	JSR putc

	JSR getline
	
	CMP #$0d ; LF
	BEQ cmd_return
	; here user hit ESC
	
cmd_esc:
	; here we do whatever to handle an ESC
	LDA #'E'
	JSR putc
	lda #'S'
	JSR putc
	lda #'C'
	JSR putc
	; fall through to  put_newline

put_newline:
	; output a CR+LF
	LDA #$0a ; CR
	JSR putc
	LDA #$0d ; LF
	JSR putc
	JMP loop

cmd_return:
	; here we do whatever to handle a RETURN
	
	; decision tree depending on the length
	; (length is still stored in X at this pointtp)

	CPX #0	; user has just hit return again?
	BEQ user_hit_return

	LDA CMD	 ; first char
	CMP #'.'
	BEQ dot_cmd

	CPX #4
	BEQ it_is_an_addr
	JMP error

user_hit_return:
	; User has just hit return
	; we increment ADDR,show it and show value
	INC ADDR	; ADDR LO++
	BNE show_addr	;
	INC ADDR+1	; ADDR HI++
	; fall through to show_addr

show_addr:
	LDA ADDR+1
	JSR print_byte
	LDA ADDR
	JSR print_byte
	
	JMP show_value	; show val at ADDR & loop

dot_cmd:
	LDX #1
	JSR scan_ascii_byte

	STA (ADDR),y

	JMP put_newline

only_1_char:
	LDA CMD
	CMP #'.' ; edit
	BNE put_newline

	; User has typed '.' EDIT!
	; get a byte

	LDA #'='
	JSR putc
	JSR getline

	CMP #$1B	; ESC
	BEQ cmd_esc

	LDX #0		; advance to next char
	JSR scan_ascii_byte

	STA (ADDR),y

	JMP put_newline

it_is_an_addr:
	LDX #0
	JSR scan_ascii_addr
	; address in ADDR
	; fall through to show_value

show_value:
	LDA #':'
	JSR putc

	LDY #0
	LDA (ADDR),y
	TAX		; we use X to save the VALUE
	JSR print_byte

	CPX #$20
	BMI put_newline
	CPX #$7E
	BPL put_newline

	LDA #' '
	JSR putc
	TXA
	JSR putc

; put new line and repeat
	JMP put_newline
	;JMP loop ; show prompt again and getline
	
error:
	LDA #'E'
	JSR putc
	lda #'R'
	JSR putc
	lda #'R'
	JSR putc

	JMP put_newline ; and loop


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
	STA CMD,x	; save in buffer
	
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
	STX LEN
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
	LDA CMD,X	; load char into A
	JSR nibble_asc_to_value
	ASL
	ASL
	ASL
	ASL
	STA ADDR+1

	INX
	LDA CMD,X	; load char into A
	JSR nibble_asc_to_value
	
	ORA ADDR+1
	STA ADDR+1

	INX
	LDA CMD,X	; load char into A
	JSR nibble_asc_to_value
	ASL
	ASL
	ASL
	ASL
	STA ADDR
	
	INX
	LDA CMD,X	; load char into A
	JSR nibble_asc_to_value
	ORA ADDR
	STA ADDR
	
	RTS

scan_ascii_byte:
	LDA CMD,X	; load char into A
	JSR nibble_asc_to_value
	ASL
	ASL
	ASL
	ASL
	STA BYTE

	INX
	LDA CMD,X	; load char into A
	JSR nibble_asc_to_value
	ORA BYTE
	STA BYTE
	RTS

msg	.BYTE "Monitor v0", 0

IRQ_vec
    RTI

NMI_vec
    RTI

; system vectors

    *=  $FFFA

    .word   NMI_vec     ; NMI vector
    .word   RES_vec     ; RESET vector
    .word   IRQ_vec     ; IRQ vector