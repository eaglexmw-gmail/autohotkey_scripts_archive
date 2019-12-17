#Singleinstance, force 
#NoEnv
SetBatchLines, -1
DetectHiddenWindows, On

	Gui, +LastFound +Resize 
	hGui := WinExist() 
	Gui, Show, w600 h300 hide

	Gui, Font, s11, Courier New

  ;create image list
	hIL := IL_Create(10, 0, 1) 
	loop, 20
	   IL_ADD(hIL, A_WinDir "\system32\shell32.dll", A_Index) 

  ;create edit
	Gui, Add, Edit, HWNDhLog w100 h100

  ;create combo
	Gui, Add, ComboBox, HWNDhCombo gOnCombo w80, item 1 |item 2|item 3

  ;create toolbar
	hToolbar := Toolbar_Add(hGui, "OnToolbar", "FLAT WRAPABLE", 1, "x0")
	Toolbar_AddButtons(hToolbar, "123`nabc`n123`nabc`n`n123`nabc`n123`nabc`n")
	Toolbar_AutoSize(hToolbar, "fit")

  ;create toolbar menu
	hMenu := Toolbar_Add(hGui, "OnToolbar", "menu", 0, "x0")
	Toolbar_AddButtons(hMenu, "File,`nEdit`nView`nFavorites`nTools`nHelp")
	Toolbar_AutoSize(hMenu, "fit")

  ;create rebar	
	hRebar := Rebar_Add(hGui, "", hIL)	
	ReBar_AddBand(hRebar, hLog, "mw 500", "L 400", "T Log")
	ReBar_AddBand(hRebar, hCombo, "L 300", "I 4", "T dir")
	ReBar_AddBand(hRebar, hToolbar, "mW 45", "S usechevron" )
	ReBar_AddBand(hRebar, hMenu, "mW 45", "P 1", "S usechevron")

	layout := "10002 356 0|10003 214 0|10001 400 1|10004 290 1"
	Rebar_SetLayout(hRebar, layout)

  ;create notepad
;	Run, Notepad,,Hide
;	winwait, Untitled
;	hNotepad := WinExist("Untitled")
;	WinSet, Style, -0xC00000, ahk_id %hNotepad%
;	WinSet, Style, -0x40000, ahk_id %hNotepad%
;	reNotepad := Rebar_AddBand(hRebar, hNotepad, "L 300", "mh 140", "T Note", "I 17")

  ;Add other GUI controls
	h := Rebar_Height(hRebar) + 90

	Gui, Font, s9
	Gui, Add, Text, y%h% xm , F1 to recall initial layout     F2 to toggle lock      F3 to show layout
	Gui, Add, Text, y+10 xm , F4 to load layout from Log
	Gui, Show

	;Rebar_ShowBand(hRebar, reNotepad, false)	;for redrawing notepad
 	;Rebar_ShowBand(hRebar, reNotepad, true)
return 

#IfWinActive, _Test
F1::
;	layout := "10001 120 1|10003 243 0|10002 370 1|10004 230 1"
	layout := "10002 356 0|10003 214 0|10001 400 1|10004 290 1"
	Rebar_SetLayout(hRebar, layout)
return

F2::
	Rebar_Lock(hRebar, "~")
return

F3::
	Log(Rebar_GetLayout(hRebar))
return

F4::
	ControlGetText, layout, ,ahk_id %hLog%
	Rebar_SetLayout(hRebar, layout)
return


OnToolbar(h, e, p, t, i){
	ifEqual, e, hot, return
	Log(e "  " t " (" p ")")
} 

GuiClose:
	WinClose, ahk_id %hNotepad%
	ExitApp
return

GuiSize:
	Rebar_ShowBand(hRebar, 1)
return

OnCombo:
	Log( "combo event" )
return

Log(txt){
	global hLog
	ControlSetText, , %txt%, ahk_id %hLog% 
}


#include Rebar.ahk
#include Toolbar.ahk