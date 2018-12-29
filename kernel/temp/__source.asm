; *********************************************************************************
; *********************************************************************************
;
;  File:  graphics.asm
;  Purpose: General screen I/O routines
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************


; =============== @word.ix screen.setmode ==============

define_73_63_72_65_65_6e_2e_73_65_74_6d_6f_64_65:
  pop ix
  call  GFXMode
  pop  hl
  jp (ix)


; =============== @word.ix screen.write ==============

define_73_63_72_65_65_6e_2e_77_72_69_74_65:
  pop ix
  pop  de
  call GFXWriteCharacter
  pop  hl
  jp (ix)


; =============== @word.ix screen.writehex ==============

define_73_63_72_65_65_6e_2e_77_72_69_74_65_68_65_78:
  pop ix
  pop  de
  call GFXWriteHexWord
  pop  hl
  jp (ix)

; *********************************************************************************
;
;        Set Graphics Mode to L
;
; *********************************************************************************

GFXMode:
  push  bc
  push  de
  push  hl
  dec  l          ; L = 1 mode layer2
  jr   z,__GFXLayer2
  dec  l
  jr   z,__GFXLowRes       ; L = 2 mode lowres

  call  GFXInitialise48k     ; L = 0 or anything else, 48k mode.
  jr   __GFXConfigure

__GFXLayer2:
  call  GFXInitialiseLayer2
  jr   __GFXConfigure

__GFXLowRes:
  call  GFXInitialiseLowRes

__GFXConfigure:
  ld   a,l         ; save screen size
  ld   (SIScreenWidth),a
  ld   a,h
  ld   (SIScreenHeight),a
  ex   de,hl         ; save driver
  ld   (SIScreenDriver),hl

  ld   l,d         ; put sizes in HL DE
  ld   h,0
  ld   d,0
  call  MULTMultiply16       ; multiply to get size and store.
  ld   (SIScreenSize),hl

  pop  hl
  pop  de
  pop  bc
  ret

; *********************************************************************************
;
;  Write character D (colour) E (character) to position HL.
;
; *********************************************************************************

GFXWriteCharacter:
  push  af
  push  bc
  push  de
  push  hl
  ld   bc,__GFXWCExit
  push  bc
  ld   bc,(SIScreenDriver)
  push  bc
  ret
__GFXWCExit:
  pop  hl
  pop  de
  pop  bc
  pop  af
  ret

; *********************************************************************************
;
;      Write hex word DE at position HL
;
; *********************************************************************************

GFXWriteHexWord:
  ld   a,5
GFXWriteHexWordA:
  push  bc
  push  de
  push  hl
  ld   c,a
  ld   a,d
  push  de
  call  __GFXWHByte
  pop  de
  ld   a,e
  call __GFXWHByte
  pop  hl
  pop  de
  pop  bc
  ret

__GFXWHByte:
  push  af
  rrc  a
  rrc  a
  rrc  a
  rrc  a
  call  __GFXWHNibble
  pop  af
__GFXWHNibble:
  ld   d,c
  and  15
  cp   10
  jr   c,__GFXWHDigit
  add  a,7
__GFXWHDigit:
  add  a,48
  ld   e,a
  call  GFXWriteCharacter
  inc  hl
  ret
; *********************************************************************************
; *********************************************************************************
;
;  File:  keyboard.asm
;  Purpose: Spectrum Keyboard Interface
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************


; =============== @word.ix inkey ==============

define_69_6e_6b_65_79:
  pop ix
  push  hl
  call  IOScanKeyboard       ; read keyboard
  ld   l,a
  ld   h,0
  jp (ix)

; *********************************************************************************
;
;   Scan the keyboard, return currently pressed key code in A
;
; *********************************************************************************

IOScanKeyboard:
  push  bc
  push  de
  push  hl

  ld   hl,__kr_no_shift_table     ; firstly identify shift state.

  ld   c,$FE         ; check CAPS SHIFT (emulator : left shift)
  ld   b,$FE
  in   a,(c)
  bit  0,a
  jr   nz,__kr1
  ld   hl,__kr_shift_table
  jr   __kr2
__kr1:
  ld   b,$7F         ; check SYMBOL SHIFT (emulator : right shift)
  in   a,(c)
  bit  1,a
  jr   nz,__kr2
  ld   hl,__kr_symbol_shift_table
__kr2:

  ld   e,$FE         ; scan pattern.
