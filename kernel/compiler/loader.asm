; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		loader.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Source loader
;		Date : 		19th November 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;									Load the bootstrap page
;
; ********************************************************************************************************

LOADBootstrap:
		ld 		hl,$0000 							; get SP, the operating stack, into DE
		add 	hl,sp
		ex 		de,hl 

		ld 		sp,LOADStack 						; the stack used while loading.

		ld 		a,BootstrapPage 					; set the current page to bootstrap page.
		call 	PAGESwitch
		ld 		ix,$C000 							; current section being loaded.
;
;		Once here for every 'chunk'. We copy the text to the editor buffer in 
;		chunks (currently 1024 bytes) until we've done all 16k of the page.
;
__LOADBootLoop:

		push 	bc 									; save registers
		push 	de
		push 	hl

		push 	ix 									; HL = Current Section in IX.
		pop 	hl
		ld 		de,EditBuffer  						; Copy to edit buffer 1/2k (512 bytes) of code.
		ld 		bc,512
		ldir 	

		ld 		h,0 								; Progress prompt at the screen top.
		ld 		a,ixh
		rrca
		and 	31
		ld 		l,a
		ld 		de,$052A
		call 	GFXWriteCharacter

		pop 	hl 									; restore registers
		pop 	de
		pop 	bc

		ld 		bc,EditBuffer 						; now scan the edit buffer
		call 	LOADScanBuffer 

		ld 		bc,512 								; add 512 size to IX
		add 	ix,bc
		jr 		nc,__LOADBootLoop 					; will cause carry to occur on overflow.

__LOADEnds:
		call 	PAGERestore 						; restore page
		jp 		HaltZ80 							; and stop
		
; ********************************************************************************************************
;
;		  Process (compiling) the text at BC. The current stack (uncached) is in DE
; 
; ********************************************************************************************************

LOADScanBuffer:
		push 	af
		push 	bc
		push 	ix

__LOADScanLoop:
		ld 		a,(bc) 								; look at tage
		cp 		$FF 								; was it $FF - end of page marker ?
		jr 		z,__LOADScanExit 					; if so, we are done.

		call 	COMCompileExecute 					; execute text at BC, 
													; uncached stack in DE.

__LOADNextWord: 									; look for the next bit 7 high.
		inc 	bc 									; advance forward to next word.
		ld 		a,(bc)
		bit 	7,a
		jr 		z,__LOADNextWord
		jr 		__LOADScanLoop 

__LOADScanExit:
		pop 	ix
		pop 	bc
		pop 	af
		ret
