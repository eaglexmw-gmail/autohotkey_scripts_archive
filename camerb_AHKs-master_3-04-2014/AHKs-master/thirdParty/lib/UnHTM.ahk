; UnHTM by SKAN
; Please do not expect UnHTM() to unformat a whole HTML file. If you have already parsed out a string, and need to unformat it to plain text, then UnHTM() would be handy. 
; Example:
; HTM = <a href="/intl/en/ads/">Advertising&nbsp;Programs</a>
; MsgBox, % UnHTM( HTM )

UnHTM( HTM ) { ; Remove HTML formatting / Convert to ordinary text     by SKAN 19-Nov-2009
 Static HT     ; Forum Topic: www.autohotkey.com/forum/topic51342.html
 IfEqual,HT,,   SetEnv,HT, % "&aacute�&acirc�&acute�&aelig�&agrave�&amp&aring�&atilde�&au"
 . "ml�&bdquo�&brvbar�&bull�&ccedil�&cedil�&cent�&circ�&copy�&curren�&dagger�&dagger�&deg"
 . "�&divide�&eacute�&ecirc�&egrave�&eth�&euml�&euro�&fnof�&frac12�&frac14�&frac34�&gt>&h"
 . "ellip�&iacute�&icirc�&iexcl�&igrave�&iquest�&iuml�&laquo�&ldquo�&lsaquo�&lsquo�&lt<&m"
 . "acr�&mdash�&micro�&middot�&nbsp &ndash�&not�&ntilde�&oacute�&ocirc�&oelig�&ograve�&or"
 . "df�&ordm�&oslash�&otilde�&ouml�&para�&permil�&plusmn�&pound�&quot""&raquo�&rdquo�&reg"
 . "�&rsaquo�&rsquo�&sbquo�&scaron�&sect�&shy�&sup1�&sup2�&sup3�&szlig�&thorn�&tilde�&tim"
 . "es�&trade�&uacute�&ucirc�&ugrave�&uml�&uuml�&yacute�&yen�&yuml�"
 TXT := RegExReplace( HTM,"<[^>]+>" )               ; Remove all tags between  "<" and ">"
 Loop, Parse, TXT, &`;                              ; Create a list of special characters
   L := "&" A_LoopField ";", R .= (!(A_Index&1)) ? ( (!InStr(R,L,1)) ? L:"" ) : ""
 StringTrimRight, R, R, 1
 Loop, Parse, R , `;                                ; Parse Special Characters
  If F := InStr( HT, A_LoopField )                  ; Lookup HT Data
    StringReplace, TXT,TXT, %A_LoopField%`;, % SubStr( HT,F+StrLen(A_LoopField), 1 ), All
  Else If ( SubStr( A_LoopField,2,1)="#" )
    StringReplace, TXT, TXT, %A_LoopField%`;, % Chr(SubStr(A_LoopField,3)), All
Return RegExReplace( TXT, "(^\s*|\s*$)")            ; Remove leading/trailing white spaces
}

/*
; Array of Special Character Entities was created with following code
Loop % 256-33 {
Transform, F, HTML, % Chr( A := A_Index+33 )
If Strlen(F) > 1 && !Instr( F, "#" )
  list .= "&" SubStr(F,2, StrLen(F)-2) Chr(A )
}
StringLower, List, List
Sort, List, D& U
Clipboard := List
MsgBox, 0, % StrLen( List ), % Clipboard
*/