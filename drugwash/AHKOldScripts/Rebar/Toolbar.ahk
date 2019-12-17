; Title:    Toolbar
;			*Encapsulation of the system Toolbar API.*
;			(see toolbar.png)
;			The module is designed with following goals in mind :
;			* To allow programmers to quickly create toolbars in intuitive way
;			* To allow advanced (non-typical) use, such as dynamic toolbar creation in such way that it doesn't complicate typical toolbar usage.
;			* To allow users to customize toolbar and programmer to save changed toolbar state.
;			* Not to have any side effects to your script.
;
;----------------------------------------------------------------------------------------------
;Function:  Add
;			Add a Toolbar to the GUI
;
;Parameters:
;			hGui		- HWND of the GUI. GUI must have defined size.
;			pFun		- User function that handles Toolbar events. See below.
;			pStyle		- Styles to apply to the toolbar control, see list of styles bellow. Integer styles are allowed.
;			pImageList	- Handle of the image list that contains button images. Otherwse it specifies number and icon size of the one of the 3 system catalogs (see catalogs.png).
;						  Each catalog contains number of common icons in large and small size -- S or L (default). Defaults to "1L" (first catalog, large icons)
;			pPos		- Postion of the toolbar - any space separated combination of the x y w h keywords followed by the size.
;
; Event Handling:
;			You handle events by specifying user function as pFun parameter. Function accepts 4 parameters:
;>�			OnToolbar(hToolbar, pEvent, pPos, pTxt, pId)
;
;			hToolbar - Handle of the Toolbar.
;			pEvent	- Can be "click", "menu", "hot", "change", "adjust".
;			pPos	- Position of the button that rised event
;			pTxt	- Caption of the button that raised event
;			pId		- ID of the button that raised event
;
; Events:
;			click	- User has clicked on the button. 
;			menu	- User has clicked on the dropdown icon.
;			hot		- User is hovering the button with the mouse
;			change	- User has dragged the button using SHIFT + drag			
;			adjust	- User has finished customizing the toolbar.
;
; Control Styles:
;			adjustable	- Allows users to change a toolbar button's position by dragging it while holding down the SHIFT key and to open customization dialog by double clicking Toolbar empty area, or separator
;			border		- Creates a Toolbar that has a thin-line border.
;			bottom		- Causes the control to position itself at the bottom of the parent window's client area
;			flat		- Creates a flat toolbar. In a flat toolbar, both the toolbar and the buttons are transparent and hot-tracking is enabled. Button text appears under button bitmaps. To prevent repainting problems, this style should be set before the toolbar control becomes visible.
;			list		- Creates a flat toolbar with button text to the right of the bitmap. Otherwise, this style is identical to FLAT style. To prevent repainting problems, this style should be set before the toolbar control becomes visible.
;			tooltips	- Creates a ToolTip control that an application can use to display descriptive text for the buttons in the toolbar.
;			nodivder	- Prevents a two-pixel highlight from being drawn at the top of the control.
;			tabstop		- Specifies that a control can receive the keyboard focus when the user presses the TAB key.
;			wrapable	- Creates a toolbar that can have multiple lines of buttons. Toolbar buttons can "wrap" to the next line when the toolbar becomes too narrow to include all buttons on the same line. When the toolbar is wrapped, the break will occur on either the rightmost separator or the rightmost button if there are no separators on the bar. This style must be set to display a vertical toolbar control when the toolbar is part of a vertical rebar control.
;			vertical	- Creates vertical toolbar
;			menu		- Creates toolbar that is visualy similar to application main menu. All buttons have "dropdown showtext" styles and have no icons by default.
;
; Returns: 
;			Handle of the newly created toolbar
;
Toolbar_Add(hGui, pFun, pStyle="WRAPABLE", pImageList="1L", pPos="") {

	;vars
		local hStyle, hToolbar, p,x,y,w,h, old, bMenu, hExStyle
	  ;Standard Styles
		static WS_CHILD := 0x40000000, WS_VISIBLE := 0x10000000, WS_CLIPSIBLINGS = 0x4000000, WS_CLIPCHILDREN = 0x2000000, TBSTYLE_BORDER=0x800000, TBSTYLE_THICKFRAME=0x40000, TBSTYLE_TABSTOP = 0x10000
	  ;Toolbar Styles
		static TBSTYLE_WRAPABLE = 0x200, TBSTYLE_FLAT = 0x800, TBSTYLE_LIST=0x1000, TBSTYLE_TOOLTIPS=0x100, TBSTYLE_TRANSPARENT = 0x8000, TBSTYLE_ADJUSTABLE = 0x20, TBSTYLE_VERTICAL=0x80
	  ;Toolbar Extended Styles
		static TBSTYLE_EX_DRAWDDARROWS = 0x1, TBSTYLE_EX_HIDECLIPPEDBUTTONS=0x10, TBSTYLE_EX_MIXEDBUTTONS=0x8
	  ;Messages
		static TB_BUTTONSTRUCTSIZE=0x41E, TB_SETEXTENDEDSTYLE := 0x454, TB_SETUNICODEFORMAT := 0x2005
	  ;common
		static TBSTYLE_NODIVIDER=0x40, CCS_NOPARENTALIGN=0x8, CCS_NORESIZE = 0x4, TBSTYLE_BOTTOM = 0x3
	  ;Other
		static TOOLBARCLASSNAME  = "ToolbarWindow32", TBSTYLE_MENU=0, init

  	hStyle := 0
	hExStyle := TBSTYLE_EX_HIDECLIPPEDBUTTONS|TBSTYLE_EX_MIXEDBUTTONS

	if bMenu := InStr(pStyle, "MENU"){
		StringReplace, pStyle, pStyle, MENU
		hStyle |= TBSTYLE_FLAT | TBSTYLE_LIST | WS_CLIPSIBLINGS		;set this style only if custom flag MENU is set. It serves only as a mark later

	} else hExStyle |= TBSTYLE_EX_DRAWDDARROWS

	loop, parse, pStyle, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		ifEqual, A_LoopField,,continue
		hStyle |= A_LoopField+0 ? A_LoopField : TBSTYLE_%A_LoopField%
	}
	ifEqual, hStyle, ,return "Err: Some of the styles are invalid"


	if !init {
		Toolbar_MODULEID := 10608

		old := OnMessage(0x4E, "Toolbar_onNotify")
		if (old != "Toolbar_onNotify")
			Toolbar_oldNotify := RegisterCallback(old)
		init := true 
	}


	if (pPos != ""){
		x := y := 0, w := h := 100
		loop, parse, pPos, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		{
			ifEqual, A_LoopField, , continue
			p := SubStr(A_LoopField, 1, 1)
			if p not in x,y,w,h
				return "Err: Invalid position specifier"
			%p% := SubStr(A_LoopField, 2)
		}
		hStyle |= CCS_NOPARENTALIGN | TBSTYLE_NODIVIDER	| CCS_NORESIZE
	}

    hToolbar := DllCall("CreateWindowEx" 
             , "uint", 0
             , "str",  TOOLBARCLASSNAME 
             , "uint", 0
             , "uint", WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | hStyle
             , "uint", x, "uint", y, "uint", w, "uint", h
             , "uint", hGui 
             , "uint", Toolbar_MODULEID 
             , "uint", 0 
             , "uint", 0, "Uint") 
    ifEqual, hToolbar, 0, return "Err: can't create toolbar" 
	
	SendMessage, TB_BUTTONSTRUCTSIZE, 20, 0, , ahk_id %hToolbar%
	SendMessage, TB_SETEXTENDEDSTYLE, 0, hExStyle, , ahk_id %hToolbar%  ;!!! u ovom drugom je bilo disabled
	SendMessage, TB_SETUNICODEFORMAT, 0, 0, , ahk_id %hToolbar%		  ;set to ANSI

	if (pImageList != "")
		Toolbar_SetImageList(hToolbar, pImageList)
	
	Toolbar_%hToolbar%_fun := pFun
	return hToolbar 
}
;----------------------------------------------------------------------------------------------
;Function:  AddButtons
;			Add button(s) to the Toolbar. 
;
;Parameters:
;			pBtns		- The button definition list. Each button to be added is specified on separate line
;						  using button definition string. Empty lines will be skipped.
;			pPos		- Optional 1-based index of a button, to insert the new buttons to the left of this button.
;						  This doesn't apply to the list of available buttons.
;
;Button Definition:
;			Button is defined by set of its characteristics separated by comma:
;
;			caption		- Button caption. All printable letters are valid except comma. 
;						  "-" can be used to add separator. Add more "-" to set the separator width. Each "-" adds 10px to the separator.
;			iconNumber  - Number of icon in the image list, 1 based. 0 means that there is no icon associated with button.
;			states		- Space separated list of button states. See bellow list of possible states.
;			styles		- Space separated list of button styles. See bellow list of possible styles.
;			ID			- Button ID, unique number you choose to identify button. On customizable toolbars position can't be used to set button information.
;						  If you need to setup button information using <SetButton> function or obtain information using <GetButton>, you need to use button ID 
;						  as user can change button position any time.
;						  ID *must be* number between 1 and 10,000. Numbers > 10,000 are reserved for auto ID that module does on its own. In most
;						  typical scenarios you don't need to use ID to identify the button.
;
;Button Styles:
;			autosize	- Specifies that the toolbar control should not assign the standard width to the button. Instead, the button's width will be calculated based on the width of the text plus the image of the button. 
;			check		- Creates a dual-state push button that toggles between the pressed and nonpressed states each time the user clicks it.
;			checkgroup	- Creates a button that stays pressed until another button in the group is pressed, similar to option buttons (also known as radio buttons).
;			dropdown	- Creates a drop-down style button that can display a list when the button is clicked.
;			noprefix	- Specifies that the button text will not have an accelerator prefix associated with it.
;			showtext	- Specifies that button text should be displayed. All buttons can have text, but only those buttons with the SHOWTEXT button style will display it. 
;						  This button style must be used with the LIST style. If you set text for buttons that do not have the SHOWTEXT style, the toolbar control will 
;						  automatically display it as a ToolTip when the cursor hovers over the button. For this to work you must create the toolbar with TOOLTIPS style.
;						  You can create multiline tooltips by using $ in the tooltip caption. Each $ will be replaced with new line.
;
;Button States:
;			checked		- The button has the CHECK style and is being clicked.
;			disabled	- The button does not accept user input.
;			hidden		- The button is not visible and cannot receive user input.
;			wrap		- The button is followed by a line break. Toolbar must not have WRAPABLE style.
;
;Remarks:
;		Using this function you can add one or more buttons to the toolbar. Furthermore, adding group of buttons to the end (omiting pPos) is the 
;		fastest way of adding set of buttons to the toolbar and it also allows you to use some automatic features that are not available when you add button by button.
;		If you omit some parameter in button definition it will receive default value. Button that has no icon defined will get the icon with index that is equal to 
;		the line number of its defintion list. Buttons without ID will get ID automaticaly, starting from 10 000. 
;		You can use `r instead `n to create multiline button captions. This make sense only for toolbars that have LIST TOOLTIP toolbar style and no SHOWTEXT button style
;	    (i.e. their captions are seen as tooltips and are not displayed.
;
Toolbar_AddButtons(hToolbar, pBtns, pPos=""){
	local cnt, cBTN
	static TB_ADDBUTTONSA = 0x414, TB_INSERTBUTTONA=0x415

	if hToolbar is not integer
		return "Err: Invalid toolbar handle"

	cnt := Toolbar_compileButtons(hToolbar, pBtns, cBTN)
	if pPos =
		SendMessage, TB_ADDBUTTONSA, cnt, cBTN ,, ahk_id %hToolbar%
	else loop, %cnt%
		SendMessage, TB_INSERTBUTTONA, pPos+A_Index-2, cBTN + 20*(A_Index-1) ,, ahk_id %hToolbar%

	Toolbar_mfree(cBTN)

   ;for some reason, you need to call this 2 times for proper results in some scenarios .... !?
	SendMessage,0x421,,,,ahk_id %hToolbar%	;autosize
 	SendMessage,0x421,,,,ahk_id %hToolbar%	;autosize
}

;----------------------------------------------------------------------------------------------
;Function:  AutoSize
;			Causes a toolbar to be resized.
;
;Parameters:
;			hToolbar - HWND of the toolbar
;			align	 - How toolbar is aligned to its parent. bottom left (bl), bottom right (br), top right (tr), top left (tl) or fit (doesn't reposition control
;					   resizes it so it takes minimum possible space with all buttons visible)	
; 
;Remarks:
;			An application calls the AutoSize function after causing the size of a toolbar to 
;			change either by setting the button or bitmap size or by adding strings for the first time.
;
Toolbar_AutoSize(hToolbar, align="fit"){
	dhw := A_DetectHiddenWindows
	DetectHiddenWindows,on

	if align !=
	{
		Toolbar_GetMaxSize(hToolbar, w, h)

		SysGet, f, 8		;SM_CYFIXEDFRAME , Thickness of the frame around the perimeter of a window that has a caption but is not sizable
		SysGet, c, 4		;SM_CYCAPTION: Height of a caption area, in pixels.

		hParent := DllCall("GetParent", "uint", hToolbar)
		WinGetPos, ,,pw,ph, ahk_id %hParent%
		w+=2, h+=2
		if align = fit
			ControlMove,,,,%w%,%h%, ahk_id %hToolbar%
		else if align = tr
			ControlMove,,pw-w-f,c+f+2,%w%,%h%, ahk_id %hToolbar%
		else if align = tl
			ControlMove,,f,c+f+2,%w%,%h%, ahk_id %hToolbar%
		else if align = br
			ControlMove,,pw-w-f,ph-h-f,%w%,%h%, ahk_id %hToolbar%
		else if align = bl
			ControlMove,,,ph-h-f,%w%,%h%, ahk_id %hToolbar%
	}
	else SendMessage,0x421,,,,ahk_id %hToolbar%

	DetectHiddenWindows, %dhw%
}

;----------------------------------------------------------------------------------------------
;Function:  Clear
;			Removes all buttons from the toolbar, both current and available
;
Toolbar_Clear(hToolbar){
	global

	loop % Toolbar_Count(hToolbar)
		SendMessage, 0x416, , , ,ahk_id %hToolbar%		;TB_DELETEBUTTON

	Toolbar_mfree(Toolbar_%hToolbar%_aBTN), Toolbar_%hToolbar%_aBTN := ""
 	SendMessage,0x421,,,,ahk_id %hToolbar% ;autosize
}

;----------------------------------------------------------------------------------------------
;Function:  Customize
;			Launches customization dialog
;			(see customize.png)
;
Toolbar_Customize(hToolbar) {
	static TB_CUSTOMIZE=0x41B
	SendMessage, TB_CUSTOMIZE,,,, ahk_id %hToolbar%
}

;----------------------------------------------------------------------------------------------
;Function:  Define
;			Get current toolbar definition
;
;Parameters:
;			pQ			- Query parameter. Specify "c" to get only current buttons, "a" to get only available buttons.
;						  Leave empty to get all buttons.
;
;Returns:
;			Button definition list
;
Toolbar_Define(hToolbar, pQ="") {
	local btns, cnta

	if pQ !=
		if  pQ not in a,c
			return "Err: Invalid query parameter"

	if (pQ = "") or (pQ = "c")
		loop, % Toolbar_Count(hToolbar)
			btns .= Toolbar_GetButton(hToolbar, A_Index) "`r`n"
	ifEqual, pQ, c, return SubStr(btns, 1, -2)

	if (pQ="") or (pQ = "a"){
		if pQ =
			btns .= "`r`n"

		cnta := NumGet(Toolbar_%hToolbar%_aBTN+0)
		loop, %cnta%
			btns .= Toolbar_GetButton(hToolbar, -A_Index) "`r`n"
	
		return SubStr(btns, 1, -2)
	}
}

;----------------------------------------------------------------------------------------------
;Function:  DeleteButton
;			Delete button from the toolbar
;
;Parameters:
;			pPos		- 1-based position of the button, by default 1
;						  To delete one of the available buttons, specify "*" before position
;
;Returns:
;			TRUE if successful, or FALSE otherwise.
;
Toolbar_DeleteButton(hToolbar, pPos=1) {
	local aBTN, cnta
	static TB_DELETEBUTTON = 0x416

	if InStr(pPos, "*") {
		pPos := SubStr(pPos, 2),  aBTN := Toolbar_%hToolbar%_aBTN,  cnta := NumGet(aBTN+0)
		if (pPos > cnta)
			return FALSE
		if (pPos < cnta)
			Toolbar_memmove( aBTN + 20*(pPos-1) +4, aBTN + 20*pPos +4, aBTN + 20*pPos +4)
		NumPut(cnta-1, aBTN+0)
		return TRUE
	}

    SendMessage, TB_DELETEBUTTON, pPos-1, , ,ahk_id %hToolbar%
	return ErrorLevel
}

;----------------------------------------------------------------------------------------------
;Function:  GetButton
;			Get button information
;
;Parameters:
;			pWhichBtn	- One of the ways to identify the button: 1-based button position or button ID.
;						  If pWhichBtn is negative, the information about *available* button on position -pWhichBtn will be returned.				
;			pQ			- Query parameter, can be C (Caption) I (Icon number), T (sTate), S (Style) or N (identification Number)
;						  If omitted, all information will be returned in the form of button definition
;
;Returns:
;			If pQ is omitted, button definition, otherwise requested button information.
;
;Examples:
;>		   s := GetButton(hToolbar, 3)			;return string completely defining 3th current toolbar button
;>		   c := GetButton(hToolbar, 3, "c")		;return only caption of the 3th current button
;>         s := GetButton(hToolbar, .101, "t")	;return the state of the current button with ID=101
;
Toolbar_GetButton(hToolbar, pWhichBtn, pQ="") {
	local a, aBTN, cnta, o, id, icon, style, state, data, buf, sIdx, TBB, aTBB
	static TB_GETBUTTON = 0x417, TB_GETBUTTONTEXT=0x42D, TB_GETSTRING=0x45C, TB_COMMANDTOINDEX=0x419

	if pWhichBtn is not number
		return "Err: Invalid button position or ID: " pWhichBtn

	if (pWhichBtn < 0)
		aBtn := Toolbar_%hToolbar%_aBTN + 4,  cnta := NumGet(Toolbar_%hToolbar%_aBTN+0),  pWhichBtn := -pWhichBtn,   a := true
	else if (pWhichBtn < 1){
		ifEqual, pWhichBtn, 0, return "Err: 0 is invalid position and ID"
		SendMessage, TB_COMMANDTOINDEX, SubStr(pWhichBtn, 2),, ,ahk_id %hToolbar%
		ifEqual, ErrorLevel, 4294967295, return "Err: No such ID " SubStr(pWhichBtn, 2)
		pWhichBtn := ErrorLevel + 1
	} 
	pWhichBtn--

	if (a AND (cnta < pWhichBtn)) OR (!a and (Toolbar_Count(hToolbar) < pWhichBtn) )
		return "Err: Button position is too large: " pWhichBtn	

 ;get TBB structure
	VarSetCapacity(TBB, 20), aTBB := &TBB
	if a
		 aTBB := aBtn + pWhichBtn*20
	else SendMessage, TB_GETBUTTON, pWhichBtn, aTBB,,ahk_id %hToolbar%

	id := NumGet(aTBB+0, 4)
	IfEqual, pQ, N, return id

 ;check for separator
	if NumGet(aTBB+0, 9, "Char") = 1  {
		loop, % NumGet(TBB)//10 + 1
			buf .= "-"
		return buf
	}

 ;get caption
	VarSetCapacity( buf, 128 ), sIdx := NumGet(aTBB+0, 16)
	SendMessage, TB_GETSTRING, (sIdx<<16)|128, &buf, ,ahk_id %hToolbar%			;SendMessage, TB_GETBUTTONTEXT,id,&buf,,ahk_id %hToolbar%
	VarSetCapacity( buf, -1 )
	if a
		buf := "*" buf
	ifEqual, pQ, c, return buf
	
 ;get other data
	state := Toolbar_getStateName(NumGet(aTBB+0, 8, "Char"))
	ifEqual, pQ, T, return state

	icon := NumGet(aTBB+0)+1
	ifEqual, pQ, I, return icon

	style := Toolbar_getStyleName(NumGet(aTBB+0, 9, "Char"))
	ifEqual, pQ, S, return style

 ;make string
	buf :=  buf ", " icon ", " state ", " style (id < 10000 ? ", " id : "")
	return buf
}

;----------------------------------------------------------------------------------------------
;Function:  Count
;			Get count of buttons on the toolbar
;
;Parameters:
;			pQ			- Query parameter, set to "c" to get the number of current buttons (default)
;						  Set to "a" to get the number of available buttons. Set to empty string to return both.
;
;Returns:
;			if pQ is empty function returns rational number in the form cntC.cntA otherwise  requested count
Toolbar_Count(hToolbar, pQ="c") {
	local c, a
	static TB_BUTTONCOUNT = 0x418

	SendMessage, TB_BUTTONCOUNT, , , ,ahk_id %hToolbar%
	c := ErrorLevel	
	IfEqual, pQ, c, return c

	a := NumGet(Toolbar_%hToolbar%_aBTN+0)
	ifEqual, pQ, a, return a

	return c "." a
}

;----------------------------------------------------------------------------------------------
;Function:  GetRect
;			Get button rectangle
;
;Parameters:
;			pPos		- Button position. Leave blank to get dimensions of the toolbar control itself.
;			pQ			- Query parameter: set x,y,w,h to return appropriate value, or leave blank to return all in single line.
;
;Returns:
;			String with 4 values separated by space or requested information
;
Toolbar_GetRect(hToolbar, pPos="", pQ="") {
	static TB_GETITEMRECT=0x41D

	if pPos !=
		ifLessOrEqual, pPos, 0, return "Err: Invalid button position"

	VarSetCapacity(RECT, 16)
    SendMessage, TB_GETITEMRECT, pPos-1,&RECT, ,ahk_id %hToolbar%
	IfEqual, ErrorLevel, 0, return "Err: can't get rect"

	if pPos =
		DllCall("GetClientRect", "uint", hToolbar, "uint", &RECT)

	x := NumGet(RECT, 0), y := NumGet(RECT, 4), r := NumGet(RECT, 8), b := NumGet(RECT, 12)

	return (pQ = "x") ? x : (pQ = "y") ? y : (pQ = "w") ? r-x : (pQ = "h") ? b-y : x " " y " " r-x " " b-y
}

;----------------------------------------------------------------------------------------------
;Function:  GetMaxSize
;			Retrieves the total size of all of the visible buttons and separators in the toolbar.
;
;Parameters:
;			pWidth, pHeight		- Variables which will receive size
;
;Returns:
;			Returns nonzero if successful, or zero otherwise.
;
Toolbar_GetMaxSize(hToolbar, ByRef pWidth, ByRef pHeight){
	static TB_GETMAXSIZE = 0x453

	VarSetCapacity(SIZE, 8)
	SendMessage, TB_GETMAXSIZE, 0, &SIZE, , ahk_id %hToolbar%
	res := ErrorLevel, 	pWidth := NumGet(SIZE), pHeight := NumGet(SIZE, 4)
	return res
}

;----------------------------------------------------------------------------------------------
;Function:  MoveButton
;			Moves a button from one position to another.
;
;Parameters:
;			pOldPos		- 1-based postion of the button to be moved.
;			pNewPos		- 1-based postion where the button will be moved.
;
;Returns:
;			Returns nonzero if successful, or zero otherwise.
;
Toolbar_MoveButton(hToolbar, pOldPos, pNewPos) {
	static TB_MOVEBUTTON = 0x452
    SendMessage, TB_MOVEBUTTON, pOldPos-1,pNewPos-1, ,ahk_id %hToolbar%
	return ErrorLevel
}

;----------------------------------------------------------------------------------------------
;Function:  SetButtonInfo
;			Set button information
;
;Parameters:
;			pWhichBtn	- One of the 2 ways to identify the button: 1-based button position or button ID
;			state		- List of button states to set, separated by white space.
;			width		- Button width (can't be used with LIST style)
;
; Returns:
;			Nonzero if successful, or zero otherwise.
;
Toolbar_SetButton(hToolbar, pWhichBtn, state="", width=""){
	local aBtn, cnta, a, hState, mask, TBB, k, BI, res 
	static TBIF_TEXT=2, TBIF_STATE=4, TBIF_SIZE=0x40, 
	static TB_SETBUTTONINFO=0x442, TB_GETSTATE=0x412, TB_GETBUTTON = 0x417
	static TBSTATE_CHECKED=1, TBSTATE_ENABLED=4, TBSTATE_HIDDEN=8, TBSTATE_ELLIPSES=0x40, TBSTATE_DISABLED=0

	if pWhichBtn is not number
		return "Err: Invalid button position or ID: " pWhichBtn

    if (pWhichBtn >= 1){
		VarSetCapacity(TBB, 20)
		SendMessage, TB_GETBUTTON, --pWhichBtn, &TBB,,ahk_id %hToolbar%
		pWhichBtn := NumGet(&TBB+0, 4)
	} else pWhichBtn := SubStr(pWhichBtn, 2)

	SendMessage, TB_GETSTATE, pWhichBtn,,,ahk_id %hToolbar%
	hState := ErrorLevel

	mask := 0
	mask |= state != "" ?  TBIF_STATE : 0
	mask |= width != "" ?  TBIF_SIZE  : 0

	if InStr(state, "-disabled") {
		hState |= TBSTATE_ENABLED 
		StringReplace, state, state, -disabled
	}
	else if InStr(state, "disabled")
		hState &= ~TBSTATE_ENABLED

	loop, parse, state, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		ifEqual, A_LoopField,,continue
		if SubStr(A_LoopField, 1, 1) != "-"
		 	  hstate |= TBSTATE_%A_LOOPFIELD%
		else  k := SubStr(A_LoopField, 2),    k := TBSTATE_%k%, 	hState &= ~k
	}
	ifEqual, hState, , return "Err: Some of the states are invalid"

	VarSetCapacity(BI, 32, 0)
	NumPut(32,		BI, 0)
	NumPut(mask,	BI, 4)
	NumPut(hState,	BI, 16, "Char")
	NumPut(width,	BI, 18, "Short")
   
	SendMessage, TB_SETBUTTONINFO, pWhichBtn, &BI, ,ahk_id %hToolbar%
	res := ErrorLevel
	
	SendMessage, 0x421, , ,,ahk_id %hToolbar%	;autosize
	return res
}
;----------------------------------------------------------------------------------------------
;Function:  SetButtonWidth
;			Sets the size of the each button
;
;Parameters:
;			pMin, pMax - Minimum and maximum button width. If you omit pMax it defaults to pMin.
;
;Returns:
;			Nonzero if successful, or zero otherwise.
;
Toolbar_SetButtonWidth(hToolbar, pMin, pMax=""){
	static TB_SETBUTTONWIDTH=0x43B

	if pMax =
		pMax := pMin

	SendMessage, TB_SETBUTTONWIDTH, 0,(pMax<<16) | pMin,,ahk_id %hToolbar%
	ret := ErrorLevel

 	SendMessage,0x421,,,,ahk_id %hToolbar%	;autosize
	return ret
}

;----------------------------------------------------------------------------------------------
;Function:  SetButtonSize
;			Sets the size of the each button. Doesn't do anything with LIST style.
;
;Parameters:
;			w, h		- Width & Height. If you omit height, it defaults to width.
;
Toolbar_SetButtonSize(hToolbar, w, h="") {
	static TB_SETBUTTONSIZE = 0x41F

	if h =
		h := w
	SendMessage, TB_SETBUTTONSIZE, 0,(w<<16) | h,,ahk_id %hToolbar%
	SendMessage, 0x421, , ,,ahk_id %hToolbar%	;autosize
}


;----------------------------------------------------------------------------------------------
;Function:  SetImageList
;			Set toolbar image list
;
;Parameters:
;			hIL	- Image list handle
;
;Returns:
;			Handle of the previous image list
;
Toolbar_SetImageList(hToolbar, hIL="1S"){
	static TB_SETIMAGELIST = 0x430, TB_LOADIMAGES=0x432, TB_SETBITMAPSIZE=0x420

	hIL .= 	if StrLen(hIL) = 1 ? "S" : ""
	if hIL is Integer
		SendMessage, TB_SETIMAGELIST, 0, hIL, ,ahk_id %hToolbar%
	else {
		size := SubStr(hIL,2,1)="L" ? 24:16,  cat := (SubStr(hIL,1,1)-1)*4 + (size=16 ? 0:1)
		SendMessage, TB_SETBITMAPSIZE,0,(size<<16)+size, , ahk_id %hToolbar%
		SendMessage, TB_LOADIMAGES, cat, -1,,ahk_id %hToolbar% 
	}

	return ErrorLevel
}

;----------------------------------------------------------------------------------------------
;Function:  SetMaxTextRows
;			Sets the maximum number of text rows displayed on a toolbar button.
;
;Parameters:
;			iMaxRows	- Maximum number of rows of text that can be displayed.
;
;Remarks:
;			Returns nonzero if successful, or zero otherwise. To cause text to wrap, you must set the maximum 
;			button width by using <SetButtonWidth>. The text wraps at a word break. Text in LIST styled toolbars is always shown on a single line.
;
Toolbar_SetMaxTextRows(hToolbar, iMaxRows=0) {
	static TB_SETMAXTEXTROWS = 0x43C
    SendMessage, TB_SETMAXTEXTROWS,iMaxRows,,,ahk_id %hToolbar%
	res := ErrorLevel
 	SendMessage,0x421,,,,ahk_id %hToolbar% ;autosize
	return res
}


;----------------------------------------------------------------------------------------------
;Function:  ToggleStyle
;			Toggle specific toolbar creation style
;
;Parameters:
;			pStyle		- Style to toggle, by default "LIST". You can also specify numeric style value.
;
Toolbar_ToggleStyle(hToolbar, pStyle="LIST"){
    static TBSTYLE_WRAPABLE = 0x200, TBSTYLE_FLAT = 0x800, TBSTYLE_LIST=0x1000, TBSTYLE_TOOLTIPS=0x100, TBSTYLE_TRANSPARENT = 0x8000, TBSTYLE_ADJUSTABLE = 0x20,  TBSTYLE_BORDER=0x800000, TBSTYLE_THICKFRAME=0x40000, TBSTYLE_TABSTOP = 0x10000
	static TB_SETSTYLE=1080, TB_GETSTYLE=1081

	if pStyle is Integer
			style := pStyle
	else	style := TBSTYLE_%pStyle%
	ifEqual, style, , return "Err: Invalid style"

	WinSet, Style, ^%style%, ahk_id %hToolbar%

; This didn't work...
;	SendMessage, TB_GETSTYLE, ,,, ahk_id %hToolbar%
;	style := (ErrorLevel & style) ? ErrorLevel & !style : ErrorLevel | style
;	SendMessage, TB_SETSTYLE, 0, style,, ahk_id %hToolbar%

	if (style = TBSTYLE_LIST) {
		;somehow, text doesn't return without this, when you switch from ON to OFF
		Toolbar_SetMaxTextRows(hToolbar, 0)
		Toolbar_SetMaxTextRows(hToolbar, 1)	
	}

 	SendMessage,0x421,,,,ahk_id %hToolbar%	;autosize
}

;------------------------------------------------------------------------------
;Parse button definition list and compile it the into binary array. Add strings to pull. Return number of current buttons.
;  cBTN	 - Pointer to the compiled button array of current buttons
;  aBTN  - Pointer to the compiled button array of available buttons
;  pBtns - Button definition list
;  
;Button definition:
;	[*]caption, icon, state, style, id
;
Toolbar_compileButtons(hToolbar, pBtns, ByRef cBTN) {
	;var
	 local cnta, btnNO, a, cnt, hState, hStyle, o, sIdx, a0, a1, a2, a3, a4, a5, sep, buf, _, aBTN, warning ,bid, bMenu
	 ;styles
	  static BTNS_SEP=1, BTNS_CHECK =2, BTNS_CHECKGROUP = 6, BTNS_DROPDOWN = 8, BTNS_A=16, BTNS_AUTOSIZE = 16, BTNS_NOPREFIX = 32, BTNS_SHOWTEXT = 64
	 ;states
	  static TBSTATE_CHECKED=1, TBSTATE_ENABLED=4, TBSTATE_HIDDEN=8, TBSTATE_DISABLED=0, TBSTATE_WRAP = 0x20
	 ;other
	  static TB_ADDSTRING = 0x41C, WS_CLIPSIBLINGS = 0x4000000, id=10000	;automatic IDing starts form 10000,     1 <= userID < 10 000
    
	WinGet, bMenu, Style, ahk_id %hToolbar%
	bMenu := bMenu & WS_CLIPSIBLINGS

	if (Toolbar_%hToolbar%_aBTN = "")			;if space for array of * buttons isn't reserved and there are definitions of * buttons
		 aBTN := Toolbar_malloc( 50 * 20 + 4)	;reserve place for 50 buttons + some more so i can keep some data there....
	else aBTN := Toolbar_%hToolbar%_aBTN	

	StringReplace, _, pBtns, `n, , UseErrorLevel
	btnNo := ErrorLevel + 1
	cBTN := Toolbar_malloc( btnNo * 20 )

	a := cnt := 0, 	cnta := NumGet(aBTN+0)		;get number of buttons in the array
	loop, parse, pBtns, `n, %A_Space%%A_Tab%	
	{
		ifEqual, A_LoopField, ,continue			;skip emtpy lines

		a1:=a2:=a3:=a4:=a5:=""					;a1-caption;  a2-icon_num;  a3-state;  a4-style;	a5-id;
		StringSplit, a, A_LoopField, `,,%A_Space%%A_Tab%

	 ;check icon
		if (bMenu AND a2="") or (a2=0)
			a2 := -1		;so to become I_IMAGENONE = -2

	 ;check for available button
		a := SubStr(a1,1,1) = "*"
		if a
			a1 := SubStr(a1,2), o := aBTN + 4
		else o := cBtn

	 ;parse states
		hstate := InStr(a3, "disabled") ? 0 : TBSTATE_ENABLED
		loop, parse, a3, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		{
			ifEqual, A_LoopField,,continue
			hstate |= TBSTATE_%A_LOOPFIELD%
		}
		ifEqual, hState, , return "Err: Some of the states are invalid"

	 ;parse styles
		hStyle := 0
		if bMenu 
			hStyle := BTNS_SHOWTEXT | BTNS_DROPDOWN
		hstyle |= (A_LoopField >= "-") and (A_LoopField <= "-------------------") ? BTNS_SEP : 0
		sep += (hstyle = BTNS_SEP) ? 1 : 0
		loop, parse, a4, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		{
			ifEqual, A_LoopField,,continue
			hstyle |= BTNS_%A_LOOPFIELD%
		}
		ifEqual, hStyle, , return "Err: Some of the styles are invalid"

	 ;calculate icon
		if a2 is not Integer					;if user didn't specify icon, use button number as icon index (don't count separators)
			a2 := cnt+cnta+1-sep
		
		o += 20 * (a ? cnta : cnt)				;calculate offset o of this structure in array of TBBUTON structures.
												; only A buttons (* marked) are remembered, current buttons will temporary use
	 ;add caption to the string pool
		if (hstyle != BTNS_SEP) {
			StringReplace a1, a1, `r, `n, A		;replace `r with new lines (for multiline tooltips)
			VarSetCapacity(buf, StrLen(a1)+1, 0), buf := a1	 ;Buf must be double-NULL-terminated
			sIdx := DllCall("SendMessage","uint",hToolbar,"uint", TB_ADDSTRING, "uint",0,"uint",&buf)  ;returns the new index of the string within the string pool
		} else sIdx := -1,  a2 := (StrLen(A_LoopField)-1)*10 + 1			;if separator, lentgth of the "-" string determines width of the separation. Each - adds 10 pixels.
	 ;TBBUTTON Structure
		bid := a5 ? a5 : ++id 					;user id or auto id makes button id

		NumPut(a2-1,	o+0, 0)					;Zero-based index of the button image. If the button is a separator, determines the width of the separator, in pixels
		NumPut(bid,	o+0, 4)						;Command identifier associated with the button
		NumPut(hstate,  o+0, 8, "Char")			;Button state flags
		NumPut(hStyle,  o+0, 9, "Char")			;Button style
		NumPut(0,		o+0, 12)				;User data
		NumPut(sIdx,	o+0, 16)				;Zero-based index of the button string

		if a
		{
			if (cnta = 50)
				warning := true
			else cnta++
		}
		else cnt++
	}

	Toolbar_%hToolbar%_aBTN := aBTN				;save available buttons
	NumPut(cnta, aBTN + 0)	

	if warning
		msgbox You exceeded the limit of available buttons (50)
	return cnt									;return number of buttons in the array
}

