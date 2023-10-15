module ini

import strings { Builder, new_builder }

pub struct MarshalOpts {
}

pub fn marshal[T](source &T) !string {
	return marshal_opt[T](source, MarshalOpts{})!
}

pub fn marshal_opt[T](source &T, opts &MarshalOpts) !string {
	mut builder := new_builder(1024)
	marshal_to_opt[T](source, mut builder, opts)!
	return builder.str()
}

pub fn marshal_to[T](source &T, mut builder Builder) ! {
	marshal_to_opt[T](source, mut builder, MarshalOpts{})!
}

pub fn marshal_to_opt[T](typ &T, mut builder Builder, opts &MarshalOpts) ! {
	$for field in T.fields {
		mut json_name := field.name
		mut skip := false
		mut split := ','
		mut entrysplit := ':'
		for attr in field.attrs {
			if attr.starts_with('json: ') {
				json_name = attr[6..]
			} else if attr == 'skip' {
				skip = true
			} else if attr == 'split' {
				split = ','
			} else if attr.starts_with('split: ') {
				split = attr[7..]
			} else if attr == 'entrysplit' {
				entrysplit = ':'
			} else if attr.starts_with('entrysplit: ') {
				entrysplit = attr[12..]
			}
		}

		if skip {
		} else {
			$if field.is_option {
				mut val_opt := typ.$(field.name)
				if val := val_opt {
					builder.write_string(json_name)
					builder.write_u8(` `)
					builder.write_u8(`=`)
					builder.write_u8(` `)
					$if field.typ is ?int || field.typ is ?u8 || field.typ is ?u16
						|| field.typ is ?u32 || field.typ is ?u64 || field.typ is ?i8
						|| field.typ is ?i16 || field.typ is ?i64 || field.typ is ?bool {
						builder.write_string(val.str())
					} $else $if field.typ is f32 {
						builder.write_string(number32_to_string(val))
					} $else $if field.typ is ?f64 {
						builder.write_string(number64_to_string(val))
						// } $else $if field.typ is ?string {
						//  mut val := typ.$(field.name)
						// 	builder.write_string(val?)
					} $else {
						return error('unsupported type Option(${type_name(field.typ)}) of ${field.name}')
					}
				}
			} $else {
				builder.write_string(json_name)
				builder.write_u8(` `)
				builder.write_u8(`=`)
				builder.write_u8(` `)
				$if field.is_enum || field.typ is int || field.typ is u8 || field.typ is u16
					|| field.typ is u32 || field.typ is u64 || field.typ is i8 || field.typ is i16
					|| field.typ is i64 || field.typ is bool {
					val := typ.$(field.name)
					builder.write_string(val.str())
				} $else $if field.typ is f32 {
					val := typ.$(field.name)
					builder.write_string(number32_to_string(val))
				} $else $if field.typ is f64 {
					val := typ.$(field.name)
					builder.write_string(number64_to_string(val))
				} $else $if field.typ is string {
					val := typ.$(field.name)
					builder.write_string(val)
				} $else $if field.is_array {
					arr := typ.$(field.name)
					marshal_array(arr, split, mut builder, opts)!
				} $else $if field.is_map {
					src := &typ.$(field.name)
					marshal_map(src, split, entrysplit, mut builder, opts)!
				} $else {
					return error('unsupported type ${type_name(field.typ)} of ${field.name}')
				}
			}
		}

		builder.write_u8(`\n`)
	}
}

fn marshal_val[T](val &T, mut builder Builder, opts &MarshalOpts) !bool {
	$if T is $enum || T is int || T is u8 || T is u16 || T is u32 || T is u64 || T is i8 || T is i16
		|| T is i64 || T is bool {
		builder.write_string(val.str())
	} $else $if T is f32 {
		builder.write_string(number32_to_string(val))
	} $else $if T is f64 {
		builder.write_string(number64_to_string(val))
	} $else $if T is string {
		builder.write_string(val)
	} $else {
		return error('unsupported type ${T.name}')
	}
	return true
}

fn marshal_array[T](typ []T, split string, mut builder Builder, opts &MarshalOpts) ! {
	mut next := false
	for item in typ {
		if next {
			builder.write_string(split)
			builder.write_u8(` `)
		}
		if marshal_val[T](item, mut builder, opts)! {
			next = true
		}
	}
}

fn marshal_map[T](typ &map[string]T, split string, entrysplit string, mut builder Builder, opts &MarshalOpts) ! {
	mut next := false
	for key, value in typ {
		if next {
			builder.write_string(split)
			builder.write_u8(` `)
		}
		builder.write_string(key)
		builder.write_string(entrysplit)
		builder.write_u8(` `)
		marshal_val[T](value, mut builder, opts)!
		next = true
	}
}

fn number32_to_string(float f32) string {
	num := int(float)
	return if float == num {
		num.str()
	} else {
		float.str()
	}
}

fn number64_to_string(float f64) string {
	num := int(float)
	return if float == num {
		num.str()
	} else {
		float.str()
	}
}
