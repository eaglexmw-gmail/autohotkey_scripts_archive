; VolOSD GUI
; Generated by SmartGUI Creater
; Created by Drugwash, Oct 2008

version = 1.6 Pro
release = October 8, 2008	; release date
type = internal			; release type can be internal or public
debug = 0				; debug switch (1=active)
;****************************************
; If your keyboard has multimedia buttons for Volume, you can
; try changing the below hotkeys to use them by specifying
; Volume_Up, ^Volume_Up, Volume_Down, and ^Volume_Down
initFile := A_WorkingDir . "\VolOSD.ini"
if A_OSVersion in WIN_95,WIN_98,WIN_ME
	{
	icon = %A_Windir%\sndvol32.exe
	monpath = Enum\MONITOR
	}
else
	{
	icon = %A_Windir%\System32\sndvol32.exe
	monpath = SYSTEM\CurrentControlSet\Enum\DISPLAY
	}
;*************** Default hotkeys Win9x ****************
; (Note: Win9x does not distinguish Left/Right of ALT/CTRL/SHIFT)
	def_hkmUp = ^Up			; CTRL+UpArrow (master up)
	def_hkmDn = ^Down		; CTRL+DownArrow (master down)
	def_hkwUp = ^!Up			; ALT+UpArrow (wave up)
	def_hkwDn = ^!Down		; ALT+DownArrow (wave down)
	def_hkmDim = ^+Up		; CTRL+SHIFT+Up
	def_hkmMut = ^+Down		; CTRL+SHIFT+Down
	def_hkOpt = ^+o			; CTRL+SHIFT+O
	def_hkSC = ^+Enter		; CTRL+SHIFT+Enter
	def_hkExit = ^Backspace	; CTRL+Backspace (exit application)
;*************** Default hotkeys Win2000+ ****************
	def_hkmUp = >^Up		; RCTRL+UpArrow (master up)
	def_hkmDn = >^Down		; RCTRL+DownArrow (master down)
	def_hkwUp = >^!Up		; RALT+UpArrow (wave up)
	def_hkwDn = >^!Down		; RALT+DownArrow (wave down)
	def_hkmDim = >^+Up		; RCTRL+SHIFT+Up
	def_hkmMut = >^+Down	; RCTRL+SHIFT+Down
	def_hkOpt = >^+o			; RCTRL+SHIFT+O
	def_hkSC = >^+Enter		; RCTRL+SHIFT+Enter
	def_hkExit = >^BS			; RCTRL+Backspace (exit application)
;************** User Settings **************
; Make customization only in this area and/or hotkey area only!!
defA = 1				; default soundcard
defAS = 0			; default soundcard selection
defM = 1				; default monitor
defMS = 0			; default monitor selection
defS = 2				; default volume change step (percent)
defD = 10			; default volume when dimmed (percent)
defW = 120			; default progressbar width (px)
defH = 10			; default progressbar height (px)
defCM = FF0000		; default master bar color (hex RGB)
defCW = 0000FF		; default wave bar color (hex RGB)
defCB = C0C0C0		; default bar background color (hex RGB)
defDT = 2000			; default progressbars display time (ms)
;****************************************
gosub initialize
gosub getpos
if ! FileExist(initFile)
	{
	aud_Def := defA		; current soundcard
	aud_DS := defAS		; current soundcard selection
	mon_Def := defM		; current display monitor number (in multi-monitor environments)
	mon_DS := defMS		; current monitor selection (in multi-monitor environments)
	vol_PosX = -1			; default horizontal position (center)
	vol_PosY = -1			; default vertical position (center)
	vol_Step := defS		; current percentage by which to raise or lower the volume each time
	vol_Dim := defD		; current volume when dimmed
	vol_DT := defDT		; current progressbars display time
	vol_Width := defW		; current width of bar
	vol_Thick := defH		; current thickness of bar
	vol_CBM := defCM		; current Master Volume Bar color
	vol_CBW := defCW		; current Wave Volume Bar color
	vol_CW := defCB		; current Background color
	hkm_Up := def_hkmUp	; current hotkey for (master up)
	hkm_Dn := def_hkmDn	; current hotkey for (master down)
	hkw_Up := def_hkwUp	; current hotkey for (wave up)
	hkw_Dn := def_hkwDn	; current hotkey for (wave down)
	hkm_Dim := def_hkmDim	; current hotkey for (master dimmed)
	hkm_Mut := def_hkmMut ; current hotkey for (master mute)
	hk_Opt := def_hkOpt	; current hotkey for (show Options)
	hk_SC := def_hkSC		; current hotkey for (cycle soundcard)
	hk_Exit := def_hkExit	; current hotkey for (exit application)
	}
