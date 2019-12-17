;===========================================
;	LOAD EXTERNAL SCRIPT : CLIPBOARD CODE
;===========================================
ClipGUI:
	InScrName=Clip
	scrLines=0
	Loop, Parse, Clipboard, `n
		scrLines++
	gosub cmnEditStart
	Loop, Parse, Clipboard, `n
		{
		CurrLine := A_LoopField
		gosub commonEdit
		}
goto CheckCode
return
;===========================================
;	LOAD EXTERNAL SCRIPT : DRAG'N'DROP
;===========================================
;dropped a script to edit
GuiDropFiles:

	;edit only one script per session
	IfNotEqual, InputScript,, Return

	IfInString, A_GuiControlEvent, `n
		StringGetPos, CRPos, A_GuiControlEvent, `n

	IfNotEqual, CRPos,
		StringLeft, InputScript, A_GuiControlEvent, %CRPos%
	Else
		InputScript = %A_GuiControlEvent%

	CRPos =
	goto LockNload
;===========================================
;	LOAD EXTERNAL SCRIPT : COMMANDLINE PARAMETER
;===========================================
EditGUI:
	Gui, 9:+OwnDialogs
	IfExist, %1%
		InputScript = %1%

	if w9x
		{
		Hotkey9x("LD", "Off")
		IfNotExist, %InputScript%, FileSelectFile, InputScript, 1, %LoadDir%, Select GUI script to edit, AutoHotkey GUI script (*.ahk)
		Hotkey9x("LD", "On")
		}
	else
		{
		Hotkey, *~LButton, Off
		IfNotExist, %InputScript%, FileSelectFile, InputScript, 1, %LoadDir%, Select GUI script to edit, AutoHotkey GUI script (*.ahk)
		Hotkey, *~LButton, On
		}

	IfNotExist, %InputScript%
		{
		InputScript =
		Return
		}
;===========================================
LockNload:
	SplitPath, InputScript,, LoadDir, Ext, InScrName
	If Ext not in ahk,txt			; push the limits: allow txt files as they may contain AHK code
		{
		InputScript =
		Return
		}

	SaveAsFile = %InputScript%
	scrLines=0
	Loop, Read, %InputScript%
		scrLines++
	gosub cmnEditStart
	Loop, Read, %InputScript%
		{
		CurrLine := A_LoopReadLine
		gosub commonEdit
		}
goto CheckCode
return
;===========================================
cmnEditStart:
	Progress, B P0 X150 Y20 H30 W230 FM8 ZX0 ZY0 ZH10 R0-%scrLines%,, Processing script...,, Tahoma
	Menu, FileMenu, Disable, &Open Script
	Menu, FileMenu, Disable, GUI St&ealer
	Menu, FileMenu, Disable, &Load Script from clipboard
	Gui_Status = 0
	; 0 gui not started
	; 1 gui add going on
	; 2 gui show
	; 3 gui show passed
	menuAdded=
	menuRead=
	menuLabels=
	MenuScript=	; gathers menu commands separately in a block
	prevLine=
	blockCmt=0
	iIdx=0
	cbc=0		; open/close bracket count for conditions
	conditions :="if,else,ifequal,ifless,ifgreater,ifinstring,ifnotinstring,ifexist,ifnotexist,while,loop," Chr(123)
return
;===========================================
commonEdit:
	Progress, %A_Index%
	CL = %CurrLine%
	Check = %CL%
;_________________________________________________________
	; check for commented block
	StringLeft, CmtCheck, Check, 2
if debug
	FileAppend,
(
cpos=%cpos%
CmtCheck=[%CmtCheck%]
Line %A_Index%:
[%CurrLine%]
blockCmt=%blockCmt%
MenuScript:
%menuScript%
), %debugdir%\scriptParse_%InScrName%.txt
	if CmtCheck = /*
		{
		blockCmt++
		goto addLine
		}
	if (CmtCheck = "*/" && blockCmt)
		{
		blockCmt--
		goto addLine
		}
	if blockCmt
		goto addLine