__kr3: ld   a,e         ; work out the mask, so we don't detect shift keys
  ld   d,$1E         ; $FE row, don't check the least significant bit.
  cp   $FE
  jr   z,___kr4
  ld   d,$01D         ; $7F row, don't check the 2nd least significant bit
  cp   $7F
  jr   z,___kr4
  ld   d,$01F         ; check all bits.
___kr4:
  ld   b,e         ; scan the keyboard
  ld   c,$FE
  in   a,(c)
  cpl           ; make that active high.
  and  d           ; and with check value.
  jr   nz,__kr_keypressed      ; exit loop if key pressed.

  inc  hl          ; next set of keyboard characters
  inc  hl
  inc  hl
  inc  hl
  inc  hl

  ld   a,e         ; get pattern
  add  a,a         ; shift left
  or   1          ; set bit 1.
  ld   e,a

  cp   $FF         ; finished when all 1's.
  jr   nz,__kr3
  xor  a
  jr   __kr_exit        ; no key found, return with zero.
;
__kr_keypressed:
  inc  hl          ; shift right until carry set
  rra
  jr   nc,__kr_keypressed
  dec  hl          ; undo the last inc hl
  ld   a,(hl)         ; get the character number.
__kr_exit:
  pop  hl
  pop  de
  pop  bc
  ret

; *********************************************************************************
;        Keyboard Mapping Tables
; *********************************************************************************
;
; $FEFE-$7FFE scan, bit 0-4, active low
;
; 3:Abort (Shift+Q) 8:Backspace 13:Return
; 27:Break 32-127: Std ASCII all L/C
;
__kr_no_shift_table:
  db   0,  'z','x','c','v',   'a','s','d','f','g'
  db   'q','w','e','r','t',   '1','2','3','4','5'
  db   '0','9','8','7','6',   'p','o','i','u','y'
  db   13, 'l','k','j','h',   ' ', 0, 'm','n','b'

__kr_shift_table:
__kr_symbol_shift_table:
  db    0, ':', 0,  '?','/',   '~','|','\','{','}'
  db    3,  0,  0  ,'<','>',   '!','@','#','$','%'
  db   '_',')','(',"'",'&',   '"',';', 0, ']','['
  db   27, '=','+','-','^',   ' ', 0, '.',',','*'

  db   0,  ':',0  ,'?','/',   '~','|','\','{','}'
  db   3,  0,  0  ,'<','>',   16,17,18,19,20
  db   8, ')',23,  22, 21,    '"',';', 0, ']','['
  db   27, '=','+','-','^',   ' ', 0, '.',',','*'
; *********************************************************************************
; *********************************************************************************
;
;  File:  screen48k.asm
;  Purpose: Hardware interface to Spectrum display, standard but with
;     sprites enabled.
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;      Call the SetMode for the Spectrum 48k
;
; *********************************************************************************

GFXInitialise48k:
  push  af          ; save registers
  push  bc

  ld   bc,$123B        ; Layer 2 access port
  ld   a,0         ; disable Layer 2
  out  (c),a
  db   $ED,$91,$15,$3      ; Disable LowRes but enable Sprites

  ld   hl,$4000        ; clear pixel memory
__cs1: ld   (hl),0
  inc  hl
  ld   a,h
  cp   $58
  jr   nz,__cs1
__cs2: ld   (hl),$47       ; clear attribute memory
  inc  hl
  ld   a,h
  cp   $5B
  jr   nz,__cs2
  xor  a          ; border off
  out  ($FE),a
  pop  bc
  pop  af
  ld   hl,$1820        ; H = 24,L = 32, screen extent
  ld   de,GFXPrintCharacter48k
  ret

; *********************************************************************************
;
;    Write a character E on the screen at HL, in colour D
;
; *********************************************************************************

GFXPrintCharacter48k:
  push  af          ; save registers
  push  bc
  push  de
  push  hl

  ld   b,e         ; character in B
  ld   a,h         ; check range.
  cp   3
  jr   nc,__ZXWCExit
;
;  work out attribute position
;
  push  hl          ; save position.
  ld   a,h
  add  $58
  ld   h,a

  ld   a,d         ; get current colour
  and  7           ; mask 0..2
  or   $40          ; make bright
  ld   (hl),a         ; store it.
  pop  hl
