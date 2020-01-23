#include "reg9s12.h"

lcd_dat 	equ	PortK   	; LCD data pins (PK5~PK2)
lcd_dir 	equ   	DDRK    	; LCD data direction port
lcd_E   	equ   	$02     	; E signal pin
lcd_RS  	equ   	$01     	; RS signal pin
G3	equ	7653	; delay count to generate G3 note (with prescaler=8)
B3	equ	6074	; delay count to generate B3 note 
C4 	equ	5733	; delay count to generate C4 note 
C4S	equ	5412	; delay count to generate C4S (sharp) note
D4 	equ	5108	; delay count to generate D4 note 
E4 	equ	4551	; delay count to generate E4 note 
F4 	equ	4295	; delay count to generate F4 note 
F4S	equ	4054	; delay count to generate F4S note 
G4 	equ	3827	; delay count to generate G4 note 
A4 	equ	3409	; delay count to generate A4 note 
B4F 	equ	3218	; delay count to generate B4F note 
B4	equ	3037	; delay count to generate B4 note 
C5 	equ	2867	; delay count to generate C5 note 
D5 	equ	2554	; delay count to generate D5 note 
E5 	equ	2275	; delay count to generate E5 note 
F5 	equ	2148	; delay count to generate F5 note 
ZZ	equ	20	; delay count to generate an inaudible sound

notes	equ	101	; number of notes in the song 

	org   	$1000
delaySONG	ds.w  	1 		; store the delay for OC operation
rep_cnt	ds.b	1		; repeat the song this many times
ip	ds.b	1		; remaining notes to be played

	org   	$2000
;CODE FOR BUTTONS
	movb	#$FF, DDRB	; set port B as output for LEDs
	bset	DDRJ, $02	; set port J bit 1 as output (required by Dragon12+)
	bclr	PTJ, $02		; turn off port J bit 1 to enable LEDs
	movb	#$FF, DDRP	; set port P as output
	movb	#$0F, PTP	; turn off 7-segement displays (in Dragon12+)
	movb	#$00, DDRH	; set port H as input for DIP switches
	lds   	#$2000  	; set up stack pointer
	jsr   	openLCD 	; initialize the LCD
	ldx   	#msg1	; point to the first line of message
	jsr   	putsLCD	; display in the LCD screen
	jsr	delayLCD
	jsr 	loop
	jsr	loop
	jsr	loop
	jsr 	loop
	jsr	loop
	jsr	loop
	jsr 	loop
	jsr	loop
	jsr	loop
	jsr 	loop
	jsr	loop
	jsr	loop
	jsr 	loop
	jsr	loop
	jsr	loop
	jsr 	loop
	jsr	loop
	jsr	loop
	jsr 	loop
	jsr	loop
	jsr	loop
	jsr 	loop
	jsr	loop
	jsr	loop


main	ldaa 	PTH
	cmpa 	#$01
	BEQ	TWINKLE
	cmpa	#$80
	beq	SPIDER; output to LEDs 
	clra
	jmp 	main

loop	ldaa	#$18
	jsr	cmd2LCD
	jsr	delayLCD
	rts
	
;CODE FOR TWINKLE STAR
TWINKLE	movw	#oc5isr,$3E64	; set the interrupt vector
	movb  	#$90,TSCR 	; enable TCNT, fast timer flag clear
	movb  	#$03,TMSK2 	; set main timer prescaler to 8
	bset  	TIOS,$20   	; enable OC5
	movb 	#$04,TCTL1 	; select toggle for OC5 pin action
	ldx	#songTwinkle		; use as a pointer to score table
	ldy	#durationTwinkle	; points to duration table
	movb	#1,rep_cnt	; play the song twice
	movb	#notes,ip	; set up the note counter 
	movw	2,x+,delaySONG	; start with zeroth note 
	ldd	TCNT		; play the first note
	addd	delaySONG		; "
	std	TC5		; "
	bset  	TIE,$20     	; enable OC5 interrupt
	cli                 	;       "

foreverTWINKLE 	pshy			; save duration table pointer in stack
	ldy   	0,y      	; get the duration of the current note
	jsr   	d10ms   		; play the note for ?duration x 10ms?
	puly			; get the duration pointer from stack
	iny			; move the duration pointer
	iny			; "
	ldd	2,x+		; get the next note, move pointer
	std	delaySONG		; "
	dec	ip		; if not the last note, play again
	bne	foreverTWINKLE		;
	dec	rep_cnt		; check how many times left to play song
	beq	doneTWINKLE		; if not finish playing, re-start from 1st note
	ldx	#songTwinkle		; pointers and loop count
	ldy	#durationTwinkle	; "
	movb	#notes,ip	; "
	movw	0,x,delaySONG	; get the first note delay count
	ldd	TCNT		; play the first note
	addd	#delaySONG		; "
	std	TC5
	bra   	foreverTWINKLE			