Toolbar_onNotify(wparam, lparam) {
    local hwnd, id, code, TBB, iItem, o, fun, pos, txt, idFrom, msg
	static NM_CLICK=-2, TBN_DROPDOWN = -710, TBN_HOTITEMCHANGE = -713, TBN_BEGINADJUST=-703, TBN_GETBUTTONINFOA=-700, TBN_QUERYINSERT=-706, TBN_QUERYDELETE=-707, TBN_BEGINADJUST=-703, TBN_ENDADJUST=-704, TBN_RESET=-705, TBN_TOOLBARCHANGE=-708, TB_COMMANDTOINDEX = 0x419
	static cnt, cnta, cBTN, inDialog

	idFrom :=  NumGet(lparam+4)   ; and its ID 
	if (idFrom != Toolbar_MODULEID)
		return Toolbar_oldNotify ? DllCall(Toolbar_oldNotify, "uint", wparam, "uint", lparam, "uint", msg, "uint", hwnd) : ""

 ;NMHDR
	hwnd   :=  NumGet(lparam+0)	; control sending the message - this toolbar
;	idFrom :=  NumGet(lparam+4)	; and its ID
    code   :=  NumGet(lparam+8) - 4294967296

 ;TOOLBAR
	iItem  :=  (code != TBN_HOTITEMCHANGE) ? NumGet(lparam+12) : NumGet(lparam+16)
	
	SendMessage, TB_COMMANDTOINDEX,iItem,,,ahk_id %hwnd%	
	pos := ErrorLevel 
	
	
	pos++
	fun := Toolbar_%hwnd%_fun
	txt := Toolbar_GetButton( hwnd, pos, "c")

	if (code = NM_CLICK) {
		IfEqual, pos, 4294967296, return
		return %fun%(hwnd, "click", pos, txt, iItem)
	}

	if (code = TBN_DROPDOWN)
		return %fun%(hwnd, "menu", pos, txt, iItem)

	if (code = TBN_HOTITEMCHANGE) {
		IfEqual, pos, 4294967296, return
		%fun%(hwnd, "hot", pos, txt, iItem)
		return 0
	}


	if (code = TBN_BEGINADJUST) {
		cnta := NumGet(Toolbar_%hwnd%_aBTN+0), cnt := Toolbar_getButtonArray(hwnd, cBTN), inDialog := true
		if (cnta="" or cnta=0) AND (cnt=0)
			Msgbox Nothing to customize
		return
	}

	if (code = TBN_GETBUTTONINFOA)	{
		if (iItem = cnt + cnta)		;iItem is position, not identifier. Win keeps sending incresing numbers until we say "no more" (return 0)
			return 0
		
		TBB := lparam + 16			;The OS buffer where to put button structure
		o := (iItem < cnt) ?  cBTN + 20*iItem : Toolbar_%hwnd%_aBTN + 20*(iItem-cnt) + 4
		Toolbar_memcpy( TBB, o, 20) ;copy the compiled item into notification struct
		return 1
	}

	;Return at least one TRUE in QueryInsert to show the dialog, if the dialog is openinig. When the dialog is open, QueryInsert affects btn addition. QueryDelete affects deletion.
	if (code = TBN_QUERYINSERT) or (code = TBN_QUERYDELETE) {
		if (cnta="" or cnta=0) AND (cnt=0)
			return FALSE
		return TRUE
	}

	if (code=TBN_ENDADJUST) {
		Toolbar_onEndAdjust(hwnd, cBTN, cnt), inDialog := false
		return %fun%(hwnd, "adjust", "", "", "")
	}

	;This will fire when user is dragging buttons around with adjustable style
	if (code = TBN_TOOLBARCHANGE) and !inDialog
		return %fun%(hwnd, "change", "", "", "")
}