;
;  calculate screen position => HL
;
  push  de
  ex   de,hl
  ld   l,e         ; Y5 Y4 Y3 X4 X3 X2 X1 X0
  ld   a,d
  and  3
  add  a,a
  add  a,a
  add  a,a
  or   $40
  ld   h,a
  pop  de
;
;  char# 32-127 to font address => DE
;
  push  hl
  ld   a,b         ; get character
  and  $7F         ; bits 0-6 only.
  sub  32
  ld   l,a         ; put in HL
  ld   h,0
  add  hl,hl         ; x 8
  add  hl,hl
  add  hl,hl
  ld   de,(SIFontBase)      ; add the font base.
  add  hl,de
  ex   de,hl         ; put in DE (font address)
  pop  hl
;
;  copy font data to screen position.
;
  ld   a,b
  ld   b,8         ; copy 8 characters
  ld   c,0         ; XOR value 0
  bit  7,a         ; is the character reversed
  jr   z,__ZXWCCopy
  dec  c          ; C is the XOR mask now $FF
__ZXWCCopy:
  ld   a,(de)        ; get font data
  xor  c          ; xor with reverse
  ld   (hl),a         ; write back
  inc  h          ; bump pointers
  inc  de
  djnz  __ZXWCCopy        ; do B times.
__ZXWCExit:
  pop  hl          ; restore and exit
  pop  de
  pop  bc
  pop  af
  ret
; *********************************************************************************
; *********************************************************************************
;
;  File:  screen_layer2.asm
;  Purpose: Layer 2 console interface, sprites enabled, no shadow.
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;        Clear Layer 2 Display.
;
; *********************************************************************************


GFXInitialiseLayer2:
  push  af
  push  bc
  push  de
  db   $ED,$91,$15,$3      ; Disable LowRes but enable Sprites

  ld   e,2         ; 3 banks to erase
L2PClear:
  ld   a,e         ; put bank number in bits 6/7
  rrc  a
  rrc  a
  or   2+1         ; shadow on, visible, enable write paging
  ld   bc,$123B        ; out to layer 2 port
  out  (c),a
  ld   hl,$4000        ; erase the bank to $00
L2PClearBank:           ; assume default palette :)
  dec  hl
  ld   (hl),$00
  ld   a,h
  or   l
  jr  nz,L2PClearBank
  dec  e
  jp   p,L2PClear

  xor  a
  out  ($FE),a

  pop  de
  pop  bc
  pop  af
  ld   hl,$1820        ; still 32 x 24
  ld   de,GFXPrintCharacterLayer2
  ret
;
;  Print Character E, colour D, position HL
;
GFXPrintCharacterLayer2:
  push  af
  push  bc
  push  de
  push  hl
  push  ix

  ld   b,e         ; save A temporarily
  ld   a,b
  and  $7F
  cp   32
  jr   c,__L2Exit        ; check char in range
  ld   a,h
  cp   3
  jr   nc,__L2Exit       ; check position in range
  ld   a,b

  push  af
  xor  a          ; convert colour in C to palette index
  bit  0,d         ; (assumes standard palette)
  jr   z,__L2Not1
  or   $03
__L2Not1:
  bit  2,d
  jr   z,__L2Not2
  or   $1C
__L2Not2:
  bit  1,d
  jr   z,__L2Not3
  or   $C0
__L2Not3:
  ld   c,a         ; C is foreground
  ld   b,0         ; B is xor flipper, initially zero
  pop  af          ; restore char

  push  hl
  bit  7,a         ; adjust background bit on bit 7
  jr   z,__L2NotCursor
  ld   b,$FF         ; light grey is cursor
__L2NotCursor:
  and  $7F         ; offset from space
  sub  $20
  ld   l,a         ; put into HL
  ld   h,0
  add  hl,hl         ; x 8
  add  hl,hl
  add  hl,hl

  push  hl          ; transfer to IX
  pop  ix
  pop  hl

  push  bc          ; add the font base to it.
  ld   bc,(SIFontBase)
  add  ix,bc
  pop  bc
  ;
  ;  figure out the correct bank.
  ;
  push  bc
  ld   a,h         ; this is the page number.
  rrc  a
  rrc  a
  and  $C0         ; in bits 6 & 7
  or   $03         ; shadow on, visible, enable write pagin.
  ld   bc,$123B        ; out to layer 2 port
  out  (c),a
  pop  bc
  ;
  ;   now figure out position in bank
  ;
  ex   de,hl
  ld   l,e
  ld   h,0
  add  hl,hl
  add  hl,hl
  add  hl,hl
  sla  h
  sla  h
  sla  h

  ld   e,8         ; do 8 rows
