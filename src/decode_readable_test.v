module ini

struct Empty {}

fn test_decode_empty() {
	i := ReadableIni{}
	mut e := decode[Empty, ReadableIni](i)!
	decode_to[Empty, ReadableIni](i, mut e)!
}

enum Human {
	man
	woman
}

struct PrimitiveTypes {
	h1     Human
	h2     Human
	u8     u8
	u16    u16
	u32    u32
	u64    u64
	i8     i8
	i16    i16
	int    int
	i64    i64
	f32    f32
	f64    f64
	string string
	bool   bool
}

fn test_decode_primitive_types() {
	i := ReadableIni.from_globals_map({
		'h1':     '1'
		'h2':     'woman'
		'u8':     '1'
		'u16':    '2'
		'u32':    '3'
		'u64':    '4'
		'i8':     '5'
		'i16':    '6'
		'int':    '7'
		'i64':    '8'
		'f32':    '9.1'
		'f64':    '9.2'
		'string': 's'
		'bool':   'true'
	})
	r := decode[PrimitiveTypes, ReadableIni](i)!
	assert r.h1 == .woman
	assert r.h2 == .woman
	assert r.u8 == 1
	assert r.u16 == 2
	assert r.u32 == 3
	assert r.u64 == 4
	assert r.i8 == 5
	assert r.i16 == 6
	assert r.int == 7
	assert r.i64 == 8
	assert r.f32 == 9.1
	assert r.f64 == 9.2
	assert r.string == 's'
	assert r.bool == true
}

struct OptionalTypes {
	h1     ?Human
	h2     ?Human
	u8     ?u8
	u16    ?u16
	u32    ?u32
	u64    ?u64
	i8     ?i8
	i16    ?i16
	int    ?int
	i64    ?i64
	f32    ?f32
	f64    ?f64
	string ?string
	bool   ?bool
}

fn test_decode_optional_types() {
	i := ReadableIni.from_globals_map({
		'h1':     '1'
		'h2':     'woman'
		'u8':     '1'
		'u16':    '2'
		'u32':    '3'
		'u64':    '4'
		'i8':     '5'
		'i16':    '6'
		'int':    '7'
		'i64':    '8'
		'f32':    '9.1'
		'f64':    '9.2'
		'string': 's'
		'bool':   'true'
	})
	r := decode[OptionalTypes, ReadableIni](i)!
	assert r.h1? == .woman
	assert r.h2? == .woman
	assert r.u8? == 1
	assert r.u16? == 2
	assert r.u32? == 3
	assert r.u64? == 4
	assert r.i8? == 5
	assert r.i16? == 6
	assert r.int? == 7
	assert r.i64? == 8
	assert r.f32? == 9.1
	assert r.f64? == 9.2
	assert r.string? == 's'
	assert r.bool? == true
}

struct Arrays {
	h1     []Human
	h2     []Human
	u8     []u8
	u16    []u16
	u32    []u32
	u64    []u64
	i8     []i8
	i16    []i16
	int    []int
	i64    []i64
	f32    []f32
	f64    []f64
	string []string
	bool   []bool
}

fn test_decode_arrays_1() {
	i := ReadableIni.from_globals_map({
		'h1':     '1'
		'h2':     'woman'
		'u8':     '1'
		'u16':    '2'
		'u32':    '3'
		'u64':    '4'
		'i8':     '5'
		'i16':    '6'
		'int':    '7'
		'i64':    '8'
		'f32':    '9.1'
		'f64':    '9.2'
		'string': 's'
		'bool':   'true'
	})
	r := decode[Arrays, ReadableIni](i)!
	assert r.h1 == [.woman]
	assert r.h2 == [.woman]
	assert r.u8 == [u8(1)]
	assert r.u16 == [u16(2)]
	assert r.u32 == [u32(3)]
	assert r.u64 == [u64(4)]
	assert r.i8 == [i8(5)]
	assert r.i16 == [i16(6)]
	assert r.int == [7]
	assert r.i64 == [i64(8)]
	assert r.f32 == [f32(9.1)]
	assert r.f64 == [9.2]
	assert r.string == ['s']
	assert r.bool == [true]
}

fn test_decode_arrays_2() {
	i := ReadableIni.from_globals_map({
		'h1':     '1, 0'
		'h2':     'woman, man'
		'u8':     '1, 2 '
		'u16':    '2, 3 '
		'u32':    '3, 4 '
		'u64':    '4, 5 '
		'i8':     '5, 6 '
		'i16':    '6, 7 '
		'int':    '7, 8 '
		'i64':    '8, 9 '
		'f32':    '9.1, 10 '
		'f64':    '9.2, 10 '
		'string': 's, t '
		'bool':   'true, false'
	})
	r := decode[Arrays, ReadableIni](i)!
	assert r.h1 == [.woman, .man]
	assert r.h2 == [.woman, .man]
	assert r.u8 == [u8(1), 2]
	assert r.u16 == [u16(2), 3]
	assert r.u32 == [u32(3), 4]
	assert r.u64 == [u64(4), 5]
	assert r.i8 == [i8(5), 6]
	assert r.i16 == [i16(6), 7]
	assert r.int == [7, 8]
	assert r.i64 == [i64(8), 9]
	assert r.f32 == [f32(9.1), 10]
	assert r.f64 == [9.2, 10]
	assert r.string == ['s', 't']
	assert r.bool == [true, false]
}

struct CustomSplit {
	string []string @[split: ';']
}

fn test_decode_arrays_custom_split() {
	i := ReadableIni.from_globals_map({
		'string': 's;t'
	})
	r := decode[CustomSplit, ReadableIni](i)!
	assert r.string == ['s', 't']
}

