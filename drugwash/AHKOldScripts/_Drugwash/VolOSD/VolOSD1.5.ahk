; VolOSD GUI
; Generated by SmartGUI Creater
; Created by Drugwash, Oct 2008

version = 1.5 Pro
release = October 7, 2008	; release date
type = "internal"			; release type can be internal or public
;****************************************
init := A_WorkingDir . "\VolOSD.ini"
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
gosub initialize
;************** User Settings **************
; Make customization only in this area and/or hotkey area only!!
defS = 2				; default percentage by which to raise or lower the volume each time
defD = 10			; default volume when dimmed (in percent)
defW = 120			; default progressbar width
defH = 10			; default progressbar height
defCM = FF0000		; default master bar color
defCW = 0000FF		; default wave bar color
defCB = C0C0C0		; default bar background color
defDT = 2000			; default progressbars display time
;*************** Hotkeys ****************
; If your keyboard has multimedia buttons for Volume, you can
; try changing the below hotkeys to use them by specifying
; Volume_Up, ^Volume_Up, Volume_Down, and ^Volume_Down:
;HotKey, #Up, vol_MasterUp			; Win+UpArrow
;HotKey, #Down, vol_MasterDown	; Win+DownArrow
HotKey, >^Up, vol_MasterUp		; RCTRL+UpArrow
HotKey, >^Down, vol_MasterDown	; RCTRL+DownArrow
HotKey, ^!Up, vol_WaveUp			; RALT+UpArrow
HotKey, ^!Down, vol_WaveDown		; RALT+DownArrow
Hotkey, >^BS, getout				; RCTRL+Backspace
Hotkey, >^+Up, vol_Dimmer			; RCTRL+SHIFT+Up
Hotkey, >^+Down, vol_MasterMute	; RCTRL+SHIFT+Down
; (Note: Win9x does not distinguish Left/Right of ALT/CTRL/SHIFT)
;****************************************
gosub getpos
if ! FileExist(init)
	{
	vol_Step := defS		; The percentage by which to raise or lower the volume each time
	dimmer := defD		; volume when dimmed (in percent)
	vol_DT := defDT		; progressbars display time
	vol_Width := defW		; width of bar
	vol_Thick := defH		; thickness of bar
	vol_CBM := defCM		; Master Volume Bar color (see the help file to use more precise shades)
	vol_CBW := defCW		; Wave Volume Bar color
	vol_CW := defCB		; Background color
	vol_PosX = -1			; default horizontal position is center
	vol_PosY = -1			; default vertical position is center
	}
else
	readini(init)

gosub createGUI
gosub autoex
#SingleInstance, Force
SetBatchLines, 10ms
Return

autoex:
;********* Auto Execute Section ************* 
; DON'T CHANGE ANYTHING HERE (unless you know what you're doing).

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

;******* Sound changes apply here *******
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
   SoundSet, %dimmer% 
   Clip = 1 
   } 
Else 
   { 
   SoundSet, %tmp% 
   Clip = 
   } 
Gosub, vol_ShowBars 
return 
;*********** Close & Exit ************
getout:
ExitApp

ButtonCancel:
readini(init)
GuiControl, +Disabled, Cancel
GuiControl, +Disabled, Apply
goto GuiClose

ButtonClose:
saveini(init)

GuiClose:
vol_DT := custDT
gosub vol_BarOff
Gui, Hide
return

;*************** DIsplay *****************
vol_ShowBars:
gosub getpos	; find the active window's screen and position OSD according to user settings
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
;****** Find multi-monitor data ******
SysGet, MonTot, MonitorCount
SysGet, MonAct, 80
SysGet, MonPrim, MonitorPrimary
gosub getmon
;******** Search monitor names ********
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

MsgBox, Total monitors: %MonTot%`nTotal active monitors: %MonAct%`nPrimary monitor: %MonPrim%`nName1: %MonNam1%`nName2: %MonNam2%`nName3: %MonNam3%`nName4: %MonNam4%`n`n%Mon1Left%,%Mon1Top%`n%Mon2Left%,%Mon2Top%`n%Mon3Left%,%Mon3Top%`n%Mon4Left%,%Mon4Top%
;************* Get mute state **************
getmute:
SoundGet, init,, mute
mutt := init="On" ? 4 : 5
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
;WinGet, actID, A
WinGetPos, ActX, ActY, ActW, ActH, A	; get coords of active window
gosub getmon
Loop, %MonAct%
	if compare(ActX, ActY, ActW, ActH, Mon%A_Index%Left, Mon%A_Index%Top, Mon%A_Index%Right, Mon%A_Index%Bottom)
		{
		gosub autoex
		break
		}
else
MsgBox, You need to calculate position in regard to active window.`nMonitor coords are: %Mon1Left%,%Mon1Top%,%Mon1Right%,%Mon1Bottom%`nCurrent active window coordinates are: %ActX%, %ActY%, %ActW%, %ActH%`nCurrent active window center is %centW%,%centH%
return

refresh:
gosub vol_BarOff
gosub autoex
gosub vol_ShowBars
return

