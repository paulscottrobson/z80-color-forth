; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		commandline.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		23rd November 2018
;		Purpose :	Command line handler.
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;								Command Line Warm Start
;
; ***************************************************************************************

StartSystem:
		call 	GFXClearScreen 						; clear the screen
		ld 		hl,SystemIntroMessage
		ld 		de,$ABCD
;
;					Come here with message to be shown in HL
;
ErrorHandler: 										; handle error, message is at HL
		ld 		sp,(SIStack)						; reset stack
		push 	de 									; save DE for now
		push 	hl 									; save message
;
;		Clear bottom lines
;
		ld 		hl,(DIScreenSize)					; clear the bottom 2 lines.
		ld 		de,-64
		add 	hl,de
__CLIClearLoop:
		ld 		de,$0720
		call 	GFXWriteCharacter
		inc 	hl
		djnz 	__CLIClearLoop
;
;		Display error message
;
		pop 	bc  								; error message into BC
		ld 		hl,(DIScreenSize)  					; error message from bottom-48 onwards.
		ld 		de,-48
		add 	hl,de
__CLIDisplayMessage:
		ld 		a,(bc)
		ld 		e,a
		add 	a,a
		jr 		c,__CLIDisplayStack 				; bit 7 set
		jr 		z,__CLIDisplayStack					; or zero
		ld 		d,2
		call 	GFXWriteCharacter
		inc 	hl
		inc 	bc
		jr 		__CLIDisplayMessage
;
;		Show A and B
;
__CLIDisplayStack: 									; display A and B
		ld 		hl,(DIScreenSize)
		ld 		bc,-32
		add 	hl,bc

;		Enter the command line
;
__CLIEnterCommandLine:
		ld 		hl,(DIScreenSize) 					; HL = start of entry
		ld 		de,-64
		add 	hl,de
		ld 		ix,CLIBuffer 						; IX = character position.

__CLILoop:
		ld 		de,$047F 							; write the cursor out
		call 	GFXWriteCharacter 					
		call 	CLIGetKey 							; key get
		cp 		13
		jr		z,__CLIExecuteWord
		cp 		32 									; execute on space or return
		jr		z,__CLIExecuteWord
		jr 		c,__CLILoopBack 					; any control clears word

		ld 		(ix+0),a 							; put in buffer
		ld 		e,a 								; display on screen
		ld 		d,6
		call 	GFXWriteCharacter
		ld 		a,l 								; check reached limit
		and 	$1F
		cp 		$1E
		jr 		z,__CLIEnterCommandLine
		inc 	hl 									; go round again with one extra character
		inc 	ix
		jr 		__CLILoop
;
;		Execute word in buffer
;
__CLIExecuteWord:
		pop 	de
		db 		$DD,$01

__CLILoopBack:
		ld 		hl,SystemEmptyMessage
		jp 		ErrorHandler

SystemIntroMessage:
		db 		"Flat 21-11-18"
SystemEmptyMessage:
		db 		" ",$FF

;
;		Display DE in Decimal at HL
;
__CLIDisplayDecimal:

;
;		Get keystroke into A (No repeating)
;
CLIGetKey:
		push 	bc
__CLIWaitChange:
		call 	__CLIGetKeyboardChange
		or 		a
		jr 		z,__CLIWaitChange
		pop 	bc
		ret

__CLIGetKeyboardChange:
		call 	IOScanKeyboard
		ld 		b,a
		ld 		a,(CLILastKeyboardState)
		cp 		b
		jr 		z,__CLIGetKeyboardChange
		ld 		a,b
		ld 		(CLILastKeyboardState),a
		ret

		