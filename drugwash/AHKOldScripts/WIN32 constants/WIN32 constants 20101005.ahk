/* 

 'List of Win32 CONSTANTS' by SKAN - Suresh Kumar A N ( arian.suresh@gmail.com )
  Topic      : www.autohotkey.com/forum/viewtopic.php?t=19766
  Dependency : www.autohotkey.net/~Skan/Utils/List_of_WIN32_CONSTANTS/Constants.W32.ini
  Screenshot : www.autohotkey.net/~Skan/Utils/List_of_WIN32_CONSTANTS/Constants.W32.png

*/ ;                                              Created / Last Modified : 05-Oct-2010

#SingleInstance, Force
Menu, Tray,UseErrorLevel
Menu, Tray, Icon, shell32.dll, 44
SetWorkingDir, %A_ScriptDir%
IfNotExist, Constants.W32.ini, URLDownloadToFile
        , http://www.autohotkey.net/~Skan/Utils/List_of_WIN32_CONSTANTS/Constants.W32.ini
        , Constants.W32.ini
If ! LoadConstants( "Constants.W32.ini", Data, Cons )
  ExitApp
Gui, Margin, 5, 10
Gui, +LastFound
Gui, Font, s9 Normal, Arial
Gui, Add,  ComboBox, w480 R10 Simple 0x2000 vConstant gComboBoxRoutine, % SubStr(Cons,2)
Gui, Font, s10 Bold
Gui, Add,  Edit, y+0 wp h23 0x200 vValue c003046
Gui, Font, s9 Normal
Gui, Add,  ListView, wp r10 +Grid -Multi NoSortHdr Checked AltSubmit gListViewRoutine
        ,  Constant|Value
LV_ModifyCol( 1,"200" ), LV_ModifyCol( 2,"2000" ), Array:="|"
Gui, Add,  Button, w115 h25 +Default gSelectConstant, &Select Constant
Gui, Add,  Button, x+116 w80 hp  gClearList, Cle&ar List
Gui, Add,  Button, x+10 w160 hp gCopyToClipboard, &Copy List to Clipboard
Gui, Font, s8 Normal
Gui, Show,,List of WIN32 Constants ( 52927 )
Return ;                                                 // end of auto-execute section //

ComboBoxRoutine:
 GuiControlGet, Constant
 GuiControl,, Value,  % Value := pIniGetValue( Data,Constant )
Return

ListViewRoutine:
 IfNotEqual, A_GuiEvent, Normal, Return
 Row := LV_GetNext( 0,"Focused" ), LV_GetText( String,Row,1 )
 GuiControl, ChooseString, Constant, %String%
Return

SelectConstant:
 GuiControlGet, Constant
 If ( InStr( Array, "|" Constant "|" ) && DllCall( "Beep", UInt,400, UInt,200 ) )
   Return
 If ( ( Constants := ResolveDependencies( Constant, Data ) ) = "" )
   Return
 Loop, Parse, Constants, |
   If !InStr( Array, "|" ( Cons := A_LoopField ) "|" )
   && ( ( Val := pIniGetValue( Data, Cons := A_LoopField  ) ) <> "" )
      LV_Add( "Check Select", Cons, RegExReplace( Val, "\sOr\s", " | " ) )
    , LV_Modify( LV_GetCount(), "Vis" ), Array .= Cons "|"
 GuiControl, Focus, Constant
Return

ClearList:
 Array := "|", LV_Delete()
 GuiControl, Focus, Constant
Return

CopyToClipboard:
 While ( ( Row := LV_GetNext( Row, "Checked" ) ) && LV_Modify( Row, "-Check" ) )
   LV_GetText( Con,Row,1 ), LV_GetText( Val,Row,2 ), List .= Con " := " Val "`n"
 List ? ( Row:=0, Clipboard := List, List:="", DllCall( "Beep", UInt,1000, UInt,50 ) ) :
Return

GuiEscape:
GuiClose:
 ExitApp

;                                                              //  end of sub-routines  //

LoadConstants( INI, ByRef Data, ByRef Cons ) {
 FileRead, Data, %INI%
 IfNotEqual,ErrorLevel,0, Return 0
 StringTrimLeft, Data, Data, 13
 Cons := RegExReplace( Data, "=(.*?)\r\n", "|" )
 Sort, Cons, D|
Return 1
}

ResolveDependencies( Constant, ByRef Data ) {
 Static Rec := 0
 If ( ( Value := pIniGetValue( Data, Constant ) ) = "" || ( Rec := Rec + 1 ) > 20 )
    Return SubStr( Rec := 0, 0, 0  )
 If ( ( SubStr(Value,1,1) = """" && SubStr(Value,0) = """" ) || ( (Value+0) <> "" ) )
    Return Constant ; because value is either a string or a numerical value
 StringReplace, Value,Value, % " Or ",% " | ", All
 Constants := Constant
 Loop, Parse, Value, |+^/-, %A_Space%%A_Tab%()
    If ( ( Constant  := %A_ThisFunc%( A_LoopField, Data, Array ) ) <> "" )
       Constants := Constant "|" Constants
Return Constants
}

pIniGetValue( ByRef I,Key ) { ; www.autohotkey.com/forum/viewtopic.php?p=382194#382194
Return ( SubStr( ( Val := ( F := InStr(I,"`r`n" key "=")) ? SubStr(I, S := F+StrLen(Key)+3
    ,(C := InStr(I,"`r`n",0,S)) ? C-S : StrLen(I)-F ) : "" ),1,1) = """" || SubStr(Val,0 )
    = """" ) ? SubStr(Val,2,StrLen(Val)-2) : Val                             ; By SKAN
}


;                                                     //  end of user-defined functions //
