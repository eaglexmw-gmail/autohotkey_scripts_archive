gosub createGUI
goto start
about:
MsgBox,
(
• Original script by Rajat (presented in AHK Help file showcase)
http://www.autohotkey.com/forum/viewtopic.php?t=88
• Dimmer solution borrowed from oxymor0n
http://www.autohotkey.com/forum/posting.php?mode=quote&p=18505
• Color Chooser function extracted from Majkinetor's CmnDlg
http://www.autohotkey.com/forum/topic17230.html
Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>
• modified by Drugwash
• version 1.3
)
;_________________________________________________ 
;_______User Settings_____________________________ 
start:
init := A_WorkingDir . "\VolOSD.ini"
gosub initialize
;****** CUSTOM TRAY MENU ******
Menu, Tray, Icon
Menu, Tray, NoStandard
Menu, Tray, Add, Settings, options,
Menu, Tray, Default, Settings
Menu, Tray, Add, About, about,
Menu, Tray, Add
Menu, Tray, Add, Exit, getout,
;******************************
; Make customisation only in this area or hotkey area only!! 
; The percentage by which to raise or lower the volume each time:
vol_Step = 2
dimmer = 10

; How long to display the volume level bar graphs:
vol_DisplayTime = 2000

; Master Volume Bar color (see the help file to use more
; precise shades):
vol_CBM = Red

; Wave Volume Bar color
vol_CBW = Blue

; Background color
vol_CW = Silver

; Bar's screen position.  Use -1 to center the bar in that dimension:
; This needs some multi-monitor checks (note by Drugwash)
;vol_PosX = -1
;vol_PosY = -1
gosub getpos
if ! FileExist(init)
	{
	vol_Width = 120  ; width of bar
	vol_Thick = 8   ; thickness of bar
	}
else
	readini(init)

; If your keyboard has multimedia buttons for Volume, you can
; try changing the below hotkeys to use them by specifying
; Volume_Up, ^Volume_Up, Volume_Down, and ^Volume_Down:
;HotKey, #Up, vol_MasterUp      ; Win+UpArrow
;HotKey, #Down, vol_MasterDown	; Win+DownArrow
HotKey, >^Up, vol_MasterUp      ; CTRL+UpArrow
HotKey, >^Down, vol_MasterDown	; CTRL+DnArrow
HotKey, ^!Up, vol_WaveUp       ; RALT+UpArrow
HotKey, ^!Down, vol_WaveDown	; RALT+DnArrow
Hotkey, ^BS, getout	; CTRL+Backspace
Hotkey, ^+Up, vol_Dimmer	; CTRL+SHIFT+Up
Hotkey, ^+Down, vol_MasterMute	; CTRL+SHIFT+Down
;___________________________________________ 
;_____Auto Execute Section__________________ 

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

#SingleInstance, Force
SetBatchLines, 10ms
Return


;___________________________________________ 

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
Gui, Hide
return

vol_ShowBars:
gosub getpos	; find the active window's screen and position OSD according to user settings
; To prevent the "flashing" effect, only create the bar window if it
; doesn't already exist:
IfWinNotExist, vol_Wave
    Progress, %vol_BarOptionsWave%, , , vol_Wave
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
	Menu, Tray, Icon, %A_Windir%\sndvol32.exe, 5,
	mutt := 5
	}
; Get both volumes in case the user or an external program changed them:
gosub getval
Progress, 1:%vol_Master%
Progress, 2:%vol_Wave%
SetTimer, vol_BarOff, %vol_DisplayTime%
return

initialize:
;****** find multi-monitor data ******
SysGet, MonTot, MonitorCount
SysGet, MonAct, 80
SysGet, MonPrim, MonitorPrimary
Loop, %MonAct%
	{
	SysGet, coord%A_Index%, MonitorWorkArea, %A_Index%
	SysGet, MonNam%A_Index%, MonitorName, %A_Index%
	SysGet, Mon%A_Index%, Monitor, %A_Index%
	}
;*******************************
getmute:
SoundGet, init,, mute
mutt := init="On" ? 4 : 5
Menu, Tray, Icon, %A_Windir%\sndvol32.exe, %mutt%,
getval:
muted := mutt=4 ? "ON" : "OFF"
SoundGet, vol_Master, Master
SoundGet, vol_Wave, Wave
vM := Floor(vol_Master)
vW := Floor(vol_Wave)
Menu, Tray, Tip, Master: %vM%`% • Wave: %vW%`% • Mute is %muted%
return

getpos:
;WinGet, actID, A
WinGetPos, ActX, ActY, ActW, ActH, A	; get coords of active window
centW := ActX - (ActW/=2)	; get center H
centH := ActY - (ActH/=2)	; get center V
if (centW > Mon1Left && centW < Mon1Right && centH > Mon1Top && centH < Mon1Bottom)
	{
	vol_PosX := 
	vol_PosY := 
	}
return

vol_BarOff:
SetTimer, vol_BarOff, off
Progress, 1:Off
Progress, 2:Off
return

