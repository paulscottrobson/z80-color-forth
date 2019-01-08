	db	6
	db	$20
	dw	_define_forth_2b
	db	1
	db	"+"

	db	6
	db	$20
	dw	_define_macro_2b
	db	129
	db	"+"

	db	6
	db	$20
	dw	_define_forth_2a
	db	1
	db	"*"

	db	6
	db	$20
	dw	_define_forth_2f
	db	1
	db	"/"

	db	8
	db	$20
	dw	_define_forth_6d_6f_64
	db	3
	db	"mod"

	db	9
	db	$20
	dw	_define_forth_2f_6d_6f_64
	db	4
	db	"/mod"

	db	6
	db	$20
	dw	_define_forth_3c
	db	1
	db	"<"

	db	6
	db	$20
	dw	_define_forth_3d
	db	1
	db	"="

	db	8
	db	$20
	dw	_define_forth_61_6e_64
	db	3
	db	"and"

	db	7
	db	$20
	dw	_define_forth_6f_72
	db	2
	db	"or"

	db	8
	db	$20
	dw	_define_forth_78_6f_72
	db	3
	db	"xor"

	db	8
	db	$20
	dw	_define_forth_2b_6f_72
	db	3
	db	"+or"

	db	8
	db	$20
	dw	_define_forth_6c_6f_72
	db	3
	db	"lor"

	db	6
	db	$20
	dw	_define_forth_21
	db	1
	db	"!"

	db	6
	db	$20
	dw	_define_macro_21
	db	129
	db	"!"

	db	7
	db	$20
	dw	_define_forth_2b_21
	db	2
	db	"+!"

	db	6
	db	$20
	dw	_define_forth_40
	db	1
	db	"@"

	db	6
	db	$20
	dw	_define_macro_40
	db	129
	db	"@"

	db	7
	db	$20
	dw	_define_forth_62_40
	db	2
	db	"b@"

	db	7
	db	$20
	dw	_define_macro_62_40
	db	130
	db	"b@"

	db	7
	db	$20
	dw	_define_forth_63_40
	db	2
	db	"c@"

	db	7
	db	$20
	dw	_define_macro_63_40
	db	130
	db	"c@"

	db	7
	db	$20
	dw	_define_forth_62_21
	db	2
	db	"b!"

	db	7
	db	$20
	dw	_define_macro_62_21
	db	130
	db	"b!"

	db	7
	db	$20
	dw	_define_forth_63_21
	db	2
	db	"c!"

	db	7
	db	$20
	dw	_define_macro_63_21
	db	130
	db	"c!"

	db	8
	db	$20
	dw	_define_forth_6f_72_21
	db	3
	db	"or!"

	db	7
	db	$20
	dw	_define_forth_70_40
	db	2
	db	"p@"

	db	7
	db	$20
	dw	_define_macro_70_40
	db	130
	db	"p@"

	db	7
	db	$20
	dw	_define_forth_70_21
	db	2
	db	"p!"

	db	7
	db	$20
	dw	_define_macro_70_21
	db	130
	db	"p!"

	db	21
	db	$20
	dw	_define_forth_73_79_73_2e_65_78_70_61_6e_64_2e_6d_61_63_72_6f
	db	16
	db	"sys.expand.macro"

	db	7
	db	$20
	dw	_define_forth_31_2c
	db	2
	db	"1,"

	db	7
	db	$20
	dw	_define_forth_32_2c
	db	2
	db	"2,"

	db	9
	db	$20
	dw	_define_forth_64_72_6f_70
	db	4
	db	"drop"

	db	9
	db	$20
	dw	_define_macro_64_72_6f_70
	db	132
	db	"drop"

	db	8
	db	$20
	dw	_define_forth_64_75_70
	db	3
	db	"dup"

	db	8
	db	$20
	dw	_define_macro_64_75_70
	db	131
	db	"dup"

	db	8
	db	$20
	dw	_define_forth_6e_69_70
	db	3
	db	"nip"

	db	8
	db	$20
	dw	_define_macro_6e_69_70
	db	131
	db	"nip"

	db	9
	db	$20
	dw	_define_forth_6f_76_65_72
	db	4
	db	"over"

	db	9
	db	$20
	dw	_define_macro_6f_76_65_72
	db	132
	db	"over"

	db	9
	db	$20
	dw	_define_forth_73_77_61_70
	db	4
	db	"swap"

	db	9
	db	$20
	dw	_define_macro_73_77_61_70
	db	132
	db	"swap"

	db	6
	db	$20
	dw	_define_forth_2d
	db	1
	db	"-"

	db	8
	db	$20
	dw	_define_forth_6e_6f_74
	db	3
	db	"not"

	db	7
	db	$20
	dw	_define_forth_32_2a
	db	2
	db	"2*"

	db	7
	db	$20
	dw	_define_macro_32_2a
	db	130
	db	"2*"

	db	7
	db	$20
	dw	_define_forth_34_2a
	db	2
	db	"4*"

	db	7
	db	$20
	dw	_define_macro_34_2a
	db	130
	db	"4*"

	db	7
	db	$20
	dw	_define_forth_38_2a
	db	2
	db	"8*"

	db	7
	db	$20
	dw	_define_macro_38_2a
	db	130
	db	"8*"

	db	8
	db	$20
	dw	_define_forth_31_36_2a
	db	3
	db	"16*"

	db	8
	db	$20
	dw	_define_macro_31_36_2a
	db	131
	db	"16*"

	db	7
	db	$20
	dw	_define_forth_32_2f
	db	2
	db	"2/"

	db	7
	db	$20
	dw	_define_macro_32_2f
	db	130
	db	"2/"

	db	7
	db	$20
	dw	_define_forth_34_2f
	db	2
	db	"4/"

	db	7
	db	$20
	dw	_define_macro_34_2f
	db	130
	db	"4/"

	db	8
	db	$20
	dw	_define_forth_61_62_73
	db	3
	db	"abs"

	db	10
	db	$20
	dw	_define_forth_62_73_77_61_70
	db	5
	db	"bswap"

	db	10
	db	$20
	dw	_define_macro_62_73_77_61_70
	db	133
	db	"bswap"

	db	7
	db	$20
	dw	_define_forth_30_3d
	db	2
	db	"0="

	db	11
	db	$20
	dw	_define_forth_6e_65_67_61_74_65
	db	6
	db	"negate"

	db	0

