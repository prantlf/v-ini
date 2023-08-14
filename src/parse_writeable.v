module ini

struct WriteableParser {
	Parser
mut:
	ini     &WriteableIni = unsafe { nil }
	section string
}

pub fn WriteableIni.parse(source string) !&WriteableIni {
	return WriteableIni.parse_opt(source, ParseOpts{})!
}

pub fn WriteableIni.parse_opt(source string, opts &ParseOpts) !&WriteableIni {
	mut ini := &WriteableIni{}
	WriteableIni.parse_to_opt(source, mut ini, opts)!
	return ini
}

pub fn WriteableIni.parse_to(source string, mut ini WriteableIni) ! {
	WriteableIni.parse_to_opt(source, mut ini, ParseOpts{})!
}

pub fn WriteableIni.parse_to_opt(source string, mut ini WriteableIni, opts &ParseOpts) ! {
	mut p := &WriteableParser{
		opts: unsafe { opts }
		ini: unsafe { ini }
		source: source
	}
	parse_contents(mut p, ini, opts)!
}

[direct_array_access]
fn (mut p WriteableParser) parse_section(from int) !int {
	start, name_end, i := skip_section(p, from)!
	p.section = p.source[start..name_end]
	d.log('start section "%s"', p.section)
	return i
}

[direct_array_access]
fn (mut p WriteableParser) parse_property(from int) !int {
	name_end, start, end, i := skip_property(p, from)!

	name := p.source[from..name_end]
	val := p.source[start..end]
	val_s := d.shorten(val)
	d.log('set property "%s" to "%s"', name, val_s)

	if p.section.len > 0 {
		p.ini.sections[p.section][name] = val
	} else {
		p.ini.globals[name] = val
	}

	return i
}
