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

struct Opts {
	tag_prefix   string @[json: 'tag-prefix']
	body_re      string @[json: 'body-re']
	version_re   string
	prolog       string
	version_tpl  string
	logged_types []string          = ['feat', 'fix', 'perf']          @[json: 'logged-types'; split]
	type_mapping map[string]string = {} @[json: 'type-mapping']
	type_titles  map[string]string = {
		'feat':            'Features'
		'fix':             'Bug Fixes'
		'perf':            'Performance Improvements'
		'refactor':        'Refactoring'
		'docs':            'Documentation'
		'style':           'Source Code Styling'
		'build':           'Build Configuration'
		'chore':           'Chores'
		'BREAKING_CHANGE': 'BREAKING CHANGES'
	} @[json: 'type-titles']
mut:
	heading int
}

fn test_unmarshal_opts() {
	input := r'heading=1
tag-prefix=v

subject-re=^(?<description>.+)\s*\((?<type>[^ ]+(?:\s+[^ ]+)?)\s+#(?<issue>\d+)\)$
version-re=^(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)|(?:\[(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\])).+(?:-[.0-9A-Za-z-]+)?$

prolog = # Changes
version-tpl = {heading} [{version}]({repo_url}/compare/{tag_prefix}{prev_version}...{tag_prefix}{version}) ({date})
commit-tpl = * {description} ([{short_hash}]({repo_url}/commit/{hash}) resolved [{issue}](https://jira.opentext.com/browse/{issue}))

[type-mapping]
defect = fix
feature = feat
'
	mut opts := unmarshal[Opts](input)!
	assert opts.heading == 1
	assert opts.tag_prefix == 'v'
	assert opts.type_mapping['defect'] == 'fix'
	assert opts.type_titles['feat'] == 'Features'
}