else
	gosub readini
gosub apphk
gosub createGUI
gosub applyVal
gosub autoex
#SingleInstance, Force
SetBatchLines, 10ms
Return

;********* Auto Execute Section ************* 
; DON'T CHANGE ANYTHING HERE (unless you know what you're doing).
autoex:
vol_BarOptionsMaster = 1:B ZH%vol_Thick% ZX0 ZY0 W%vol_Width% CB%vol_CBM% CW%vol_CW%
vol_BarOptionsWave   = 2:B ZH%vol_Thick% ZX0 ZY0 W%vol_Width% CB%vol_CBW% CW%vol_CW%

; If the X position has been specified, add it to the options.
; Otherwise, omit it to center the bar horizontally:
if vol_PosX >= 0
{
    vol_BarOptionsMaster = %vol_BarOptionsMaster% X%vol_PosX%
    vol_BarOptionsWave   = %vol_BarOptionsWave% X%vol_PosX%
}

; If the Y position has been specified, add it to the options.
; Otherwise, omit it to have it calculated later:
if vol_PosY >= 0
{
    vol_BarOptionsMaster = %vol_BarOptionsMaster% Y%vol_PosY%
    vol_PosY_wave = %vol_PosY%
    vol_PosY_wave += %vol_Thick%
    vol_BarOptionsWave = %vol_BarOptionsWave% Y%vol_PosY_wave%
}
return

;************ Sound changes apply here *************
vol_WaveUp:
Clip =
SoundSet, +%vol_Step%, Wave
Gosub, vol_ShowBars
return

vol_WaveDown:
Clip =
SoundSet, -%vol_Step%, Wave
Gosub, vol_ShowBars
return

vol_MasterUp:
Clip =
SoundSet, +%vol_Step%
Gosub, vol_ShowBars
return

vol_MasterDown:
Clip =
SoundSet, -%vol_Step%
Gosub, vol_ShowBars
return

vol_MasterMute: 
Clip = 
SoundSet, -1, , mute
mutt := mutt=5 ? 4 : 5
gosub getmute
return

vol_Dimmer:
If ! Clip
   { 
   SoundGet, tmp, Master 
   SoundSet, %vol_Dim% 
   Clip = 1 
   } 
Else 
   { 
   SoundSet, %tmp% 
   Clip = 
   } 
Gosub, vol_ShowBars 
return 
;****************** Close & Exit ********************
ButtonCancel:
GuiControl, Disabled, &Cancel
gosub readini
gosub autoex
vol_DT := custDT
goto GuiClose

ButtonOK:
Gui, Submit, NoHide
vol_DT := custDT
if change
	gosub saveini

GuiClose:
gosub apphk
HotKey, %hkm_Up%, on
HotKey, %hkm_Dn%, on
HotKey, %hkw_Up%, on
HotKey, %hkw_Dn%, on
Hotkey, %hkm_Dim%, on
Hotkey, %hkm_Mut%, on
Hotkey, %hk_Opt%, on
Hotkey, %hk_SC%, on
Hotkey, %hk_Exit%, on
gosub vol_BarOff
Gui, Hide
change =
return

getout:
ExitApp

;*************** Display *****************
vol_ShowBars:
gosub getpos	; find the active window's screen and position OSD according to user settings
gosub autoex
; To prevent the "flashing" effect, only create the bar window if it doesn't already exist:

IfWinNotExist, vol_Wave
    Progress, %vol_BarOptionsWave%, , , vol_Wave