__L2Outer:
  push  hl          ; save start
  ld   d,8         ; do 8 columns
  ld   a,(ix+0)        ; get the bit pattern
  xor  b          ; maybe flip it ?
  inc  ix
__L2Loop:
  ld   (hl),0         ; background
  add  a,a         ; shift pattern left
  jr   nc,__L2NotSet
  ld   (hl),c         ; if MSB was set, overwrite with fgr
__L2NotSet:
  inc  hl
  dec  d          ; do a row
  jr   nz, __L2Loop
  pop  hl          ; restore, go 256 bytes down.
  inc  h
  dec  e          ; do 8 rows
  jr   nz,__L2Outer
__L2Exit:
  pop  ix
  pop  hl
  pop  de
  pop  bc
  pop  af
  ret
; *********************************************************************************
; *********************************************************************************
;
;  File:  screen_lores.asm
;  Purpose: LowRes console interface, sprites enabled.
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;        Clear LowRes Display.
;
; *********************************************************************************

GFXInitialiseLowRes:
  push  af
  push  bc
  push  de

  db   $ED,$91,$15,$83      ; Enable LowRes and enable Sprites
  xor  a          ; layer 2 off.
  ld   bc,$123B        ; out to layer 2 port
  out  (c),a

  ld   hl,$4000        ; erase the bank to $00
  ld   de,$6000
LowClearScreen:          ; assume default palette :)
  xor  a
  ld   (hl),a
  ld   (de),a
  inc  hl
  inc  de
  ld   a,h
  cp   $58
  jr  nz,LowClearScreen
  xor  a
  out  ($FE),a
  pop  de
  pop  bc
  pop  af
  ld   hl,$0C10        ; resolution is 16x12 chars
  ld   de,GFXPrintCharacterLowRes
  ret
;
;  Print Character E Colour D @ HL
;
GFXPrintCharacterLowRes:
  push  af
  push  bc
  push  de
  push  hl
  push  ix

  ld   b,e         ; save character in B
  ld   a,e
  and  $7F
  cp   32
  jr   c,__LPExit

  add  hl,hl
  add  hl,hl
  ld   a,h         ; check in range 192*4 = 768
  cp   3
  jr   nc,__LPExit

  ld   a,d         ; only lower 3 bits of colour
  and  7
  ld   c,a         ; C is foreground

  push  hl
  ld   a,b         ; get char back
  ld   b,0         ; B = no flip colour.
  bit  7,a
  jr   z,__LowNotReverse      ; but 7 set, flip is $FF
  dec  b
__LowNotReverse:
  and  $7F         ; offset from space
  sub  $20
  ld   l,a         ; put into HL
  ld   h,0
  add  hl,hl         ; x 8
  add  hl,hl
  add  hl,hl

  push  hl          ; transfer to IX
  pop  ix

  push  bc          ; add the font base to it.
  ld   bc,(SIFontBase)
  add  ix,bc
  pop  bc
  pop  hl
  ex   de,hl
  ld   a,e         ; put DE => HL
  and  192         ; these are part of Y
  ld   l,a          ; Y multiplied by 4 then 32 = 128
  ld   h,d
  add  hl,hl
  add  hl,hl
  add  hl,hl
  add  hl,hl
  set  6,h         ; put into $4000 range

  ld   a,15*4         ; mask for X, which has been premultiplied.
  and  e          ; and with E, gives X position
  add  a,a         ; now multiplied by 8.
  ld   e,a         ; DE is x offset.
  ld   d,0

  add  hl,de
  ld   a,h
  cp   $58         ; need to be shifted to 2nd chunk ?
  jr   c,__LowNotLower2
  ld   de,$0800
  add  hl,de
__LowNotLower2:
  ld   e,8         ; do 8 rows
__LowOuter:
  push  hl          ; save start
  ld   d,8         ; do 8 columns
  ld   a,(ix+0)        ; get the bit pattern
  xor  b
  inc  ix
__LowLoop:
  ld   (hl),0         ; background
  add  a,a         ; shift pattern left
  jr   nc,__LowNotSet
  ld   (hl),c         ; if MSB was set, overwrite with fgr
