/*
	Title: Decimal-Binary
	
	Converts a binary string to an integer and vice versa.
	
	Function: toInt
		Converts binary string to an integer.
	
	Parameters:
		b - binary
		s - signed (default: false)
		c - offset
	
	Returns:
		An intenger.
	
	Function: toBin
		Converts an integer to a binary string.
	
	Parameters:
		i - integer
		s - signed (default: false)
		c - offset
	
	Returns:
		A binary string.
	
	About: License
		- Version 1.2 by Titan <http://www.autohotkey.net/~Titan/#decimal-binary>.
		- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.

*/

toInt(b, s = 0, c = 0) {
	Loop, % l := StrLen(b) - c
		i += SubStr(b, ++c, 1) * 1 << l - c
	Return, i - s * (1 << l)
}

toBin(i, s = 0, c = 0) {
	l := StrLen(i := Abs(i + u := i < 0))
	Loop, % Abs(s) + !s * l << 2
		b := u ^ 1 & i // (1 << c++) . b
	Return, b
}
