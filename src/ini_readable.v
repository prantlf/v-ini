module ini

import strings { Builder, new_builder }
import prantlf.strutil { compare_str_within_nochk }

struct Property {
	name_start int
	name_end   int
	val_start  int
	val_end    int
}

struct Section {
	name_start int
	name_end   int
mut:
	props []Property
}

[heap; noinit]
pub struct ReadableIni {
mut:
	source   string
	globals  []Property
	sections []Section
}

pub fn ReadableIni.from_globals_map(globals map[string]string) &ReadableIni {
	return ReadableIni.from_both_maps(globals, map[string]map[string]string{})
}

pub fn ReadableIni.from_sections_map(sections map[string]map[string]string) &ReadableIni {
	return ReadableIni.from_both_maps(map[string]string{}, sections)
}

pub fn ReadableIni.from_both_maps(globals map[string]string, sections map[string]map[string]string) &ReadableIni {
	mut builder := new_builder(32)
	mut ini := &ReadableIni{}

	fill_props(globals, mut ini.globals, mut builder)

	for section, vals in sections {
		builder.write_u8(`[`)
		start_sect := builder.len
		builder.write_string(section)
		builder.write_u8(`]`)
		builder.write_u8(`\n`)
		mut sect := Section{
			name_start: start_sect
			name_end: start_sect + section.len
		}
		fill_props(vals, mut sect.props, mut builder)
		ini.sections << sect
	}

	ini.source = builder.str()
	return ini
}

fn fill_props(vals map[string]string, mut props []Property, mut builder Builder) {
	for name, val in vals {
		start := builder.len
		builder.write_string(name)
		builder.write_u8(`=`)
		builder.write_string(val)
		builder.write_u8(`\n`)
		props << Property{
			name_start: start
			name_end: start + name.len
			val_start: start + name.len + 1
			val_end: start + name.len + 1 + val.len
		}
	}
}

pub fn (i &ReadableIni) globals_len() int {
	return i.globals.len
}

pub fn (i &ReadableIni) global_names() []string {
	mut names := []string{}
	for prop in i.globals {
		names << i.source[prop.name_start..prop.name_end]
	}
	return names
}

pub fn (i &ReadableIni) has_global_val(name string) bool {
	for prop in i.globals {
		if unsafe { compare_str_within_nochk(name, i.source, prop.name_start, prop.name_end) } == 0 {
			return true
		}
	}
	return false
}

pub fn (i &ReadableIni) global_val(name string) ?string {
	for prop in i.globals {
		if unsafe { compare_str_within_nochk(name, i.source, prop.name_start, prop.name_end) } == 0 {
			return i.source[prop.val_start..prop.val_end]
		}
	}
	return none
}

pub fn (i &ReadableIni) sections_len() int {
	return i.sections.len
}

pub fn (i &ReadableIni) section_names() []string {
	mut names := []string{}
	for sect in i.sections {
		names << i.source[sect.name_start..sect.name_end]
	}
	return names
}

pub fn (i &ReadableIni) has_section(section string) bool {
	for sect in i.sections {
		if unsafe { compare_str_within_nochk(section, i.source, sect.name_start, sect.name_end) } == 0 {
			return true
		}
	}
	return false
}

pub fn (i &ReadableIni) section_props_len(section string) ?int {
	for sect in i.sections {
		if unsafe { compare_str_within_nochk(section, i.source, sect.name_start, sect.name_end) } == 0 {
			return sect.props.len
		}
	}
	return none
}

pub fn (i &ReadableIni) section_prop_names(name string) ?[]string {
	for sect in i.sections {
		if unsafe { compare_str_within_nochk(name, i.source, sect.name_start, sect.name_end) } == 0 {
			mut names := []string{}
			for prop in sect.props {
				names << i.source[prop.name_start..prop.name_end]
			}
			return names
		}
	}
	return none
}

pub fn (i &ReadableIni) has_section_prop(section string, name string) bool {
	for sect in i.sections {
		if unsafe { compare_str_within_nochk(section, i.source, sect.name_start, sect.name_end) } == 0 {
			for prop in sect.props {
				if unsafe {
					compare_str_within_nochk(name, i.source, prop.name_start, prop.name_end)
				} == 0 {
					return true
				}
			}
			break
		}
	}
	return false
}

