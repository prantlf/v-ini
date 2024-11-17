module ini

fn test_parse_empty() {
	i := parse_readable('')!
	assert i.globals_len() == 0
	assert i.sections_len() == 0
}

fn test_parse_global_property() {
	i := parse_readable('answer=42')!
	assert i.str() == 'answer=42'
	assert i.globals_len() == 1
	assert i.global_val('answer')? == '42'
	assert i.sections_len() == 0
}

fn test_parse_global_property_with_whitespace() {
	i := parse_readable(' answer = 42 ')!
	assert i.globals_len() == 1
	assert i.global_val('answer')? == '42'
	assert i.sections_len() == 0
}

fn test_parse_global_property_with_whitespace_in_name() {
	i := parse_readable('another answer = 42')!
	assert i.globals_len() == 1
	assert i.global_val('another answer')? == '42'
	assert i.sections_len() == 0
}

fn test_parse_global_property_with_comments() {
	i := parse_readable(';
answer = 42
;')!
	assert i.globals_len() == 1
	assert i.global_val('answer')? == '42'
	assert i.sections_len() == 0
}

fn test_parse_two_global_properties() {
	i := parse_readable('answer=42
question=unknown')!
	assert i.globals_len() == 2
	assert i.global_val('answer')? == '42'
	assert i.global_val('question')? == 'unknown'
	assert i.sections_len() == 0
}

fn test_parse_empty_section() {
	i := parse_readable('[test]')!
	assert i.globals_len() == 0
	assert i.sections_len() == 1
	assert i.section_props_len('test')? == 0
}

fn test_parse_two_empty_sections() {
	i := parse_readable('[test1]
[test2]')!
	assert i.globals_len() == 0
	assert i.sections_len() == 2
	assert i.section_props_len('test1')? == 0
	assert i.section_props_len('test2')? == 0
}

fn test_parse_section_with_property() {
	i := parse_readable('[test]
answer=42')!
	assert i.globals_len() == 0
	assert i.sections_len() == 1
	assert i.section_props_len('test')? == 1
	assert i.section_prop_val('test', 'answer')? == '42'
}

fn test_parse_section_with_whitespace_in_name() {
	i := parse_readable('[more test]
answer=42')!
	assert i.globals_len() == 0
	assert i.sections_len() == 1
	assert i.section_props_len('more test')? == 1
	assert i.section_prop_val('more test', 'answer')? == '42'
}

fn test_parse_section_with_whitespace_and_property() {
	i := parse_readable(' [ test ] 
answer=42')!
	assert i.globals_len() == 0
	assert i.sections_len() == 1
	assert i.section_props_len('test')? == 1
	assert i.section_prop_val('test', 'answer')? == '42'
}

fn test_parse_global_and_section() {
	i := parse_readable('question=unknown
[test]
answer=42')!
	assert i.globals_len() == 1
	assert i.global_val('question')? == 'unknown'
	assert i.sections_len() == 1
	assert i.section_props_len('test')? == 1
	assert i.section_prop_val('test', 'answer')? == '42'
}

fn test_parse_empty_val() {
	i := parse_readable('answer=')!
	assert i.globals_len() == 1
	assert i.global_val('answer')? == ''
	assert i.sections_len() == 0
}

fn test_parse_whitespace_val() {
	i := parse_readable('answer= ')!
	assert i.globals_len() == 1
	assert i.global_val('answer')? == ''
	assert i.sections_len() == 0
}

fn test_parse_preserving_whitespace() {
	i := parse_readable_opt('answer= ', &ParseOpts{ preserve_whitespace: true })!
	assert i.globals_len() == 1
	assert i.global_val('answer')? == ' '
	assert i.sections_len() == 0
}

fn test_parse_preserving_whitespace_around() {
	i := parse_readable_opt('answer= 42 ', &ParseOpts{ preserve_whitespace: true })!
	assert i.globals_len() == 1
	assert i.global_val('answer')? == ' 42 '
	assert i.sections_len() == 0
}
