; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		buffer.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		23rd November 2018
;		Purpose :	Buffer read/write routines.
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;			Given a buffer# in BC, convert that to a page A, and address BC.
;
; ***************************************************************************************

BUFFindBuffer:
		push 	bc 									; save buffer number
		ld 		a,5 								; divide by 32
__BUFDiv32:
		srl 	b
		rr 		c
		dec 	a
		jr 		nz,__BUFDiv32 						; this gives the index into the page
		ld 		a,SourceFirstPage 					; add it twice to first page gives page #
		add 	a,c 								; where the buffer is.
		add 	a,c

		pop  	bc 									; get the buffer number back
		push 	af 									; save buffer page

		ld 		a,c 								; this is the index in the page
		and 	31
		add 	a,a 								; index x 2 
		or 		$C0 								; put into $C000-$FFF range
		ld 		b,a 								; BC = this index x 512
		ld 		c,0

		pop 	af 									; A = saved buffer page
		ret

; ***************************************************************************************
;			
;							Load Buffer at A:BC into Edit Buffer
;
; ***************************************************************************************

BUFLoadBuffer:
		push 	af
		push 	bc
		push 	de
		push 	hl
		call 	PAGESwitch 							; switch to $22
		ld 		l,c 								; copy it in.
		ld 		h,b
		ld 		de,EditBuffer
		ld 		bc,512
		ldir
		call 	PAGERestore 						; go back
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***************************************************************************************
;			
;							Save Buffer into memory at A:BC 
;
; ***************************************************************************************

BUFSaveBuffer:
		push 	af
		push 	bc
		push 	de
		push 	hl
		call 	PAGESwitch 							; switch to $22
		ld 		e,c 								; copy it in.
		ld 		d,b
		ld 		hl,EditBuffer
		ld 		bc,512
		ldir
		call 	PAGERestore 						; go back
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret
