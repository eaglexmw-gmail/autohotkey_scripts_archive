; Title:    Spell
;			*Spellchecking using Hunspell*
;----------------------------------------------------------------------------------

/* 
 Function:  GetEncoding
			Get dictonary encoding
	
 */
Spell_GetEncoding( hSpell ) {
	return DllCall("hunspelldll.dll\hunspell_get_dic_encoding", "uint", hSpell, "CDecl str")
}

/* 
 Function:  Init
			Initialise the spellcheck engine
 
 Parameters:
			aff		- Path to affinity file
			dic		- Path to dictionary file

 Returns:
			Handle to the spell object.
	
 */
Spell_Init(aff, dic){
	return DllCall("hunspelldll.dll\hunspell_initialize", "str", aff, "str", dic, "CDecl UInt")
}

/* 
 Function:  PutWord
			Add word to dictionary. Word is valid until spell object is not destroyed
	
 */
Spell_PutWord( hSpell, word ) {
	return DllCall("hunspelldll.dll\hunspell_put_word", "uint", hSpell, "str", word, "CDecl UInt")	
}


/* 
 Function:  Spell
			Spellcheck word

 Returns:
			True or False
 */
Spell_Spell( hSPell, word ) {
	return DllCall("hunspelldll.dll\hunspell_spell", "uint", hSpell, "str", word, "CDecl UInt")	
}

/* 
 Function:  Suggest
			Suggest words for word

 Parameters:
			word	- Word for which to look up for suggestions
			sList	- Reference to variable to recive suggestion word list

 Returns:
			Number of words in sList
	
 */
Spell_Suggest( hSpell, word, ByRef sList) {
	VarSetCapacity(lst, 4, 0)
	r := DllCall("hunspelldll.dll\hunspell_suggest", "uint", hSpell, "str", word, "uint", &lst, "CDecl UInt")
	ifEqual, r, 0, return 0
	lst := NumGet(lst)

	sList = 
	loop, %r%
		sList .= DllCall("MulDiv", "Int", NumGet(lst+0, (A_Index-1)*4), "Int",1, "Int",1, "str") "`n"

	DllCall("hunspelldll.dll\hunspell_suggest_free", "uint", hSpell, "uint", lst, "int", r, "Cdecl")
	StringTrimRight, sList, sList, 1
	return r
}

/* 
 Function:  Unint
			Uninitialise the spellcheck engine
 */
Spell_Uninit( hSpell ) {
	return DllCall("hunspelldll.dll\hunspell_uninitialize", "uint", hSpell, "CDecl")	
}

/* -------------------------------------------------------------------------------------------------------------------
 Group: Example

 >	word = autohotkey
 >
 >	hSpell := Spell_Init("dic\en_US.aff", "dic\en_US.dic")
 >	if Spell_Spell(hSpell, word)
 >		msgbox OK
 >	else {
 >		cnt := Spell_Suggest(hSPell, word, lst)
 >		msgbox %cnt%`n`n%lst%
 >	}
 >
 >	Spell_Uninit( hSpell )
 >return

 */

;-------------------------------------------------------------------------------------------------------------------
;Group: About
;	o Ver 1.0 by majkinetor.
;:
;	o Hunspell: http://hunspell.sourceforge.net/
;	o Dictionaries: http://wiki.services.openoffice.org/wiki/Dictionaries
;   o Hunspell API: http://sourceforge.net/docman/display_doc.php?docid=115683&group_id=143754
;:
;	o Licenced under Creative Commons Attribution <http://creativecommons.org/licenses/by/3.0/>.  