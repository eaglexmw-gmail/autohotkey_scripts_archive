toolbar32_Initialize() {
	CommandRegister("Toolbar32 Create", "Toolbar32_Add")
	CommandRegister("Toolbar32 SetMetrics", "Toolbar32_SetMetrics")
	CommandRegister("Toolbar32 SetImageList", "Toolbar32_SetImageList")
}

toolbar32_Create(ByRef A_Args) {

	name := getValue(A_Args, "name")
	style := getValue(A_Args, "style")
	callback := getValue(A_Args, "callback")

	x := getValue(A_Args, "x")
	y := getValue(A_Args, "y")
	w := getValue(A_Args, "w")
	h := getValue(A_Args, "h")

	if (InStr(style, "Hidden"))
		options := "Hidden"
	
	Gui, 1:Add,Picture, x%x% y%y% w%w% h%h% HWNDtoolbarhWnd %options%
	addValues(A_Args, "/hwnd:" . toolbarhWnd)

	static TOOLBARCLASSNAME  = "ToolbarWindow32"
	static WS_CHILD := 0x40000000, WS_VISIBLE := 0x10000000, WS_CLIPSIBLINGS = 0x4000000, WS_CLIPCHILDREN = 0x2000000
	static TBSTYLE_EX_DRAWDDARROWS = 0x1, TBSTYLE_EX_HIDECLIPPEDBUTTONS=0x10, TBSTYLE_EX_MIXEDBUTTONS=0x8   ;extended styles
	static TBSTYLE_WRAPABLE = 0x200, TBSTYLE_FLAT = 0x800, TBSTYLE_LIST=0x1000, TBSTYLE_TOOLTIPS=0x100, TBSTYLE_TRANSPARENT = 0x8000
	static TBSTYLE_BORDER=0x800000, TBSTYLE_ADJUSTABLE = 0x20
	static init, TB_BUTTONSTRUCTSIZE=0x41E, TB_SETEXTENDEDSTYLE := 0x454, TB_SETUNICODEFORMAT := 0x2005

	hStyle = 0
	loop, parse, style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		ifEqual, A_LoopField,,continue
		hStyle |= A_LoopField+0 ? A_LoopField : TBSTYLE_%A_LoopField%
	}

	hToolbar := DllCall("CreateWindowEx" 
		, "uint", 0
		, "str",  TOOLBARCLASSNAME 
		, "uint", 0 
		, "uint", WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | hStyle
		, "uint", 0, "uint", 0, "uint", 0, "uint", 0 
		, "uint", toolbarhWnd 
		, "uint", 0 
		, "uint", 0 
		, "uint", 0, "Uint")

	if (hToolbar = "") {
		logA("Create toolbar failed")
		Return
	}

	SendMessage, TB_BUTTONSTRUCTSIZE, 20, 0, , ahk_id %hToolbar%
	SendMessage, TB_SETEXTENDEDSTYLE, 0, TBSTYLE_EX_DRAWDDARROWS|TBSTYLE_EX_MIXEDBUTTONS, , ahk_id %hToolbar%
	SendMessage, TB_SETUNICODEFORMAT, 0, 0, , ahk_id %hToolbar%        ;set to ANSI
	Subclass(toolbarhWnd, "ToolbarWindowProc")

	addValues(A_Args, "/handle:" . hToolbar)

	return toolbarhWnd 
}

Subclass(hCtrl, func, cbOpt="") {
	oldProc := DllCall("GetWindowLong", "uint", hCtrl, "uint", -4)
	ifEqual, oldProc, 0, return 0

	WndProc := RegisterCallback(func, cbOpt, 4, oldProc)
	ifEqual, WndProc, , return 0

	return DllCall("SetWindowLong", "UInt", hCtrl, "Int", -4, "Int", WndProc, "UInt")
}

ToolbarWindowProc(hwnd, uMsg, wParam, lParam){

	if uMsg = 0x4E
		return Toolbar_OnNotify(wparam, lparam)
	return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
}

