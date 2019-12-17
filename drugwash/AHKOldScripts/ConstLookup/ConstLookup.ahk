SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On
Menu, Tray, Icon, C:\Windows\System\USER.EXE, 5 ; For Win98, provide fullpath or comment out this line

Gui, 1:Margin, 0, 2
Gui, 1:+AlwaysOnTop +ToolWindow +LastFound
CSV := "W32C_R01.CSV" , GuiH := WinExist() , Con := 0

IfNotExist,%CSV%, URLDownloadToFile,http://www.autohotkey.net/~goyyah/resource/%CSV%,%CSV%

Loop, Read, %CSV%
  Loop, Parse, A_LoopReadLine, CSV
     If ( A_Index = 1 )
        Lst .= A_LoopField "|" , Con := Con + 1

CBS_SORT := 0x100 , CBS_UPPERCASE := 0x2000
Gui, Add, ComboBox, w275 R9 +%CBS_UPPERCASE% +%CBS_SORT% Simple AltSubmit vSelected, %Lst%
Gui, Show, Hide , WIN32 Constants [ Total : %Con% ]
Gui, Add, Button, +Default gSendInput, &SendInput
WinGetPos,,, GW, GH, ahk_id %GuiH%
Menu, Tray, Tip, WIN32 Constants [ Total : %Con% ]
Return                                              ;     //   End of Auto-Execute Section

^i::GoSub, LookupGUI                          ; <- Note: Redefine Hotkey as per need

LookupGUI:
  IfWinActive, ahk_id %GuiH%,,,, Return

  X := ( A_CaretX = "" ? 0 : A_CaretX )
  Y := ( A_CaretY = "" ? 0 : A_CaretY )
  If ( X + GW  > A_ScreenWidth )
       X := A_ScreenWidth  - GW - 10
  If ( Y + GH > A_ScreenHeight )
       Y := A_ScreenHeight - GH - 10

  Gui, 1:Show, x%x% y%y%
Return

SendInput:
  Gui 1:Hide
  GuiControlGet, Selected
  FileReadLine, Constant, %CSV%, %Selected%
  rCon := RmvLTQ( AGetF( Constant, 1, "," ) )
  rVal := HexVal( RmvLTQ( AGetF( Constant, 2, "," ) ) )
  SendInput, % rCon " := " rVal
Return

GuiClose:
GuiEscape:
  Gui, 1:Hide
Return


AGetF( Str="", Fld=1, D="" )                   {  ;                        ArrayGetField()
  Loop,Parse,Str, % ( D="" ? "|" : D )
    IfEqual,A_Index,%Fld%, Return,A_LoopField
}

RmvLTQ( Str="" )                               {  ;          RemoveLeadingTrailingQuotes()
  RegExMatch( Str ,"^""?(.*?)""?$", Str )
Return Str1
}

HexVal( Int )                                  {  ;                             HexValue()
  If Int is not Digit
     Return Int
  SetFormat, Integer, Hex
  Hex := Int + 0
  StringUpper, Hex, Hex
  SetFormat, Integer, Decimal
  StringReplace, Hex, Hex, X, x
Return Hex
}
