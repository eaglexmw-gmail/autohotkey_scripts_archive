goto start
about:
MsgBox,
(
• Original script by Rajat
http://www.autohotkey.com/forum/viewtopic.php?t=88
• Dimmer solution borrowed from oxymor0n
http://www.autohotkey.com/forum/posting.php?mode=quote&p=18505
• modified by Drugwash
• version 1.2
)
;_________________________________________________ 
;_______User Settings_____________________________ 
start:
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
vol_PosX = -1
vol_PosY = -1
vol_Width = 120  ; width of bar
vol_Thick = 8   ; thickness of bar

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
gosub initialize
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

GuiClose:
Gui, Hide
return

vol_ShowBars:
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

vol_BarOff:
SetTimer, vol_BarOff, off
Progress, 1:Off
Progress, 2:Off
return

options:
MsgBox, Unfinished section, sorry!`nCome back later.
return