Toolbar_onNotify(wparam, lparam) {

	static NM_CLICK = -2
	static NM_RCLICK = -5
	static TBN_HOTITEMCHANGE = -713

	code :=  NumGet(lparam+8) - 4294967296

	if (code  = NM_CLICK) {
		id  :=  NumGet(lparam+12)
		if (id < 100) {
			hWnd  :=  NumGet(lparam+0)
			entry := syslist_Get("Controls", "/single:Yes /filter:handle=" . hWnd)
			if (entry <> "") {
				callback := getValue(entry, "callback")
				if (callback <> "") {
					addValues(entry, "/id:" . id)
					COMMAND(callback, entry)
				}
			}
			NOTIFY("UI Click" . hWnd, " /id:" . id " /toolbar:" . hWnd)
		}
	}  else if (code = NM_RCLICK) {
		id :=  NumGet(lparam+12)
		if (id < 100) {
			handle  :=  NumGet(lparam+0)
			entry := syslist_Get("Controls", "/single:Yes /filter:handle=" . handle)
			if (entry <> "") {
				callback := getValue(entry, "rightClickCallback")
				if (callback <> "") {
					addValues(entry, "/id:" . id)
					COMMAND(callback, entry)
				}
			}
		}
	} else if (code = TBN_HOTITEMCHANGE) {
		hWnd  :=  NumGet(lparam+0)
		id := NumGet(lparam+16)
Critical
		entry := syslist_Get("Controls", "/single:Yes /filter:handle=" . hwnd)

		if (entry <> "") {
; TODO-1: thread issues
STATE_SET("Toolbar tooltipId", id)
			control := getValue(entry, "control")
			toolbar_MouseOver("")
			toolbar_MouseOver(control)
		}
Critical,Off
;	} else {
;		log("code:" . code)
;		id :=  NumGet(lparam+12)
;		log("id:" . id)
	}
}

Toolbar32_GetToolbarMeta(A_Args) {
	control := getValue(A_Args, "control")
	
	toolbar32Meta := syslist_Get("Controls", "/single:Yes /filter:name=" . control)
	if (toolbar32Meta = "") {
		log("Invalid toolbar control:" . control)
	}
	return toolbar32Meta
}

Toolbar32_SetImageList(A_Command, A_Args) {

	toolbar32Meta := Toolbar32_GetToolbarMeta(A_Args)
	hToolbar := getValue(toolbar32Meta, "handle")

	if (hToolbar = "") {
		log("Invalid Toolbar:" . A_Args)
		Return
	}

	hIL := getValue(toolbar32Meta, "imageList")
	if (hIL <> "")
		IL_Destroy(hIL)

	hIL := getValue(A_Args, "imageList")
	
	toolbar32NewMeta := toolbar32Meta
	replaceValue(toolbar32NewMeta, "imageList", hIL)
	syslist_Replace("Toolbar32", toolbar32NewMeta, toolbar32Meta)

	static TB_SETIMAGELIST=0x430, TB_INSERTBUTTON=0x415
	static BTNS_AUTOSIZE=0x10

	VarSetCapacity(TBB, 20, 0) 
	NumPut(4, TBB, 8, "Char")      ;TBSTATE_ENABLED 
	NumPut(BTNS_AUTOSIZE, TBB, 9, "Char")

	count:= Toolbar_GetButtonCount(hToolbar)
	Loop, %count%
	{
		Toolbar_DeleteButton(hToolbar, 1)
	}

	SendMessage, TB_SETIMAGELIST, 0, hIL, ,ahk_id %hToolbar%
	count := DllCall("comctl32.dll\ImageList_GetImageCount", "uint", hIL)

	Loop, %count%
	{ 
		NumPut(A_Index-1, TBB, 0) 
		NumPut(A_Index, TBB, 4)
		SendMessage, TB_INSERTBUTTON, A_Index-1, &TBB, ,ahk_id %hToolbar% 
	}
}

Toolbar_GetImageList(tbm)
{
    return DllCall("SendMessage","uint",tbm,"uint",0x431,"uint",0,"uint",0)
}


;----------------------------------------------------------------------------------------------
;Function:  SetButtonInfo
;         Set button information
;
;Parameters:
;         hToolbar   - HWND of the toolbar
;         id         - Button identification (currently equal to buttons position)
;         text      - Text to set for the button. If "" text will not be changed. If "-" text wil be removed (the same as omiting both text and state parameters)
;         state      - List of button states to set, separated by white space. See bellow.
;
; Button states:
;         CHECKED, ENABLED, HIDDEN, GRAYED, PRESSED, CLICKED
;
; Returns:
;         Nonzero if successful, or zero otherwise.
;
Toolbar_SetButtonInfo(hToolbar, id, text="", state="", width=""){
   static TB_SETBUTTONINFO=0x442, TBIF_TEXT=2, TBIF_STATE=4, TBIF_SIZE=0x40, TB_AUTOSIZE=0x421
   static TBSTATE_CHECKED=1, TBSTATE_ENABLED=4, TBSTATE_HIDDEN=8, TBSTATE_GRAYED=16, TBSTATE_PRESSED=5, TBSTATE_CLICKED=6, TBSTATE_WRAP=32

   hstate := 0
   loop, parse, state, %A_Tab%%A_Space%, %A_Tab%%A_Space%
   {
      ifEqual, A_LoopField,,continue
      hstate |= TBSTATE_%A_LOOPFIELD%
   }

   mask := 0
   mask |= text != "" ?  TBIF_TEXT : 0
   mask |= state!= "" ?  TBIF_STATE : 0
   mask |= width!= "" ?  TBIF_SIZE : 0

   if text = -
      text =
   if (state text = "")
      mask := TBIF_TEXT, text := ""

   VarSetCapacity(BI, 32, 0)
   NumPut(32, BI, 0)
   NumPut(mask, BI, 4)
   NumPut(hstate, BI, 16, "Char")
   NumPut(width, BI, 18, "Short")
   NumPut(&text, BI, 24)
    SendMessage, TB_SETBUTTONINFO, id, &BI, ,ahk_id %hToolbar%
   res := ErrorLevel
   SendMessage, 0x421, , ,,ahk_id %hToolbar%   ;autosize
   return res
}