;MsgBox, Initial values:`nvolBarOptionsWave=%vol_BarOptionsWave%`nvolWave=%vol_Wave%
IfWinNotExist, vol_Master
{
    ; Calculate position here in case screen resolution changes while
    ; the script is running:
    if vol_PosY < 0
    {
        ; Create the Wave bar just above the Master bar:
        WinGetPos, , vol_Wave_Posy, , , vol_Wave
        vol_Wave_Posy -= %vol_Thick%
        Progress, %vol_BarOptionsMaster% Y%vol_Wave_Posy%, , , vol_Master
    }
    else
        Progress, %vol_BarOptionsMaster%, , , vol_Master
}
; unmute when any of the volume controls is changed (by Drugwash)
if mutt = 4
	{
	SoundSet, 0, , mute
	Menu, Tray, Icon, %icon%, 5,
	mutt := 5
	}
; Get both volumes in case the user or an external program changed them:
gosub getval
Progress, 1:%vol_Master%
Progress, 2:%vol_Wave%
SetTimer, vol_BarOff, %vol_DT%
return

vol_BarOff:
SetTimer, vol_BarOff, off
Progress, 1:Off
Progress, 2:Off
return

initialize:
;********** Find multi-monitor data ***********
SysGet, MonTot, MonitorCount
SysGet, MonAct, 80
SysGet, MonPrim, MonitorPrimary
gosub getmon
;********** Search monitor names ************
SetBatchLines -1
Loop, HKEY_LOCAL_MACHINE, %monpath%, 1, 1
	{
	if a_LoopRegType = key
		value =
	else
		{
		RegRead, value
		if ErrorLevel
			value = *error*
		}
	if (A_LoopRegName = "DeviceDesc")
		{
		num++
		;MsgBox, %a_LoopRegName% = %value% (%a_LoopRegType%)
		MonNam%num% := value
		}
	}

if debug
	MsgBox, Total monitors: %MonTot%`nTotal active monitors: %MonAct%`nPrimary monitor: %MonPrim%`nName1: %MonNam1%`nName2: %MonNam2%`nName3: %MonNam3%`nName4: %MonNam4%`n`n%Mon1Left%,%Mon1Top%`n%Mon2Left%,%Mon2Top%`n%Mon3Left%,%Mon3Top%`n%Mon4Left%,%Mon4Top%
;************* Get mute state **************
getmute:
SoundGet, initM,, mute
mutt := initM="On" ? 4 : 5
Menu, Tray, Icon, %icon%, %mutt%,
getval:
muted := mutt=4 ? "ON" : "OFF"
SoundGet, vol_Master, Master
SoundGet, vol_Wave, Wave
vM := Floor(vol_Master)
vW := Floor(vol_Wave)
Menu, Tray, Tip, Master: %vM%`% � Wave: %vW%`% � Mute is %muted%
return

getmon:
Loop, %MonAct%
	{
	SysGet, coord%A_Index%, MonitorWorkArea, %A_Index%
;	SysGet, MonNam%A_Index%, MonitorName, %A_Index%
	SysGet, Mon%A_Index%, Monitor, %A_Index%
	}
return

getpos:
WinGetPos, ActX, ActY, ActW, ActH, A	; get coords of active window
gosub getmon
Loop, %MonAct%
	if compare(ActX, ActY, ActW, ActH, Mon%A_Index%Left, Mon%A_Index%Top, Mon%A_Index%Right, Mon%A_Index%Bottom)
		{
		gosub autoex
		break
		}
/*
else
Loop, MonAct
	if (Mon%A_Index%Right - centW > 0)
		{
		vol_PosX := Mon%A_Index%Right / 2 - vol_Width / 2
		break
		}
if debug
	MsgBox, You need to calculate position in regard to active window.`nMonitor coords are: %Mon1Left%,%Mon1Top%,%Mon1Right%,%Mon1Bottom%`nCurrent active window coordinates are: %ActX%, %ActY%, %ActW%, %ActH%`nCurrent active window center is %centW%,%centH%
