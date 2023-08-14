module ini

fn test_parse_empty() {
	ini := WriteableIni.parse('')!
	assert ini.globals.len == 0
	assert ini.sections.len == 0
}

fn test_parse_global_property() {
	ini := WriteableIni.parse('answer=42')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == '42'
	assert ini.sections.len == 0
}

fn test_parse_global_property_with_whitespace() {
	ini := WriteableIni.parse(' answer = 42 ')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == '42'
	assert ini.sections.len == 0
}

fn test_parse_global_property_with_comments() {
	ini := WriteableIni.parse(';
answer = 42
;')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == '42'
	assert ini.sections.len == 0
}

fn test_parse_two_global_properties() {
	ini := WriteableIni.parse('answer=42
question=unknown')!
	assert ini.globals.len == 2
	assert ini.globals['answer'] == '42'
	assert ini.globals['question'] == 'unknown'
	assert ini.sections.len == 0
}

fn test_parse_empty_section() {
	ini := WriteableIni.parse('[test]')!
	assert ini.globals.len == 0
	assert ini.sections.len == 0
}

fn test_parse_two_empty_sections() {
	ini := WriteableIni.parse('[test1]
[test2]')!
	assert ini.globals.len == 0
	assert ini.sections.len == 0
}

fn test_parse_section_with_property() {
	ini := WriteableIni.parse('[test]
answer=42')!
	assert ini.globals.len == 0
	assert ini.sections.len == 1
	assert 'test' in ini.sections
	assert ini.sections['test'].len == 1
	assert ini.sections['test']['answer'] == '42'
}

fn test_parse_section_with_whitespace_and_property() {
	ini := WriteableIni.parse(' [ test ] 
answer=42')!
	assert ini.globals.len == 0
	assert ini.sections.len == 1
	assert 'test' in ini.sections
	assert ini.sections['test'].len == 1
	assert ini.sections['test']['answer'] == '42'
}

fn test_parse_global_and_section() {
	ini := WriteableIni.parse('question=unknown
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
	ini := WriteableIni.parse('answer=')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ''
	assert ini.sections.len == 0
}

fn test_parse_whitespace_value() {
	ini := WriteableIni.parse('answer= ')!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ''
	assert ini.sections.len == 0
}

fn test_parse_preserving_whitespace() {
	ini := WriteableIni.parse_opt('answer= ', &ParseOpts{ preserve_whitespace: true })!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ' '
	assert ini.sections.len == 0
}

fn test_parse_preserving_whitespace_around() {
	ini := WriteableIni.parse_opt('answer= 42 ', &ParseOpts{ preserve_whitespace: true })!
	assert ini.globals.len == 1
	assert ini.globals['answer'] == ' 42 '
	assert ini.sections.len == 0
}
