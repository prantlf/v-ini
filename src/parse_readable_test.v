module ini

fn test_parse_empty() {
	ini := parse_readable('')!
	assert ini.globals_len() == 0
	assert ini.sections_len() == 0
}

fn test_parse_global_property() {
	ini := parse_readable('answer=42')!
	assert ini.globals_len() == 1
	assert ini.global_val('answer')? == '42'
	assert ini.sections_len() == 0
}

fn test_parse_global_property_with_whitespace() {
	ini := parse_readable(' answer = 42 ')!
	assert ini.globals_len() == 1
	assert ini.global_val('answer')? == '42'
	assert ini.sections_len() == 0
}

fn test_parse_global_property_with_comments() {
	ini := parse_readable(';
answer = 42
;')!
	assert ini.globals_len() == 1
	assert ini.global_val('answer')? == '42'
	assert ini.sections_len() == 0
}

fn test_parse_two_global_properties() {
	ini := parse_readable('answer=42
question=unknown')!
	assert ini.globals_len() == 2
	assert ini.global_val('answer')? == '42'
	assert ini.global_val('question')? == 'unknown'
	assert ini.sections_len() == 0
}

fn test_parse_empty_section() {
	ini := parse_readable('[test]')!
	assert ini.globals_len() == 0
	assert ini.sections_len() == 1
	assert ini.section_props_len('test')? == 0
}

fn test_parse_two_empty_sections() {
	ini := parse_readable('[test1]
[test2]')!
	assert ini.globals_len() == 0
	assert ini.sections_len() == 2
	assert ini.section_props_len('test1')? == 0
	assert ini.section_props_len('test2')? == 0
}

fn test_parse_section_with_property() {
	ini := parse_readable('[test]
answer=42')!
	assert ini.globals_len() == 0
	assert ini.sections_len() == 1
	assert ini.section_props_len('test')? == 1
	assert ini.section_prop_val('test', 'answer')? == '42'
}

fn test_parse_section_with_whitespace_and_property() {
	ini := parse_readable(' [ test ] 
answer=42')!
	assert ini.globals_len() == 0
	assert ini.sections_len() == 1
	assert ini.section_props_len('test')? == 1
	assert ini.section_prop_val('test', 'answer')? == '42'
}

fn test_parse_global_and_section() {
	ini := parse_readable('question=unknown
[test]
answer=42')!
	assert ini.globals_len() == 1
	assert ini.global_val('question')? == 'unknown'
	assert ini.sections_len() == 1
	assert ini.section_props_len('test')? == 1
	assert ini.section_prop_val('test', 'answer')? == '42'
}

fn test_parse_empty_val() {
	ini := parse_readable('answer=')!
	assert ini.globals_len() == 1
	assert ini.global_val('answer')? == ''
	assert ini.sections_len() == 0
}

fn test_parse_whitespace_val() {
	ini := parse_readable('answer= ')!
	assert ini.globals_len() == 1
	assert ini.global_val('answer')? == ''
	assert ini.sections_len() == 0
}

fn test_parse_preserving_whitespace() {
	ini := parse_readable_opt('answer= ', &ParseOpts{ preserve_whitespace: true })!
	assert ini.globals_len() == 1
	assert ini.global_val('answer')? == ' '
	assert ini.sections_len() == 0
}

fn test_parse_preserving_whitespace_around() {
	ini := parse_readable_opt('answer= 42 ', &ParseOpts{ preserve_whitespace: true })!
	assert ini.globals_len() == 1
	assert ini.global_val('answer')? == ' 42 '
	assert ini.sections_len() == 0
}
