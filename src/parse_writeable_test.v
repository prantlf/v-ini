module ini

fn test_parse_empty() {
	ini := parse_writeable('')!
	assert ini.globals.len == 0
	assert ini.sections.len == 0
}

fn test_parse_global_property() {
	ini := parse_writeable('answer=42')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == '42'
	assert ini.sections.len == 0
}

fn test_parse_global_property_with_whitespace() {
	ini := parse_writeable(' answer = 42 ')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == '42'
	assert ini.sections.len == 0
}

fn test_parse_global_property_with_comments() {
	ini := parse_writeable(';
answer = 42
;')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == '42'
	assert ini.sections.len == 0
}

fn test_parse_two_global_properties() {
	ini := parse_writeable('answer=42
question=unknown')!
	assert ini.globals.len == 2
	assert ini.globals['answer'] == '42'
	assert ini.globals['question'] == 'unknown'
	assert ini.sections.len == 0
}

fn test_parse_empty_section() {
	ini := parse_writeable('[test]')!
	assert ini.globals.len == 0
	assert ini.sections.len == 0
}

fn test_parse_two_empty_sections() {
	ini := parse_writeable('[test1]
[test2]')!
	assert ini.globals.len == 0
	assert ini.sections.len == 0
}

fn test_parse_section_with_property() {
	ini := parse_writeable('[test]
answer=42')!
	assert ini.globals.len == 0
	assert ini.sections.len == 1
	assert 'test' in ini.sections
	assert ini.sections['test'].len == 1
	assert ini.sections['test']['answer'] == '42'
}

fn test_parse_section_with_whitespace_and_property() {
	ini := parse_writeable(' [ test ] 
answer=42')!
	assert ini.globals.len == 0
	assert ini.sections.len == 1
	assert 'test' in ini.sections
	assert ini.sections['test'].len == 1
	assert ini.sections['test']['answer'] == '42'
}

fn test_parse_global_and_section() {
	ini := parse_writeable('question=unknown
[test]
answer=42')!
	assert ini.globals.len == 1
	assert ini.globals['question'] == 'unknown'
	assert ini.sections.len == 1
	assert 'test' in ini.sections
	assert ini.sections['test'].len == 1
	assert ini.sections['test']['answer'] == '42'
}

fn test_parse_empty_value() {
	ini := parse_writeable('answer=')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ''
	assert ini.sections.len == 0
}

fn test_parse_whitespace_value() {
	ini := parse_writeable('answer= ')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ''
	assert ini.sections.len == 0
}

fn test_parse_preserving_whitespace() {
	ini := parse_writeable_opt('answer= ', &ParseOpts{ preserve_whitespace: true })!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ' '
	assert ini.sections.len == 0
}

fn test_parse_preserving_whitespace_around() {
	ini := parse_writeable_opt('answer= 42 ', &ParseOpts{ preserve_whitespace: true })!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ' 42 '
	assert ini.sections.len == 0
}