doneTWINKLE	jmp	main
;END CODE FOR TWINKLE STAR

;START CODE FOR SPIDER
SPIDER movw	#oc5isr,$3E64	; set the interrupt vector
	movb  	#$90,TSCR 	; enable TCNT, fast timer flag clear
	movb  	#$03,TMSK2 	; set main timer prescaler to 8
	bset  	TIOS,$20   	; enable OC5
	movb 	#$04,TCTL1 	; select toggle for OC5 pin action
	ldx	#songSPIDER		; use as a pointer to score table
	ldy	#durationSPIDER	; points to duration table
	movb	#1,rep_cnt	; play the song twice
	movb	#notes,ip	; set up the note counter 
	movw	2,x+,delaySONG	; start with zeroth note 
	ldd	TCNT		; play the first note
	addd	delaySONG		; "
	std	TC5		; "
	bset  	TIE,$20     	; enable OC5 interrupt
	cli                 	;       "

foreverSPIDER 	pshy			; save duration table pointer in stack
	ldy   	0,y      	; get the duration of the current note
	jsr   	d10ms   		; play the note for ?duration x 10ms?
	puly			; get the duration pointer from stack
	iny			; move the duration pointer
	iny			; "
	ldd	2,x+		; get the next note, move pointer
	std	delaySONG		; "
	dec	ip		; if not the last note, play again
	bne	foreverSPIDER		;
	dec	rep_cnt		; check how many times left to play song
	beq	doneSPIDER		; if not finish playing, re-start from 1st note
	ldx	#songSPIDER		; pointers and loop count
	ldy	#durationSPIDER	; "
	movb	#notes,ip	; "
	movw	0,x,delaySONG	; get the first note delay count
	ldd	TCNT		; play the first note
	addd	#delaySONG		; "
	std	TC5
	bra   	foreverSPIDER			
doneSPIDER	jmp 	main

msg1 	dc.b   	"Pavninder Deol Harjot Singh Shail Patel",0


; the command is contained in A when calling this subroutine from main program
cmd2LCD	psha				; save the command in stack
	bclr  	lcd_dat, lcd_RS	; set RS=0 for IR => PTK0=0
	bset  	lcd_dat, lcd_E 	; set E=1 => PTK=1
	anda  	#$F0    		; clear the lower 4 bits of the command
	lsra 			; shift the upper 4 bits to PTK5-2 to the 
	lsra            		; LCD data pins
	oraa  	#$02  		; maintain RS=0 & E=1 after LSRA
	staa  	lcd_dat 		; send the content of PTK to IR 
	nop			; delay for signal stability
	nop			; 	
	nop			;	
	bclr  	lcd_dat,lcd_E   	; set E=0 to complete the transfer

	pula			; retrieve the LCD command from stack
	anda  	#$0F    		; clear the lower four bits of the command
	lsla            		; shift the lower 4 bits to PTK5-2 to the
	lsla            		; LCD data pins
	bset  	lcd_dat, lcd_E 	; set E=1 => PTK=1
	oraa  	#$02  		; maintain E=1 to PTK1 after LSLA
	staa  	lcd_dat 		; send the content of PTK to IR
	nop			; delay for signal stability
	nop			;	
	nop			;	
	bclr  	lcd_dat,lcd_E	; set E=0 to complete the transfer

	ldy	#1		; adding this delay will complete the internal
	jsr	delay50us	; operation for most instructions
	rts

openLCD 	movb	#$FF,lcd_dir		; configure Port K for output
	ldy   	#2		; wait for LCD to be ready
	jsr   	delay100ms	;	?
	ldaa  	#$28            	; set 4-bit data, 2-line display, 5 × 8 font
	jsr   	cmd2lcd         	;       "	
	ldaa  	#$0F            	; turn on display, cursor, and blinking
	jsr   	cmd2lcd         	;       "
	ldaa  	#$06            	; move cursor right (entry mode set instruction)
	jsr   	cmd2lcd         	;       "
	ldaa  	#$01            	; clear display screen and return to home position
	jsr   	cmd2lcd         	;       "
	ldy   	#2              	; wait until clear display command is complete
	jsr   	delay1ms   	;       "
	rts 	

; The character to be output is in accumulator A.
putcLCD	psha                    	; save a copy of the chasracter
	bset  	lcd_dat,lcd_RS	; set RS=1 for data register => PK0=1
	bset  	lcd_dat,lcd_E  	; set E=1 => PTK=1
	anda  	#$F0            	; clear the lower 4 bits of the character
	lsra           		; shift the upper 4 bits to PTK5-2 to the
	lsra            		; LCD data pins
	oraa  	#$03            	; maintain RS=1 & E=1 after LSRA
	staa  	lcd_dat        	; send the content of PTK to DR
	nop                     	; delay for signal stability
	nop                     	;      
	nop                     	;     
	bclr  	lcd_dat,lcd_E   	; set E=0 to complete the transfer

	pula			; retrieve the character from the stack
	anda  	#$0F    		; clear the upper 4 bits of the character
	lsla            		; shift the lower 4 bits to PTK5-2 to the
	lsla            		; LCD data pins
	bset  	lcd_dat,lcd_E   	; set E=1 => PTK=1
	oraa  	#$03            	; maintain RS=1 & E=1 after LSLA
	staa  	lcd_dat		; send the content of PTK to DR
	nop			; delay for signal stability
	nop			;
	nop			;
	bclr  	lcd_dat,lcd_E   	; set E=0 to complete the transfer

	ldy	#1		; wait until the write operation is complete
	jsr	delay50us	; 
	rts


