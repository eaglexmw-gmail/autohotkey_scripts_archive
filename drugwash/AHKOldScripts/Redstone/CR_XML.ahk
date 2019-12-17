isXML(ByRef data) {
	StringLeft, firstChar, data, 1

	if (firstChar = "<") {
		return 1
	}
	return 0
}

getRoot(args) {

	xp := "(?:\w+:)?\w+/"
	RegExMatch(args, "<" . xp . ":: ", root)
	StringReplace, root, root, <, 
	StringReplace, root, root, /::%A_Space%, 

	return root
}

xml_quicksort(ByRef xml, leftIn, rightIn) {

	left := leftIn
	right := rightIn + 1

	pivot := list_Get(xml, leftIn)
	
	Loop {
		Loop {
			left++
			if (left > rightIn) {
				break
			}
			entry := list_Get(xml, left)
			if (list_Compare(entry, pivot) >= 0)
				break
		}

		Loop {
			right--
			entry := list_Get(xml, right) 
			if (list_Compare(entry, pivot) <= 0)
				break
		}

		if (left < right) {
			xml_Swap(xml, left, right)
		}
		if (left > right)
			break
	}

	xml_Swap(xml, leftIn, right)
	
	if (leftIn < right) 
		xml_quicksort(xml, leftIn, right)

	if (left < rightIn)
		xml_quicksort(xml, left, rightIn)
}

xml_reroot(root, ByRef entry) {

	eroot := getRoot(entry)

	if (eroot <> root) {
		stag := "<" . eroot . "/"
		etag := "</" . eroot . "/"
	
		srtag := "<" . root . "/"
		ertag := "</" . root . "/"

		StringReplace, entry, entry, %stag%, %srtag%, All
		StringReplace, entry, entry, %etag%, %ertag%, All
	}	
}

xml_unroot(ByRef entry) {
	epos := InStr(entry, "/")
	root := SubStr(entry, 2, epos-2)

	stag := "<" . root . "/"
	etag := "</" . root . "/"
    StringReplace, entry, entry, %stag%, <, All
    StringReplace, entry, entry, %etag%, </, All
}

xml_addRoot(root, ByRef entry) {

	eroot := getRoot(entry)

	if (eroot <> root) {
		stag := "<" . eroot . "/"
		etag := "</" . eroot . "/"
	
		srtag := "<" . root . "/" . eroot . "/"
		ertag := "</" . root . "/" . eroot . "/"

		StringReplace, entry, entry, %stag%, %srtag%, All
		StringReplace, entry, entry, %etag%, %ertag%, All
	}	
}

xml_replace(ByRef doc, ByRef os, entry) {
	
	xp := "(?:\w+:)?\w+/(?:\w+:)?\w+/"
	if (os = "") {
		os = 0
	}

	osx := RegExMatch(doc, "</" . xp . ">", rem, os) + StrLen(rem)

	If (os = 0) {
		Return
	}
	doc := SubStr(doc, 1, os - 1) . entry . SubStr(doc, osx)
}

xml_Set(ByRef rlist, index, sentry) {

	Loop
	{
		entry := xml_iterate(rlist, iter, "", 1)
		if (entry = "") {
			break
		}
		if (index = A_Index) {
			xml_replace(rlist, iter, sentry)
			break
		}
	}
}

xml_Get(ByRef glist, indexNo) {

	Loop
	{
		entry := xml_iterate(glist, iter, "", 1)
		if (entry = "") {
			break
		}
		if (A_Index = indexNo) {
			return entry
		}
	}
	return ""
}

xml_Swap(ByRef xml, left, right) {
	ltemp := xml_Get(xml, left)
	rtemp := xml_Get(xml, right)
	xml_Set(xml, left, rtemp)
	xml_Set(xml, right, ltemp)
}

xml_remove(ByRef doc, os) {
	
	xp := "(?:\w+:)?\w+/(?:\w+:)?\w+/"
	if (os = "") {
		os = 0
	}

	; find offset of next element, and its closing tag offset:
;	os := RegExMatch(doc, "<" . xp . ":: ", "", os)
	osx := RegExMatch(doc, "</" . xp . ">", rem, os) + StrLen(rem)

	If (os = 0) {
		Return
	}

	doc := SubStr(doc, 1, os - 1) . SubStr(doc, osx)
}