options:
custDT := vol_DT
vol_DT = 60000
Gui, Show, x228 y9 h338 w335, VolOSD options
gosub vol_ShowBars
return

setW:
vol_Width := dimW		; set bar width
gosub refresh
return

resetW:
vol_Width := defW		; reset bar width to default
GuiControl,, dimW, %vol_Width%
gosub refresh
return

setH:
vol_Thick := dimH		; set bar thickness
gosub refresh
return

resetH:
vol_Thick := defH		; reset bar thickness to default
GuiControl,, dimH, %vol_Thick%
gosub refresh
return

resetC:
vol_CBM := defCM		; reset Master Volume Bar color to default
vol_CBW := defCW		; reset Wave Volume Bar color to default
vol_CW := defCB		; reset Background color to default
GuiControl +Background%vol_CBM%, CBM
GuiControl +Background%vol_CBW%, CBW
GuiControl +Background%vol_CW%, CW
gosub refresh
return

cyclesel:
Loop, 4
	GuiControl, Enable, mm%A_Index%
return

defactive:

defmon:
Loop, 4
	GuiControl, Disable, mm%A_Index%
return

pickit:
if (A_GuiEvent != "Normal")
	return
if ! CColor(vol_%A_GuiControl%)
	return
colorU := vol_%A_GuiControl%
;MsgBox, A_GuiControl=%A_GuiControl% %vol_CBM%, %vol_CBW%, %vol_CW%, return: %colorU%
GuiControl +Background%colorU%, %A_GuiControl%
;MsgBox, %vol_CBM% %vol_CBW% %vol_CW%
gosub refresh
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
	}
else
	{
vol_CBM := custM
vol_CBW := custW
vol_CW := custB
	}
gosub refresh
return

readini(file)
{
;IniRead, 
}

saveini(file)
{
;IniWrite, 
}

