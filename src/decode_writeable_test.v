module ini

struct Arrays {
	// h1     []Human
	// h2     []Human
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
	i := WriteableIni.from_globals_map({
		// 'h1':     '1'
		// 'h2':     'woman'
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
	r := decode[Arrays, WriteableIni](i)!
	// assert r.h1 == .woman
	// assert r.h2 == .woman
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