*/
return
; *********** Apply settings (either default or from ini) ********
applyVal:
GuiControl,, m%mon_DS%, 1
gosub ms%mon_DS%
GuiControl,, s%aud_DS%, 1
gosub ss%aud_DS%
change =			; trigger for any change in the options
GuiControl, Disabled, &Cancel
return
; ****************** Apply hotkeys *******************
apphk:
HotKey, %hkm_Up%, vol_MasterUp	; current hotkey for (master up)
HotKey, %hkm_Dn%, vol_MasterDown	; current hotkey for (master down)
HotKey, %hkw_Up%, vol_WaveUp	; current hotkey for (wave up)
HotKey, %hkw_Dn%, vol_WaveDown	; current hotkey for (wave down)
Hotkey, %hkm_Dim%, vol_Dimmer		; current hotkey for (master dimmed)
Hotkey, %hkm_Mut%, vol_MasterMute	; current hotkey for (master mute)
Hotkey, %hk_Opt%, options			; current hotkey for (show Options)
Hotkey, %hk_SC%, cycleCard		; current hotkey for (cycle soundcard)
Hotkey, %hk_Exit%, getout			; current hotkey for (exit application)
return
; **************** Settings *****************
refresh:
gosub vol_BarOff
;gosub autoex
gosub vol_ShowBars
return

options:
HotKey, %hkm_Up%, off
HotKey, %hkm_Dn%, off
HotKey, %hkw_Up%, off
HotKey, %hkw_Dn%, off
Hotkey, %hkm_Dim%, off
Hotkey, %hkm_Mut%, off
Hotkey, %hk_Opt%, off
Hotkey, %hk_SC%, off
Hotkey, %hk_Exit%, off
custDT := vol_DT
vol_DT = 60000
Gui, Show, x228 y9 h338 w335, VolOSD options
gosub vol_ShowBars
return

setW:
if (vol_Width - dimW = 0)
	return
vol_Width := dimW		; set bar width
gosub refresh
change = 1
GuiControl, Enabled, &Cancel
return

resetW:
if (vol_Width - defW = 0)
	return
vol_Width := defW		; reset bar width to default
GuiControl,, dimW, %vol_Width%
gosub refresh
change = 1
GuiControl, Enabled, &Cancel
return

setH:
if (vol_Thick - dimH = 0)
	return
vol_Thick := dimH		; set bar thickness
gosub refresh
change = 1
GuiControl, Enabled, &Cancel
return

resetH:
if (vol_Thick - defH = 0)
	return
vol_Thick := defH		; reset bar thickness to default
GuiControl,, dimH, %vol_Thick%
gosub refresh
change = 1
GuiControl, Enabled, &Cancel
return

resetC:
if ((vol_CBM - defCM = 0) && (vol_CBW - defCW = 0) && (vol_CW - defCB = 0))
	return
vol_CBM := defCM		; reset Master Volume Bar color to default
vol_CBW := defCW		; reset Wave Volume Bar color to default
vol_CW := defCB		; reset Background color to default
GuiControl +Background%vol_CBM%, CBM
GuiControl +Background%vol_CBW%, CBW
GuiControl +Background%vol_CW%, CW
gosub refresh
change = 1
GuiControl, Enabled, &Cancel
return

cycleCard:
card := %card% > 3 ? 1 : ++card
if debug
	MsgBox, card=%card%
return

ms0:
GuiControl, Show, mm1
GuiControl,, mm1, 1
GuiControl, Hide, mm2
GuiControl, Hide, mm3
GuiControl, Hide, mm4
mon_DS = 0
change = 1
GuiControl, Enabled, &Cancel
return

ms1:
Loop, 4
	GuiControl, Hide, mm%A_Index%
mon_DS = 1
change = 1
GuiControl, Enabled, &Cancel
return

ms2:
Loop, 4
	GuiControl, Show, mm%A_Index%
mon_DS = 2
change = 1
GuiControl, Enabled, &Cancel
return

ss0:
change = 1
GuiControl, Enabled, &Cancel
return

ss1:
change = 1
GuiControl, Enabled, &Cancel
return

ss2:
change = 1
GuiControl, Enabled, &Cancel
return

ch:
change = 1
GuiControl, Enabled, &Cancel
return

pickit:
if (A_GuiEvent != "Normal")
	return
if ! CColor(vol_%A_GuiControl%)
	return
colorU := vol_%A_GuiControl%
GuiControl +Background%colorU%, %A_GuiControl%
gosub refresh
change = 1
GuiControl, Enabled, &Cancel
return

