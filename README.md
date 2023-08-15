# JSON Parser and Formatter

Strictly parse and format INI file contents.

Although reading configuration is usually not the time-critical part of the application, sometimes it may be so. For example, when many localisation texts are stored in INI files, loading them may take longer. This package attempts to process INI file contents as fast as possible, while focusing on the [original INI file format].

* Uses a [fast](bench/README.md) recursive descent parser written in V.
* Shows detailed [error messages](#errors) with location context.
* Focuses on the [original INI file format].
* Supports access both by a map and by a statically typed struct.

See also the [INI file grammar].

## Synopsis

```go
import prantlf.ini { parse_readable, unmarshal, decode }

ini := parse_readable('answer=42')!
assert ini.global_val('answer')? == '42'

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

The following types, functions and methods are exported:

### Types

    struct ParseOpts {
      preserve_whitespace bool
    }

    struct DecodeOpts {
      require_all_fields     bool
      forbid_extra_keys      bool
      ignore_number_overflow bool
      preserve_whitespace    bool
    }

    struct UnmarshalOpts {
      require_all_fields     bool
      forbid_extra_keys      bool
      ignore_number_overflow bool
      preserve_whitespace    bool
    }

    struct ParseError {
      reason string
      offset int
      line   int
      column int
    }

    struct ReadableIni {}

    struct WriteableIni {}

    struct Sections {}

    struct Properties {}

### Functinos

    ReadableIni.from_globals_map(globals map[string]string) &ReadableIni
    ReadableIni.from_sections_map(sections map[string]map[string]string) &ReadableIni
    ReadableIni.from_both_maps(globals map[string]string, sections map[string]map[string]string) &ReadableIni

    WriteableIni.from_globals_map(globals map[string]string) &WriteableIni
    WriteableIni.from_sections_map(sections map[string]map[string]string) &WriteableIni
    WriteableIni.from_both_maps(globals map[string]string, sections map[string]map[string]string) &WriteableIni

    parse_readable(source string) !&ReadableIni
    parse_readable_opt(source string, opts &ParseOpts) !&ReadableIni

    parse_writeable(source string) !&WriteableIni
    parse_writeable_opt(source string, opts &ParseOpts) !&WriteableIni
    parse_writeable_to(source string, mut ini WriteableIni) !
    parse_writeable_to_opt(source string, mut ini WriteableIni, opts &ParseOpts) !

    decode[T, I](ini &I) !T
    decode_opt[T, I](ini &I, opts &DecodeOpts) !T
    decode_to[T, I](ini &I, mut obj T) !
    decode_to_opt[T, I](ini &I, mut obj T, opts &DecodeOpts) !

    decode_readable[T](ini &ReadableIni) !T
    decode_readable_opt[T](ini &ReadableIni, opts &DecodeOpts) !T
    decode_readable_to[T](ini &ReadableIni, mut obj T) !
    decode_readable_to_opt[T](ini &ReadableIni, mut obj T, opts &DecodeOpts) !

    decode_writeable[T](ini &WriteableIni) !T
    decode_writeable_opt[T](ini &WriteableIni, opts &DecodeOpts) !T
    decode_writeable_to[T](ini &WriteableIni, mut obj T) !
    decode_writeable_to_opt[T](ini &WriteableIni, mut obj T, opts &DecodeOpts) !

    unmarshal[T](source string) !T
    unmarshal_opt[T](source string, opts &UnmarshalOpts) !T
    unmarshal_to[T](source string, mut obj T) !
    unmarshal_to_opt[T](source string, mut obj T, opts &UnmarshalOpts) !

### Methods

    (i &ReadableIni) globals_len() int
    (i &ReadableIni) global_names() []string
    (i &ReadableIni) has_global_val(name string) bool
    (i &ReadableIni) global_val(name string) ?string
    (i &ReadableIni) globals(section string) Properties

    (i &ReadableIni) sections_len() int
    (i &ReadableIni) section_names() []string
    (i &ReadableIni) has_section(section string) bool
    (i &ReadableIni) section_props_len(section string) ?int
    (i &ReadableIni) section_prop_names(name string) ?[]string
    (i &ReadableIni) has_section_prop(section string, name string) bool
    (i &ReadableIni) section_prop_val(section string, name string) ?string
    (i &ReadableIni) section_props(section string) ?Properties
    (i &ReadableIni) sections() Sections

    (s &Sections) is_valid() bool
    (mut s Sections) next() bool
    (s &Sections) name() string
    (s &Sections) len() int
    (s &Sections) has(name string) bool
    (s &Sections) prop_names(name string) []string
    (s &Sections) prop_val(name string) ?string
    (s &Sections) props() Properties

    (s &Properties) is_valid() bool
    (mut s Properties) next() bool
    (s &Properties) name() string
    (s &Properties) val() string
    (s &Properties) name_and_val() (string, string)

    (i &WriteableIni) globals_len() int
    (i &WriteableIni) global_val(name string) ?string

    (i &WriteableIni) sections_len() int
    (i &WriteableIni) section_val(section string, name string) ?string

## Errors

For example, the following code:

```go
parse('answer', ParseOpts{})
```

will fail with the following message:

    unexpected end encountered when parsing a property name on line 1, column 7:
    1 | answer
      |       ^

The message is formatted using the error fields, for example:

    ParseError {
      reason  string = 'unexpected end encountered when parsing a property name'
      offset  int    = 7
      line    int    = 1
      column  int    = 7
    }

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023 Ferdinand Prantl

Licensed under the MIT license.

[VPM]: https://vpm.vlang.io/packages/prantlf.ini
[original INI file format]: https://en.wikipedia.org/wiki/INI_file#Example
[INI file grammar]: ./doc/grammar.md#ini-file-grammar
