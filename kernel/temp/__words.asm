
_define_forth_2b:
	pop ix
	pop hl
	add hl,de
	ex de,hl
	jp (ix)

_define_macro_2b:
	ld b,_end_0-_start_0
	call MacroExpansion
_start_0:
	pop hl
	add hl,de
	ex de,hl
_end_0:

_define_forth_3c:
	pop ix
	pop hl
	ld a,h
	xor d
	add a,a
	jr nc,__less_samesign
	ld a,d
	add a,a
	jr __less_returnc
__less_samesign:
	ex de,hl
	sbc hl,de
__less_returnc:
	ld a,0
	sbc a,0
	ld e,a
	ld d,a
	jp (ix)

_define_forth_3d:
	pop ix
	pop hl
	ld a,h
	xor d
	ld h,a
	ld a,l
	xor e
	or h
	ld de,$0000
	jr nz,__equal_different
	dec de
__equal_different:
	jp (ix)

_define_forth_61_6e_64:
	pop ix
	pop hl
	ld a,e
	and l
	ld e,a
	ld a,d
	and h
	ld d,a
	jp (ix)

_define_forth_6f_72:
	pop ix
	pop hl
	ld a,e
	xor l
	ld e,a
	ld a,d
	xor h
	ld d,a
	jp (ix)

_define_forth_78_6f_72:
	pop ix
	pop hl
	ld a,e
	xor l
	ld e,a
	ld a,d
	xor h
	ld d,a
	jp (ix)

_define_forth_2b_6f_72:
	pop ix
	pop hl
	ld a,e
	or l
	ld e,a
	ld a,d
	or h
	ld d,a
	jp (ix)

_define_forth_6c_6f_72:
	pop ix
	pop hl
	ld a,e
	or l
	ld e,a
	ld a,d
	or h
	ld d,a
	jp (ix)

_define_forth_21:
	pop ix
	pop hl
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	pop de
	jp (ix)

_define_macro_21:
	ld b,_end_1-_start_1
	call MacroExpansion
_start_1:
	pop hl
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	pop de
_end_1:

_define_forth_2b_21:
	pop ix
	pop hl
	ld a,(de)
	add a,l
	ld (de),a
	inc de
	ld a,(de)
	adc a,h
	ld (de),a
	pop de
	jp (ix)

_define_forth_40:
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ret

_define_macro_40:
	ld b,_end_2-_start_2
	call MacroExpansion
_start_2:
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
_end_2:

_define_forth_62_40:
	ld a,(de)
	ld e,a
	ld d,0
	ret

_define_macro_62_40:
	ld b,_end_3-_start_3
	call MacroExpansion
_start_3:
	ld a,(de)
	ld e,a
	ld d,0
_end_3:

_define_forth_63_40:
	ld a,(de)
	ld e,a
	ld d,0
	ret

_define_macro_63_40:
	ld b,_end_4-_start_4
	call MacroExpansion
_start_4:
	ld a,(de)
	ld e,a
	ld d,0
_end_4:

_define_forth_62_21:
	pop ix
	pop hl
	ld a,l
	ld (de),a
	pop de
	jp (ix)

_define_macro_62_21:
	ld b,_end_5-_start_5
	call MacroExpansion
_start_5:
	pop hl
	ld a,l
	ld (de),a
	pop de
_end_5:

_define_forth_63_21:
	pop ix
	pop hl
	ld a,l
	ld (de),a
	pop de
	jp (ix)

_define_macro_63_21:
	ld b,_end_6-_start_6
	call MacroExpansion
_start_6:
	pop hl
	ld a,l
	ld (de),a
	pop de
_end_6:

_define_forth_6f_72_21:
	pop ix
	pop hl
	ld a,(de)
	or l
	ld (de),a
	inc de
	ld a,(de)
	or h
	ld (de),a
	pop de
	jp (ix)

_define_forth_70_40:
	ld c,e
	ld b,d
	in e,(c)
	ld d,0
	ret

_define_macro_70_40:
	ld b,_end_7-_start_7
	call MacroExpansion
_start_7:
	ld c,e
	ld b,d
	in e,(c)
	ld d,0
_end_7:

