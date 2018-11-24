; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		compiler.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd November 2018
;		Purpose :	Compile/Execute code.
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;		On entry HL points to a word, which is a tag followed by text, followed by
; 		a byte with bit 7 set. The stack is in (SP) DE as usual, this is a callable
; 		word. It should *not* be used by the interpreter as it is *not* re-entrant.
;
; ***************************************************************************************

COMCompileExecute:
	pop 	bc 										; get the return address.
	ld 		(__COMCEOut+1),bc 						; save the return address

	push 	de 										; save DE on the stack, so this is a normal stack (no DE cache)
	ld 		(__COMCELoadSP+1),sp 					; save the stack pointer to be reloaded

	ld 		sp,COMWorkingStack 						; we have a new SP for stuff.
	push 	hl
	push 	ix

	ld 		b,h 									; put the word address in BC
	ld 		c,l
	ld 		a,(hl) 									; get the tag
	cp 		$84 									; is it green (execute macro, compile forth,compile number)
	jp 		z,__COMGreenWord
	cp 		$85										; is it cyan (compile macro)
	jp 		z,__COMCyanWord 						
	cp 		$86 									; is it yellow (execute)
	jr 		z,__COMYellowWord

; =======================================================================================
;
;		Come her on error.
;
; =======================================================================================

__COMError:
	ld 		h,b
	ld 		l,c
	inc 	hl
	jp 		ErrorHandler

; =======================================================================================
;
;		Come here to exit
;
; =======================================================================================

__COMExit:
	pop 	ix
	pop 	hl
__COMCELoadSP:
	ld 		sp,$0000 								; reload the complete stack
	pop 	de 										; make it a DE cached stack.
__COMCEOut:
	jp 		$0000 									; effectively, RET

; =======================================================================================
;
;		This is a green word. If it is in macro, then we run that word. If it is in
; 		FORTH, we compile that word. If it is a number, compile that code.
;
; =======================================================================================

__COMGreenWord:
	ld 		a,$80 									; is it in the MACRO dictionary
	call 	DICTFindWord 
	jp 		nc,__COMExecuteEHL 					; execute the word

	ld 		h,b 									; is it in the FORTH dictionary
	ld 		l,c
	ld 		a,$00 
	call 	DICTFindWord
	jp 		nc,__COMCompileEHL 						; compile a call to EHL

	ld 		h,b 									; is it a constant
	ld 		l,c
	call 	CONSTConvert
	jp 		c,__COMError 							; if not, then error
	jp 		__COMCompileConstant

; =======================================================================================
;
;		This is a cyan word. If it is in macro, then we compile that word. If it is in
; 		FORTH, we compile that word.
;
; =======================================================================================

__COMCyanWord:
	ld 		a,$80 									; is it in the MACRO dictionary
	call 	DICTFindWord 
	jp 		nc,__COMCompileEHL 						; execute the word
	jp 		__COMError 								; if not, then error

; =======================================================================================
;
;		This is a yellow word. If it is in FORTH, run it. If it is a number, 
;		push it on the stack.
;
; =======================================================================================

__COMYellowWord:
	ld 		a,$00									; is it in FORTH ?
	call 	DICTFindWord
	jp 		nc,__COMExecuteEHL

	ld 		h,b 									; is it a constant
	ld 		l,c
	call 	CONSTConvert
	jp 		c,__COMError 							; if not, then error
	jp 		__COMPushHLOnStack

; =======================================================================================
;
;							Push HL on the (saved) stack
;
; =======================================================================================

__COMPushHLOnStack:
	ex 		de,hl 									; put number in DE
	ld 		hl,(__COMCELoadSP+1) 					; retrieve stack
	dec 	hl 										; push DE on manually.
	ld 		(hl),d
	dec 	hl
	ld 		(hl),e
	ld 		(__COMCELoadSP+1),hl 					; and write the stack return value back
	jp 		__COMExit

; =======================================================================================
;
;								Execute the word in EHL
;
; =======================================================================================

__COMExecuteEHL:
	ld 		a,e 									; switch to page E
	call 	PAGESwitch
	ld 		(__COMXReloadSP+1),sp 					; set to reload that stack.
	ld 		sp,(__COMCELoadSP+1) 					; reload the stack. 
	pop 	de 										; fix up DE
	call 	__COMCallHL
	push 	de 										; push DE, make the stack uncached
	ld 		(__COMCELoadSP+1),sp 					; update the return stack value.
__COMXReloadSP:
	ld 		sp,$0000 								; reload the working stack.
	call 	PAGERestore 							; restore original page and exit.
	jp 		__COMExit

__COMCallHL:
	jp 		(hl)

; =======================================================================================
;
;					Compile code to push constant HL on the stack
;
; =======================================================================================

__COMCompileConstant:
	ld 		a,$D5 									; Push DE
	call 	FARCompileByte
	ld 		a,$11 									; ld de,0000
	call 	FARCompileByte
	call 	FARCompileWord
	jp 		__COMExit

; =======================================================================================
;
;							Compile a call to the word at EHL
;
; =======================================================================================

__COMCompileEHL:
	;
	; TODO: Paging ,operates if E != HERE.PAGE and HL >= $C000
	;
	ld 		a,$CD 									; but for now, use a normal Z80 call.
	call 	FARCompileByte
	call 	FARCompileWord
	jp 		__COMExit 								; and exit.

