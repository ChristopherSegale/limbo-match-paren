implement Match_Paren;

include "sys.m";
include "draw.m";
include "bufio.m";
bufio: Bufio;
Iobuf: import bufio;

sys: Sys;

BUFSIZ: con 1024;

DEFAULT, COMMENT, QUOTE, ESCAPE: con iota;

Match_Paren: module
{
	init: fn (nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;

	bufio = load Bufio Bufio->PATH;
	stdin := sys->fildes(0);
	reader := bufio->fopen(stdin, bufio->OREAD);
	buf := array[BUFSIZ] of byte;
	i := 0;
	st := DEFAULT;
	igq := 0;
	pc := 0;

	for(c := reader.getc(); c != Bufio->EOF; c = reader.getc()) {
		if (i > BUFSIZ - 1) {
			sys->print("%s", string buf);
			i = 0;
		}
		buf[i++] = byte c;
		case st {
		QUOTE => 
			if (c == '\\') {
				igq = 1;
			}
			if (c == '"') {
				if (igq) {
					igq = 0;
				}
				else {
					st = DEFAULT;
				};
			}
		COMMENT =>
			if (c == '\n') {
				st = DEFAULT;
			}
		ESCAPE =>
			st = DEFAULT;
		DEFAULT =>
			case c {
			'(' =>
				pc++;
			')' =>
				pc--;
			'"' =>
				st = QUOTE;
			'\\' =>
				st = ESCAPE;
			';' =>
				st = COMMENT;
			}
		}	
	}

	if (pc > 0) {
		while (pc-- > 0) {
			if (i > BUFSIZ - 1) {
				sys->print ("%s", string buf);
				i = 0;
			}
			buf[i++] = byte ')';
		}
	}
	else if (pc < 0) {
		i += pc;
	}

	#buf[i] = byte Bufio->EOF;
	sys->print("%s", string buf[:i]);
}
