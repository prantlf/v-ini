module ini

fn test_parse_empty() {
	i := parse_writeable('')!
	assert i.globals.len == 0
	assert i.sections.len == 0
}

fn test_parse_global_property() {
	i := parse_writeable('answer=42')!
	assert i.globals.len == 1
	assert i.globals['answer'] == '42'
	assert i.sections.len == 0
}

fn test_parse_global_property_with_whitespace() {
	i := parse_writeable(' answer = 42 ')!
	assert i.globals.len == 1
	assert i.globals['answer'] == '42'
	assert i.sections.len == 0
}

fn test_parse_global_property_with_whitespace_in_name() {
	i := parse_writeable('another answer = 42')!
	assert i.globals_len() == 1
	assert i.global_val('another answer')? == '42'
	assert i.sections_len() == 0
}

fn test_parse_global_property_with_comments() {
	i := parse_writeable(';
answer = 42
;')!
	assert i.globals.len == 1
	assert i.globals['answer'] == '42'
	assert i.sections.len == 0
}

fn test_parse_two_global_properties() {
	i := parse_writeable('answer=42
question=unknown')!
	assert i.globals.len == 2
	assert i.globals['answer'] == '42'
	assert i.globals['question'] == 'unknown'
	assert i.sections.len == 0
}

fn test_parse_empty_section() {
	i := parse_writeable('[test]')!
	assert i.globals.len == 0
	assert i.sections.len == 0
}

fn test_parse_two_empty_sections() {
	i := parse_writeable('[test1]
[test2]')!
	assert i.globals.len == 0
	assert i.sections.len == 0
}

fn test_parse_section_with_property() {
	i := parse_writeable('[test]
answer=42')!
	assert i.globals.len == 0
	assert i.sections.len == 1
	assert 'test' in i.sections
	assert i.sections['test'].len == 1
	assert i.sections['test']['answer'] == '42'
}

fn test_parse_section_with_whitespace_and_property() {
	i := parse_writeable(' [ test ] 
answer=42')!
	assert i.globals.len == 0
	assert i.sections.len == 1
	assert 'test' in i.sections
	assert i.sections['test'].len == 1
	assert i.sections['test']['answer'] == '42'
}

fn test_parse_global_and_section() {
	i := parse_writeable('question=unknown
[test]
answer=42')!
	assert i.globals.len == 1
	assert i.globals['question'] == 'unknown'
	assert i.sections.len == 1
	assert 'test' in i.sections
	assert i.sections['test'].len == 1
	assert i.sections['test']['answer'] == '42'
}

fn test_parse_empty_value() {
	i := parse_writeable('answer=')!
	assert i.globals.len == 1
	assert i.globals['answer'] == ''
	assert i.sections.len == 0
}

fn test_parse_whitespace_value() {
	i := parse_writeable('answer= ')!
	assert i.globals.len == 1
	assert i.globals['answer'] == ''
	assert i.sections.len == 0
}

fn test_parse_preserving_whitespace() {
	i := parse_writeable_opt('answer= ', &ParseOpts{ preserve_whitespace: true })!
	assert i.globals.len == 1
	assert i.globals['answer'] == ' '
	assert i.sections.len == 0
}

fn test_parse_preserving_whitespace_around() {
	i := parse_writeable_opt('answer= 42 ', &ParseOpts{ preserve_whitespace: true })!
	assert i.globals.len == 1
	assert i.globals['answer'] == ' 42 '
	assert i.sections.len == 0
}