__LowNotSet:
  inc  l
  dec  d          ; do a row
  jr   nz, __LowLoop
  pop  hl          ; restore, go 256 bytes down.
  push  de
  ld   de,128
  add  hl,de
  pop  de
  dec  e          ; do 8 rows
  jr   nz,__LowOuter
__LPExit:
  pop  ix
  pop  hl
  pop  de
  pop  bc
  pop  af
  ret

; *********************************************************************************
; *********************************************************************************
;
;  File:  binary.asm
;  Purpose: Binary words
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************


; =============== @word.ix  * ==============

define_2a:
  pop ix
 pop  de
 call  MULTMultiply16
  jp (ix)


; =============== @word.ix  / ==============

define_2f:
  pop ix
 pop  de
 call  DIVDivideMod16
 ex   de,hl
  jp (ix)


; =============== @word.ix  mod ==============

define_6d_6f_64:
  pop ix
 pop  de
 call  DIVDivideMod16
  jp (ix)


; =============== @word.ix  /mod ==============

define_2f_6d_6f_64:
  pop ix
 pop  de
 call  DIVDivideMod16
 push  hl
 ex   de,hl
  jp (ix)


; =============== @copier  + ==============

define_2b:
  nop
  call copyIntoCodeSpace
  db end_2b-start_2b
start_2b:
 pop  de
 add  hl,de
end_2b:


; =============== @word.ix and ==============

define_61_6e_64:
  pop ix
 pop  de
 ld   a,h
 and  d
 ld   h,a
 ld   a,l
 and  e
 ld   l,a
  jp (ix)


; =============== @word.ix or ==============

define_6f_72:
  pop ix
 pop  de
 ld   a,h
 xor  d
 ld   h,a
 ld   a,l
 xor  e
 ld   l,a
  jp (ix)


; =============== @word.ix +or ==============

define_2b_6f_72:
  pop ix
 pop  de
 ld   a,h
 or   d
 ld   h,a
 ld   a,l
 or   e
 ld   l,a
  jp (ix)


; =============== @word.ix  = ==============

define_3d:
  pop ix
 ld   a,h
 xor  d
 ld   h,a
 ld   a,l
 xor  e
 or   h
 ld   hl,$0000
 jr   nz,__Not_Equal
 dec  hl
__Not_Equal:
  jp (ix)


; =============== @word.ix  < ==============

define_3c:
  pop ix
 pop  de
 ld   a,h          ; check signs are different.
 xor  d
 jp   p,__SameSign

 ld   a,d          ; if 2nd stack value bit 7 set must be <, signs different
 add  a,a          ; put bit into carry
 jr   __Less_TrueIfCarry

__SameSign:
 ex   de,hl         ; check HL < DE
 xor  a
 sbc  hl,de          ; CS if HL < DE
__Less_TrueIfCarry:
 ld   a,0
 sbc  a,a          ; A = $FF if HL < DE $00 otherwise
 ld   l,a          ; copy to HL
 ld   h,a
  jp (ix)

; *********************************************************************************
; *********************************************************************************
;
;  File:  divide.asm
;  Purpose: 16 bit unsigned divide
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;   Calculates DE / HL. On exit DE = result, HL = remainder
;
; *********************************************************************************

DIVDivideMod16:

 push  bc
 ld   b,d     ; DE
 ld   c,e
 ex   de,hl
 ld   hl,0
 ld   a,b
 ld   b,8
Div16_Loop1:
 rla
 adc  hl,hl
 sbc  hl,de
 jr   nc,Div16_NoAdd1
 add  hl,de
Div16_NoAdd1:
 djnz  Div16_Loop1
 rla
 cpl
 ld   b,a
 ld   a,c
 ld   c,b
 ld   b,8
Div16_Loop2:
 rla
 adc  hl,hl
 sbc  hl,de
 jr   nc,Div16_NoAdd2
 add  hl,de
Div16_NoAdd2:
 djnz  Div16_Loop2
 rla
 cpl
 ld   d,c
 ld   e,a
 pop  bc
 ret


; *********************************************************************************
; *********************************************************************************
;
;  File:  memory.asm
;  Purpose: Memory access words
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;         Standard words
; *********************************************************************************


; =============== @copier  ! ==============

define_21:
  nop
  call copyIntoCodeSpace
  db end_21-start_21
start_21:
 pop  de
 ld   (hl),e
 inc  hl
 ld   (hl),d
 pop  hl
end_21:


; =============== @copier  b! ==============

define_62_21:
  nop
  call copyIntoCodeSpace
  db end_62_21-start_62_21