CColor(ByRef pColor, hGui=0){ 
  ;convert from rgb
    clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF) 

    VarSetCapacity(sCHOOSECOLOR, 0x24, 0) 
    VarSetCapacity(aChooseColor, 64, 0) 

    NumPut(0x24,		 sCHOOSECOLOR, 0)      ; DWORD lStructSize 
    NumPut(hGui,		 sCHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal"). 
    NumPut(clr,			 sCHOOSECOLOR, 12)     ; clr.rgbResult 
    NumPut(&aChooseColor,sCHOOSECOLOR, 16)     ; COLORREF *lpCustColors 
    NumPut(0x00000103,	 sCHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT 

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
;    pColor=0x%pColor%	; not needed here for ListView
    SetFormat, integer, %oldFormat% 

	return true
}

compare(a, b, c, d, e, f, g, h)	; ActX, ActY, ActW, ActH,  MonXLeft, MonXTop, MonXRight, MonXBottom
{
i := (c - a) // 2	; get center H
j :=  (d - b) // 2	; get center V
global vol_PosX, vol_PosY, vol_Width, vol_Thick
if ((i - e > 0) && (g - i > 0) && (j - f > 0) && (h - j > 0))
	{
	vol_PosX := (g- e) // 2 - (vol_Width // 2)
	vol_PosY := (h - f) // 2 - vol_Thick
	return true
	}
else
	return false
}

createGUI:
Gui, Add, Tab2, x5 y5 w326 h300 -Wrap -Theme -Background -0x800 0x3040 AltSubmit, Appearance|Hotkeys|Monitor|Soundcard|General|About
Gui, Tab
Gui, Add, Button, x130 y310 w62 h22 Disabled, &Apply
Gui, Add, Button, x194 y310 w62 h22 Default, &Close
Gui, Add, Button, x258 y310 w62 h22 Disabled, Ca&ncel
;============== TAB 1 ================
Gui, Tab, 1
Gui, Add, GroupBox, x11 y+5 w310 h135, Size
Gui, Add, Text, x20 y50 w100 h16, Progress bar width:
Gui, Add, Button, x245 yp w62 h22 gresetW, Default
Gui, Add, Slider, x20 y75 w290 h25 vdimW gsetW AltSubmit Range50-500 TickInterval10 ToolTip, %vol_Width%
Gui, Add, Text, x20 y105 w100 h16, Progress bar height:
Gui, Add, Button, x245 yp w62 h22 gresetH, Default
Gui, Add, Slider, x20 y130 w290 h25 vdimH gsetH AltSubmit Range5-20 TickInterval1 ToolTip, %vol_Thick%
Gui, Add, GroupBox, x11 y170 w310 h122, Colors
Gui, Add, Checkbox, x20 y193 w100 h19 vthemed gtheme AltSubmit, Obey OS theme
if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_2000
	GuiControl, Disabled, themed
Gui, Add, Button, x245 y190 w62 h22 gresetC, Default
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
Gui, Add, Edit, x+5 y47 w170 h20, CTRL+Up
Gui, Add, Text, x20 y75 w90 h14 Right, Master down:
Gui, Add, Edit, x+5 y72 w170 h20, CTRL+Down
Gui, Add, Text, x20 y100 w90 h14 Right, Wave up:
Gui, Add, Edit, x+5 y97 w170 h20, RALT+Up
Gui, Add, Text, x20 y125 w90 h14 Right, Wave down:
Gui, Add, Edit, x+5 y122 w170 h20, RALT+Down
Gui, Add, Text, x20 y150 w90 h14 Right, Master dim:
Gui, Add, Edit, x+5 y147 w170 h20, CTRL+SHIFT+Up
Gui, Add, Text, x20 y175 w90 h14 Right, Mute:
Gui, Add, Edit, x+5 y172 w170 h20, CTRL+SHIFT+Down
Gui, Add, Text, x20 y200 w90 h14 Right Disabled, Options:
Gui, Add, Edit, x+5 y197 w170 h20 Disabled, CTRL+SHIFT+O
Gui, Add, Text, x20 y225 w90 h14 Right Disabled, Cycle soundcards:
Gui, Add, Edit, x+5 y222 w170 h20 Disabled, CTRL+SHIFT+Enter
Gui, Add, Text, x20 y245 w290 h45 Center Disabled, Note: The 'Options' hotkey is only available when there is no tray icon. To disable the tray icon, mark 'No tray icon' in the 'General' panel.
;============== TAB 3 ================
Gui, Tab, 3
Gui, Add, GroupBox, x11 y+5 w310 h260, Behavior
Gui, Add, Radio, x20 y50 w290 h18 gdefmon Checked, Always on primary monitor
Gui, Add, Radio, x20 y+2 wp hp vm1 gdefactive Disabled, Always follow active window
Gui, Add, Radio, x20 y+2 wp hp vm2 gcyclesel Disabled, Use the monitor selected below:
Gui, Add, Radio, xp+15 y+5 w280 hp vmm1 Group Checked Disabled, %MonNam1%
Gui, Add, Radio, xp y+2 wp hp vmm2 Disabled, %MonNam2%
Gui, Add, Radio, xp y+2 wp hp vmm3 Disabled, %MonNam3%
Gui, Add, Radio, xp y+2 wp hp vmm4 Disabled, %MonNam4%
if MonAct > 1
	Loop, 2
		GuiControl, Enable, m%A_Index%
Gui, Add, Text, x20 y257 w290 h30 Center Disabled, Note: Due to OS limitations`, Windows 95 && NT will always display OSD on primary monitor.
;============== TAB 4 ================
Gui, Tab, 4
Gui, Add, GroupBox, x11 y+5 w310 h260, Device control
Gui, Add, Radio, x20 y50 w290 h18 Checked, Always use the following card:
Gui, Add, Radio, x20 y140 wp hp Disabled, Cycle through the following (using hotkey):
Gui, Add, Radio, xp+15 y75 w280 hp Group Checked, Soundcard #1
Gui, Add, Radio, xp y+2 wp hp Disabled, Soundcard #2
Gui, Add, Radio, xp y+2 wp hp Disabled, Soundcard #3
Gui, Add, Checkbox, xp y160 w280 hp Checked Disabled vscard1, Soundcard #1
Gui, Add, Checkbox, xp y+2 wp hp Checked Disabled vscard2, Soundcard #2
Gui, Add, Checkbox, xp y+2 wp hp Checked Disabled vscard3, Soundcard #3
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
Gui, Add, Text, x+10 y50 w290 h14, � Original script by Rajat (presented in AHK Help showcase)
;Gui, Add, Text, xp y+2 wp hp, http://www.autohotkey.com/forum/viewtopic.php?t=88
Gui, Add, Text, xp y+2 wp hp, � Dimmer solution borrowed from oxymor0n
Gui, Add, Text, xp y+2 wp hp, http://www.autohotkey.com/forum/posting.php?mode=quote&p=18505
Gui, Add, Text, xp y+2 wp hp, � Color Chooser function extracted from Majkinetor's CmnDlg
Gui, Add, Text, xp y+2 wp hp, http://www.autohotkey.com/forum/topic17230.html
Gui, Add, Text, xp y+2 wp hp, Licenced under Creative Commons Attribution-Noncommercial
Gui, Add, Text, xp y+2 wp hp, <http://creativecommons.org/licenses/by-nc/3.0/>
Gui, Add, Text, xp y+2 wp hp, Color picker trigger solution by SKAN
Gui, Add, Text, xp y+2 wp hp, � Graphical interface and additional options by Drugwash
Gui, Add, Text, xp y+2 wp hp, � Current version: %version% released on %release%
Gui, Tab
;************ Custom tray menu ************
Menu, Tray, Icon
Menu, Tray, NoStandard
Menu, Tray, Add, Settings, options,
Menu, Tray, Default, Settings
Menu, Tray, Add, About, about,
Menu, Tray, Add
Menu, Tray, Add, Exit, getout,
Return

about:
MsgBox, 64, About,
(
VolOSD %version%
by Drugwash

Released %release%
(%type% version)

This product is open-source.
)
return
