; Title:	Toolbar
;			*Toolbar control*

;----------------------------------------------------------------------------------------------
;Function:  Add
;			Add toolbar to the GUI
;
;Parameters:
;			hGui	- HWND of the GUI
;			hIL		- If number, handle of the image list that contains button images. 
;					  If string (default), default image list will be used, see details bellow
;			style	- Styles to apply to the toolbar control, see list of styles bellow.
;
; Default image list:
;			If hIL isn't number, you must specify string in strict format. The syntax is *CS iconlist" 
;			where C is catalog number (1-4) and S is the icon size - S (small, 16px) or L (large, 24px).
;			Iconlist is the list of icons you want to use from desired catalog (each catalog has different number of images - from 5 to 15)
;			By default, hIL is set as *"1S 7,8,9,|,2,3,|,4,5,10"* so that first catalog and large images are used, and icons as specified.
;			You can set "|" instead of icon number to insert separator button at particular position
;
; Control Styles:
;			WRAPABLE	- Creates a toolbar that can have multiple lines of buttons. Toolbar buttons can "wrap" to the next line when the toolbar becomes too narrow to include all buttons on the same line. When the toolbar is wrapped, the break will occur on either the rightmost separator or the rightmost button if there are no separators on the bar. This style must be set to display a vertical toolbar control when the toolbar is part of a vertical rebar control. This style cannot be combined with CCS_VERT.
;			FLAT		- Creates a flat toolbar. In a flat toolbar, both the toolbar and the buttons are transparent and hot-tracking is enabled. Button text appears under button bitmaps. To prevent repainting problems, this style should be set before the toolbar control becomes visible.
;			LIST		- Creates a flat toolbar with button text to the right of the bitmap. Otherwise, this style is identical to TBSTYLE_FLAT. To prevent repainting problems, this style should be set before the toolbar control becomes visible.
;
; Returns: 
;		Handle of the toolbar
;
Toolbar_Add(hGui, hIL="1S 7,8,9,|,2,3,|,4,5,10", style="WRAPABLE FLAT LIST") { 
   static ICC_BAR_CLASSES := 0x4, TOOLBARCLASSNAME  = "ToolbarWindow32" 
   static WS_EX_TOOLWINDOW := 0x80, WS_CHILD := 0x40000000, WS_VISIBLE := 0x10000000,  WS_CLIPSIBLINGS = 0x4000000, WS_CLIPCHILDREN = 0x2000000

 ;extended styles
	static TBSTYLE_EX_DRAWDDARROWS = 0x1, TBSTYLE_EX_HIDECLIPPEDBUTTONS=0x10, TBSTYLE_EX_MIXEDBUTTONS=0x8

 ;styles for control
   static TBSTYLE_WRAPABLE = 0x200, TBSTYLE_FLAT = 0x800, TBSTYLE_LIST=0x1000, TBSTYLE_TOOLTIPS=0x100, TBSTYLE_TRANSPARENT = 0x8000
 ;styles for buttons
    static BTNS_AUTOSIZE=0x10, BTNS_SEP = 0x1, BNTS_GROUP = 0x4, BTNS_CHECK=0x2, BTNS_DROPDOWN=0x8, BTNS_SHOWTEXT=0x40, BTNS_WHOLEDROPDOWN=0x80

 ;messages
   static TB_SETBITMAPSIZE=0x420, TB_SETIMAGELIST=0x430, TB_LOADIMAGES=0x432, TB_AUTOSIZE=0x421, TB_BUTTONSTRUCTSIZE=0x41E, TB_ADDBUTTONS=0x414, TB_INSERTBUTTON=0x415, TB_SETEXTENDEDSTYLE := 0x454
   static init, hToolbar, internal


	hStyle := 0
	loop, parse, style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		ifEqual, A_LoopField,,continue
		hStyle |= TBSTYLE_%A_LOOPFIELD%
	}

   if !init 
   { 
      init := true 
      VarSetCapacity(ICCE, 8) 
      NumPut(8, ICCE, 0)
      NumPut(ICC_BAR_CLASSES, ICCE, 4) 

      if !DllCall("comctl32.dll\InitCommonControlsEx", "uint", &ICCE) 
         return "Err: can't initialize common controls" 
		OnMessage(WM_NOTIFY := 0x4E, "Toolbar_onNotify")
   }

    hToolbar := DllCall("CreateWindowEx" 
             , "uint", 0
             , "str",  TOOLBARCLASSNAME 
             , "uint", 0 
             , "uint", WS_CHILD | hstyle
             , "uint", 0, "uint", 0, "uint", 0, "uint", 0 
             , "uint", hGui 
             , "uint", 0 
             , "uint", 0 
             , "uint", 0, "Uint") 
    ifEqual, hToolbar, 0, return "Err: can't create toolbar" 
	
	SendMessage, TB_BUTTONSTRUCTSIZE, 20, 0, , ahk_id %hToolbar% 
