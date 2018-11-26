; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		data.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd November 2018
;		Purpose :	Data area
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;									System Information
;
; ***************************************************************************************

SystemInformationTable:

SINextFreeCode: 									; +0 	Next Free Code Byte
		dw 		FreeMemory
SINextFreeCodePage: 								; +2 	Next Free Code Byte Page
		db 		FirstCodePage,0

SIBootCodeAddress:									; +4	Run from here
		dw 		HaltZ80
SIBootCodePage: 									; +6    Run page.
		db		FirstCodePage,0

SIDisplayInformation:								; +8 	Display Information structure address
		dw 		DIScreenWidth,0

SIStack:											; +12 	Initial Z80 stack value
		dw 		StackTop,0							

; ***************************************************************************************
;
;								 Other data and buffers
;
; ***************************************************************************************

PAGEStackPointer: 									; stack used for switching pages
		dw 		0
PAGEStackBase:
		ds 		16
;
;		Page usage table. Note this needs to match up with the definitions in kernel.asm
;
PageUsage:
		db 		1 									; $20 Dictionary (1)
		db 		2 									; $22 First binary code page (2)
		db 		0,0,0,0,0,0 						; to $2E, remaining pages
		db 		0,0,0,0,0,0,0,0 					; $30-$3E
		db 		0,0,0,0,0,0,0,0 					; $40-$4E
		db 		0,0,0,0,0,0,0,0 					; $50-$5E
		db 		$FF
;
;			Display Information
;
DIScreenWidth:										; +0 	Screen Width
		dw 		0,0
DIScreenHeight:										; +4 	Screen Height
		dw 		0,0
DIScreenSize: 										; +8    Screen Size in Characters
		dw 		0,0
DIScreenDriver:										; +12 	Screen Driver
		dw 		0,0 								
DIFontBase:											; +16 	768 byte font, begins with space
		dw 		AlternateFont,0 							
DIScreenMode:										; +20 	Current Mode
		dw 		0,0

		org 	$A000
FreeMemory:		