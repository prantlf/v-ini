module ini

import io { Writer }
import strings { Builder, new_builder }

interface Output {
mut:
	write_string(s string) !
	write_u8(ch u8) !
}

struct BuilderOutput {
mut:
	builder &Builder
}

fn (mut o BuilderOutput) write_string(s string) ! {
	o.builder.write_string(s)
}

fn (mut o BuilderOutput) write_u8(ch u8) ! {
	o.builder.write_u8(ch)
}

struct WriterOuptut {
mut:
	writer Writer
}

fn (mut o WriterOuptut) write_string(s string) ! {
	buf := s.bytes()
	n := o.writer.write(buf)!
	if n != buf.len {
		return error('only ${n} bytes from ${buf.len} were written')
	}
}

fn (mut o WriterOuptut) write_u8(ch u8) ! {
	buf := unsafe {
		array{
			element_size: sizeof(u8)
			data: vcalloc(1)
			len: 1
			cap: 1
		}
	}
	// buf := [ch]
	n := o.writer.write(buf)!
	if n != 1 {
		return error('no bytes from 1 were written')
	}
}

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

pub fn marshal_to_writer[T](source &T, mut writer Writer) ! {
	marshal_to_writer_opt[T](source, mut writer, MarshalOpts{})!
}

pub fn marshal_to_opt[T](source &T, mut builder Builder, opts &MarshalOpts) ! {
	mut out := BuilderOutput{
		builder: unsafe { &builder }
	}
	marshal_out[T](source, mut out, opts)!
}

pub fn marshal_to_writer_opt[T](source &T, mut writer Writer, opts &MarshalOpts) ! {
	mut out := WriterOuptut{writer}
	marshal_out[T](source, mut out, opts)!
}

pub fn marshal_out[T](typ &T, mut output Output, opts &MarshalOpts) ! {
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
					output.write_string(json_name)!
					output.write_string(' = ')!
					$if field.typ is ?int || field.typ is ?u8 || field.typ is ?u16
						|| field.typ is ?u32 || field.typ is ?u64 || field.typ is ?i8
						|| field.typ is ?i16 || field.typ is ?i64 || field.typ is ?bool {
						output.write_string(val.str())!
					} $else $if field.typ is f32 {
						output.write_string(number32_to_string(val))!
					} $else $if field.typ is ?f64 {
						output.write_string(number64_to_string(val))!
						// } $else $if field.typ is ?string {
						//  mut val := typ.$(field.name)
						// 	output.write_string(val?)!
					} $else {
						return error('unsupported type Option(${type_name(field.typ)}) of ${field.name}')
					}
				}
			} $else {
				output.write_string(json_name)!
				output.write_string(' = ')!
				$if field.is_enum || field.typ is int || field.typ is u8 || field.typ is u16
					|| field.typ is u32 || field.typ is u64 || field.typ is i8 || field.typ is i16
					|| field.typ is i64 || field.typ is bool {
					val := typ.$(field.name)
					output.write_string(val.str())!
				} $else $if field.typ is f32 {
					val := typ.$(field.name)
					output.write_string(number32_to_string(val))!
				} $else $if field.typ is f64 {
					val := typ.$(field.name)
					output.write_string(number64_to_string(val))!
				} $else $if field.typ is string {
					val := typ.$(field.name)
					output.write_string(val)!
				} $else $if field.is_array {
					arr := typ.$(field.name)
					marshal_array(arr, split, mut output, opts)!
				} $else $if field.is_map {
					src := &typ.$(field.name)
					marshal_map(src, split, entrysplit, mut output, opts)!
				} $else {
					return error('unsupported type ${type_name(field.typ)} of ${field.name}')
				}
			}
		}

		output.write_u8(`\n`)!
	}
}

fn marshal_val[T](val &T, mut output Output, opts &MarshalOpts) !bool {
	$if T is $enum || T is int || T is u8 || T is u16 || T is u32 || T is u64 || T is i8 || T is i16
		|| T is i64 || T is bool {
		output.write_string(val.str())!
	} $else $if T is f32 {
		output.write_string(number32_to_string(val))!
	} $else $if T is f64 {
		output.write_string(number64_to_string(val))!
	} $else $if T is string {
		output.write_string(val)!
	} $else {
		return error('unsupported type ${T.name}')
	}
	return true
}

fn marshal_array[T](typ []T, split string, mut output Output, opts &MarshalOpts) ! {
	mut next := false
	for item in typ {
		if next {
			output.write_string(split)!
			output.write_u8(` `)!
		}
		if marshal_val[T](item, mut output, opts)! {
			next = true
		}
	}
}

fn marshal_map[T](typ &map[string]T, split string, entrysplit string, mut output Output, opts &MarshalOpts) ! {
	mut next := false
	for key, value in typ {
		if next {
			output.write_string(split)!
			output.write_u8(` `)!
		}
		output.write_string(key)!
		output.write_string(entrysplit)!
		output.write_u8(` `)!
		marshal_val[T](value, mut output, opts)!
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