theme:
Gui, Submit, NoHide
if themed
	{
custM := vol_CBM
custW := vol_CBW
custB := vol_CW
vol_CBM = Default
vol_CBW = Default
vol_CW = Default
GuiControl, Hide, CBM
GuiControl, Hide, CBW
GuiControl, Hide, CW
GuiControl, Hide, Master:
GuiControl, Hide, Wave:
GuiControl, Hide, Background:
GuiControl, Hide, resetC
	}
else
	{
vol_CBM := custM
vol_CBW := custW
vol_CW := custB
GuiControl, Show, CBM
GuiControl, Show, CBW
GuiControl, Show, CW
GuiControl, Show, Master:
GuiControl, Show, Wave:
GuiControl, Show, Background:
GuiControl, Show, resetC
	}
gosub refresh
change = 1
GuiControl, Enabled, &Cancel
return

;************* INI operations ***************
readini:
IniRead, aud_Def, %initFile%, Hardware, aud_Def
IniRead, aud_DS, %initFile%, Hardware, aud_DS
IniRead, mon_Def, %initFile%, Hardware, mon_Def
IniRead, mon_DS, %initFile%, Hardware, mon_DS
IniRead, vol_PosX, %initFile%, Position, vol_PosX
IniRead, vol_PosY, %initFile%, Position, vol_PosY
IniRead, vol_Step, %initFile%, Ranges, vol_Step
IniRead, vol_Dim, %initFile%, Ranges, vol_Dim
IniRead, vol_DT, %initFile%, Ranges, vol_DT
IniRead, vol_Width, %initFile%, Size, vol_Width
IniRead, vol_Thick, %initFile%, Size, vol_Thick
IniRead, vol_CBM, %initFile%, Colors, vol_CBM
IniRead, vol_CBW, %initFile%, Colors, vol_CBW
IniRead, vol_CW, %initFile%, Colors, vol_CW
IniRead, themed, %initFile%, Colors, themed
IniRead, hkm_Up, %initFile%, Hotkeys, hkm_Up
IniRead, hkm_Dn, %initFile%, Hotkeys, hkm_Dn
IniRead, hkw_Up, %initFile%, Hotkeys, hkw_Up
IniRead, hkw_Dn, %initFile%, Hotkeys, hkw_Dn
IniRead, hkm_Dim, %initFile%, Hotkeys, hkm_Dim
IniRead, hkm_Mut, %initFile%, Hotkeys, hkm_Mut
IniRead, hk_Opt, %initFile%, Hotkeys, hk_Opt
IniRead, hk_SC, %initFile%, Hotkeys, hk_SC
IniRead, hk_Exit, %initFile%, Hotkeys, hk_Exit
return

saveini:
IniWrite, %aud_Def%, %initFile%, Hardware, aud_Def
IniWrite, %aud_DS%, %initFile%, Hardware, aud_DS
IniWrite, %mon_Def%, %initFile%, Hardware, mon_Def
IniWrite, %mon_DS%, %initFile%, Hardware, mon_DS
IniWrite, %vol_PosX%, %initFile%, Position, vol_PosX
IniWrite, %vol_PosY%, %initFile%, Position, vol_PosY
IniWrite, %vol_Step%, %initFile%, Ranges, vol_Step
IniWrite, %vol_Dim%, %initFile%, Ranges, vol_Dim
IniWrite, %vol_DT%, %initFile%, Ranges, vol_DT
IniWrite, %vol_Width%, %initFile%, Size, vol_Width
IniWrite, %vol_Thick%, %initFile%, Size, vol_Thick
IniWrite, %vol_CBM%, %initFile%, Colors, vol_CBM
IniWrite, %vol_CBW%, %initFile%, Colors, vol_CBW
IniWrite, %vol_CW%, %initFile%, Colors, vol_CW
IniWrite, %themed%, %initFile%, Colors, themed
IniWrite, %hkm_Up%, %initFile%, Hotkeys, hkm_Up
IniWrite, %hkm_Dn%, %initFile%, Hotkeys, hkm_Dn
IniWrite, %hkw_Up%, %initFile%, Hotkeys, hkw_Up
IniWrite, %hkw_Dn%, %initFile%, Hotkeys, hkw_Dn
IniWrite, %hkm_Dim%, %initFile%, Hotkeys, hkm_Dim
IniWrite, %hkm_Mut%, %initFile%, Hotkeys, hkm_Mut
IniWrite, %hk_Opt%, %initFile%, Hotkeys, hk_Opt
IniWrite, %hk_SC%, %initFile%, Hotkeys, hk_SC
IniWrite, %hk_Exit%, %initFile%, Hotkeys, hk_Exit
return
;********** Color Picker function *************
CColor(ByRef pColor, hGui=0){ 
;convert from rgb
clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF) 

