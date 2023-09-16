module ini

struct ReadableParser {
	Parser
mut:
	ri      &ReadableIni = unsafe { nil }
	section &Section     = unsafe { nil }
}

pub fn parse_readable(source string) !&ReadableIni {
	return parse_readable_opt(source, ParseOpts{})!
}

pub fn parse_readable_opt(source string, opts &ParseOpts) !&ReadableIni {
	mut i := &ReadableIni{
		source: source
	}
	mut p := &ReadableParser{
		opts: unsafe { opts }
		ri: i
		source: source
	}
	parse_contents(mut p, i, opts)!
	return i
}

[direct_array_access]
fn (mut p ReadableParser) parse_section(from int) !int {
	start, name_end, i := skip_section(p, from)!

	p.ri.sections << Section{
		name_start: start
		name_end: name_end
	}
	p.section = &p.ri.sections[p.ri.sections.len - 1]
	if d.is_enabled() {
		name := d.shorten(p.source[from..name_end])
		d.log_str('start section "${name}"')
	}

	return i
}

[direct_array_access]
fn (mut p ReadableParser) parse_property(from int) !int {
	name_end, start, end, i := skip_property(p, from)!

	prop := Property{
		name_start: from
		name_end: name_end
		val_start: start
		val_end: end
	}
	if isnil(p.section) {
		p.ri.globals << prop
	} else {
		p.section.props << prop
	}

	return i
}
