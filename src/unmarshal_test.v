module ini

struct Empty {}

fn test_unmarshal_empty() {
	mut e := unmarshal[Empty]('')!
	unmarshal_to[Empty]('', mut e)!
}

struct Answer {
	answer string
}

fn test_unmarshal_global() {
	mut a := unmarshal[Answer]('answer=42')!
	assert a.answer == '42'
	a = Answer{}
	unmarshal_to[Answer]('answer=42', mut a)!
	assert a.answer == '42'
}
