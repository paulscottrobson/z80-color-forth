;
;			Z80 Skeleton
;	
			opt 	zxnextreg
			org 	$8000
Start:		ld 		sp,$7F00
			ld 		ix,$7E00
			push 	$C823
			push 	$B722			
			ld 		bc,$A011
			ld 		de,CodeList
			db 		$DD,$01

Next:		ld 		a,(de)
			inc 	de
			ld 		l,a
			ld 		a,(de)
			inc 	de
			ld 		h,a
			jp 		(hl)


Entry:		ld 		(ix+0),e
			ld 		(ix+$7E),d
			dec 	ix
			pop 	hl
			ld 		e,(hl)
			inc 	hl
			ld 		d,(hl)
			inc 	hl
			ex 		de,hl
			jp 		(hl)

Exit:		inc 	ix
			ld 		l,(ix+0)
			ld 		h,(ix+$7E)
			ld 		e,(hl)
			inc 	hl
			ld 		d,(hl)
			inc 	hl
			ex 		de,hl
			jp 		(hl)

CodeList:	dw 		add2
			dw 		question
			dw 		incr
			dw 		double

add2:		call 	Entry
			dw 		incr
			dw 		incr
			dw 		Exit

incr:		inc 	bc
			jp 		Next

double:		sla 	c
			rrc 	b
			jp 		Next

question:	push 	bc
			ld 		bc,42
			jp	 	Next







			savesna	"kernel.sna",Start




