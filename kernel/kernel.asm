; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		27th December 2018
;		Purpose :	Flat Forth Kernel
;
; ***************************************************************************************
; ***************************************************************************************

StackTop = $7EFC 									;      -$7EFC Top of stack
DictionaryPage = $20 								; $20 = dictionary page
FirstCodePage = $22 								; $22 = code page.

		org 	$8000 								; $8000 boot.
		jr 		Boot
		org 	$8004 								; $8004 address of sysinfo
		dw 		SystemInformation 

Boot:	ld 		sp,StackTop							; reset Z80 Stack
		di											; disable interrupts
		db 		$ED,$91,7,2							; set turbo port (7) to 2 (14Mhz speed)
	
		ld 		a,(StartAddressPage)				; Switch to start page
		db 		$ED,$92,$56
		inc 	a
		db 		$ED,$92,$57
		dec 	a
		ex 		af,af'								; Set A' to current page.
		ld 		hl,(StartAddress) 					; start running address
		jp 		(hl) 								; and start

__KernelHalt: 										; if boot address not set.
		jr 		__KernelHalt

copyIntoCodeSpace:
		jr 		copyIntoCodeSpace
		
AlternateFont:										; nicer font
		include "font.inc" 							; can be $3D00 here to save memory
		include "temp/__source.asm"
		include "data.asm"