struct EmptySection {
	empty Empty
}

fn test_decode_empty_section() {
	i := ReadableIni.from_sections_map({
		'empty': map[string]string{}
	})
	r := decode[EmptySection, ReadableIni](i)!
}

// struct OptionalArrays {
// 	// h1     ?[]Human
// 	// h2     ?[]Human
// 	u8     ?[]u8
// 	u16    ?[]u16
// 	u32    ?[]u32
// 	u64    ?[]u64
// 	i8     ?[]i8
// 	i16    ?[]i16
// 	int    ?[]int
// 	i64    ?[]i64
// 	f32    ?[]f32
// 	f64    ?[]f64
// 	string ?[]string
// 	bool   ?[]bool
// }

// fn test_decode_optinal_arrays() {
// 	i := ReadableIni.from_globals_map({
//		// 'h1':     '1'
//		// 'h2':     'woman'
//		'u8':     '1'
//		'u16':    '2'
//		'u32':    '3'
//		'u64':    '4'
//		'i8':     '5'
//		'i16':    '6'
//		'int':    '7'
//		'i64':    '8'
//		'f32':    '9.1'
//		'f64':    '9.2'
//		'string': 's'
//		'bool':   'true'
// 	})
// 	r := decode[OptionalArrays, ReadableIni](i)!
// 	// assert r.h1 == .woman
// 	// assert r.h2 == .woman
// 	assert r.u8? == [u8(1)]
// 	assert r.u16? == [u16(2)]
// 	assert r.u32? == [u32(3)]
// 	assert r.u64? == [u64(4)]
// 	assert r.i8? == [i8(5)]
// 	assert r.i16? == [i16(6)]
// 	assert r.int? == [7]
// 	assert r.i64? == [i64(8)]
// 	assert r.f32? == [f32(9.1)]
// 	assert r.f64? == [9.2]
// 	assert r.string? == ['s']
// 	assert r.bool? == [true]
// }

// struct ArraysOfOptions {
// 	// h1     []?Human
// 	// h2     []?Human
// 	u8     []?u8
// 	u16    []?u16
// 	u32    []?u32
// 	u64    []?u64
// 	i8     []?i8
// 	i16    []?i16
// 	int    []?int
// 	i64    []?i64
// 	f32    []?f32
// 	f64    []?f64
// 	string []?string
// 	bool   []?bool
// }

// fn test_decode_arrays_of_options() {
// 	i := ReadableIni.from_globals_map({
//		// 'h1':     '1'
//		// 'h2':     'woman'
//		'u8':     '1'
//		'u16':    '2'
//		'u32':    '3'
//		'u64':    '4'
//		'i8':     '5'
//		'i16':    '6'
//		'int':    '7'
//		'i64':    '8'
//		'f32':    '9.1'
//		'f64':    '9.2'
//		'string': 's'
//		'bool':   'true'
// 	})
// 	r := decode[ArraysOfOptions, ReadableIni](i)!
// 	// assert r.h1 == .woman
// 	// assert r.h2 == .woman
// 	assert r.u8 == [?u8(1)]
// 	assert r.u16 == [?u16(2)]
// 	assert r.u32 == [?u32(3)]
// 	assert r.u64 == [?u64(4)]
// 	assert r.i8 == [?i8(5)]
// 	assert r.i16 == [?i16(6)]
// 	assert r.int == [?int(7)]
// 	assert r.i64 == [?i64(8)]
// 	assert r.f32 == [?f32(9.1)]
// 	assert r.f64 == [?f64(9.2)]
// 	assert r.string == [?string('s')]
// 	assert r.bool == [?bool(true)]
// }

struct Maps {
	// h1     []Human
	// h2     []Human
	// u8 map[string]u8
	// u16    map[string]u16
	// u32    map[string]u32
	// u64    map[string]u64
	// i8     map[string]i8
	// i16    map[string]i16
	// int    map[string]int
	// i64    map[string]i64
	// f32    map[string]f32
	// f64    map[string]f64
	string map[string]string
	// bool   map[string]bool
}

fn test_decode_maps_1() {
	i := ReadableIni.from_globals_map({
		// 'h1':     '1'
		// 'h2':     'woman'
		// 'u8': 'val:1'
		// 'u16':    'val:2'
		// 'u32':    'val:3'
		// 'u64':    'val:4'
		// 'i8':     'val:5'
		// 'i16':    'val:6'
		// 'int':    'val:7'
		// 'i64':    'val:8'
		// 'f32':    'val:9.1'
		// 'f64':    'val:9.2'
		'string': 'val:s'
		// 'bool':   'val:true'
	})
	r := decode[Maps, ReadableIni](i)!
	// assert r.h1 == .woman
	// assert r.h2 == .woman
	// assert r.u8 == {
	// 	'val': u8(1)
	// }
	// assert r.u16 == {
	// 	'val': u16(2)
	// }
	// assert r.u32 == {
	// 	'val': u32(3)
	// }
	// assert r.u64 == {
	// 	'val': u64(4)
	// }
	// assert r.i8 == {
	// 	'val': i8(5)
	// }
	// assert r.i16 == {
	// 	'val': i16(6)
	// }
	// assert r.int == {
	// 	'val': 7
	// }
	// assert r.i64 == {
	// 	'val': i64(8)
	// }
	// assert r.f32 == {
	// 	'val': f32(9.1)
	// }
	// assert r.f64 == {
	// 	'val': 9.2
	// }
	assert r.string == {
		'val': 's'
	}
	// assert r.bool == {
	// 	'val': true
	// }
}
