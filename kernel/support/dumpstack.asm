; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		dumpstack.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		24th November 2018
;		Purpose :	Dump the stack
;
; ***************************************************************************************
; ***************************************************************************************

DUMPShowStack:
		pop 	ix 									; get return address
		push 	de 									; make stack uncached

		ld 		hl,(DIScreenSize) 					; HL = screen size, DE = width
		ld 		de,(DIScreenWidth)
		ld		b,e 								; width in B and C
__DSSClear: 										; clear the bottom line.
		dec 	hl 									; backwards
		ld 		de,$0220 				
		call 	GFXWriteCharacter
		djnz 	__DSSClear

		ld 		hl,$0000							; number of bytes used on the stack.
		add 	hl,sp
		ld 		de,(SIStack)
		xor 	a
		ex 		de,hl
		sbc 	hl,de
		jr 		c,__DSSExit 						; popped off stack (!)
		ld 		a,l
		or 		a
		jr 		z,__DSSExit 						; empty sack

		rra 										; halve it, number of entries to display.
		ld 		b,a 								; put that count of entries in B

		ld 		hl,(DIScreenSize) 					; HL = screen size, DE = width
		ld 		de,(DIScreenWidth)
		xor 	a 									; calculate start of last line
		sbc 	hl,de

		ld 		de,(SIStack)						; DE contains the stack pointer base

__DSSDisplayConstant:								; read next stack entry into A:C
		dec 	de
		ld 		a,(de) 								
		ld 		c,a
		dec 	de
		ld 		a,(de)													
		push 	de 									; save DE
		ld 		e,a 								; put stack entry in DE.
		ld 		d,c 
		call 	__DSSPrint 							; print the number
		pop 	de 									; restore DE
		inc 	hl 									; leave a space
		djnz 	__DSSDisplayConstant 				; do them all.

__DSSExit:
		pop 	de 									; make stack cached
		jp 		(ix)								; and exit.

;
;		Print integer DE at HL
;
__DSSPrint:
		push 	bc
		push 	de

		push 	de
		bit 	7,d
		jr 		z,__DSSDDNotNegative
		ld 		a,d
		cpl 
		ld 		d,a
		ld 		a,e
		cpl 
		ld 		e,a
		inc 	de
__DSSDDNotNegative:
		call 	__DSSDisplayRecursive
		pop 	bc
		ld 		de,$0600+'-'
		bit 	7,b
		jr 		z,__DSDDNoMinus
		call 	GFXWriteCharacter
		inc 	hl
__DSDDNoMinus:
		pop 	de
		pop 	bc
		ret

__DSSDisplayRecursive:
		push 	hl
		ld 		hl,10
		call 	DIVDivideMod16
		ex 		(sp),hl
		ld 		a,d
		or 		e
		call 	nz,__DSSDisplayRecursive
		pop 	de
		ld 		a,e
		add 	a,48
		ld 		e,a
		ld 		d,6
		call 	GFXWriteCharacter
		inc 	hl
		ret