VarSetCapacity(sCHOOSECOLOR, 0x24, 0) 
VarSetCapacity(aChooseColor, 64, 0) 

NumPut(0x24,			 sCHOOSECOLOR, 0)	; DWORD lStructSize 
NumPut(hGui,			 sCHOOSECOLOR, 4)	; HWND hwndOwner (makes dialog "modal"). 
NumPut(clr,			 sCHOOSECOLOR, 12)	; clr.rgbResult 
NumPut(&aChooseColor, sCHOOSECOLOR, 16)	; COLORREF *lpCustColors 
NumPut(0x00000103,	 sCHOOSECOLOR, 20)	; Flag: CC_ANYCOLOR || CC_RGBINIT 

nRC := DllCall("comdlg32\ChooseColorA", str, sCHOOSECOLOR)  ; Display the dialog. 
if (errorlevel <> 0) || (nRC = 0) 
	return  false 

clr := NumGet(sCHOOSECOLOR, 12) 
oldFormat := A_FormatInteger 
SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

;convert to rgb 
pColor := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16) 
StringTrimLeft, pColor, pColor, 2 
loop, % 6-strlen(pColor) 
	pColor=0%pColor% 
;pColor=0x%pColor%	; not needed here for ListView
SetFormat, integer, %oldFormat% 
return true
}

;************** Find active monitor function ****************
compare(a, b, c, d, e, f, g, h)	; ActX, ActY, ActW, ActH,  MonXLeft, MonXTop, MonXRight, MonXBottom
{
i := a + c // 2	; get center H
j :=  b + d // 2	; get center V
global vol_PosX, vol_PosY, vol_Width, vol_Thick
if ((i - e > 0) && (g - i > 0) && (j - f > 0) && (h - j > 0))
	{
	vol_PosX := e + (g- e) // 2 - (vol_Width // 2)
	vol_PosY := f + (h - f) // 2 - vol_Thick
	return true
	}
else
	return false
}

;******************* GUI creation ***********************
createGUI:
Gui, Add, Tab2, x5 y5 w326 h300 -Wrap -Theme -Background -0x800 0x3040 AltSubmit, Appearance|Hotkeys|Monitor|Soundcard|General|About
Gui, Tab
;Gui, Add, Button, x130 y310 w62 h22 Disabled, &Apply
Gui, Add, Button, x194 y310 w62 h22 Default, &OK
Gui, Add, Button, x258 y310 w62 h22 Disabled, &Cancel
;============== TAB 1 ================
Gui, Tab, 1
Gui, Add, GroupBox, x11 y+5 w310 h135, Size
Gui, Add, Text, x20 y50 w100 h16, Progress bar width:
Gui, Add, Button, x245 yp w62 h22 gresetW, Default
Gui, Add, Slider, x20 y75 w290 h25 vdimW gsetW AltSubmit Range50-500 TickInterval18 ToolTip, %vol_Width%
Gui, Add, Text, x20 y105 w100 h16, Progress bar height:
Gui, Add, Button, x245 yp w62 h22 gresetH, Default
Gui, Add, Slider, x20 y130 w290 h25 vdimH gsetH AltSubmit Range5-30 TickInterval1 ToolTip, %vol_Thick%
Gui, Add, GroupBox, x11 y170 w310 h122, Colors
Gui, Add, Checkbox, x20 y193 w100 h19 vthemed gtheme AltSubmit, Obey OS theme
if ! debug
	if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_2000
		GuiControl, Disabled, themed
