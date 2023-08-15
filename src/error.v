module ini

import os
import strings
import term

[noinit]
pub struct ParseError {
	Error
	head_context string
	head_error   string
	tail_error   string
	tail_context string
pub:
	reason string
	offset int
	line   int
	column int
}

pub fn (e &ParseError) msg() string {
	return '${e.reason} on line ${e.line}, column ${e.column}'
}

pub fn (e &ParseError) msg_full() string {
	before := (e.head_context + e.head_error + e.tail_error).split_into_lines()
	after := e.tail_context.split_into_lines()

	last_line := e.line - 1 + before.len + after.len
	num_len := last_line.str().len + 1

	mut builder := strings.new_builder(64)
	mut line_num := e.line - before.len

	colors := term.can_show_color_on_stderr() && os.getenv('NO_COLOR').len == 0
	mut on := ''
	mut off := ''
	if colors {
		on = '\033[1m'
		off = '\033[0m'
	}

	line_num = write_context(mut builder, before, line_num, num_len, false, colors)
	write_pointer(mut builder, num_len, e.head_error.len, colors)
	write_context(mut builder, after, line_num, num_len, true, colors)

	return '${on}${e.reason}${off}:\n${builder.str()}'
}

fn write_context(mut builder strings.Builder, lines []string, start_line int, num_len int, eol_before bool, colors bool) int {
	mut on := ''
	mut off := ''
	if colors {
		on = '\033[1m\033[37m'
		off = '\033[0m'
	}

	mut line_num := start_line
	builder.write_string(on)
	if lines.len == 0 && !eol_before {
		builder.write_string(' 1 |\n')
	}
	for line in lines {
		if eol_before {
			builder.write_u8(`\n`)
		}
		line_num++
		num_str := line_num.str()
		for i := num_str.len; i < num_len; i++ {
			builder.write_u8(` `)
		}
		builder.write_string(num_str)
		builder.write_string(' | ')
		builder.write_string(line)
		if !eol_before {
			builder.write_u8(`\n`)
		}
	}
	builder.write_string(off)
	return line_num
}

fn write_pointer(mut builder strings.Builder, num_len int, head_len int, colors bool) {
	mut on1 := ''
	mut on2 := ''
	mut off := ''
	if colors {
		on1 = '\033[1m\033[37m'
		on2 = '\033[31m' // \033[32m
		off = '\033[0m'
	}

	for i := 0; i < num_len + 1; i++ {
		builder.write_u8(` `)
	}
	builder.write_string('${on1}|')
	for i := 0; i < head_len + 1; i++ {
		builder.write_u8(` `)
	}
	builder.write_string('${on2}^${off}')
}

fn before_error(input string, offset int) (string, string) {
	if input.len == 0 {
		return '', ''
	}

	mut inline := if offset > 30 {
		'…' + input[offset - 30..offset]
	} else {
		input[..offset]
	}

	mut head := ''
	eol := inline.last_index_u8(`\n`) + 1
	if eol > 0 {
		head = inline[..eol]
		inline = inline[eol..]
	}

	return head, inline
}

fn after_error(input string, offset int) (string, string) {
	if input.len == 0 {
		return '', ''
	}

	mut inline := if offset + 30 < input.len {
		input[offset..offset + 30] + '…'
	} else {
		input[offset..]
	}

	mut tail := ''
	eol := inline.index_u8(`\n`)
	if eol >= 0 {
		tail = inline[eol + 1..]
		inline = inline[..eol]
	}

	return inline, tail
}