;----------------------------------------------------------------------------------------------
;Function:  SetButtons
;         Set all butons at once using textual definition
;
;Parameters:
;         hToolbar   - HWND of the toolbar
;         info      - Textual definition of buttons info. For each button there should be line containg *text|state list* where 
;                    both _text_ and _state list_ are optional. You can also use "-" to skip button (the same as empty line).
;                    If you omit this parameter text and state for each button will be cleared
;
Toolbar_SetButtons(hToolbar, info=""){
   if info=
   {
      Loop, % Toolbar_GetButtonCount(hToolbar)
         Toolbar_SetButtonInfo(hToolbar, A_Index, "-", "ENABLED" )
      return
   }

   loop, parse, info, `n,
   {
      if j := InStr(A_LoopField, "|")
         state := SubStr(A_LoopField, j+1)
      else state := "enabled"
      txt := SubStr(A_LoopField, 1, j ? j-1 : 99)
      ifEqual txt, -, continue


      Toolbar_SetButtonInfo(hToolbar, A_Index, txt, state)
   }
}

;----------------------------------------------------------------------------------------------
;Function:  GetButtonInfo
;         Get button information
;
;Parameters:
;         hToolbar   - HWND of the toolbar
;         id         - ID of the button (currently the same as position)
;         info      - What kind of info to return - text (default) or state
;
Toolbar_GetButtonInfo(hToolbar, id, info="text"){
;   static TB_GETBUTTONINFO=0x441, TBIF_TEXT=2, TBIF_STATE=4
   static TB_GETBUTTONTEXT=0x42D, TB_GETSTATE=0x412
   static S1 = "CHECKED", S4 = "ENABLED", S8 ="HIDDEN", S16="GRAYED", S5="PRESSED", S6="CLICKED"

   if info=text
   {
      VarSetCapacity( buf, 128 )
      SendMessage, TB_GETBUTTONTEXT,id,&buf,,ahk_id %hToolbar%
      ifEqual, Errorlevel, 4294967295, return 
      VarSetCapacity( buf, -1 )
      return buf
   }
   else if info=state
   {
        SendMessage, TB_GETSTATE,id,,,ahk_id %hToolbar%
      state = S%ErrorLevel%
      state := %state%
      return state
   }

;   mask := TBIF_TEXT
;   if info = state
;      mask := TBIF_STATE
;      
;
;   VarSetCapacity(BI, 32, 0)
;   NumPut(32, BI, 0)
;   NumPut(mask, BI, 4)
;    SendMessage, TB_GETBUTTONINFO, id, &BI, ,ahk_id %hToolbar%
;   if ErrorLevel=4294967295
;      return "Err: can't get button info"
;
;   if info=text
;      return NumGet(BI, 8)


}

;----------------------------------------------------------------------------------------------
;Function:  GetButtonCount
;         Get count of buttons on the toolbar
;
;Parameters:
;         hToolbar   - HWND of the toolbar
;
;Returns:
;         Count
Toolbar_GetButtonCount(hToolbar) {
   static TB_BUTTONCOUNT = 0x418
    SendMessage, TB_BUTTONCOUNT, , , ,ahk_id %hToolbar%
   return ErrorLevel
}

;----------------------------------------------------------------------------------------------
;Function:  DeleteButton
;         Delete button from the toolbar
;
;Parameters:
;         hToolbar   - HWND of the toolbar
;         idx         - 1-based position of the button 
;
;Returns:
;         TRUE if successful, or FALSE otherwise.
;
Toolbar_DeleteButton(hToolbar, idx=1) {
   static TB_DELETEBUTTON = 0x416
    SendMessage, TB_DELETEBUTTON, idx-1, , ,ahk_id %hToolbar%
   return ErrorLevel
}


;----------------------------------------------------------------------------------------------
;Function:  GetRect
;         Get button rectangle
;
;Parameters:
;         hToolbar   - HWND of the toolbar
;         id         - Button id
;
;Returns:
;         String with 4 rect values, separated by space
;
Toolbar_GetRect(hToolbar, id) {
   static TB_GETRECT=0x433, RECT

   VarSetCapacity(RECT, 16)
    SendMessage, TB_GETRECT, id,&RECT, ,ahk_id %hToolbar%
   IfEqual, ErrorLevel, 0, return "Err: can't get rect"

   return NumGet(RECT, 0) " " NumGet(RECT, 4) " " NumGet(RECT, 8) " " NumGet(RECT, 12)
}

;----------------------------------------------------------------------------------------------
;Function:  GetRows
;         Get number of toolbar rows
;
;Parameters:
;         hToolbar   - HWND of the toolbar
;
;Returns:
;         Count
;
Toolbar_GetRows(hToolbar) {
   static TB_GETROWS=0x428
    SendMessage, TB_GETROWS,,,,ahk_id %hToolbar%
   return ErrorLevel-1
}
   
;doesn't work correctly for some reason
Toolbar_SetPadding(hToolbar, cx=6, cy=7) {
   static TB_SETPADDING=0x457

    SendMessage, TB_SETPADDING,0,(cx<<16)+cy,,ahk_id %hToolbar%
   return ErrorLevel>>16 " " ErrorLevel & 0xFFFF
}

;mnu:
;      Toolbar_SetButtonInfo(hToolbar, id, A_ThisMenuItem)
;return

Toolbar_SetDrawTextFlags(hToolbar) {
   static TB_SETDRAWTEXTFLAGS = 0x446
}

;Returns nonzero if successful, or zero otherwise.
Toolbar_SetMaxTextRows(hToolbar, iMaxRows=0) {
   static TB_SETMAXTEXTROWS = 0x43C
    SendMessage, TB_SETMAXTEXTROWS,iMaxRows,,,ahk_id %hToolbar%
   res := ErrorLevel
    SendMessage,0x421,,,,ahk_id %hToolbar% ;autoresize
   return res
}

Toolbar_SetMetrics(hToolbar, xPad="", yPad="", xButtonMargin="", yButtonMargin="", xMargin="", yMargin=""){

	toolbar32Meta := Toolbar32_GetToolbarMeta(A_Args)
	hToolbar := getValue(toolbar32Meta, "handle")
	metrics := getValue(A_Args, "metrics")
	
	StringSplit,tm,metrics,`,
	xPad := tm1
	yPad := tm2
	xButtonMargin= := tm3
	yButtonMargin= := tm4
	xMargin= := tm5
	yMargin= := tm6

    VarSetCapacity(met,32,0), NumPut(32,met)
    NumPut( ((xPad yPad)!="" ? 1:0)
        | ((xMargin yMargin)!="" ? 2:0)
        | ((xButtonMargin yButtonMargin)!="" ? 4:0), met, 4)
    NumPut(xPad,met,8), NumPut(yPad,met,12)
    NumPut(0,met,16), NumPut(yMargin,met,20)
    NumPut(xButtonMargin,met,24), NumPut(yButtonMargin,met,28)
    DllCall("SendMessage","uint",hToolbar,"uint",0x466,"uint",0,"uint",&met) ; TB_SETMETRICS
    DllCall("SendMessage","uint",hToolbar,"uint",0x42F,"int",xMargin,"uint",0) ; TB_SETINDENT
}

