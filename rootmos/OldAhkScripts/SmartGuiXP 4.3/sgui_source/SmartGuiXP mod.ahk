/*
___________________________________________
______SmartGUI Creator   - Rajat___________
___________________________________________
     GUI creation tool for AutoHotkey
            (www.autohotkey.com)
modded by Drugwash for Win9x support
___________________________________________
GUI1 = Main window
GUI2 = About window
GUI3 = Move group window
GUI4 = Set SnapToGrid window
GUI5 = GUI Helper window
GUI6 = Set Position
GUI7 = Custom Control Option
GUI8 = Save Options
GUI9 = ToolBar
GUI10= Menu editor
GUI11= GUI options
GUI12 = GUI properties (title, count, position)
GUI97= Grid/Skin chooser
GUI98= Change label
GUI99= Mini help

*ToolTip1 = Toolbar help (deleted)
ToolTip2 = Move Group selection
ToolTip3 = debug (window notifications) TVX_msg()
ToolTip4 = warning no label assigned (EditMenu)
ToolTip5 = custom options selection

Support for new controls to be added in:
	-Main Menu (in progress)
	-CreateCtrl
	-EditGUI
	-GUIStealer
	-Justify options
___________________________________________
Misc Notes:
Controls := Button,Checkbox,ComboBox,DateTime,DropDownList,Edit,GroupBox,Hotkey,ListBox,ListView
,Menu,MonthCal,Progress,Picture,Radio,Slider,StatusBar,Tab,Text,TreeView,UpDown
___________________________________________
*/
; Release version
appname=SmartGuiXP Creator mod
release=May 1, 2014
version=4.3.29.7
type=public
;___________________________________________
; Pre-run checks
#SingleInstance Ignore
SetFormat, Integer, D
i = %1%
IfEqual, A_OSType, WIN32_WINDOWS
	w9x = 1	; OS type switch for functions
TempDir=%Temp%\SGUI
FileCreateDir, %TempDir%
IniRead, port, %A_ScriptDir%\SmartGUI.ini, Settings, Portable, 0
port := w9x ? 1 : port
CreateAppdir:
appdir := (w9x OR port) ? A_ScriptDir : A_AppData "\" appname
IfNotExist, %appdir%
	{
	MsgBox, 0x43044, %appname% Information, Please note that starting with %appname% v4.3.27.1,`ndefault folder for user settings data has been changed to:`n%appdir%`n`nSettings file will be moved to that location.`nDebug logs will also be saved to the same location.`n`nPress 'Yes' to agree or 'No' for a portable setup`n(the option can also be changed later from main menu).
	IfMsgBox No
		{
		port=1
		appdir := A_ScriptDir
		}
	else
		{
		FileCreateDir, %appdir%
		if !ErrorLevel
			FileMove, %A_ScriptDir%\SmartGUI.ini, %appdir%\SmartGUI.ini
		else 
			{
			MsgBox, 0x43014, %appname% Error, Cannot create userdata folder in`n%appdir%`nPlease check free space and/or permissions.`n`nWould you like to try again?
			IfMsgBox Yes
				goto CreateAppdir
			port=1
			appdir := A_ScriptDir
			}
		}
	}
iniSet=%appdir%\SmartGUI.ini
manPath=%A_ScriptDir%\SGUI_Manual.htm
hCursM := DllCall("LoadCursor", "UInt", NULL, "Int", 32646, "UInt")		; IDC_SIZEALL
hCursN := DllCall("LoadCursor", "UInt", NULL, "Int", 32648, "UInt")		; IDC_NO
hCursH := DllCall("LoadCursor", "UInt", NULL, "Int", 32649, "UInt")		; IDC_HAND
IniRead, useSplash, %iniSet%, Settings, UseSplash, 1
if !A_IsCompiled
	{
	FileInstall, res\splash.bmp, %TempDir%\splash.bmp, 1
	hBSpl := DllCall("LoadImage"
				, "UInt", 0
				, "Str", TempDir "\splash.bmp"
				, "UInt", 0
				, "UInt", 0
				, "UInt", 0
				, "UInt", 0x10)	; LR_LOADFROMFILE
	}
else hBSpl := DllCall("LoadImage"
				, "UInt", DllCall("GetModuleHandle", "Str", A_ScriptFullPath)
				, "UInt", 102
				, "UInt", 0
				, "UInt", 0
				, "UInt", 0
				, "UInt", 0x2000)	; LR_CREATEDIBSECTION
if (useSplash or i="GiveMeSource")
	{
	Gui, 99:Font, s8 Bold, Tahoma
	Gui, 99:Margin, 0, 0
	Gui, 99:-Caption -Border +ToolWindow +AlwaysOnTop
	Gui, 99:Add, Picture, w230 h130 0x400000E AltSubmit BackgroundTrans hwndhSpl gmoveit,
	Gui, 99:Add, Text, x65 y42 w160 h28 cWhite BackgroundTrans Right, v%version%`nbuilt %release%
	GuiControlGet, p, 99:Pos, Static1
	Gui, 99:Add, Progress, x0 y70 w%pW% h6 -Theme cWhite BackgroundPurple vprog, 40
	Gui, 99:Add, Text, x110 y88 w115 h14 cAqua BackgroundTrans Hidden Right, Source copied !
	DllCall("SendMessage", "UInt", hSpl, "UInt", 0x172, "UInt", 0, "UInt", hBSpl)	; STM_SETIMAGE, IMAGE_BITMAP
	Gui, 99:Show,, SGCSplash
	}
;Include source with comments
StringCaseSense, On
IfEqual, i, GiveMeSource
	{
	StringReplace, version, version, ., _, All
	FileCreateDir, %A_ScriptDir%\source %version%
	FileCreateDir, %A_ScriptDir%\source %version%\lib
	FileCreateDir, %A_ScriptDir%\source %version%\mod
	FileCreateDir, %A_ScriptDir%\source %version%\res
	GuiControl, 99:, prog, 10
	FileInstall, lib\func_Balloon.ahk, %A_ScriptDir%\source %version%\lib\func_Balloon.ahk, 1
	FileInstall, lib\func_Brush.ahk, %A_ScriptDir%\source %version%\lib\func_Brush.ahk, 1
	FileInstall, lib\func_ChgColor.ahk, %A_ScriptDir%\source %version%\lib\func_ChgColor.ahk, 1
	FileInstall, lib\func_FileCreate.ahk, %A_ScriptDir%\source %version%\lib\func_FileCreate.ahk, 1
	FileInstall, lib\func_FontEx.ahk, %A_ScriptDir%\source %version%\lib\func_FontEx.ahk, 1
	FileInstall, lib\func_GetHwnd.ahk, %A_ScriptDir%\source %version%\lib\func_GetHwnd.ahk, 1
	FileInstall, lib\func_ImageList.ahk, %A_ScriptDir%\source %version%\lib\func_ImageList.ahk, 1
	FileInstall, lib\func_LogFile.ahk, %A_ScriptDir%\source %version%\lib\func_LogFile.ahk, 1
	FileInstall, lib\func_Menu.ahk, %A_ScriptDir%\source %version%\lib\func_Menu.ahk, 1
	FileInstall, lib\func_Rebar.ahk, %A_ScriptDir%\source %version%\lib\func_Rebar.ahk, 1
	FileInstall, lib\func_Toolbar.ahk, %A_ScriptDir%\source %version%\lib\func_Toolbar.ahk, 1
	FileInstall, lib\func_TrayIcon.ahk, %A_ScriptDir%\source %version%\lib\func_TrayIcon.ahk, 1
	FileInstall, lib\func_UrlDownloadToVar.ahk, %A_ScriptDir%\source %version%\lib\func_UrlDownloadToVar.ahk, 1
	GuiControl, 99:, prog, 30
	FileInstall, mod\mod_MenuEditor.ahk, %A_ScriptDir%\source %version%\mod\mod_MenuEditor.ahk, 1
	FileInstall, mod\mod_ScriptParser.ahk, %A_ScriptDir%\source %version%\mod\mod_ScriptParser.ahk, 1
	FileInstall, mod\mod_w9xstuff.ahk, %A_ScriptDir%\source %version%\mod\mod_w9xstuff.ahk, 1
	FileInstall, SmartGuiXP mod.ahk, %A_ScriptDir%\source %version%\SmartGuiXP mod.ahk, 1
	GuiControl, 99:, prog, 50
	FileInstall, res\SmartGuiXP_icons.dll, %A_ScriptDir%\source %version%\res\SmartGuiXP_icons.dll, 1
	GuiControl, 99:, prog, 60
	FileInstall, res\skin.bmp, %A_ScriptDir%\source %version%\res\skin.bmp, 1
	FileInstall, res\plchldr.bmp, %A_ScriptDir%\source %version%\res\plchldr.bmp, 1
	GuiControl, 99:, prog, 70
	FileInstall, res\grid.bmp, %A_ScriptDir%\source %version%\res\grid.bmp, 1
	GuiControl, 99:, prog, 80
	FileInstall, res\splash.bmp, %A_ScriptDir%\source %version%\res\splash.bmp, 1
	GuiControl, 99:, prog, 90
	FileInstall, res\icon.ico, %A_ScriptDir%\source %version%\res\icon.ico, 1
	GuiControl, 99:, prog, 100
	Sleep, 500
	GuiControl, 99:Hide, prog
	GuiControl, 99:Show, Static3
	Sleep, 4000
	IfExist, %TempDir%
		FileRemoveDir, %TempDir%
	ExitApp
	}
StringCaseSense, Off

MainWnd = GUI WorkSpace

;Only one instance allowed
WinGetClass, SelfClass, %MainWnd%
IfEqual, SelfClass, AutoHotkeyGUI
	ifNotExist, %Temp%\SGUIreload.$$$
		{
		if useSplash
			Gui, 99:Destroy
		MsgBox, 0x1010, SmartGUI Creator already running, Another instance of SmartGUI Creator found.`nOnly one instance is supported.
		ExitApp
		}
	else
		FileDelete, %Temp%\SGUIreload.$$$
;___________________________________________
; Variable Declarations

; Hook directives below should run only if !w9x, but AHK doesn't allow selective launch of directives
#NoTrayIcon
;#ErrorStdOut
#InstallKeybdHook
#InstallMouseHook
SetTitleMatchMode, Slow
SetControlDelay, 0
SetWinDelay, 0
SetFormat, float, 1.1
DetectHiddenWindows, On
CoordMode, Mouse, Relative
iconlocal = %A_ScriptDir%\res\icon.ico	; icon for uncompiled scripts
placeholder = %TempDir%\plchldr.bmp	; image palceholder for no-label/variable-label picture
iniWork=%TempDir%\SGUIControls.ini
debugdir=%appdir%\debug
debugout=%debugdir%\debugfile.txt
MenuWnd = %appname%
GeneratedWnd = New GUI Window
defGC=0xFFFFFF				; default GUI color
defCC=0xFFFFFF				; default controls color
MenuCol=0xFFFFFF			; menu color
MenuGenerated=0				; marker for Menu generation
MenuVis=0					; 'is menu visible' switch
SysGet, menuH, 15				; SM_CYMENU
SBsetStyleT := SBsetStyleS := "1"	; initialize statusbar styles
mPartW=9					; minimum part width for statusbar (-1)
inTab=0						; switch for controls' attachment to Tab control
isDefFont=0					; marker for Default font initialization
cFontIdx=0					; current font index
GuiW=475					; Initial workspace width
GuiH=400					; Initial workspace height
PosFields = XYWH
gridsizes := "2,3,4,5,10,15,20,30"
skinlist=3,4,5,6,7,8,10,11,12,98,99	; list of skinnable GUIs
CustomOptions := "0x10|0x200|0x8000|0x2000000|0x4000000|AltSubmit|BackgroundTrans|Border|Buttons|Center|Checked|Disabled
|Hidden|Horz|HScroll|Invert|Left|Limit|Lowercase|Multi|NoTicks|Number|Password|Range|ReadOnly|Right|Smooth|Theme|ToolTip
|Uppercase|Vertical|VScroll|WantReturn|Wrap"
ControlsKnown := "Button,Checkbox,ComboBox,DateTime,DropDownList,Edit,GroupBox,Hotkey,ListBox,ListView,Menu,MonthCal
,Progress,Picture,Radio,RichText,Slider,StatusBar,Tab,Text,TreeView,UpDown"
GuiOptPars := "Minimize,Maximize,Restore,NoActivate,NA,Hide" ;,AutoSize,Center,xCenter,yCenter"
ControlsList := "Button,ComboBox,Edit,ListBox,Menu,msctls_hotkey32,msctls_progress32,msctls_statusbar32,msctls_trackbar32
,msctls_UpDown32,RichEdit20W,Static,SysDateTimePick32,SysListView32,SysMonthCal32,SysTabControl32,SysTreeView32"
Loop, Parse, ControlsList, CSV
	%A_LoopField%Count=0
;___________________________________________
;MSstyles := "Dash,Dot,Dash dot,Dash dot dot,Null,Solid"
;VarSetCapacity(MSprop, 16, 0)	; LOGPEN struct
;___________________________________________
AhkHome := "http://www" Chr(46) "autohotkey" Chr(46) "com/"
SGUIHome := "http://www" Chr(46) "autohotkey" Chr(46) "com/docs/SmartGUI/"
ModHome := "http://my" Chr(46) "cloudme" Chr(46) "com/#drugwash/mytools/smartgui"Chr(46) "html"
RMail := "mr" Chr(46) "rajat" Chr(64) "gmail" Chr(46) "com"
DMail := "drugwash" Chr(64) "aol" Chr(46) "com"
RMail1 := "meet_rajat" Chr(64) "gawab" Chr(46) "com"
DMail1 := "drugwash" Chr(64) "yahoo" Chr(46) "com"
DwnUrl := "http://my" Chr(46) "cloudme" Chr(46) "com/#drugwash/mytools/SmartGUICreatorMod/"
RelUrl := ModHome
; First-run notifications
;Win9x notification / mod disclaimer
if w9x
	IfNotExist, %iniSet%
		{
		if useSplash
			Gui, 99:Hide
		MsgBox, 0x3040, %appname%         • • • Win9x Disclaimer • • •, Apparently you are currently running a version of Windows 9x (95/98/98SE/ME).`nCertain features might not work correctly (or at all) under such operating system.`nSince this is a mod`, please do not nag the original author (Rajat) about this.`n`t`t`tThank you!`n`t`t`t`t`t`t- Drugwash -
		}
if !A_IsCompiled
	{
	FileInstall, res\skin.bmp, %TempDir%\skin.bmp, 1
	FileInstall, res\grid.bmp, %TempDir%\grid.bmp, 1
	}