options:
Gui, Show, x228 y9 h375 w475, VolOSD options
;MsgBox, Unfinished section, sorry!`nCome back later.
return

pickitM:
MsgBox, Got here alright...
CColor(vol_CBM)
GuiControl +Background%pColor%, cp1
return

pickitW:
CColor(vol_CBW)
GuiControl +Background%pColor%, cp2
return

pickitB:
CColor(vol_CW)
GuiControl +Background%pColor%, cp3
return

theme:
if themed
	{
	GuiControl,, vol_Master, -Smooth cDefault BackgroundDefault
	GuiControl,, vol_Wave, -Smooth cDefault BackgroundDefault
	}
else
	{
	GuiControl,, vol_Master, Smooth c%vol_CBM% Background%vol_CW%
	GuiControl,, vol_Wave, Smooth c%vol_CBW% Background%vol_CW%
	}
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
    pColor=0x%pColor% 
    SetFormat, integer, %oldFormat% 

	return true
}

createGUI:
; VolOSD GUI
; Generated by SmartGUI Creater
; Created by Drugwash, Oct 2008

Gui, Add, GroupBox, x6 y27 w183 h171, Monitor
Gui, Add, Radio, x14 y47 w171 h18 Checked, Always on primary monitor
Gui, Add, Radio, x14 y67 w171 h18 Disabled, Always follow active window
Gui, Add, Radio, x14 y87 w171 h18 Disabled, Use the monitor selected below:
Gui, Add, Radio, x30 y110 w151 h18 Group Checked Disabled, Monitor #1
Gui, Add, Radio, x30 y130 w151 h18 Disabled, Monitor #2
Gui, Add, Radio, x30 y150 w151 h18 Disabled, Monitor #3
Gui, Add, Radio, x30 y170 w151 h18 Disabled, Monitor #4
Gui, Add, GroupBox, x193 y27 w127 h88, Soundcard
Gui, Add, Radio, x197 y47 w121 h18 Checked, Soundcard #1
Gui, Add, Radio, x197 y67 w121 h18 Disabled, Soundcard #2
Gui, Add, Radio, x197 y87 w121 h18 Disabled, Soundcard #3
Gui, Add, Text, x198 y125 w124 h76 Disabled, Note:`nDue to OS limitations Windows 95 && NT will always display OSD on primary monitor.
Gui, Add, GroupBox, x324 y27 w143 h149, Detected devices
Gui, Add, Text, x338 y40 w90 h15, Monitors:
Gui, Add, Text, x327 y55 w10 h12, 1.
Gui, Add, Text, x338 y55 w127 h12, Monitor #1
Gui, Add, Text, x327 y68 w10 h12, 2.
Gui, Add, Text, x338 y68 w127 h12, Monitor #2
Gui, Add, Text, x327 y81 w10 h12, 3.
Gui, Add, Text, x338 y81 w127 h12, Monitor #3
Gui, Add, Text, x327 y94 w10 h12, 4.
Gui, Add, Text, x338 y94 w127 h12, Monitor #4
Gui, Add, Text, x338 y115 w90 h15, Soundcards:
Gui, Add, Text, x327 y130 w10 h12, 1.
Gui, Add, Text, x338 y130 w127 h12, Soundcard #1
Gui, Add, Text, x327 y143 w10 h12, 2.
Gui, Add, Text, x338 y143 w127 h12, Soundcard #2
Gui, Add, Text, x327 y156 w10 h12, 3.
Gui, Add, Text, x338 y156 w127 h12, Soundcard #3
Gui, Add, Checkbox, x328 y184 w137 h18 Checked, Start with Windows
Gui, Add, GroupBox, x6 y203 w183 h165, Appearance
Gui, Add, Text, x14 y220 w100 h16, Progress bar width:
Gui, Add, Button, x119 y217 w62 h22, Default
Gui, Add, Slider, x14 y240 w164 h25 vsetW Range50-500 TickInterval50 ToolTip, 120
Gui, Add, Text, x14 y270 w100 h16, Progress bar height:
Gui, Add, Button, x119 y266 w62 h22, Default
Gui, Add, Slider, x14 y290 w164 h25 vsetH Range5-20 TickInterval1 ToolTip, 8
Gui, Add, Text, x14 y320 w60 h14, Master:
Gui, Add, ListView, x76 y320 w40 h13 -E0x200 +Border -hdr +ReadOnly BackgroundFF0000 vcp1 gpickitM
Gui, Add, Text, x14 y334 w60 h14, Wave:
Gui, Add, ListView, x76 y334 w40 h13 -E0x200 +Border -hdr +ReadOnly Background0000FF vcp2 gpickitW
Gui, Add, Text, x14 y348 w60 h14, Background:
Gui, Add, ListView, x76 y348 w40 h13 -E0x200 +Border -hdr +ReadOnly BackgroundSilver vcp3 gpickitB
Gui, Add, Button, x119 y316 w62 h22, Default
Gui, Add, Checkbox, x119 y340 w68 h19, XP theme
Gui, Add, GroupBox, x193 y203 w275 h165, Hotkeys
Gui, Add, Text, x198 y221 w67 h14, Master up:
Gui, Add, Edit, x268 y220 w110 h19, CTRL+Up
Gui, Add, Text, x198 y241 w67 h14, Master down:
Gui, Add, Edit, x268 y240 w110 h19, CTRL+Down
Gui, Add, Text, x198 y261 w67 h14, Wave up:
Gui, Add, Edit, x268 y260 w110 h19, RALT+Up
Gui, Add, Text, x198 y281 w67 h14, Wave down:
Gui, Add, Edit, x268 y280 w110 h19, RALT+Down
Gui, Add, Text, x198 y301 w67 h14, Master dim:
Gui, Add, Edit, x268 y300 w110 h19, CTRL+SHIFT+Up
Gui, Add, Text, x198 y321 w66 h14, Mute:
Gui, Add, Edit, x268 y320 w110 h19, CTRL+SHIFT+Down
Gui, Add, Text, x198 y341 w67 h14 Disabled, Options:
Gui, Add, Edit, x268 y340 w110 h19 Disabled, CTRL+SHIFT+O
Gui, Add, Checkbox, x385 y340 w77 h19, No tray icon
Gui, Add, Button, x395 y220 w62 h32 Disabled, &Apply
Gui, Add, Button, x395 y260 w62 h32 Default, &Close
Gui, Add, Button, x395 y300 w62 h32 Disabled, Ca&ncel
Gui, Show, x228 y9 w475 h375, VolOSD options
Return
