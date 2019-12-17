SetWorkingDir, %A_ScriptDir%
CSV := "W32C_R01.CSV"

Gui, Font, s8, Tahoma
Gui, Add, ListView, w640 h480 +Grid, Constant|Value|Hex|Remarks
LV_ModifyCol( 1, "300" )      , LV_ModifyCol( 2, "Integer 85" )
LV_ModifyCol( 3, "Right 85" ) , LV_ModifyCol( 4, "Center 150" )

Loop, Read, %CSV% 
   {
     Loop, Parse, A_LoopReadLine, CSV
           F%A_Index% := A_LoopField
     LV_Add( "", F1, F2, HexVal( F2 ), F3 )
   }
Gui, Show, , ListView of Win32 Constants
Return

HexVal( Int ) {                                   ;  HexValue()
  SetFormat, Integer, Hex
  Hex := Int + 0
  StringUpper, Hex, Hex
  SetFormat, Integer, Decimal
  StringReplace, Hex, Hex, X, x
Return Hex
}

GuiClose:
  ExitApp
