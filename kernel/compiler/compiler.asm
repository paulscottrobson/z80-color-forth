; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		compiler.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Source loader
;		Date : 		23rd November 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
; ********************************************************************************************************
;
;	 Handle the word in BC. The current uncached stack is at DE (e.g. TOS is on the stack)
;					Returns DE possibly changed depending on what's been done.
;
;	Note each level of stack needs its own stack. So we really only want three levels of
; 	reentrancy.  L1 : Loading the bootstrap L2 : Executing a typed word in the CLI
;	L3 : compiling code as a result of that word.
;
;	The stack is only needed for messing around in here though.
;
; ********************************************************************************************************
; ********************************************************************************************************

COMCompileExecute:

		push 	bc
		push 	hl 									; save BC, HL and IX.
		push 	ix

		push 	de 									; put the "data stack" in ix
		pop 	ix

		ld 		a,(bc) 								; read the tag.
		cp 		$84
		jp 		z,__COMCE_Compiler_Green
		cp 		$86
		jp 		z,__COMCE_Executor_Yellow
;
;						  Come here to exit successfully
;
__COMExit: 
		push 	ix 									; transfer the "data stack" to DE
		pop 	de

		pop 	ix									; restore IX and HL and BC
		pop 	hl
		pop 	bc
		ret
;
;									Come here to fail
;
__COMError:
		push 	bc 									; put the word in HL
		pop 	hl
		inc 	hl 									; skip the tag
		jp 		ErrorHandler

; ********************************************************************************************************
;
;										Green Compiler
;
; ********************************************************************************************************

__COMCE_Compiler_Green:
		ld 		a,$80 								; look for the word in MACRO
		call 	DICTFindWord
		jp 		nc,__COMCE_ExecuteEHL 				; if found then *execute* it.

		ld 		a,$00 								; look for the word in FORTH
		call 	DICTFindWord
		jp 		nc,__COMCE_CompileCallEHL 			; if found then compile a call to it.

		call 	CONSTConvert 						; try a number.
		jp 		nc,__COMCE_CompileConstantCode		; if found then compile a push integer

		jp 		__COMError

; ********************************************************************************************************
;
;										Yellow Compiler
;
; ********************************************************************************************************

__COMCE_Executor_Yellow:
		ld 		a,$00 								; look for the word in FORTH
		call 	DICTFindWord
		jp 		nc,__COMCE_ExecuteEHL 				; if found then *execute* it.

		call 	CONSTConvert 						; try a number.
		jp 		nc,__COMCE_ExecuteConstantCode		; if found then compile a push integer

		jp 		__COMError

; ********************************************************************************************************
;
;							  Compile code to Push constant HL
;
; ********************************************************************************************************

__COMCE_CompileConstantCode:
		ld 		a,$D5 								; PUSH DE
		call 	FARCompileByte
		ld 		a,$11 								; LD DE,xxxx
		call 	FARCompileByte		
		call 	FARCompileWord 						; the constant
		jp 		__COMExit 							; and we are done.

; ********************************************************************************************************
;
;							  Compile code to call code at EHL
;
; ********************************************************************************************************

__COMCE_CompileCallEHL:
		;
		;		TODO *** If HL >= $C000 and E != Here.Page then paging call required.
		;
		ld 		a,$CD 								; call
		call 	FARCompileByte		
		call 	FARCompileWord 						; the constant
		jp 		__COMExit 							; and we are done.

; ********************************************************************************************************
;
;				    Execute routine at EHL. This needs to be re-entrant
;
; ********************************************************************************************************

__COMCE_ExecuteEHL:
		ld 		a,e 								; first, switch to that page
		call 	PAGESwitch
		ex 		de,hl 								; put the call address in DE for a minute

		ld 		hl,$0000 							; get the actual SP value.
		add 	hl,sp

		ld 		bc,(COMXStackPointer)				; Push it on the stack used by Compiler.
		ld 		a,l
		ld 		(bc),a
		inc 	bc
		ld 		a,h
		ld 		(bc),a
		inc 	bc
		ld 		(COMXStackPointer),bc 

		push 	ix 									; put the runtime stack pointer in SP
		pop 	hl
		ld 		sp,hl 

		ex 		de,hl 								; put address back in HL

		pop 	de  								; cache the TOS in DE.

		call 	__COMCE_CallHL 						; same as CALL (HL)

		push 	de 									; make the stack uncached.

		ld 		hl,$0000 							; copy SP back into IX
		add 	hl,sp 								; the save place of the working stack.
		push 	hl
		pop 	ix

		ld 		hl,(COMXStackPointer) 				; retrieve the old stack pointer
		dec 	hl
		ld 		d,(hl)
		dec 	hl
		ld 		e,(hl)
		ld 		(COMXStackPointer),hl 

		ex 		de,hl 								; and put it in SP
		ld 		sp,hl

		call 	PAGERestore 						; restore the original page

		jp 		__COMExit							; and we're done :)

__COMCE_CallHL:
		jp 		(hl)

; ********************************************************************************************************
;
;					Modify the Stack at IX so it has HL on the top now
;	
; ********************************************************************************************************

__COMCE_ExecuteConstantCode:
		ld 		(ix-2),l 							; IX is our uncached stack.
		ld 		(ix-1),h
		dec 	ix
		dec 	ix
		jp 		__COMExit
