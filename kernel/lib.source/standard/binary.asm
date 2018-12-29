; *********************************************************************************
; *********************************************************************************
;
;		File:		binary.asm
;		Purpose:	Binary words
;		Date : 		28th December 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************
	
@word.ix 	*
	pop 	de
	call 	MULTMultiply16
@end

@word.ix 	/
	pop 	de
	call 	DIVDivideMod16
	ex 		de,hl
@end

@word.ix 	mod
	pop 	de
	call 	DIVDivideMod16
@end

@word.ix 	/mod
	pop 	de
	call 	DIVDivideMod16
	push 	hl
	ex 		de,hl
@end

@copier 	+
	pop 	de
	add 	hl,de
@end

@word.ix	and
	pop 	de
	ld 		a,h
	and 	d
	ld 		h,a
	ld 		a,l
	and 	e
	ld 		l,a
@end

@word.ix	or
	pop 	de
	ld 		a,h
	xor 	d
	ld 		h,a
	ld 		a,l
	xor 	e
	ld 		l,a
@end

@word.ix	+or
	pop 	de
	ld 		a,h
	or 		d
	ld 		h,a
	ld 		a,l
	or 		e
	ld 		l,a
@end

@word.ix 	=
	ld 		a,h
	xor 	d
	ld 		h,a
	ld 		a,l
	xor 	e
	or 		h
	ld 		hl,$0000
	jr 		nz,__Not_Equal
	dec 	hl
__Not_Equal:
@end

@word.ix 	<
	pop 	de
	ld 		a,h 									; check signs are different.
	xor 	d 
	jp 		p,__SameSign

	ld 		a,d 									; if 2nd stack value bit 7 set must be <, signs different
	add 	a,a 									; put bit into carry
	jr 		__Less_TrueIfCarry		

__SameSign:
	ex 		de,hl									; check HL < DE
	xor 	a
	sbc 	hl,de 									; CS if HL < DE
__Less_TrueIfCarry:
	ld 		a,0
	sbc 	a,a 									; A = $FF if HL < DE $00 otherwise
	ld 		l,a 									; copy to HL
	ld 		h,a
@end

