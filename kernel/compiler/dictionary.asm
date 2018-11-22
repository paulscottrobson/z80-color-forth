; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		dictionary.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd November 2018
;		Purpose :	Dictionary handler.
;
; ***************************************************************************************
; ***************************************************************************************

; ***********************************************************************************************
;
;		Add Dictionary Word. Name is string at HL ends in $80-$FF, uses the current page/pointer
;		values. C identifies whether MACRO ($40) or FORTH $(00)
;
; ***********************************************************************************************

DICTAddWord:
		push 	af 									; registers to stack.
		push 	bc
		push 	de
		push	hl
		push 	ix
		push 	hl 									
		ld 		b,-1								; put length of string in B
__DICTAddGetLength:
		inc 	hl
		inc 	b
		bit 	7,(hl)
		jr 		z,__DICTAddGetLength
		pop 	hl

		ld 		a,DictionaryPage					; switch to dictionary page
		call 	PAGESwitch

		ld 		ix,$C000							; IX = Start of dictionary

__DICTFindEndDictionary:
		ld 		a,(ix+0) 							; follow down chain to the end
		or 		a
		jr 		z,__DICTCreateEntry
		ld 		e,a
		ld 		d,0
		add 	ix,de
		jr 		__DICTFindEndDictionary

__DICTCreateEntry:
		ld 		a,b
		add 	a,5
		ld 		(ix+0),a 							; offset is length + 5

		ld 		a,(SINextFreeCodePage)				; code page
		ld 		(ix+1),a
		ld 		de,(SINextFreeCode)					; code address
		ld 		(ix+2),e
		ld 		(ix+3),d 

		ld 		a,c 								; get FORTH/MACRO flag
		and 	$80
		or 		b 									; or length in
		ld 		(ix+4),a 							; length (0..5) forth/macro (7)

		ex 		de,hl 								; put name in DE
		inc 	de 									; skip over tag.
__DICTAddCopy:
		ld 		a,(de) 								; copy byte over as 7 bit ASCII.
		ld 		(ix+5),a
		inc 	ix 									
		inc 	de
		djnz	__DICTAddCopy 						; until string is copied over.

		ld 		(ix+5),0 							; write end of dictionary zero.

		call 	PAGERestore
		pop 	ix 									; restore and exit
		pop 	hl
 		pop 	de
		pop 	bc
		pop 	af
		ret

; ***********************************************************************************************
;
;			Find word in dictionary. HL points to name. C is the mask for flag/macro.
;			On exit, HL is the address and E the page number with CC if found, 
;			CS set and HL=DE=0 if not found.
;
; ***********************************************************************************************

DICTFindWord:
		push 	bc 								; save registers - return in EHL Carry
		push 	ix

		ld 		a,DictionaryPage 				; switch to dictionary page
		call 	PAGESwitch

		ld 		ix,$C000 						; dictionary start			
__DICTFindMainLoop:
		ld 		a,(ix+0)						; examine offset, exit if zero.
		or 		a
		jr 		z,__DICTFindFail

		ld 		a,(ix+4) 						; get the flag/macro (and length) byte
		xor 	c 								; xor with the mask
		and 	$80 							; only interested in bit 7
		jr 		nz,__DICTFindNext 				; so if different, go to next.

		push 	ix 								; save pointers on stack.
		push 	hl 

		ld 		a,(ix+4) 						; characters to compare
		and 	$3F
		ld 		b,a
		inc 	hl 								; skip over tag
__DICTCheckName:
		ld 		a,(ix+5) 						; compare dictionary vs character.
		cp 		(hl) 							; compare vs the matching character.
		jr 		nz,__DICTFindNoMatch 			; no, not the same word.
		inc 	hl 								; HL point to next character
		inc 	ix
		djnz 	__DICTCheckName

		bit 	7,(hl)							; if so, see if the next one is EOW
		jr 		z,__DICTFindNoMatch 			; if not , bad match.

		pop 	hl 								; Found a match. restore HL and IX
		pop 	ix
		ld 		d,0 							; D = 0 for neatness.
		ld 		e,(ix+1)						; E = page
		ld 		l,(ix+2)						; HL = address
		ld 		h,(ix+3)		
		xor 	a 								; clear the carry flag.
		jr 		__DICTFindExit

__DICTFindNoMatch:								; this one doesn't match.
		pop 	hl 								; restore HL and IX
		pop 	ix
__DICTFindNext:
		ld 		e,(ix+0)						; DE = offset
		ld 		d,$00
		add 	ix,de 							; next word.
		jr 		__DICTFindMainLoop				; and try the next one.

__DICTFindFail:
		ld 		de,$0000 						; return all zeros.
		ld 		hl,$0000
		scf 									; set carry flag
__DICTFindExit:
		push 	af
		call 	PAGERestore
		pop 	af
		pop 	ix 								; pop registers and return.
		pop 	bc
		ret