;_________________________________________________________
	;Get script cmd till 2nd comma
	StringGetPos, cpos, CL, `,, L2
	StringLeft, GuiCheck, CL, %cpos%

	Check = %GuiCheck%
	Check = %Check%
	;Check for commented line
	StringLeft, CmtCheck, Check, 1

	IfNotEqual, CmtCheck, `;
		{
		StringReplace, CLc, CL, %A_Tab%, %A_Space%, All
		StringSplit, item, CLc, %A_Space%, `,
		If item1 in %conditions%
			{
			if (item1 = Chr(123))
				cbc++
			if item1 in ifexist,ifnotexist
				if item3
					goto checkGM
			if item1 in ifequal,ifless,ifgreater
				if item4
					goto checkGM
			if item1 = else
				if item2
					goto checkGM
			prevLine .= CurrLine "`n"
			}
checkGM:
		IfInString, GuiCheck, Gui`,
			{
			IfNotEqual, Gui_Status, 2
				IfNotEqual, Gui_Status, 3
					{
					;gui script started
					IfNotEqual, Gui_Status, 2
						Gui_Status = 1
					IfInString, GuiCheck, Show
						Gui_Status = 2
					}
			IfInString, GuiCheck, Menu
				if !menuRead	; only import first displayed menu (buggy)
					{
					StringSplit, item, CL, `,, %A_Space%
					CtrlText := item3
					item0 := item1 := item2 := item3 :=
					menuRead=1
					}
			}
;===========================================
; Parsing Menu commands first, to make sure control coordinates are all correct afterwards.
; Scripts that contain a main Menu should have these commands before any GUI command
		else If InStr(CL, "Menu,") = 1
			if InStr(CL, "Tray,")
				Gui_Status = 0
			else IfNotEqual, Gui_Status, 2
				{
				IfNotEqual, Gui_Status, 3
				{
				Gui_Status = 1
				data = %CL%
				param4=
				param5=
				KiIdx=
				LiIdx=
				StringSplit, param, data, `,, %A_Space%
;_________________________________________________________
				IfEqual, param3, Add
					{
					iIdx++
					pvIdx := param2 = prevP ? prevI : "0"
					pIdx := param2
					if !param4
						{
						param4 := sstr
						cIdx = 3
						}
					else
						{
						IfNotInString, menuAdded, %param2%|
							menuAdded .= param2 "|"
					; clean up in-line comments that can screw up goto labels
						tmpV := InStr(param5, Chr(59))
						if tmpV
							{
							StringLeft, param5, param5, tmpV-1
							StringReplace, param5, param5, %A_Tab%,, A
							param5 = %param5%
							}
						if (SubStr(param5, 1, 1) = Chr(58))
							isM=1
						else IfNotInString, menuLabels, %param5%|
								menuLabels .= param5 "|"
						LiIdx := param5
						tmpV := InStr(param4, A_Tab) ? InStr(param4, A_Tab) : InStr(param4, "``t")
						if tmpV
							{
							StringReplace, param4, param4, ``t,, A
							StringReplace, param4, param4, %A_Tab%,, A
					; needs a better RegExReplace for non-alphanumeric chars in hotkeys (such as [ ] { } etc.)
							KiIdx := RegExReplace(SubStr(param4, tmpV), "^(\*|{|\(|\[)+|(\*|}|\)|\])+")
							if debug
								msgbox, hotkey is: %KiIdx%
							StringReplace, KiIdx, KiIdx, Shift`+, `+
							StringReplace, KiIdx, KiIdx, Alt`+, !
							StringReplace, KiIdx, KiIdx, Ctrl`+, ^
							StringReplace, KiIdx, KiIdx, Win`+, #
							param4 := SubStr(param4, 1, tmpV-1)
							}
						StringReplace, param4, param4, ``&, `&, A
						StringReplace, param4, param4, ``:, `:, A
						cIdx = 2
						}
					tmpV := param4 Chr(160) iIdx Chr(160) pIdx Chr(160) pvIdx Chr(160) cIdx Chr(160) KiIdx Chr(160) LiIdx Chr(160) "|"
					if isM
						{
						TVml .= tmpV
						mStr .= SubStr(param5, 2) "|"
						}
					else
					TVtl%param2% .= tmpV
					prevP := param2
					prevI := iIdx
					isM=
