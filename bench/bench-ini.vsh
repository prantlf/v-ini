#!/usr/bin/env -S v -prod run

import benchmark { start }
import toml
import prantlf.ini
// import spytheman.vini
// import Cyklan.ini as cini
// import ldedev.ini as lini
// import Sorrow446.vini as sini
import prantlf.json

const repeat_count = 100_000

const repeat_get_count = 1_000_000

const contents_ini = 'answer=42
question=unknown
[context]
description=ultimate'

const contents_toml = 'answer=42
question="unknown"
[context]
description="ultimate"'

const contents_json = '{"answer":42,"question":"unknown","context":{"description":"ultimate"}}'

mut b := start()

for _ in 0 .. repeat_count {
	ini.parse(contents_ini)!
}
b.measure('prantlf.ini')

// for _ in 0 .. repeat_count {
// 	ini.parse2(contents_ini)!
// }
// b.measure('prantlf.ini2')

for _ in 0 .. repeat_count {
	toml.parse_text(contents_toml)!
}
b.measure('toml')

// for _ in 0 .. repeat_count {
// 	mut reader := vini.new_ini_reader(contents_ini)
// 	reader.parse()
// }
// b.measure('spytheman.vini')

// for _ in 0 .. repeat_count {
// 	cini.parse(contents_ini)
// }
// b.measure('Cyklan.ini')

// for _ in 0 .. repeat_count {
// 	lini.parser(contents_ini)
// }
// b.measure('ldedev.ini')

// for _ in 0 .. repeat_count {
// 	sini.parse(contents_ini)
// }
// b.measure('Sorrow446.vini')

for _ in 0 .. repeat_count {
	json.parse(contents_json, json.ParseOpts{})!
}
b.measure('prantlf.json')

// if true {
// 	i := ini.parse(contents_ini)!
// 	d := map[string]string{}
// 	for _ in 0 .. repeat_get_count {
// 		_ := i.globals['dummy'] or { '' }
// 		_ := i.globals['answer']!
// 		_ := i.sections['dummy'] or { d }
// 		_ := i.sections['context']['dummy'] or { '' }
// 		_ := i.sections['context']['description']!
// 	}
// }
// b.measure('prantlf.ini get directly')

if true {
	i := ini.parse(contents_ini)!
	for _ in 0 .. repeat_get_count {
		i.global_val('dummy')
		i.global_val('answer')
		i.section_prop_val('dummy', 'dummy')
		i.section_prop_val('context', 'dummy')
		i.section_prop_val('context', 'description')
	}
}
b.measure('prantlf.ini get methods')

// if true {
// 	i := ini.parse2(contents_ini)!
// 	for _ in 0 .. repeat_get_count {
// 		i.global_val('dummy')
// 		i.global_val('answer')
// 		i.section_prop_val('dummy', 'dummy')
// 		i.section_prop_val('context', 'dummy')
// 		i.section_prop_val('context', 'description')
// 	}
// }
// b.measure('prantlf.ini2 get')
