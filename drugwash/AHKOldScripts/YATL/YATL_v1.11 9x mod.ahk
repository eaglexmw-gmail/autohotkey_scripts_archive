;===============================+
; YATL - Yet Another Todo List	|
;-------------------------------|
; Version:  1.11                |
; Date:     12/2/2008           |
; Author:   rulfzid             |
;===============================+


;==============+
; AUTO-EXECUTE |
;===============================================================================
#SingleInstance, Force
#NoEnv

; Listbox message constants
;---------------------------------------
LB_INSERTSTRING := 0x181
LB_GETCURSEL := 0x188
LB_GETTEXT := 0x189
LB_GETTEXTLEN := 0x18A
LB_SETITEMDATA := 0x19A
LB_DELETESTRING := 0x182
LB_SETCURSEL := 0x186
LB_GETCOUNT := 0x18B
LB_GETITEMRECT := 0x198

; SendMessageProc - for faster DllCalls
;---------------------------------------
SendMessageProc := GetProcAddress("user32", "SendMessageA")

; Gui options
;---------------------------------------
yatl_font = Trebuchet MS
yatl_font_size = 10
yatl_font_color = White
yatl_tabstop = 12
yatl_margin = 10
yatl_bgcolor = 333333
yatl_control_bgcolor = 444444
yatl_guiW = 400
yatl_listboxH = 300

; Set the hotkeys
;---------------------------------------
Hotkey, IfWinActive, YATL ahk_class AutoHotkeyGUI
Hotkey, ^n,		_AddTask
Hotkey, ^e,		_EditTask
Hotkey, ^x,		CheckOffAndRemove
Hotkey, ^Del,	DeleteSelected
Hotkey, ^Right, Indent
Hotkey, ^Left,	Dedent
Hotkey, +Up,	MoveUp
Hotkey, +Down,	MoveDown
Hotkey, ^q,		Quit
Hotkey, IfWinExist, YATL ahk_class AutoHotkeyGUI
Hotkey, ^h,		ToggleHelpGui
Hotkey, Escape, yatlEscape
Hotkey, IfWinActive
Hotkey, ^t, ToggleMainGUI

; Create the Gui's
;---------------------------------------
createGui()
createHelpText()
createHelpGui()

; Load the saved todo lists
;---------------------------------------
LoadTodos(hList)

OnExit, SaveAndExit
return
;===============================================================================


;========================+
; AUTO-EXECUTE FUNCTIONS |
;===============================================================================
createGui() {
	global
	Gui, +lastfound -caption +alwaysontop
	gid := WinExist()
	Gui, Margin, %yatl_margin%, %yatl_margin%
	Gui, Color, %yatl_bgcolor%, %yatl_control_bgcolor%
	Gui, Font, s%yatl_font_size% c%yatl_font_color%, %yatl_font%
	Gui, Add, Text, , YET ANOTHER TODO LIST
	Gui, Font, s%yatl_font_size%
	Gui, Add, ListBox, h%yatl_listboxH% w%yatl_guiW% t%yatl_tabstop% vyatl_list HwndhList,
	Gui, Add, Edit, xp yp wp hp vyatl_help -vscroll +readonly Hidden, Help stuff
	Gui, Add, Edit, r1 w%yatl_guiW% -WantReturn Hidden vyatl_edit, 
	Gui, Add, Button, Default Hidden gAddOrEditTask, 
	Gui, Show, AutoSize, YATL
	yatl_shown = 1
}

createHelpGui() {
	global
	Gui, 2: +lastfound -caption +alwaysontop +owner1
	hid := WinExist()
	Gui, 2: Margin, %yatl_margin%, %yatl_margin%
	Gui, 2: Color, 555555
	2fsize := yatl_font_size - 1
	Gui, 2: Font, s%2fsize% c%yatl_font_color%, %yatl_font%
	Gui, 2: Add, Text, , YATL - Command List
	Gui, 2: Add, Text, -vscroll +readonly, %yatl_helptext%
	Gui, 2: Show, Hide AutoSize, Help
	yatl_help_shown = 0
}