;I am not keeping current buttons in memory, so I must obtain them if customization dialog is called, to populate it
Toolbar_getButtonArray(hToolbar, ByRef cBtn){
	static TB_GETBUTTON = 0x417

	cnt := Toolbar_Count(hToolbar)	

	cBtn := Toolbar_malloc( cnt * 20 )
	loop, %cnt%
		SendMessage, TB_GETBUTTON, A_Index-1, cbtn + (A_Index-1)*20,,ahk_id %hToolbar%

	return cnt
}

Toolbar_getStateName( hState ) {
	static TBSTATE_HIDDEN=8, TBSTATE_PRESSED = 0x2, TBSTATE_CHECKED=1, TBSTATE_ENABLED=0x4
	static states="hidden,pressed,checked,enabled"

	if !(hState & TBSTATE_ENABLED)				
		state := "disabled "

	ifEqual,hState, %TBSTATE_ENABLED%, return

	loop, parse, states, `,
		if (hState & TBSTATE_%A_LoopField%)
			state .= A_LoopField " "

	StringReplace state, state, %A_Space%enabled%A_Space%
	return state
}

Toolbar_getStyleName( hStyle ) {
	static BTNS_CHECK=2, BTNS_GROUP = 4, BTNS_DROPDOWN = 8, BTNS_AUTOSIZE = 16, BTNS_NOPREFIX = 32, BTNS_SHOWTEXT = 64
	static styles="check,group,dropdown,autosize,noprefix,showtext"
	
	loop, parse, styles, `,
		if (hStyle & BTNS_%A_LoopField%)
			style .= A_LoopField " "
	StringReplace, style, style, check group, checkgroup		;I don't use group flag at all
	return style
}

