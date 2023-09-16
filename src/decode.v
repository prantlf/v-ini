module ini

import math
import strconv { atoi, parse_int, parse_uint }
import v.reflection { Enum, get_type }
import prantlf.debug { new_debug }
import prantlf.strutil { avoid_space }

#include <stdlib.h>
#include <errno.h>

fn C.strtod(charptr, &charptr) f64

const d = new_debug('ini')

pub struct DecodeOpts {
pub:
	require_all_fields     bool
	forbid_extra_keys      bool
	ignore_number_overflow bool
	preserve_whitespace    bool
}

pub fn decode[T, I](i &I) !T {
	return decode_opt[T, I](i, &DecodeOpts{})!
}

pub fn decode_opt[T, I](i &I, opts &DecodeOpts) !T {
	mut obj := T{}
	decode_to_opt[T, I](i, mut obj, opts)!
	return obj
}

pub fn decode_to[T, I](i &I, mut obj T) ! {
	decode_to_opt[T, I](i, mut obj, &DecodeOpts{})!
}

pub fn decode_to_opt[T, I](i &I, mut obj T, opts &DecodeOpts) ! {
	decode_props[T, I](mut obj, i, i.globals, opts)!
	decode_sects[T, I](mut obj, i, opts)!
}

pub fn decode_readable[T](i &ReadableIni) !T {
	return decode_readable_opt[T](i, &DecodeOpts{})!
}

pub fn decode_readable_opt[T](i &ReadableIni, opts &DecodeOpts) !T {
	mut obj := T{}
	decode_readable_to_opt[T](i, mut obj, opts)!
	return obj
}

pub fn decode_readable_to[T](i &ReadableIni, mut obj T) ! {
	decode_readable_to_opt[T](i, mut obj, &DecodeOpts{})!
}

pub fn decode_readable_to_opt[T](i &ReadableIni, mut obj T, opts &DecodeOpts) ! {
	decode_props[T, ReadableIni](mut obj, i, i.globals, opts)!
	decode_sects[T, ReadableIni](mut obj, i, opts)!
}

pub fn decode_writeable[T](i &WriteableIni) !T {
	return decode_writeable_opt[T](i, &DecodeOpts{})!
}

pub fn decode_writeable_opt[T](i &WriteableIni, opts &DecodeOpts) !T {
	mut obj := T{}
	decode_writeable_to_opt[T](i, mut obj, opts)!
	return obj
}

pub fn decode_writeable_to[T](i &WriteableIni, mut obj T) ! {
	decode_writeable_to_opt[T](i, mut obj, &DecodeOpts{})!
}

pub fn decode_writeable_to_opt[T](i &WriteableIni, mut obj T, opts &DecodeOpts) ! {
	decode_props[T, WriteableIni](mut obj, i, i.globals, opts)!
	decode_sects[T, WriteableIni](mut obj, i, opts)!
}

fn decode_props[T, I](mut typ T, i &I, props voidptr, opts &DecodeOpts) ! {
	if opts.forbid_extra_keys {
		props_len := i.get_props_len(props)
		for n in 0 .. props_len {
			$for field in T.fields {
				mut json_name := field.name
				mut skip := false
				for attr in field.attrs {
					if attr.starts_with('json: ') {
						json_name = attr[6..]
					} else if attr == 'skip' {
						skip = true
					}
				}
				if skip || json_name == i.get_prop_name(props, n) {
					unsafe {
						goto passed
					}
				}
			}
			return error('extra "${i.get_prop_name(props, n)}" key')
			passed:
		}
	}

	$for field in T.fields {
		$if !field.is_struct {
			mut json_name := field.name
			mut required := false
			mut skip := false
			mut split := ','
			mut nooverflow := false
			for attr in field.attrs {
				if attr.starts_with('json: ') {
					json_name = attr[6..]
				} else if attr == 'required' {
					required = true
				} else if attr == 'skip' {
					skip = true
				} else if attr == 'split' {
					split = ','
				} else if attr.starts_with('split: ') {
					split = attr[7..]
				} else if attr == 'nooverflow' {
					nooverflow = true
				}
			}

			if skip {
			} else if val := i.get_prop_val(props, json_name) {
				ino := nooverflow || opts.ignore_number_overflow
				$if field.is_enum {
					typ.$(field.name) = decode_enum(val, field.typ)!
				} $else $if field.typ is int || field.typ is ?int {
					typ.$(field.name) = decode_int[int](val, ino)!
				} $else $if field.typ is u8 || field.typ is ?u8 {
					typ.$(field.name) = decode_int[u8](val, ino)!
				} $else $if field.typ is u16 || field.typ is ?u16 {
					typ.$(field.name) = decode_int[u16](val, ino)!
				} $else $if field.typ is u32 || field.typ is ?u32 {
					typ.$(field.name) = decode_int[u32](val, ino)!
				} $else $if field.typ is u64 || field.typ is ?u64 {
					typ.$(field.name) = parse_uint(val, 10, 64)!
				} $else $if field.typ is i8 || field.typ is ?i8 {
					typ.$(field.name) = decode_int[i8](val, ino)!
				} $else $if field.typ is i16 || field.typ is ?i16 {
					typ.$(field.name) = decode_int[i16](val, ino)!
				} $else $if field.typ is i64 || field.typ is ?i64 {
					typ.$(field.name) = parse_int(val, 10, 64)!
				} $else $if field.typ is f32 || field.typ is ?f32 {
					typ.$(field.name) = decode_f32(val, ino)!
				} $else $if field.typ is f64 || field.typ is ?f64 {
					typ.$(field.name) = decode_f64(val, ino)!
				} $else $if field.typ is bool || field.typ is ?bool {
					typ.$(field.name) = decode_bool(val)!
				} $else $if field.typ is string || field.typ is ?string {
					typ.$(field.name) = val
				} $else $if field.is_array {
					$if field.is_option {
						mut arr := typ.$(field.name)
						typ.$(field.name) = decode_array_option(arr, val, split, opts)!
					} $else {
						mut arr := typ.$(field.name)
						decode_array(mut arr, val, split, opts)!
						typ.$(field.name) = arr
					}
				} $else {
					return error('unsupported type ${type_name(field.typ)} of ${field.name}')
				}
			} else if required || opts.require_all_fields {
				return error('missing "${json_name}" key')
			}
		}
	}
}

