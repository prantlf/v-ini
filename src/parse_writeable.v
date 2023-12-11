module ini

struct WriteableParser {
	Parser
mut:
	ri      &WriteableIni = unsafe { nil }
	section string
}

pub fn parse_writeable(source string) !&WriteableIni {
	return parse_writeable_opt(source, ParseOpts{})!
}

pub fn parse_writeable_opt(source string, opts &ParseOpts) !&WriteableIni {
	mut i := &WriteableIni{}
	parse_writeable_to_opt(source, mut i, opts)!
	return i
}

pub fn parse_writeable_to(source string, mut i WriteableIni) ! {
	parse_writeable_to_opt(source, mut i, ParseOpts{})!
}

pub fn parse_writeable_to_opt(source string, mut i WriteableIni, opts &ParseOpts) ! {
	mut p := &WriteableParser{
		opts: unsafe { opts }
		ri: unsafe { i }
		source: source
	}
	parse_contents(mut p, i, opts)!
}

@[direct_array_access]
fn (mut p WriteableParser) parse_section(from int) !int {
	start, name_end, i := skip_section(p, from)!
	p.section = p.source[start..name_end]
	d.log('start section "%s"', p.section)
	return i
}

@[direct_array_access]
fn (mut p WriteableParser) parse_property(from int) !int {
	name_end, start, end, i := skip_property(p, from)!

	name := p.source[from..name_end]
	val := p.source[start..end]
	val_s := d.shorten(val)
	d.log('set property "%s" to "%s"', name, val_s)

	if p.section.len > 0 {
		p.ri.sections[p.section][name] = val
	} else {
		p.ri.globals[name] = val
	}

	return i
}