;					MenuScript .= "`n" CurrLine
					}
;_________________________________________________________
				else IfEqual, param3, Color
					Menu_%param2%_color = %param4%
;_________________________________________________________
				else IfEqual, param3, Default
					Gui_Status=1
				}
			}
		else if !prevLine
			Gui_Status=0
		}
;===========================================
addLine:
	if prevLine
		{
		if (CL = Chr(125) && cbc)
			{
			if --cbc
				return
			CurrLine := prevLine CurrLine
			}
		prevLine=
		}
	IfEqual, Gui_Status, 0
		BeforeScript := BeforeScript "`n" CurrLine
	IfEqual, Gui_Status, 1
		GuiScript := GuiScript "`n" CurrLine
	IfEqual, Gui_Status, 2
		{
		GuiScript := GuiScript "`n" CurrLine
		Gui_Status = 3
		return
		}
	IfEqual, Gui_Status, 3
		AfterScript := AfterScript "`n" CurrLine
Return

CheckCode:
	Progress, Off
	if menuRead && isMenuEditor
		gosub %isMenuEditor%
	StringTrimLeft, BeforeScript, BeforeScript, 1
	StringTrimLeft, AfterScript, AfterScript, 1
	if debug
		{
		FileDelete, scripts.txt
		FileAppend, BEFORE:`n`n%BeforeScript%`n`nAFTER:`n`n%AfterScript%`n`nGUI:`n`n%GuiScript%, scripts.txt
		run, scripts.txt
		}
	isDefFont=
	setDefFont=1
	cFontIdx := pFontIdx := ""
	Loop, Parse, GuiScript, `n
		{
		IfEqual, A_LoopField,, Continue

		CurrLine = %A_LoopField%
		;Check for commented line
		CmtCheck =
		ToStrip = %CurrLine%
		ToStrip = %ToStrip%

		StringLeft, CmtCheck, ToStrip, 1
		IfEqual, CmtCheck, `;, Continue
		if i := InStr(CmtCheck, ";")
			if (InStr(CmtCheck, "`") != i-1)
				StringTrimLeft, CmtCheck, CmtCheck, i-1
		;Get script cmd till 2nd comma
		StringGetPos, cpos, CurrLine, `,, L2
		StringLeft, check, CurrLine, %cpos%

		;to take care of out of tab controls
		;spl treatment because this cmd doesn't have 2 commas
		IfEqual, Check,
			IfInString, CurrLine, Gui
				IfInString, CurrLine, Tab
					{
					Gui, 1:Tab
					TabCount ++
					Gui, 1:Tab, %TabCount%
					}
		;For Gui, Tab_______________________________
		IfInString, check, GUI
			IfInString, check, Tab
				{
				IfNotEqual, TabCreated, 1, Continue

				StringGetPos, fpos, check, Tab
				fpos += 3
				StringTrimLeft, data, CurrLine, %fpos%

				Param2 =

				StringSplit, param, data, `,
				IfInString, param2, `:, Continue

				StringReplace, check, param2, %a_space%,, All	; why????
				IfEqual, check,, SetEnv, param2,

				;literal spaces around Tab name can create problems
				param2 = %param2%

				Gui, 1:Tab, %param2%
				TabCount ++
				Gui, 1:Submit, NoHide
				IniRead, ItemList, %iniWork%, Main, ItemList, |
				chT := param2 ? "TabChange" param2 : "TabNUL"
				IniWrite, %ItemList%%chT%|, %iniWork%, Main, ItemList
				}
		;For Gui, Font______________________________
		IfInString, check, GUI
			IfInString, check, Font
				{
				StringGetPos, fpos, check, Font
				fpos += 4
				StringTrimLeft, data, CurrLine, %fpos%

				Param2 =
				Param3 =

				StringSplit, param, data, `,
				IfInString, param2, `:, Continue

				StringReplace, check, param2, %A_Space%,, All
				IfEqual, check,, SetEnv, param2,

				StringReplace, check, param3, %A_Space%,, All
				IfEqual, check,, SetEnv, param3,

				;literal spaces around font name create problems
				param3 = %param3%
; s-size c-color w-weight italic underline strike name charset / bold norm default
				j := "||||||" param3 "|Western"
				StringSplit, i, j, |
				Loop, Parse, param2, %A_Space%, %A_Space%
					{
					if InStr(A_LoopField, "norm")
						{
						i3=400
						i4 := i5 := i6 := ""
						}
					else if InStr(A_LoopField, "bold")
						i3=700
					else if InStr(A_LoopField, "italic")
						StringUpper, i4, A_LoopField, T
					else if InStr(A_LoopField, "underline")
						StringUpper, i5, A_LoopField, T
					else if InStr(A_LoopField, "strike")
						StringUpper, i6, A_LoopField, T
					else
						{
						StringLeft, i, A_LoopField, 1
						StringTrimLeft, k, A_LoopField, 1
						if i=s
							i1 := k+0
						else if i=w
							i3 := k+0
						else if i=c
							i2 := FormatColor(k)
						}
					}
				j := i1 "|" i2 "|" i3 "|" i4 "|" i5 "|" i6 "|" i7 "|" i8
				gosub fontcommon1
				}
		;For Gui, Color______________________________
		IfInString, check, GUI
			IfInString, check, Color
				if !GuiColor
				{
				StringGetPos, fpos, check, Color
				fpos += 5
				StringTrimLeft, data, CurrLine, %fpos%

				Param2 =
				Param3 =

				StringSplit, param, data, `,
				IfInString, param2, `:, Continue

				StringReplace, check, param2, %A_Space%,, All
				IfEqual, check,, SetEnv, param2,

				StringReplace, check, param3, %A_Space%,, All
				IfEqual, check,, SetEnv, param3,
				;GUI, 1:Color, %param2%, %param3%	; don't use, it kills the grid !!!
				GuiColor=1
				IniWrite, %param2%`,%param3%, %iniWork%, GUI%GuiCount%, Color
