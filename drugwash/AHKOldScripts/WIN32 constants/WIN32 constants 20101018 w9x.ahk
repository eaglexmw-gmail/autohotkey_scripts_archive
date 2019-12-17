/* 

 'List of Win32 CONSTANTS' by SKAN - Suresh Kumar A N, arian.suresh@gmail.com 
  Topic      : www.autohotkey.com/forum/viewtopic.php?t=19766
  Dependency : www.autohotkey.net/~Skan/Utils/List_of_WIN32_CONSTANTS/Constants.W32.ini
  Screenshot : www.autohotkey.net/~Skan/Utils/List_of_WIN32_CONSTANTS/Constants.W32.png

*/ ;                                  Created: 05-Oct-2010 / Last Modified: 18-Oct-2010

#SingleInstance, Force
Menu, Tray,UseErrorLevel
Menu, Tray, Icon, shell32.dll, 44
SetBatchLines -1
SetControlDelay, -1
SetWinDelay, -1
ListLines, off
SetWorkingDir, %A_ScriptDir%
w9x := (A_OSType = "WIN32_WINDOWS")
IfNotExist, Constants.W32.9x.txt, URLDownloadToFile
 , http://www.autohotkey.net/~Skan/Utils/List_of_WIN32_CONSTANTS/Constants.W32.ini
 , Constants.W32.ini
 
if !w9x
	If ! LoadConstants( "Constants.W32.ini", Data, Cons )
		  ExitApp
 
Gui, Margin, 5, 10
Gui, +LastFound
Gui, Font, s9 Normal, Arial
if w9x
	{
	Gui, Add, Edit, w480 h21 Uppercase vConstant gEditRoutine,
	Gui, Add,  ListView, y+1 w480 R10 AltSubmit Count60000 -Hdr -Multi Sort ReadOnly vLV2 gListView2Routine, Constants
	If ! LoadConstants( "Constants.W32.ini", Data, Cons )
	  ExitApp
	}
else
	Gui, Add,  ComboBox, w480 R10 Simple 0x2000 vConstant gComboBoxRoutine, % SubStr( Cons,2 )
Gui, Font, s10 Bold
Gui, Add,  Edit, y+0 wp h23 0x200 vValue c003046
Gui, Font, s9 Normal
Gui, Add,  ListView, wp r10 +Grid -Multi NoSortHdr Checked AltSubmit gListViewRoutine
        ,  Constant|Value
LV_ModifyCol( 1,"200" ), LV_ModifyCol( 2,"2000" ), Array:="|"
Gui, Add,  Button, w115 h25 +Default Section gSelectConstant, &Select Constant
Gui, Add,  Button, x+10 yp w100 hp, Copy &value
Gui, Add,  Button, xp y+0 w100 hp, Copy &name
Gui, Add,  Button, x+10 ys w160 hp gCopyToClipboard, &Copy List to Clipboard
Gui, Add,  Button, xp y+0 w80 hp  gClearList, Cle&ar List
Gui, Add,  Button, x+90 ys w75 hp, E&xit
Gui, Font, s8 Normal
Gui, Show,,List of WIN32 Constants ( 52927 )
Return

EditRoutine:
Gui, Submit, NoHide
Gui, ListView, SysListView321
Loop, % LV_GetCount()
	{
	LV_GetText(i, A_Index)
	if InStr(i, Constant) = 1
		{
		LV_Modify(A_Index+9, "-Select Vis -Focus")
		LV_Modify(A_Index, "Select Vis -Focus")
		break
		}
	}
 GuiControl, Focus, Constant
Return

ListView2Routine:
IfEqual, A_GuiEvent, DoubleClick, goto SelectConstant
 If A_GuiEvent not in Normal
	Return
 Gui, ListView, SysListView321
 LV_GetText(Constant, A_EventInfo)
 GuiControl,, Constant,  %Constant%
 GuiControl,, Value,  % Value := pIniGetValue( Data,Constant )
Return