putsLCD	ldaa  	1,X+   		; get one character from the string
	beq   	donePS	; reach NULL character?
	jsr   	putcLCD
	bra   	putsLCD
donePS	rts 


delay1ms 	movb	#$90,TSCR	; enable TCNT & fast flags clear
		movb	#$06,TMSK2 	; configure prescale factor to 64
		bset	TIOS,$01		; enable OC0
		ldd 	TCNT
again0		addd	#375		; start an output compare operation
		std	TC0		; with 50 ms time delay
wait_lp0		brclr	TFLG1,$01,wait_lp0
		ldd	TC0
		dbne	y,again0
		rts

delay100ms 	movb	#$90,TSCR	; enable TCNT & fast flags clear
		movb	#$06,TMSK2 	; configure prescale factor to 64
		bset	TIOS,$01		; enable OC0
		ldd 	TCNT
again1		addd	#37500		; start an output compare operation
		std	TC0		; with 50 ms time delay
wait_lp1		brclr	TFLG1,$01,wait_lp1
		ldd	TC0
		dbne	y,again1
		rts

delay50us 	movb	#$90,TSCR	; enable TCNT & fast flags clear
		movb	#$06,TMSK2 	; configure prescale factor to 64
		bset	TIOS,$01		; enable OC0
		ldd 	TCNT
again2		addd	#15		; start an output compare operation
		std	TC0		; with 50 ms time delay
wait_lp2		brclr	TFLG1,$01,wait_lp2
		ldd	TC0
		dbne	y,again2
		rts

;START CODE FOR TWINKLE STAR
oc5isr 	ldd   	TC5		; restart the OC function
	addd  	delaySONG
	std   	TC5
	rti

; Create a time delay of 10ms Y times (prescaler =8)
d10ms	bset	TIOS,$01		; enable OC0
	ldd 	TCNT
again1Twinkle	addd	#30000		; start an output-compare operation
	std	TC0		; for 10 ms time delay
	brclr	TFLG1,$01,*
	ldd	TC0
	dbne	y,again1Twinkle
	rts

; store the notes of the whole song
songTwinkle	dc.w	C4, C4, G4, G4, A4, A4, G4
	dc.w	F4, F4, E4, E4, D4, D4, C4
	dc.w	G4, G4, F4, F4, E4, E4, D4 
	dc.w	G4, G4, F4, F4, E4, E4, D4
	dc.w	C4, C4, G4, G4, A4, A4, G4
	dc.w	F4, F4, E4, E4, D4, D4, C4


; each number is multiplied by 10 ms to give the duration of the corresponding note
durationTwinkle	dc.w	50, 50, 50, 50, 50, 50, 90, 50, 50, 50, 50, 50, 50, 90
		dc.w	50, 50, 50, 50, 50, 50, 90, 50, 50, 50, 50, 50, 50, 90
		dc.w	50, 50, 50, 50, 50, 50, 90, 50, 50, 50, 50, 50, 50, 90
;END CODE FOR TWINKLE STAR
;START CODE FOR SPIDER
again1SPIDER	addd	#30000		; start an output-compare operation
	std	TC0		; for 10 ms time delay
	brclr	TFLG1,$01,*
	ldd	TC0
	dbne	y,again1SPIDER
	rts
delayLCD:		ldy	#$0060
delay1:		ldx	#$FFFF
delay2:		dbne	x,delay2
		dbne	y,delay1
		rts
; store the notes of the whole song
songSPIDER	dc.w	G4, C4, C4, C4, D4, E4, E4
	dc.w	E4, D4, C4, D4, E4, C4
	dc.w	E4, E4, F4, G4
	dc.w	G4, F4, E4, F4, G4, E4
	dc.w	C4, C4, D4, E4, E4
	dc.w	D4, C4, D4, E4, C4, C4 
	dc.w	G4, C4, C4, C4, D4, E4, E4
	dc.w	E4, D4, C4, D4, E4, C4

; each number is multiplied by 10 ms to give the duration of the corresponding note
durationSPIDER	dc.w	50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50
		dc.w	50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50
		dc.w	50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50
		dc.w	50, 50, 50, 50, 50, 50, 50, 50
;END CODE FOR SPIDER

		end
