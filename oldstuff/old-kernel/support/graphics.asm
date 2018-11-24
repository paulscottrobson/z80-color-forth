; *********************************************************************************
; *********************************************************************************
;
;		File:		graphics.asm
;		Purpose:	General screen I/O routines
;		Date : 		22nd November 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;									Clear screen
;
; *********************************************************************************

GFXClearScreen:
		push 	hl 									; clear screen by reinitialising
		ld 		a,(DIScreenMode)
		ld 		l,a
		call 	GFXMode
		pop 	hl
		ret

; *********************************************************************************
;
;								Set Graphics Mode to L
;
; *********************************************************************************

GFXMode:
		push 	bc
		push 	de
		push 	hl
		ld 		a,l 								; save current mode
		ld 		(DIScreenMode),a
		dec 	l 									; L = 1 mode layer2
		jr 		z,__GFXLayer2
		dec 	l
		jr 		z,__GFXLowRes 						; L = 2 mode lowres

		call 	GFXInitialise48k					; L = 0 or anything else, 48k mode.
		jr 		__GFXConfigure

__GFXLayer2:
		call 	GFXInitialiseLayer2
		jr 		__GFXConfigure

__GFXLowRes:
		call 	GFXInitialiseLowRes

__GFXConfigure:
		ld 		a,l 								; save screen size
		ld 		(DIScreenWidth),a
		ld 		a,h
		ld 		(DIScreenHeight),a
		ex 		de,hl 								; save driver
		ld 		(DIScreenDriver),hl

		ld 		l,d 								; put sizes in HL DE
		ld 		h,0
		ld 		d,0
		call 	MULTMultiply16 						; multiply to get size and store.
		ld 		(DIScreenSize),hl

		pop 	hl
		pop 	de
		pop 	bc
		ret

; *********************************************************************************
;
;		Write character D (colour) E (character) to position HL.
;
; *********************************************************************************

GFXWriteCharacter:
		push 	af
		push 	bc
		push 	de
		push 	hl
		ld 		bc,__GFXWCExit
		push 	bc
		ld 		bc,(DIScreenDriver)
		push 	bc
		ret
__GFXWCExit:
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; *********************************************************************************
;
;						Write hex word DE at position HL
;
; *********************************************************************************

GFXWriteHexWord:
		ld 		a,6 
GFXWriteHexWordA:
		push 	bc
		push 	de
		push 	hl
		ld 		c,a
		ld 		a,d
		push 	de
		call 	__GFXWHByte
		pop 	de
		ld 		a,e
		call	__GFXWHByte
		pop 	hl
		pop 	de
		pop 	bc
		ret

__GFXWHByte:
		push 	af
		rrc 	a
		rrc		a
		rrc 	a
		rrc 	a
		call 	__GFXWHNibble
		pop 	af
__GFXWHNibble:
		ld 		d,c
		and 	15
		cp 		10
		jr 		c,__GFXWHDigit
		add		a,7
__GFXWHDigit:
		add 	a,48
		ld 		e,a
		call 	GFXWriteCharacter
		inc 	hl
		ret

; *********************************************************************************
;
;				For character A, put address of character in DE
;
; *********************************************************************************

GFXGetFontGraphicDE:
		push 	af
		push 	hl
		and 	$7F 								; bits 0-6 only.
		sub 	32
		ld 		l,a 								; put in HL
		ld 		h,0
		add 	hl,hl 								; x 8
		add 	hl,hl
		add 	hl,hl
		ld 		de,(DIFontBase) 					; add the font base.
		add 	hl,de
		ex 		de,hl 								; put in DE (font address)

		pop 	hl
		pop 	af
		cp 		$7F 								; map $7F to the prompt character
		ret 	nz
		ld 		de,__GFXPromptCharacter
		ret

__GFXPromptCharacter:
		db 		$FC,$7E,$3F,$1F
		db 		$1F,$3F,$7E,$FC