ComboBoxRoutine:
 GuiControlGet, Constant
 GuiControl,, Value,  % Value := pIniGetValue( Data,Constant )
Return

ListViewRoutine:
 IfNotEqual, A_GuiEvent, Normal, Return
 Gui, ListView, SysListView322
 Row := LV_GetNext( 0,"Focused" ), LV_GetText( String,Row,1 )
if w9x
	{
	Gui, ListView, SysListView321
	Loop % LV_GetCount()
		{
		LV_GetText(i, A_Index)
		if (i = String)
			{
			LV_Modify(A_Index, "Select Vis")
			break
			}
		}
	}
else
 GuiControl, ChooseString, Constant, %String%
Return

SelectConstant:
 GuiControlGet, Constant
 If ( InStr( Array, "|" Constant "|" ) && DllCall( "Beep", UInt,400, UInt,200 ) )
   Return
 If ( ( Constants := ResolveDependencies( Constant, Data ) ) = "" )
   Return
if w9x
	Gui, ListView, SysListView322
 Loop, Parse, Constants, |
   If !InStr( Array, "|" ( Cons := A_LoopField ) "|" )
   && ( ( Val := pIniGetValue( Data, Cons := A_LoopField  ) ) <> "" )
      LV_Add( "Check Select", Cons, RegExReplace( Val, "\sOr\s", " | " ) )
    , LV_Modify( LV_GetCount(), "Vis" ), Array .= Cons "|"
 GuiControl, Focus, % (w9x ? "LV2" : "Constant")
Return

ClearList:
if w9x
	Gui, ListView, SysListView322
 Array := "|", LV_Delete()
 GuiControl, Focus, % (w9x ? "LV2" : "Constant")
Return

CopyToClipboard:
if w9x
	Gui, ListView, SysListView322
 While ( ( Row := LV_GetNext( Row, "Checked" ) ) && LV_Modify( Row, "-Check" ) )
   LV_GetText( Con,Row,1 ), LV_GetText( Val,Row,2 ), List .= Con " := " Val "`n"
 List ? ( Row:=0, Clipboard := List, List:="", DllCall( "Beep", UInt,1000, UInt,50 ) ) :
Return

ButtonCopyvalue:
v := pIniGetValue( Data,Constant )
r := ResolveDependencies( Constant, Data )
v2 := pIniGetValue( Data,v )
msgbox, value=%v%`ndependencies=%r%`nresolved=%v2%
 Clipboard := v2 ? v2 : v
GuiControl, Disable, Button2
GuiControl,, Button2, Value copied
SetTimer, bt2, 1500
Return

ButtonCopyname:
 Clipboard := Constant
GuiControl, Disable, Button3
GuiControl,, Button3, Name copied
SetTimer, bt, 1500
Return

bt:
SetTimer, bt, off
GuiControl, Enable, Button3
GuiControl,, Button3, Copy &name
Return

bt2:
SetTimer, bt, off
GuiControl, Enable, Button2
GuiControl,, Button2, Copy &value
Return

GuiEscape:
GuiClose:
ButtonExit:
 ExitApp


LoadConstants( INI, ByRef Data, ByRef Cons ) {
Global w9x
FileRead, Data, %INI%
 IfNotEqual,ErrorLevel,0, Return 0
 StringTrimLeft, Data, Data, 13
if w9x
	{
	Gui, ListView, SysListView321
	GuiControl, -Redraw, SysListView321
	StringTrimLeft, Data1, Data, 8
	Loop, Parse, Data1, `n, `r
		{
		StringSplit, i, A_LoopField, `=
		LV_Add("", i1)
		Cons .= i1 "|"
		}
	LV_ModifyCol(1, 460)
	GuiControl, +Redraw, SysListView321
	Sort, Cons, D|
	}
else
	{
	Loop, Read, %INI%
	    Cons .= SubStr(A_LoopReadLine,1, InStr( A_LoopReadLine,"=" )-1 ) "|"
	 StringTrimLeft, Cons, Cons, 11
	 Sort, Cons, D|
	}
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