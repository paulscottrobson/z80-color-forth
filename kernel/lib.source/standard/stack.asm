; *********************************************************************************
; *********************************************************************************
;
;		File:		stack.asm
;		Purpose:	Spectrum Keyboard Interface
;		Date : 		28th December 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;						standard stack routines, all macros
; *********************************************************************************
	
@copier 	drop
	pop 	hl
@end

@copier 	dup
	push 	hl
@end

@copier 	nip
	pop 	de
@end

@copier 	swap
	pop 	de
	ex 		de,hl
	push 	de
@end

@copier 	over
	pop 	de
	push 	de
	push 	hl
	ex 		de,hl
@end

; *********************************************************************************
;	we cannot do r> and >r because of the reentrancy, so push and pop have a 
;	small stack so it can be used as a temp, which is mostly what it's used for
;	anyway.
; *********************************************************************************

@word.ix 	push
	ex 		de,hl
	ld 		hl,(TempStackOffset)
	ld 		bc,TempStack
	add 	hl,bc
	ld 		(hl),e
	inc 	hl
	ld 		(hl),d

	ld 		hl,TempStackOffset
	inc 	(hl)
	inc 	(hl)

	ld 		a,(hl)
	and 	$1F
	ld 		(hl),a

	pop 	hl
@end

@word.ix 	pop
	push 	hl

	ld 		hl,TempStackOffset
	dec 	(hl)
	dec 	(hl)
	ld 		a,(hl)
	and 	$1F
	ld 		(hl),a

	ld 		hl,(TempStackOffset)
	ld 		de,TempStack
	add 	hl,de

	ld 		e,(hl)
	inc 	hl
	ld 		d,(hl)
	ex 		de,hl
@end	