; need to enable respective controls in GUI11
				GO1=1
				GuiControl, 11:+Background%param2%, defGC
				GuiControl, 11:+Background%param3%, defCC
				}
		;For Gui, Margin______________________________
		IfInString, check, GUI
			IfInString, check, Margin
				if !GuiMargin
				{
				StringGetPos, fpos, check, Margin
				fpos += 6
				StringTrimLeft, data, CurrLine, %fpos%

				Param2 =
				Param3 =

				StringSplit, param, data, `,
				IfInString, param2, `:, Continue

				StringReplace, check, param2, %A_Space%,, All
				IfEqual, check,, SetEnv, param2,

				StringReplace, check, param3, %A_Space%,, All
				IfEqual, check,, SetEnv, param3,
				GUI, 1:Margin, %param2%, %param3%
				GuiMargin=1
				IniWrite, %param2%`,%param3%, %iniWork%, GUI%GuiCount%, Margin
; need to enable respective controls in GUI11
				}
		;For Gui, Add_______________________________
		IfInString, check, GUI
			IfInString, check, Add
				{
				StringGetPos, apos, check, Add
				apos += 3
				StringTrimLeft, data, CurrLine, %apos%

				;check to see if the cmd has at least 2 params and make the rest blank
				StringSplit, param, data, `,
				IfLess, param0, 4, SetEnv, param4,
				IfLess, param0, 3, SetEnv, param3,
				IfLess, param0, 2, Continue
				IfInString, param2, `:, Continue
				;to take care of commas in control labels
				IfGreater, param0, 4
				Loop, %param0%
					{
					IfLess, A_Index, 5, Continue
					StringTrimRight, currparam, param%A_Index%, 0
					param4 = %param4%`,%currparam%
					}

				;formatting control labels
				StringReplace, CtrlText, param4, ```,, `,, A
				StringReplace, CtrlText, CtrlText, ``n, `n, A
				StringReplace, CtrlText, CtrlText, ```%, `%, A

				;getting CtrlName & CtrlCount
				Ctrl2Add = %param2%
				CtrlName = %param2%
				IfEqual, Ctrl2Add, CheckBox, SetEnv, CtrlName, Button
				IfEqual, Ctrl2Add, ComboBox, SetEnv, CtrlName, ComboBox
				IfEqual, Ctrl2Add, DateTime, SetEnv, CtrlName, SysDateTimePick32
				IfEqual, Ctrl2Add, DropDownList, SetEnv, CtrlName, ComboBox
				IfEqual, Ctrl2Add, GroupBox, SetEnv, CtrlName, Button
				IfEqual, Ctrl2Add, Hotkey, SetEnv, CtrlName, msctls_hotkey32
				IfEqual, Ctrl2Add, ListBox, SetEnv, CtrlName, ListBox
				IfEqual, Ctrl2Add, ListView, SetEnv, CtrlName, SysListView32
				IfEqual, Ctrl2Add, MonthCal, SetEnv, CtrlName, SysMonthCal32
				IfEqual, Ctrl2Add, Picture, SetEnv, CtrlName, Static
				IfEqual, Ctrl2Add, Progress, SetEnv, CtrlName, msctls_progress32
				IfEqual, Ctrl2Add, Radio, SetEnv, CtrlName, Button
				IfEqual, Ctrl2Add, RichText, SetEnv, CtrlName, RichEdit20W
				IfEqual, Ctrl2Add, Slider, SetEnv, CtrlName, msctls_trackbar32
				IfEqual, Ctrl2Add, StatusBar, SetEnv, CtrlName, msctls_statusbar32
				IfEqual, Ctrl2Add, Tab2, SetEnv, Ctrl2Add, Tab
				IfEqual, Ctrl2Add, Tab, SetEnv, CtrlName, SysTabControl32
				IfEqual, Ctrl2Add, Text, SetEnv, CtrlName, Static
				IfEqual, Ctrl2Add, TreeView, SetEnv, CtrlName, SysTreeView32
				IfEqual, Ctrl2Add, UpDown, SetEnv, CtrlName, msctls_UpDown32
				CtrlCount := ++%CtrlName%Count
				;analysing various options
				Options =
				OptionsA =
; coords were being inherited from some previous control, messing it all up...
				cX := cY := cW := cH := ""
				Loop, Parse, param3, %A_Space%
					{
					IfEqual, A_LoopField,, Continue
; When options are treated as one variable (single percent version), we need this to pass other processing.
; However, g-Labels are a pain, since they cannot be created on-the-fly,
; so we save them separately to the ini
					IfEqual, A_LoopField, `%
						{
						param3 = %param3%
;msgbox, first field: %A_LoopField%`nparam3:`n%param3%
						Loop, Parse, param3, %A_Space%
						if SubStr(A_LoopField, 1, 1) in g
							if (SubStr(A_LoopField, 2, 1) not in Chr(34))
								{
								gLabel := A_LoopField
								StringReplace, param3, param3, %gLabel%
								}
						IfEqual, Ctrl2Add, StatusBar
							if SubStr(A_LoopField, 1, 11) contains Background
								{
								IniWrite, %A_LoopField%, %iniWork%, %Ctrl2Add%, Color
								StringReplace, param3, param3, %A_LoopField%
								}
						Options = %param3%
;msgbox, block options:`n%Options%`nparam3:`n%param3%
						cX := cY := cW := cH := ""
						blockOpt=1
						break
						}
					StringLeft, Opt1, A_LoopField, 1
					StringTrimLeft, Opt2, A_LoopField, 1
					tmpV := A_LoopField
					;position
					Done = 0
					Loop, Parse, PosFields
						{
						IfEqual, Opt1, %A_LoopField%
							if tmpV not contains Hidden,Hwnd	; got tired of seeing "H=idden" in the ini... *sigh*
								{
								c%A_LoopField% = %Opt2%
							;	IniWrite, %Opt2%, %iniWork%, %CtrlName%%CtrlCount%, %A_LoopField%
								Done = 1
								}
						}
					IfEqual, Done, 1, Continue

					; StatusBar background color must be saved separately
					IfEqual, Ctrl2Add, StatusBar
						{
						i := SubStr(A_LoopField, 1, 11)
						if i contains Background
							{
							CtrlColor := A_LoopField
							StringReplace, i, A_LoopField, Background
							StringLeft, j, i, 1
							if j in +,-
								StringTrimLeft, i, i, 1
							IniWrite, %i%, %iniWork%, %Ctrl2Add%, Color
							StringReplace, Options, Options, %A_LoopField%,
							Options = %Options%
							continue
							}
						}
					;all options are saved and processed
					;Group and Var options are just saved
					Options = %Options% %Opt1%%Opt2%
					If Opt1 Not In G,V
						OptionsA = %OptionsA% %tmpV%

					}

				param2 = %param2%
				param3 = %param3%
				param4 = %param4%
				CtrlText = %CtrlText%
				Options = %Options%
; we have a problem: controls added after GUI creation without size/coordinates, won't show up
				currCoord := (cX ? "x" cX " " : "") (cY ? "y" cY " " : "") (cW ? "w" cW " " : "") (cH ? "h" cH : "")
;msgbox, control=%param2%`ncurrCoord=%currCoord%`nOptions=%Options%`nOptionsA=%OptionsA%`nborder=%bord%`ntext=%CtrlText%
				if blockOpt
					{
					bord := TabCreated ? "Border" :
; because variables parsing is utterly non-cooperative, I can't add the options block here
					GUI, 1:Add, %param2%, %bord%, %CtrlText%
					}
				else
				;remember that tab is created
				;and disable further tab support
				If param2 in Tab2,Tab
					{
					IfEqual, TabCreated, 1, Continue

					commonOptions = %currCoord% vTabName gTabGroup %OptionsA%
					commonOptions = %commonOptions%
					GUI, 1:Add, Tab, %commonOptions%, %CtrlText%	; DON'T use Tab2, it hides all controls !!!
					TabCreated = 1
					}
				Else
					{
					;create border for controls on Tab
					bord := TabCreated ? "Border" :
					commonOptions = %currCoord% %bord% %OptionsA%
					if param2=StatusBar
						commonOptions = %commonOptions% %CtrlColor% gSBclick
					commonOptions = %commonOptions%
					GUI, 1:Add, %param2%, %commonOptions%, %CtrlText%
;msgbox, GUI, 1:Add, %param2%, %commonOptions%, %CtrlText%`n`ncontrol=%param2%`ncommonOptions=%commonOptions%`ncurrCoord=%currCoord%`nOptions=%Options%`nOptionsA=%OptionsA%`nborder=%bord%`ntext=%CtrlText%
					}

				IniRead, ItemList, %iniWork%, Main, ItemList, |
				i := Ctrl2Add="StatusBar" ? Ctrl2Add : CtrlName CtrlCount
				IniWrite, %ItemList%%i%|, %iniWork%, Main, ItemList
				IniWrite, %param2%, %iniWork%, %i%, Name
				IniWrite, %param4%, %iniWork%, %i%, Label
				IniWrite, %Options%, %iniWork%, %i%, Options
				if gLabel
					{
					IniWrite, %gLabel%, %iniWork%, %i%, gLabel
					gLabel=
					}
				if Ctrl2Add not in StatusBar
					Loop, Parse, PosFields
						{
						CurrPos := c%A_LoopField%
						IniWrite, %CurrPos%, %iniWork%, %CtrlName%%CtrlCount%, %A_LoopField%
						}

				;fix for grid for Tabs
				;remove WS_CLIPSIBLINGS
				If Ctrl2Add In Tab,ListView
					GuiControl, 1:-0x4000000, %CtrlName%%CtrlCount%

				Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
				Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
				}
		;For Gui, Show______________________________
		IfInString, check, GUI
			IfInString, check, Show
				{
				StringGetPos, spos, check, Show
				spos += 4
				StringTrimLeft, data, CurrLine, %spos%
				data = %data%
/* can't remember what this was for, but it breaks GUI coords
				Loop
					{
					i := SubStr(data, 1, 1)
					if i in ,,
						StringTrimLeft, data, data, 1
					else break
					}
*/
				param2 =
				param3 =
				StringSplit, param, data, `,
				IfLess, param0, 2, SetEnv, param2,
				IfInString, param2, `:, Continue

				param2 = %param2%
				param3 = %param3%
				StringReplace, param2, param2, `r	; these 2 lines clean up some odd EOL that prevent
				StringReplace, param3, param3, `r	; correct parsing of parameters
; we need to save the SHOW parameters for saving time
				StringReplace, ShParam, param2, Hide,,
				Loop, Parse, GuiOptPars, CSV
					StringReplace, ShParam, ShParam, %A_LoopField%,,
				StringReplace, ShParam, ShParam, %A_Space%%A_Space%, %A_Space%, All
;				GUI, 1:Show, %param2%
				IniWrite, %param3%, %iniWork%, Main, Title
				IniWrite, %param2%, %iniWork%, Main, Options
;				Break
				}
		;For StatusBar______________________________
		IfInString, ToStrip, SB_SetParts
			{
			StringReplace, i, ToStrip, SB_SetParts(,,
			StringTrimRight, SBparts, i, 1
			StringSplit, i, SBparts, `,, %A_Space%
			Gui, 1:Default
			SB_SetParts(i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25
			, i26, i27, i28, i29, i30, i31, i32, i33, i34, i35, i36, i37, i38, i39, i40, i41, i42, i43, i44, i45, i46, i47, i48, i49, i50)
			IniWrite, %SBparts%, %iniWork%, StatusBar, Parts
			}
		IfInString, ToStrip, SB_SetIcon
			{
			StringReplace, i, ToStrip, SB_SetIcon(,,
			StringTrimRight, i, i, 1
			StringReplace, i, i, `",, All
			StringSplit, i, i, `,, %A_Space%
			Gui, 1:Default
			SB_SetIcon(i1, i2, i3)
			IniWrite, %i1%, %iniWork%, StatusBar, %i3%IconFile
			IniWrite, %i2%, %iniWork%, StatusBar, %i3%IconNmb
			}
		}
;	param2 := (param2 <> "Hide") ? param2 : ""
	GUI, 1:Show, %ShParam%
	Ctrl2Add =
Return

FormatColor(c, t="H")
{
Static colornames="Black|0,Silver|C0C0C0,Gray|808080,White|FFFFFF,Maroon|800000,Red|FF0000,Purple|800080,Fuchsia|FF00FF,Green|8000,Lime|FF00,Olive|808000,Yellow|FFFF00,Navy|80,Blue|FF,Teal|8080,Aqua|FFFF"
if c=Default
	return c
if t not in H,D
	t=H
ofi := A_FormatInteger
SetFormat, Integer, %t%
if c is not integer
	r := "0x" c
if r is not integer
	Loop, Parse, colornames, CSV
		if InStr(A_LoopField, c)=1
			{
			StringSplit, i, A_LoopField, |
			r := "0x" i2
			break
			}
else r := c+0
SetFormat, Integer, %ofi%
return r
}
