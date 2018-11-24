; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		16th November 2018
;		Purpose :	FlatColorForth Kernel
;
; ***************************************************************************************
; ***************************************************************************************


;
;		Page allocation. These need to match up with those given in the page table
;		in data.asm
;													
DictionaryPage = $20 								; dictionary page
SourceFirstPage = $22 								; bootstrap page
SourcePages = 64
FirstCodePage = SourceFirstPage + SourcePages/16	; first page of actual code.
								
;
;		Memory allocated from the Unused space in $4000-$7FFF
;
EditBuffer = $7B08 									; $7B00-$7D20 512 byte edit buffer
StackTop = $7EFC 									;      -$7EFC Top of stack

		opt 	zxnextreg
		org 	$8000 								; $8000 boot.
		jr 		Boot
		org 	$8004 								; $8004 address of sysinfo
		dw 		SystemInformationTable

Boot:	ld 		sp,(SIStack)						; reset Z80 Stack
		di											; disable interrupts
	
		db 		$ED,$91,7,2							; set turbo port (7) to 2 (14Mhz speed)
		ld 		l,0 								; set graphics mode 0 (48k Spectrum)
		call 	GFXMode

		ld 		a,(SIBootCodePage) 					; get the page to start
		call 	PAGEInitialise
		ld 		hl,(SIBootCodeAddress) 				; get boot address
		jp 		(hl) 								; and go there

ErrorHandler:
		jr 		ErrorHandler

HaltZ80:di
		halt
		jr 		HaltZ80

		include "support/paging.asm" 				; page switcher (not while executing)
		include "support/farmemory.asm" 			; far memory routines
		include "support/divide.asm" 				; division
		include "support/multiply.asm" 				; multiplication
		include "support/graphics.asm" 				; common graphics
		include "support/keyboard.asm"
		include "support/screen48k.asm"				; screen "drivers"
		include "support/screen_layer2.asm"
		include "support/screen_lores.asm"
		include "support/utilities.asm"				; utility functions
		include "support/dumpstack.asm"				; stack display.

		include "compiler/dictionary.asm"			; dictionary add/update routines.
		include "compiler/buffer.asm"				; buffer routines.
		include "compiler/constant.asm" 			; ASCII -> Int conversion
		include "compiler/compiler.asm"				; actual compiler code.
				
		include "temp/__words.asm" 					; and the actual words

AlternateFont:										; nicer font
		include "font.inc" 							; can be $3D00 here to save memory

		include "data.asm"		

		org 	$C000
		db 		0 									; start of dictionary, which is empty.
