module ini

struct Empty {}

fn test_decode_empty() {
	mut e := unmarshal[Empty]('')!
	unmarshal_to[Empty]('', mut e)!
}
