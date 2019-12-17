/*
	Function: uuencode
	
	A set of Unix binary to text conversion functions.
	
	Parameters:
		bin - a variable containing the binary data to convert
	
	Returns:
		A uuencoded string.
	
	Function: uudecode
	
	Parameters:
		txt - a variable containing the encoded text to convert to binary
	
	Returns:
		Decoded binary.
	
	About: License
		- Version 1.2 by Titan <http://www.autohotkey.net/~Titan/#uuencode>.
		- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.

*/

uuencode(ByRef bin) {
	adr := &bin - 1
	VarSetCapacity(u, Ceil(1.3 * len := VarSetCapacity(bin)))
	Loop, % Ceil(len / 3) {
		a := *++adr, b := *++adr, c := *++adr
		u .= Chr(32 + (a >> 2 & 63)) . Chr(32 + ((a << 4 | (b >> 4 & 15)) & 63))
		 . Chr(32 + ((b << 2 | (c >> 6 & 3)) & 63)) . Chr(32 + (c & 63))
	}
	Return, u
}

uudecode(ByRef txt) {
	adr := &txt - 1
	VarSetCapacity(u, Ceil(0.6 * len := StrLen(txt)))
	Loop, % Ceil(len / 4) {
		a := *++adr - 32 & 63, b := *++adr - 32 & 63
			, c := *++adr - 32 & 63, d := *++adr - 32 & 63
		u .= Chr((a << 2 & 252) | (b >> 4 & 3))
			. Chr((b << 4 & 240) | (c >> 2 & 15)) . Chr((c << 6 & 192) | d)
	}
	Return, u
}
