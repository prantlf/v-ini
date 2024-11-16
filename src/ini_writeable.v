module ini

@[heap; noinit]
pub struct WriteableIni {
pub mut:
	globals  map[string]string
	sections map[string]map[string]string
}

pub fn WriteableIni.from_globals_map(globals map[string]string) &WriteableIni {
	return WriteableIni.from_both_maps(globals, map[string]map[string]string{})
}

pub fn WriteableIni.from_sections_map(sections map[string]map[string]string) &WriteableIni {
	return WriteableIni.from_both_maps(map[string]string{}, sections)
}

pub fn WriteableIni.from_both_maps(globals map[string]string, sections map[string]map[string]string) &WriteableIni {
	return &WriteableIni{
		globals:  globals
		sections: sections
	}
}

pub fn (i &WriteableIni) globals_len() int {
	return i.globals.len
}

pub fn (i &WriteableIni) global_val(name string) ?string {
	for prop, val in i.globals {
		if name == prop {
			return val
		}
	}
	return none
}

pub fn (i &WriteableIni) sections_len() int {
	return i.sections.len
}

pub fn (i &WriteableIni) section_val(section string, name string) ?string {
	for sect, props in i.sections {
		if section == sect {
			for prop, val in props {
				if name == prop {
					return val
				}
			}
			break
		}
	}
	return none
}

struct PropsData {
	props map[string]string
	keys  []string
}

fn (i &WriteableIni) get_sect_props(section string) ?voidptr {
	if sect := i.sections[section] {
		props_data := &PropsData{
			props: sect
			keys:  sect.keys()
		}
		return props_data
	}
	return none
}

@[inline]
fn (i &WriteableIni) get_props_len(props voidptr) int {
	props_data := unsafe { &PropsData(props) }
	return props_data.props.len
}

@[inline]
fn (i &WriteableIni) get_prop_name(props voidptr, idx int) string {
	props_data := unsafe { &PropsData(props) }
	return props_data.keys[idx]
}

fn (i &WriteableIni) get_prop_val(props voidptr, name string) ?string {
	props_data := unsafe { &PropsData(props) }
	return if val := props_data.props[name] {
		val
	} else {
		return none
	}
}