;----------------------------------------------------------------------------------------------
;After the customization dialog finishes, order and placements of buttons of the left and right side is changed.
;As I keep available buttons as part of the AHK API, I must rebuild array of available buttons; add to it buttons 
; that are removed from the toolbar and remove buttons that are added to the toolbar.
;
Toolbar_onEndAdjust(hToolbar, cBTN, cnt) {
	local aBtn, cnta, cnta2, id, size, o, buf
	static TB_COMMANDTOINDEX = 0x419, BTNS_SEP=1
	
	aBtn := Toolbar_%hToolbar%_aBTN + 4, 	cnta := NumGet(Toolbar_%hToolbar%_aBTN+0)
	size := cnt+cnta,  size := size<50 ? 50 : size			;reserve memory for new aBTN array, minimum 50 buttons
	buf := Toolbar_malloc( size * 20 + 4)

  ;check current button changes
    cnta2 := 0
	loop, %cnt%
	{
		o := cBTN + 20*(A_Index-1),	id := NumGet(o+0, 4)
		SendMessage, TB_COMMANDTOINDEX,id,,,ahk_id %hToolbar%		
		if Errorlevel != 4294967295							;if errorlevel = -1 button isn't on toolbar
			continue
		if NumGet(o+0, 9, "Char") = BTNS_SEP				;skip separators
			continue
	   Toolbar_memcpy( buf + cnta2++*20 +4, o, 20) ;copy the button struct into new array
	}
	Toolbar_mfree(cBTN)	

  ;check available button changes
	loop, %cnta%
	{
		o := aBTN + 20*(A_Index-1),	id := NumGet(o+0, 4)
		SendMessage, TB_COMMANDTOINDEX,id,,,ahk_id %hToolbar%		
		if Errorlevel != 4294967295							;if errorlevel = -1 button isn't on toolbar
			continue
		Toolbar_memcpy(buf + cnta2++*20 +4, o, 20) ;copy the button struct into new array
	}
	Toolbar_mfree(aBTN)

	Toolbar_%hToolbar%_aBTN := buf, NumPut(cnta2, buf+0)	;save array
}


