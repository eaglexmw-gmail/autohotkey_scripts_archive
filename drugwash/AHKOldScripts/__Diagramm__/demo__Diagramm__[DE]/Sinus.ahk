#NoEnv
#Include __Diagramm__.ahk

; ------------------------------------------------------------------------------
; Funktionsparameter:
; Höhe des Diagrammfeldes
H_D := 360
; Höchster und niedrigster anzuzeigender Wert
H_Y := 1
L_Y := -1
; Maximale Anzahl der darzustellenden Werte
M_X := 361
; Faktor für die X-Achse
F_X := 2
; Raster und Beschriftung für Y-Achse
I := 0
D := H_D // 20
S_Y := I . ";R;1,00|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";R;0,00|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";;|"
S_Y .= (I += D) . ";R;-1,00"
; Raster und Beschriftung für X-Achse
S_X := " "
V_I := 1
Loop, % (M_X // 45) {
   V_I += 45
   S_X .= V_I . ";;|"
}
S_X .= M_X . ";L;Kurvenverlauf über den Bereich von 0 - 360°"
; Werteliste erstellen: Sinuskurve
V_L := ""
V_I := 0
Loop, %M_X% {
   V_L .= V_I . "|" . Sin(V_I * 0.01745329252) . "`n"
   V_I++
}
V_L := SubStr(V_L, 1, -1)
; Diagramm anzeigen
Gui, Margin, 20, 20
Gui, Font, s10
If Not __Diagramm__(  1, 20, 20, V_L, H_D, H_Y, L_Y, S_Y, M_X, F_X, S_X
                , "Lime", "Gray", "Silver", 0, 0, 2)
   ExitApp
Gui, Show, , Sinuskurve
Return
; ------------------------------------------------------------------------------
GuiCLose:
GuiEscape:
ExitApp
