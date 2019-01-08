
@forth +
	pop ix
	pop  hl
	add  hl,de
	ex   de,hl
	jp (ix)

@macro +
	ld b,_end_0-_start_0
	call MacroExpansion
_start_0
	pop  hl
	add  hl,de
	ex   de,hl
_end_0

@forth <
	pop ix
	pop  hl
	ld   a,h
	xor  d
	add  a,a
	jr   nc,__less_samesign
	ld   a,d
	add  a,a
	jr   __less_returnc
__less_samesign:
	ex   de,hl
	sbc  hl,de
__less_returnc:
	ld   a,0
	sbc  a,0
	ld   e,a
	ld   d,a
	jp (ix)

@forth =
	pop ix
	pop  hl
	ld   a,h
	xor  d
	ld   h,a
	ld   a,l
	xor  e
	or   h
	ld   de,$0000
	jr   nz,__equal_different
	dec  de
__equal_different:
	jp (ix)

@forth and
	pop ix
	pop  hl
	ld   a,e
	and  l
	ld   e,a
	ld   a,d
	and  h
	ld   d,a
	jp (ix)

@forth or
	pop ix
	pop  hl
	ld   a,e
	xor  l
	ld   e,a
	ld   a,d
	xor  h
	ld   d,a
	jp (ix)

@forth xor
	pop ix
	pop  hl
	ld   a,e
	xor  l
	ld   e,a
	ld   a,d
	xor  h
	ld   d,a
	jp (ix)

@forth +or
	pop ix
	pop  hl
	ld   a,e
	or   l
	ld   e,a
	ld   a,d
	or   h
	ld   d,a
	jp (ix)

@forth lor
	pop ix
	pop  hl
	ld   a,e
	or   l
	ld   e,a
	ld   a,d
	or   h
	ld   d,a
	jp (ix)

@forth !
	pop ix
	pop  hl
	ex   de,hl
	ld   (hl),e
	inc  hl
	ld   (hl),d
	pop  de
	jp (ix)

@macro !
	ld b,_end_1-_start_1
	call MacroExpansion
_start_1
	pop  hl
	ex   de,hl
	ld   (hl),e
	inc  hl
	ld   (hl),d
	pop  de
_end_1

@forth +!
	pop ix
	pop  hl
	ld   a,(de)
	add  a,l
	ld   (de),a
	inc  de
	ld   a,(de)
	adc  a,h
	ld   (de),a
	pop  de
	jp (ix)

@forth @
	ex   de,hl
	ld   e,(hl)
	inc  hl
	ld   d,(hl)
	ret

@macro @
	ld b,_end_2-_start_2
	call MacroExpansion
_start_2
	ex   de,hl
	ld   e,(hl)
	inc  hl
	ld   d,(hl)
_end_2

@forth b@
	ld   a,(de)
	ld   e,a
	ld   d,0
	ret

@macro b@
	ld b,_end_3-_start_3
	call MacroExpansion
_start_3
	ld   a,(de)
	ld   e,a
	ld   d,0
_end_3

@forth c@
	ld   a,(de)
	ld   e,a
	ld   d,0
	ret

@macro c@
	ld b,_end_4-_start_4
	call MacroExpansion
_start_4
	ld   a,(de)
	ld   e,a
	ld   d,0
_end_4

@forth b!
	pop ix
	pop  hl
	ld   a,l
	ld   (de),a
	pop  de
	jp (ix)

@macro b!
	ld b,_end_5-_start_5
	call MacroExpansion
_start_5
	pop  hl
	ld   a,l
	ld   (de),a
	pop  de
_end_5

@forth c!
	pop ix
	pop  hl
	ld   a,l
	ld   (de),a
	pop  de
	jp (ix)

@macro c!
	ld b,_end_6-_start_6
	call MacroExpansion
_start_6
	pop  hl
	ld   a,l
	ld   (de),a
	pop  de
_end_6

@forth or!
	pop ix
	pop  hl
	ld   a,(de)
	or   l
	ld   (de),a
	inc  de
	ld   a,(de)
	or   h
	ld   (de),a
	pop  de
	jp (ix)

@forth p@
	ld   c,e
	ld   b,d
	in   e,(c)
	ld   d,0
	ret

