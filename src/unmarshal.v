module ini

pub struct UnmarshalOpts {
pub:
	require_all_fields     bool
	forbid_extra_keys      bool
	ignore_number_overflow bool
	preserve_whitespace    bool
}

pub fn unmarshal[T](source string) !T {
	return unmarshal_opt[T](source, UnmarshalOpts{})!
}

pub fn unmarshal_opt[T](source string, opts &UnmarshalOpts) !T {
	mut obj := T{}
	unmarshal_to_opt[T](source, mut obj, opts)!
	return obj
}

pub fn unmarshal_to[T](source string, mut obj T) ! {
	unmarshal_to_opt[T](source, mut obj, UnmarshalOpts{})!
}

pub fn unmarshal_to_opt[T](source string, mut obj T, opts &UnmarshalOpts) ! {
	ini := ReadableIni.parse_opt(source, ParseOpts{
		preserve_whitespace: opts.preserve_whitespace
	})!
	decode_to_opt[T, ReadableIni](ini, mut obj, DecodeOpts{
		require_all_fields: opts.require_all_fields
		forbid_extra_keys: opts.forbid_extra_keys
		ignore_number_overflow: opts.ignore_number_overflow
		preserve_whitespace: opts.preserve_whitespace
	})!
}
