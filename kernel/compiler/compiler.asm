; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		compiler.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		20th November 2018
;		Purpose :	Compile/Execute code.
;
; ***************************************************************************************
; ***************************************************************************************

CompilerTest:				; bodge ; part of CLI loader eventually
		ld 		de,-1
		push 	de

		ld 		de,$5AC2 	; set up a fake stack :)
		push 	de
		ld 		de,$5AC1

		ld 		bc,0
		call 	COMCompileBuffer
w1: 	jr 		w1

; ***************************************************************************************
; ***************************************************************************************
;
;					Compile the buffer given in BC. Not re-entrant.
;				Called as normal word, so DE is TOS and data on Z80 Stack
;
;			   NOT re-entrant. Could technically call itself but will error.
;
; ***************************************************************************************
; ***************************************************************************************

COMCompileBuffer:
		pop 	hl 									; return address, back to a data stack
		ld 		(__COMCBOut+1),hl 					; save for leaving.
		push 	de 									; make the stack uncached.

		ld 		hl,COMReentrancy 					; reentrancy ???
		bit 	7,(hl) 								; if it's already -ve, then we're in a second time
__COMFailReentrancy:
		jr 		nz,__COMFailReentrancy
		dec 	(hl)

		call 	BUFFindBuffer 						; A:BC is the buffer page/address
		call 	BUFLoadBuffer 						; load buffer into edit buffer.

		ld 		hl,$0000							; put the stack in IX and HL
		add 	hl,sp
		push 	hl
		pop 	ix

		ld 		bc,-64 								; make working space so we can put stuff
		add 	hl,bc 								; on the stack at IX without stuffing up
		ld 		sp,hl								; this code.

		ld 		bc,EditBuffer 						; now process it.
__COMCBTag:
		ld 		a,(bc) 								; look at the first word
		cp 		$FF 								; reached the end ?
		jr 		z,__COMCBExit

;		db 		$DD,$01

		ld 		a,(bc)
		cp 		$82 								; red (defining word)
		call 	z,COMDefinition_Red
		ld 		a,(bc)
		cp 		$83 								; magenta (variable word)
		call 	z,COMDefinition_Magenta	
		ld 		a,(bc)
		cp 		$84 								; green (compile) word
		call 	z,COMCompileWord_Green
		ld 		a,(bc)
		cp 		$85 								; cyan (compile) word
		call 	z,COMCompileWord_Cyan
		ld 		a,(bc)
		cp 		$86 								; yellow (execute) word
		call 	z,COMExecuteWord_Yellow
__COMCBNext: 										; go to the next tag/end (bit 7 set)
		inc 	bc
		ld 		a,(bc)
		bit 	7,a
		jr 		z,__COMCBNext
		jr 		__COMCBTag 								

__COMCBError: 										; error, come here.
		push 	bc
		pop 	hl
		inc 	hl 									; skip over tag.
		jp 		ErrorHandler

__COMCBExit:
		ld 		hl,(COMReentrancy)					; bump the reentrancy count
		inc 	(hl)
		ld 		sp,ix
		pop 	de 									; make the stack uncached again.
__COMCBOut:
		jp 		$0000

; ***************************************************************************************
;
;		Red words. Create a definition at this point, and compile the preamble.
;
; ***************************************************************************************

COMDefinition_Red:
		ret