Gui, Add, Button, x245 y190 w62 h22 vresetC gresetC, Default
Gui, Add, Text, x180 y218 w60 h14 Right, Master:
Gui, Add, ListView, x+5 yp-3 w60 h20 -E0x200 +Border -hdr +ReadOnly BackgroundFF0000 AltSubmit vCBM gpickit
Gui, Add, Text, x180 y243 w60 h14 Right, Wave:
Gui, Add, ListView, x+5 yp-3 w60 h20 -E0x200 +Border -hdr +ReadOnly Background0000FF AltSubmit vCBW gpickit
Gui, Add, Text, x180 y268 w60 h14 Right, Background:
Gui, Add, ListView, x+5 yp-3 w60 h20 -E0x200 +Border -hdr +ReadOnly BackgroundSilver AltSubmit vCW gpickit
;============== TAB 2 ================
Gui, Tab, 2
Gui, Add, GroupBox, x11 y+5 w310 h260, Hotkeys
Gui, Add, Text, x20 y50 w90 h14 Right, Master up:
Gui, Add, Hotkey, x+5 y47 w170 h20 vhkm_Up gch, %hkm_Up%
Gui, Add, Text, x20 y75 w90 h14 Right, Master down:
Gui, Add, Hotkey, x+5 y72 w170 h20 vhkm_Dn gch, %hkm_Dn%
Gui, Add, Text, x20 y100 w90 h14 Right, Wave up:
Gui, Add, Hotkey, x+5 y97 w170 h20 vhkw_Up gch, %hkw_Up%
Gui, Add, Text, x20 y125 w90 h14 Right, Wave down:
Gui, Add, Hotkey, x+5 y122 w170 h20 vhkw_Dn gch, %hkw_Dn%
Gui, Add, Text, x20 y150 w90 h14 Right, Master dim:
Gui, Add, Hotkey, x+5 y147 w170 h20 vhkm_Dim gch, %hkm_Dim%
Gui, Add, Text, x20 y175 w90 h14 Right, Mute:
Gui, Add, Hotkey, x+5 y172 w170 h20 vhkm_Mut gch, %hkm_Mut%
Gui, Add, Text, x20 y200 w90 h14 Right Disabled, Options:
Gui, Add, Hotkey, x+5 y197 w170 h20 Disabled vhk_Opt gch, %hk_Opt%
Gui, Add, Text, x20 y225 w90 h14 Right Disabled, Cycle soundcards:
Gui, Add, Hotkey, x+5 y222 w170 h20 Disabled vhk_SC gch, %hk_SC%
Gui, Add, Text, x20 y245 w290 h45 Center, Note: The 'Options' hotkey is only available when there is no tray icon. To disable the tray icon, mark 'No tray icon' in the 'General' panel.
;============== TAB 3 ================
Gui, Tab, 3
Gui, Add, GroupBox, x11 y+5 w310 h260, Behavior
Gui, Add, Radio, x20 y50 w290 h18 vm0 gms0 Checked, Always on primary monitor
Gui, Add, Radio, x20 y+2 wp hp vm1 gms1 Disabled, Always follow active window
Gui, Add, Radio, x20 y+2 wp hp vm2 gms2 Disabled, Use the monitor selected below:
Gui, Add, Radio, xp+15 y+5 w280 hp vmm1 Group Checked, %MonNam1%
Gui, Add, Radio, xp y+2 wp hp vmm2 Hidden, %MonNam2%
Gui, Add, Radio, xp y+2 wp hp vmm3 Hidden, %MonNam3%
Gui, Add, Radio, xp y+2 wp hp vmm4 Hidden, %MonNam4%
if MonAct > 1
	Loop, 2
		GuiControl, Enable, m%A_Index%
