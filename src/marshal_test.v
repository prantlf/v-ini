module ini

struct Empty {}

fn test_marshal_empty() {
	out := marshal(Empty{})!
	assert out == ''
}

enum Human {
	man
	woman
}

struct PrimitiveTypes {
	h      Human
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

fn test_marshal_primitive_types() {
	src := PrimitiveTypes{
		h: .woman
		u8: 1
		u16: 2
		u32: 3
		u64: 4
		i8: 5
		i16: 6
		int: 7
		i64: 8
		f32: f32(9.1)
		f64: 9.2
		string: 's'
		bool: true
	}
	res := marshal(src)!
	assert res == 'h = woman
u8 = 1
u16 = 2
u32 = 3
u64 = 4
i8 = 5
i16 = 6
int = 7
i64 = 8
f32 = 9.1
f64 = 9.2
string = s
bool = true
'
}

// struct OptionalTypes {
// 	// h     ?Human
// 	u8     ?u8
// 	u16    ?u16
// 	u32    ?u32
// 	u64    ?u64
// 	i8     ?i8
// 	i16    ?i16
// 	int    ?int
// 	i64    ?i64
// 	f32    ?f32
// 	f64    ?f64
// 	// string ?string
// 	bool   ?bool
// }

// fn test_marshal_optional_types() {
// 	src := OptionalTypes{
// 		// h:     .woman
// 		u8:     1
// 		u16:    2
// 		u32:    3
// 		u64:    4
// 		i8:     5
// 		i16:    6
// 		int:    7
// 		i64:    8
// 		f32:    f32(9.1)
// 		f64:    9.2
// 		// string: 's'
// 		bool:   true
// 	}
// 	res := marshal(src)!
// assert res == 'u8 = 1
// u16 = 2
// u32 = 3
// u64 = 4
// i8 = 5
// i16 = 6
// int = 7
// i64 = 8
// f32 = 9.1
// f64 = 9.2
// bool = true
// '
// }

struct Arrays {
	h      []Human
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

fn test_marshal_arrays() {
	src := Arrays{
		h: [.woman]
		u8: [u8(1)]
		u16: [u16(2)]
		u32: [u32(3)]
		u64: [u64(4)]
		i8: [i8(5)]
		i16: [i16(6)]
		int: [7]
		i64: [i64(8)]
		f32: [f32(9.1)]
		f64: [9.2]
		string: ['s']
		bool: [true]
	}
	res := marshal(src)!
	assert res == 'h = woman
u8 = 1
u16 = 2
u32 = 3
u64 = 4
i8 = 5
i16 = 6
int = 7
i64 = 8
f32 = 9.1
f64 = 9.2
string = s
bool = true
'
}

fn test_marshal_arrays_2() {
	src := Arrays{
		h: [.man, .woman]
		u8: [u8(1), u8(2)]
		u16: [u16(2), u16(3)]
		u32: [u32(3), u32(4)]
		u64: [u64(4), u64(5)]
		i8: [i8(5), i8(6)]
		i16: [i16(6), i16(7)]
		int: [7, 8]
		i64: [i64(8), i64(9)]
		f32: [f32(9.1), f32(10)]
		f64: [9.2, 10]
		string: ['s', 't']
		bool: [true, false]
	}
	res := marshal(src)!
	assert res == 'h = man, woman
u8 = 1, 2
u16 = 2, 3
u32 = 3, 4
u64 = 4, 5
i8 = 5, 6
i16 = 6, 7
int = 7, 8
i64 = 8, 9
f32 = 9.1, 10
f64 = 9.2, 10
string = s, t
bool = true, false
'
}

struct CustomSplit {
	string []string @[split: ';']
}

fn test_marshal_arrays_custom_split() {
	src := CustomSplit{
		string: ['s', 't']
	}
	res := marshal(src)!
	assert res == 'string = s; t
'
}