pub fn (i &ReadableIni) section_prop_val(section string, name string) ?string {
	for sect in i.sections {
		if unsafe { compare_str_within_nochk(section, i.source, sect.name_start, sect.name_end) } == 0 {
			for prop in sect.props {
				if unsafe {
					compare_str_within_nochk(name, i.source, prop.name_start, prop.name_end)
				} == 0 {
					return i.source[prop.val_start..prop.val_end]
				}
			}
			break
		}
	}
	return none
}

[noinit]
pub struct Sections {
	ini &ReadableIni
mut:
	idx int
}

pub fn (i &ReadableIni) sections() Sections {
	return Sections{
		ini: i
	}
}

pub fn (s &Sections) is_valid() bool {
	return s.idx != s.ini.sections.len
}

pub fn (mut s Sections) next() bool {
	if s.idx == s.ini.sections.len {
		return false
	}
	s.idx++
	return true
}

pub fn (s &Sections) name() string {
	sect := s.ini.sections[s.idx]
	return s.ini.source[sect.name_start..sect.name_end]
}

pub fn (s &Sections) len() int {
	return s.ini.sections[s.idx].props.len
}

pub fn (s &Sections) has(name string) bool {
	for prop in s.ini.sections[s.idx].props {
		if unsafe { compare_str_within_nochk(name, s.ini.source, prop.name_start, prop.name_end) } == 0 {
			return true
		}
	}
	return false
}

pub fn (s &Sections) prop_names(name string) []string {
	mut names := []string{}
	for prop in s.ini.sections[s.idx].props {
		names << s.ini.source[prop.name_start..prop.name_end]
	}
	return names
}

pub fn (s &Sections) prop_val(name string) ?string {
	for prop in s.ini.sections[s.idx].props {
		if unsafe { compare_str_within_nochk(name, s.ini.source, prop.name_start, prop.name_end) } == 0 {
			return s.ini.source[prop.val_start..prop.val_end]
		}
	}
	return none
}

pub fn (s &Sections) props() Properties {
	return Properties{
		ini: s.ini
		props: s.ini.sections[s.idx].props
	}
}

[noinit]
pub struct Properties {
	ini   &ReadableIni
	props []Property
mut:
	idx int
}

pub fn (i &ReadableIni) globals(section string) Properties {
	return Properties{
		ini: i
		props: i.globals
	}
}

pub fn (i &ReadableIni) section_props(section string) ?Properties {
	for sect in i.sections {
		if unsafe { compare_str_within_nochk(section, i.source, sect.name_start, sect.name_end) } == 0 {
			return Properties{
				ini: i
				props: sect.props
			}
		}
	}
	return none
}

pub fn (s &Properties) is_valid() bool {
	return s.idx != s.props.len
}

pub fn (mut s Properties) next() bool {
	if s.idx == s.props.len {
		return false
	}
	s.idx++
	return true
}

pub fn (s &Properties) name() string {
	prop := s.props[s.idx]
	return s.ini.source[prop.name_start..prop.name_end]
}

pub fn (s &Properties) val() string {
	prop := s.props[s.idx]
	return s.ini.source[prop.val_start..prop.val_end]
}

pub fn (s &Properties) name_and_val() (string, string) {
	prop := s.props[s.idx]
	return s.ini.source[prop.name_start..prop.name_end], s.ini.source[prop.val_start..prop.val_end]
}

fn (i &ReadableIni) get_sect_props(section string) ?voidptr {
	for sect in i.sections {
		if unsafe { compare_str_within_nochk(section, i.source, sect.name_start, sect.name_end) } == 0 {
			props := unsafe { &sect.props }
			return props
		}
	}
	return none
}

[inline]
fn (i &ReadableIni) get_props_len(props voidptr) int {
	props_arr := &[]Property(props)
	return props_arr.len
}

[inline]
fn (i &ReadableIni) get_prop_name(props voidptr, idx int) string {
	props_arr := &[]Property(props)
	prop := unsafe { props_arr[idx] }
	return i.source[prop.name_start..prop.name_end]
}

fn (i &ReadableIni) get_prop_val(props voidptr, name string) ?string {
	for prop in &[]Property(props) {
		if unsafe { compare_str_within_nochk(name, i.source, prop.name_start, prop.name_end) } == 0 {
			return i.source[prop.val_start..prop.val_end]
		}
	}
	return none
}
