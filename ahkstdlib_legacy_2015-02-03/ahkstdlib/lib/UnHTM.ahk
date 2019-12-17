UnHTM( HTM ) {   ; Remove HTML formatting / Convert to ordinary text   by SKAN 19-Nov-2009
 Static HT,C=";" ; Forum Topic: www.autohotkey.com/forum/topic51342.html  Mod: 16-Sep-2010
 IfEqual,HT,,   SetEnv,HT, % "&aacute�&acirc�&acute�&aelig�&agrave�&amp&aring�&atilde�&au"
 . "ml�&bdquo�&brvbar�&bull�&ccedil�&cedil�&cent�&circ�&copy�&curren�&dagger�&dagger�&deg"
 . "�&divide�&eacute�&ecirc�&egrave�&eth�&euml�&euro�&fnof�&frac12�&frac14�&frac34�&gt>&h"
 . "ellip�&iacute�&icirc�&iexcl�&igrave�&iquest�&iuml�&laquo�&ldquo�&lsaquo�&lsquo�&lt<&m"
 . "acr�&mdash�&micro�&middot�&nbsp &ndash�&not�&ntilde�&oacute�&ocirc�&oelig�&ograve�&or"
 . "df�&ordm�&oslash�&otilde�&ouml�&para�&permil�&plusmn�&pound�&quot""&raquo�&rdquo�&reg"
 . "�&rsaquo�&rsquo�&sbquo�&scaron�&sect�&shy &sup1�&sup2�&sup3�&szlig�&thorn�&tilde�&tim"
 . "es�&trade�&uacute�&ucirc�&ugrave�&uml�&uuml�&yacute�&yen�&yuml�"
 $ := RegExReplace( HTM,"<[^>]+>" )               ; Remove all tags between  "<" and ">"
 Loop, Parse, $, &`;                              ; Create a list of special characters
   L := "&" A_LoopField C, R .= (!(A_Index&1)) ? ( (!InStr(R,L,1)) ? L:"" ) : ""
 StringTrimRight, R, R, 1
 Loop, Parse, R , %C%                               ; Parse Special Characters
  If F := InStr( HT, L := A_LoopField )             ; Lookup HT Data
    StringReplace, $,$, %L%%C%, % SubStr( HT,F+StrLen(L), 1 ), All
  Else If ( SubStr( L,2,1)="#" )
    StringReplace, $, $, %L%%C%, % Chr(((SubStr(L,3,1)="x") ? "0" : "" ) SubStr(L,3)), All
Return RegExReplace( $, "(^\s*|\s*$)")            ; Remove leading/trailing white spaces
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
*