; ***************************************************************************************
;
;	 	Magenta words. Variables (that don't autoupdate the source). Create a definition
;	 	and follow it with a call to the code to push the address on the stack, and 
;		data space.
;
; ***************************************************************************************

COMDefinition_Magenta:
		ld 		a,$00 								; put it in the WORD dictionary.
		call 	DICTAddWord 				
		ld 		a,$CD 								; compile call to the magenta handler.
		call 	FARCompileByte
		ld 		hl,COMVariableSupport 			
		call 	FARCompileWord
		ld 		hl,$0000 							; and the variable space.
		call 	FARCompileWord
		ret

COMVariableSupport:
		pop 	bc 									; the variable address into BC
		pop 	hl  								; the return address after calling.
		push 	de 									; push TOS cached onto stack
		ld 		d,b 								; variable address is new TOS
		ld 		e,c 	
		jp 		(hl) 								; and go to the caller.


; ***************************************************************************************
;
;		Green words. If in the Macro dictionary, execute it. If in the Forth dictionary
; 		compile it. If it's a number, compile the code for it.
;
; ***************************************************************************************

COMCompileWord_Green:
		ld 		a,$80 								; search in MACRO
		call 	DICTFindWord
		jp 		nc,COMW_CallRoutineAtEHL 			; if found execute.

		ld 		a,$00 								; search in FORTH
		call 	DICTFindWord
		jp 		nc,COMW_CompileCalltoEHL 			; compile code to call it

		call 	CONSTConvert						; is it a constant
		jp 		nc,COMW_CompileConstantHL 			; compile code to compile it.

		jp 		__COMCBError 						; report an error

; ***************************************************************************************
;
;		Cyan words. If in the Macro dictionary, compile it. Included for compatibility
;		(probably)
;
; ***************************************************************************************

COMCompileWord_Cyan:
		ld 		a,$80 								; search in MACRO
		call 	DICTFindWord
		jp 		nc,COMW_CompileCalltoEHL 			; compile code to call it

		jp 		__COMCBError 						; report an error

; ***************************************************************************************
;
;		Yellow words. If in the execute dictionary, execute them, using the cached
;		stack in IX. If a number, push that number on the cached stack at IX.
;
; ***************************************************************************************

COMExecuteWord_Yellow:
		ld 		a,$00 								; search in FORTH
		call 	DICTFindWord
		jp 		nc,COMW_CallRoutineAtEHL 			; if found execute.

		call 	CONSTConvert						; is it a constant
		jp 		c,__COMCBError 						; no, report error

		dec 	ix 									; put it on the 'stack'
		dec 	ix 									; that is kept in IX.
		ld 		(ix+0),l
		ld 		(ix+1),h
		ret

; ***************************************************************************************
;
;						Compile code to call function at A:HL
;
; ***************************************************************************************

COMW_CompileCalltoEHL:
		;
		; TODO: if call to >$C000 and here.page != E then paged call
		;
		ld 		a,$CD
		call 	FARCompileByte
		call 	FARCompileWord
		ret

; ***************************************************************************************
;
;					 Compile code to push constant HL on the stack
;
; ***************************************************************************************

COMW_CompileConstantHL:
		ld 		a,$D5
		call 	FARCompileByte
		ld 		a,$11
		call 	FARCompileByte
		call 	FARCompileWord
		ret

; ***************************************************************************************
;
;				Call the routine at E:HL using IX as the (uncached) stack.
;							This one belongs to the Compiler Code
;
; ***************************************************************************************

COMW_CallRoutineAtEHL:
		push 	bc
		ld 		(COMStackTemp),sp 					; save the stack pointer
		ld 		a,e
		call 	PAGESwitch 							; switch to page E

		ld 		sp,ix 								; now back with the data stack
		pop 	de 									; make it cached (e.g. DE = TOS)

		call 	__COMW_CallHL 						; call the routine

		push 	de 									; make it uncached (all values on stack)
		ld 		ix,$0000 							; put it back in IX
		add 	ix,sp

		call 	PAGERestore 						; restore the page
		ld 		sp,(COMStackTemp) 					; and the stack pointer.
		pop 	bc
		ret

; ***************************************************************************************
;
;				Call the routine at E:HL with cached stack state. Used by CLI
;
; ***************************************************************************************

COMW_CallRoutineAtAHL_ConsoleVersion:
		pop 	bc 									; return address. makes stack right
		ld 		(__COMW_CVOut+1),bc
		ld 		a,e
		call 	PAGESwitch 							; switch to that page.
		call 	__COMW_CallHL 						; call the routine to call (HL)
		call 	PAGERestore 						; fix the page back up
__COMW_CVOut:
		jp 		$0000

;
;		Helper function, calling this effectively does CALL (HL)
;
__COMW_CallHL:
		jp 		(hl) 
		