Gui, Add, Text, x20 y257 w290 h30 Center, Note: Due to OS limitations`, Windows 95 && NT will always display OSD on primary monitor.
;============== TAB 4 ================
Gui, Tab, 4
Gui, Add, GroupBox, x11 y+5 w310 h260, Device control
Gui, Add, Radio, x20 y50 w290 h18 Checked, Always use the following card:
Gui, Add, Radio, x20 y140 wp hp Hidden, Cycle through the following (using hotkey):
Gui, Add, Radio, xp+15 y75 w280 hp vs0 gss0 Group Checked, Soundcard #1
Gui, Add, Radio, xp y+2 wp hp Hidden, vs1 gss1 Soundcard #2
Gui, Add, Radio, xp y+2 wp hp Hidden, vs2 gss2 Soundcard #3
Gui, Add, Checkbox, xp y160 w280 hp Checked Hidden vscard1, Soundcard #1
Gui, Add, Checkbox, xp y+2 wp hp Checked Hidden vscard2, Soundcard #2
Gui, Add, Checkbox, xp y+2 wp hp Checked Hidden vscard3, Soundcard #3
;============== TAB 5 ================
Gui, Tab, 5
Gui, Add, GroupBox, x11 y+5 w310 h100, Detected monitors
Gui, Add, Text, x20 y50 w10 h14, 1.
Gui, Add, Text, x+1 yp w280 h14, %MonNam1%
Gui, Add, Text, x20 y+6 w10 h14, 2.
Gui, Add, Text, x+1 yp w280 h14, %MonNam2%
Gui, Add, Text, x20 y+6 w10 h14, 3.
Gui, Add, Text, x+1 yp w280 h14, %MonNam3%
Gui, Add, Text, x20 y+6 w10 h14, 4.
Gui, Add, Text, x+1 yp w280 h14, %MonNam4%
Gui, Add, GroupBox, x11 y135 w310 h80, Detected soundcards
Gui, Add, Text, x20 yp+18 w10 h14, 1.
Gui, Add, Text, x+1 yp w280 h14, Soundcard #1
Gui, Add, Text, x20 y+6 w10 h14, 2.
Gui, Add, Text, x+1 yp w280 h14, Soundcard #2
Gui, Add, Text, x20 y+6 w10 h14, 3.
Gui, Add, Text, x+1 yp w280 h14, Soundcard #3
Gui, Add, Checkbox, x20 y255 w100 h18, No tray icon
Gui, Add, Checkbox, x20 y275 w200 h18 Checked, Start with Windows
;============== TAB 6 ================
Gui, Tab, 6
Gui, Add, Text, x+10 y50 w295 h14 -Wrap, � Original script by Rajat (presented in AHK Help showcase)
;Gui, Add, Text, xp y+2 wp hp 0x100 -Wrap cBlue, http://www.autohotkey.com/forum/viewtopic.php?t=88
Gui, Add, Text, xp y+2 wp hp -Wrap, � Dimmer solution borrowed from oxymor0n
Gui, Add, Text, xp y+2 wp hp 0x100 -Wrap cBlue, http://www.autohotkey.com/forum/posting.php?mode=quote&p=18505
Gui, Add, Text, xp y+2 wp hp -Wrap, � Color Chooser function extracted from Majkinetor's CmnDlg
Gui, Add, Text, xp y+2 wp hp 0x100 -Wrap cBlue, http://www.autohotkey.com/forum/topic17230.html
Gui, Add, Text, xp y+2 wp hp -Wrap, Licenced under Creative Commons Attribution-Noncommercial
Gui, Add, Text, xp y+2 wp hp 0x100 -Wrap cBlue, http://creativecommons.org/licenses/by-nc/3.0/
Gui, Add, Text, xp y+2 wp hp -Wrap, � Color Picker trigger solution by SKAN
Gui, Add, Text, xp y+2 wp hp -Wrap, � Graphical interface and additional options by Drugwash
Gui, Add, Text, xp y+2 wp hp -Wrap, � Current version: %version% released on %release%
Gui, Tab
;************* Custom tray menu *************
Menu, Tray, Icon
Menu, Tray, NoStandard
Menu, Tray, Add, Settings, options,
Menu, Tray, Default, Settings
Menu, Tray, Add, About, about,
Menu, Tray, Add
Menu, Tray, Add, Exit, getout,
Return
;************** ABOUT box *****************
about:
MsgBox, 64, About,
(
VolOSD %version%
by Drugwash

Released %release%
(%type% version)

This product is open-source.
http://www.autohotkey.com
)
return