createHelpText() {
	global
	yatl_helptext = 
	(LTrim
	Win-t`t`tHide/show YATL
	n`t`tAdd a new task
	e`t`tEdit a task
	x`t`tCheck off a task
	Delete`t`tDelete selected task
	Right`t`tIndent selected task
	Left`t`tDedent selected task
	Win-Up`t`tMove task up
	Win-Down`tMove task down
	Win-q`t`tQuit YATL
	Win-h`t`tToggle command list
	Escape`t`tEscape out of things
	)
}
;===============================================================================

;=====================+
; SHOW/HIDE THE GUI'S |
;===============================================================================
ToggleMainGui:
	If yatl_help_shown
		ToggleGui( hid, yatl_help_shown )
	ToggleGui( gid, yatl_shown )
return

ToggleHelpGui:
	GuiControlGet, focused_control, focusv
	If ( focused_control = "yatl_edit" )
		return
	ToggleGui( hid, yatl_help_shown )
return

ToggleGui( hWnd, ByRef isshown ) {
	If isshown
	{	WinHide, ahk_id %hWnd%
		isshown = 0
	} Else {
		WinShow, ahk_id %hWnd%
		isshown = 1
	}
}
;===============================================================================


;=========================+
; HOTKEYS AND SUBROUTINES |
;===============================================================================
CheckOffAndRemove:
	GuiControlGet, focused_control, focusv
	If ( focused_control != "yatl_list" )
		return	
	i := LB_GetCurrentSelection( hList )
	If (i < 0)
		return
	Gui, Submit, NoHide
	
	replaceStr := RegExReplace( yatl_list, "(\s*\[) (\])", "$1x$2" )
	LB_ReplaceString( hList, i, replaceStr )
	
	; Get the x,y,w,h of current list item
	VarSetCapacity( yatl_rect, 16 )
	DllCall( "SendMessage", UInt, hList, UInt, LB_GETITEMRECT, UInt, i, UInt, &yatl_rect )
	yatl_rect_x := NumGet( yatl_rect, 0, Int )
	yatl_rect_y := NumGet( yatl_rect, 4, Int )
	yatl_rect_w := NumGet( yatl_rect, 8, Int ) - yatl_rect_x
	yatl_rect_h := NumGet( yatl_rect, 12, Int ) - yatl_rect_y

	; Get the coordinates for the YATL GUI and the listbox within it
	WinGetPos, gX,gY, , , ahk_id %gid%	
	ControlGetpos, lX, lY, , , , ahk_id %hList%

	; Using info above, set coordinate so new GUI will be positioned
	; exactly over the current list item
	; (the extra "2" is to account for the with of the border of the
	; listbox - so far it's been 2 pixels on Vista and XP)
	itemX := gX + lx + yatl_rect_x + 2
	itemY := gY + ly + yatl_rect_y + 2

	; Create second, temporary GUI 
	Gui, 99: +toolwindow -caption +alwaysontop +lastfound
	99gid := WinExist()
	Gui, 99: color, green, green

	; Position it over the selected list item (the "99" accounts for the 
	; 99 pixels of WS_EXCLIENTEDGE for the listbox - on XP and Vista, at least
	; Show the temporary GUI, then fade it out
	Gui, 99: Show, x%itemX% y%itemY% w%yatl_rect_w% h%yatl_rect_h%,
	AnimateWindow( 99gid, 500, 0x90000 )
	Gui, 99: destroy

	; Delete the list item
	LB_DeleteString( hList, i )
return

_AddTask:
	GuiControlGet, focused_control, focusv
	If (focused_control != "yatl_list")
		return
	yatl_action := "add"
	GuiControl, Show, yatl_edit	
	Gui, Show, Autosize
	GuiControl, Focus, yatl_edit
return

_EditTask:
	GuiControlGet, focused_control, focusv
	If (focused_control != "yatl_list")
		return
	yatl_action := "edit"
	Gui, Submit, NoHide
	RegExMatch(yatl_list, "(\s*\[.\] )(.*)", yedit)
	
	; This is so trying to "edit" tasks when the list is empty behaves properly
	yedit1 := yedit1 ? yedit1 : "[ ] "
	
	Guicontrol, , yatl_edit, %yedit2%
	GuiControl, Show, yatl_edit	
	Gui, Show, Autosize
	GuiControl, Focus, yatl_edit
return

AddOrEditTask:
	Gui, Submit, NoHide
	If not yatl_edit
		return
	If (yatl_action = "add")
	{	yatl_edit := "[ ] " . yatl_edit
		i := LB_GetCurrentSelection(hList)
		i := (i >= 0) ? i + 1 : i
		LB_InsertString(hList, i, yatl_edit)
	}
	If (yatl_action = "edit")
	{	i := LB_GetCurrentSelection(hList)
		yatl_edit := yedit1 . yatl_edit
		LB_ReplaceString(hList, i, yatl_edit)
	}
	GuiControl, Hide, yatl_edit
	GuiControl, , yatl_edit, 
	Gui, Show, Autosize
return

DeleteSelected:
	GuiControlGet, focused_control, focusv
	If (focused_control != "yatl_list")
		return	
	i := LB_GetCurrentSelection(hList)
	If (i < 0)
		return
	LB_DeleteString(hList, i)
return

Indent:
Dedent:
	GuiControlGet, focused_control, focusv
	If (focused_control != "yatl_list")
		return
	i := LB_GetCurrentSelection(hList)
	If (i < 0)
		return
	Gui, Submit, NoHide
	If (A_ThisLabel = "Indent")
		replaceStr := "`t" . yatl_list
	If (A_ThisLabel = "Dedent")
		replaceStr := (Substr(yatl_list, 1, 1) = "`t") ? Substr(yatl_list, 2) : yatl_list
	LB_ReplaceString(hList, i, replaceStr)
return

MoveUp:
MoveDown:
	GuiControlGet, focused_control, focusv
	If (focused_control != "yatl_list")
		return
	i := LB_GetCurrentSelection(hList)
	If (i < 0)
		return	
	If ( A_ThisLabel = "MoveUp") and ( (j:=i-1) < 0 )
		return
	If ( A_ThisLabel = "MoveDown") and ( (j:=i+1) >= LB_GetCount( hList ) )
		return
	LB_SwapMove(hList, i, j)
return

~Up::
~Down::
	IfWinActive, YATL
		ControlSend, , {%A_ThisHotkey%}, ahk_id %hList%
return

yatlEscape:
	GuiControlGet, editisvisible, Visible, yatl_edit
	If editisvisible
	{	GuiControl, , yatl_edit, 
		GuiControl, Hide, yatl_edit
		Gui, Show, Autosize
	} 
	Else If yatl_help_shown
		Gosub, ToggleHelpGui
	Else 
	{	WinHide, ahk_id %gid%
		WinActivate, ahk_id %curractive%
        shown := 0
	}
return

GuiClose:
Quit:
	ExitApp
return

SaveAndExit:
	SaveToDos(hList)
	ExitApp
Return
;===============================================================================


;=====================+
; SAVE/LOAD FUNCTIONS |
;===============================================================================
SaveToDos(hWnd) {
	cnt := LB_GetCount(hWnd)
	Loop, % cnt
		todos .= LB_GetString(hWnd, A_Index - 1) . "`n"
	StringTrimRight, todos, todos, 1
	Loop, Read, %A_ScriptFullPath%
	{	thisscript .= A_LoopReadLine . "`n"
		If InStr(A_LoopReadLine, "Saved YATL List") and not Instr(A_LoopReadLine, "InStr")
			break
	}
	FileDelete, %A_ScriptFullPath%
	FileAppend, %thisscript%%todos%, %A_ScriptFullPath%	
}

LoadToDos(hWnd) {
	istodo = 0
	Loop, Read, %A_ScriptFullPath%
	{	If istodo
		{	If A_LoopReadline
				todos .= A_LoopReadLine . "`n"
			continue
		}
		If InStr(A_LoopReadLine, "Saved YATL List") and not Instr(A_LoopReadLine, "InStr")
			istodo = 1
	}
	StringTrimRight, todos, todos, 1
	Loop, Parse, Todos, `n
		LB_InsertString(hWnd, -1, A_LoopField)		
}
;===============================================================================


;===========================+
; DLLCALL WRAPPER FUNCTIONS |
;===============================================================================
AnimateWindow( hWnd, Duration, Flag) {
	Return DllCall( "AnimateWindow", UInt, hWnd, Int, Duration, UInt, Flag )
}



GetProcAddress(dll, funcname) {
	return DllCall("GetProcAddress", UInt, DllCall("GetModuleHandle", Str, dll) ,Str, funcname)
}

LB_GetCurrentSelection(hWnd) {
	global SendMessageProc
	global LB_GETCURSEL
	Return DllCall(SendMessageProc, UInt, hWnd, UInt, LB_GETCURSEL, UInt, 0, UInt, 0)
}

LB_SwapMove(hWnd, from_index, to_index) {
	global SendMessageProc
	global LB_GETTEXTLEN, LB_GETTEXT, LB_DELETESTRING, LB_INSERTSTRING, LB_SETCURSEL
	If (DllCall(SendMessageProc, UInt, hWnd, UInt, LB_GETTEXTLEN, UInt, j, UInt, 0) < 0)
		return
	lo := (from_index < to_index) ? from_index : to_index
	len := DllCall(SendMessageProc, UInt, hWnd, UInt, LB_GETTEXTLEN, UInt, lo, UInt, 0)
	VarSetCapacity(tmp, len)
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_GETTEXT, UInt, lo, UInt, &tmp)
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_DELETESTRING, UInt, lo, UInt, 0)
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_INSERTSTRING, UInt, lo + 1, UInt, &tmp)
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_SETCURSEL, UInt, to_index, UInt, 0)
}

LB_InsertString(hWnd, index, string) {
	global SendMessageProc
	global LB_INSERTSTRING, LB_SETCURSEL	
	i := DllCall(SendMessageProc, UInt, hWnd, UInt, LB_INSERTSTRING, UInt, index, UInt, &string)
	Sleep, -1
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_SETCURSEL, UInt, i, UInt, 0)
	Return i
}

LB_ReplaceString(hWnd, index, string) {
	global SendMessageProc
	global LB_DELETESTRING
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_DELETESTRING, UInt, index, UInt, 0)
	LB_InsertString(hWnd, index, string)
}

LB_DeleteString(hWnd, index) {
	global SendMessageProc
	global LB_DELETESTRING
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_DELETESTRING, UInt, index, UInt, 0)
	cnt := LB_GetCount( hWnd )
	LB_SelectThis( hWnd, (index >= cnt) ? (index - 1) : (index) )
}

LB_GetString(hWnd, index) {
	global SendMessageProc
	global LB_GETTEXTLEN, LB_GETTEXT
	len := DllCall(SendMessageProc, UInt, hWnd, UInt, LB_GETTEXTLEN, UInt, index, UInt, 0)
	VarSetCapacity(tmp, len)
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_GETTEXT, UInt, index, UInt, &tmp)
	return tmp
}

LB_GetCount(hWnd) {
	global SendMessageProc
	global LB_GETCOUNT
	return DllCall(SendMessageProc, UInt, hWnd, UInt, LB_GETCOUNT, UInt, 0, UInt, 0)
}

LB_SelectThis(hWnd, index) {
	global SendMessageProc
	global LB_SETCURSEL
	DllCall(SendMessageProc, UInt, hWnd, UInt, LB_SETCURSEL, UInt, index, UInt, 0)
}
;===============================================================================


/*******************************************************************************
/*************** DO NOT MODIFY BELOW THIS LINE: Saved YATL List ****************
[ ] The YATL tutorial - try me out!
	[ ] 1. Press Win-t to toggle the main window
	[ ] 2. Press Win-h to view the command list
	[ ] 3. Press n to add a new task
	[ ] 4. Press e to edit a task
	[ ] 5. Press x to check off completed tasks
	[ ] 6. Use the Right and Left arrows to indent/dedent
	[ ] 7. Move tasks up and down with Shift-Up and Shift-Down
	[ ] 8. Press Delete to remove tasks
	[ ] 9. Finally, Win-q quits YATL
		[ ] task1
			[ ] task2