; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		data.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		27th December 2018
;		Purpose :	Data area
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;								System Information
;
; ***************************************************************************************

SystemInformation:

Here:												; +0 	Here 
		dw 		FreeMemory
HerePage: 											; +2	Here.Page
		db 		FirstCodePage,0
NextFreePage: 										; +4 	Next available code page (2 8k pages/page)
		db 		FirstCodePage+2,0,0,0
DisplayInfo: 										; +8 	Display information
		dw 		DisplayInformation,0		
Parameter: 											; +12 	Third Parameter used in some functions.
		dw 		0,0
StartAddress: 										; +16 	Start Address
		dw 		__KernelHalt
StartAddressPage: 									; +20 	Start Page
		db 		FirstCodePage,0

; ***************************************************************************************
;
;							 Display system information
;
; ***************************************************************************************

DisplayInformation:

SIScreenWidth: 									; +0 	screen width
		db 		0,0,0,0
SIScreenHeight:									; +4 	screen height
		db 		0,0,0,0
SIScreenSize:									; +8 	screen size
		dw 		0,0
SIFontBase:										; +12 	font in use
		dw 		AlternateFont,0
SIScreenDriver:									; +16 	screen driver pointer
		dw 		0 										

TempStack:										; 16 word element stack
		ds 		32 								
TempStackOffset:								; current offset.
		dw 		0 											
		
FreeMemory:		