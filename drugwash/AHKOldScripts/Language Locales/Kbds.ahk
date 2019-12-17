

; This routine enumerates all keyboards which are installed on the system
; and returns the ID, the long and abbreviated name of the language
loop HKEY_CURRENT_USER, Keyboard Layout\Preload,0,1
{
RegRead Locale

locale := "0x" locale

VarSetCapacity(name, 128, 32) ; Set capacity new to clean up the buffer

Lang := DllCall("GetLocaleInfoA"
	,Uint,	Locale
	,Uint,	2	; &H2  'localized name of language
	,Str,		name
	,UInt,	128)

lname := name

Lang := DllCall("GetLocaleInfoA"
	,Uint,	Locale
	,Uint,	3	; &H2  'Abbreviates  name of language
	,Str,		name
	,UInt,	128)

msgbox Locale code:`t%locale%`nLong name:`t%lname%`nShort name:`t%name%
}
