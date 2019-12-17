#NoEnv
#Include __Diagramm__.ahk
; Schuldenliste generieren
Schulden := ""
Städte := "München|Berlin|Bonn"
StringSplit, Stadt, Städte, |
Farben := "Black|Red|0xFFEF00"
Monate := "Januar|Februar|März|April|Mai|Juni|Juli|August|September|Oktober|"
Monate .= "November|Dezember"
StringSplit, Monat, Monate, |
I := 0
Loop, 36 {
   I := ++I > 3 ? 1 : I
   Random, U, 7000, 10000
   Schulden .= Stadt%I% . "|" . U . "`n"
}
StringTrimRight, Schulden, Schulden, 1
; Maximale Anzahl der darzustellenden Werte
MX := 36
; Faktor für die X-Achse
FX := 20
; Höhe des Diagrammfeldes
DH := 500
; Höchster und niedrigster anzuzeigender Wert
YH := 10000
YL := 5000
; Beschriftung für Y-Achse
YScaler := ""
I := 0
C := YH
D1 := 100
D2 := DH // ((YH - YL) // D1)
Loop, % (DH // D2) + 1 {
   YScaler .= I . (Mod(C, 500) ? ";;|" : ";R;"
            . SubStr(C, 1, -3) . "." . SubStr(C, -2) . "|")
   C -= D1
   I += D2
}
StringTrimRight, YScaler, YScaler, 1
; Beschriftung für Y-Achse
XScaler := ""
I := 0
D := 3
Loop, % (MX // D) {
   I += D
   XScaler .= I . ";L;" . Monat%A_Index% . "|"
}
StringTrimRight, XScaler, XScaler, 1
; Ränder
XM := 10
YM := 10
; Gui
Gui, +ToolWindow
Gui, Margin, %XM%, %YM%
Gui, Font, s8
RC := __Diagramm__(  1, XM, YM, Schulden, DH, YH, YL, YScaler, MX, FX, XScaler
                  , Farben, "Silver", "White", "Blue" )
If Not RC{
   MsgBox, Fehler beim Aufruf der Funktion __Diagramm__()
   ExitApp
}
Gui, Show, , % "    Durchschnittliche monatliche Neuverschuldung 2007 in Tsd. €"
Return
; ------------------------------------------------------------------------------
GuiCLose:
GuiEscape:
ExitApp