@macro p@
	ld b,_end_7-_start_7
	call MacroExpansion
_start_7
	ld   c,e
	ld   b,d
	in   e,(c)
	ld   d,0
_end_7

@forth p!
	pop hl
	pop  hl
	ld   c,e
	ld   b,d
	out  (c),l
	pop  de
	jp (hl)

@macro p!
	ld b,_end_8-_start_8
	call MacroExpansion
_start_8
	pop  hl
	ld   c,e
	ld   b,d
	out  (c),l
	pop  de
_end_8

@forth drop
	pop ix
	pop  de
	jp (ix)

@macro drop
	ld b,_end_9-_start_9
	call MacroExpansion
_start_9
	pop  de
_end_9

@forth dup
	pop ix
	push  de
	jp (ix)

@macro dup
	ld b,_end_10-_start_10
	call MacroExpansion
_start_10
	push  de
_end_10

@forth nip
	pop ix
	pop  bc
	jp (ix)

@macro nip
	ld b,_end_11-_start_11
	call MacroExpansion
_start_11
	pop  bc
_end_11

@forth over
	pop ix
	pop  hl
	push  hl
	push  de
	ex   de,hl
	jp (ix)

@macro over
	ld b,_end_12-_start_12
	call MacroExpansion
_start_12
	pop  hl
	push  hl
	push  de
	ex   de,hl
_end_12

@forth swap
	pop ix
	pop  hl
	ex   de,hl
	push  hl
	jp (ix)

@macro swap
	ld b,_end_13-_start_13
	call MacroExpansion
_start_13
	pop  hl
	ex   de,hl
	push  hl
_end_13

@forth -
	ld   a,e
	cpl
	ld   e,a
	ld   a,d
	cpl
	ld   d,a
	ret

@forth not
	ld   a,e
	cpl
	ld   e,a
	ld   a,d
	cpl
	ld   d,a
	ret

@forth 2*
	add  hl,hl
	ret

@macro 2*
	ld b,_end_14-_start_14
	call MacroExpansion
_start_14
	add  hl,hl
_end_14

@forth 4*
	add  hl,hl
	add  hl,hl
	ret

@macro 4*
	ld b,_end_15-_start_15
	call MacroExpansion
_start_15
	add  hl,hl
	add  hl,hl
_end_15

@forth 8*
	add  hl,hl
	add  hl,hl
	add  hl,hl
	ret

@macro 8*
	ld b,_end_16-_start_16
	call MacroExpansion
_start_16
	add  hl,hl
	add  hl,hl
	add  hl,hl
_end_16

@forth 16*
	add  hl,hl
	add  hl,hl
	add  hl,hl
	add  hl,hl
	ret

@macro 16*
	ld b,_end_17-_start_17
	call MacroExpansion
_start_17
	add  hl,hl
	add  hl,hl
	add  hl,hl
	add  hl,hl
_end_17

@forth 2/
	sra  d
	rr   e
	ret

@macro 2/
	ld b,_end_18-_start_18
	call MacroExpansion
_start_18
	sra  d
	rr   e
_end_18

@forth 4/
	sra  d
	rr   e
	sra  d
	rr   e
	ret

@macro 4/
	ld b,_end_19-_start_19
	call MacroExpansion
_start_19
	sra  d
	rr   e
	sra  d
	rr   e
_end_19

@forth abs
	bit  7,d
	jr   z,__abs_isPositive
	ld   a,e
	cpl
	ld   e,a
	ld   a,d
	cpl
	ld   d,a
	inc  de
__abs_isPositive:
	ret

@forth bswap
	ld   a,h
	ld   h,l
	ld   l,a
	ret

@macro bswap
	ld b,_end_20-_start_20
	call MacroExpansion
_start_20
	ld   a,h
	ld   h,l
	ld   l,a
_end_20

@forth 0=
	ld   a,d
	or   e
	ld   de,$0000
	jr   nz,__zEquals_notZero
	dec  de
__zEquals_notZero:
	ret

@forth negate
	ld   a,e
	cpl
	ld   e,a
	ld   a,d
	cpl
	ld   d,a
	inc  de
	ret
