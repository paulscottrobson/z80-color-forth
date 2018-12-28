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
	ld 		hl,(TempStackPointer)
	ld 		(hl),e
	inc 	hl
	ld 		(hl),d
	inc 	hl
	ld 		(TempStackPointer),hl
	pop 	hl
@end

@word.ix 	pop
	push 	hl
	ld 		hl,(TempStackPointer)
	dec 	hl
	ld 		d,(hl)
	dec 	hl
	ld 		e,(hl)
	ld 		(TempStackPointer),hl
	ex 		de,hl
@end	

