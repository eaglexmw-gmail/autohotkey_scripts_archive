;Written by Thalon with parts from Skrommel (www.donationcoders.com/skrommel)

record={LCtrl}{F12}
keydelay=10			;xxx Not used at the moment
windelay=100		;xxx Not used at the moment

;Get informations for abort-condition
StringReplace, endrecord, record, }, %A_Space%Down}
StringLen, length, endrecord



#SingleInstance,Force
#Persistent
SetBatchLines, -1
PID := DllCall("GetCurrentProcessId")
AutoTrim, Off
CoordMode, Mouse, Relative
modifiers =LCTRL,RCTRL,LALT,RALT,LSHIFT,RSHIFT,LWIN,RWIN,LButton,RButton,MButton,XButton1,XButton2
recording = 0
playing = 0
SendFlag = 0		;Flag for keyboard-recording
ControlSendFlag = 0		;Flag for special record-mode
GoSub, InitStyle
GoSub, Traymenu
Return



Record_On_Off:
If recording = 0
{
  ;Start recording if all modifier-keys are unpressed
	GetKeyState, state, LShift, P
  If state = d
  Loop
  {
    GetKeyState, state, LShift, P
    If state = U
      Break
  }
  GetKeyState, state, LCtrl, P
  If state = d
  Loop
  {
    GetKeyState, state, LCtrl, P
    If state = U
      Break
  }
  GetKeyState, state, LAlt, P
  If state = d
  Loop
  {
    GetKeyState, state, LAlt, P
    If state = U
      Break
  }
  GetKeyState, state, LWin, P
  If state = d
  Loop
  {
    GetKeyState, state, LWin, P
    If state = U
      Break
  }
  
  ;Start Recording
	recording = 1
  ToolTip, Recording... 
  Process, Priority, %PID%, High		;Sets Priority to high
  Gosub, Record_Loop
  Process, Priority, %PID%, Normal		;Sets Priority to high
  
  ToolTip, Recording finished
  
  ;Send recorded data to clipboard
	Clipboard = %keys%
  
  Sleep, 1000
  ToolTip,
  recording = 0
}
Else
{
	recording = 0
	SetTimer, Check_Modifier_Keys, Off
}
Return



Record_Loop:
SetTimer, Check_Modifier_Keys, 50
OldWinID =
keys =
Loop
{
  if recording = 0
  	break
	Input, key, M B C V I L1 T1, {BackSpace}{Space}{WheelDown}{WheelUp}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{F13}{F14}{F15}{F16}{F17}{F18}{F19}{F20}{F21}{F22}{F23}{F24}{ENTER}{ESCAPE}{TAB}{DELETE}{INSERT}{UP}{DOWN}{LEFT}{RIGHT}{HOME}{END}{PGUP}{PGDN}{CapsLock}{ScrollLock}{NumLock}{APPSKEY}{SLEEP}{Numpad0}{Numpad0}{Numpad1}{Numpad2}{Numpad3}{Numpad4}{Numpad5}{Numpad6}{Numpad7}{Numpad8}{Numpad9}{NumpadDot}{NumpadEnter}{NumpadMult}{NumpadDiv}{NumpadAdd}{NumpadSub}{NumpadDel}{NumpadIns}{NumpadClear}{NumpadUp}{NumpadDown}{NumpadLeft}{NumpadRight}{NumpadHome}{NumpadEnd}{NumpadPgUp}{NumpadPgDn}{BROWSER_BACK}{BROWSER_FORWARD}{BROWSER_REFRESH}{BROWSER_STOP}{BROWSER_SEARCH}{BROWSER_FAVORITES}{BROWSER_HOME}{VOLUME_MUTE}{VOLUME_DOWN}{VOLUME_UP}{MEDIA_NEXT}{MEDIA_PREV}{MEDIA_STOP}{MEDIA_PLAY_PAUSE}{LAUNCH_MAIL}{LAUNCH_MEDIA}{LAUNCH_APP1}{LAUNCH_APP2}{PRINTSCREEN}{CTRLBREAK}{PAUSE}
  endkey = %ErrorLevel%
	if (key = "" AND Errorlevel = "Timeout")   ;No key pressed
  	Continue
  
	GoSub, CheckWindow		;Check window-changes before key-record

  IfInString, endkey, EndKey:
  {
    StringTrimLeft, key, endkey, 7
    key = {%key%}
  }
  GoSub, Start_Send
	keys = %keys%%key%
  
  IfInString, keys, %endrecord%		;Finish-Shortcut was pressed
  {
		StringTrimRight, keys, keys, % length		;Remove Finish-Shortcut from record
		
		if (ControlSendFlag = 1)	;If "ControlSend" is recorded (due to pressing Finish-Shortcut)
		{
			StringRight, CheckTrimMode, keys, % 14 + StrLen(Controlname)
			if CheckTrimMode = ControlSend`, %Controlname%`,		;Check if Controlsend-Mode was initialized by Finish-Shortcut or if other letters where typed
				StringTrimRight, keys, keys, % 14 + StrLen(Controlname)		;Remove Controlsend-Command
			else		;Other letters typed --> Finish Controlsend-Command
				keys = %keys%`, %WinTitle%
		}
		else	;If "Send" is recorded (due to pressing Finish-Shortcut)
		{
			StringRight, CheckTrimMode, keys, % 5
			if CheckTrimMode = Send`,		;Check if Send-Mode was initialized by Finish-Shortcut or if other letters where typed
				StringTrimRight, keys, keys, 5		;Remove Send-Command
		}

			
    recording = 0
  }
  If recording = 0
  {
    SetTimer, Check_Modifier_Keys, Off
    Break
  }
}
Return