start_62_21:
 pop  de
 ld   (hl),e
 pop  hl
end_62_21:


; =============== @copier  @ ==============

define_40:
  nop
  call copyIntoCodeSpace
  db end_40-start_40
start_40:
 ld   a,(hl)
 inc  hl
 ld   h,(hl)
 ld   l,a
end_40:


; =============== @copier  b@ ==============

define_62_40:
  nop
  call copyIntoCodeSpace
  db end_62_40-start_62_40
start_62_40:
 ld   l,(hl)
 ld   h,0
end_62_40:

; *********************************************************************************
;         Add to memory
; *********************************************************************************


; =============== @word.ix  +! ==============

define_2b_21:
  pop ix
 pop  de
 ld   a,(hl)
 add  a,e
 ld   (hl),a
 inc  hl
 ld   a,(hl)
 adc  a,d
 ld   (hl),a
 pop  hl
  jp (ix)

; *********************************************************************************
;         Or to memory
; *********************************************************************************


; =============== @word.ix  or! ==============

define_6f_72_21:
  pop ix
 pop  de
 ld   a,(hl)
 or   e
 ld   (hl),a
 inc  hl
 ld   a,(hl)
 or   d
 ld   (hl),a
 pop  hl
  jp (ix)

; *********************************************************************************
; *********************************************************************************
;
;  File:  multiply.asm
;  Purpose: 16 bit unsigned multiply
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;        Does HL = HL * DE
;
; *********************************************************************************

MULTMultiply16:
  push  bc
  push  de
  ld   b,h        ; get multipliers in DE/BC
  ld   c,l
  ld   hl,0        ; zero total
__Core__Mult_Loop:
  bit  0,c        ; lsb of shifter is non-zero
  jr   z,__Core__Mult_Shift
  add  hl,de        ; add adder to total
__Core__Mult_Shift:
  srl  b         ; shift BC right.
  rr   c
  ex   de,hl        ; shift DE left
  add  hl,hl
  ex   de,hl
  ld   a,b        ; loop back if BC is nonzero
  or   c
  jr   nz,__Core__Mult_Loop
  pop  de
  pop  bc
  ret
; *********************************************************************************
; *********************************************************************************
;
;  File:  stack.asm
;  Purpose: Spectrum Keyboard Interface
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;      standard stack routines, all macros
; *********************************************************************************


; =============== @copier  drop ==============

define_64_72_6f_70:
  nop
  call copyIntoCodeSpace
  db end_64_72_6f_70-start_64_72_6f_70
start_64_72_6f_70:
 pop  hl
end_64_72_6f_70:


; =============== @copier  dup ==============

define_64_75_70:
  nop
  call copyIntoCodeSpace
  db end_64_75_70-start_64_75_70
start_64_75_70:
 push  hl
end_64_75_70:


; =============== @copier  nip ==============

define_6e_69_70:
  nop
  call copyIntoCodeSpace
  db end_6e_69_70-start_6e_69_70
start_6e_69_70:
 pop  de
end_6e_69_70:


; =============== @copier  swap ==============

define_73_77_61_70:
  nop
  call copyIntoCodeSpace
  db end_73_77_61_70-start_73_77_61_70
start_73_77_61_70:
 pop  de
 ex   de,hl
 push  de
end_73_77_61_70:


; =============== @copier  over ==============

define_6f_76_65_72:
  nop
  call copyIntoCodeSpace
  db end_6f_76_65_72-start_6f_76_65_72
start_6f_76_65_72:
 pop  de
 push  de
 push  hl
 ex   de,hl
end_6f_76_65_72:

; *********************************************************************************
; we cannot do r> and >r because of the reentrancy, so push and pop have a
; small stack so it can be used as a temp, which is mostly what it's used for
; anyway.
; *********************************************************************************


; =============== @word.ix  push ==============

define_70_75_73_68:
  pop ix
 ex   de,hl
 ld   hl,(TempStackOffset)
 ld   bc,TempStack
 add  hl,bc
 ld   (hl),e
 inc  hl
 ld   (hl),d

 ld   hl,TempStackOffset
 inc  (hl)
 inc  (hl)

 ld   a,(hl)
 and  $1F
 ld   (hl),a

 pop  hl
  jp (ix)


; =============== @word.ix  pop ==============

