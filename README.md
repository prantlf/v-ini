# INI Parser and Formatter

Strictly parse and format INI file contents.

Although reading configuration is usually not the time-critical part of the application, sometimes it may be so. For example, when many localisation texts are stored in INI files, loading them may take longer. This package attempts to process INI file contents as fast as possible, while focusing on the [original INI file format].

* Uses a [fast](bench/README.md) recursive descent parser written in V.
* Shows detailed [error messages](#errors) with location context.
* Focuses on the [original INI file format].
* Supports access both by a map and by a statically typed struct.

See also the [INI file grammar].

## Synopsis

```go
import prantlf.ini { parse_readable, unmarshal }

ini := parse_readable('answer=42
; the rest is unknown
[rest]
question=unknown')!
assert ini.global_val('answer')? == '42'
assert ini.section_prop_val('rest', 'question')? == 'unknown'

struct Cfg {
  answer int
}

cfg := unmarshal[Cfg]('answer=42')!
assert cfg.answer == 42
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.ini
v install --git https://github.com/prantlf/v-ini
```

## API

The API is divided to to three parts - functions around `ReadableIni` optimised for read-only access, functions around `WriteableIni` allowing changes in memory after parsing and marshalling/unmarshalling that works with strings and structures.

### Read-Only Access

Parse the contents of an ini-file to a `ReadableIni` object:

```go
parse_readable(source string) !&ReadableIni

struct ParseOpts {
  preserve_whitespace bool
}

parse_readable_opt(source string, opts &ParseOpts) !&ReadableIni
```

Decode the contents of a `ReadableIni` object to a custom structure, either by creating a new instance or by setting fields of an existing one:

```go
decode_readable[T](ini &ReadableIni) !T
decode_readable_to[T](ini &ReadableIni, mut obj T) !

struct DecodeOpts {
  require_all_fields     bool
  forbid_extra_keys      bool
  ignore_number_overflow bool
  preserve_whitespace    bool
}

decode_readable_opt[T](ini &ReadableIni, opts &DecodeOpts) !T
decode_readable_to_opt[T](ini &ReadableIni, mut obj T, opts &DecodeOpts) !
```

Unmarshal the contents of an ini-file to a custom structure, either by creating a new instance or by setting fields of an existing one:

```go
unmarshal[T](source string) !T
unmarshal_to[T](source string, mut obj T) !

struct UnmarshalOpts {
  DecodeOpts
}

unmarshal_opt[T](source string, opts &UnmarshalOpts) !T
unmarshal_to_opt[T](source string, mut obj T, opts &UnmarshalOpts) !
```

Convert a string map to a `ReadableIni` object:

```go
ReadableIni.from_globals_map(globals map[string]string) &ReadableIni
ReadableIni.from_sections_map(sections map[string]map[string]string) &ReadableIni
ReadableIni.from_both_maps(globals map[string]string, sections map[string]map[string]string) &ReadableIni
```

Global properties can be inspected by the following methods:

```go
(i &ReadableIni) globals_len() int
(i &ReadableIni) global_names() []string
(i &ReadableIni) has_global_val(name string) bool
(i &ReadableIni) global_val(name string) ?string
```

Sections and section properties can be inspected by the following methods:

```go
(i &ReadableIni) sections_len() int
(i &ReadableIni) section_names() []string
(i &ReadableIni) has_section(section string) bool
(i &ReadableIni) section_props_len(section string) ?int
(i &ReadableIni) section_prop_names(name string) ?[]string
(i &ReadableIni) has_section_prop(section string, name string) bool
(i &ReadableIni) section_prop_val(section string, name string) ?string
```

Global properties, sections and section properties can be inspected by iterators too:

```go
(i &ReadableIni) globals(section string) Properties

  (s &Properties) is_valid() bool
  (mut s Properties) next() bool
  (s &Properties) name() string
  (s &Properties) val() string
  (s &Properties) name_and_val() (string, string)

(i &ReadableIni) sections() Sections
(i &ReadableIni) section_props(section string) ?Properties

  (s &Sections) is_valid() bool
  (mut s Sections) next() bool
  (s &Sections) name() string
  (s &Sections) len() int
  (s &Sections) has(name string) bool
  (s &Sections) prop_names(name string) []string
  (s &Sections) prop_val(name string) ?string
  (s &Sections) props() Properties
```

### Write Access

Parse the contents of an ini-file to a `WriteableIni` object:

```go
parse_writeable(source string) !&WriteableIni
parse_writeable_to(source string, mut ini WriteableIni) !

struct ParseOpts {
  preserve_whitespace bool
}

parse_writeable_opt(source string, opts &ParseOpts) !&WriteableIni
parse_writeable_to_opt(source string, mut ini WriteableIni, opts &ParseOpts) !
```

Decode the contents of a `WriteableIni` object to a custom structure, either by creating a new instance or by setting fields of an existing one:

```go
decode_writeable[T](ini &WriteableIni) !T
decode_writeable_to[T](ini &WriteableIni, mut obj T) !

struct DecodeOpts {
  require_all_fields     bool
  forbid_extra_keys      bool
  ignore_number_overflow bool
  preserve_whitespace    bool
}

decode_writeable_opt[T](ini &WriteableIni, opts &DecodeOpts) !T
decode_writeable_to_opt[T](ini &WriteableIni, mut obj T, opts &DecodeOpts) !
```

Convert a string map to a `WriteableIni` object:

```go
WriteableIni.from_globals_map(globals map[string]string) &WriteableIni
WriteableIni.from_sections_map(sections map[string]map[string]string) &WriteableIni
WriteableIni.from_both_maps(globals map[string]string, sections map[string]map[string]string) &WriteableIni
```

Global properties can be inspected by the following methods and properties:

```go
(i &WriteableIni) globals_len() int
(i &WriteableIni) global_val(name string) ?string

(i &WriteableIni) globals map[string]string
```

Sections and section properties can be inspected by the following methods and properties:

```go
(i &WriteableIni) sections_len() int
(i &WriteableIni) section_val(section string, name string) ?string

(i &WriteableIni) sections map[string]map[string]string
```

### Saving

Marshal the contents of an object to a string:

```go
struct MarshalOpts {
	enums_as_names bool = true
}

fn marshal[T](source &T) !string
fn marshal_opt[T](source &T, opts &MarshalOpts) !string
fn marshal_to[T](source &T, mut builder Builder) !
fn marshal_to_opt[T](source &T, mut builder Builder, opts &MarshalOpts) !
```

### Errors

If parsing the ini-file contents fails because of an invalid syntax, the following error will be returned:

```go
struct ParseError {
  reason string
  offset int
  line   int
  column int
}

(e &ParseError) msg() string
(e &ParseError) msg_full() string
```

For example, parsing the following contents:

    answer=42
    question

will return the following short message by `msg()`:

    unexpected end encountered when parsing a property name on line 2, column 9

and the following long and colourful message by `msg_full()`:

		unexpected end encountered when parsing a property name:
     1 | answer=42
     2 | question
       |         ^

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023-2025 Ferdinand Prantl

Licensed under the MIT license.

[VPM]: https://vpm.vlang.io/packages/prantlf.ini
[original INI file format]: https://en.wikipedia.org/wiki/INI_file#Example
[INI file grammar]: ./doc/grammar.md#ini-file-grammar
