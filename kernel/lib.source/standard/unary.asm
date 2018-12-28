; *********************************************************************************
; *********************************************************************************
;
;		File:		unary.asm
;		Purpose:	Unary words
;		Date : 		28th December 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

@copier - 
	ld	a,h
	cpl	
	ld 	h,a
	ld 	a,l
	cpl 	
	ld 	l,a
@end

@copier 2* 
	add hl,hl
@end

@copier 2/ 
	sra h
	rr 	l
@end

@word.ret abs 
	bit 7,h
	ret z
	ld	a,h
	cpl	
	ld 	h,a
	ld 	a,l
	cpl 	
	ld 	l,a
	inc	hl
@end

@copier 4* 
	add hl,hl
	add hl,hl
@end

@copier 8* 
	add hl,hl
	add hl,hl
	add hl,hl
@end

@copier 16* 
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
@end


@copier bswap 
	ld 	a,l
	ld 	l,h
	ld 	h,a
@end

@word.ret 0< 
	bit 7,h
	ld 	hl,$0000
	ret z
	dec hl
@end

@word.ret 0= 
	ld 	a,h
	or 	l
	ld 	hl,$0000
	ret nz
	dec hl
@end

@word.ret negate
	ld	a,h
	cpl	
	ld 	h,a
	ld 	a,l
	cpl 	
	ld 	l,a
	inc	hl
@end

	