Check_Modifier_Keys:
Loop, Parse, modifiers, `,
{
  GetKeyState, state, %A_LoopField%, P
  If (state = "d" AND state%A_Index% = "")
  {
		GoSub, CheckWindow		;Check window-changes before key-record
		state%A_Index% = d
    if InStr(A_LoopField, "Button")
    {
	    GoSub, End_Send
;			keys = %keys%Sleep`, %A_TimeSincePriorHotkey%`n  ;Wofür war das?
			
			if (WinClass = "Progman" or WinClass = "WorkerW")		;Desktop
			{
;				CoordMode, Mouse, Screen
				MouseGetPos, XPos, YPos
				keys = %keys%
				(
MouseMove, %XPos%,%YPos%, 5
Loop,
{
	MouseGetPos, , , WinID
	WinGetClass, WinClass, ahk_id `%WinID`%
	if (WinClass != "Progman" and WinClass != "WorkerW")		;Falls Desktop nicht an dieser Stelle: alle Fenster minimieren
		Send, #m
	else
		break
}`n
				)
;				CoordMode, Mouse, Relative
				GoSub, MouseClick
			}
			else	;"normal" Window
			{
				;Getting style for clearer information
				MouseGetPos, XPos, YPos, WinID, Controlname
				ControlGet, ControlStyle, Style, , %Controlname%, ahk_id %WinID%

				if InStr(Controlname, "Button")	;Normaler Button, Checkbox, Radio, 
				{
					ControlStyle := (ControlStyle & 0xF)		;Es ist nur B0000 bis B1111 interessant
					if (ControlStyle = BS_PUSHBUTTON OR ControlStyle = BS_DEFPUSHBUTTON)
					{
						LButtonDownTime = %A_TickCount%
						keys = %keys%ControlClick`, %Controlname%`, %WinTitle%`, `, Left`, 1`, D`n
					}
					else if (ControlStyle = BS_3STATE OR ControlStyle = BS_AUTO3STATE)
					{
						SendMessage, BM_GETSTATE, 0, 0, %Controlname%, %WinTitle%
				  	state := ErrorLevel
				  	;Obey: The previous state has to be used for check...
				  	If (state & 0x3 = BST_UNCHECKED)	;State = CHECKED
							keys = %keys%Control`, Check`, `, %Controlname%`, %WinTitle%`n
						Else If (state & 0x3 = BST_CHECKED)		;State = INDETERMINATE
							keys = %keys%SendMessage`, %BM_SETCHECK%`, %BST_INDETERMINATE%`, 0`, %Controlname%, %WinTitle%`n
						Else If (state & 0x3 = BST_INDETERMINATE)		;State = UNCHECKED
							keys = %keys%Control`, UnCheck`, `, %Controlname%`, %WinTitle%`n
					}
					else if (ControlStyle = BS_CHECKBOX OR ControlStyle = BS_AUTOCHECKBOX)
					{
						ControlGet, Checked?, Checked, , %Controlname%, %WinTitle%
						if Checked? = 1	;Beachte: Mausklick erfolgt erst nach Statuserfassung!
							keys = %keys%Control`, UnCheck`, `, %Controlname%`, %WinTitle%`n
						else
							keys = %keys%Control`, Check`, `, %Controlname%`, %WinTitle%`n
					}
					else if (ControlStyle = BS_RADIOBUTTON OR ControlStyle = BS_AUTORADIOBUTTON)
						keys = %keys%ControlClick`, %Controlname%`, %WinTitle%`, `, Left`, 1`n
					else	;Unhandled Button-Type
					{
						LButtonDownTime = %A_TickCount%
						keys = %keys%MouseClick`, Left`, %XPos%`, %YPos%`, `, `, D`n
					}
				}
				else if InStr(Controlname, "Edit")		;Edit, Combobox (here only Edit-part)
				{
					GoSub, MouseClick
					keys = %keys%ControlFocus`, %Controlname%`, %WinTitle%`n
				}
/*
			
				else if InStr(Controlname, "ComboBox")	;DropDown, Combobox (hier nur Button zum droppen)
				{
					
				}
				else if InStr(Controlname, "Listbox")	;Listbox
				{
					
				}
				else if InStr(Controlname, "Hotkey")	;Hotkey-Control
				{
					History = %History%ControlFocus`, %Controlname%`, %WinTitle%`n
				}
				else if InStr(Controlname, "Trackbar")	;Slider
				{
					
				}
				
*/
				else	;Klick somewhere in the window or unknown control
				{
					GoSub, MouseClick
				}
			}

 
    }
    Else
    {
			GoSub, Start_Send
			keys = %keys%{%A_LoopField% Down}
		}
  }
  
  GetKeyState, state, %A_LoopField%, P
  If (state = "u" AND state%A_Index% = "d") 
  {
		GoSub, CheckWindow		;Check window-changes before key-record
		
    if InStr(A_LoopField, "Button")
    {
      GoSub, End_Send
			
			if LButtonDownTime !=
			{
				LButtonDownDuration := A_TickCount - LButtonDownTime
				MouseGetPos, XPos, YPos
				keys = %keys%Sleep`, %LButtonDownDuration%`nMouseClick`, Left`, %XPos%`, %YPos%`, `, `, U`n
				LButtonDownTime =
			}
    }
    Else
    {
			GoSub, Start_Send
			keys = %keys%{%A_LoopField% Up}
		}
    state%A_Index%=
  }
}
If keys = {LShift Up}
  keys =
If keys = {LCtrl Up}
  keys =
If keys = {LAlt Up}
  keys =
If keys = {LWin Up}
  keys =
StringRight, tooltip, keys, 500
ToolTip, %tooltip%
Return


MouseClick:		;Saves a mouseclick (unknown controls or for controls where position is needed (Edit-Control for example))
MouseGetPos, XPos, YPos
LButtonDownTime = %A_TickCount%
keys = %keys%MouseClick`, Left`, %XPos%`, %YPos%`, `, `, D`n
return

Traymenu:
;Menu, Tray, NoStandard 
;Menu, Tray, DeleteAll 
;Menu, Tray, Add, DoOver, TRAYPLAYBACK
;Menu, Tray, Add,
;Menu, Tray, Add, &Playback, TRAYPLAYBACK
Menu, Tray, Add, &Record, Record_On_Off
;Menu, Tray, Add,
;Menu, Tray, Add, &Settings, SETTINGS
Menu, Tray, Add, R&eload, Reload
;Menu, Tray, Add,
;Menu, Tray, Add, &About, ABOUT
Menu, Tray, Add, &Quit, Quit
;Menu, Tray, Default, DoOVer
Return

/*
TRAYRECORD:
WinActivate, ahk_id %currentid%
WinWaitActive, ahk_id %currentid%, , 2
Gosub, Record_On_Off
Return
*/

Reload:
Reload

CheckWindow:
WinGet, WinID, ID, A
If WinID <> %OldWinID%
{
	GoSub, End_Send

	WinGetClass, WinClass, ahk_id %WinID%
	WinGetTitle, WinTitle, ahk_id %WinID%
/*
	if (WinClass = "Progman" OR WinClass = "WorkerW")
	{
		;keys = %keys%{LWIN Down}m{LWIN UP}
	}
	else 
	*/
	if WinTitle !=
	{
		keys = %keys%WinActivate`, %WinTitle%`nWinWaitActive`, %WinTitle%`n
	}
  OldWinID = %WinID%
}
return

Start_Send:
if SendFlag = 0		;If "Send" was not already added it is added just before the keypress...
{
	ControlGetFocus, Controlname, ahk_id %WinID%
	if InStr(Controlname, "Edit")		;If control is of Edit-Type use "ControlSend" instead of "Send"
	{
		ControlSendFlag = 1
		keys = %keys%ControlSend`, %Controlname%`,
	}
	else
		keys = %keys%Send`,
	SendFlag = 1
}
return

End_Send:
if ControlSendFlag = 1
{
	SendFlag = 0
	ControlSendFlag = 0
	keys = %keys%`, %WinTitle%`n
	Controlname = 	;Delete Last Controlname on Windowchange
}
else if SendFlag = 1
{
	SendFlag = 0
	keys = %keys%`n		
}
return

;Set constants
InitStyle:
;Borderstyles
BS_PUSHBUTTON = 0x0
BS_DEFPUSHBUTTON = 0x1
BS_CHECKBOX = 0x2
BS_AUTOCHECKBOX = 0x3
BS_RADIOBUTTON = 0x4 
BS_3STATE = 0x5
BS_AUTO3STATE = 0x6
BS_GROUPBOX = 0x7
BS_AUTORADIOBUTTON = 0x9
;BS_PUSHLIKE = 0x1000

;Constants for retreive/set 3rd state of a checkbox
BM_GETSTATE = 0xF2
BST_UNCHECKED = 0x0
BST_CHECKED = 0x1
BST_INDETERMINATE = 0x2
BM_SETCHECK = 0xF1
return

Quit:
ExitApp
