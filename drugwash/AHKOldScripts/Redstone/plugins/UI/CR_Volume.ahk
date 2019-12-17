; include plugins/experimental/volume_osd.ahk
volume_Initialize() {

	CommandRegister("Volume Up", "volume_Command", "/name:Volume Up")
	CommandRegister("Volume Down", "volume_Command", "/name:Volume Down")
	CommandRegister("Volume Unmute", "volume_Command", "/name:Sound On")
	CommandRegister("Volume Mute", "volume_Command", "/name:Sound Off")
	CommandRegister("Volume ToggleMute", "volume_Command", "/name:Toggle Mute")

	; Get notified when to build UI components
	NotifyRegister("UI Create", "volume_CreateUI")
}

volume_Command(A_Command, A_Args) {

	A_Command := getValue(A_Command, "command")
	if (A_Command = "Volume Up") {
		SetVolume("Up","Master",1,1,8)
	} else if (A_Command = "Volume Down") {
		SetVolume("Down","Master",1,1,8)
	} else if (A_Command = "Volume Mute") {
		SoundSet, 1, , MUTE
	} else if (A_Command = "Volume Unmute") {
		SoundSet, 0, , MUTE
	} else if (A_Command = "Volume ToggleMute") {
		SoundGet, var, , MUTE
		if (var = "Off")
			var := 1
		else
			var := 0
		SoundSet, %var%, , MUTE 
	}

	control := getControl("VolumeLevel")
	GuiControlGet,isVisible,Visible,%control%
	if (isVisible = 0) {
		GuiControl, Show, %control%
	}
	SoundGet, vol_Master, Master
	GuiControl,, %control%, %vol_Master%
	SetTimer, vol_BarOff, 2000
	
	Return

	vol_BarOff:
		control := getControl("VolumeLevel")
		SetTimer, vol_BarOff, off
		GuiControl, Hide, %control%
	Return
}

volume_CreateUI(A_Command, A_Args) {

	COMMAND("UI AddControl", "/name:VolumeLevel"
		. " /type:progress"
		. " /x:5 /y:78 /w:502 /h:6"
		. " /anchor:w"
		. " /style:Hidden +C66FF66")

	Hotkey, IfWinActive, RedStone
	Hotkey, WheelUp, onWheelUp
	Hotkey, WheelDown, onWheelDown
	Return

	onWheelUp:
		MouseGetPos, , , id, currWnd, 2
		entry := syslist_Get("Controls", "/single:Yes /filter:hwnd=" . currWnd)
		name := getValue(entry, "name")
		vact := getValue(entry, "volumeActivate")
		if (name = "CTRLHeader") OR (name = "Background") OR (name = "VolumeLevel") OR (vact = "Yes") {
			Command("Volume Up")
		}
		ControlClick,, ahk_id %currWnd%, , WheelUp
	return
	onWheelDown:
		MouseGetPos, , , id, currWnd, 2
		entry := syslist_Get("Controls", "/single:Yes /filter:hwnd=" . currWnd)
		name := getValue(entry, "name")
		vact := getValue(entry, "volumeActivate")
		if (name = "CTRLHeader") OR (name = "Background") OR (name = "VolumeLevel") OR (vact = "Yes") {
			Command("Volume Down")
		}
		ControlClick,, ahk_id %currWnd%, , WheelDown
	return
}

; http://www.autohotkey.com/forum/topic9286.html - jballi
SetVolume(p_Command
	 ,p_ComponentType=""
	 ,p_Value=1
	 ,p_Increment=1
	 ,p_MaxValue=4
	 ,p_MinValue=0.05
	 ,p_ETT=200)
{
	static s_Command
	static s_ComponentType
	static s_Value
	static s_TickCount

	;[  Initialize  ]
	l_ControlType=Volume

	;[   Parameters  ]
	p_Command=%p_Command%              ;-- AutoTrim
	p_ComponentType=%p_ComponentType%  ;-- AutoTrim
	if not p_ComponentType
		p_ComponentType=Master

	if (p_MaxValue<p_Value)
		p_MaxValue:=p_Value+0

	;[  First run?  ]
	if not s_Command
		s_TickCount=600000

	;[  Determine value  ]
	if p_Command not in Set,Mute
	{
		if (p_Command=s_Command
			and  p_ComponentType=s_ComponentType
			and  (A_TickCount-s_TickCount)<=p_ETT)
			{
			s_Value:=s_Value+p_Increment
			if (s_Value>p_MaxValue)
				s_Value:=p_MaxValue+0
			 else
				if (s_Value<p_MinValue)
					s_Value:=p_MinValue+0
			}
		 else
			s_Value:=p_Value+0
		}
	   
	;[  Identify/Define volume setting  ]
	if p_Command in +,U,Up
		l_NewSetting=+%s_Value%
	else if p_Command in -,D,Down
		l_NewSetting=-%s_Value%
	else if p_Command=Set
		l_NewSetting:=abs(p_Value)
	 else
	{
		l_ControlType=Mute
		l_NewSetting:=p_Value
	}

	;[  Set Volume  ]
	SoundSet %l_NewSetting%,%p_ComponentType%,%l_ControlType%

	;[  Update static  ]
	s_Command      :=p_Command
	s_ComponentType:=p_ComponentType
	s_TickCount    :=A_TickCount
}