;Returns TRUE if successful, or FALSE otherwise.
Toolbar_SetButtonSize(hToolbar, x=0, y=0) {
   static TB_SETBUTTONSIZE = 0x41F

   SendMessage, TB_SETBUTTONSIZE, 0,(y<<16) | x,,ahk_id %hToolbar% 
   SendMessage, 0x421, , ,,ahk_id %hToolbar%   ;autosize
}

;Returns nonzero if successful, or zero otherwise.
Toolbar_SetButtonWidth(hToolbar, cxMin, cxMax ){
   static TB_SETBUTTONWIDTH=0x43B

   SendMessage, TB_SETBUTTONWIDTH, 0,(cxMin<<16) | cxMax,,ahk_id %hToolbar% 
   return Errorlevel
}

Toolbar_SetBitmapSize(hToolbar, x, y ) {
   SendMessage, 0x420,0,(x<<16)+y, , ahk_id %hToolbar%
}

Toolbar_AutoSize(hToolbar){
    SendMessage,0x421,,,,ahk_id %hToolbar% ;autoresize
}

;-------------------------------------------------------------------------------------------------------------------
;Group: About
;      o Ver 1.0 b1 by majkinetor. See http://www.autohotkey.com/forum/topic27382.html
;      o Toolbar Reference at MSDN: <http://msdn2.microsoft.com/en-us/library/bb760435(VS.85).aspx>
;      o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.
