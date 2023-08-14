module ini

struct Parser {
	opts   &ParseOpts = unsafe { nil }
	source string
mut:
	section    string
	line       int
	line_start int
}

fn (p &Parser) fail(offset int, msg string) ParseError {
	head_context, head_error := before_error(p.source, offset)
	tail_error, tail_context := after_error(p.source, offset)

	return ParseError{
		reason: msg
		head_context: head_context
		head_error: head_error
		tail_error: tail_error
		tail_context: tail_context
		offset: offset + 1
		line: p.line_start + 1
		column: offset - p.line_start + 1
	}
}

pub struct ParseOpts {
pub:
	preserve_whitespace bool
}

fn parse_contents[P, I](mut p P, ini &I, opts &ParseOpts) ! {
	if d.is_enabled() {
		short_s := d.shorten(p.source)
		opts_s := if opts.preserve_whitespace {
			', preserve whitespace'
		} else {
			''
		}
		d.log_str('parse ini "${short_s}" (length ${p.source.len}${opts_s})')
		d.stop_ticking()
		defer {
			d.start_ticking()
		}
	}

	mut globs_len := ini.globals.len
	mut sects_len := ini.sections.len
	for i := p.after_bom(); true; {
		i = p.skip_whitespace(i)
		if i == p.source.len {
			break
		}
		if p.source[i] == `[` {
			i = p.parse_section(i)!
		} else {
			i = p.parse_property(i)!
		}
		i = p.skip_whitespace(i)
	}

	if d.is_enabled() {
		d.start_ticking()
		globs_len = p.ini.globals.len - globs_len
		sects_len = p.ini.sections.len - sects_len
		globs := if globs_len == 1 {
			'property'
		} else {
			'properties'
		}
		sects := if sects_len == 1 {
			'section'
		} else {
			'sections'
		}
		d.log_str('parsed ini with ${globs_len} global ${globs} and ${sects_len} ${sects}')
	}
}

[direct_array_access]
fn skip_section[P](p &P, from int) !(int, int, int) {
	start := p.skip_space(from + 1)
	if start == p.source.len {
		return p.fail(start, 'unexpected end encountered before a section name')
	}

	mut name_end := 0
	mut i := start
	for {
		match p.source[i] {
			`]` {
				name_end = i
				break
			}
			` `, `\t` {
				next := p.skip_space(i + 1)
				if next == p.source.len {
					return p.fail(next, 'unexpected end encountered after a section name')
				}
				c := p.source[next]
				if c == `\r` || c == `\n` {
					return p.fail(next, 'unexpected line break encountered after a section name')
				}
				if c != `]` {
					return p.fail(next, 'unexpected "${rune(c)}" encountered when expecting "]"')
				}
				name_end = i
				i = next
				break
			}
			`\r`, `\n` {
				return p.fail(i, 'unexpected line break encountered when parsing a section name')
			}
			else {
				i++
				if i == p.source.len {
					return p.fail(i, 'unexpected end encountered when parsing a section name')
				}
			}
		}
	}
	if start == name_end {
		return p.fail(i, 'unexpected "]" encountered when expecting a section name')
	}

	return start, name_end, i + 1
}

[direct_array_access]
fn skip_property[P](p &P, from int) !(int, int, int, int) {
	mut name_end := 0
	mut i := from
	for {
		match p.source[i] {
			`=` {
				if i == from {
					return p.fail(i, 'unexpected "=" encountered when expecting a property name')
				}
				name_end = i
				break
			}
			` `, `\t` {
				next := p.skip_space(i + 1)
				if next == p.source.len {
					return p.fail(next, 'unexpected end encountered after a property name')
				}
				c := p.source[next]
				if c == `\r` || c == `\n` {
					return p.fail(next, 'unexpected line break encountered after a property name')
				}
				if c != `=` {
					return p.fail(next, 'unexpected "${rune(c)}" encountered when expecting "="')
				}
				name_end = i
				i = next
				break
			}
			`\r`, `\n` {
				return p.fail(i, 'unexpected line break encountered when parsing a property name')
			}
			else {
				i++
				if i == p.source.len {
					return p.fail(i, 'unexpected end encountered when parsing a property name')
				}
			}
		}
	}

	mut start := 0
	end := if p.opts.preserve_whitespace {
		i++
		start = i
		for i < p.source.len {
			match p.source[i] {
				`\r`, `\n` {
					break
				}
				else {
					i++
				}
			}
		}
		i
	} else {
		i = p.skip_space(i + 1)
		start = i
		mut last_space := 0
		for i < p.source.len {
			match p.source[i] {
				`\r`, `\n` {
					break
				}
				` `, `\t` {
					if last_space == 0 {
						last_space = i
					}
				}
				else {
					if last_space != 0 {
						last_space = 0
					}
				}
			}
			i++
		}
		if last_space > 0 {
			last_space
		} else {
			i
		}
	}
	if d.is_enabled() {
		name := d.shorten(p.source[from..name_end])
		val_s := d.shorten(p.source[start..end])
		d.log_str('set property "${name}" to "${val_s}"')
	}
	return name_end, start, end, i
}

[direct_array_access]
fn (p &Parser) skip_space(from int) int {
	mut i := from
	for i < p.source.len {
		match p.source[i] {
			` `, `\t` {
				i++
			}
			else {
				break
			}
		}
	}
	return i
}

[direct_array_access]
fn (mut p Parser) skip_whitespace(from int) int {
	mut i := from
	for i < p.source.len {
		match p.source[i] {
			` `, `\t`, `\r` {
				i++
			}
			`\n` {
				i++
				p.line++
				p.line_start = i
			}
			`;` {
				i = p.skip_comment(i)
			}
			else {
				break
			}
		}
	}
	return i
}

[direct_array_access]
fn (mut p Parser) skip_comment(from int) int {
	mut i := from + 1
	for i < p.source.len {
		c := p.source[i]
		i++
		if c == `\n` {
			p.line++
			p.line_start = i
			break
		}
	}
	return i
}

[direct_array_access]
fn (p &Parser) after_bom() int {
	if p.source.len >= 3 {
		unsafe {
			text := p.source.str
			if text[0] == 0xEF && text[1] == 0xBB && text[2] == 0xBF {
				return 3
			}
		}
	}
	return 0
}
