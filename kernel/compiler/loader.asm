; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		loader.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Source loader
;		Date : 		22nd November 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;									Load the bootstrap page
;
; ********************************************************************************************************

LOADBootstrap:
		ld 		a,BootstrapPage 					; set the current page to bootstrap page.
		call 	PAGESwitch
		ld 		ix,$C000 							; current section being loaded.
		ld 		c,0 								; used to display progress.

		ld 		de,$ABCD
;
;		Once here for every 'chunk'. We copy the text to the editor buffer in 
;		chunks (currently 512 bytes) until we've done all 16k of the page.
;
__LOADBootLoop:
		push 	ix 									; HL = Current Section
		pop 	hl
		push 	bc
		push 	de
		ld 		de,EditBuffer  						; Copy to edit buffer 1/2k (512 bytes) of code.
		ld 		bc,512
		ldir 	
		pop 	de
		pop 	bc

		push 	de
		ld 		h,0 								; Progress prompt.
		ld 		a,ixh 								; derive position.
		rrc 	a
		and 	31
		ld 		l,a
		ld 		de,$022A
		call 	GFXWriteCharacter
		inc 	c
		pop 	de

		ld 		hl,EditBuffer
__LOADScanLoop:
		ld 		a,(hl) 								; look at tage
		cp 		$FF 								; was it $FF ?
		jr 		z,__LOADScanExit 					; if so, we are done.

		call 	COMCompileExecute 					; execute text at HL

__LOADNextWord: 									; look for the next bit 7 high.
		inc 	hl 									; advance forward to next word.
		bit		7,(hl)
		jr 		z,__LOADNextWord
		jr 		__LOADScanLoop

__LOADScanExit:
		ld 		bc,512 								; add 512 size to IX
		add 	ix,bc
		push 	ix									; until wrapped round to $0000
		pop 	bc
		bit 	7,b
		jr 		nz,__LOADBootLoop

__LOADEnds:
		call 	PAGERestore 						; restore page

w2:		jp 		w2 									; go to start interpreter