_define_forth_70_21:
	pop hl
	pop hl
	ld c,e
	ld b,d
	out (c),l
	pop de
	jp (hl)

_define_macro_70_21:
	ld b,_end_8-_start_8
	call MacroExpansion
_start_8:
	pop hl
	ld c,e
	ld b,d
	out (c),l
	pop de
_end_8:

_define_forth_64_72_6f_70:
	pop ix
	pop de
	jp (ix)

_define_macro_64_72_6f_70:
	ld b,_end_9-_start_9
	call MacroExpansion
_start_9:
	pop de
_end_9:

_define_forth_64_75_70:
	pop ix
	push de
	jp (ix)

_define_macro_64_75_70:
	ld b,_end_10-_start_10
	call MacroExpansion
_start_10:
	push de
_end_10:

_define_forth_6e_69_70:
	pop ix
	pop bc
	jp (ix)

_define_macro_6e_69_70:
	ld b,_end_11-_start_11
	call MacroExpansion
_start_11:
	pop bc
_end_11:

_define_forth_6f_76_65_72:
	pop ix
	pop hl
	push hl
	push de
	ex de,hl
	jp (ix)

_define_macro_6f_76_65_72:
	ld b,_end_12-_start_12
	call MacroExpansion
_start_12:
	pop hl
	push hl
	push de
	ex de,hl
_end_12:

_define_forth_73_77_61_70:
	pop ix
	pop hl
	ex de,hl
	push hl
	jp (ix)

_define_macro_73_77_61_70:
	ld b,_end_13-_start_13
	call MacroExpansion
_start_13:
	pop hl
	ex de,hl
	push hl
_end_13:

_define_forth_2d:
	ld a,e
	cpl
	ld e,a
	ld a,d
	cpl
	ld d,a
	ret

_define_forth_6e_6f_74:
	ld a,e
	cpl
	ld e,a
	ld a,d
	cpl
	ld d,a
	ret

_define_forth_32_2a:
	add hl,hl
	ret

_define_macro_32_2a:
	ld b,_end_14-_start_14
	call MacroExpansion
_start_14:
	add hl,hl
_end_14:

_define_forth_34_2a:
	add hl,hl
	add hl,hl
	ret

_define_macro_34_2a:
	ld b,_end_15-_start_15
	call MacroExpansion
_start_15:
	add hl,hl
	add hl,hl
_end_15:

_define_forth_38_2a:
	add hl,hl
	add hl,hl
	add hl,hl
	ret

_define_macro_38_2a:
	ld b,_end_16-_start_16
	call MacroExpansion
_start_16:
	add hl,hl
	add hl,hl
	add hl,hl
_end_16:

_define_forth_31_36_2a:
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ret

_define_macro_31_36_2a:
	ld b,_end_17-_start_17
	call MacroExpansion
_start_17:
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
_end_17:

_define_forth_32_2f:
	sra d
	rr e
	ret

_define_macro_32_2f:
	ld b,_end_18-_start_18
	call MacroExpansion
_start_18:
	sra d
	rr e
_end_18:

_define_forth_34_2f:
	sra d
	rr e
	sra d
	rr e
	ret

_define_macro_34_2f:
	ld b,_end_19-_start_19
	call MacroExpansion
_start_19:
	sra d
	rr e
	sra d
	rr e
_end_19:

_define_forth_61_62_73:
	bit 7,d
	jr z,__abs_isPositive
	ld a,e
	cpl
	ld e,a
	ld a,d
	cpl
	ld d,a
	inc de
__abs_isPositive:
	ret

_define_forth_62_73_77_61_70:
	ld a,h
	ld h,l
	ld l,a
	ret

_define_macro_62_73_77_61_70:
	ld b,_end_20-_start_20
	call MacroExpansion
_start_20:
	ld a,h
	ld h,l
	ld l,a
_end_20:

_define_forth_30_3d:
	ld a,d
	or e
	ld de,$0000
	jr nz,__zEquals_notZero
	dec de
__zEquals_notZero:
	ret

_define_forth_6e_65_67_61_74_65:
	ld a,e
	cpl
	ld e,a
	ld a,d
	cpl
	ld d,a
	inc de
	ret
