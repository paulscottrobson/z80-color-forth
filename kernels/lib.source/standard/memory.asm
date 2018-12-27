; *********************************************************************************
; *********************************************************************************
;
;		File:		memory.asm
;		Purpose:	Memory access words
;		Date : 		27th December 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************
	
@macro @
		ld 		a,(hl)
		inc 	hl
		ld 		h,(hl)
		ld 		l,a
@end

@macro !
		pop 	de
		ld 		(hl),e
		inc 	hl
		ld 		(hl),d
		pop 	hl
@end

@macro b@
		ld 		l,(hl)
		ld 		h,0
@end

@macro b!
		pop 	de
		ld 		(hl),e
		pop 	hl
@end

@word.ix +!
		pop 	de
		ld 		a,(hl)
		add 	a,e
		ld 		(hl),a
		inc 	hl
		ld 		a,(hl)
		adc 	a,d
		ld 		(hl),a
		pop 	hl
@end

@macro @a+
		ld 		l,(ix+0)
		ld 		h,(ix+1)
		inc 	ix
		inc 	ix
@end

@macro b@a+				
		ld 		l,(ix+0)
		ld 		h,0
		inc 	ix
@end

@macro !a+
		ld 		(ix+0),l
@macro b!a+				same but byte

@macro a! 					TOS>A
@macro a@ 					A>TOS
@macro @a 					Fetch from A
@macro !a 					Store to A
@macro b@a 
@macro b!a 			Byte equivalents


@a[n]				Fetch from A+n (0,2,4,6,8,10,12,14)
!a[n]				Store to A+n (0,2,4,6,8,10,12,14) 