;XML decode by infogulch
;Decode xml required characters, as well as numeric character references
Dec_XML(str) {
   Loop
   {
      If RegexMatch(str, "S)(&#(\d+);)", dec)                  ; matches:   &#[dec];
         StringReplace, str, str, %dec1%, % Chr(dec2), All
      Else If   RegexMatch(str, "Si)(&#x([\da-f]+);)", hex)         ; matches:   &#x[hex];
         StringReplace, str, str, %hex1%, % Chr("0x" . hex2), All
      Else
         Break
   }
   
   ; TODO: search for semicolon in string - if none, just return string
   
   StringReplace, str, str, &nbsp;, %A_Space%, All
   StringReplace, str, str, &quot;, ", All         ;required predefined character entities &"<'>
   StringReplace, str, str, &apos;, ', All
   StringReplace, str, str, &lt;,   <, All
   StringReplace, str, str, &gt;,   >, All
   StringReplace, str, str, &amp;,  &, All         ;do this last so str doesn't resolve to other entities
   return, str
}

Enc_XML(str, chars=",@[]")
{ ;encode required xml characters. and characters listed in Param2 as numeric character references
   StringReplace, str, str, &, &amp;,  All         ;do first so it doesn't re-encode already encoded characters
   StringReplace, str, str, ", &quot;, All         ;required predefined character entities &"<'>
   StringReplace, str, str, ', &apos;, All
   StringReplace, str, str, <, &lt;,   All
   StringReplace, str, str, >, &gt;,   All
   Loop, Parse, chars         
      StringReplace, str, str, %A_LoopField%, % "&#" . Asc(A_LoopField) . "`;", All
   return, str
}

xml_value(ByRef doc, name) {

	os = 0
	xp := "(?:\w+:)?\w+/" . name . "/"

	os := RegExMatch(doc, "<" . xp . ":: ", "", 1 + os)
		, osx := RegExMatch(doc, "</" . xp . ">", rem, os) + StrLen(rem)

	If (os = 0)
		Return ""

	os := InStr(doc, ">", "", os) + 1, osx := InStr(doc, rem, true, os)
	StringMid, sub, doc, os, osx - os ; extract result

	return Dec_XML(sub)
}

xml_iterate(ByRef doc, ByRef os, filter="", raw=0) {
	
	xp := "(?:\w+:)?\w+/(?:\w+:)?\w+/"
	if (os = "") {
		os = 0
	}

;	if (filter <> "") {
;		logExt("Filter:" . filter)
;	}

	Loop
	{
		; find offset of next element, and its closing tag offset:
		os := RegExMatch(doc, "<" . xp . ":: ", "", 1 + os)
			, osx := RegExMatch(doc, "</" . xp . ">", rem, os) + StrLen(rem)

		If os = 0 ; stop looping when no more tags are found
			return ""

		StringMid, sub, doc, os, osx - os

		if (filter = "") {
			break
		}

		root := "(?:\w+:)?\w+/(?:\w+:)?\w+/"
		RegExMatch(rem, "(?<=^</)" . root, root)
		sk = 0
		Loop, Parse, filter, ] ; for each predicate
		{
			; split components to: (1) path, (2) selector, (3) operator, (4) quotation char, (5) operand
			If (!RegExMatch(A_LoopField, "/?(.*?)\[(.+?)(?:\s*([<>!=]{1,2})\s*(['""])?(.+)(?(4)\4))?\s*$", a))
				Continue

			StringMid, value, sub
				, t := InStr(sub, ">", "", InStr(sub, "<" . root . a2 . "/:: ", true) + 1) + 1
				, InStr(sub, "</" . root . a2 . "/>", true) - t

			if (a5 = "null")
				a5 := ""
			if (a3 = "") {
				; Invalid search
				return ""
			}
			
			if (isXML(value)) {
				xml_unroot(value)
				value := Enc_XML(value)
			}

			; dynamic mini expression evaluator:
			sk += !(a3 == "" ? (value == "")
				: a3 == "=" ? value == a5
				: a3 == "!=" ? value != a5
				: a3 == ">" ? value > a5
				: a3 == ">=" ? value >= a5
				: a3 == "<" ? value < a5
				: a3 == "<=" ? value <= a5)

logExt("value:" . value . " a3:" . a3 . " a5:" . a5 . " sk:" . sk)

			If sk != 0 ; if conditions were not met for this result, skip it
				break
		}
		If sk = 0 ; if conditions were not met for this result, skip it
			break
	}
	
	if (raw = 1) {
		return sub
	}

	bpos := InStr(sub, ",")
	epos := InStr(sub, "/")
	root := SubStr(sub, bpos+2, epos-bpos-2)

	stag := "<" . root . "/"
	etag := "</" . root . "/"
    StringReplace, sub, sub, %stag%, <, All
    StringReplace, sub, sub, %etag%, </, All
	
	return sub
}