Toolbar_malloc(pSize){
	static MEM_COMMIT=0x1000, PAGE_READWRITE=0x04
	return DllCall("VirtualAlloc", "uint", 0, "uint", pSize, "uint", MEM_COMMIT, "uint", PAGE_READWRITE)
}

Toolbar_mfree(pAdr) {
	static MEM_RELEASE = 0x8000
	return DllCall("VirtualFree", "uint", pAdr, "uint", 0, "uint", MEM_RELEASE)
}

Toolbar_memmove(dst, src, cnt) {
	return DllCall("MSVCRT\memmove", "uint", dst, "uint", src, "uint", cnt)
}

Toolbar_memcpy(dst, src, cnt) {
	return DllCall("MSVCRT\memcpy", "UInt", dst, "UInt", src, "uint", cnt)
}

;-------------------------------------------------------------------------------------------------------------------
;Group: Example
;
;>  Gui, +LastFound
;>  hGui := WinExist()
;>  Gui, Show , w400 h100 Hide                              ;set gui width & height prior to adding toolbar (mandatory)
;>
;>  hToolbar := Toolbar_Add(hGui, "OnToolbar", "FLAT TOOLTIPS", "1L")    ;add the toolbar
;>
;>  btns =
;>   (LTrim
;>      new,  7,            ,dropdown showtext
;>      open, 8
;>      save, 9, disabled
;>      -
;>      undo, 4,            ,dropdown
;>      redo, 5,            ,dropdown
;>      -----
;>      state, 11, checked  ,check
;>   )
;>
;>   Toolbar_AddButtons(hToolbar, btns)
;>   Toolbar_SetButtonWidth(hToolbar, 50)                   ;set button width & height to 50 pixels
;>
;>   Gui, Show
;>return
;>
;>;toolbar event handler
;>OnToolbar(hToolbar, pEvent, pPos, pTxt, pId){				
;>	if pEvent = click
;>		msgbox %pTxt% (%pPos%)
;>}
;>
;>#include Toolbar.ahk

;-------------------------------------------------------------------------------------------------------------------
;Group: About
;	o Ver 2.0 b3 by majkinetor. 
;	o Toolbar Reference at MSDN: <http://msdn2.microsoft.com/en-us/library/bb760435(VS.85).aspx>
;	o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.  
