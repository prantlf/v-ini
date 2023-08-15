module ini

fn test_parse_end_before_property_name() {
	parse_writeable('=') or {
		if err is ParseError {
			assert err.msg() == 'unexpected "=" encountered when expecting a property name on line 1, column 1'
			assert err.msg_full() == 'unexpected "=" encountered when expecting a property name:
 1 | =
   | ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_in_property_name() {
	parse_writeable('test') or {
		if err is ParseError {
			assert err.msg() == 'unexpected end encountered when parsing a property name on line 1, column 5'
			assert err.msg_full() == 'unexpected end encountered when parsing a property name:
 1 | test
   |     ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_eoln_in_property_name() {
	parse_writeable('test
') or {
		if err is ParseError {
			assert err.msg() == 'unexpected line break encountered when parsing a property name on line 1, column 5'
			assert err.msg_full() == 'unexpected line break encountered when parsing a property name:
 1 | test
   |     ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_after_property_name_1() {
	parse_writeable('test ') or {
		if err is ParseError {
			assert err.msg() == 'unexpected end encountered after a property name on line 1, column 6'
			assert err.msg_full() == 'unexpected end encountered after a property name:
 1 | test 
   |      ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_after_property_name_2() {
	parse_writeable('test 
') or {
		if err is ParseError {
			assert err.msg() == 'unexpected line break encountered after a property name on line 1, column 6'
			assert err.msg_full() == 'unexpected line break encountered after a property name:
 1 | test 
   |      ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_unexpected_after_property_name() {
	parse_writeable('test *') or {
		if err is ParseError {
			assert err.msg() == 'unexpected "*" encountered when expecting "=" on line 1, column 6'
			assert err.msg_full() == 'unexpected "*" encountered when expecting "=":
 1 | test *
   |      ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_before_section_name_1() {
	parse_writeable('[') or {
		if err is ParseError {
			assert err.msg() == 'unexpected end encountered before a section name on line 1, column 2'
			assert err.msg_full() == 'unexpected end encountered before a section name:
 1 | [
   |  ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_before_section_name_2() {
	parse_writeable('[ ') or {
		if err is ParseError {
			assert err.msg() == 'unexpected end encountered before a section name on line 1, column 3'
			assert err.msg_full() == 'unexpected end encountered before a section name:
 1 | [ 
   |   ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_before_section_name_3() {
	parse_writeable('[
') or {
		if err is ParseError {
			assert err.msg() == 'unexpected line break encountered when parsing a section name on line 1, column 2'
			assert err.msg_full() == 'unexpected line break encountered when parsing a section name:
 1 | [
   |  ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_empty_section_name() {
	parse_writeable('[]') or {
		if err is ParseError {
			assert err.msg() == 'unexpected "]" encountered when expecting a section name on line 1, column 2'
			assert err.msg_full() == 'unexpected "]" encountered when expecting a section name:
 1 | []
   |  ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_whitespace_section_name() {
	parse_writeable('[ ]') or {
		if err is ParseError {
			assert err.msg() == 'unexpected "]" encountered when expecting a section name on line 1, column 3'
			assert err.msg_full() == 'unexpected "]" encountered when expecting a section name:
 1 | [ ]
   |   ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_unfinished_section_name_1() {
	parse_writeable('[test') or {
		if err is ParseError {
			assert err.msg() == 'unexpected end encountered when parsing a section name on line 1, column 6'
			assert err.msg_full() == 'unexpected end encountered when parsing a section name:
 1 | [test
   |      ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_unfinished_section_name_2() {
	parse_writeable('[test 
') or {
		if err is ParseError {
			assert err.msg() == 'unexpected line break encountered after a section name on line 1, column 7'
			assert err.msg_full() == 'unexpected line break encountered after a section name:
 1 | [test 
   |       ^'
		} else {
			assert false
		}
		return
	}
	assert false
}
