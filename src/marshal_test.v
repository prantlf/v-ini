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
		h:      .woman
		u8:     1
		u16:    2
		u32:    3
		u64:    4
		i8:     5
		i16:    6
		int:    7
		i64:    8
		f32:    f32(9.1)
		f64:    9.2
		string: 's'
		bool:   true
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

struct OptionalTypes {
	h ?Human
	// u8     ?u8
	// u16    ?u16
	// u32    ?u32
	// u64    ?u64
	// i8     ?i8
	// i16    ?i16
	// int    ?int
	// i64    ?i64
	// f32    ?f32
	// f64    ?f64
	// string ?string
	// bool   ?bool
}

fn test_marshal_optional_types() {
	src := OptionalTypes{
		h: .woman
		// u8:     1
		// u16:    2
		// u32:    3
		// u64:    4
		// i8:     5
		// i16:    6
		// int:    7
		// i64:    8
		// f32:    f32(9.1)
		// f64:    9.2
		// string: 's'
		// bool:   true
	}
	res := marshal(src)!
	assert res == 'h = woman
'
}

fn test_marshal_enum_as_int() {
	src := OptionalTypes{
		h: .woman
	}
	res := marshal_opt(src, &MarshalOpts{ enums_as_names: false })!
	assert res == 'h = 1
'
}

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
		h:      [.woman]
		u8:     [u8(1)]
		u16:    [u16(2)]
		u32:    [u32(3)]
		u64:    [u64(4)]
		i8:     [i8(5)]
		i16:    [i16(6)]
		int:    [7]
		i64:    [i64(8)]
		f32:    [f32(9.1)]
		f64:    [9.2]
		string: ['s']
		bool:   [true]
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
		h:      [.man, .woman]
		u8:     [u8(1), u8(2)]
		u16:    [u16(2), u16(3)]
		u32:    [u32(3), u32(4)]
		u64:    [u64(4), u64(5)]
		i8:     [i8(5), i8(6)]
		i16:    [i16(6), i16(7)]
		int:    [7, 8]
		i64:    [i64(8), i64(9)]
		f32:    [f32(9.1), f32(10)]
		f64:    [9.2, 10]
		string: ['s', 't']
		bool:   [true, false]
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

struct MapProp {
	mapping map[string]string
}

fn test_marshal_map_to_property() {
	src := MapProp{
		mapping: {
			'defect':  'fix'
			'feature': 'feat'
		}
	}
	res := marshal(src)!
	out := r'mapping = defect: fix, feature: feat
'
	assert res == out
}

struct MapSection {
	mapping map[string]string @[json: 'type-mapping'; section]
}

fn test_marshal_map_to_section() {
	src := MapSection{
		mapping: {
			'defect':  'fix'
			'feature': 'feat'
		}
	}
	res := marshal(src)!
	out := r'[type-mapping]
defect = fix
feature = feat
'
	assert res == out
}

struct InnerStruct {
	answer int = 42
}

struct OuterStruct {
	inner InnerStruct
}

fn test_marshal_inner_struct() {
	src := OuterStruct{}
	res := marshal(src)!
	out := r'[inner]
answer = 42
'
	assert res == out
}

struct Opts {
	tag_prefix   string = 'v' @[json: 'tag-prefix']
	body_re      string @[json: 'body-re']
	version_re   string            = r'^\s*(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)|(?:\[(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\])).+\((?<date>[-\d]+)\)\s*$' @[json: 'version-re']
	prolog       string            = '# Changes'
	version_tpl  string            = '{heading} [{version}]({repo_url}/compare/{tag_prefix}{prev_version}...{tag_prefix}{version}) ({date})'            @[json: 'version-tpl']
	logged_types []string          = ['feat', 'fix', 'perf']          @[json: 'logged-types'; split]
	type_mapping map[string]string = {
		'defect':  'fix'
		'feature': 'feat'
	} @[json: 'type-mapping'; section]
mut:
	heading int = 2
}

fn test_marshal_opts() {
	opts := Opts{}
	res := marshal(opts)!
	out := r'tag-prefix = v
body-re = 
version-re = ^\s*(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)|(?:\[(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\])).+\((?<date>[-\d]+)\)\s*$
prolog = # Changes
version-tpl = {heading} [{version}]({repo_url}/compare/{tag_prefix}{prev_version}...{tag_prefix}{version}) ({date})
logged-types = feat, fix, perf
heading = 2

[type-mapping]
defect = fix
feature = feat
'
	assert res == out
}
