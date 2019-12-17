
; This routine enumerates all available languages on a system
; and stores them in a drop down list

 Gui, Add,  DropDownList, x10 y10 w250 r10  Sort vLanguages

 EnumAddress := RegisterCallback("EnumerateLanguagesProc", Fast)
 RegRead, def, HKEY_CURRENT_USER, Control Panel\International, Locale
 StringRight, def, def, 4   
 Long := DllCall("EnumSystemLocalesA"
	,Uint,	EnumAddress
	,Uint,	1)
 Gui, Show
 return

 EnumerateLanguagesProc(lang)
 {
   global def
   VarSetCapacity(loc, 4, 0)
   DllCall("crtdll\strcpy", Str, loc, UInt, lang+4, cdecl)
   locale := "0x" loc

   VarSetCapacity(name, 128, 32) ; Set capacity new to clean up the buffer

   Lang := DllCall("GetLocaleInfoA"
	,Uint,	Locale
	,Uint,	2	; &H2  'localized name of language
	,Str,		name
	,UInt,	128)

   locale := locale "    " name

    Lang := DllCall("GetLocaleInfoA"
	,Uint,	Locale
	,Uint,	3	; &H2  'Abbreviated  name of language
	,Str,		name
	,UInt,	128)
   
   setdef := (def=loc) ? "||" : ""
   locale := locale "    " name setdef
   GUIControl,,Languages, %locale%
   return True
 }

 GuiClose:
 ExitApp