FileInstall, res\plchldr.bmp, %TempDir%\plchldr.bmp, 1
IniRead, cSkin, %iniSet%, Settings, SkinFile, 10
IniRead, iGrid, %iniSet%, Settings, GridFile, 5
skin := A_IsCompiled ? A_ScriptFullPath : TempDir "\skin.bmp"
grid := A_IsCompiled ? A_ScriptFullPath : TempDir "\grid.bmp"
skinsz=2							; individual skin image width - try making it 1px, see what comes up in Win7! :(
gridsz=60						; individual grid image width
hSkin := GetBmp(cSkin, skinsz, skin, 100, 0)	; handle to skin bitmap (returns ImageList handle in 'skin')
hGbmp := GetBmp(iGrid, gridsz, grid, 101, 0)	; handle to grid bitmap (returns ImageList handle in 'grid')
if debug
	LogFile("Skin" cSkin " handle: " hSkin " and skin ImageList handle: " skin, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
	, "Create skin ImageList and load current skin (hSkin skin)", debugout)
if debug
	LogFile("Grid" iGrid " handle: " hGbmp " and grid ImageList handle: " grid, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
	, "Create grid ImageList and load current grid (hGbmp skin)", debugout)
skincount := ILC_Count(skin)			; number of skin images
gridcount := ILC_Count(grid)			; number of grid images
skincolor := GetPixelColor(hSkin, 0, 1)
menucolor := SwColor(skincolor)		; menu background color
tc2 := skincolor					; balloon tip background color
tc1 := tc2 & 0x007F7F7F			; balloon tip font color
;ask to read manual
IfNotExist, %iniSet%
	{
	if useSplash
		Gui, 99:Hide
	Msgbox, 0x3024, WELCOME,  `t`t`t`tWelcome to SmartGUI XP Creator !`n`nIf you are using it for the first time, then it's recommended that you read the help manual, especially the 'Guidelines' section.`n`n`t`t`t`tWould you like to open it now?
	IfMsgbox, Yes
		DelayShowHelp=2
	else DelayShowHelp=1
	}
if useSplash
	{
	Gui, 99:Show
	GuiControl, 99:, prog, 20
	}
icons=%TempDir%\icons.dll
FileInstall, res\SmartGuiXP_icons.dll, %icons%, 1
if useSplash
	GuiControl, 99:, prog, 30
FileDelete, %iniWork%

if w9x
	gosub w9xstuff
else
	{
	OnMessage(0x201, "click")		; WM_LBUTTONDOWN
	OnMessage(0x202, "clickup")		; WM_LBUTTONUP
	}
OnMessage(0x200, "move")			; WM_MOUSEMOVE
OnMessage(0x2A2, "CloseBT")		; WM_NCMOUSELEAVE
OnMessage(0x2A3, "CloseBT")		; WM_MOUSELEAVE
OnMessage(0x4E, "notif")			; WM_NOTIFY
OnMessage(0xA4, "hideit")			; WM_NCRBUTTONDOWN
OnMessage(0x111, "comm")			; WM_COMMAND
OnMessage(0x112, "nocls")			; WM_SYSCOMMAND
GuiControl, 99:, prog, 40

; had to add it here for the 'Reload' menu item to work
IniRead, debug, %iniSet%, Settings, Debug mode
debug := (debug = "ERROR") ? "0" : debug

if debug
	IfNotExist, %debugdir%
		FileCreateDir, %debugdir%

; Build Tray menu
Menu, Tray, NoStandard
Menu, Tray, UseErrorLevel
Menu, Tray, Add, Hide window, showWnd
Menu, Tray, Default, Hide window
Menu, Tray, Add, &About, About
if debug
	Menu, Tray, Add, &Reload, Reload	; added for debugging sessions
Menu, Tray, Add
Menu, Tray, Add, E&xit, GuiClose
if !A_IsCompiled
	Menu, Tray, Icon, %iconlocal%
Menu, Tray, NoIcon
Menu, Tray, Color, %menucolor%
if useSplash
	GuiControl, 99:, prog, 50

; Generate Main Menu
;___________________________________________
Menu, MultiselTh, Add, 1 px, MSthick
Menu, MultiselTh, Add, 2 px, MSthick
Menu, MultiselTh, Add, 3 px, MSthick
Menu, MultiselTh, Add, 4 px, MSthick
Menu, MultiselTh, Add, 5 px, MSthick

Menu, MultiselSt, Add, Solid, MSstyle
Menu, MultiselSt, Add, Dash, MSstyle
Menu, MultiselSt, Add, Dot, MSstyle
Menu, MultiselSt, Add, Dash dot, MSstyle
Menu, MultiselSt, Add, Dash dot dot, MSstyle

Menu, Multisel, Add, Style, :MultiselSt
Menu, Multisel, Add, Thick, :MultiselTh
Menu, Multisel, Add, Color, MScolor
Menu, Multisel, Color, %menucolor%
if useSplash
	GuiControl, 99:, prog, 55
;___________________________________________
Menu, HelpMenu, Add, Help Manual, OpenManual
Menu, HelpMenu, Default, Help Manual
Menu, HelpMenu, Add, Keyboard Help, ShowHelp
Menu, HelpMenu, Add
Menu, HelpMenu, Add, About, About
;___________________________________________
Menu, Preferences, Add, Change grid, ChGrid
Menu, Preferences, Add, Change skin, ChSkin
Menu, Preferences, Add, Change snapTo, ChSnapTo
Menu, Preferences, Add
;Menu, Preferences, Add, Multi-selection, :Multisel
Menu, Preferences, Add, Toolbar tips, showBT
Menu, Preferences, Add, Tray balloon, showTBT
Menu, Preferences, Add, Splash screen, showSplash
if !w9x
	Menu, Preferences, Add, Portable setup, setPortable
;___________________________________________
Menu, Options, Add, Show Grid, Grid
Menu, Options, Add, Show GUI Helper, Helper
Menu, Options, Check, Show GUI Helper
Menu, Options, Add, Ask Control Label, CtrlText
Menu, Options, Add, Ask GUI Properties, AskGUIProp
Menu, Options, Add, MicroEditing, MicroEditing
Menu, Options, Add, Shift + Move Group, ShiftMove
Menu, Options, Add
Menu, Options, Add, Debug mode, tdebug
if useSplash
	GuiControl, 99:, prog, 60
;___________________________________________
if IsLabel("EditGUI")
	Menu, FileMenu, Add, &Open Script, EditGUI
if IsLabel("ClipGUI")
	Menu, FileMenu, Add, &Load Script from clipboard, ClipGUI ;ruespe
Menu, FileMenu, Add, &Test Script`tF9, TestGUI
Menu, FileMenu, Add, &Save Script, SaveGUI2
Menu, FileMenu, Add, Save Script &As, SaveGUI
Menu, FileMenu, Add
Menu, FileMenu, Add, GUI St&ealer, Stealer
Menu, FileMenu, Add, Set GUI Count in Script, SetGUICount
Menu, FileMenu, Add
Menu, FileMenu, Add, &Reload, Reload
Menu, FileMenu, Add, E&xit, GuiClose
if useSplash
	GuiControl, 99:, prog, 65
;___________________________________________
Menu, JustifyMenu, Add, Left, Justify
Menu, JustifyMenu, Add, Center, Justify
Menu, JustifyMenu, Add, Right, Justify

Menu, InTabMenu, Add, Attach to Tab..., TabAdd
Menu, InTabMenu, Add, Move to Tab..., TabMove
Menu, InTabMenu, Add, Remove from Tab, TabRem

Menu, ControlFont, Add, Set/Change, CtrlFontSet
Menu, ControlFont, Add, GUI default, CtrlFontGui
Menu, ControlFont, Add, System default, CtrlFontSys
;___________________________________________
Menu, ControlMenu, Add, Justify Text, :JustifyMenu
;Menu, ControlMenu, Add, InTab Options, :InTabMenu
Menu, ControlMenu, Add
Menu, ControlMenu, Add, Change Font, :ControlFont
Menu, ControlMenu, Add, Change Label, ChangeLabel
Menu, ControlMenu, Add, Custom Option, CustomOption
Menu, ControlMenu, Add
Menu, ControlMenu, Add, Duplicate Control, Duplicate
Menu, ControlMenu, Add, Delete Control, Delete
Menu, ControlMenu, Add
Menu, ControlMenu, Add, Move Control, Modify
Menu, ControlMenu, Add, Set Position, SetPos
Menu, ControlMenu, Add, Center Horizontally, CenterH
Menu, ControlMenu, Add, Center Vertically, CenterV
Menu, ControlMenu, Color, %menucolor%
;___________________________________________
Menu, SBstyle, Add, Tooltips, SBsetStyleT
Menu, SBstyle, Check, Tooltips
Menu, SBstyle, Add, Sizing grip, SBsetStyleS
Menu, SBstyle, Check, Sizing grip
Menu, SBstyle, Color, %menucolor%

Menu, SBicon, Add, Set/Change, SBsetIcon
Menu, SBicon, Add, Remove, SBremIcon
Menu, SBicon, Add, Remove all, SBremAllIcon
Menu, SBicon, Color, %menucolor%

Menu, SBprogMenu, Add, Attach themed, SBsetProgress
Menu, SBprogMenu, Add, Attach smooth, SBsetSmProgress
Menu, SBprogMenu, Add
Menu, SBprogMenu, Add, Remove, SBremProgress
Menu, SBprogMenu, Add, Remove all, SBremAllProgress
Menu, SBprogMenu, Color, %menucolor%

Menu, SBbkgMenu, Add, Set/Change, SBsetBkg
Menu, SBbkgMenu, Add, GUI default, SBsetDefBkg
Menu, SBbkgMenu, Add, System default, SBresetBkg
Menu, SBbkgMenu, Disable, GUI default
Menu, SBbkgMenu, Disable, System default
Menu, SBbkgMenu, Color, %menucolor%

Menu, SBfontMenu, Add, Set/Change font, SBsetFont
Menu, SBfontMenu, Add, Set to current, SBsetCurFont
Menu, SBfontMenu, Add, Set to GUI default, SBsetDefFont
Menu, SBfontMenu, Add, Set to system default, SBresetFont
Menu, SBfontMenu, Disable, Set to current
Menu, SBfontMenu, Disable, Set to GUI default
Menu, SBfontMenu, Disable, Set to system default
Menu, SBfontMenu, Color, %menucolor%
;___________________________________________
Menu, SBmenu, Add, Set parts, SBsetParts
Menu, SBmenu, Add, Set gLabel, SBsetLabel
Menu, SBmenu, Add, Style, :SBstyle
Menu, SBmenu, Add
Menu, SBmenu, Add, Icons, :SBicon
Menu, SBmenu, Add, Progressbars, :SBprogMenu
Menu, SBmenu, Add
Menu, SBmenu, Add, Background color, :SBbkgMenu
Menu, SBmenu, Add, Font, :SBfontMenu
Menu, SBmenu, Add
Menu, SBmenu, Add, Remove status bar, DelSB
Menu, SBmenu, Color, %menucolor%
;___________________________________________
Menu, MenuOpt, Add, Edit, EditMenu
Menu, MenuOpt, Add, Remove, DelMenu
Menu, MenuOpt, Color, %menucolor%
;___________________________________________
Menu, ControlMenu2, Add, GUI options, SetGUIoptions
Menu, ControlMenu2, Add
Menu, ControlMenu2, Add, Main menu, :MenuOpt
Menu, ControlMenu2, Disable, Main menu
Menu, ControlMenu2, Add, Status bar, :SBmenu
Menu, ControlMenu2, Disable, Status bar
Menu, ControlMenu2, Color, %menucolor%
;___________________________________________
Menu, TrayMenu, Add, &File, :FileMenu
Menu, TrayMenu, Add, &Options, :Options
Menu, TrayMenu, Add, &Preferences, :Preferences
Menu, TrayMenu, Add, &Help, :HelpMenu
Menu, TrayMenu, Color, %menucolor%
;___________________________________________
Menu, ToolBarMenu, Add, &File, :FileMenu
Menu, ToolBarMenu, Add, &Options, :Options
Menu, ToolBarMenu, Add, &Preferences, :Preferences
Menu, ToolBarMenu, Add, &Help, :HelpMenu
Menu, ToolBarMenu, Color, %menucolor%
;___________________________________________
Menu, hv, Add, Horizontal, addh
Menu, hv, Add, Vertical, addv
Menu, hv, Color, %menucolor%

Menu, uhv, Add, Horizontal, addh
Menu, uhv, Add, Vertical, addv
Menu, uhv, Add, Vertical free, addfv
Menu, uhv, Color, %menucolor%

Menu, sm, Add, Single line, adds
Menu, sm, Add, Multiline, addm
Menu, sm, Color, %menucolor%

Menu, picm, Add, Empty label, nullpic
Menu, picm, Add, Variable, varpic
Menu, picm, Add, Full path, fullpic
Menu, picm, Add, Relative path, relpic
Menu, picm, Color, %menucolor%

Menu, fnt, Add, Select new font, SelectFont
Menu, fnt, Add, Set GUI default font, SetDefaultFont
Menu, fnt, Add
Menu, fnt, Add, Reset to GUI default, ResetDefFont
Menu, fnt, Add, Reset to system default, ResetFont
Menu, fnt, Disable, Reset to GUI default
Menu, fnt, Disable, Reset to system default
Menu, fnt, Color, %menucolor%
if useSplash
	GuiControl, 99:, prog, 70
;___________________________________________
; Reading/Writing settings
IniRead, LoadDir, %iniSet%, Folders, LoadDir
IfEqual, LoadDir, ERROR, SetEnv, LoadDir,

IniRead, SaveDir, %iniSet%, Folders, SaveDir
IfEqual, SaveDir, ERROR, SetEnv, SaveDir,

IniRead, stgType, %iniSet%, Settings, Snap to grid Type
stgType := (stgType = "ERROR") ? "3" : stgType

IniRead, stgX, %iniSet%, Settings, Snap to grid H
stgX := (stgX = "ERROR") ? "10" : stgX

IniRead, stgY, %iniSet%, Settings, Snap to grid V
stgY := (stgY = "ERROR") ? "10" : stgY

IniRead, HG, %iniSet%, Settings, Hide grid
HG := (HG = "ERROR") ? "0" : HG

IniRead, AL, %iniSet%, Settings, AskControlLabel
AL := (AL = "ERROR") ? "0" : AL

IniRead, AG, %iniSet%, Settings, AskGUIProp
AG := (AG = "ERROR") ? "0" : AG

IniRead, gpos, %iniSet%, Settings, GuiPosType
gpos := (gpos = "ERROR") ? "2" : gpos

IniRead, ME, %iniSet%, Settings, MicroEditing
ME := (ME = "ERROR") ? "0" : ME

IniRead, SM, %iniSet%, Settings, ShiftMove
SM := (SM = "ERROR") ? "0" : SM
/*
IniRead, lastmms, %iniSet%, Settings, MultiselectStyle
lastmms := (lastmms = "ERROR") ? "Solid" : lastmms

IniRead, lastmmt, %iniSet%, Settings, MultiselectThick
lastmmt := (lastmmt = "ERROR") ? "2 px" : lastmmt

IniRead, pencolor, %iniSet%, Settings, MultiselectColor
pencolor := (pencolor = "ERROR") ? "0x660000FF" : pencolor
*/
IniRead, showBT, %iniSet%, Settings, ShowToolbarTips
showBT := (showBT = "ERROR") ? "1" : showBT

IniRead, showTBT, %iniSet%, Settings, ShowTrayTip
showTBT := (showTBT = "ERROR") ? "1" : showTBT
;___________________________________________
if useSplash
	GuiControl, 99:, prog, 75
if w9x
	{
	Hotkey9x("LD", "LeftButton")
	Hotkey9x("L2", "LeftDbl")
	Hotkey9x("RD", "RightButton")
	Hotkey, F1, HKHelp, UseErrorLevel
	Hotkey, F9, HKSave, UseErrorLevel
	Hotkey, ^Z, HKUndo, UseErrorLevel
	}
else
	{
	Hotkey, IfWinActive, GUI WorkSpace
	Hotkey, *~LButton, LeftButton, UseErrorLevel
	Hotkey, RButton, RightButton, UseErrorLevel
	Hotkey, ~F1, HKHelp, UseErrorLevel
	Hotkey, ~F9, HKSave, UseErrorLevel
	Hotkey, ~^Z, HKUndo, UseErrorLevel
	}

; Create GUI97 for Skin/Grid selection
Gui, 97:Font, s8 Bold cBlack, Tahoma
Gui, 97:Margin, 5, 5
Gui, 97:Color, White, White
Gui, 97:-Caption +ToolWindow +Border +AlwaysOnTop
Gui, 97:Add, Text, x4 y4 w62 h62 0x7 Border BackgroundTrans,
Gui, 97:Add, Text, x4 y4 w62 h62 0x8 BackgroundTrans,
Loop, Parse, gridsizes, CSV
	Gui, 97:Add, Text, % "x" 5+65*(A_Index-1) " y" 67+65*((gridcount-1)//8) " w60 h16 0x200 Center BackgroundTrans gmoveit vgs" A_Index, %A_LoopField% px
Loop, %skincount%
	Gui, 97:Add, Picture, % "x" 5+65*(A_Index-1-8*((A_Index-1)//8)) " y" 5+65*((A_Index-1)//8) " w60 h60 0xE gselimg vimage" A_Index " hwndhImg" A_Index,
Gui, 97:Show, AutoSize Hide, Select picture
WinGet, hGui97, ID, Select picture
hGuis .= hGui97
if debug
	LogFile("GUI97 handle: " hGui97, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI97 handle (hGui97)", debugout)
if useSplash
	GuiControl, 99:, prog, 80

; Generate ToolBar
Gui, 9:+Resize +OwnDialogs +MinSize410x400 +0x02000000
Gui, 9:Color, %menucolor%, %menucolor%
Gui, 9:Menu, ToolBarMenu
TBCtrls := "1|Button,2|Checkbox,14|Radio,6|Edit|0x18,17|Text,7|GroupBox,12|Picture|0x18,5|DropDownList,3|ComboBox,9|ListBox,10|ListView
,4|DateTime,11|MonthCal,13|Progress|0x18,15|Slider|0x18,8|Hotkey,16|Tab,18|UpDown|0x18,20|TreeView,22|RichEdit||0,21|Menu||0
,26|StatusBar,19|Font|0x18"
WinHeight := A_ScreenHeight - 192
WinWidth := A_ScreenWidth - 100
;darker background for non-toolbar area
Gui, 9:Add, Text, x0 y41 w%WinWidth% h%WinHeight% +0x4 +Border hwndwpID,
Gui, 9:Add, Progress, x0 y0 w%WinWidth% h8 -Theme cRed Background%tc2% +E0x8 Hidden hwndhSLP vSLP, 0
DllCall("SetParent", "UInt", hSLP, "UInt", wpID)
if useSplash
	GuiControl, 99:, prog, 90
WinHeight += 42
Gui, 9:Show, w%WinWidth% h%WinHeight% Hide, %MenuWnd%
WinGet, MenuWndID, ID, %MenuWnd%
if !hRB99 := RB_Create("9")
	MsgBox, 0x43010, Error, Cannot create Rebar!
if debug
	LogFile("Rebar handle: " hRB99, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create rebar control (hRB99)", debugout)
s1=1
hTB99IL := IL_Create(26, 1, 1)
if debug
	LogFile("Toolbar ImageList handle: " hTB99IL, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
	, "Create toolbar imagelist (hTB99IL)", debugout)
Loop, 26
	IL_Add(hTB99IL, icons, A_Index)
if !hTB99 := TB_Create("9", "0|0|0|0", "0x8A1D", "0x89")
	MsgBox, 0x43010, Error, Cannot create Toolbar!
if debug
	LogFile("Toolbar handle: " hTB99, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create toolbar control (hTB99)", debugout)
ControlGetPos, x, y, w, h, TrayNotifyWnd1, ahk_class Shell_TrayWnd
ControlGet, TID, Hwnd,, TrayNotifyWnd1, ahk_class Shell_TrayWnd
TB_SetIL(hTB99, "I0|" hTB99IL, 5)
Loop, Parse, TBCtrls, CSV
	{
	i3=0x10
	i4=0x4
	StringSplit, i, A_LoopField, |
	i4 := (!IsFunc("Init" i2) && i4="0") ? 0 : 0x4
	TB_AddBtn(hTB99, "", A_Index, i4, i3, i1-1, 0)
	}
TB_Size(hTB99)
if !b1 := RB_Add(hRB99, hTB99, "Toolbar99", "", 1, TB_Get(hTB99, "sW"), bh1 := TB_Get(hTB99, "bH"), 0x5C1)
	MsgBox, 0x43010, Error, Cannot add Toolbar to Rebar!
TB_Set(hTB99, "s0x9A1D b" 0x24|0x24<<16 " d" 0x7|0x6<<16)
bh1 := TB_Get(hTB99, "bH")
RB_Set(hRB99, b1, "ic" bh1)
Loop, Parse, TBCtrls, CSV
	{
	StringSplit, i, A_LoopField, |
	TB_BtnSet(hTB99, A_Index, "t" i2)
	}
Gui, 9:Maximize
Sleep, 50
ControlGetPos,,, w, h,, ahk_id %hRB99%
hBack := ResizeBmp(hSkin, w, h)
if debug
	LogFile("Skin handle: " hBack, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
	, "Get Rebar background image handle (hBack)", debugout)
RB_Set(hRB99, b1, " bk" hBack)
Gui, 9:Show
if hMainMenu := MenuHmenu(MenuWndID)
	if hSM1 := MenuHsub(hMainMenu, 3)
		if hSM2 := MenuHsub(hSM1, 5)
			{
			hSMs := MenuHsub(hSM2, 1)
			hSMt := MenuHsub(hSM2, 2)
			MenuBitmap(hSM2, 3, pencolor, 3)
			}
if debug
	LogFile("Menu handles: " hMainMenu "`t" hSM1 "`t" hSM2, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
	, "Get menu handles (hMainMenu hSM1 hSM2)", debugout)
hBrMenu := MenuSkin(hMainMenu, hBack, 0)
if debug
	LogFile("Menu brush handle: " hBrMenu, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
	, "Create menu brush (hBrMenu)", debugout)
if useSplash
	GuiControl, 99:, prog, 95

Gui, 1:+LastFound +Resize -MaximizeBox -SysMenu +MinSize100x20 +0x40000000 +E0x10 +AlwaysOnTop
;Gui, 1:Color, White, White	; don't use, it'll break the grid display !
MainWndID := WinExist()
if !HG
	DBB := Brush("3", hGbmp)
if debug
	LogFile("Grid brush handle: " DBB, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create grid brush (DBB)", debugout)
WPrc1 := RegisterCallback("WPrc", "", 4, "")
WPrc0 := DllCall("SetWindowLong", "UInt", MainWndID, "Int", -4, "Int", WPrc1, "UInt")
Gui, 1:Show, w%GuiW% h%GuiH% x144 y2, %MainWnd%
; Must give up this solution when I find a better way (if any) to allow free workspace positioning across the display
DllCall("SetParent", "UInt", MainWndID, "UInt", wpID)
GroupAdd, needHelp, ahk_id %MainWndID%
;GroupAdd, needHelp, ahk_id %MenuWndID%
;WinDiffW contains 1 border, WinDiffH contains titlebar + bottom border
WinGetPos,,, WinW, WinH, ahk_id %MainWndID%
WinDiffW := (WinW-GuiW)//2
WinDiffH := WinH-GuiH

IfEqual, HG, 0, Menu, Options, Check, Show Grid
IfEqual, AL, 1, Menu, Options, Check, Ask Control Label
IfEqual, AG, 1, Menu, Options, Check, Ask GUI Properties
IfEqual, AN, 1, Menu, Options, Check, Ask GUI Name
IfEqual, ME, 1, Menu, Options, Check, MicroEditing
IfEqual, SM, 1, Menu, Options, Check, Shift + Move Group
IfEqual, debug, 1, Menu, Options, Check, Debug mode
IfEqual, showBT, 1, Menu, Preferences, Check, Toolbar tips
IfEqual, showTBT, 1, Menu, Preferences, Check, Tray balloon
IfEqual, useSplash, 1, Menu, Preferences, Check, Splash screen
IfEqual, port, 1, Menu, Preferences, Check, Portable setup
/*
Loop, Parse, MSstyles, CSV
	if (A_LoopField=lastmms)
		{
		pentype := A_Index
		multiS := (pentype="6" ? 1 : pentype)
		MenuCheckEx(hSMs, multiS, "1")
		}
NumPut(pentype, MSprop, 0, "UInt")
StringLeft, pensize, lastmmt, 1
MenuCheckEx(hSMt, pensize, "1")
NumPut(pentype!=6 ? 1 : pensize, MSprop, 4, "UInt")
NumPut(pencolor, MSprop, 12, "UInt")	; ABGR
Menu, Multisel, % (pentype!=6 ? "Disable" : "Enable"), Thick
*/
TrayIcon("1", MenuWndID, "159|" iconlocal, 0x2222, "LSMTrayMenu|LDLshowWnd|RSMTray")
hTBT := TrayIconTip("1", MenuWndID, type " version`, released " release, "1$" appname " " version, "C$" tc1 "$" tc2)
if debug
	LogFile("Tray balloon handle: " hTBT, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create tray balloon", debugout)
showBT(1)
if !showTBT
		TrackBT(hTBT, 0)	; disable tray balloon if disabled in Options
if debug
	{
	Gui, 55:+AlwaysOnTop
	Loop, 6
		Gui, 55:Add, Text, % "w350 h14 x5 y" 2+15*(A_Index-1)
	Gui, 55:Show
	}
if useSplash
	GuiControl, 99:, prog, 100
HelperStatus = 1
SetTimer, GuiHelper, 500
if useSplash
	{
	Sleep, 3500
	Gui, 99:Destroy
	}
;dropped file on SmartGUI icon
IfExist, %1%
	{
	GUIScript = %1%
	i := IsLabel("EditGUI") ? "EditGUI" : ""
	Goto %i%
	MsgBox, 0x43010, %appname% error, ScriptParser module not found.`nCannot edit external script.
	}

WinActivate, ahk_id %MenuWndID%
if DelayShowHelp
	ShowHelp(DelayShowHelp-1)
Return
;===========================================
;	WORKSPACE RESIZE
;===========================================
9GuiSize:
	if !hRB99
		return
	if !margins && A_GuiWidth && A_GuiHeight && WinExist("ahk_id" MenuWndID)
		{
		WinGetPos,,, ww, wh, ahk_id %MenuWndID%
		wmh := ww-A_GuiWidth
		wmv := wh-A_GuiHeight
		margins=1
		}
	RB_Show(hRB99, b1, s1)
	br1 := TB_Get(hTB99, "bR")
	RB_Size(hRB99, A_GuiWidth, (bh1+1)*s1*br1-1+1)
	y := RB_Get(hRB99, "h")
	WinGetPos,,, ww, wh, ahk_id %MenuWndID%
	GuiControl, 9:Move, Static1, % "y" y+1 " w" ww-wmh " h" wh-wmv-y-1
	GuiControl, 9:Move, msctls_progress321, % "x0 y0 w" ww-wmh
	if A_EventInfo
		return
	WinGetPos, wx, wy, ww, wh, % "ahk_id " DllCall("GetAncestor", "UInt", MainWndID, "UInt", 1)	; GA_PARENT
	WinGetPos, wsx, wsy, wsw, wsh, ahk_id %MainWndID%
	wsx := (wsx > wx) ? (wsx < wx+ww-wsw ? wsx : wx+ww-wsw) : wx+1
	wsy := (wsy > wy) ? (wsy < wy+wh-wsh ? wsy : wy+wh-wsh) : wy+1
	WinMove, ahk_id %MainWndID%,, wsx-wx-1, wsy-wy-1, wsw, wsh
return
;===========================================
;	DEBUG HOTKEY (Ctrl+Shift+D)
;===========================================
^+D::
	Run, open %iniWork%,,UseErrorLevel
	ListVars
	;ListHotkeys
	;ListLines
Return
;===========================================
;	HELP HOTKEY
;===========================================
;~F1::
HKHelp:
	IfWinActive, ahk_id %MenuWndID%
		goto OpenManual
	IfWinNotActive, ahk_group needHelp
		{
		if w9x
			Hotkey, F1, Off
		SendInput {F1}
		if w9x
			Hotkey, F1, On
		Return
		}
ShowHelp:
	ShowHelp()
Return

OpenManual:
	ShowHelp("1")
Return
;===========================================
;	TOOLBAR SUBMENUS (vertical/horizontal single/multi-line control styles)
;===========================================
addh:
	COvert := (TBCtrl="UpDown" ? "1" : "")
	goto PreCreateCtrl
addv:
	COvert := (TBCtrl="UpDown" ? "" : "1")
	goto PreCreateCtrl
addfv:
	COvert := (TBCtrl="UpDown" ? "2" : "")
	goto PreCreateCtrl
adds:
	COvert=
	goto PreCreateCtrl
addm:
	COvert=1
	goto PreCreateCtrl
nullpic:
	CtrlType=0
	goto PreCreateCtrl
varpic:
	CtrlType=1
	goto PreCreateCtrl
fullpic:
	CtrlType=2
	goto PreCreateCtrl
relpic:
	CtrlType=3
	goto PreCreateCtrl
return
;===========================================
;	MULTISELECT SUBMENUS
;===========================================
MSstyle:
	MenuCheckEx(hSMs, multiS)
	lastmms := A_ThisMenuItem
	multiS := A_ThisMenuItemPos
	pentype := A_ThisMenuItemPos=1 ? 6 : A_ThisMenuItemPos-1
	NumPut(pentype, MSprop, 0, "UInt")
	NumPut(pentype!=6 ? 1 : pensize, MSprop, 4, "UInt")
	MenuCheckEx(hSMs, multiS, "1")
	Menu, Multisel, % (pentype!=6 ? "Disable" : "Enable"), Thick
Return

MSthick:
	MenuCheckEx(hSMt, pensize)
	lastmmt := A_ThisMenuItem
	pensize := A_ThisMenuItemPos
	NumPut(pensize, MSprop, 4, "UInt")
	MenuCheckEx(hSMt, pensize, "1")
Return

MScolor:
	i := ChgColor(pencolor, "BB")
	if ErrorLevel
		return
	NumPut(pencolor := i, MSprop, 12, "UInt")	; ABGR
	MenuBitmap(hSM2, 3, pencolor, 1)
Return
;===========================================
;	BALLOON TIPS, SPLASH SCREEN, PORTABILITY (toggles)
;===========================================
showBT:
	showBT := !showBT
	Menu, Preferences, ToggleCheck, Toolbar tips
	TrackBT(hBT, showBT)	; toolbar balloon tips disabled/enabled
Return

showTBT:
	showTBT := !showTBT
	Menu, Preferences, ToggleCheck, Tray balloon
	TrackBT(hTBT, showTBT)	; tray balloon tip disabled/enabled
	if showTBT
		hTBT := TrayIconTip("1", MenuWndID)
Return

showSplash:
	useSplash := !useSplash
	Menu, Preferences, ToggleCheck, Splash screen
Return

setPortable:
	port := !port
	Menu, Preferences, ToggleCheck, Portable setup
	i := appdir
	appdir := port ? A_ScriptDir : A_AppData "\" appname
	FileMove, %i%\SmartGUI.ini, %appdir%\SmartGUI.ini
	IfExist, %debugdir%
		{
		FileCreateDir, %appdir%\debug
		FileMove, %debugdir%\*.*, %appdir%\debug
		FileRemoveDir, %debugdir%, 1
		}
	debugdir=%appdir%\debug
	debugout=%debugdir%\debugfile.txt
	if debug
		IfNotExist, %debugdir%
			FileCreateDir, %debugdir%
	i=
return
;===========================================
; 	STATUSBAR
;===========================================
SBclick:
	part := A_EventInfo > 256 ? 1 : A_EventInfo
	MouseGetPos, x
	x -= WinDiffW
	altSB := GetKeyState("Alt", "P")
	if A_GuiEvent=RightClick
		Menu, SBmenu, Show
	else if A_GuiEvent=DoubleClick
		goto SBsetParts
return

SBsetParts:
; Double-click to Add, Alt+Double-click to Remove part
	Loop, 256
		i%A_Index%=
	if !SBparts
		{
		if altSB
			return
		SBparts := x
		SB_SetParts(x)
		}
	else
		{
		i=0
		j:=k:=x1:=x2:=""
		if altSB
			{
			StringSplit, i, SBparts, `,, %A_Space%
			Loop, %i0%
				{
				if !i%A_Index%
					Continue
				i += i%A_Index%
				j := A_Index+1
				if x between % i-2 and % i+2
					{
					if i%j%
						{
						i%A_Index% += i%j%
						i%j%=
						}
					else i%A_Index%=
					}
				if i%A_Index%
					k .= i%A_Index% ", "
				}
			}
		else Loop, Parse, SBparts, `,, %A_Space%
			{
			i += A_LoopField
			if (j OR x > i)
				{
				k .= A_LoopField ", "
				Continue
				}
			x1 := x-i+A_LoopField
			x2 := A_LoopField-x1
			if (x1 > mPartW && x2 > mPartW)
				k .= x1 ", " x2 ", "
			else
				k .= A_LoopField ", "
			j=1
			}
		if (!j && x-i > mPartW)
			k .= x-i ", "
		StringTrimRight, SBparts, k, 2
		StringSplit, i, SBparts, `,, %A_Space%
		SB_SetParts(i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25
		, i26, i27, i28, i29, i30, i31, i32, i33, i34, i35, i36, i37, i38, i39, i40, i41, i42, i43, i44, i45, i46, i47, i48, i49, i50)
		}
	IniWrite, %SBparts%, %iniWork%, StatusBar, Parts
return

SBsetStyleT:
	SBsetStyleT := !SBsetStyleT
	Menu, SBstyle, ToggleCheck, Tooltips
	j := SBsetStyleT ? "+0x800" : "-0x800"
	GuiControl, 1:%j%, msctls_statusbar321
	WinSet, Redraw,, ahk_id %MainWndID%
	IniRead, i, %iniWork%, StatusBar, Options
	Loop, Parse, i, %A_Space%
		IfInString, A_LoopField, 0x800
			StringReplace, CtrlOptions, i, A_LoopField,
	CtrlOptions=%CtrlOptions%
	CtrlOptions .= A_Space j
	IniWrite, %CtrlOptions%, %iniWork%, StatusBar, Options
return

SBsetStyleS:
	SBsetStyleS := !SBsetStyleS
	Menu, SBstyle, ToggleCheck, Sizing grip
	j := SBsetStyleS ? "+0x100" : "-0x100"
	GuiControl, 1:%j%, msctls_statusbar321
	WinSet, Redraw,, ahk_id %MainWndID%
	IniRead, i, %iniWork%, StatusBar, Options
	Loop, Parse, i, %A_Space%
		IfInString, A_LoopField, 0x100
			StringReplace, CtrlOptions, i, A_LoopField,
	CtrlOptions=%CtrlOptions%
	CtrlOptions .= A_Space j
	IniWrite, %CtrlOptions%, %iniWork%, StatusBar, Options
return

SBsetCurFont:
	GuiControl, 1:Font, msctls_statusbar321
	WinSet, Redraw,, ahk_id %MainWndID%
	IniRead, i, %iniWork%, Font, 0
	Menu, SBfontMenu, Disable, Set to current
	if i
		Menu, SBfontMenu, Enable, Set to GUI default
	Menu, SBfontMenu, Enable, Set to system default
	IniWrite, %cFontIdx%, %iniWork%, StatusBar, Font
return

SBsetDefFont:
	IniRead, i, %iniWork%, Font, 0
	if i=ERROR
		return
	StringSplit, i, i, |
	j := i7
	k := (i1 ? "s" i1 : "") (i2 ? " c" i2 : "") (i3 ? " w" i3 : "") " " i4 " " i5 " " i6
	k = %k%
	StringReplace, k, k, %A_Space%%A_Space%, %A_Space%, All
	Gui, 1:Font
	Gui, 1:Font, %k%, %j%
	GuiControl, 1:Font, msctls_statusbar321
	Gui, 1:Font
	Gui, 1:Font, %FSet%, %FName%
	WinSet, Redraw,, ahk_id %MainWndID%
	Menu, SBfontMenu, Enable, Set to current
	Menu, SBfontMenu, Disable, Set to GUI default
	Menu, SBfontMenu, Enable, Set to system default
	IniWrite, 0, %iniWork%, StatusBar, Font
return

SBresetFont:
	Gui, 1:Font
	j=
	IniRead, i, %iniWork%, Font, 0
	Menu, SBfontMenu, Enable, Set to current
	if i
		Menu, SBfontMenu, Enable, Set to GUI default
	Menu, SBfontMenu, Disable, Set to system default
	goto SBfontcommon

SBsetFont:
	Gui, 1:Font
	if !j := FontEx("AR", 1)
		return
	IniRead, i, %iniWork%, Font, 0
	Menu, SBfontMenu, Enable, Set to current
	if i
		Menu, SBfontMenu, Enable, Set to GUI default
	Menu, SBfontMenu, Enable, Set to system default
SBfontcommon:
	GuiControl, 1:Font, msctls_statusbar321
	Gui, 1:Font
	Gui, 1:Font, %FSet%, %FName%
	WinSet, Redraw,, ahk_id %MainWndID%
	Loop
		{
		idx := A_Index - isDefFont
		IniRead, i, %iniWork%, Font, %idx%
		if i=ERROR
			{
			IniWrite, %j%, %iniWork%, Font, %idx%
			break
			}
		else if (i=j)
			break
		}
	IniWrite, %idx%, %iniWork%, StatusBar, Font
return

SBsetLabel:
	IniRead, gLabel, %iniWork%, StatusBar, gLabel, %A_Space%
	InputBox, gLabel, Status bar, Set status bar's GOTO label:,, 200, 110,,,,, %gLabel%
	if gLabel
		IniWrite, %gLabel%, %iniWork%, StatusBar, gLabel
return

SBsetIcon:
	FileSelectFile, file, 3, %file%, Select icon file:,
	if !file OR ErrorLevel=1
		return
	; in the future, count icon groups and display a list of icons to choose from
	; (borrow code from VI Lister)
	if part not between 1 and 256
		part=1
	SB_SetIcon(file, icon, part)
	IniWrite, %file%, %iniWork%, StatusBar, %part%IconFile
	IniWrite, %icon%, %iniWork%, StatusBar, %part%IconNmb
return

SBremIcon:
	DllCall("SendMessage", "UInt", hSB, "UInt", 0x40F, "UInt", part-1, "UInt", 0)	; SB_SETICON
	IniDelete, %iniWork%, StatusBar, %part%IconFile
	IniDelete, %iniWork%, StatusBar, %part%IconNmb
return

SBremAllIcon:
	Loop, % DllCall("SendMessage", "UInt", hSB, "UInt", 0x406, "UInt", 0, "UInt", 0)	; SB_GETPARTS
		{
		DllCall("SendMessage", "UInt", hSB, "UInt", 0x40F, "UInt", A_Index-1, "UInt", 0)	; SB_SETICON
		IniDelete, %iniWork%, StatusBar, %A_Index%IconFile
		IniDelete, %iniWork%, StatusBar, %A_Index%IconNmb
		}
return

SBsetSmProgress:
	smth=1
SBsetProgress:
	if !hSBProg%part%
		{
		VarSetCapacity(aBorders, 12, 0)
		DllCall("SendMessage", "UInt", hSB, "UInt", 0x407, "UInt", 0, "UInt", &aBorders)	; SB_GETBORDERS
		vB := NumGet(aBorders, 4, "UInt")
		VarSetCapacity(RECT, 16, 0)
		DllCall("SendMessage", "UInt", hSB, "UInt", 0x40A, "UInt", part-1, "UInt", &RECT)	; SB_GETRECT
		px := NumGet(RECT, 0, "Int")
		py := NumGet(RECT, 4, "Int")
		pw := NumGet(RECT, 8, "Int") - px
		ph := NumGet(RECT, 12, "Int") - py
		Gui, 1:Add, Progress, % "x" px+vB " y" vB+1 " w" pw-vB " h" ph-vB " hwndhSBProg" part " vvarprog" part " Hidden -E0x4 Range0-100" (smth ? "" : " -Smooth"), 25
		DllCall("SetParent", "UInt", hSBProg%part%, "UInt", hSB)
		}
	else if !smth
		{
		ControlFocus,, % "ahk_id" hProg%part%		; Use Focus as a trick...
		GuiControlGet, v, FocusV					; to get control's associated variable
		GuiControl, -C +BackgroundDefault, %v%
		GuiControl, -Smooth, %v%
		}
	WinShow, % "ahk_id" hSBProg%part%
	IniWrite, %smth%, %iniWork%, StatusBar, %part%Prog
	smth=0
return

SBremProgress:
	if hSBProg%part%
		{
		WinHide, % "ahk_id" hSBProg%part%
		IniDelete, %iniWork%, StatusBar, %part%Prog
		}
return

SBremAllProgress:
	Loop, % DllCall("SendMessage", "UInt", hSB, "UInt", 0x406, "UInt", 0, "UInt", 0)	; SB_GETPARTS
		if hSBProg%A_Index%
			{
			WinHide, % "ahk_id" hSBProg%A_Index%
			IniDelete, %iniWork%, StatusBar, %A_Index%Prog
			}
return

SBsetDefBkg:
	GuiControl, 1:+Background%defGC%, msctls_statusbar321
	Menu, SBbkgMenu, Disable, GUI default
	Menu, SBbkgMenu, Enable, System default
	IniWrite, %defGC%, %iniWork%, StatusBar, Color
return

SBresetBkg:
	GuiControl, 1:+BackgroundDefault, msctls_statusbar321
	Menu, SBbkgMenu, Enable, GUI default
	Menu, SBbkgMenu, Disable, System default
	IniWrite, Default, %iniWork%, StatusBar, Color
return

SBsetBkg:
	IniRead, i, %iniWork%, StatusBar, Color, Default
	if i=Default
		i := DllCall("GetSysColor", "UInt", 15)	; COLOR_3DFACE
	i := ChgColor(i, "RR")
	if ErrorLevel
		return
	GuiControl, 1:+Background%i%, msctls_statusbar321
	Menu, SBbkgMenu, Enable, GUI default
	Menu, SBbkgMenu, Enable, System default
	IniWrite, %i%, %iniWork%, StatusBar, Color
return
;===========================================
;	MENU TOGGLES
;===========================================
Grid:
	sysWC := DllCall("GetSysColor", "Int", 15)	; COLOR_3DFACE
	HG := !HG
	Menu, Options, ToggleCheck, Show Grid
	setGrid((HG ? (GO1 ? SwColor(defGC) : sysWC) : grid), (HG ? "-1" : iGrid), DBB, MainWndID)
	if debug
		LogFile("New grid handle: " DBB, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create new grid (DBB)", debugout)
Return

;Ask Control Label
CtrlText:
	AL := !AL
	Menu, Options, ToggleCheck, Ask Control Label
Return

AskGUIProp:
	AG := !AG
	Menu, Options, ToggleCheck, Ask GUI Properties
Return

MicroEditing:
	ME := !ME
	Menu, Options, ToggleCheck, MicroEditing
Return

ShiftMove:
	SM := !SM
	Menu, Options, ToggleCheck, Shift + Move Group
Return

tdebug:
	debug := !debug
	Menu, Options, ToggleCheck, Debug mode
	if debug
		IfNotExist, %debugdir%
			FileCreateDir, %debugdir%
Return

; Gui Helper: 0 = not shown, 1 = created, 2 = showing
Helper:
	HelperStatus := HelperStatus > "0" ? "0" : "1"
	if HelperStatus
		goto GuiHelper
Return
;===========================================
;	GENERIC GUI OPTIONS
;===========================================
SetGUIoptions:
	IfNotEqual, FirstTimeGO, No
		{
		gofl := "AlwaysOnTop|Border|Caption||Disabled|LastFound|MinimizeBox||MaximizeBox||OwnDialogs|Resize|SysMenu||Theme||ToolWindow"
		GOcList := "Static2,Static3,Static4,Static5,Static6,Static7,Static8,Static9,Static10,Static11,Static12,Static13,Static14,Static15,Static16,Static17,Static18,Static19"
		Gui, 11:+Owner1 +ToolWindow -Caption +Border
		Gui, 11:Font, s8 Norm, Tahoma
		Gui, 11:Color, White, White
		Gui, 11:Add, ListView, x153 y17 w40 h20 -E0x200 +Border -hdr +ReadOnly Report Background%defGC% Hidden AltSubmit hwndhLVGO1 vdefGC gsetColors, G
		Gui, 11:Add, ListView, x216 y17 w40 h20 -E0x200 +Border -hdr +ReadOnly Report Background%defCC% Hidden AltSubmit hwndhLVGO2 vdefCC gsetColors, C
		Gui, 11:Add, Edit, x153 y39 w40 h22 Disabled vGOhm, 5
		Gui, 11:Add, UpDown, x183 y39 w13 h22 Disabled, 5
		Gui, 11:Add, Edit, x216 y39 w40 h22 Disabled vGOvm, 5
		Gui, 11:Add, UpDown, x246 y39 w13 h22 Disabled, 5
		Gui, 11:Add, Edit, x137 y61 w16 h22 Disabled Center vGOdel, |
		Gui, 11:Add, Edit, x137 y83 w120 h22 Disabled vGOlbl,
		Gui, 11:Add, Edit, x137 y105 w50 h22 Disabled vGOmsx,
		Gui, 11:Add, UpDown, x+1 y105 w16 h22 Disabled Range50-, 100
		Gui, 11:Add, Edit, x207 y105 w50 h22 Disabled vGOmsy,
		Gui, 11:Add, UpDown, x+1 y105 w16 h22 Disabled Range14-, 100
		Gui, 11:Add, Edit, x137 y127 w50 h22 Disabled vGOmxx,
		Gui, 11:Add, UpDown, x+1 y127 w16 h22 Disabled Range50-, 100
		Gui, 11:Add, Edit, x207 y127 w50 h22 Disabled vGOmxy,
		Gui, 11:Add, UpDown, x+1 y127 w16 h22 Disabled Range14-, 100
		Gui, 11:Add, ComboBox, x137 y149 w50 h21 R5 +BackgroundTrans Disabled vGOown, 1||
		Gui, 11:Add, Edit, x137 y171 w120 h22 Disabled vGOst,
		Gui, 11:Add, Edit, x137 y193 w120 h22 Disabled vGOest,
		Gui, 11:Add, ListBox, x260 y17 w100 h174 0x108 Sort vgol, %gofl%
		Gui, 11:Add, Button, x260 y+2 w30 h22 gGOall, All
		Gui, 11:Add, Button, x+2 yp w36 h22 gGOnone, None
		Gui, 11:Add, Button, x+2 yp w30 h22 gGOdef, Def
		Gui, 11:Add, Button, x11 y226 w100 h24, OK
		Gui, 11:Add, Button, x11 y+1 w100 h24, Cancel
		Gui, 11:Add, Picture, x0 y0 w372 h280 0x400000E hwndhPic11 vsk11 gmoveit,
		hBSkin11 := ILC_FitBmp(hPic11, skin, cSkin)
		if debug
			LogFile("GUI11 skin handle: " hBSkin11, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI11 skin (hBSkin11)", debugout)
		Gui, 11:Add, GroupBox, x6 y3 w360 h217 +0x8000 BackgroundTrans,

		Gui, 11:Font, s16 c0xFF0000 w400, Wingdings
		Gui, 11:Add, Text, x11 y17 w18 h22 +0x200 +BackgroundTrans hwndhGO011 vGO1 gToggleGO, û
		Gui, 11:Add, Text, xp y39 wp hp +0x200 +BackgroundTrans hwndhGO021 vGO2 gToggleGO, û
		Gui, 11:Add, Text, xp y61 wp hp +0x200 +BackgroundTrans hwndhGO031 vGO3 gToggleGO, û
		Gui, 11:Add, Text, xp y83 wp hp +0x200 +BackgroundTrans hwndhGO041 vGO4 gToggleGO, û
		Gui, 11:Add, Text, xp y105 wp hp +0x200 +BackgroundTrans hwndhGO051 vGO5 gToggleGO, û
		Gui, 11:Add, Text, xp y127 wp hp +0x200 +BackgroundTrans hwndhGO061 vGO6 gToggleGO, û
		Gui, 11:Add, Text, xp y149 wp hp +0x200 +BackgroundTrans hwndhGO071 vGO7 gToggleGO, û
		Gui, 11:Add, Text, xp y171 wp hp +0x200 +BackgroundTrans hwndhGO081 vGO8 gToggleGO, û
		Gui, 11:Add, Text, xp y193 wp hp +0x200 +BackgroundTrans hwndhGO091 vGO9 gToggleGO, û
		Gui, 11:Font, s8 cDefault Norm, Tahoma
		Gui, 11:Add, Text, x29 y17 w107 h22 +0x200 BackgroundTrans hwndhGO012 gToggleGO, GUI color
		Gui, 11:Add, Text, xp y39 wp hp +0x200 BackgroundTrans hwndhGO022 gToggleGO, GUI margins
		Gui, 11:Add, Text, xp y61 wp hp +0x200 BackgroundTrans hwndhGO032 gToggleGO, GUI delimiter
		Gui, 11:Add, Text, xp y83 wp hp +0x200 BackgroundTrans hwndhGO042 gToggleGO, GUI custom labels
		Gui, 11:Add, Text, xp y105 wp hp +0x200 BackgroundTrans hwndhGO052 gToggleGO, GUI MinSize
		Gui, 11:Add, Text, xp y127 wp hp +0x200 BackgroundTrans hwndhGO062 gToggleGO, GUI MaxSize
		Gui, 11:Add, Text, xp y149 wp hp +0x200 BackgroundTrans hwndhGO072 gToggleGO, GUI owner
		Gui, 11:Add, Text, xp y171 wp hp +0x200 BackgroundTrans hwndhGO082 gToggleGO, GUI style
		Gui, 11:Add, Text, xp y193 wp hp +0x200 BackgroundTrans hwndhGO092 gToggleGO, GUI extended style

		Gui, 11:Add, Text, x137 y39 w15 h22 +0x200 +Right BackgroundTrans Disabled, H:
		Gui, 11:Add, Text, x200 y39 w15 h22 +0x200 +Right BackgroundTrans Disabled, V:
		Gui, 11:Add, Text, x189 y105 w17 h22 +0x200 +Center BackgroundTrans Disabled, X
		Gui, 11:Add, Text, x189 y127 w17 h22 +0x200 +Center BackgroundTrans Disabled, X
		Gui, 11:Add, Text, x119 y225 w248 h64 +Disabled BackgroundTrans, Due to their nature`, some of the options will not take effect in the workspace`; they will however work correctly in the saved script.
		; Generated using SmartGUI Creator 4.3y
		Gui, 11:Show, w372 h280, GUI options
		WinGet, hGui11, ID, GUI options
		hGuis .= "," hGui11
		DllCall("SetParent", "UInt", hGui11, "UInt", wpID)
		if debug
			LogFile("GUI11 handle: " hGui11, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Get GUI11 handle (hGui11)", debugout)
		FirstTimeGO = No
		}
	else, Gui, 11:Show
	if w9x
		Hotkey9x("LD", "Off")
return

ToggleGO:
	StringReplace, i, ClickedCtrl, Static,
	i-=(1+9*(i>10))
	GO%i% := !GO%i%
	Gui, 11:Font, % "s16 " (GO%i% ? "c0x0000FF" : "c0xFF0000") " w400", Wingdings
	GuiControl, 11:Font, % "Static" i+1
	GuiControl, 11:, % ("Static" i+1), % (GO%i% ? "ü" : "û")
	Gui, 11:Font
goto GO%i%

GO1:
	GuiControl, % "11:" (GO1 ? "Show" : "Hide"), SysListView321
	GuiControl, % "11:" (GO1 ? "Show" : "Hide"), SysListView322
return
GO2:
	GuiControl, % "11:" (GO2 ? "Enable" : "Disable"), Edit1
	GuiControl, % "11:" (GO2 ? "Enable" : "Disable"), msctls_updown321
	GuiControl, % "11:" (GO2 ? "Enable" : "Disable"), Edit2
	GuiControl, % "11:" (GO2 ? "Enable" : "Disable"), msctls_updown322
return
GO3:
	GuiControl, % "11:" (GO3 ? "Enable" : "Disable"), Edit3
return
GO4:
	GuiControl, % "11:" (GO4 ? "Enable" : "Disable"), Edit4
return
GO5:
	GuiControl, % "11:" (GO5 ? "Enable" : "Disable"), Edit5
	GuiControl, % "11:" (GO5 ? "Enable" : "Disable"), msctls_updown323
	GuiControl, % "11:" (GO5 ? "Enable" : "Disable"), Edit6
	GuiControl, % "11:" (GO5 ? "Enable" : "Disable"), msctls_updown324
return
GO6:
	GuiControl, % "11:" (GO6 ? "Enable" : "Disable"), Edit7
	GuiControl, % "11:" (GO6 ? "Enable" : "Disable"), msctls_updown325
	GuiControl, % "11:" (GO6 ? "Enable" : "Disable"), Edit8
	GuiControl, % "11:" (GO6 ? "Enable" : "Disable"), msctls_updown326
return
GO7:
	GuiControl, % "11:" (GO7 ? "Enable" : "Disable"), ComboBox1
return
GO8:
	GuiControl, % "11:" (GO8 ? "Enable" : "Disable"), Edit10
return
GO9:
	GuiControl, % "11:" (GO9 ? "Enable" : "Disable"), Edit11
return

GOall:
	PostMessage, 0x185, 1, -1, ListBox1, ahk_id %hGui11%	; Select all items (LB_SETSEL)
return

GOnone:
	PostMessage, 0x185, 0, -1, ListBox1, ahk_id %hGui11%	; Deselect all items
return

GOdef:
	GuiControl, 11:, gol, |%gofl%
return

11ButtonOK:
	Gui, 11:Submit, NoHide
	gofl2 := "|" gofl "|"
	StringReplace, gofl2, gofl2, ||, |, all
	gol := "|" gol "|"
	GenGuiOptions =
	Loop, Parse, gofl2, |
		if (A_LoopField <> "")
			{
			if InStr(gol, "|" A_LoopField "|")
				GenGuiOptions .= "+" A_LoopField " "
			else GenGuiOptions .= "-" A_LoopField " "
			}
	StringTrimRight, GenGuiOptions, GenGuiOptions, 1
	if GO1
		GenGuiOptions .= "`nColor, " defGC "`, " defCC
	if GO2
		GenGuiOptions .= "`nMargin, " GOhm "`, " GOvm
	if GO3
		GenGuiOptions .= "`n+Delimiter" GOdel
	if GO4
		GenGuiOptions .= "`n+Label" GOlbl
	if GO5
		GenGuiOptions .= "`n+MinSize" GOmsx "x" GOmsy
	if GO6
		GenGuiOptions .= "`n+MaxSize" GOmxx "x" GOmxy
	if GO7
		GenGuiOptions .= "`n+Owner" GOown
	if GO8
		GenGuiOptions .= "`n+" GOst
	if GO9
		GenGuiOptions .= "`n+" GOest
	;Gui, 1:Color, % (GO1 ? defGC : "Default"), % (GO1 ? defCC : "Default")	; don't use coz it kills the grid
	setGrid((HG ? (GO1 ? SwColor(defGC) : sysWC) : grid), (HG ? "-1" : iGrid), DBB, MainWndID)
	if GO3
		Gui, 1:+Delimiter%GOdel%
	if GO5
		Gui, 1:+MinSize%GOmsx%x%GOmsy%
	if GO6
		Gui, 1:+MaxSize%GOmxx%x%GOmxy%
11ButtonCancel:
11GuiClose:
	Gui, 11:Cancel
	Gui, 1:Default
	if w9x
		Hotkey9x("LD", "On")
return
;===========================================
;	SET PICKED COLOR
;===========================================
setColors:
	if (A_GuiEvent != "Normal")
		return
	ofi := A_FormatInteger
	SetFormat, Integer, Hex
	j := A_GuiControl
	i := %j%
	r := ChgColor(i, "BR", "1")
	SetFormat, Integer, %ofi%
	if ErrorLevel
		return
	%j% := r
	GuiControl, %A_Gui%:+Background%r%, %j%
return
;===========================================
;	GLOBAL FONT SETTINGS
;===========================================
ResetFont:
	FSet=
	FName=
	FCharset=
	j=|||||||
	Menu, fnt, Enable, Reset to GUI default
	Menu, fnt, Disable, Reset to system default
	goto fontcommon

ResetDefFont:
	IniRead, j, %iniWork%, Font, 0
	if j=ERROR
		{
		Ctrl2Add=
		return
		}
	StringSplit, i, j, |
	FName := i7
	FCharset := i8
	FSet := (i1 ? "s" i1 : "") (i2 ? " c" i2 : "") (i3 ? " w" i3 : "") " " i4 " " i5 " " i6
	StringReplace, FSet, FSet, %A_Space%%A_Space%, %A_Space%, All
	FSet = %FSet%
	Gui, 1:Font
	Gui, 1:Font, %FSet%, %FName%
	cFontIdx=0
	Menu, fnt, Disable, Reset to GUI default
	Menu, fnt, Enable, Reset to system default
goto fontcommon2
Return

SetDefaultFont:
	Menu, fnt, Disable, Reset to GUI default
	setDefFont=1
	j := FontEx("R", "1")
	if ErrorLevel
		{
		setDefFont=
		Ctrl2Add=
		return
		}
goto fontcommon1

SelectFont:
	j := FontEx("R", "1")
	if ErrorLevel
		{
		Ctrl2Add=
		return
		}
	Menu, fnt, Enable, Reset to GUI default
fontcommon1:
	StringSplit, i, j, |
	FName := i7
	FCharset := i8
	FSet := (i1 ? "s" i1 : "") (i2 ? " c" i2 : "") (i3 ? " w" i3 : "") (i4 ? " " i4 : "") (i5 ? " " i5 : "") (i6 ? " " i6 : "")
	StringReplace, FSet, FSet, %A_Space%%A_Space%, %A_Space%, All
	FSet = %FSet%
	Menu, fnt, Enable, Reset to system default
fontcommon:
	IniRead, ItemList, %iniWork%, Main, ItemList, |
	if (ItemList = "|" OR setDefFont)
		{
		isDefFont=1
		setDefFont=
		Menu, SBfontMenu, Enable, Set to GUI default
		Menu, ControlFont, Enable, GUI default
		}
	Loop
		{
		cFontIdx := A_Index - isDefFont
		IniRead, i, %iniWork%, Font, %cFontIdx%
		if i=ERROR
			{
			IniWrite, %j%, %iniWork%, Font, %cFontIdx%
			break
			}
		else if (i=j)
			break
		}
	Gui, 1:Font
	if FSet OR FName
		Gui, 1:Font, %FSet%, %FName%
fontcommon2:
	Menu, SBfontMenu, Enable, Set to current
	Ctrl2Add=
	IniRead, ItemList, %iniWork%, Main, ItemList, |
	IniWrite, %ItemList%Font%CFontIdx%|, %iniWork%, Main, ItemList
Return
;===========================================
;	CONTROL FONT SETTINGS
;===========================================
CtrlFontSet:
	i := FontEx("R", "1")
	if ErrorLevel
		return
	if isDefFont
		Menu, ControlFont, Enable, GUI default
	Menu, ControlFont, Enable, System default
	goto CtrlFontCom
CtrlFontGui:
	IniRead, i, %iniWork%, Font, 0
	if i=ERROR
		return
CtrlFontCom:
	FormatFont(i, 1, j)
CtrlFontCom2:
	Edit2Combo(CtrlNameCount)
	GuiControl, 1:Font, %CtrlNameCount%
	Gui, 1:Font
	Gui, 1:Font, %FSet%, %FName%
	Loop
		{
		idx := A_Index - isDefFont
		IniRead, j, %iniWork%, Font, %idx%
		if j=ERROR
			{
			IniWrite, %i%, %iniWork%, Font, %idx%
			break
			}
		else if (i=j)
			break
		}
	IniWrite, %idx%, %iniWork%, %CtrlNameCount%, Font
return
CtrlFontSys:
	i=
	if isDefFont
		Menu, ControlFont, Enable, GUI default
	Gui, 1:Font
	goto CtrlFontCom2
;===========================================
;	SNAP TO GRID
;===========================================
ChSnapTo:
	IfNotEqual, FirstTimeSTG, No
		{
		Gui, 4:+ToolWindow -Caption +Border
		Gui, 4:Color, White, White
		Gui, 4:Font, s8, Tahoma
		Gui, 4:Add, Edit, x28 y27 w45 h20 BackgroundTrans vstgXm gstgH, 
		Gui, 4:Add, UpDown, x60 y27 w13 h20 Range1-999 BackgroundTrans vstgXu, 
		Gui, 4:Add, Edit, x95 y27 w45 h20 BackgroundTrans vstgYm gstgV, 
		Gui, 4:Add, UpDown, x127 y27 w13 h20 Range1-999 BackgroundTrans vstgYu, 
		Gui, 4:Add, Button, x20 y112 w50 h20 Default, OK
		Gui, 4:Add, Button, x80 y112 w50 h20, Cancel
		Gui, 4:Add, Picture, x0 y0 w148 h135 0x400000E hwndhPic4 vsk4 gmoveit,
		hBSkin4 := ILC_FitBmp(hPic4, skin, cSkin)
		if debug
			LogFile("GUI4 skin handle: " hBSkin4, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI4 skin (hBSkin4)", debugout)
		Gui, 4:Add, GroupBox, x3 y-2 w142 h110 +0x8000 BackgroundTrans, 
		Gui, 4:Add, Text, x6 y6 w140 h20 0x200 BackgroundTrans Center, SnapToGrid steps [px]
		Gui, 4:Add, Text, x6 y27 w20 h20 0x200 BackgroundTrans Right, H :
		Gui, 4:Add, Text, x73 y27 w20 h20 0x200 BackgroundTrans Right, V :
		Gui, 4:Font, s8, Wingdings
		Gui, 4:Add, Text, x28 y50 w12 h16 +0x200 BackgroundTrans vstg1 gToggleSTG, % Chr(164)
		Gui, 4:Add, Text, x28 y68 w12 h16 +0x200 BackgroundTrans vstg2 gToggleSTG, % Chr(161)
		Gui, 4:Add, Text, x28 y86 w12 h16 +0x200 BackgroundTrans vstg3 gToggleSTG, % Chr(161)
		Gui, 4:Font, s8, Tahoma
		Gui, 4:Add, Text, x40 y50 w70 h16 +0x200 BackgroundTrans gToggleSTG, Separate
		Gui, 4:Add, Text, x40 y67 w70 h16 +0x200 BackgroundTrans gToggleSTG, Proportional
		Gui, 4:Add, Text, x40 y85 w70 h16 +0x200 BackgroundTrans gToggleSTG, Square
		; Generated using SmartGUI Creator 4.3.26.2
		ClickedCtrl=Static%stgType%
		stgTypem := stgType
		Gui, 4:Show, w148 h135, Set SnapToGrid Step
		WinGet, hGui4, ID, Set SnapToGrid Step
		hGuis .= "," hGui4
		DllCall("SetParent", "UInt", hGui4, "UInt", wpID)
		if debug
			LogFile("GUI4 handle: " hGui4, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI4 handle (hGui4)", debugout)
		FirstTimeSTG = No
		}

	gosub firstSTG
	Gui, 4:Show
	GuiControl, 4:, stgXm, %stgX%
	GuiControl, 4:, stgYm, %stgY%
return

ToggleSTG:
	StringReplace, stgType, ClickedCtrl, Static,
	stgType-=(4+3*(stgType>7))
firstSTG:
	Loop, 3
		GuiControl, 4:, % "Static" 4+A_Index, % Chr(stgType=A_Index ? "164" : "161")
	GuiControl, % "4:" (stgType=3 ? "Hide" : "Show"), Static3
	GuiControl, % "4:" (stgType=3 ? "Hide" : "Show"), Static4
	GuiControl, % "4:" (stgType=3 ? "Hide" : "Show"), Edit2
	GuiControl, % "4:" (stgType=3 ? "Hide" : "Show"), msctls_updown322
return

stgH:
	ostgXm := stgXu
	Gui, 4:Submit, NoHide
	if stgType=3
		GuiControl, 4:, stgYm, %stgXm%
	else if stgType=2
		GuiControl, 4:, stgYu, % Round((stgXu*stgYm)/ostgXm)
	Gui, 4:Submit, NoHide
return

stgV:
	ostgYm := stgYu
	Gui, 4:Submit, NoHide
	if stgType=2
		GuiControl, 4:, stgXu, % Round((stgXm*stgYu)/ostgYm)
	Gui, 4:Submit, NoHide
return

4ButtonCancel:
	stgXm := stgX
	stgYm := stgY
	stgType := stgTypem
	Gui, 4:Cancel
Return

4ButtonOK:
	Gui, 4:Submit
	stgX := stgXm
	stgY := stgType=3 ? (stgYm := stgXm) : stgYm
	stgTypem := stgType
Return
;===========================================
;	CONTROL REPOSITIONING / RESIZE
;===========================================
SetPos:
	ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH, %CtrlNameCount%, ahk_id %MainWndID%
	IfNotEqual, FirstTimeSP, No
		{
		Gui, 6:+ToolWindow -Caption +Border
		Gui, 6:Color, White, White
		Gui, 6:Add, Edit, x28 y12 w45 h20 BackgroundTrans vCtrlSetX,
		Gui, 6:Add, UpDown, Range-1-9999 BackgroundTrans
		Gui, 6:Add, Edit, x95 y12 w45 h20 BackgroundTrans vCtrlSetY,
		Gui, 6:Add, UpDown, Range-1-9999 BackgroundTrans
		Gui, 6:Add, Edit, x28 y42 w45 h20 BackgroundTrans vCtrlSetW,
		Gui, 6:Add, UpDown, Range-1-9999 BackgroundTrans
		Gui, 6:Add, Edit, x95 y42 w45 h20 BackgroundTrans vCtrlSetH,
		Gui, 6:Add, UpDown, Range-1-9999 BackgroundTrans
		Gui, 6:Add, Button, x20 y77 w50 h20 Default, OK
		Gui, 6:Add, Button, x80 y77 w50 h20, Cancel
		Gui, 6:Add, Picture, x0 y0 w148 h102 0x400000E hwndhPic6 vsk6 gmoveit,
		hBSkin6 := ILC_FitBmp(hPic6, skin, cSkin)
		if debug
			LogFile("GUI6 skin handle: " hBSkin6, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI6 skin (hBSkin6)", debugout)
		Gui, 6:Add, GroupBox, x3 y-2 w142 h72 +0x8000 BackgroundTrans,
		Gui, 6:Add, Text, x6 y12 w20 h20 0x200 BackgroundTrans Right, X :
		Gui, 6:Add, Text, x73 y12 w20 h20 0x200 BackgroundTrans Right, Y :
		Gui, 6:Add, Text, x6 y42 w20 h20 0x200 BackgroundTrans Right, W :
		Gui, 6:Add, Text, x73 y42 w20 h20 0x200 BackgroundTrans Right, H :
		Gui, 6:Show, h102 w148, Set Position
		WinGet, hGui6, ID, Set Position
		hGuis .= "," hGui6
		DllCall("SetParent", "UInt", hGui6, "UInt", wpID)
		if debug
			LogFile("GUI6 handle: " hGui6, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI6 handle (hGui6)", debugout)
		FirstTimeSP = No
		}

	Gui, 6:Show
	GuiControl, 6:, CtrlSetX, % CtrlX-WinDiffW
	GuiControl, 6:, CtrlSetY, % CtrlY-WinDiffH+WinDiffW-menuH*MenuVis
	GuiControl, 6:, CtrlSetW, %CtrlW%
	GuiControl, 6:, CtrlSetH, %CtrlH%
Return

6ButtonCancel:
	Gui, 6:Cancel
Return

6ButtonOK:
	Gui, 6:Submit
	ControlMove, %CtrlNameCount%, % CtrlSetX+WinDiffW, % CtrlSetY+WinDiffH-WinDiffW+menuH*MenuVis
	, %CtrlSetW%, %CtrlSetH%, ahk_id %MainWndID%

	Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%

	;here we get Ctrl2Add (ahk name)
	IniRead, Ctrl2Add, %iniWork%, %CtrlNameCount%, Name

	;Here we get correct Ctrl text after modification
	IniRead, CtrlText, %iniWork%, %CtrlNameCount%, Label

	Loop, Parse, PosFields
		{
		CurrPos := CtrlSet%A_LoopField%
		IniWrite, %CurrPos%, %iniWork%, %CtrlNameCount%, %A_LoopField%
		}
	Ctrl2Add=
Return
;===========================================
;	REDIRECT EDIT TO COMBOBOX (use in Font, Label, Custom options)
;===========================================
Edit2Combo(ByRef cCtrl)
{
Global MainWndID, iniWork
ControlGet, k, Hwnd,, %cCtrl%, ahk_id %MainWndID%
j := DllCall("GetParent", "UInt", k)
if (j != MainWndID)
	{
	IniRead, ItemList, %iniWork%, Main, ItemList
	Loop, Parse, ItemList,|
		{
		GuiControlGet, i, 1:Hwnd, %A_LoopField%
		if (i=j)
			cCtrl := A_LoopField, return 1
		}
	return -1
	}
return
}
;===========================================
;	LABEL CHANGING
;===========================================
ChangeLabel:
	IniRead, OLabel, %iniWork%, %CtrlNameCount%, Label
	IniRead, CtrlType, %iniWork%, %CtrlNameCount%, Type, %A_Space%
	StringReplace, OLabel, OLabel, ```,, `,, A
	StringReplace, OLabel, OLabel, ````, ``, A
	StringReplace, OLabel, OLabel, ```%, `%, A
	resume := "resumeChange"
	if CtrlNameCount contains Static,Edit,Button,Menu
		{
		ControlGet, i, Style,, %CtrlNameCount%, ahk_id %MainWndID%
		i &= 0x0F
		StringReplace, OLabel, OLabel, ``n, `n, A
		ControlGetPos,,, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%
		labelToChange := "Change " CtrlNameCount " label :"
		if CtrlNameCount contains Button
			cH := (i="7" ? "14" : cH)	; if control is Groupbox, use standard one-row height
		IniRead, cOpt, %iniWork%, %CtrlNameCount%, Options
		if CtrlNameCount contains Static
			{
			if i in 3,14,15	; SS_ICON/BITMAP/ENHMETAFILE
				gosub SelPic
			else goto niceText
			}
		else if CtrlNameCount contains Edit
			{
			if Edit2Combo(CtrlNameCount)
				goto ChangeLabel
			else goto niceText
			}
		else 	goto niceText
;		msgbox, We should never see this. Please report it!
;		IfNotExist, %CtrlText%
;			CtrlText := OLabel
;		if err
;			CtrlText := OLabel
		}
	else if CtrlNameCount contains msctls_progress32,msctls_trackbar32,msctls_updown32,SysTabControl32
		{
		cW=80
		cH=14
		cOpt=
		if CtrlNameCount contains msctls_progress32,msctls_trackbar32,msctls_updown32
			labelToChange := "Change " CtrlNameCount " value :"
		else
			{
			ControlGetPos,,, cW,, %CtrlNameCount%, ahk_id %MainWndID%
			labelToChange := "Change " CtrlNameCount " items :"
			}
		goto niceText
		}
	else if CtrlNameCount contains msctls_hotkey32,ListBox,SysListView32,ComboBox
		{
		ControlGetPos,,, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%
		cOpt=
		if CtrlNameCount contains msctls_hotkey32
			labelToChange := "Change " CtrlNameCount " key combination :"
		else if CtrlNameCount contains ListBox
			labelToChange := "Change " CtrlNameCount " item list :", cW += 8
		else if CtrlNameCount contains SysListView32
			{
			labelToChange := "Change " CtrlNameCount " header items :"
			ControlGetPos,,,, cH, SysHeader32%CtrlCount%, ahk_id %MainWndID%
			}
		else if CtrlNameCount contains ComboBox
			{
			; read user-defined height, else use a predefined height (5*16)
			IniRead, cH, %iniWork%, %CtrlNameCount%, H, 80
			labelToChange := "Change " CtrlNameCount " item list :"
			}
		goto niceText
		}
	else if CtrlNameCount contains SysTreeView32
		return
	else
		InputBox, CtrlText, Label, Enter Control Label,, 250, 135,,,,,%OLabel%
;msgbox, control is %CtrlNameCount% %OLabel%
resumeChange:
	IfEqual, ErrorLevel, 1, Return
	If CtrlNameCount contains SysTabControl,ListBox,ComboBox,SysListView32
		{
; somebody might erroneously use 'newline' as separator, so we correct this in the background
		StringReplace, TmpCtrlText, CtrlText, ``n, |, A
		StringReplace, TmpCtrlText, TmpCtrlText, `n, |, A
		CtrlText := TmpCtrlText
		}
	else StringReplace, CtrlText, CtrlText, ``n, `n, A

	;replacing earlier contents of ctrl label / need to check if Tab retains respective controls
	If CtrlNameCount contains SysTabControl,ListBox,ComboBox
		GuiControl, 1:, %CtrlNameCount%, |%TmpCtrlText%
	Else if CtrlNameCount contains SysListView32
		{
		Gui, 1:Default
		Gui, 1:ListView, %CtrlNameCount%
		i := LV_GetCount("Col")
		j=0
		Loop, Parse, TmpCtrlText, |
			{
			if (A_Index > i)
				LV_InsertCol(A_Index, "AutoHdr", A_LoopField)
			else LV_ModifyCol(A_Index, "AutoHdr", A_LoopField)
			j++
			}
		Loop, % i-j
			LV_DeleteCol(j+1)
		LV_ModifyCol(1, "AutoHdr")
		}
	Else if CtrlNameCount contains Static
			{
;msgbox, CtrlText before text fixed is %CtrlText%`nStyle is %i%
			if i in 3,14,15	; SS_ICON/BITMAP/ENHMETAFILE
				if DllCall("shlwapi\PathFileExistsA", "Str", CtrlText)	; because FileExist() is so fucked up on 9x!
					GuiControl, 1:, %CtrlNameCount%, %CtrlText%
			}
	Else
		GuiControl, 1:, %CtrlNameCount%, %CtrlText%
	Gosub, FixText

	;leading pipe removed from controltext
	;this pipe is added to control labels to clear previous contents
	;eg. for listbox and tabs
	StringLeft, Test, CtrlText, 1
	IfEqual, Test, |, StringTrimLeft, CtrlText, CtrlText, 1

	IniWrite, %CtrlText%, %iniWork%, %CtrlNameCount%, Label
;msgbox, CtrlText after text fixed and ini write is %CtrlText%
Return

niceText:
	IfNotEqual, BuiltTE, 1
		{
		Gui, 98:+Owner1 +ToolWindow -Caption +Border +AlwaysOnTop
		Gui, 98:Margin, 5, 5
		Gui, 98:Color, White, White
		Gui, 98:Font, s8 cBlack, Tahoma
		Gui, 98:Add, Edit, ym+15 w150 h75 +Multi -0x00300000 -E0x200 Border vTElabel, %OLabel%
		Gui, 98:Add, Button, xm y+5 w44 h24, OK
		Gui, 98:Add, Button, x+2 yp w44 h24, Cancel
		Gui, 98:Add, Picture, x0 y0 w150 h75 0x400000E hwndhPic98 vsk98 gmoveit,
		Gui, 98:Font, s8 Bold cBlack, Tahoma
		Gui, 98:Add, Text, xm ym w90 h14 +0x200 Center BackgroundTrans hwndhLabel, %labelToChange%
		hBSkin98 := ILC_FitBmp(hPic98, skin, cSkin)
		if debug
			LogFile("GUI98 skin handle: " hBSkin98, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI98 skin (hBSkin98)", debugout)
		Gui, 98:Show,, Change text
		Gui, 98:+LastFound
		WinGet, hGui98, ID, Change text
		hGuis .= "," hGui98
		; get a handle to the help label font (Tahoma, Bold, 8 by default)
		VarSetCapacity(LF, 60, 0)
		hDC := DllCall("GetDC", UInt, hGui98)
		if debug
			LogFile("GUI98 DC handle: " hDC, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "GUI98 GetDC handle (hDC)", debugout)
		; lfHeight LOGPIXELSY
		NumPut(-DllCall("MulDiv", "Int", 8, "Int", DllCall("gdi32\GetDeviceCaps", "UInt", hDC, "Int", 90), "Int", 72), LF, 0, "Int")
		DllCall("ReleaseDC", "UInt", hGui98, "UInt", hDC)
		NumPut(700, LF, 16, "UInt")		; FW_BOLD
		NumPut(1, LF, 23, "UChar")		; DEFAULT_CHARSET
		DllCall("lstrcpy", "UInt", &LF + 28, "Str", "Tahoma")
		hFont := DllCall("CreateFontIndirectA", "UInt", &LF)
		if debug
			LogFile("Font handle: " hFont, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI98 font Tahoma 8 Bold (hFont)", debugout)
		BuiltTE=1
		}
	; compensate for any extra chars in label (like &, %, etc)
	Loop, Parse, OLabel
		{
		z := Asc(A_LoopField)
		if z in 37,38
			cW += 9
		}
;===== trying to get rid of disabled/read-only styles that break label editing (April 28-29, 2014)
		if InStr(cOpt, " Disabled")
			StringReplace, cOpt, cOpt, %A_Space%Disabled,,
		if InStr(cOpt, " +Disabled")
			StringReplace, cOpt, cOpt, %A_Space%+Disabled,,
		if InStr(cOpt, " ReadOnly")
			StringReplace, cOpt, cOpt, %A_Space%ReadOnly,,
		if InStr(cOpt, " +ReadOnly")
			StringReplace, cOpt, cOpt, %A_Space%+ReadOnly,,
;=====
	hDC := DllCall("GetDC", "UInt", hGui98)
	hOldFont := DllCall("SelectObject", "UInt", hDC, "UInt", hFont)
	if debug
		LogFile("GUI98 DC handle: " hDC " and old font handle: " hOldFont, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "GUI98 GetDC handle (hDC) and SelectObject (hFont)", debugout)
	VarSetCapacity(size, 8, 0)
	DllCall("GetTextExtentPoint32", "UInt", hDC, "Str", labelToChange, "UInt", StrLen(labelToChange), "UInt", &size)
	DllCall("SelectObject", "UInt", hDC, "UInt", hOldFont)
	DllCall("ReleaseDC", "UInt", hGui98, "UInt", hDC)
	w := 1+NumGet(size, 0), h := 1+NumGet(size, 4), max := (cW+2>w ? cW+2 : w)
	GuiControl, 98:, Static2, %labelToChange%
	ControlMove, Edit1, % (max+10-cW-2)//2,, % cW+2, % cH+4, ahk_id %hGui98%
	ControlMove, Static2, % (max+10-w)//2,, %w%, %h%, ahk_id %hGui98%
	GuiControl, 98:MoveDraw, Static1, x0, y0, w%cW%, h%cH%
	ControlMove, Button1, % (max+10-90)//2, % cH+30,,, ahk_id %hGui98%
	ControlMove, Button2, % 1+(max+10)//2, % cH+30,,, ahk_id %hGui98%
	GuiControl, 98:%cOpt% -0x003000C0 +vTElabel -g, Edit1
	IniRead, z, %iniWork%, %CtrlNameCount%, Font, %A_Space%
	IniRead, i, %iniWork%, Font, %z%, %A_Space%
	k := FormatFont(i, 98, j)
	GuiControl, 98:Font, Edit1
	GuiControl, 98:, Edit1, %OLabel%
	Gui, 98:Font
	Gui, 98:Font, s8 cBlack, Tahoma
	Gui, 98:Show, AutoSize
	WinGetPos,,, cW, cH, ahk_id %hGui98%
	GuiControl, 98:MoveDraw, Static1, x0, y0, w%cW%, h%cH%
return

98ButtonCancel:
	ErrorLevel=1
98ButtonOK:
	Gui, 98:Submit
	CtrlText := TElabel
	If CtrlNameCount contains SysTabControl,SysListView32
		if (!CtrlText && !ErrorLevel)
			goto niceText
	goto %resume%
return
;===========================================
splitNC:
	Loop
		{
		StringRight, check, CtrlNameCount, %A_Index%
		if check is not integer
			Break
		CtrlCount := check
		StringTrimRight, CtrlName, CtrlNameCount, %A_Index%
		}
	CtrlCount := CtrlCount ? CtrlCount : "1"
	if debug
		GuiControl, 9:, test2, Ctrl: %CtrlName% %CtrlCount%
return
;===========================================
;	MOVE / RESIZE CONTROL
;===========================================
Modify:
	ControlGetPos, cX, cY,,, %CtrlNameCount%, ahk_id %MainWndID%
	;here we get Ctrl2Add (ahk name)
	IniRead, Ctrl2Add, %iniWork%, %CtrlNameCount%, Name
	If Ctrl2Add Not In %ControlsKnown%
		{
		Ctrl2Add=
		Return
		}
	;get separate CtrlName and CtrlCount from CtrlNameCount
	gosub splitNC
	;Here we get correct Ctrl text after modification
	IniRead, CtrlText, %iniWork%, %CtrlNameCount%, Label, %A_Space%
	ControlGetPos, cx, cY,,, %CtrlNameCount%, ahk_id %MainWndID%	; fix by fasto
	MouseMove, %cx%, %cy%, 0								; fix by fasto
	Goto, Alter
return
;===========================================
;	DUPLICATE CONTROL
;===========================================
Duplicate:
	ControlGetPos, cX, cY, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%
	;get separate CtrlName and CtrlCount from CtrlNameCount
	gosub splitNC
	;No Tab or Menu duplication
	If CtrlName in SysTabControl,Menu
		return
	;read from ini the Ctrl data
	IniRead, Ctrl2Add, %iniWork%, %CtrlNameCount%, Name
	IniRead, CtrlLabel, %iniWork%, %CtrlNameCount%, Label, %A_Space%
	IniRead, CtrlOptions, %iniWork%, %CtrlNameCount%, Options, %A_Space%
	IniRead, CtrlFont, %iniWork%, %CtrlNameCount%, Font, %A_Space%
	IniRead, CtrlType, %iniWork%, %CtrlNameCount%, Type, %A_Space%

	JustCopy = Y
	Goto, CreateCtrl
Return
;===========================================
;	DELETE CONTROL
;===========================================
DelSB:
	CtrlNameCount = StatusBar
	Menu, ControlMenu2, Disable, Status bar
	goto Delete
DelMenu:
	CtrlNameCount = Menu1
	Menu, ControlMenu2, Disable, Main menu
Delete:
	;get and store undo information and then hide control
	IniRead, ItemList, %iniWork%, Main, ItemList
	StringReplace, ItemList, ItemList, |%CtrlNameCount%|, |^%CtrlNameCount%|, A
	IniWrite, %ItemList%, %iniWork%, Main, ItemList
	if CtrlNameCount = Menu1
		{
		Gui, 1:Menu
		MenuVis=0
		}
	else if CtrlNameCount = StatusBar
		Control, Hide,, msctls_statusbar321, ahk_id %MainWndID%
	else
		{
;		Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
; don't use the above - it makes deleted controls reappear, in Tab control
		GuiControl, Hide, %CtrlNameCount%
		if CtrlNameCount = SysTabControl321
			{
			TabDeleted=1
			inTab=0
			TB_BtnSet(hTB99, 17, "s4")
			}
		}
	LastDel = %CtrlNameCount%|%lastDel%
	IfEqual, FirstTimeM, No
		goto updatectrls
Return
;===========================================
;	'UNDO' HOTKEY
;===========================================
;~^Z::
HKUndo:
	IfWinNotActive, ahk_id %MainWndID%,,
		{
		if w9x
			Hotkey, ^Z, Off
		SendInput {^Z}
		if w9x
			Hotkey, ^Z, On
		Return
		}

	;Showing the last hidden control
	StringGetPos, PPos, LastDel, |
	if PPos = -1
		return
	StringLeft, CtrlNameCount, LastDel, %PPos%
	PPos ++
	StringTrimLeft, LastDel, LastDel, %PPos%
restoreCtrl:
	if CtrlNameCount = Menu1
		{
		StringReplace, LastDel, LastDel, %CtrlNameCount%|,,
		IniRead, CtrlText, %iniWork%, %CtrlNameCount%, Label
		Menu, ControlMenu2, Enable, Main menu
		gosub EditMenu
		CtrlText=
		}
	else if CtrlNameCount = StatusBar
		{
		StringReplace, LastDel, LastDel, %CtrlNameCount%|,,
		Control, Show,, msctls_statusbar321, ahk_id %MainWndID%
		Menu, ControlMenu2, Enable, Status bar
		}
	else
;		Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%
; don't use the above - it makes restored controls disappear, in Tab control
		GuiControl, Show, %CtrlNameCount%
	if CtrlNameCount = SysTabControl321
		{
		TabDeleted=
		inTab=0
		}
	IniRead, ItemList, %iniWork%, Main, ItemList
	StringReplace, ItemList, ItemList, |^%CtrlNameCount%|, |%CtrlNameCount%|, A
	IniWrite, %ItemList%, %iniWork%, Main, ItemList
Return
;===========================================
;	CONTROL ALIGNMENT : CENTER HORIZONTALLY
;===========================================
CenterH:
	ControlGetPos,,, cW,, %CtrlNameCount%, ahk_id %MainWndID%
	WinGetPos,,, wW,, ahk_id %MainWndID%

	wW -= %cW%
	wW /= 2

	ControlMove, %CtrlNameCount%, %wW%,,,, ahk_id %MainWndID%
	ControlGetPos, cX, cY, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%

	;get CtrlText
	IniRead, CtrlText, %iniWork%, %CtrlNameCount%, Label
	;fix for title bar & border
	FixCoord(cX, cY)
	Loop, Parse, PosFields
		{
		CurrPos := c%A_LoopField%
		IniWrite, %CurrPos%, %iniWork%, %CtrlNameCount%, %A_LoopField%
		}
Return
;===========================================
;	CONTROL ALIGNMENT : CENTER VERTICALLY
;===========================================
CenterV:
	ControlGetPos,,,, cH, %CtrlNameCount%, ahk_id %MainWndID%
	WinGetPos,,,, wH, ahk_id %MainWndID%

	wH += %WinDiffH%
	wH -= %cH%
	wH /= 2
	wH -= %WinDiffW%

	ControlMove, %CtrlNameCount%,, %wH%,,, ahk_id %MainWndID%
	ControlGetPos, cX, cY, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%

	;get CtrlText
	IniRead, CtrlText, %iniWork%, %CtrlNameCount%, Label
	;fix for title bar & border
	FixCoord(cX, cY)

	Loop, Parse, PosFields
		{
		CurrPos := c%A_LoopField%
		IniWrite, %CurrPos%, %iniWork%, %CtrlNameCount%, %A_LoopField%
		}
Return
;===========================================
;	CONTROL ALIGNMENT : JUSTIFY
;===========================================
Justify:
	IniRead, WhichCtrl, %iniWork%, %CtrlNameCount%, Name
	IfEqual, WhichCtrl, ERROR, Return

	;remove earlier justifications
	IniRead, Options, %iniWork%, %CtrlNameCount%, Options, %A_Space%

	StringReplace, Options, Options, +Left,, All
	StringReplace, Options, Options, +Center,, All
	StringReplace, Options, Options, +Right,, All

	IniWrite, %Options% +%A_ThisMenuItem%, %iniWork%, %CtrlNameCount%, Options

	GuiControl, 1:+%A_ThisMenuItem%, %CtrlNameCount%
	Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%
Return
;===========================================
;	CONTROL CUSTOM OPTIONS
;===========================================
CustomOption:
	IfNotEqual, COptionGUIShown, 1
		{
		Gui, 7:+ToolWindow -Caption +Border
		Gui, 7:Default
		Gui, 7:Color, White, White
		Gui, 7:Add, ComboBox, x7 y9 w200 h190 Sort vNewOption gsubstr,
		Gui, 7:Add, ListView, x7 y+4 w200 h250 -E0x200 +0x8 -Hdr ReadOnly AltSubmit Grid vBulkOption gyankit, Custom option
		Gui, 7:Add, Button, x82 y292 w50 h25 Default, OK
		Gui, 7:Add, Picture, x0 y0 w214 h322 0x400000E hwndhPic7 AltSubmit vsk7 gmoveit,
		hBSkin7 := ILC_FitBmp(hPic7, skin, cSkin)
		if debug
			LogFile("GUI7 skin handle: " hBSkin7, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI7 skin (hBSkin7)", debugout)
		Gui, 7:Add, Groupbox, x3 y-2 w208 h290 +0x8000,
		Gui, 7:Font, s7 cBlue,
		Gui, 7:Add, Text, x6 y291 w74 h26 BackgroundTrans Hidden, SHIFT : multi`nCTRL : pick
		Gui, 7:Add, Text, x134 y291 w74 h26 BackgroundTrans Right Hidden, ALT : -option`nESC : Close
		Gui, 7:Font
		GuiControl, 7:-Redraw, SysListView321
		Loop, Parse, CustomOptions, |
			LV_Add("", A_LoopField)
		LV_ModifyCol(1, "AutoHdr")
		GuiControl, 7:+Redraw, SysListView321
		Gui, 7:Show, w214 h322, Custom Control Option
		WinGet, hGui7, ID, Custom Control Option
		hGuis .= "," hGui7
		if debug
			LogFile("GUI7 handle: " hGui7, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI7 handle (hGui7)", debugout)
		DllCall("SetParent", "UInt", hGui7, "UInt", wpID)
		ControlGet, hEdit, Hwnd,, Edit1, ahk_id %hGui7%
		if debug
			LogFile("Edit handle: " hEdit, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Get Edit1 handle in GUI7 (hEdit)", debugout)
; ultimately, build a preview GUI containing similar control with real-time updated options
		COptionGUIShown = 1
		}
	else, Gui, 7:Show
	NewOption := Options := ""
	Edit2Combo(CtrlNameCount)
	IniRead, Options, %iniWork%, %CtrlNameCount%, Options, %A_Space%%A_Space%
	DllCall("SendMessageA", "UInt", hEdit, "UInt", 0x0C, "UInt", 0, "UInt", &Options)	; WM_SETTEXT
	Gui, 7:Submit, NoHide
	NewOption_TT := Options
	ControlGetPos,,, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%
Return

yankit:
	lastitem := A_EventInfo
	hint := (A_GuiEvent = "K") ? "Show" : "Hide"
	GuiControl, 7:%hint%, Static2
	GuiControl, 7:%hint%, Static3
	if A_GuiEvent not in Normal,DoubleClick
		return
	lvmin := GetKeyState("Alt", "P") ? "-" : "+"
	lvr=
	While lvr := LV_GetNext(lvr)
		{
		LV_GetText(lvso, lvr) ; get ListView selected object
		if i := InStr(NewOption, lvso)
			{
			if j := SubStr(NewOption, i - 1, 1)
				if j in +,-
					if (j != lvmin)
						StringReplace, NewOption, NewOption, %j%%lvso%,
			}
		else NewOption .= A_Space lvmin lvso
		}
	StringReplace, NewOption, NewOption, %A_Space%%A_Space%, %A_Space%, A
	NewOption = %NewOption%
	DllCall("SendMessageA", "UInt", hEdit, "UInt", 0x0C, "UInt", 0, "UInt", &NewOption)
	Gui, 7:Submit, NoHide
	NewOption_TT := NewOption
	if A_GuiEvent = DoubleClick
		goto 7ButtonOK
return

substr:
	savestr = %NewOption%
	Gui, 7:Submit, NoHide
	NewOption_TT := NewOption
return

7ButtonOK:
	Gui, 7:Submit, NoHide
	if !NewOption
		{
		ControlGet, tmpstrg, FindString, %savestr%, ComboBox1, A
		Control, Delete, %tmpstrg%, ComboBox1, A
		return
		}
	ControlGet, tmpstrg, List,, ComboBox1, A
	tmpstrg .= "`n"
	ControlGet, tmplist, List,, SysListView321, A
	tmplist .= tmpstrg "`n"
	Loop, Parse, NewOption, %A_Space%, %A_Space%
		{
		cOpt = %A_LoopField%
		StringLeft, Test, cOpt, 1
		if Test in g
			if StrLen(cOpt) > 1
			{
			StringTrimLeft, Test, cOpt, 1
			IniWrite, %Test%, %iniWork%, %CtrlNameCount%, gLabel
			StringReplace, NewOption, NewOption, %cOpt%
			StringReplace, NewOption, NewOption, %A_Space%%A_Space%, %A_Space%, A
			NewOption = %NewOption%
			}
		}
	GuiControl, 1:%NewOption%, %CtrlNameCount%
	IfNotInString, tmplist, %NewOption%`n
		GuiControl, 7:, ComboBox1, %NewOption%
	if debug
		msgbox, CtrlNameCount=%CtrlNameCount%`nOptions=%NewOption%
	IniWrite, %NewOption%, %iniWork%, %CtrlNameCount%, Options
	IniRead, CtrlType, %iniWork%, %CtrlNameCount%, Type		; see if it's a Picture control
	if CtrlType between 0 and 1								; and if it's a no-label or variable-label
		GuiControl, 1:, %CtrlNameCount%, %placeholder%		; add the placeholder image again
	Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
	GuiControl, 1:MoveDraw, %CtrlNameCount%, w%cW% h%cH%
	Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%
	tmpstrg := tmplist := ""
	Gui, 1:Default
7GuiClose:
7GuiEscape:
	savestr=
	Tooltip,,,, 5
	Gui, 7:Cancel
Return
;===========================================
;	CONTROL FORMAT AND ADD
;===========================================
SelPic:
	gosub ChPicType
	WinWaitClose, ahk_id %hGui13%
	if cptType != 1
		return
SelPic2:
; use a temporary path variable to avoid opening A_ScriptDir on each picture addition
	tpath := DllCall("shlwapi\PathFileExistsA", "Str", OLabel) ? OLabel : A_ScriptDir
	if w9x
		{
		Hotkey9x("LD", "Off")
		FileSelectFile, PicFile,, %tpath%, Select Picture File, Picture Files (*.jpg; *.gif; *.bmp; *.png; *.tif; *.ico; *.ani; *.cur; *.wmf; *.emf)
		err := ErrorLevel
		Hotkey9x("LD", "On")
		}
	else
		{
		Hotkey, *~LButton, Off
		FileSelectFile, PicFile,, %tpath%, Select Picture File, Picture Files (*.jpg; *.gif; *.bmp; *.png; *.tif; *.ico; *.ani; *.cur; *.wmf; *.emf)
		err := ErrorLevel
		Hotkey, *~LButton, On
		}
	CtrlText = %PicFile%
	CtrlType=2
return

;===========================================
;	CHOOSE PICTURE TYPE
;===========================================
ChPicType:
	Gui, 13:+ToolWindow -Caption +Border
	Gui, 13:Color, White, White
	Gui, 13:Font, s8, Tahoma
	Gui, 13:Add, Edit, x20 y55 w254 h22 -Multi BackgroundTrans vcptypem gcptypeL, %OLabel%
	Gui, 13:Add, Button, x88 y88 w100 h24, continue
	Gui, 13:Add, Button, x+10 y88 h24, Cancel
	Gui, 13:Add, Picture, x0 y0 w284 h116 0x400000E hwndhPic13 vsk13 gmoveit,
	hBSkin13 := ILC_FitBmp(hPic13, skin, cSkin)
	if debug
		LogFile("GUI13 skin handle: " hBSkin13, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Create GUI13 skin (hBSkin13)", debugout)
	Gui, 13:Add, GroupBox, x4 y4 w276 h80 +0x8000 BackgroundTrans,
	Gui, 13:Font, s8, Wingdings
	Gui, 13:Add, Text, x8 y18 w12 h16 +0x200 BackgroundTrans vcpt1 gToggleCPT,
	Gui, 13:Add, Text, x8 y36 w12 h16 +0x200 BackgroundTrans vcpt2 gToggleCPT,
	Gui, 13:Font, s8, Tahoma
	Gui, 13:Add, Text, x20 y18 w254 h16 +0x200 BackgroundTrans vcpt3 gToggleCPT
		, Select an actual picture from your drive(s)
	Gui, 13:Add, Text, x20 y36 w254 h16 +0x200 BackgroundTrans vcpt4 gToggleCPT
		, Use a variable name for picture path: (with `%)
	if (!DllCall("shlwapi\PathFileExistsA", "Str", OLabel) OR COvert=1)
		cptType=3
	else cptType=2
	ClickedCtrl=Static%cptType%
	Gui, 13:Show, w284 h116, Choose picture type
	if hGui13
		StringReplace, hGuis, hGuis, `,%hGui13%,,
	WinGet, hGui13, ID, Choose picture type
	hGuis .= "," hGui13
	DllCall("SetParent", "UInt", hGui13, "UInt", wpID)
	if debug
		LogFile("GUI13 handle: " hGui13, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Get GUI13 handle (hGui13)", debugout)
	Gui, 13:Show

ToggleCPT:
	if COvert=1
		return
	StringReplace, cptType, ClickedCtrl, Static,
	cptType-=(1+2*(cptType>3))
	Loop, 2
		GuiControl, 13:, cpt%A_Index%,
	GuiControl, 13:, cpt%cptType%, è
return

cptypeL:
Gui, 13:Submit, NoHide
return

13Buttoncontinue:
Gui, 13:Submit, NoHide
if cptType=2					; if user set a variable name as picture path
	{
;	if (cptypem="")			; check if it's blank and return to script if so,
;		return				; but we may want a blank label so just let it be
	CtrlText = %cptypem%
	PicFile=
	}
Gui, 13:Destroy
CtrlType := cptType="1" ? "2" : cptType="2" ? cptypem="" ? "0" : "1"
ErrorLevel=
return

13ButtonCancel:
cptType=0					; use a trick to tell the script we aborted
PicFile := CtrlText := ""
Gui, 13:Destroy
ErrorLevel=1					; try this instead of cptType=0 above
return
;===========================================
PreCreateCtrl:
	;so that one doesn't select another control to create before placing the previous one
	;this requires all sections to set 'Ctrl2Add =' otherwise the toolbar will get disabled
	IfNotEqual, Ctrl2Add,, Return
	Ctrl2Add := TBCtrl
CreateCtrl:
	Gui, 9:+OwnDialogs
	;only one tab, one statusbar and one main menu allowed
	if (Ctrl2Add = "Menu" && MenuGenerated) OR (Ctrl2Add = "StatusBar" && StatusBarCreated)
		{
		MsgBox,, SmartGUIXP Notification, Sorry, but a %Ctrl2Add% has already been created.`nThere can be no two such controls in one GUI.`n`nYou may right-click the %Ctrl2Add% control to edit it.`n(Win9x users: Right-Click the workspace to edit Menu or Status bar)
		CtrlNameCount := Ctrl2Add = "Menu" ? "Menu1" : Ctrl2Add
		gosub restoreCtrl
		Ctrl2Add =
		Return
		}
	if  (Ctrl2Add = "Tab" && TabCreated)
		{
		CtrlNameCount := "SysTabControl321"
		if TabDeleted
			gosub restoreCtrl
		else
			{
			inTab := !inTab
			TB_BtnSet(hTB99, 17, "s" 4+2*inTab)
			}
		IniRead, ItemList, %iniWork%, Main, ItemList, |
		ItemList .= (inTab ? "TabChange" TabName : "TabNUL") "|"
		IniWrite, %ItemList%, %iniWork%, Main, ItemList
		Ctrl2Add =
		Return
		}
	;default labels
	CtrlText = %Ctrl2Add%
	IfEqual, Ctrl2Add, Tab
		CtrlText = Tab1|Tab2
	IfEqual, Ctrl2Add, Menu
		CtrlText = MyMenu
	IfEqual, Ctrl2Add, StatusBar
		CtrlText = Status bar
	If Ctrl2Add In Progress,Slider
		CtrlText = 25
	If Ctrl2Add In Hotkey,MonthCal,DateTime,TreeView
		CtrlText =

	;preset width & height if not copying control
	IfNotEqual, JustCopy, Y
		{
		CtrlOptions=
		;so that control label is always asked if option is on
		IfEqual, AL, 1
			if Ctrl2Add Not In Picture,Hotkey,MonthCal,DateTime,TreeView,StatusBar,Menu
			{
			InputBox, CtrlText, Label, Enter Control Label,, 250, 125,,,,,%CtrlText%
			IfEqual, ErrorLevel, 1
				{
				Ctrl2Add=
				Return
				}
			}
		StringReplace, CtrlText, CtrlText, ``n, `n, A

		cW = 100
		cH = 30

		IfEqual, Ctrl2Add, MonthCal
			{
			cW = 190
			cH = 160
			}
		If Ctrl2Add In ComboBox,DropDownList,DDL
			{
askrows:
			InputBox, i, List rows, Enter number of rows (Rnn)`nor control height (nn),, 200, 130,,,,, R5
			if (!i OR ErrorLevel)
				CtrlOptions .= " R5"
			else if InStr(i, "R")=1
				CtrlOptions .= " " i
			else if !InStr(i, "R")
				{
				if i is integer
					cH := i
				else goto askrows
				}
			}
		If Ctrl2Add In Progress,Slider
			{
			cW := COvert ? 30 : 100
			cH := COvert ? 100 : 30
			CtrlOptions .= (COvert ? " Vertical" : "")
			COvert=
			}
		If Ctrl2Add In UpDown
			{
			CtrlOptions .= (COvert=1 ? " Horz" : COvert=2 ? " -16" : "")
			COvert=
			}
		IfEqual, Ctrl2Add, Edit
			{
			CtrlOptions .= (COvert ? " +Multi" : " -Multi")
			COvert=
			}
		}

	WinActivate, ahk_id %MainWndID%

	if (inTab && !TabDeleted)
		Gui, 1:Tab, %TabName%
	else if (!inTab && TabCreated)
		Gui, 1:Tab
	if CtrlFont
		{
		IniRead, i, %iniWork%, Font, %CtrlFont%
		if i != ERROR
			FormatFont(i, 1, j)
		}
	;select picture
	IfEqual, Ctrl2Add, Picture
		{
		ErrorLevel=
		;For duplication, file selection isn't reqd
		IfEqual, JustCopy, Y
			CtrlText = %CtrlLabel%
		Else
			{
			if CtrlType=0
				CtrlText =
			else if CtrlType=1
				gosub SelPic
			else if CtrlType=2
				gosub SelPic2
			if ErrorLevel		; this should be valid only when canceling the label dialog in SelPic
				{
				Ctrl2Add =
				return		; or in SelPic2
				}
			}
; must add conversion from absolute to relative path and a new field in the ini to store it. Added CtrlType field.
; Don't use FileExist() to check for valid image coz 9x throws a large error message with %var% labels!
		isValidPath := DllCall("shlwapi\PathFileExistsA", "Str", CtrlText)
		if (CtrlType>1 && !isValidPath)	; maybe we should use ErrorLevel here !
				{
				Ctrl2Add =
				Return
				}
		MouseGetPos, mX, mY
		;fix for title bar & border
		FixCoord(mX, mY)
		trick=										; how stupidly picture won't show if it has 0x200 style !!!
		Loop, Parse, CtrlOptions, %A_Space%, %A_Space%
			if (A_LoopField="+0x200" OR A_LoopField="0x200")
				{
				StringReplace, CtrlOptions, CtrlOptions, %A_LoopField%,,
				trick=1
				break
				}
			else if (A_LoopField & 0x200)
				{
				i := A_LoopField ^ 0x200
				StringReplace, CtrlOptions, CtrlOptions, %A_LoopField%, %i%,
				trick=1
				break
				}
		; AltSubmit allows better picture display through GdiPlus
		; but does not play well with standalone icons (.ico)
		if isValidPath
			{
			Loop, %CtrlText%
				if (InStr(CtrlOptions, "AltSubmit") && A_LoopFileExt = "ico")
					StringReplace, CtrlOptions, CtrlOptions, AltSubmit,,
				else CtrlOptions .= (A_LoopFileExt <> "ico" ? " AltSubmit" : "")
			;no width & height specified to get it at original size initially
; leave room for absolute/relative path transformation
			Gui, 1:Add, %Ctrl2Add%, x%mX% y%mY% %CtrlOptions%, %CtrlText%
			}
		else
			{
			sz := JustCopy="Y" ? " w" cW " h" cH : " w32 h32"
			Gui, 1:Add, %Ctrl2Add%, % "x" mX " y" mY sz " " CtrlOptions, %placeholder%
			}
		if trick
			CtrlOptions .= " +0x200"	; must improve it to bring back combined value
		}
	IfEqual, Ctrl2Add, Tab
		{
		MouseGetPos, mX, mY
		;fix for title bar & border
		FixCoord(mX, mY)
		if CtrlOptions not contains +0x4000000
			CtrlOptions .= " +0x4000000"
		if CtrlOptions not contains +0x2000000
			CtrlOptions .= " +0x2000000"
		; don't use Tab2 here, or it'll hide ALL controls underneath it !!!
		Gui, 1:Add, %Ctrl2Add%, x%mX% y%mY% w250 h100 hwndhTab vTabName gTabGroup, %CtrlText%
		Gui, 1:Tab
		TabCreated = 1
		}

	IfEqual, Ctrl2Add, StatusBar
		{
		SetEnv, CtrlName, StatusBar
		CtrlCount := ++%CtrlName%Count
		; Need to fix deletion - Deletion/restore should automatically fix GUI height
 		MsgBox, 0x43024, Add StatusBar, Change status bar's background color?
		IfMsgBox Yes
			{
			i := ChgColor()
			if ErrorLevel
				i := "Default"
			else
				{
				Menu, SBbkgMenu, Enable, GUI default
				Menu, SBbkgMenu, Enable, System default
				}
			}
		else i := "Default"
		Gui, 1:Add, %Ctrl2Add%, -Theme Background%i% hwndhSB gSBclick, %CtrlText%
		Gui, 1:Hide
		Gui, 1:Show
		Menu, ControlMenu2, Enable, Status bar
		StatusBarCreated=1
		goto write2ini
		}
	IfEqual, Ctrl2Add, Menu
		{
		SetEnv, CtrlName, Menu
		CtrlCount := ++%CtrlName%Count
		menuname := CtrlText
		goto EditMenu
		}
	IfEqual, Ctrl2Add, RichText
		goto EditRTF
	;other controls
	If Ctrl2Add In Button,Checkbox,ComboBox,DateTime,DropDownList,Edit,GroupBox,ListBox,ListView
		,MonthCal,Progress,Radio,Slider,Text,UpDown,Hotkey,TreeView
		{
		if Ctrl2Add in ListView
			if CtrlOptions not contains -0x4000000
				CtrlOptions .= " -0x4000000"
		;duplicate has same label
		IfEqual, JustCopy, Y, SetEnv, CtrlText, %CtrlLabel%

		MouseGetPos, mX, mY
		;fix for title bar & border
		FixCoord(mX, mY)

		;create border for controls on Tab
		i := (TabCreated && inTab) ? " Border" : ""
		Gui, 1:Add, %Ctrl2Add%, x%mX% y%mY% w%cW% h%cH% %CtrlOptions%%i%, %CtrlText%

		;blanking for next duplication
		CtrlLabel =
		}

	Gui, 1:Font, Default %FSet%, %FName%
	Sleep, 100

	;Ctrl2Add contains AHK naming of controls
	;CtrlName contains real (win spy) names without the count suffix
	;CtrlCount contains real names with count

	CtrlName = %Ctrl2Add%
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
	IfEqual, Ctrl2Add, Tab, SetEnv, CtrlName, SysTabControl32
	IfEqual, Ctrl2Add, Text, SetEnv, CtrlName, Static
	IfEqual, Ctrl2Add, TreeView, SetEnv, CtrlName, SysTreeView32
	IfEqual, Ctrl2Add, UpDown, SetEnv, CtrlName, msctls_UpDown32
	;fix for combobox
	IfEqual, Ctrl2Add, ComboBox
		EditCount ++
	CtrlCount := ++%CtrlName%Count

	;Fix to prevent Listview from hiding behind the grid
	If Ctrl2Add in ListView,TreeView
		IfNotEqual, TabCreated, 1
			GuiControl, 1:-0x4000000, %CtrlName%%CtrlCount%

	IfEqual, Ctrl2Add, Picture
		if CtrlType<2
			{
			ControlGetPos, cX, cY, cW, cH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			GuiControl, 1:, %CtrlName%%CtrlCount%, %placeholder%		; add the placeholder image again
			GuiControl, 1:MoveDraw, %CtrlName%%CtrlCount%, w%cW% h%cH%
			}
		else JustCopy=Y					; allow pictures to be added at original size without automatic resizing
										; but only if they are not variables represented by placeholders
	Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%

	Menu, FileMenu, Disable, GUI Stealer
	Menu, FileMenu, Disable, Edit GUI script
Alter:
	GuiControl, 5:, Static6, Control [positioning...]
	WinActivate, ahk_id %MainWndID%
	ctrlOp=1
	if w9x
		{
		Hotkey9x("LD", "Off")
		KeyWait9x("LU")
		}
	else
		{
		Hotkey, *~LButton, Off
		KeyWait, LButton
		}

	Loop
		{
		GetKeyState, LB, LButton
			IfEqual, LB, D, Break
		Sleep, 50
		MouseGetPos, mX, mY
		FixCoord(mX, mY)

		;this seems easier on CPU than 'transform, mod'
		if (ME="0" && !isShift)
			{
			mX := stgX*(mX//stgX)
			mY := stgY*(mY//stgY)
			}

		;if mouse position not changed then no need to do anything
		ControlGetPos, tempX, tempY,,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
		FixCoord(tempX, tempY)
		if (tempX=mX && tempY=mY)
			Continue

		;move control to upper left corner of mouse
		ControlMove, %CtrlName%%CtrlCount%, % mX+WinDiffW, % mY+WinDiffH-WinDiffW,,, ahk_id %MainWndID%

		;update Gui Helper window
		ControlGetPos, ScX, ScY, ScW, ScH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
		FixCoord(ScX, ScY)
		CtrlInfo = %CtrlName%%CtrlCount%`nX:%ScX%`tY:%ScY%`nW:%ScW%`tH:%ScH%
		GuiControl, 5:, Static3, %CtrlInfo%
		Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
		Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
		}

	Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%

	ControlGetPos, cX, cY, cW, cH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%

	;move mouse to control's lower right corner
	cX += %cW%
	cY += %cH%
	IfNotEqual, JustCopy, Y
		{
		MouseMove, %cX%, %cY%
		GuiControl, 5:, Static6, Control [resizing...]
		Sleep, 10
		}
	;wait for mouse button to press to get lower right corner
	if w9x
		KeyWait9x("LU")
	else
		KeyWait, LButton

	;do this only if not duplicating
	IfNotEqual, JustCopy, Y
	Loop
		{
		GetKeyState, LB, LButton
		IfEqual, LB, U
			{
			MouseGetPos, mX2, mY2, CurrID, i
			if (CurrID != MainWndID)
				continue
			FixCoord(mX2, mY2)
			if (ME="0" && !isShift)
				{
				mX2 := stgX*(mX2//stgX)
				mY2 := stgY*(mY2//stgY)
				}
			cW := mX2-mX
			cH := mY2-mY

			;if mouse position not changed then no need to do anything
			ControlGetPos,,, tempW, tempH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			if (tempW=cW && tempH=cH)
				Continue

			;change controls width/height
			ControlMove, %CtrlName%%CtrlCount%,,, %cW%, %cH%, ahk_id %MainWndID%

			;update Gui Helper window
			ControlGetPos, ScX, ScY, ScW, ScH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			FixCoord(ScX, ScY, CurrID)
			CtrlInfo = %CtrlName%%CtrlCount%`nX:%ScX%`tY:%ScY%`nW:%ScW%`tH:%ScH%
			GuiControl, 5:, Static3, %CtrlInfo%

			Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%

			Sleep, 50
			}
		IfEqual, LB, D, Break
		}

	Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	GuiControl, 5:, Static6, Control

	JustCopy = N
	;fix for title bar & border
	FixCoord(mX, mY)

	cX = %mX%
	cY = %mY%
	ctrlOp=
;===========================================
;	WRITE CONTROL DATA TO INI FILE
;===========================================
write2ini:
	IniRead, ItemList, %iniWork%, Main, ItemList, |

	;write these settings if creating a new control
	IfNotInString, ItemList, |%CtrlName%%CtrlCount%|
		{
		Gui, 1:Submit, NoHide
		StringReplace, ItemList, ItemList, |%CtrlName%%CtrlCount%|, |, A
		if inTab && TabChanged && InStr(ItemList, "|SysTabControl32")
			{
			ItemList .= "TabChange" TabName "|"
			TabChanged=
			}
		ItemList .= CtrlName CtrlCount "|"
		ifEqual, CtrlName, SysTabControl32
			ItemList .= "TabNUL|"
		IniWrite, %ItemList%, %iniWork%, Main, ItemList
		IniWrite, %Ctrl2Add%, %iniWork%, %CtrlName%%CtrlCount%, Name
; check to see if it clears the field or deletes it completely; maybe add A_Space for blank CtrlText
		IniWrite, %CtrlText%, %iniWork%, %CtrlName%%CtrlCount%, Label
		IniWrite, %CtrlType%, %iniWork%, %CtrlName%%CtrlCount%, Type
		if CtrlOptions
			IniWrite, %CtrlOptions%, %iniWork%, %CtrlName%%CtrlCount%, Options
		if CtrlFont
			IniWrite, %CtrlFont%, %iniWork%, %CtrlName%%CtrlCount%, Font
		}
	ifEqual, CtrlName, Menu
		{
		IniWrite, %i%, %iniWork%, %CtrlName%%CtrlCount%, Color
		IniWrite, %TVnl%, %iniWork%, %CtrlName%%CtrlCount%, Items
		}
	else ifEqual, CtrlName, StatusBar
		{
		IniWrite, %i%, %iniWork%, %CtrlName%%CtrlCount%, Color
		}
	else Loop, Parse, PosFields
		{
		CurrPos := c%A_LoopField% + (A_LoopField="X")*WinDiffW + (A_LoopField="Y")*(WinDiffH-WinDiffW-(menuH+1)*MenuVis)
		IniWrite, %CurrPos%, %iniWork%, %CtrlName%%CtrlCount%, %A_LoopField%
		}

	CtrlText =
	CtrlName =
	Ctrl2Add =
	CtrlLabel =
	CtrlNameCount =
	CtrlOptions =
	CtrlFont =
	CtrlType =
	PicFile =

	if w9x
		Hotkey9x("LD", "On")
	else
		Hotkey, *~LButton, On
	; update group-move list here
	IfEqual, FirstTimeM, No
		gosub updatectrls
Return
;===========================================
;	RELOAD SCRIPT
;===========================================
Reload:
	FileAppend, , %Temp%\SGUIreload.$$$
	if !ErrorLevel
		Loop
			IfExist, %Temp%\SGUIreload.$$$, break
	IfExist, %iniWork%
		{
		MsgBox, 0x43024, Save before reload, Workspace contains unsaved work.`nIf you reload the application now
		,`nall the work will be lost.`n`nAre you sure you don't want to save?
		IfMsgBox, No, Return
		}
	gosub FinalSave
	gosub cleanup
	Reload
Return
;===========================================
;	EXIT SCRIPT
;===========================================
FinalExit:
	gosub FinalSave
	FileDelete, %Temp%\SGUIreload.$$$
	gosub cleanup
	ExitApp
;===========================================
FinalSave:
	IniDelete, %iniSet%, Settings, AskGUICount
	IniDelete, %iniSet%, Settings, AskGUIName
	IniWrite, %HG%, %iniSet%, Settings, Hide grid
	IniWrite, %AG%, %iniSet%, Settings, AskGUIProp
	IniWrite, %gpos%, %iniSet%, Settings, GuiPosType
	IniWrite, %AL%, %iniSet%, Settings, AskControlLabel
	IniWrite, %ME%, %iniSet%, Settings, MicroEditing
	IniWrite, %SM%, %iniSet%, Settings, ShiftMove
;	IniWrite, %lastmms%, %iniSet%, Settings, MultiselectStyle
;	IniWrite, %lastmmt%, %iniSet%, Settings, MultiselectThick
;	IniWrite, %pencolor%, %iniSet%, Settings, MultiselectColor
	IniWrite, %showBT%, %iniSet%, Settings, ShowToolbarTips
	IniWrite, %showTBT%, %iniSet%, Settings, ShowTrayTip
	IniWrite, %cSkin%, %iniSet%, Settings, SkinFile
	IniWrite, %iGrid%, %iniSet%, Settings, GridFile
	IniWrite, %stgType%, %iniSet%, Settings, Snap to grid Type
	IniWrite, %stgX%, %iniSet%, Settings, Snap to grid H
	IniWrite, %stgY%, %iniSet%, Settings, Snap to grid V
	IniWrite, %SaveDir%, %iniSet%, Folders, SaveDir
	IniWrite, %LoadDir%, %iniSet%, Folders, LoadDir
	IniWrite, %debug%, %iniSet%, Settings, Debug mode
	IniWrite, %useSplash%, %iniSet%, Settings, UseSplash
	IniWrite, %port%, %iniSet%, Settings, Portable
return
;===========================================
;	CLEANUP BEFORE EXIT / RELOAD
;===========================================
cleanup:
	OnMessage(0x112, "")	; WM_SYSCOMMAND
	Loop, Parse, TBctrls, CSV
		{
		StringSplit, i, A_LoopField, |
		f := !i4 ? "Init" i2 : ""
		%f%()
		}
	DllCall("DestroyCursor", "UInt", hCursM)
	DllCall("DestroyCursor", "UInt", hCursN)
	DllCall("DestroyCursor", "UInt", hCursH)
	Loop, Parse, skinlist, CSV
		{
		Gui, %A_LoopField%:Destroy
		if hGui%A_LoopField%
			if !DllCall("DeleteObject", "UInt", hBSkin%A_LoopField%) && debug
				LogFile("Failure deleting handle: " hBSkin%A_LoopField%, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
				, "Delete failure on exit (hBSkin" A_LoopField ")", debugout)
		}
	Gui, 2:Destroy
	Gui, 8:Destroy
	Gui, 9:Destroy
	Gui, 1:Destroy
	if DBB
		if !DllCall("DeleteObject", "UInt", DBB) && debug
			LogFile("Failure deleting brush handle: " DBB, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Delete failure on exit (DBB)", debugout)
	if !DllCall("DeleteObject", "UInt", hSkin) && debug
		LogFile("Failure deleting skin handle: " hSkin, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Delete failure on exit (hSkin)", debugout)
	if !DllCall("DeleteObject", "UInt", hBack) && debug
		LogFile("Failure deleting background handle: " hBack, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Delete failure on exit (hBack)", debugout)
	if hBSpl
		if !DllCall("DeleteObject", "UInt", hBSpl) && debug
			LogFile("Failure deleting splash handle: " hBSpl, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Delete failure on exit (hBSpl)", debugout)
	if hFont
		if !DllCall("DeleteObject", "UInt", hFont) && debug
			LogFile("Failure deleting font handle: " hFont, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Delete failure on exit (hFont)", debugout)
	MenuBitmap()
	MenuSkin()
	IL_Destroy(skin)
	TrayIcon("-1", MenuWndID)
	IfExist, %TempDir%
		FileRemoveDir, %TempDir%, 1
Return
;===========================================
;	SAVE OPTIONS BEFORE EXIT / RELOAD
;===========================================
GuiClose:
9GuiClose:
	IfNotExist, %iniWork%
		goto FinalExit
	ExitAfterSave = 1
SaveGUI:
	IfNotEqual, SaveGUIShown, 1
		{
		Gui, 8:+Owner1 +ToolWindow -Caption +Border +AlwaysOnTop
		Gui, 8:Color, White, White
		Gui, 8:Font, s8 Bold, Tahoma
		Gui, 8:Add, Button, x15 y105 w80 h23, Exit
		Gui, 8:Add, Button, x+10 yp w80 h23, Cancel
		Gui, 8:Add, Picture, x0 y0 w200 h133 0x400000E hwndhPic8 vsk8 gmoveit,
		hBSkin8 := ILC_FitBmp(hPic8, skin, cSkin)
		if debug
			LogFile("GUI8 skin handle: " hBSkin8, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI8 skin (hBSkin8)", debugout)
		Gui, 8:Add, GroupBox, x5 y0 w190 h100 +0x8000 BackgroundTrans,
		Gui, 8:Add, Text, x10 y14 w180 h23 +0x200 Center Border BackgroundTrans cRed gsaveType, Save New GUI to Clipboard
		Gui, 8:Add, Text, x10 y+5 w180 h23 +0x200 Center Border BackgroundTrans cGreen gsaveType, Save New GUI to File
		Gui, 8:Add, Text, x10 y+5 w180 h23 +0x200 Center Border BackgroundTrans cBlue gsaveType, Save Modified GUI Info to File
		Gui, 8:Show, h133 w200, Save Options
		WinGet, hGui8, ID, Save Options
		hGuis .= "," hGui8
		if debug
			LogFile("GUI8 handle: " hGui8, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI8 handle (hGui8)", debugout)
		SaveGUIShown = 1
		}

	Gui, 8:Show
Return

SaveGUI2:
	IfExist, %SaveAsFile%, IfNotEqual, SaveAsFile, %TempDir%\Generated.ahk
		Goto, GenerateGUI
	IfEqual, SaveAsFile, %TempDir%\Generated.ahk, IfNotEqual, LastFileSaved,
		{
		SetEnv, SaveAsFile, %LastFileSaved%
		Goto, GenerateGUI
		}
	Goto, SaveGUI
Return

8ButtonCancel:
	Gui, 8:Cancel
Return

8ButtonExit:
	Gui, 8:Submit
	IfEqual, ExitAfterSave, 1
		Goto, FinalExit
Return

; SaveGUI 1=clipboard, 2=new file, 3=modified file
saveType:
StringReplace, SaveGUI, ClickedCtrl, Static,
SaveGUI--
savefile:
	Gui, 8:Submit
	Gui, 9:+OwnDialogs
	SaveAsFile =

	IfNotEqual, SaveGUI, 1
		{
		if w9x
			{
			Hotkey9x("LD", "Off")
			FileSelectFile, SaveAsFile, S16, %SaveDir%, Save generated GUI script as:, AutoHotkey Script (*.ahk)
			Hotkey9x("LD", "On")
			}
		else
			{
			Hotkey, *~LButton, Off
			FileSelectFile, SaveAsFile, S16, %SaveDir%, Save generated GUI script as:, AutoHotkey Script (*.ahk)
			Hotkey, *~LButton, On
			}
		if (!SaveAsFile OR ErrorLevel="1")
			{
			IfNotEqual, ExitAfterSave, 1
				return
			MsgBox, 0x43023, Save before exit, Workspace contains unsaved work.`nIf you exit the application now
			,`nall the work will be lost.`n`nAre you sure you don't want to save?
			IfMsgBox No
				goto savefile
			IfMsgBox Cancel
				return
			}
		}

	IfNotEqual, SaveAsFile,
		{
		SplitPath, SaveAsFile,, SaveDir, Ext,Spos
		Ext := Ext ? "." Ext : ""
		; assume a filename might contain periods so don't discard last name chunk as being an extension
		IfNotEqual, Ext, .ahk, SetEnv, SaveAsFile, %SaveAsFile%%Ext%.ahk
		}
	Gosub, GenerateGUI

	IfEqual, ExitAfterSave, 1
		Goto, FinalExit
Return
;===========================================
;	'SAVE' HOTKEY
;===========================================
;~F9::
HKSave:
	IfWinNotActive, ahk_id %MainWndID%,,
		IfWinNotActive, ahk_id %MenuWndID%,,
			{
			if w9x
				{
				Hotkey, F9, Off
				SendInput {F9}
				Hotkey, F9, On
				}
			Return
			}
TestGUI:
	SaveGUI = 2
	SaveAsFile = %TempDir%\Generated.ahk
	RunSaved = 1
	Gosub, GenerateGUI
Return
;===========================================
;	GENERATE FINAL SCRIPT
;===========================================
GenerateGUI:
	;SaveGui
	;1 = clipboard
	;2 = gui script
	;3 = complete script

	IfNotEqual, SaveGUI, 1, IfExist, %SaveAsFile%
		{
		FileDelete, %SaveAsFile%
		if ErrorLevel
			{
			MsgBox, 0x43011, %appname% error, Destination file in use:`n%SaveAsFile%`n`nPlease close the file, then press`nOK to continue or Cancel to abort save
			IfMsgBox, Cancel, return
			}
		goto GenerateGUI
		}
	TabGenerated = 0
	TabDeleted = 0
	MenuGenerated = 0
	IniRead, ItemList, %iniWork%, Main, ItemList, |
	IfEqual, ItemList, |, Return
	;fixes for title bar & border
	gpos := gpos ? gpos : 2
	WinGetPos, wX, wY, wW, wH, ahk_id %MainWndID%
	GuiPos := gpos=2 ? " Center" : gpos=3 ? " xCenter y" wY : gpos=4 ? " x" wX " yCenter" : " x" wX " y" wY
	wW -= 2*WinDiffW
	wH -= menuH*MenuVis+WinDiffH
	x := wX, y := wY
; show final GUI adjustments window here
	IfEqual, AG, 1
		IfNotEqual, SaveAsFile, %TempDir%\Generated.ahk
			goto finalAdj
; resume thereafter
resumeGenerate:
	if GUICount
		GUICountA = %GUICount%:
	GUIName := GUIName ? GUIName : GeneratedWnd
	;recording that Tab is generated
	IfInString, ItemList, |SysTabControl
		TabGenerated = 1
	IfInString, ItemList, |^SysTabControl
		TabDeleted = 1

	;recording that Menu is generated
	IfInString, ItemList, |Menu
		MenuGenerated = 1
	FinalScript := k := ""
	MenuPassed=0	; fix for wrong Y in controls added before Menu (used below)
	IniRead, dFont, %iniWork%, Font, 0, |||||||	; get default GUI font
	lastFont := dFont
	isFont=
	IfEqual, SaveGUI, 3
		FinalScript = %BeforeScript%`n
	Loop, Parse, ItemList, |
		{
		IfEqual, A_LoopField,, Continue
		IfInString, A_LoopField, ^, Continue
		CtrlNameCount = %A_LoopField%

		;tab selection detection
		IfInString, CtrlNameCount, TabChange
			{
			StringReplace, Count, CtrlNameCount, TabChange,, A
			if !TabDeleted
				FinalScript = %FinalScript%Gui`, %GUICountA%Tab`, %Count%`n
			Continue
			}
		IfInString, CtrlNameCount, TabNUL
			{
			if !TabDeleted
				FinalScript = %FinalScript%Gui`, %GUICountA%Tab`n
			Continue
			}

		IniRead, Ctrl2Add, %iniWork%, %CtrlNameCount%, Name
		IniRead, CtrlText, %iniWork%, %CtrlNameCount%, Label, %A_Space%
		IniRead, i, %iniWork%, %CtrlNameCount%, Color, %A_Space%
		;show % in labels as literal text
		StringReplace, CtrlText, CtrlText, ````, ``, A
		StringReplace, CtrlText, CtrlText, ```%, `%, A	; attempt to fix nasty "Windows cannot find the file `%blabla`% "
		IfInString, CtrlNameCount, Menu
			{
			IniRead, menuItems, %iniWork%, %CtrlNameCount%, Items
			IfEqual, menuItems, ERROR, Continue
			Gui, 1:Default
			if i
				menuStr .= "Menu, " CtrlText ", Color, " i "`n"
			FinalScript .= menuStr "Gui, " GUICountA "Menu, " CtrlText "`n"
			MenuPassed=1
			Continue
			}
		Loop, Parse, PosFields
			IniRead, c%A_LoopField%, %iniWork%, %CtrlNameCount%, %A_LoopField%, %A_Space%

		IniRead, Options, %iniWork%, %A_LoopField%, Options, %A_Space%
		IniRead, gLabel, %iniWork%, %A_LoopField%, gLabel, %A_Space%
		IniRead, cFont, %iniWork%, %A_LoopField%, Font, %dFont%
		IniRead, CtrlType, %iniWork%, %A_LoopField%, Type, %A_Space%
		if cFont not in %lastFont%
			{
			IniRead, j, %iniWork%, Font, %cFont%, %dFont%
			lastFont := cFont
			chF=1
			}
		if chF
			{
			StringSplit, i, j, |
			FN := i7
			FC := i8
			FS := (i1 ? "s" i1 : "") (i2 ? " c" i2 : "") (i3 ? " w" i3 : "") (i4 ? " " i4 : "") (i5 ? " " i5 : "") (i6 ? " " i6 : "")
			StringReplace, FS, FS, %A_Space%%A_Space%, %A_Space%, All
			FS = %FS%
			FinalScript .= (isFont ? "Gui, " GUICountA "Font`n" : "") (FS OR FN ? "Gui, " GUICountA "Font, " FS ", " FN "`n" : "")
			isFont=1
			chF=
			}
		if gLabel
			Options = %Options% g%gLabel%
		Options = %Options%
		IfInString, CtrlNameCount, StatusBar
			{
			if (i <> "" && i <> "Default")
				Options .= " -Theme +Background" i
			Options = %Options%
			k = Gui`, %GUICountA%Default`n
			IniRead, parts, %iniWork%, StatusBar, Parts, %A_Space%
			if !parts
				parts=1
			else k .= "SB_SetParts(" parts ")`n"
			Loop, Parse, parts, `,, %A_Space%
				{
				IniRead, i, %iniWork%, StatusBar, %A_Index%IconFile, %A_Space%
				IniRead, j, %iniWork%, StatusBar, %A_Index%IconNmb, 1
				if i
					k .= "SB_SetIcon(""" i """, " (j ? j : "1") ", " A_Index ")`n"
				}
			FinalScript = %FinalScript%Gui`, %GUICountA%Add`, %Ctrl2Add%`, %Options%`, %CtrlText%`n
			Continue
			}
		IfInString, CtrlNameCount, Font
			{
			StringReplace, dFont, CtrlNameCount, Font,
			if (dFont=lastFont)
				Continue
			IniRead, j, %iniWork%, Font, %dFont%, |||||||
			chF=1
			Continue
			}
		if Ctrl2Add not in Menu,StatusBar
			{
			coord := (cX<>"" ? "x" cX : "") (cY<>"" ? " y" cY : "") (cW<>"" ? " w" cW : "") (cH<>"" ? " h" cH : "")
			Options = %coord% %Options%
			Options = %Options%
			if (Ctrl2Add="Picture" && CtrlType<2 && SaveAsFile=TempDir "\Generated.ahk")
				CtrlText=%placeholder%
			}
		ifNotEqual, Ctrl2Add, Menu
			{
			IfEqual, Ctrl2Add, Tab, SetEnv, Ctrl2Add, Tab2
			FinalScript = %FinalScript%Gui`, %GUICountA%Add`, %Ctrl2Add%`, %Options%`, %CtrlText%`n
			}
		}

	FinalScript .= k
	IfEqual, SaveGUI, 3
		{
		IniRead, Title, %iniWork%, Main, Title, %GeneratedWnd%
		FinalScript = %FinalScript%`; Generated using %appname% %version%`n
		FinalScript = %FinalScript%Gui`, %GUICountA%Show`,%GuiPos% w%wW% h%wH%`, %Title%`n
		FinalScript = %FinalScript%%AfterScript%`n
		}

	Else
		{
		FinalScript = %FinalScript%`; Generated using %appname% %version%`n
		Title := AG ? GUIName : GeneratedWnd
		FinalScript = %FinalScript%Gui`, %GUICountA%Show`,%GuiPos% w%wW% h%wH%`, %Title%`n
		FinalScript = %FinalScript%Return`n`n
		GUICount := GUICount = 1 ? "" : GUICount	; fix for "1GuiClose:" not working
		FinalScript = %FinalScript%%GUICount%GuiClose`:`nExitApp`n
		IniWrite, %Title%, %iniWork%, Main, Title
		}
; we check for gLabels against existing labels and create when necessary
; Menu labels have already been taken care of - not in a perfect manner but still...
;******************************************
	labelsEx=
	extraScript=
	Loop, Parse, FinalScript, `n
		{
		i=%A_LoopField%
		if (SubStr(i, 1, 1) = Chr(59))
			continue
		StringSplit, f, i, `;, %A_Space%%A_Tab%
		f1=%f1%
			if (SubStr(f1, 0) = Chr(58))
				labelsEx .= SubStr(f1,1,-1) "|"
		}
	Loop, Parse, menuLabels, |
		if A_LoopField
			ifNotInString, labelsEx, %A_LoopField%|
				extraScript .= "`n" A_LoopField ":`n; Automatic label for Menu commands`nReturn`n"
	IniRead, ItemList, %iniWork%, Main, ItemList, %A_Space%
	Loop, Parse, ItemList, |
		{
		IniRead, gLabel, %iniWork%, %A_LoopField%, gLabel, %A_Space%
		if !gLabel
			continue
		ifNotInString, labelsEx, %gLabel%|
			ifNotInString, menuLabels, %gLabel%|
				extraScript .= "`n`n" gLabel ":`n; Automatic label for gLabel assigned to " A_LoopField "`nReturn`n"
		}
	FinalScript .= extraScript
	IfNotEqual, SaveGUI, 3
		{
		i=
		Loop, Parse, GenGuiOptions, `n, `r
			i .= "Gui, " GuiCountA A_LoopField "`n"
		FinalScript := i FinalScript
		}
;******************************************
	IfEqual, SaveGUI, 1
		ClipBoard = %FinalScript%

	IfNotEqual, SaveGUI, 1
		FileAppend, %FinalScript%, %SaveAsFile%

	IfEqual, RunSaved, 1
		{
		RunSaved =
		Run, %SaveAsFile%,, UseErrorLevel
		}
	IfNotEqual, SaveAsFile, %TempDir%\Generated.ahk, SetEnv, LastFileSaved, %SaveAsFile%
	Ctrl2Add =
Return
;===========================================
;	FINAL GUI ADJUSTMENTS
;===========================================
finalAdj:
	IfNotEqual, FirstTimeFA, No
		{
		Gui, 12:+Owner1 +ToolWindow -Caption +Border
		Gui, 12:Font, s8 Norm, Tahoma
		Gui, 12:Color, White, White
		Gui, 12:Add, Edit, x86 y19 w325 h18 -E0x200 +Border +Multi -0x200040 hwndhEd121 vGUIName gtgcue, %GUIName%
		Gui, 12:Add, Edit, x86 y39 w325 h18 -E0x200 +Border +Multi -0x200040 hwndhEd122 vGUICount gtgcue, %GUICount%
		Gui, 12:Add, DropDownList, x86 y59 w85 h120 R8 AltSubmit vgpos gselGuiPos, Workspace|Centered|H Centered|V Centered|Custom|At cursor
		Gui, 12:Font, s11 w700, Tahoma
		Gui, 12:Add, Edit, x195 y59 w70 h21 -E0x200 +Number +Border +Multi -0x200040 hwndhEd123 gupdXY, 
		Gui, 12:Add, UpDown, x254 y60 w13 h17 +0x4000080 Range-9999-9999 vx gupdXY,
		Gui, 12:Add, Edit, x284 y59 w70 h21 -E0x200 +Number +Border +Multi -0x200040 hwndhEd124 gupdXY, 
		Gui, 12:Add, UpDown, x343 y60 w13 h17 +0x4000080 Range-9999-9999 vy gupdXY,
		Gui, 12:Font
		VarSetCapacity(RECT, 16, 0)
		Loop, 4
			{
			DllCall("SendMessage", "UInt", hEd12%A_Index%, "UInt", 0xB2, "UInt", 0, "UInt", &RECT)	; EM_GETRECT
			NumPut(NumGet(RECT, 4, "Int")+1, RECT, 4, "Int")
			NumPut(NumGet(RECT, 12, "Int")+1, RECT, 12, "Int")
			DllCall("SendMessage", "UInt", hEd12%A_Index%, "UInt", 0xB3, "UInt", 0, "UInt", &RECT)	; EM_SETRECT
			}
		Gui, 12:Add, Button, x361 y59 w50 h21, Retry
		Gui, 12:Add, Button, x170 y90 w80 h30 Default, OK
		Gui, 12:Add, Picture, x0 y0 w420 h124 0x400000E hwndhPic12 vsk12 gmoveit,
		hBSkin12 := ILC_FitBmp(hPic12, skin, cSkin)
		Gui, 12:Add, GroupBox, x5 y5 w410 h80 +0x8007 BackgroundTrans, ;GUI properties
		Gui, 12:Add, Text, x10 y19 w75 h18 +0x200 +Right BackgroundTrans, GUI title :
		Gui, 12:Add, Text, x10 y39 w75 h18 +0x200 +Right BackgroundTrans, Count (Name) :
		Gui, 12:Add, Text, x10 y59 w75 h21 +0x200 +Right BackgroundTrans, Position X.Y :
		Gui, 12:Add, Text, x172 y59 w239 h21 +0x200 +Center +Hidden BackgroundTrans, Place cursor at desired position, then press CTRL
		Gui, 12:Add, Text, x182 y59 w90 h21 +0x200 BackgroundTrans, X :
		Gui, 12:Add, Text, x271 y59 w90 h21 +0x200 BackgroundTrans, Y :
		i := GUIName ? 1 : 0
		Gui, 12:Add, Text, x94 y21 w315 h16 BackgroundTrans Disabled Hidden%i% vgncue, (optional) name displayed in titlebar and taskbar button
		i := GUICount ? 1 : 0
		Gui, 12:Add, Text, x94 y41 w315 h16 BackgroundTrans Disabled Hidden%i% vcncue, (optional) number (1 to 99) for AHK Basic or name for AHK_L
		; Generated using SmartGuiXP Creator mod 4.3.29.0
		Gui, 12:Show, w420 h124, GUI properties
		WinGet, hGui12, ID, GUI properties
		hGuis .= "," hGui12
		FirstTimeFA=No
		}
	Gui, 12:Show
GuiControl, 12:Choose, gpos, ||%gpos%
Return

tgcue:
Gui, 12:Submit, NoHide
GuiControl, % "12:" (GUIName ? "Hide" : "Show"), gncue
GuiControl, % "12:" (GUICount ? "Hide" : "Show"), cncue
return

selGuiPos:
Gui, 12:Submit, NoHide
goto gpos%gpos%
return

gpos1:
GuiControl, 12:Hide, Button1
GuiControl, 12:, Edit3, %wX%
GuiControl, 12:, Edit4, %wY%
GuiControl, 12:, msctls_updown322, %wY%
GuiControl, 12:, msctls_updown321, %wX%
GuiControl, 12:Hide, Static5
GuiControl, 12:, Static6, X :
GuiControl, 12:, Static7, Y :
GuiControl, 12:Show, Static6
GuiControl, 12:Show, Static7
GuiControl, 12:Show, Edit3
GuiControl, 12:Show, Edit4
GuiControl, 12:Show, msctls_updown321
GuiControl, 12:Show, msctls_updown322
GuiPos := " x" wX " y" wY
return

gpos2:
GuiControl, 12:Hide, Button1
GuiControl, 12:Hide, Edit3
GuiControl, 12:Hide, Edit4
GuiControl, 12:Hide, msctls_updown321
GuiControl, 12:Hide, msctls_updown322
GuiControl, 12:Hide, Static5
GuiControl, 12:Show, Static6
GuiControl, 12:Show, Static7
GuiControl, 12:, Static6, X :  Centered
GuiControl, 12:, Static7, Y :  Centered
GuiControl, 12:Show, Static6
GuiControl, 12:Show, Static7
GuiPos := " Center"
return

gpos3:
GuiControl, 12:Hide, Button1
GuiControl, 12:Hide, Edit3
GuiControl, 12:Hide, msctls_updown321
GuiControl, 12:, Edit4, %wY%
GuiControl, 12:, msctls_updown322, %wY%
GuiControl, 12:Show, Edit4
GuiControl, 12:Show, msctls_updown322
GuiControl, 12:, Static6, X :  Centered
GuiControl, 12:, Static7, Y :
GuiControl, 12:Hide, Static5
GuiControl, 12:Show, Static6
GuiControl, 12:Show, Static7
GuiPos := " xCenter y" wY
return

gpos4:
GuiControl, 12:Hide, Button1
GuiControl, 12:Hide, Edit4
GuiControl, 12:Hide, msctls_updown322
GuiControl, 12:, Edit3, %wX%
GuiControl, 12:, msctls_updown321, %wX%
GuiControl, 12:Show, Edit3
GuiControl, 12:Show, msctls_updown321
GuiControl, 12:, Static6, X :
GuiControl, 12:, Static7, Y :  Centered
GuiControl, 12:Hide, Static5
GuiControl, 12:Show, Static6
GuiControl, 12:Show, Static7
GuiPos := " x" wX " yCenter"
return

gpos5:
GuiControl, 12:Hide, Button1
GuiControl, 12:, Edit3, %x%
GuiControl, 12:, Edit4, %y%
GuiControl, 12:Show, Edit3
GuiControl, 12:Show, Edit4
GuiControl, 12:Show, msctls_updown321
GuiControl, 12:Show, msctls_updown322
GuiControl, 12:Hide, Static5
GuiControl, 12:, Static6, X :
GuiControl, 12:, Static7, Y :
GuiControl, 12:Show, Static6
GuiControl, 12:Show, Static7
GuiPos := " x" x " y" y
return

gpos6:
12ButtonRetry:
GuiControl, 12:Hide, Button1
GuiControl, 12:Hide, Edit3
GuiControl, 12:Hide, Edit4
GuiControl, 12:Hide, msctls_updown321
GuiControl, 12:Hide, msctls_updown322
GuiControl, 12:Hide, Static6
GuiControl, 12:Hide, Static7
GuiControl, 12:Show, Static5
GuiControl, 12:, Static6, X :
GuiControl, 12:, Static7, Y :
CoordMode, Mouse, Screen
KeyWait, Control, D
MouseGetPos, x, y
CoordMode, Mouse, Relative
GuiControl, 12:, Edit3, %x%
GuiControl, 12:, Edit4, %y%
GuiControl, 12:, msctls_updown321, %x%
GuiControl, 12:, msctls_updown322, %y%
Gui, 12:Submit, NoHide
GuiControl, 12:Show, Button1
GuiControl, 12:Show, Edit3
GuiControl, 12:Show, Edit4
GuiControl, 12:Show, msctls_updown321
GuiControl, 12:Show, msctls_updown322
GuiControl, 12:Show, Static6
GuiControl, 12:Show, Static7
GuiControl, 12:Hide, Static5
GuiPos := " x" x " y" y
return

12ButtonOK:
Gui, 12:Submit
if gpos in 5,6
	GuiPos := " x" x " y" y
goto resumeGenerate
return

updXY:
Gui, 12:Submit, NoHide
return
;===========================================
;	'ABOUT' WINDOW
;===========================================
About:
	IfNotEqual, FirstTimeA, No
		{
		Gui, 2:+Owner1 -Caption +Border +AlwaysOnTop
		Gui, 2:Color, %menucolor%, %menucolor%
		Gui, 2:Font, S10 CA03410, Tahoma
		Gui, 2:Add, Text, x260 y16 w170 h1 Center, version %version%`n(%type% version)
		Gui, 2:Add, Picture, x16 y16 w230 h130 +0x400000E AltSubmit BackgroundTrans hwndhSpl2 gmoveit,
		Gui, 2:Add, Text, 0x200 Center Border x316 y237 w70 h21 g2ButtonClose, Close
		Gui, 2:Add, Progress, x16 y237 w230 h21 Hidden hwndhPrAbt, 0
		Gui, 2:Add, Text, x16 y237 w230 h21 0x200 Border Center gRelCheck, Check Latest Release
		Gui, 2:Font, Underline C3571AC, Tahoma
		Gui, 2:Add, Text, x260 y52 w170 h18 gSguiHome Center, SmartGUI homepage
		Gui, 2:Add, Text, x260 y70 w170 h18 gAhkHome Center, AutoHotkey homepage
		Gui, 2:Add, Text, x260 y90 w170 h18 gModHome Center, SmartGUI Mod homepage
		Gui, 2:Font, Underline C154D85, Tahoma
		Gui, 2:Add, Text, 0x8000 x260 y114 w170 h18 Center gMail1, ©2004-2006 Rajat
		Gui, 2:Font, S8, Tahoma
		Gui, 2:Add, Text, 0x8000 x260 y133 w170 h14 s7 Center gMail2, ©2009-2012 Drugwash
		Gui, 2:Font, S7 CBlack Norm, Tahoma
		Gui, 2:Add, Text, x10 y155 w416 h75 Center, SmartGUI Creator is freeware.`nIf you use it regularly and would like the project to be kept active`,`nplease visit the homepage and post your comments, suggestions and bug reports.`nA few words of encouragement are always welcome.`n`nPlease do not nag Rajat about features or bugs in the modded version. Thank you!
		Gui, 2:Add, Text, x2 y2 w432 h276 0x7 BackgroundTrans
		DllCall("SendMessage", "UInt", hSpl2, "UInt", 0x172, "UInt", 0, "UInt", hBSpl)	; STM_SETIMAGE, IMAGE_BITMAP
		FirstTimeA = No
		}

	GuiControl, 2:+gRelCheck, Static4
	GuiControl, 2:, Static4, Check Latest Release
	GuiControl, 2:Hide, msctls_progress321
	GuiControl, 2:Show, Static4
	ControlMove, Static1,,,, 1, About..
	Gui, 2:Show, h280 w436 Hide, About..
	hGui2 := WinExist("About..")
	if debug
		LogFile("GUI2 handle: " hGui2, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI2 handle (hGui2)", debugout)
	if A_OSVersion = WIN_95	; Win95 workaround
		Gui, 2:Show
	else
		DllCall("AnimateWindow", "Int", hGui2, "Int", 500, "Int", 0x00020010)
	;nice release counter
	Loop, 40
		{
		ControlMove, Static1,,,, %A_Index%, About..
		Sleep, 100
		}
Return

; AW_BLEND = 0x00080000
; AW_SLIDE = 0x00040000
; AW_ACTIVATE = 0x00020000
; AW_HIDE = 0x00010000
; AW_CENTER = 0x00000010
; AW_VER_NEGATIVE = 0x00000008
; AW_VER_POSITIVE = 0x00000004
; AW_HOR_NEGATIVE = 0x00000002
; AW_HOR_POSITIVE = 0x00000001

2ButtonClose:
2GuiClose:
	gosub hideAbout
	WinActivate, ahk_id %MainWndID%
Return

hideAbout:
	If A_OSVersion in WIN_98,WIN_ME
		DllCall("AnimateWindow", "Int", hGui2, "Int", 500, "Int", 0x00010010)
	else if A_OSVersion not in WIN_95
		DllCall("AnimateWindow", "Int", hGui2, "Int", 500, "Int", 0x00090010)
	else
		Gui, 2:Hide
Return
;===========================================
;	OPEN LINKS
;===========================================
Mail1:
Mail1=mailto:%Rmail%?subject=Comments on SmartGUI Creator
Mail2:
Mail2=mailto:%Dmail%?subject=Comments on %appname%
AhkHome:
SGUIHome:
ModHome:
	i := %A_ThisLabel%
	gosub hideAbout
	Run, %i%,, UseErrorLevel
	e := ErrorLevel
	SetTimer, chkSent, 50
Return

chkSent:
	if WinExist("Comments on SmartGui")
		{
		SetTimer, chkSent, off
		WinWaitClose, Comments on SmartGui
		DllCall("AnimateWindow", "Int", hGui2, "Int", 500, "Int", 0x00020010)
		return
		}
	if !e
		if !WinExist("Problem with Shortcut")
				return
	SetTimer, chkSent, off
	ControlGetText, err, Static2, Problem with Shortcut
	if err
		err .= "`n`n"
	WinClose, Problem with Shortcut
	MsgBox, 0x43010, %appname% error, An error occured while trying to open the link:`n%i%`n`n%err%Please try again later or contact us at:`n• %RMail%`n• %RMail1%`n• %DMail%`n• %DMail1%`n`nSorry for the inconvenience!
	DllCall("AnimateWindow", "Int", hGui2, "Int", 500, "Int", 0x00020010)
Return
;===========================================
;	CHECK LATEST RELEASE
;===========================================
RelCheck:
	GuiControl, 2:, Static4, Please Wait...
	if !len := UrlDownloadToVar(hpage, RelUrl)
		{
		GuiControl, 2:, Static4, System error !
		return
		}
	if InStr(hpage, "<title>Error 404 (Not Found)</title>")
		{
		GuiControl, 2:, Static4, Error 404`: Page not found!
		return
		}
	if InStr(hpage, "<title>500 Internal server error</title>")
		{
		GuiControl, 2:, Static4, Error 500`: Internal server error!
		return
		}
	Pos1 := InStr(hpage, "DOWNLOAD v", 1)+10
	RelInfo := SubStr(hpage, Pos1, InStr(hpage, "</span>", 0, Pos1)-Pos1)
	v := r := 0
	Loop, Parse, version, `.
		v += A_LoopField << (4-A_Index)*8
	Loop, Parse, RelInfo, `.
		r += A_LoopField << (4-A_Index)*8
	if (r > v)
		{
		StringReplace, r, RelInfo, `.,, All
		GuiControl, 2:+gdownUpd, Static4
		GuiControl, 2:, Static4, Download v%RelInfo%
		return
		}
	GuiControl, 2:, Static4, No update !
Return
;===========================================
;	DOWNLOAD UPDATED VERSION
;===========================================
downUpd:
	i := "SmartGuiXP" r ".7z"
	FileSelectFile, newver, S18, %A_ScriptDir%\%i%, Select path and filename to save to:, 7-zip archive (*.7z)
	if (!newver OR ErrorLevel)
		return
	SplitPath, newver,,, e, f
	if !e
		newver .= ".7z"
	else if (e <> "7z")
		newver := f ".7z"
	GuiControl, 2:Hide, Static4
	GuiControl, 2:Show, msctls_progress321
	if !len := UrlDownloadToVar(checkver, DwnUrl i, hPrAbt)
		GuiControl, 2:, Static4, System error !
	else if InStr(checkver, "<title>Error 404 (Not Found)</title>")
		GuiControl, 2:, Static4, Error`: File not found!
	else
		{
		FileCreate(newver, checkver, len)
		GuiControl, 2:, Static4, Download complete!
		}
	GuiControl, 2:Hide, msctls_progress321
	GuiControl, 2:Show, Static4
return
;===========================================
;	GUI HELPER
;===========================================
GuiHelper:
	IfEqual, HelperStatus, 0
		{
		Gui, 5:Hide
		Menu, Options, Uncheck, Show GUI Helper
		SetTimer, GuiHelper, Off
		Return
		}

	IfNotEqual, HelperWnd, No
		{
		Gui, 5:+ToolWindow -Caption +Border
		Gui, 5:Color, White, White
		Gui, 5:Add, Picture, % "x0 y0 w140 h" 170 + 155*debug " +0x400000E AltSubmit hwndhPic5 vsk5 gmoveit",
		hBSkin5 := ILC_FitBmp(hPic5, skin, cSkin)
		if debug
			LogFile("GUI5 skin handle: " hBSkin5, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI5 skin (hBSkin5)", debugout)
		Gui, 5:Add, Groupbox, x2 y10 w136 h40 0x8000 BackgroundTrans,
		Gui, 5:Add, Groupbox, x2 y63 w136 h55 0x8000 BackgroundTrans,
		Gui, 5:Add, Groupbox, x2 y128 w136 h30 0x8000 BackgroundTrans,
		Gui, 5:Add, Text, x8 y20 w120 h30 BackgroundTrans,
		Gui, 5:Add, Text, x8 y73 w120 h45 BackgroundTrans,
		Gui, 5:Add, Text, x8 y138 w120 h20 0x200 BackgroundTrans,
		Gui, 5:Font, CMaroon,
		Gui, 5:Add, Text, x2 y2 w136 h14 Center BackgroundTrans, Window
		Gui, 5:Add, Text, x2 y55 w136 h14 Center BackgroundTrans, Control
		Gui, 5:Add, Text, x2 y120 w136 h14 Center BackgroundTrans, Mouse
		Gui, 5:Font

		if debug
			{
			Gui, 5:Add, Text, x2 y170 w136 h50 BackgroundTrans vdbg1,
			Gui, 5:Add, Text, x2 y+2 w136 h50 BackgroundTrans vdbg2,
			Gui, 5:Add, Text, x2 y+2 w136 h50 BackgroundTrans vdbg3,
			Gui, 5:Show, x2 y2 h325 w140, GUI Helper
			}
		else
			Gui, 5:Show, x2 y2 h170 w140, GUI Helper
		WinGet, hGui5, ID, GUI Helper
		hGuis .= "," hGui5
		if debug
			LogFile("GUI5 handle: " hGui5, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI5 handle (hGui5)", debugout)
		DllCall("SetParent", "UInt", hGui5, "UInt", wpID)
		WinActivate, ahk_id %MenuWndID%
		HelperWnd=No
		}
	IfEqual, HelperStatus, 1
		{
		Gui, 5:Show
		SetTimer, GuiHelper, 500
		HelperStatus = 2
		Menu, Options, Check, Show GUI Helper
		}
	;report mouse position
	MouseGetPos, MouseX, MouseY, CurrID, MCtrl
	FixCoord(MouseX, MouseY, CurrID)
	GuiControl, 5:, Static4, X: %MouseX%  Y:%MouseY%

	;Only return control info from SGUI main window
	IfEqual, CurrID, %MainWndID%
		{
		ControlGetPos, ScX, ScY, ScW, ScH, %MCtrl%, ahk_id %MainWndID%
		FixCoord(ScX, ScY, CurrID)
		WinGetActiveStats, SwT, SwW, SwH, SwX, SwY

		WinInfo = X:%SwX%`tY:%SwY%`t`nW:%SwW%`tH:%SwH%
		CtrlInfo = %MCtrl%`nX:%ScX%`tY:%ScY%`t`nW:%ScW%`tH:%ScH%

		GuiControl, 5:, Static2, %WinInfo%
		if MCtrl
			GuiControl, 5:, Static3, %CtrlInfo%
		}
Return
;===========================================
;	MOVE CONTROL GROUP
;===========================================
MoveGroup:
	IfWinNotActive, ahk_id %MainWndID%,,Return
	if w9x
		Hotkey9x("LD", "Off")
	else
		Hotkey, *~LButton, Off
	FixCoord(sX, sY, CurrID)
	Loop
		{
		GetKeyState, RB, LButton, P
		IfEqual, RB, U, Break
		}
	MouseGetPos, eX, eY, CurrID
	;fix for title bar & border
	FixCoord(eX, eY, CurrID)

	if w9x
		Hotkey9x("LD", "On")
	else
		Hotkey, *~LButton, On

	;check if mouse not moved at all
	TestX = %eX%
	TestY = %eY%
	TestX -= %sX%
	TestY -= %sY%
	IfLess, TestX, 7
		IfLess, TestY, 7
			Return
	Controls2Modify =

	;getting all the controls within selection
	IniRead, ItemList, %iniWork%, Main, ItemList, |

	Loop, Parse, ItemList, |
		{
		If A_LoopField in ,^
			Continue
		CtrlNameCount = %A_LoopField%
		Loop, Parse, PosFields
			{
			IniRead, CurrPos, %iniWork%, %CtrlNameCount%, %A_LoopField%
			Ctrl%A_LoopField% = %CurrPos%
			}

		;now check if it lies in selection
		;if yes add to string
		CtrlW += %CtrlX%
		; DDL and ComboBox have a hidden height and don't get caught in selection so we take visible height
		if CtrlNameCount contains ComboBox
			GuiControlGet, Ctrl, 1:Pos, %CtrlNameCount%
		else CtrlH += %CtrlY%

		;Finally checking if the control is visible
		ControlGet, CtrlVis, Visible,, %CtrlNameCount%, ahk_id %MainWndID%
		IfEqual, CtrlVis, 0, Continue
		IfGreaterOrEqual, CtrlX, %sX%
		IfGreaterOrEqual, CtrlY, %sY%
		IfLessOrEqual, CtrlW, %eX%
		IfLessOrEqual, CtrlH, %eY%
			;Controls2Modify contains real (win spy) names
			Controls2Modify = %Controls2Modify%|%CtrlNameCount%
		}

	;remove leading |
	StringTrimLeft, Controls2Modify, Controls2Modify, 1

	;create gui for first time
	IfNotEqual, FirstTimeM, No
		{
		Gui, 3:+ToolWindow -Caption +Border
		Gui, 3:Color, White, White
		Gui, 3:Add, Groupbox, x22 y-3 w96 h100 0x8007 -Theme BackgroundTrans,
		Gui, 3:Add, Edit, x56 y35 w30 h20 vToMove Center, 10
		Gui, 3:Add, Checkbox, x36 y85 w70 h20 +0x9000 -Theme vShowAdv gMoveAdv, Advanced
		Gui, 3:Add, ListBox, x2 y113 w136 h138 +0x8 vControls2Modify gupdateselection,
		Gui, 3:Font, s12, Wingdings
		Gui, 3:Add, Button, x30 y9 w22 h22 g3UL, % Chr(235)
		Gui, 3:Add, Button, x60 y9 w22 h22 g3U , % Chr(233)
		Gui, 3:Add, Button, x90 y9 w22 h22 g3UR, % Chr(236)
		Gui, 3:Add, Button, x30 y34 w22 h22 g3L , % Chr(231)
		Gui, 3:Add, Button, x30 y59 w22 h22 g3DL, % Chr(237)
		Gui, 3:Add, Button, x60 y59 w22 h22 g3D, % Chr(234)
		Gui, 3:Add, Button, x90 y59 w22 h22 g3DR, % Chr(238)
		Gui, 3:Add, Button, x90 y34 w22 h22 g3R, % Chr(232)
		Gui, 3:Add, Picture, x0 y0 w140 h110 0x0400000E BackgroundTrans hwndhPic3 vsk3 gmoveit,
		hBSkin3 := ILC_FitBmp(hPic3, skin, cSkin)
		if debug
			LogFile("GUI3 skin handle: " hBSkin3, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create GUI3 skin (hBSkin3)", debugout)
		MoveWX = 2
		MoveWY := 2 + 170 + 155*debug
		Gui, 3:Show, x%MoveWX% y%MoveWY% w140 h%mgd%, Move Group
		WinGet, hGui3, ID, Move Group
		hGuis .= "," hGui3
		if debug
			LogFile("GUI3 handle: " hGui3, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI3 handle (hGui3)", debugout)
		DllCall("SetParent", "UInt", hGui3, "UInt", wpID)
		FirstTimeM = No
		}
updatectrls:
	;get complete list of controls and delimit them by |
	WinGet, CtrlList0, ControlList, ahk_id %MainWndID%
	CtrlList =
	LastCtrlCombo = 0

	Loop, Parse, CtrlList0, `n
		{
		;checking if the control is visible
		ControlGet, CtrlVis, Visible,, %A_LoopField%, ahk_id %MainWndID%
		IfEqual, CtrlVis, 0, Continue

		;don't add statusbar, listview headers to listbox
		if A_LoopField contains msctls_statusbar321,SysHeader32
			Continue

		;check for false edit field generated by combobox
		IfEqual, LastCtrlCombo, 1
			IfInString, A_LoopField, Edit
				{
				LastCtrlCombo = 0
				Continue
				}

		IfInString, A_LoopField, ComboBox
			{
			ControlGet, CtrlStyle, Style,, %A_LoopField%, ahk_id %MainWndID%
			Transform, ControlType, BitAnd, %Ctrlstyle%, 0xF
			IfNotEqual, ControlType, 3, SetEnv, LastCtrlCombo, 1
			}

		CtrlList = %CtrlList%|%A_LoopField%
		}

	;now set the list in listbox and select the reqd items
	GuiControl, 3:, ListBox1, %CtrlList%

	Loop, Parse, Controls2Modify, |
		GuiControl, 3:ChooseString, ListBox1, %A_LoopField%
	gosub MoveAdv
	WinActivate, ahk_id %MainWndID%
updateselection:
	Gui, 3:Submit, NoHide
	return

MoveAdv:
	Gui, 3:Submit, NoHide
	WinGetPos, x, y,,, ahk_id %hGui3%
	WinGetPos, bx, by,,, ahk_id %wpID%
	GuiControl, % "3:" (ShowAdv="1" ? "Show" : "Hide"), ListBox1
	mgd := (ShowAdv="1" ? "257" : "110")
	GuiControl, 3:MoveDraw, Static1, % "x0 y0 w140 h" mgd
	WinMove, ahk_id %hGui3%,,x-bx-1,y-by-1,, mgd
return

;AddX and AddY can be negative depending on direction of movement

3UL:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX -= %ToMove%
	AddY -= %ToMove%
	Goto, 3Move

3U:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddY -= %ToMove%
	Goto, 3Move

3UR:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX += %ToMove%
	AddY -= %ToMove%
	Goto, 3Move

3L:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX -= %ToMove%
	Goto, 3Move

3DL:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX -= %ToMove%
	AddY += %ToMove%
	Goto, 3Move

3D:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddY += %ToMove%
	Goto, 3Move

3DR:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX += %ToMove%
	AddY += %ToMove%
	Goto, 3Move

3R:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX += %ToMove%
	Goto, 3Move

3Move:
	IfEqual, AddX, 0, IfEqual, AddY, 0, Return

	;Controls2Modify contains real names (win spy) so read
	;ahk names and position data
	if (drawn OR extDraw)
		DrawFocus(MainWndID, RC)
/*
		{
		hDC := DllCall( "GetDC", "UInt", MainWndID)
		DllCall("DrawFocusRect", "UInt", hDC, "UInt", &RC)
		DllCall("ReleaseDC", "UInt", MainWndID, "UInt", hDC)
		}
*/
	WinGetPos,,, ctrlEL, ctrlET, ahk_id %MainWndID%
	ctrlER := ctrlEB := 0
	Loop, Parse, Controls2Modify, |
		{
		CtrlNameCount = %A_LoopField%
		IniRead, Ctrl2Add, %iniWork%, %CtrlNameCount%, Name

		;get original position
		;adjust it for reqd change
		;move controls to desired place
		ControlGetPos, TempX, TempY, TempW, TempH, %CtrlNameCount%, ahk_id %MainWndID%
		TempX += %AddX%
		TempY += %AddY%
		ControlMove, %CtrlNameCount%, %TempX%, %TempY%,,, ahk_id %MainWndID%
		Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
		Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%

		;fix for title bar & border
		FixCoord(TempX, TempY, MainWndID)
		ctrlEL := Smaller(TempX, ctrlEL)
		ctrlET := Smaller(TempY, ctrlET)
		ctrlER := Bigger(TempX+TempW, ctrlER)
		ctrlEB := Bigger(TempY+TempH, ctrlEB)

		Loop, Parse, PosFields
			{
			CurrPos := Temp%A_LoopField%
			IniWrite, %CurrPos%, %iniWork%, %CtrlNameCount%, %A_LoopField%
			}
		}
	NumPut(ctrlEL-2, RC, 0, "Int")
	NumPut(ctrlET-2, RC, 4, "Int")
	NumPut(ctrlER+2, RC, 8, "Int")
	NumPut(ctrlEB+2, RC, 12, "Int")
	DrawFocus(MainWndID, RC)
;	hDC := DllCall( "GetDC", "UInt", MainWndID)
;	DllCall("DrawFocusRect", "UInt", hDC, "UInt", &RC)
;	DllCall("ReleaseDC", "UInt", MainWndID, "UInt", hDC)
	extDraw=1
	Ctrl2Add =
Return
;===========================================
DrawFocus(hwnd, ByRef rect)
{
hDC := DllCall( "GetDC", "UInt", hwnd)
DllCall("DrawFocusRect", "UInt", hDC, "UInt", &rect)
DllCall("ReleaseDC", "UInt", hwnd, "UInt", hDC)
}
;===========================================
;	SET GUI COUNT
;===========================================
SetGUIcount:
	Gui, 9:+OwnDialogs
	i := A_AutoTrim
	AutoTrim, off
	if w9x
		{
		Hotkey9x("LD", "Off")
		FileSelectFile, GUICountScript, 1, %LoadDir%, Select GUI script to modify, AutoHotkey GUI script (*.ahk)
		Hotkey9x("LD", "On")
		}
	else
		{
		Hotkey, *~LButton, Off
		FileSelectFile, GUICountScript, 1, %LoadDir%, Select GUI script to modify, AutoHotkey GUI script (*.ahk)
		Hotkey, *~LButton, On
		}
	IfNotExist, %GUICountScript%, Return

	InputBox, GUICount, Count, Enter Count to Add (up to 99),, 250, 125,,,,, 2
	IfEqual, ErrorLevel, 1, Return
	IfGreater, GUICount, 99, Return

	FileCopy, %GUICountScript%, %GUICountScript%.Txt, 1
	FileDelete, %GUICountScript%

	Loop, Read, %GUICountScript%.Txt, %GUICountScript%
		{
		ToAppend = %A_LoopReadLine%

		StringSplit, param, ToAppend, `,
		StringReplace, guitest, param1, %a_space%,, All
		StringReplace, guitest, guitest, %a_tab%,, All

		IfEqual, guitest, Gui
			{
			;This strips gui count
			IfEqual, GUICount,
				{
				StringGetPos, cpos, param2, `:
				cpos ++
				StringTrimLeft, TempVar, param2, %cpos%
				StringReplace, TempVar, TempVar, %a_space%,, All
				StringReplace, ToAppend, ToAppend, %param2%, %A_Space%%TempVar%, All
				}

			;this sets gui count
			Else
				{
				;if earlier gui count exists
				IfInString, param2, `:
					{
					StringGetPos, cpos, param2, `:
					cpos ++
					StringTrimLeft, TempVar, param2, %cpos%
					StringReplace, ToAppend, ToAppend, %param2%, %A_Space%%GUICount%`:%TempVar%, All
					}

				;if earlier gui count does not exist
				Else
					{
					StringReplace, TempVar, param2, %a_space%,, All
					StringReplace, ToAppend, ToAppend, %TempVar%, %GUICount%`:%TempVar%, All
					}
				}
			}

		FileAppend, %ToAppend%`n
		}
	AutoTrim, %i%
	GUICountScript =
Return
;===========================================
#include *i %A_ScriptDir%\mod
#include *i mod_ScriptParser.ahk
;===========================================
;	MOUSE ACTIONS : LEFT BUTTON DOUBLE-CLICK
;===========================================
LeftDbl:
	MouseGetPos, TestX, TestY,, CtrlNameCount
	if debug
		GuiControl, 9:, test1, Ctrl: %CtrlNameCount%
	;Don't Move Grid
		IfEqual, TestX, %sX%
			IfEqual, TestY, %sY%
				Goto Modify
	Return
;===========================================
;	MOUSE ACTIONS : LEFT BUTTON
;===========================================
LeftButton:
	IfWinNotActive, ahk_id %MainWndID%,, Return
	dblClk := DllCall("GetDoubleClickTime", "UInt") / 2000
	MouseGetPos, sX, sY, DragStW, CtrlNameCount
	GetKeyState, ShiftState, Shift
	if w9x
		KeyWait9x("LU", dblClk)
	else
		KeyWait, LButton, T%dblClk%

	;lbutton was not kept pressed
	IfNotEqual, ErrorLevel, 1
		if !w9x
		{
		KeyWait, LButton, D T%dblClk%

		;lbutton was not pressed again
		IfEqual, ErrorLevel, 1, Return
		;lbutton was pressed again so its a dbl click
		goto LeftDbl
		}
	GetKeyState, CheckLB, LButton

	;If shift is up and is reqd to be down for move group
	;then return
	IfEqual, ShiftState, U
		IfEqual, SM, 1
			Return

	IfEqual, CheckLB, D
		IfEqual, DragStW, %MainWndID%
			{
			ControlGet, i, Style,, %CtrlNameCount%, ahk_id %MainWndID%
			if (!CtrlNameCount OR SubStr(CtrlNameCount, 1, 15)="SysTabControl32"
			OR (SubStr(CtrlNameCount, 1, 6)="Button" && i&0xF=0x7))
				Goto, MoveGroup
			}
Return
;===========================================
;	MOUSE ACTIONS : RIGHT BUTTON
;===========================================
RightButton:
	MouseGetPos,,, AWID, CtrlNameCount
	IfNotEqual, AWID, %MainWndID%
		{
		if w9x
			Hotkey9x("RD", "Off")
		SendInput, {RButton}
		if w9x
			Hotkey9x("RD", "On")
		Return
		}
	;to show control/GUI menu whether grid is or or off
		If !CtrlNameCount
			Menu, ControlMenu2, Show
		else if CtrlNameCount in msctls_statusbar321
			goto SBclick
		else
			Menu, ControlMenu, Show
Return
;===========================================
;	GUI STEALER
;===========================================
Stealer:
	SplashImage,, W300 H75 B1, Activate Target Window and press F12 or press Escape to Cancel., Select Target Window,

	if w9x
		Loop
		{
		KeyWait9x("Esc", ".01")
		if !ErrorLevel
			{
			SplashImage, Off
			Return
			}
		KeyWait9x("F12", ".01")
		if !ErrorLevel
			{
			SplashImage, Off
			WinGet, WinID, ID, A
			Break
			}
		}
	else Loop
		{
		Input, UserKey, V, {Esc}{F12}
		IfEqual, ErrorLevel, Endkey:Escape
			{
			SplashImage, Off
			Return
			}

		IfEqual, ErrorLevel, Endkey:F12
			{
			SplashImage, Off
			WinGet, WinID, ID, A
			Break
			}

		Sleep, 50
		}

	Menu, FileMenu, Disable, GUI Stealer
	Menu, FileMenu, Disable, Edit GUI script

	WinGet, CtrlList, ControlList, ahk_id %WinID%
	LastCtrlCombo = 0

	Loop, Parse, CtrlList, `n
		{
		CtrlNameCount = %A_LoopField%

		;only process visible controls
		ControlGet, CtrlVis, Visible,, %CtrlNameCount%, ahk_id %WinID%
		IfEqual, CtrlVis, 0, Continue

		;get CtrlName & Count (complete real name)
		gosub splitNC

		;check for false edit field generated by combobox
		IfEqual, LastCtrlCombo, 1
			IfEqual, CtrlName, Edit
				{
				LastCtrlCombo = 0
				Continue
				}

		ControlGetPos, TempX, TempY, TempW, TempH, %CtrlNameCount%, ahk_id %WinID%
txxxx1 := TempX, txxxx2 := TempY
		;fix for title bar & border
		FixCoord(TempX, TempY)	; this might be wrong (kiwichick report)
;msgbox, old coordinates: %txxxx1%x%txxxx2%`nNew coordinates: %TempX%x%TempY%
		ControlGetText, CtrlText, %CtrlNameCount%, ahk_id %WinID%
		ControlGet, CtrlStyle, Style,, %CtrlNameCount%, ahk_id %WinID%
		ControlGet, CtrlExStyle, ExStyle,, %CtrlNameCount%, ahk_id %WinID%
;****************** check if name is accurate (missing 32) *******************
		; Set control's ahk name here   <<----
		Ctrl2Add = %CtrlName%
		IfEqual, CtrlName, SysDateTimePick, SetEnv, Ctrl2Add, DateTime
		IfEqual, CtrlName, msctls_hotkey, SetEnv, Ctrl2Add, Hotkey
		IfEqual, CtrlName, SysListView, SetEnv, Ctrl2Add, ListView
		IfEqual, CtrlName, SysMonthCal, SetEnv, Ctrl2Add, MonthCal
		IfEqual, CtrlName, msctls_progress, SetEnv, Ctrl2Add, Progress
		IfEqual, CtrlName, RichEdit20W, SetEnv, Ctrl2Add, RichEdit
		IfEqual, CtrlName, msctls_trackbar, SetEnv, Ctrl2Add, Slider
		IfEqual, CtrlName, SysTabControl, SetEnv, Ctrl2Add, Tab
		IfEqual, CtrlName, Static, SetEnv, Ctrl2Add, Text
		IfEqual, CtrlName, SysTreeView, SetEnv, Ctrl2Add, TreeView
		IfEqual, CtrlName, msctls_UpDown, SetEnv, Ctrl2Add, UpDown

		AhkStyle =

		;differentiate buttons
		IfEqual, CtrlName, Button
			{
			ControlType =  ; Set default to be blank.

			Transform, ControlType, BitAnd, %CtrlStyle%, 0xF  ; Get the last four bits.

			if ControlType in 2,3,5,6  ; check, autocheck, 3state, auto3state (respectively)
				Ctrl2Add = Checkbox
			else if ControlType in 4,9  ; radio, autoradio (respectively)
				Ctrl2Add = Radio
			else if ControlType = 7  ; GroupBox
				Ctrl2Add = GroupBox
			else ; Normal button, default button, picture button, etc.
				Ctrl2Add = Button
			}

		;differentiate comboboxes
		IfEqual, CtrlName, ComboBox
			{
			ControlType =  ; Set default to be blank.

			Transform, ControlType, BitAnd, %Ctrlstyle%, 0xF  ; Get the last four bits.

			if ControlType = 3  ; DropDownList
				Ctrl2Add = DropDownList
			else
				Ctrl2Add = ComboBox

			IfEqual, Ctrl2Add, ComboBox, SetEnv, LastCtrlCombo, 1
			}

		;differentiate sliders
		IfEqual, CtrlName, msctls_trackbar
			{
			ControlType =  ; Set default to be blank.

			Transform, ControlType, BitAnd, %Ctrlstyle%, 0xF  ; Get the last four bits.

			if ControlType = 2
				AhkStyle = Left

			if ControlType = 4
				AhkStyle = Vertical

			if ControlType = 8
				AhkStyle = Center

			if ControlType = 10
				AhkStyle = Vertical Center

			if ControlType = 11
				AhkStyle = Vertical Center
			}

		StringRight, PicCheck, CtrlText, 4
		If PicCheck In .jpg,.gif,.bmp,.png,.tif,.ico,.ani,.cur,.wmf,.emf
			SetEnv, Ctrl2Add, Picture

		;Only process supported controls
		If Ctrl2Add Not In %ControlsKnown%
			Continue

		ThisCtrlCount := ++%CtrlName%Count
		CtrlNameCount = %CtrlName%%ThisCtrlCount%

		If Ctrl2Add Not In Tab,Menu
			Gui, 1:Add, %Ctrl2Add%, x%TempX% y%TempY% w%TempW% h%TempH% %AhkStyle%, %CtrlText%

		;Special treatment for tab again :(
		;Create only one tab
		IfNotEqual, TabCreated, 1
			IfEqual, Ctrl2Add, Tab
				{
				CtrlText = TabNameHere
				TabCreated = 1
				Gui, 1:Add, %Ctrl2Add%, x%TempX% y%TempY% w%TempW% h%TempH% vTabName gTabGroup, %CtrlText%
				;fix for grid
				;remove WS_CLIPSIBLINGS
				GuiControl, -0x4000000, SysTabControl321
				}

		;for fixing spl chars
		Gosub, FixText

		IniRead, ItemList, %iniWork%, Main, ItemList, |
		IniWrite, %ItemList%%CtrlNameCount%|, %iniWork%, Main, ItemList
		IniWrite, %Ctrl2Add%, %iniWork%, %CtrlNameCount%, Name
		IniWrite, %CtrlText%, %iniWork%, %CtrlNameCount%, Label

		Loop, Parse, PosFields
			{
			CurrPos := Temp%A_LoopField%
			IniWrite, %CurrPos%, %iniWork%, %CtrlNameCount%, %A_LoopField%
			}

		IniRead, Options, %iniWork%, %CtrlNameCount%, Options, %A_Space%
		IniWrite, %Options% %AhkStyle%, %iniWork%, %CtrlNameCount%, Options
		}

	WinGetPos, wX, wY, wW, wH, ahk_id %WinID%
; we don't account for border or size margins here !!!
	WinMove, ahk_id %MainWndID%,, %wX%, %wY%, %wW%, %wH%
	WinActivate, ahk_id %MainWndID%
	Ctrl2Add =
Return

FixText:
	StringReplace, CtrlText, CtrlText, `n, ``n, A
	StringReplace, CtrlText, CtrlText, `%, ```%, A
	StringReplace, CtrlText, CtrlText, `;, ```;, A
	StringReplace, CtrlText, CtrlText, `,, ```,, A
Return
;===========================================
TabGroup:
	TabCount ++
	Gui, 1:Submit, NoHide
	Gui, Tab, %TabName%
	TabChanged=1	; used to get rid of switching redundancy in the ini
Return

TabAdd:
TabMove:
TabRem:
msgbox, not implemented (yet and possibly never).
return
;===========================================
;	DRAG'N'MOVE WINDOW
;===========================================
moveit:
	WinGet, hwnd, ID, A
	MouseGetPos,,,, ClickedCtrl
	if %mouseinmenu%(hwnd)
		return
	else if (hwnd = hGui11)
		{
		if ClickedCtrl in %GOcList%
			{
			DllCall("SetCursor", "UInt", hCursH)
			goto ToggleGO
			}
		}
	else if (hwnd = hGui8)
		{
		if ClickedCtrl in Static2,Static3,Static4
			{
			DllCall("SetCursor", "UInt", hCursH)
			goto saveType
			}
		}
	else if (hwnd = hGui4)
		{
		if ClickedCtrl in Static5,Static6,Static7,Static8,Static9,Static10
			{
			DllCall("SetCursor", "UInt", hCursH)
			goto ToggleSTG
			}
		}
	else if (hwnd = hGui13)
		{
		if ClickedCtrl in Static2,Static3,Static4,Static5
			{
			DllCall("SetCursor", "UInt", hCursH)
			goto ToggleCPT
			}
		}
	DllCall("SetCursor", "UInt", hCursM)
	PostMessage, 0xA1, 2,,, A	; WM_NCLBUTTONDOWN
return
;===========================================
;	GRID / SKIN SELECTOR
;===========================================
ChGrid:
	vartoset=1
	Loop, %skincount%
		{
		j := A_Index+10
		if (A_Index>gridcount)
			{
			GuiControl, 97:Hide, image%A_Index%
			continue
			}
		GuiControl, 97:-Border, image%A_Index%
		hDGrid%A_Index% := ILC_FitBmp(hImg%A_Index%, grid, A_Index)
		if debug
			LogFile("Grid handle " A_Index ": " hDGrid%A_Index%, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Add grid " A_Index " to grid chooser (hDGrid" A_Index ")", debugout)
		}
	GuiControl, 97:Move, Static1, % "x" 4+65*(iGrid-1-8*((iGrid-1)//8)) " y" 4+65*((iGrid-1)//8)
	GuiControl, 97:Move, Static2, % "x" 4+65*(iGrid-1-8*((iGrid-1)//8)) " y" 4+65*((iGrid-1)//8)
	Loop, 8
		GuiControl, 97:Show, gs%A_Index%
	Gui, 97:Show, AutoSize Center
return

ChSkin:
	vartoset=2
	Loop, %skincount%
		{
		j := A_Index+10
		if (A_Index>gridcount)
			GuiControl, 97:Show, image%A_Index%
		GuiControl, 97:-Border, image%A_Index%
		hDSkin%A_Index% := ILC_FitBmp(hImg%A_Index%, skin, A_Index)
		if debug
			LogFile("Skin handle " A_Index ": " hDSkin%A_Index%, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Add skin " A_Index " to skin chooser (hDSkin" A_Index ")", debugout)
		}
	Loop, 8
		GuiControl, 97:Hide, gs%A_Index%
	GuiControl, 97:Move, Static1, % "x" 4+65*(cSkin-1-8*((cSkin-1)//8)) " y" 4+65*((cSkin-1)//8)
	GuiControl, 97:Move, Static2, % "x" 4+65*(cSkin-1-8*((cSkin-1)//8)) " y" 4+65*((cSkin-1)//8)
	Gui, 97:Show, AutoSize Center
return

selimg:
if vartoset=1
	{
	StringReplace, iGrid, A_GuiControl, image,
	if iGrid is not integer
		StringReplace, iGrid, A_GuiControl, gs,
	if !HG
		{
		setGrid(grid, iGrid, DBB, MainWndID)
		if debug
			LogFile("Brush handle: " DBB, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Set new grid brush (DBB)", debugout)
		}
	}
else
	{
	StringReplace, cSkin, A_GuiControl, image,
	if !DllCall("DeleteObject", "UInt", hSkin) && debug
		LogFile("Failure deleting handle: " hSkin, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Cannot delete hSkin in skin chooser", debugout)
	if !DllCall("DeleteObject", "UInt", hBack) && debug
		LogFile("Failure deleting handle: " hBack, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Cannot delete hBack in skin chooser", debugout)
	hSkin := GetBmp(cSkin, skinsz, skin, 100, 0)
	if debug
		LogFile("Skin handle: " hSkin, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create new skin (hSkin)", debugout)
	skincolor := GetPixelColor(hSkin, 0, 1)
	menucolor := SwColor(skincolor)
	tc2 := skincolor
	tc1 := tc2 & 0x007F7F7F
	Gui, 9:Color, %menucolor%, %menucolor%
	Gui, 2:Color, %menucolor%, %menucolor%
	Loop, Parse, skinlist, CSV
		{
		if hBSkin%A_LoopField%
			if !DllCall("DeleteObject", "UInt", hBSkin%A_LoopField%) && debug
				LogFile("Failure deleting handle: " hBSkin%A_LoopField%, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
				, "Cannot delete hBSkin" A_LoopField " in skin chooser", debugout)
		if hGui%A_LoopField%
			hBSkin%A_LoopField% := ILC_FitBmp(hPic%A_LoopField%, skin, cSkin)
		if debug
			LogFile("Skin handle: " hBSkin%A_LoopField%, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Create new skin (hBSkin" A_LoopField ")", debugout)
		WinSet, Redraw,, % "ahk_id " hGui%A_LoopField%
		}
	Menu, Tray, Color, %menucolor%
	Menu, ToolbarMenu, Color, %menucolor%
	Menu, ControlMenu, Color, %menucolor%
	Menu, ControlMenu2, Color, %menucolor%
	Menu, SBmenu, Color, %menucolor%
	Menu, hv, Color, %menucolor%
	Menu, sm, Color, %menucolor%
	Menu, picm, Color, %menucolor%
	Menu, fnt, Color, %menucolor%
	if hBrMenu
		if !DllCall("DeleteObject", "UInt", hBrMenu) && debug
			LogFile("Failure deleting brush handle: " hBrMenu, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
			, "Cannot delete hBrMenu in skin chooser", debugout)
	ControlGetPos,,, w, h,, ahk_id %hRB99%
	hBack := ResizeBmp(hSkin, w, h)
	if debug
		LogFile("Skin handle: " hBack, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create new rebar skin (hBack)", debugout)
	RB_Set(hRB99, 1, "bk" hBack)
	hBrMenu := MenuSkin(hMainMenu, hBack, 0)
	if debug
		LogFile("Brush handle: " hBrMenu, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Create new rebar brush (hBrMenu)", debugout)
	hTBT := TrayIconTip("1", MenuWndID, type " version`, released " release, "1$" appname " " version, "C$" tc1 "$" tc2)
	if debug
		LogFile("Tray balloon handle: " hTBT, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Modify tray balloon colors in skin chooser", debugout)
	ShowBT(1)
	}
97GuiEscape:
	Gui, 97:Hide
	if vartoset=2
		Loop, %skincount%
			if !DllCall("DeleteObject", "UInt", hDSkin%A_Index%) && debug
				LogFile("Failure deleting handle: " hDSkin%A_Index%, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
				, "Cannot delete skin handle hDSkin" A_Index, debugout)
return
;===========================================
;	OPTIONAL MENU EDITOR MODULE
;===========================================
EditMenu:
	#include *i mod_MenuEditor.ahk
	MsgBox, 0x43010, Error, Menu Editor module is missing!
	Ctrl2Add=
return
;===========================================
;	OPTIONAL RICHEDIT MODULE
;===========================================
EditRTF:
	#include *i mod_RichEdit.ahk
	MsgBox, 0x43040, Info, Rich text add/edit.`nWork in progress...
	Ctrl2Add=
return
;===========================================
;	OPTIONAL WIN9X MOUSE HOOK MODULE
;===========================================
w9xstuff:
	#include *i mod_w9xstuff.ahk
	MsgBox, 0x43010, Error, Win9x module is missing!
return
;===========================================
;			FUNCTIONS
;===========================================
;	CLOSE TRAY BALLOON
;===========================================
CloseBT()
{
ShowBT(1)
}
;===========================================
;	FIX MOUSE COORDINATES
;===========================================
FixCoord(ByRef xCoord, ByRef yCoord, hwnd="")
{
Global
xCoord -= WinDiffW
yCoord -= WinDiffH-WinDiffW+menuH*MenuVis*(hwnd=MainWndID)
}
;===========================================
;	COMPARISONS
;===========================================
Smaller(a, b)
{
return r := a < b ? a : b
}

Bigger(a, b)
{
return r := a > b ? a : b
}
;===========================================
;	FORMAT FONT
;===========================================
FormatFont(p, g, ByRef k)
{
StringSplit, i, p, |
j := i7
l := i8
k := (i1 ? "s" i1 : "") (i2 ? " c" i2 : "") (i3 ? " w" i3 : "") " " i4 " " i5 " " i6
k = %k%
StringReplace, k, k, %A_Space%%A_Space%, %A_Space%, All
Gui, %g%:Font
Gui, %g%:Font, %k%, %j%
return j
}
;===========================================
;	HOVER EFFECT in GRID / SKIN SELECTOR
;===========================================
ImgHover(hwnd, ctrl)
{
Global hCursH, vartoset
StringReplace, ctrl, ctrl, Static,,
if (ctrl < (3+8*(vartoset=1)))
	return
DllCall("SetCursor", "UInt", hCursH)
ControlGetPos, X, Y,,, Static1, ahk_id %hwnd%
ControlGetPos, cX, cY,,, Static%ctrl%, ahk_id %hwnd%
if (X != cX-1) OR (Y != cY-1)
	{
	GuiControl, 97:Hide, Static1
	ControlMove, Static1, % cX-1, cY-1,,, ahk_id %hwnd%
	GuiControl, 97:Show, Static1
	}
}
;===========================================
;	HELPER TOOLTIP in GUI7 (CUSTOM OPTIONS)
;===========================================
tooltip()
{
static newT, oldT, _TT
newT := A_GuiControl
If newT in sk7,NewOption,NewTempOption
	{
	if (newT <> oldT)
		{
		ToolTip,,,, 5
		SetTimer, TTtimer, -7000
		ToolTip, % %newT%_TT,,, 5
		oldT := newT
		}
	return
	}
else IfNotInString, newT, Static
	SetTimer, TTtimer, -1500
return
}

TTtimer:
ToolTip,,,, 5
return
;===========================================
;	CREATE / CHANGE GRID BRUSH
;===========================================
setGrid(file, idx, ByRef brush, hwnd="")
{
Global debug, debugout, gridsz
if brush
	if !DllCall("DeleteObject", "UInt", brush) && debug
		LogFile("Failure deleting brush handle: " brush, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Cannot delete brush", debugout)
if idx < 0
	brush := Brush(0, file)
else
	brush := Brush(3, GetBmp(idx, gridsz, file, 101, 0))
if hwnd
	WinSet, Redraw,, ahk_id %hwnd%
}
;===========================================
;	MULTI-SELECT RECTANGLE
;===========================================
drawMS(ctrl, lP, msg, hwnd)
{
Static
Global MainWndID, debug, debugout, RC, drawn, extDraw
Critical
firstRect:
if (msg=0x200 && draw && hwnd=cWin)
	{
	x2 := lP & 0xFFFF
	y2 := lP>>16
	if (x2<x1 OR y2<y1)
		return 1
	hDC := DllCall( "GetDC", "UInt", cWin)
	DllCall("DrawFocusRect", "UInt", hDC, "UInt", &RC)
	NumPut(x2, RC, 8, "Int")
	NumPut(y2, RC, 12, "Int")
	DllCall("DrawFocusRect", "UInt", hDC, "UInt", &RC)
	DllCall("ReleaseDC", "UInt", cWin, "UInt", hDC)
	return 1
	}
if (msg=0x201 && hwnd=MainWndID)
	{
	draw=
	x1 := lP & 0xFFFF
	y1 := lP>>16
	cWin := MainWndID
	DllCall("SetFocus", "UInt", cWin)
	if drawn OR extDraw
		{
		drawn=
		DrawFocus(cWin, RC)
;		hDC := DllCall( "GetDC", "UInt", cWin)
;		DllCall("DrawFocusRect", "UInt", hDC, "UInt", &RC)
;		DllCall("ReleaseDC", "UInt", cWin, "UInt", hDC)
		DllCall("InvalidateRect", "UInt", cWin, "UInt", 0, "UInt", 1)
		}
	WinGetClass, j, ahk_id %ctrl%
	WinGet, i, Style, ahk_id %ctrl%
	if (!ctrl OR j="SysTabControl32" OR (j="Button" && i&0xF=0x7))
		SetTimer, drawOn, % -DllCall("GetDoubleClickTime")*1.5
	return
	}
if (msg=0x202 && hwnd=cWin)
	{
	SetTimer, drawOn, off
	extDraw=
	if draw
		{
		draw=
		drawn=1
		Tooltip,,,, 2
		return 1
		}
	}
return

drawOn:
draw=1
extDraw=
lP += 0x60006
msg=0x200
VarSetCapacity(RC, 16, 0)
NumPut(x1, RC, 0, "Int")
NumPut(y1, RC, 4, "Int")
NumPut(x1+6, RC, 8, "Int")
NumPut(y1+6, RC, 12, "Int")
DrawFocus(cWin, RC)
;hDC := DllCall( "GetDC", "UInt", cWin)
;DllCall("DrawFocusRect", "UInt", hDC, "UInt", &RC)
;DllCall("ReleaseDC", "UInt", cWin, "UInt", hDC)
MouseMove, 6, 6,, R
Tooltip, drag to select controls to be moved simultaneously, x1, y1, 2
DllCall("SetFocus", "UInt", cWin)
return
}
;===========================================
;	MINI-HELP WINDOW
;===========================================
ShowHelp(mH="0")
{
Global debug, debugout, version, skin, cSkin, sk99, hBSkin99, hPic99, hGui99, wpID, manPath
Static minihelpOn=0, minihelpGUI, i=8
if mH
	IfExist, %manPath%
		{
		Run, %manPath%,, UseErrorLevel
		return
		}
minihelpGUI := !mH & minihelpGUI
minihelpOn := !mH & minihelpOn
if !minihelpGUI
	{
	Gui, 99:Destroy
	Gui, 99:Margin, 10, 10
	Gui, 99:+ToolWindow -Caption +Border +AlwaysOnTop
	Gui, 99:Color, White, White
	; Left side
	Gui, 99:Font, s8 Bold, Tahoma
	Gui, 99:Add, Picture, x0 y0 w100 h100 0x400000E hwndhPic99 vsk99 gmoveit,
	hBSkin99 := ILC_FitBmp(hPic99, skin, cSkin)
	if debug
		LogFile("GUI99 skin handle: " hBSkin99, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc
		, "Create GUI99 skin (hBSkin99)", debugout)
	Gui, 99:Add, Text, xm ym BackgroundTrans Right, This commands help :
	Gui, 99:Add, Text, xp y+2 BackgroundTrans Right, Create control :
	Gui, 99:Add, Text, xp y+2 BackgroundTrans Right, Control settings :
	Gui, 99:Add, Text, xp y+2 BackgroundTrans Right, GUI, Menu, StatusBar :
	Gui, 99:Add, Text, xp y+2 BackgroundTrans Right, Edit Menu items :
	Gui, 99:Add, Text, xp y+2 BackgroundTrans Right, Undelete last control :
	Gui, 99:Add, Text, xp y+2 BackgroundTrans Right, Move controls group :
	Gui, 99:Add, Text, xp y+2 BackgroundTrans Right, GUI preview :
	; Right side
	Gui, 99:Font, Norm
	Gui, 99:Add, Text, x+50 ym BackgroundTrans Section, Help menu | F1 (close by Right-Click | F1)
	Gui, 99:Add, Text, xp y+2 BackgroundTrans, Click toolbar buttons
	Gui, 99:Add, Text, xp y+2 BackgroundTrans, Right-Click respective control
	Gui, 99:Add, Text, xp y+2 BackgroundTrans, Right-Click workspace background
	Gui, 99:Add, Text, xp y+2 BackgroundTrans, F2 | click-pause-click item
	Gui, 99:Add, Text, xp y+2 BackgroundTrans, CTRL+Z
	Gui, 99:Add, Text, xp y+2 BackgroundTrans, Left-Click top/left-most -> drag down-right
	Gui, 99:Add, Text, xp y+2 BackgroundTrans, File menu -> Test Script | F9
	Gui, 99:Show, Hide, SmartGUI mini-help
	GroupAdd, needHelp, SmartGUI mini-help
	Loop, %i%
		{
		ControlGetPos,,, G99cW, G99cH, % "Static" A_Index+1, SmartGUI mini-help
		G99s := G99cW > G99s ? G99cW : G99s
		G99h += G99cH+2
		}
	Loop, %i%
		{
		ControlGetPos,,, G99cW, G99cH, % "Static" A_Index+1+i, SmartGUI mini-help
		G99sa := G99cW > G99sa ? G99cW : G99sa
		G99ha += G99cH+2
		GuiControl, 99:Move, % "Static" A_Index+1+i, % "x" G99s+10+5
		GuiControl, 99:Move, % "Static" A_Index+1, % "w" G99s
		}
	G99s := G99s + G99sa + 5
	Gui, 99:Font, Bold
	if mH
		Gui, 99:Font, cRed
	Gui, 99:Add, Text, xm ym w%G99s% BackgroundTrans Center, % !mH
	? "-= Quick help =-`n-= Main commands in SmartGUI XP Creator " version " =-"
	: "Unfortunately, the main Help manual could not be found.`nPlease refer to the mini-help below, instead."
	Gui, 99:Font, Norm
	G99s += 2*10
	ControlGetPos,,,, G99cH, % "Static" 2*i+2, SmartGUI mini-help
	Loop, % 2*i
		{
		ControlGetPos,, G99y,,, % "Static" A_Index+1, SmartGUI mini-help
		GuiControl, 99:Move, % "Static" A_Index+1, % "y" G99y+G99cH+8
		}
	G99h := (G99h > G99ha ? G99h : G99ha) + 2*10 - 2 + G99cH + 8
	WinMove, SmartGUI mini-help,,,, %G99s%, %G99h%
	GuiControl, 99:Move, Static1, w%G99s% h%G99h%
	minihelpGUI := !mH
	WinGet, hGui99, ID, SmartGUI mini-help
	if debug
		LogFile("GUI99 handle: " hGui99, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI99 handle (hGui99)", debugout)
	DllCall("SetParent", "UInt", hGui99 , "UInt", wpID)
	}
minihelpOn := !minihelpOn
Gui, % "99:" (minihelpOn ? "Show" : "Hide")
}
;**********************************************
99GuiContextMenu:
ShowHelp()
return
;===========================================
;	SHOW / HIDE MAIN WINDOW
;===========================================
showWnd:
hideit(2,0,0, MenuWndID)
return

hideit(wP, lP, msg, hwnd)
{
Global Ctrl2Add, MenuWndID, MainWndID, HelperStatus
Static s=0, winlist="2,3,4,5,6,7,8,10,11,12,13,97,98,99", vislist
if wP != 2	; HTCAPTION
	return
s := !s
Menu, Tray, Rename, % (s ? "Hide" : "Show") " window", % (!s ? "Hide" : "Show") " window"
Gui, % "1:" (s ? "Hide" : "Show")
Gui, % "9:" (s ? "Hide" : "Show")
Loop, Parse, vislist, CSV
	Gui, %A_LoopField%:Show
if s
	{
	vislist=
	Loop, Parse, winlist, CSV
		{
		WinGet, t, Style, % "ahk_id " hGUI%A_LoopField%
		if t & 0x10000000	; WS_VISIBLE
			vislist .= A_LoopField ","
		Gui, %A_LoopField%:Hide
		}
	StringTrimRight, vislist, vislist, 1
	}
if (Ctrl2Add = "Menu" && !s)
	Gui, 10:Show
return 1
}
;===========================================
;	WINDOWPROC HOOK
;===========================================
WPrc(hwnd, uMsg, wParam, lParam)
{
Critical
Global DBB, WPrc0, defGC
if uMsg = 0x136	; WM_CTLCOLORDLG
	{
	DllCall("SetBkMode", "UInt", wParam, "UInt", 0)
	DllCall("SetBkColor", "UInt", wParam, "UInt", defGC)
	return DBB  ; Return the HBRUSH to notify the OS that we altered the HDC.
	}
else if uMsg=0x214	; WM_SIZING
	{
	DllCall("SetBkMode", "UInt", wParam, "UInt", 0)
	DllCall("SetBkColor", "UInt", wParam, "UInt", defGC)
	}
return DllCall("CallWindowProcA", "UInt", WPrc0, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
}
;===========================================
;	WM_MOUSEMOVE HOOK
;===========================================
move(wP, lP, msg, hwnd)
{
Global
Static winid, ctrl, last
isCtrl := (wP & 0x8)		; MK_CONTROL
isShift := (wP & 0x4)	; MK_SHIFT
isLBttn := (wP & 0x1)	; MK_LBUTTON
isRBttn := (wP & 0x2)	; MK_RBUTTON
isMBttn := (wP & 0x10)	; MK_MBUTTON
isXBttn1 := (wP & 0x20)	; MK_XBUTTON1
isXBttn2 := (wP & 0x40)	; MK_XBUTTON2
tooltip()
if (oldWMmove != A_ThisFunc)
	%oldWMmove%(wP, lP, msg, hwnd)
CoordMode, Mouse, Screen
MouseGetPos, x, y, winid, ctrl
CoordMode, Mouse, Relative
if debug
	{
	ofi := A_FormatInteger
	SetFormat, IntegerFast, H
	hwnd+=0
	GuiControl, 55:, Static3, ctrl=%ctrl% hwnd=%hwnd% winid=%winid%
	GuiControl, 55:, Static2, About=%hGUI2% Menu=%hGui10%
	SetFormat, Integer, %ofi%
	}
if (hwnd != last)
	ShowBT(2)
last := hwnd
; change StaticX below to suit the actual control(s)
if (winid=hGui2)
	if ctrl in Static4,Static5,Static6,Static7,Static8,Static9
		DllCall("SetCursor", "UInt", hCursH)
if (winid=hGui4)
	if ctrl in Static5,Static6,Static7,Static8,Static9,Static10
		DllCall("SetCursor", "UInt", hCursH)
if (winid=hGui8)
	if ctrl in Static2,Static3,Static4
		DllCall("SetCursor", "UInt", hCursH)
if (winid=hGui10)
	if ctrl in Static3,Static4,Static5,Static6,SysListView321
		DllCall("SetCursor", "UInt", hCursH)
if (winid=hGui11)
	if ctrl in %GOcList%,SysListView321,SysListView322
		DllCall("SetCursor", "UInt", hCursH)
if (winid=hGui13)
	if ctrl in Static2,Static3,Static4,Static5
		DllCall("SetCursor", "UInt", hCursH)
if (winid=hGui97)
	ImgHover(hGui97, ctrl)
if (winid=MainWndID)
	if drawMS(ctrl, lP, msg, MainWndID)
		return 0
}
;===========================================
;	WM_LBUTTONDOWN HOOK
;===========================================
click(wP, lP, msg, hwnd)
{
Global
MouseGetPos,,,, ctrl, 2
if (hwnd=hTB99)
	ShowBT(2)
else if (hwnd=hTBT)
	ShowBT(1)
else if (hwnd=MainWndID && !ctrlOp)
	if drawMS(ctrl, lP, msg, MainWndID)
		return 0
}
;===========================================
;	WM_LBUTTONUP HOOK
;===========================================
clickup(wP, lP, msg, hwnd)
{
Global
MouseGetPos,,, hwnd2, ctrl, 2
if (hwnd2=MainWndID && !ctrlOp && msg=0x202)
	if drawMS(ctrl, lP, msg, MainWndID)
		return 0
}
;===========================================
;	WM_SYSCOMMAND (DISABLE ALT+F4)
;===========================================
nocls(p1, p2, p3, p4)
{
Global
ofi := A_FormatInteger
SetFormat, IntegerFast, H
p4 := p4
if debug = 2
	msgbox, wParam: %p1%`nlParam: %p2%`nmsg: %p3%`nMsg window handle: %p4%`n`nhGuis: %hGuis%
if (p1 & 0xFFF0) = 0xF060		; SC_CLOSE := 0xF060
	if p4 in %hGuis%,%hGui99%	; add more window handles to hGuis
		{
		SetFormat, Integer, %ofi%
		return 1
		}
SetFormat, Integer, %ofi%
}
;===========================================
;	WM_COMMAND HOOK
;===========================================
comm(wP, lP, msg, hwnd)
{
Global
Local hi, l
hi := wP & 0xFFFF
hi=%hi%
if (lP=hTB99)
	{
	if hi=0x17
		SetTimer, SelectFont, -1
	else
		{
		VarSetCapacity(TBCtrl, 1+DllCall("SendMessage", "UInt", lP, "UInt", 0x42D, "UInt", hi, "UInt", 0), 0)
		DllCall("SendMessage", "UInt", lP, "UInt", 0x42D, "UInt", hi, "UInt", &TBCtrl)	; TB_GETBUTTONTEXTA
		VarSetCapacity(TBCtrl, -1)
		SetTimer, PreCreateCtrl, -1
		}
	}
}
;===========================================
;	WM_NOTIFY HOOK
;===========================================
notif(wP, lP, msg, hwnd2)
{
Local hwnd, code, cmdid, ofi, new, flags, dis, ttl, txt, x, y, ww, wh
Static sh, last, lastw, lasth
hwnd := NumGet(lP+0, 0, "UInt")
code := NumGet(lP+0, 8, "UInt")
cmdid := NumGet(lP+0, 12, "UInt")
ofi := A_FormatInteger
SetFormat, Integer, D
if (hwnd=hTB99)
	 if code=0xFFFFFD3A	; TBN_DROPDOWN
		{
;		msgbox, Dropdown command #%cmdid%
		if cmdid=0x17		; Font item selected
			Menu, fnt, Show
		else
			{
			VarSetCapacity(TBCtrl, 1+DllCall("SendMessage", "UInt", hwnd, "UInt", 0x42D, "UInt", cmdid, "UInt", 0), 0)
			DllCall("SendMessage", "UInt", hwnd, "UInt", 0x42D, "UInt", cmdid, "UInt", &TBCtrl)	; TB_GETBUTTONTEXTA
			VarSetCapacity(TBCtrl, -1)
			if cmdid=0x4	; Edit item selected
				Menu, sm, Show
			else if cmdid=0x7	; Picture item selected
				Menu, picm, Show
			else if cmdid=0x12	; UpDown item selected
				Menu, uhv, Show
			else Menu, hv, Show
			}
		}
	else if code=0xFFFFFD37	; TBN_HOTITEMCHANGE
		{
		new := NumGet(lP+0, 16, "UInt")
		flags := NumGet(lP+0, 20, "UInt")
		if !TB_BtnState(hwnd, new, "e")	; if button is disabled
			dis := "`n(currently not available)"
		if (flags & 0x20)	; HICF_LEAVING
			{
			}
		else if ((flags & 0x1) && (new != last OR lasth != hwnd) && showBT)	; HICF_MOUSE or HICF_ENTERING
			{
			VarSetCapacity(txt, 1+DllCall("SendMessage", "UInt", hwnd, "UInt", 0x42D, "UInt", new, "UInt", 0), 0)
			DllCall("SendMessage", "UInt", hwnd, "UInt", 0x42D, "UInt", new, "UInt", &txt)	; TB_GETBUTTONTEXTA
			VarSetCapacity(txt, -1)
			ttl := 1+2*(dis<>"") "$" (new = 0x17 ? "Set font"
			: (new = 0x16 ? "Add statusbar"
			: (new = 0x15 ? "Add menu"
			: ((new = 0x11 && TabCreated && !TabDeleted) ? "Tab (already created)" : txt " control"))))
			txt := (new = 0x17) ? "Change font settings for future controls.`nFace, style, size and color are allowed." 
			: (new = 0x16 ? "Attach a status bar to current GUI" 
			: (new=0x15 ? "Attach a menu bar to current GUI" 
			: ((new = 0x11 && TabCreated && !TabDeleted) ? (inTab ? "New controls will belong to current Tab" 
			: "New controls will be independent") "`n           (click to toggle option)" 
			: "Add a " txt " control to current GUI" dis)))
			CoordMode, Mouse, Screen
			MouseGetPos, x, y
			CoordMode, Mouse, Relative
			hBT := ShowBT(2, hTB99, txt, ttl, "C$" tc1 "$" tc2) ;" P$" x+15 "$" y+15)
			}
		last := new
		}
if (hwnd=hRB99)
	 if code=0xFFFFFCBE	; RBN_AUTOSIZE
		{
;		msgbox, Resize command #%cmdid%
		}
	else if code=0xFFFFFCB7	; RBN_CHEVRONPUSHED
		{
		msgbox, Chevron command #%cmdid%
		}
	else if code=0xFFFFFCB9	; RBN_CHILDSIZE
		{
;		msgbox, Childsize command #%cmdid%
		y := RB_Get(hwnd, "h")
		if (y != sh)
			{
			WinGetPos,,, ww, wh, % "ahk_id " DllCall("GetAncestor", "UInt", hwnd, "UInt", 1)	; GA_PARENT
			GuiControl, 9:Move, Static1, % "y" y+1 " w" ww-wmh " h" wh-wmv-y-1
			sh := y
			}
		}
lasth := (hwnd != hBT) ? hwnd : lasth
SetFormat, Integer, %ofi%
}
;===========================================
#include %A_ScriptDir%\lib
#include func_Balloon.ahk
#include func_Brush.ahk
#include func_ChgColor.ahk
#include func_FileCreate.ahk
#include func_FontEx.ahk
#include func_ImageList.ahk
#include func_LogFile.ahk
#include func_Menu.ahk
#include func_Rebar.ahk
#include func_Toolbar.ahk
#include func_TrayIcon.ahk
#include func_UrlDownloadToVar.ahk
