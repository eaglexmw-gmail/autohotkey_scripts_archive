; ==============================================================================
; __Diagramm__()
; ------------------------------------------------------------------------------
; Funktion:
; Diagramm für eine Werteliste an vorgegebener Position in die vorgegebene
; Gui einfügen.
; ------------------------------------------------------------------------------
; Parameter:
; G#           Nummer der Gui, Wertebereich: 1 - 98
;              99 ist für interne Zwecke reserviert (s.u. Besonderheiten).
; XD           X-Position für Diagrammbereich
; YD           Y-Position für Diagrammbereich
; VL           Werteliste, LF-separierte (`n) Liste mit jeweils zwei
;              durch | getrennten Feldern.
;              Feld1 : beliebige Beschreibung für die Wertanzeige
;              Feld2 : darzustellender numerischer Wert
;              Feld2 darf einen Dezimalpunkt oder ein Dezimalkomma enthalten.
; HY           Höhe des Diagramms in Pixeln (Y-Achse)
; YH           Höchster darzustellender Wert
; YL           Niedrigster darzustellender Wert
; SY           Beschriftung der Y-Achse als durch | getrennte Liste.
;              Jedes Listenelement hat den Aufbau: P;F;T
;              P = Rasterposition im Bereich von 1 - HY (s.u.)
;              F = Textformatierung:
;                  L = Linksbündig
;                  C = Zentriert
;                  R = Rechtsbündig
;              T = Texteintrag
;              Bei leeren Einträge für F und T wird nur ein Raster gezeichnet.
;              Leere Zeichenfolge (""): Keine Beschriftung, kein Raster
;              Eine Zeichenfolge, die kein | enthält, wird als fehlerhaft
;              abgewiesen.
; MX           Maximale Anzahl der darzustellenden Werte (X-Achse)
; FX           Ganzzahliger Faktor für die Breite des Diagramms:
;              Breite in Pixeln = MX * FX
; SX           Beschriftung der X-Achse als durch | getrennte Liste.
;              Jedes Listenelement hat den Aufbau: P;F;T
;              P = Rasterposition im Bereich von 1 - MX
;              F = Textformatierung:
;                  L = Links von der angegebenen Rasterposition P
;                  C = Zentriert unter der angegebenen Rasterposition P
;              T = Texteintrag
;              Bei leeren Einträge für F und T wird nur ein Raster gezeichnet.
;              Leere Zeichenfolge (""): Keine Beschriftung, kein Raster
;              Eine Zeichenfolge, die kein | enthält, wird als fehlerhaft
;              abgewiesen.
; Optional VC  Farbe der Wertanzeige
;              Wertebereich: HTML-Farbname | RGB-Hexcode (0x888888) | 0
;              Standard: 0 = "Gray"
;              VC kann auch eine durch | getrennte Farbliste enthalten, die
;              Farben werden dann alternierend verwendet.
; Optional BC  Farbe des Diagrammhintergrundes
;              Wertebereich: HTML-Farbname | RGB-Hexcode (0x888888) | 0
;              Standard: 0 = "White"
; Optional GC  Farbe des Diagrammrasters
;              Wertebereich: HTML-Farbname | RGB-Hexcode (0x888888) | 0
;              Standard: 0 = "Grid" (normaler Guihintergrund)
;              Bei Übergabe von BC = GC ist das Raster unsichtbar, wenn es
;              nicht im Vordergrund angezeigt wird (s.u. Parameter GF).
; Optional HC  Farbe des "Fadenkreuzes" bei der Werteanzeige
;              Wertebereich: HTML-Farbname | RGB-Hexcode (0x888888) | 0
;              Standard: 0 = "Red"
;              Achtung: HC darf nicht mit der (ersten) Farbe in VC identisch
;              sein, weil diese als Transparenzfarbe genutzt wird.
; Optional GF  Raster im Vordergrund anzeigen, Wertebereich: 0 | 1
;              Standard: 0 = Hintergrund
; Optional PL  Plottermodus, die Werte werden als Kurve dargestellt
;              Wertebereich: 0 - 3, Werte <> 0 bestimmen die Linienstärke
;              Standard: 0 = Balkendiagramm
; ------------------------------------------------------------------------------
; Rückgabewerte:
; Wenn die Funktion nicht abgearbeitet werden kann, liefert sie den Rückgabe-
; wert 0 (False).
; Bei erfolgreicher Verarbeitung werden die Breite und die Höhe des erstellten
; Diagrammbereichs getrennt durch ein | Zeichen zurückgegeben. Auf Basis der
; Parameter XD und YD sowie der Rückgabewerte für Breite und Höhe können dann
; weitere Controls positioniert werden.
; ------------------------------------------------------------------------------
; Besonderheiten:
; Die Funktion benötigt die GDIPlus.dll.
; Die Funktion verwendet für Funktionen und Label das Präfix __Diagramm__.
; Dieses Prefix sollte deshalb im aufrufenden Skript nicht verwendet werden.
; Die Funktion verwendet für die interne Zwecke die die Gui-Nummer 99.
; Diese Nummer sollte deshalb im aufrufenden Skript nicht verwendet werden.
; ------------------------------------------------------------------------------
; Danksagung:
; Mein besonderer Dank gilt
;     jonny & tonne für    http://www.autohotkey.com/forum/post-107890.html
;     holomind für         http://www.autohotkey.com/forum/topic12012.html
;     Sean für             http://www.autohotkey.com/forum/topic17179.html
; und allen Anderen, die sich im AHK-Forum mit GDI/GDIPlus beschäftigt haben.
; Ohne diese Threads gäbe es dieses Skript in dieser Form nicht, es war mit
; ihnen schon schwer genug.
; ------------------------------------------------------------------------------
__Diagramm__( G#
            , XD
            , YD
            , VL
            , HY
            , YH
            , YL
            , SY
            , MX
            , FX
            , SX
            , VC = 0
            , BC = 0
            , GC = 0
            , HC = 0
            , GF = 0
            , PL = 0 )
{
   ; HTML-Farben im BGR-Format
   Static Black := 0x000000
   Static Green := 0x008000
   Static Silver := 0xC0C0C0
   Static Lime := 0x00FF00
   Static Gray := 0x808080
   Static Olive := 0x800080
   Static White := 0xFFFFFF
   Static Yellow := 0x00FFFF
   Static Maroon := 0x000080
   Static Navy := 0x800000
   Static Red := 0x0000FF
   Static Blue := 0xFF0000
   Static Purple := 0x800080
   Static Teal := 0x808000
   Static Fuchsia := 0xFF00FF
   Static Aqua := 0xFFFF00
   Static Grid := 0xD8E9EC
   ; Präfix für Funktionen, Label, Meldungen etc.
   Static PRE := "__Diagramm__"
   ; Sonstige statische Variablen
   Static SHD
   Static SYL
   Static SF
   Static SFX
   Static XB
   Static YB
   Static PICX
   Static PICY
   Static PHID
   Static PVID
   Static CC
   Static TT
   Static RL
   MSG := ""
   PNG := A_Temp . "\__Diagramm__.png"
   ; Parameter prüfen und ggf. Standardwerte setzen
   GoSub, %PRE%Parameter
   If (MSG) {
      MsgBox, 262160, %PRE%, %MSG%
      ErrorLevel := 1
      Return False
   }
   ; Achsenbeschriftungen auswerten
   GoSub, %PRE%Achsen
   If (MSG) {
      MsgBox, 262160, %PRE%, %MSG%
      ErrorLevel := 1
      Return False
   }
   ; Diagramm aufbauen
   SFX := FX
   HD := HY
   WD := MX * FX
   SysGet, XB, 45
   Sysget, YB, 46
   ; Beschriftung der Y-Achse
   GH := 0
   GW := 0
   If (SYT) {
      X := XD
      GW := X + SYM - 1
      YM := YD + YB + (SYH / 2)
      Loop, %SY0% {
         StringSplit, SP, SY%A_Index%, `;
         If (SP0 = 3 And SP2 <> "" And SP3 <> "") {
            O := SP2 = "C" ? "Center"
              :  SP2 = "R" ? "Right"
              :  ""
            Y := YM + SP1 - (SYH / 2)
            Gui, %G#%:Add, Text
               , x%X% y%Y% w%SYM% h%SYH% %O% 0x200 BackgroundTrans
               , %SP3%
            GH := Y + SYH - 1
         }
      }
   }
   ; Diagrammhintergrund erstellen
   DX := XD + SYM + (SYH // 2) + XB
   DY := YD + (SYH // 2) + YB
   GW := DX + WD + XB - 1
   If (DY + HD + YB - 1) > GH {
      GH := DY + HD + YB - 1
   }
   Gui, 99:+LastFound
   ; Device Context (DC) für das Fenster,
   ; auf das gezeichnet werden soll
   WDC := DllCall("GetDC", UInt, WinExist())
   If Not WDC {
      MsgBox, 262160, %PRE%, Fehler beim Aufruf von GetDc!
      ErrorLevel := 1
      Return False
   }
   ; DC für den Hintergrund der Grafik (das Papier)
   PDC := DllCall("CreateCompatibleDC", UInt, 0)
   If Not PDC {
      MsgBox, 262160, %PRE%, Fehler beim Aufruf von CreateCompatibleDC!
      ErrorLevel := 1
      Return False
   }
   ; Eine Bitmap auf dem Papier erzeugen
   PDC_BM := DllCall("CreateCompatibleBitmap", UInt, WDC, UInt, WD, UInt, HD)
   If Not PDC_BM {
      MsgBox, 262160, %PRE%, Fehler beim Aufruf von CreateCompatibleBitmap!
      ErrorLevel := 1
      Return False
   }
   DllCall("SelectObject", UInt, PDC, UInt ,PDC_BM)

   ; Zeichenwerkzeuge für Rahmen (PEN) und Hintergrund (BRUSH)
   ; erzeugen und für das Papier auswählen
   PEN := DllCall( "CreatePen", UInt, 0, UInt, 0, UInt, BC )
   DllCall("SelectObject", UInt, PDC, UInt, PEN)
   BRUSH := DllCall( "CreateSolidBrush", UInt, BC )
   DllCall("SelectObject", UInt, PDC, UInt, BRUSH)
   ; Jetzt ein Recheck zeichnen
   DllCall("Rectangle", UInt, PDC, UInt, 0, UInt, 0, UInt, WD, UInt, HD)
   ; Zeichenwerkzeuge freigeben
   DllCall("DeleteObject", UInt, PEN)
   DllCall("DeleteObject", UInt, BRUSH)
   ; Ggf. Gitterraster hinter Diagramm zeichnen
   If Not (GF) {
      GoSub, %PRE%Raster
   }
   ; Diagramm zeichnen
   X := 0
   F := HD / (YH - YL)
   SHD := HD
   SYL := YL
   SF := F
   VCI := 0
   RL := "|"
   CC := ""
   PEN := ""
   BRUSH := ""
   Loop, Parse, VL, `n
   {
      If (A_Index > MX) {
         Break
      }
      StringSplit, SP, A_LoopField, |
      StringReplace, V, SP2, `,, .
      If (PL) {

      }
      If (V <= YL) {
         If (PL) {
            V := YL
         } Else {
            X += FX
            RL .= A_Index . ";" . SP1 . ";" . SP2 . "|"
            Continue
         }
      }
      If (V > YH) {
         V := YH
      }
      H := Round((V - YL) * F)
      If (PL) {
         If (PEN = "") {
            X += PL // 2
            PEN := DllCall("CreatePen", UInt, 0, UInt, PL, UInt, VC1)
            DllCall("SelectObject", UInt, PDC, UInt, PEN)
         }
         If (A_Index = 1) {
            DllCall("MoveToEx", UInt, PDC, UInt, X, UInt, HD - H, UInt, 0)
         } Else {
            DllCall("LineTo", UInt, PDC, UInt, X, UInt, HD - H)
         }
      } Else {
         VCI := ++VCI > VC0 ? 1 : VCI
         If (CC != VC%VCI%) {
            CC := VC%VCI%
            If (PEN) {
               DllCall("DeleteObject", UInt, PEN)
            }
            PEN := DllCall("CreatePen", UInt, 0, UInt, 0, UInt, CC)
            DllCall("SelectObject", UInt, PDC, UInt, PEN)
            If (BRUSH) {
               DllCall("DeleteObject", UInt, BRUSH)
            }
            BRUSH := DllCall( "CreateSolidBrush", UInt, CC )
            DllCall("SelectObject", UInt, PDC, UInt, BRUSH)
         }
         DllCall("Rectangle", UInt, PDC, UInt, X, UInt, HD - H
               , UInt, X + FX, UInt, HD)
      }
      X += FX
      RL .= A_Index . ";" . SP1 . ";" . SP2 . "|"
   }
   DllCall("DeleteObject", UInt, BRUSH)
   DllCall("DeleteObject", UInt, PEN)
   ; Ggf. Gitterraster vor Diagramm zeichnen
   If (GF) {
      GoSub, %PRE%Raster
   }
   ; Diagramm als Bild Speichern und anzeigen
   MSG := __Diagramm__Speichern(PDC_BM, PNG)
   ; Objekte freigeben
   DllCall("DeleteObject", UInt, PDC)
   DllCall("DeleteObject", UInt, PDC_BM)
   DllCall("ReleaseDC", UInt, 0, UInt, WDC)
   Gui, 99:Destroy
   If (MSG) {
      Msgbox, 262160, %PRE%, %MSG%
      ErrorLevel := 1
      Return False
   }
   X := DX - 2
   Y := DY - 2
   Gui, %G#%:Add, Pic, x%X% y%Y% g%PRE%Pic hwndPICID +E0x200, %PNG%
   ControlGetPos, PICX, PICY, , , , ahk_id %PICID%
   XX := PICX - X
   ; Beschriftung der X-Achse
   If (SXT) {
      P := 0
      Y := DY + HD + YB + (SYH // 2) - 1
      GH := Y + SYH - 1
      Loop, %SX0% {
         StringSplit, SP, SX%A_Index%, `;
         SP1 *= FX
         If (SP0 = 3 And SP2 <> "" And SP3 <> "") {
            If (SP2 = "L") {
               X := DX + P
               W := SP1 - P
               P := SP1
               Gui, %G#%:Add, Text
                  , x%X% y%Y% w%W% h%SYH% 0x200 Center BackgroundTrans
                  , %SP3%
               If (X + W - 1) > GW {
                  GW := X + W - 1
               }
            } ELSE {
               X := DX + SP1
               Gui, %G#%:Add, Text
                  , x%X% y%Y% h%SYH% 0x200 BackgroundTrans hwndCTID
                  , %SP3%
               ControlGetPos, , , W, , , ahk_id %CTID%
               X := X - (W // 2) + XX
               ControlMove, , X, , , , ahk_id %CTID%
               P := X + W
               If (P > GW) {
                  GW := P
               }
            }
         }
      }
   }
   ; Zuletzt die Gui für das Fadenkreuz
   Gui, 99:+Alwaysontop +ToolWindow +LastFound +Owner%G#%
   Gui, 99:Margin, 0, 0
   VC := SubStr(VC1, 1, 2) . SubStr(VC1, -1)
       . SubStr(VC1, 5, 2) . SubStr(VC1, 3, 2)
   Gui, 99:Color, %VC%
   Y := HD // 2
   W := WD + 2
   Gui, 99:Add, Progress
      , x0 y%Y% h3 w%W% c%HC% hwndPHID, 100
   Control, ExStyle, -0x20000, , ahk_id %PHID%
   X := WD // 2
   H := HD + 2
   Gui, 99:Add, Progress
      , x%X% y0 h%H% w3 Vertical c%HC% hwndPVID, 100
   Control, ExStyle, -0x20000, , ahk_id %PVID%
   Gui, 99:Show, w%WD% h%HD% Hide
   Winset, TransColor, %VC%
   Gui, 99:-Caption
   ; Und fertig!
   Return Round(GW - XD) . "|" . Round(GH - YD)
   ; ===========================================================================
   ; Subroutinen ===============================================================
   ; ===========================================================================
   ; Gui-Routinen
   ; ---------------------------------------------------------------------------
   __Diagramm__Pic:
      MouseGetPos, MX, MY, WID
      WinGetPos, WX, WY, , , ahk_id %WID%
      IX := ((MX - PICX - XB + SFX - 1) // SFX)
      If RegExMatch(RL
                  , "S)\|" . IX . ";[^;]+;[^\|]+\|"
                  , RX) {
         RX := SubStr(RX, 2, -1)
         TT := ""
         Loop, Parse, RX, `;
         {
            If (A_Index = 2) {
               TT .= A_LoopField . " : "
               Continue
            }
            If (A_Index = 3) {
               TT .= A_LoopField
               V := A_LoopField
               Break
            }
         }
         StringReplace, V, V, `,, ., All
         X := MX - PICX - XB -1
         Y := SHD - Round((V - SYL) * SF) - 1
         ControlMove, , X, , , , ahk_id %PVID%
         ControlMove, , , Y, , , ahk_id %PHID%
         X := WX + PICX + XB - 1
         Y := WY + PICY + YB - 1
         Gui, 99:Show, x%X% y%Y% NA
         ToolTip, %TT%
         KeyWait, LButton
         ToolTip
         Gui, 99:Hide
      } Else {
         ToolTip
         Gui, 99:Hide
      }
   Return
   ; ---------------------------------------------------------------------------
   ; Übergebene Parameter prüfen
   ; ---------------------------------------------------------------------------
   __Diagramm__Parameter:
      MSG := ""
      If (G# < 1 Or G# > 99) {
         MSG := "Der Parameter G# ist ungültig:`n" . G#
         Return
      }
      G# := Round(G#)
      If (XD + 0) = "" {
         MSG := "Der Parameter XD ist ungültig:`n" . XD
         Return
      }
      XD := Round(Abs(XD))
      If (YD + 0) = "" {
         MSG := "Der Parameter YD ist ungültig:`n" . YD
         Return
      }
      YD := Round(Abs(YD))
      If Not InStr(VL, "|") {
         MSG := "Der Parameter VL ist ungültig!"
         Return
      }
      If Not ((HY + 0) > 0) {
         MSG := "Der Parameter HY ist ungültig:`n" . HY
         Return
      }
      HY := Round(Abs(HY))
      If (YH + 0) = "" {
         MSG := "Der Parameter YH ist ungültig:`n" . YH
         Return
      }
      If (YL + 0) = "" {
         MSG := "Der Parameter YL ist ungültig:`n" . YL
         Return
      }
      If Not (YL < YH) {
         MSG := "Der Parameter YL ist nicht kleiner als YH:`n"
              . YL . " - " . YH
         Return
      }
      If (SY) {
         If Not InStr(SY, "|") {
            MSG := "Der Parameter SY ist ungültig:`n" . SY
            Return
         }
      }
      If Not ((MX + 0) > 0) {
         MSG := "Der Parameter MX ist ungültig:`n" . MX
         Return
      }
      MX := Round(MX)
      If Not ((FX + 0) > 0) {
         MSG := "Der Parameter FX ist ungültig:`n" . FX
         Return
      }
      FX := Round(FX)
      If (SX) {
         If Not InStr(SX, "|") {
            MSG := "Der Parameter SX ist ungültig:`n" . SX
            Return
         }
      }
      If (VC = 0) {
         VC := Gray
      }
      StringSplit, VC, VC, |
      Loop, %VC0%
      {
         CC := VC%A_Index%
         If (%CC% != "") {
            VC%A_Index% := %CC%
            Continue
         }
         If Not RegExMatch(CC, "i)^0x[0-9a-f]{6}$") {
            MSG := "Parameter VC: Die Angabe " . CC . " ist ungültig!"
            Return
         }
         VC%A_Index% := SubStr(CC, 1, 2) . SubStr(CC, -1)
                      . SubStr(CC, 5, 2) . SubStr(CC, 3, 2)
      }
      If (BC = 0) {
         BC := White
      } Else {
         If (%BC% != "") {
            BC := %BC%
         } Else {
            If Not RegExMatch(BC, "i)^0x[0-9a-f]{6}$") {
               MSG := "Parameter BC: Die Angabe " . BC . " ist ungültig!"
               Return
            }
            BC := SubStr(BC, 1, 2) . SubStr(BC, -1)
                . SubStr(BC, 5, 2) . SubStr(BC, 3, 2)
         }
      }
      If (GC = 0) {
         GC := Grid
      } Else {
         If (%GC% != "") {
            GC := %GC%
         } Else {
            If Not RegExMatch(GC, "i)^0x[0-9a-f]{6}$") {
               MSG := "Parameter GC: Die Angabe " . GC . " ist ungültig!"
               Return
            }
            GC := SubStr(GC, 1, 2) . SubStr(GC, -1)
                . SubStr(GC, 5, 2) . SubStr(GC, 3, 2)
         }
      }
      ; Achtung: HC wird als RGB-Wert benötigt!
      If (HC = 0) {
         HC := SubStr(Red, -1) . SubStr(Red, 5, 2) . SubStr(Red, 3, 2)
      } Else {
         If (%HC% != "") {
            HC := SubStr(%HC%, -1) . SubStr(%HC%, 5, 2) . SubStr(%HC%, 3, 2)
         } Else {
            If Not RegExMatch(HC, "i)^0x[0-9a-f]{6}$") {
               MSG := "Parameter HC: Die Angabe " . HC . " ist ungültig!"
               Return
            }
         }
      }
      If (GF != 0 And GF != 1) {
         MSG := "Der Parameter GF ist ungültig:`n" . GF
         Return
      }
      If PL Not Between 0 And 3
      {
         MSG := "Der Parameter PL ist ungültig:`n" . PL
         Return
      }
   Return
   ; ---------------------------------------------------------------------------
   ; Parameter SX und SY für Achsenbeschriftung auswerten
   ; ---------------------------------------------------------------------------
   __Diagramm__Achsen:
      MSG := ""
      SYW := SYH := SYM := 0
      SXT := SYT := ""
      ; Beschriftung der Y-Achse auswerten
      If (SY) {
         StringSplit, SY, SY, |
         Loop, %SY0% {
            StringSplit, SP, SY%A_Index%, `;
            If (SP0 = 3 And SP1 <> "" And SP3 <> "") {
               O := SP2 = "C" ? "0x200 Center"
                 :  SP2 = "R" ? "0x200 Right"
                 :  "0x200"
               Gui, %G#%:Add, Text, x%XD% y%YD% %O% hwndCTID Hidden, %SP3%
               ControlGetPos, , , SYW, SYH, , ahk_id %CTID%
               If (SYW > SYM) {
                  SYM := SYW
                  SYT := SP3
               }
            }
         }
      }
      ; Beschriftung der X-Achse auswerten
      If (SX) {
         StringSplit, SX, SX, |
         Loop, %SX0% {
            StringSplit, SP, SX%A_Index%, `;
            If (SP0 = 3 And SP2 <> "" And SP3 <> "") {
               SXT := SP3
               Break
            }
         }
      }
   Return
   ; ---------------------------------------------------------------------------
   ; Raster (Grid) zeichnen
   ; ---------------------------------------------------------------------------
   __Diagramm__Raster:
      ; now the grid
      PEN := DllCall("CreatePen", UInt, 0, UInt, 0, UInt, GC)
      DllCall("SelectObject", UInt, PDC, UInt, PEN)
      If (SY) {
         X := 0
         Loop, %SY0% {
            StringSplit, SP, SY%A_Index%, `;
            If (SP1 > 1 And SP1 < HD) {
               Y := SP1 - 1
               DllCall("MoveToEx", UInt, PDC, UInt, 0, UInt, Y, UInt, 0)
               DllCall("LineTo", UInt, PDC, UInt, WD, UInt, Y)
            }
         }
      }
      If (SX) {
         Y := 0
         Loop, %SX0% {
            StringSplit, SP, SX%A_Index%, `;
            SP1 *= FX
            If (SP1 > 1 And SP1 < WD) {
               X := SP1 - 1
               DllCall("MoveToEx", UInt, PDC, UInt, X, UInt, 0, UInt, 0)
               DllCall("LineTo", UInt, PDC, UInt, X, UInt, HD)
            }
         }
      }
      DllCall("DeleteObject", UInt, PEN)
   Return
}
; ==============================================================================
__Diagramm__Speichern(ByRef hBitMap, ByRef File)
{
   FileDelete, %File%
   VarSetCapacity(wFile, (StrLen(File) * 2) + 1)
   DllCall("kernel32\MultiByteToWideChar"
         , UInt, 0
         , UInt, 0
         , UInt, &File
         , Int, -1
         , UInt, &wFile
         , Int, StrLen(File) + 1)
   SplitPath, File, , , Ext
   hGDIPDLL := DllCall("LoadLibrary", Str, "GDIplus.dll")
   If (hGDIPDLL = 0) {
      Return, "Die GDIPlus.dll konnte nicht gefunden werden!"
   }
   VarSetCapacity(vGDIP, 4 * 4, 0)
   NumPut(1, vGDIP)
   RET := DllCall("GDIplus\GdiplusStartup"
                , UIntP, hGDIP
                , UInt, &vGDIP
                , UInt, 0)
   If (RET != 0) {
      DllCall("FreeLibrary", UInt, GDIPL)
      Return, "GDIPlus konnte nicht gestartet werden!"
   }
   hBM := 0
   DllCall("GDIplus\GdipCreateBitmapFromHBITMAP"
         , UInt, hBitMap
         , UInt, 0
         , UIntP, hBM)
   If (hBM = 0) {
      DllCall("GDIplus\GdiplusShutdown", UInt, hGDIP)
      DllCall("FreeLibrary", UInt, hGDIPDLL)
      Return, "GDIPlus: Das Diagrammbild konnte nicht erzeugt werden!"
   }
   DllCall("gdiplus\GdipGetImageEncodersSize"
         , UintP, nCount
         , UintP, nSize)
   VarSetCapacity(vEnc, nSize)
   DllCall("gdiplus\GdipGetImageEncoders"
         , Uint, nCount
         , Uint, nSize
         , Uint, &vEnc)
   Loop, %nCount% {
         pTypes := NumGet(vEnc, (76 * (A_Index - 1)) + 44)
         nSize :=DllCall("kernel32\WideCharToMultiByte"
                       , UInt, 0
                       , UInt, 0
                       , UInt, pTypes
                       , Int, -1
                       , UInt, 0
                       , Int,  0
                       , UInt, 0
                       , UInt, 0)
         VarSetCapacity(sTypes, nSize)
         DllCall("kernel32\WideCharToMultiByte"
               , UInt, 0
               , Uint, 0
               , Uint, pTypes
               , Uint, -1
               , Str, sTypes
               , UInt, nSize + 1
               , UInt, 0
               , UInt, 0)
         If !InStr(sTypes, "." . Ext)
            Continue
         pCodec := &vEnc + (76 * (A_Index - 1))
         Break
   }
   If (!pCodec) {
      DllCall("GDIplus\GdipDisposeImage", "Uint", hBM)
      DllCall("GDIplus\GdiplusShutdown"
            , UInt, hGDIP)
      DllCall("FreeLibrary", UInt, hGDIPDLL)
      Return, "GDIPlus:Es konnte kein passender Codec gefunden werden!"
   }
   RC := DllCall("GDIplus\GdipSaveImageToFile"
                , UInt, hBM
                , UInt, &wFile
                , UInt, pCodec
                , UInt, 0)
   DllCall("GDIplus\GdipDisposeImage", "Uint", hBM)
   DllCall("GDIplus\GdiplusShutdown", UInt, hGDIP)
   DllCall("FreeLibrary", UInt, hGDIPDLL)
   If (RC) {
      Return, "GDIPlus: Das Bild konnte nicht gespeichert werden! RC: " . RC
   }
   Return 0
}
; ==============================================================================