;	SendMessage, TB_SETEXTENDEDSTYLE, 0, TBSTYLE_EX_DRAWDDARROWS, , ahk_id %hToolbar%		;for dropdown arrows

	VarSetCapacity(TBB, 20, 0) 
	NumPut(4, TBB, 8, "Char")      ;TBSTATE_ENABLED 
	NumPut(BTNS_AUTOSIZE, TBB, 9, "Char")
	if hIL is Integer
	{
		SendMessage, TB_SETIMAGELIST, 0, hIL, ,ahk_id %hToolbar%
		Loop, % DllCall("comctl32.dll\ImageList_GetImageCount", "uint", hIL) 
		{ 

			NumPut(A_Index-1, TBB, 0) 
			NumPut(A_Index, TBB, 4)
			SendMessage, TB_INSERTBUTTON, A_Index-1, &TBB, ,ahk_id %hToolbar% 
			IfEqual,  ErrorLevel, 0, return "Err: can't create button " A_LoopField
		} 		
	}
	else {
		size := SubStr(hIL,2,1)="L" ? 24:16,  cat := (SubStr(hIL, 1,1)-1)*4 + (size=16 ? 0:1)
		icons := SubStr(hIL,4)
		SendMessage, TB_SETBITMAPSIZE,0,(size<<16)+size, , ahk_id %hToolbar%
		SendMessage, TB_LOADIMAGES, cat, -1,,ahk_id %hToolbar% 
		Loop, parse, icons, `,%A_Space%
		{ 
			if A_LoopField = |
				 NumPut(1, TBB, 9, "Char")    
			else NumPut(4|BTNS_AUTOSIZE, TBB, 9, "Char")
			NumPut(A_LoopField-1, TBB, 0) 
			NumPut(A_Index, TBB, 4)
			SendMessage, TB_INSERTBUTTON, A_Index-1, &TBB, ,ahk_id %hToolbar% 
			IfEqual,  ErrorLevel, 0, return "Err: can't create button " A_LoopField 
	
		} 
	    SendMessage, TB_AUTOSIZE, , ,,ahk_id %hToolbar% 
	}

    DllCall("ShowWindow", "uint", hToolbar, "uint", 1) 
    return hToolbar 
}

;    UINT  cbSize; 	 0
;    DWORD  dwMask;  4
;    int  idCommand;  8
;    int  iImage; 	 12
;    BYTE  fsState;	 16
;    BYTE  fsStyle;	 17
;    WORD  cx;		 18
;    DWORD_PTR  lParam; 20
;    LPSTR  pszText;	   24
;    int  cchText; 	   28
;    int  iImageLabel;  32
;
;----------------------------------------------------------------------------------------------
;Function:  SetButtonInfo
;			Set button information
;
;Parameters:
;			hToolbar	- HWND of the toolbar
;			id			- Button identification (currently equal to buttons position)
;			text		- Text to set for the button. If "" text will not be changed. If "-" text wil be removed (the same as omiting both text and state parameters)
;			state		- List of button states to set, separated by white space. See bellow.
;
; Button states:
;			CHECKED, ENABLED, HIDDEN, GRAYED, PRESSED, CLICKED
;
; Returns:
;			Nonzero if successful, or zero otherwise.
;
Toolbar_SetButtonInfo(hToolbar, id, text="", state=""){
	static TB_SETBUTTONINFO=0x442, TBIF_TEXT=2, TBIF_STATE=4, TB_AUTOSIZE=0x421
	static TBSTATE_CHECKED =0x1, TBSTATE_ENABLED =0x4, TBSTATE_HIDDEN =0x8, TBSTATE_GRAYED =0x10, TBSTATE_PRESSED =5, TBSTATE_CLICKED=6, TBSTATE_WRAP=0x20

	hstate := 0
	loop, parse, state, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		ifEqual, A_LoopField,,continue
		hstate |= TBSTATE_%A_LOOPFIELD%
	}

	mask := 0
	mask |= text != "" ?  TBIF_TEXT : 0
	mask |= state!= "" ?  TBIF_STATE : 0

	if text = -
		text =
	if (state text = "")
		mask := TBIF_TEXT, text := ""

	VarSetCapacity(BI, 32, 0)
	NumPut(32, BI, 0)
	NumPut(mask, BI, 4)
	NumPut(hstate, BI, 16, "Char")
	NumPut(&text, BI, 24)
    SendMessage, TB_SETBUTTONINFO, id, &BI, ,ahk_id %hToolbar%
	res := ErrorLevel
	SendMessage, TB_AUTOSIZE, , ,,ahk_id %hToolbar% 
	return res
}

;----------------------------------------------------------------------------------------------
;Function:  SetButtons
;			Set all butons at once using textual definition
;
;Parameters:
;			hToolbar	- HWND of the toolbar
;			info		- Textual definition of buttons info. For each button there should be line containg *text|state list* where 
;						  both _text_ and _state list_ are optional. You can also use "-" to skip button (the same as empty line).
;						  If you omit this parameter text and state for each button will be cleared
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
;			Get button information
;
;Parameters:
;			hToolbar	- HWND of the toolbar
;			id			- ID of the button (currently the same as position)
;			info		- What kind of info to return - text (default) or state
;
Toolbar_GetButtonInfo(hToolbar, id, info="text"){
;	static TB_GETBUTTONINFO=0x441, TBIF_TEXT=2, TBIF_STATE=4
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

;	mask := TBIF_TEXT
;	if info = state
;		mask := TBIF_STATE
;		
;
;	VarSetCapacity(BI, 32, 0)
;	NumPut(32, BI, 0)
;	NumPut(mask, BI, 4)
;    SendMessage, TB_GETBUTTONINFO, id, &BI, ,ahk_id %hToolbar%
;	if ErrorLevel=4294967295
;		return "Err: can't get button info"
;
;	if info=text
;		return NumGet(BI, 8)


}

;----------------------------------------------------------------------------------------------
;Function:  GetButtonCount
;			Get count of buttons on the toolbar
;
;Parameters:
;			hToolbar	- HWND of the toolbar
;
;Returns:
;			Count
Toolbar_GetButtonCount(hToolbar) {
	static TB_BUTTONCOUNT = 0x418
    SendMessage, TB_BUTTONCOUNT, , , ,ahk_id %hToolbar%
	return ErrorLevel
}

;----------------------------------------------------------------------------------------------
;Function:  DeleteButton
;			Delete button from the toolbar
;
;Parameters:
;			hToolbar	- HWND of the toolbar
;			idx			- 1-based position of the button 
;
;Returns:
;			TRUE if successful, or FALSE otherwise.
;
Toolbar_DeleteButton(hToolbar, idx=1) {
	static TB_DELETEBUTTON = 0x416
    SendMessage, TB_DELETEBUTTON, idx-1, , ,ahk_id %hToolbar%
	return ErrorLevel
}


;----------------------------------------------------------------------------------------------
;Function:  GetRect
;			Get button rectangle
;
;Parameters:
;			hToolbar	- HWND of the toolbar
;			id			- Button id
;
;Returns:
;			String with 4 rect values, separated by space
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
;			Get number of toolbar rows
;
;Parameters:
;			hToolbar	- HWND of the toolbar
;
;Returns:
;			Count
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


Toolbar_onNotify(wparam, lparam) {
    local hwnd, idCtrl, code, txt, out, out1, out2
	static NM_CLICK=-2

    hwnd   :=  NumGet(lparam+0)
    code   :=  NumGet(lparam+8) - 4294967296
	id	   :=  NumGet(lparam+12)

	if (code = NM_CLICK)
		tooltip % Toolbar_GetButtonInfo( hwnd, id ) ":" id
}

;-------------------------------------------------------------------------------------------------------------------
;Group: Example
;
;>	Gui, +LastFound 
;>	hwnd := WinExist() 
;>	Gui, Show ,w280 h200		;set gui width & height (mandatory)
;> 	hToolbar := Toolbar_Add(hwnd)

;-------------------------------------------------------------------------------------------------------------------
;Group: About
;		o Ver 1.0 b1 by majkinetor. See http://www.autohotkey.com/forum/topic27382.html
;		o Toolbar Reference at MSDN: <http://msdn2.microsoft.com/en-us/library/bb760435(VS.85).aspx>
;		o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.