define_70_6f_70:
  pop ix
 push  hl

 ld   hl,TempStackOffset
 dec  (hl)
 dec  (hl)
 ld   a,(hl)
 and  $1F
 ld   (hl),a

 ld   hl,(TempStackOffset)
 ld   de,TempStack
 add  hl,de

 ld   e,(hl)
 inc  hl
 ld   d,(hl)
 ex   de,hl
  jp (ix)

; *********************************************************************************
; *********************************************************************************
;
;  File:  system.asm
;  Purpose: System words
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************


; =============== @word.ret  debug ==============

define_64_65_62_75_67:
  ret

; *********************************************************************************
;        block fill/copy words
; *********************************************************************************


; =============== @word.ix  fill ==============

define_66_69_6c_6c:
  pop ix
  jp (ix)


; =============== @word.ix  move ==============

define_6d_6f_76_65:
  pop ix
  jp (ix)

; *********************************************************************************
;         Compilation words
; *********************************************************************************


; =============== @word.ix  1, ==============

define_31_2c:
  pop ix
  jp (ix)


; =============== @word.ix 2, ==============

define_32_2c:
  pop ix
  jp (ix)


; =============== @word.ix  h ==============

define_68:
  pop ix
  jp (ix)


; =============== @word.ix  here ==============

define_68_65_72_65:
  pop ix
  jp (ix)

; *********************************************************************************
;           port I/O
; *********************************************************************************


; =============== @copier  p@ ==============

define_70_40:
  nop
  call copyIntoCodeSpace
  db end_70_40-start_70_40
start_70_40:
 ld   c,l
 ld   b,h
 in   l,(c)
 ld   h,0
end_70_40:


; =============== @copier  p! ==============

define_70_21:
  nop
  call copyIntoCodeSpace
  db end_70_21-start_70_21
start_70_21:
 pop  de
 ld   b,h
 ld   c,l
 out  (c),e
 pop  hl
end_70_21:

; *********************************************************************************
; *********************************************************************************
;
;  File:  unary.asm
;  Purpose: Unary words
;  Date :   28th December 2018
;  Author:  paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************


; =============== @copier - ==============

define_2d:
  nop
  call copyIntoCodeSpace
  db end_2d-start_2d
start_2d:
 ld a,h
 cpl
 ld  h,a
 ld  a,l
 cpl
 ld  l,a
end_2d:


; =============== @copier 2* ==============

define_32_2a:
  nop
  call copyIntoCodeSpace
  db end_32_2a-start_32_2a
start_32_2a:
 add hl,hl
end_32_2a:


; =============== @copier 2/ ==============

define_32_2f:
  nop
  call copyIntoCodeSpace
  db end_32_2f-start_32_2f
start_32_2f:
 sra h
 rr  l
end_32_2f:


; =============== @word.ret abs ==============

define_61_62_73:
 bit 7,h
 ret z
 ld a,h
 cpl
 ld  h,a
 ld  a,l
 cpl
 ld  l,a
 inc hl
  ret


; =============== @copier 4* ==============

define_34_2a:
  nop
  call copyIntoCodeSpace
  db end_34_2a-start_34_2a
start_34_2a:
 add hl,hl
 add hl,hl
end_34_2a:


; =============== @copier 8* ==============

define_38_2a:
  nop
  call copyIntoCodeSpace
  db end_38_2a-start_38_2a
start_38_2a:
 add hl,hl
 add hl,hl
 add hl,hl
end_38_2a:


; =============== @copier 16* ==============

define_31_36_2a:
  nop
  call copyIntoCodeSpace
  db end_31_36_2a-start_31_36_2a
start_31_36_2a:
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
end_31_36_2a:



; =============== @copier bswap ==============

define_62_73_77_61_70:
  nop
  call copyIntoCodeSpace
  db end_62_73_77_61_70-start_62_73_77_61_70
start_62_73_77_61_70:
 ld  a,l
 ld  l,h
 ld  h,a
end_62_73_77_61_70:


; =============== @word.ret 0< ==============

define_30_3c:
 bit 7,h
 ld  hl,$0000
 ret z
 dec hl
  ret


; =============== @word.ret 0= ==============

define_30_3d:
 ld  a,h
 or  l
 ld  hl,$0000
 ret nz
 dec hl
  ret


; =============== @word.ret negate ==============

define_6e_65_67_61_74_65:
 ld a,h
 cpl
 ld  h,a
 ld  a,l
 cpl
 ld  l,a
 inc hl
  ret