fn decode_sects[T, I](mut typ T, i &I, opts &DecodeOpts) ! {
	$for field in T.fields {
		$if field.is_struct {
			mut json_name := field.name
			mut required := false
			mut skip := false
			for attr in field.attrs {
				if attr.starts_with('json: ') {
					json_name = attr[6..]
				} else if attr == 'required' {
					required = true
				} else if attr == 'skip' {
					skip = true
				}
			}

			if skip {
			} else if props := i.get_sect_props(json_name) {
				mut obj := typ.$(field.name)
				decode_props(mut obj, i, props, opts)!
				typ.$(field.name) = obj
			} else if required || opts.require_all_fields {
				return error('missing "${json_name}" key')
			}
		}
	}
}

fn decode_array[T](mut typ []T, text string, split string, opts &DecodeOpts) ! {
	res := text.split(split)
	for item in res {
		val := if opts.preserve_whitespace {
			item
		} else {
			start, end := avoid_space(item)
			item[start..end]
		}
		typ << decode_val[T](val, opts)!
	}
}

fn decode_array_option[T](_ ?[]T, val string, split string, opts &DecodeOpts) ![]T {
	mut arr := []T{}
	decode_array(mut arr, val, split, opts)!
	return arr
}

fn decode_val[T](val string, opts &DecodeOpts) !T {
	mut typ := T{}
	ino := opts.ignore_number_overflow
	$if T is $enum {
		typ = decode_enum(val, T.idx)!
	} $else $if T is int || T is ?int {
		typ = decode_int[int](val, ino)!
	} $else $if T is u8 || T is ?u8 {
		typ = decode_int[u8](val, ino)!
	} $else $if T is u16 || T is ?u16 {
		typ = decode_int[u16](val, ino)!
	} $else $if T is u32 || T is ?u32 {
		typ = decode_int[u32](val, ino)!
	} $else $if T is u64 || T is ?u64 {
		typ = parse_uint(val, 10, 64)!
	} $else $if T is i8 || T is ?i8 {
		typ = decode_int[i8](val, ino)!
	} $else $if T is i16 || T is ?i16 {
		typ = decode_int[i16](val, ino)!
	} $else $if T is i64 || T is ?i64 {
		typ = parse_int(val, 10, 64)!
	} $else $if T is f32 || T is ?f32 {
		typ = decode_f32(val, ino)!
	} $else $if T is f64 || T is ?f64 {
		typ = decode_f64(val, ino)!
	} $else $if T is bool || T is ?bool {
		typ = decode_bool(val)!
	} $else $if T is string || T is ?string {
		typ = val
	} $else {
		return error('unsupported type ${T.name}')
	}
	return typ
}

fn decode_int[T](val string, ignore_overflow bool) !T {
	n := atoi(val)!
	num := T(n)
	if !ignore_overflow && num != n {
		return error('unable to convert "${n}" to ${T.name}')
	}
	return num
}

fn decode_f64(val string, ignore_overflow bool) !f64 {
	end := unsafe { nil }
	C.errno = 0
	num := C.strtod(val.str, &end)
	if C.errno != 0 {
		text := if end != unsafe { nil } {
			unsafe { tos(val.str, &u8(end) - val.str) }
		} else {
			unsafe { tos(val.str, 1) }
		}
		return error('expected number but got "${text}"')
	}
	if end != unsafe { nil } && end != unsafe { val.str + val.len } {
		return error('unexpected text after a number "${val}"')
	}
	return num
}

fn decode_f32(val string, ignore_overflow bool) !f32 {
	float := decode_f64(val, ignore_overflow)!
	num := f32(float)
	if !ignore_overflow && float - f64(num) > math.smallest_non_zero_f64 {
		return error('unable to convert "${float}" to f32')
	}
	return num
}

fn decode_bool(val string) !bool {
	match val {
		'true', 'yes', 'on', '1' {
			return true
		}
		'false', 'no', 'off', '0' {
			return false
		}
		else {
			return error('"${val}" is not a boolean')
		}
	}
}

fn decode_enum(val string, typ int) !int {
	if val.len > 0 && val[0] >= `0` && val[0] <= `9` {
		return decode_int[int](val, false)!
	} else {
		enums := enum_vals(typ)!
		idx := enums.index(val)
		if idx >= 0 {
			return idx
		} else {
			return error('"${val}" not in ${type_name(typ)} enum')
		}
	}
}

fn type_name(idx int) string {
	return if typ := get_type(idx) {
		typ.name
	} else {
		'unknown'
	}
}

fn enum_vals(idx int) ![]string {
	return if typ := get_type(idx) {
		if typ.sym.info is Enum {
			typ.sym.info.vals
		} else {
			error('not an enum ${typ.name}')
		}
	} else {
		error('unknown enum')
	}
}
