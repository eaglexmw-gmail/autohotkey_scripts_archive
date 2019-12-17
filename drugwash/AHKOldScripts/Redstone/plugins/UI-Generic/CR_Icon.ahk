lister_AddIconToImageList(Command, ImageList, iconSize="Small") {

	hIcon := getIcon(command, iconSize)
	if (hIcon = 0) OR (hIcon = "") {
		MsgBox,"Unable to get icon")
		logA("command:" . command)
	} else {
		iconNum := DllCall("ImageList_ReplaceIcon", "uint", ImageList, "int", -1, "uint", hIcon) +1
		DllCall("DestroyIcon", "uint", hIcon)
	}
	return iconNum
}

getIcon(command, iconSize) {

	FileName := getValue(Command, "command", "")
	iconNum := ""

	defaultIconNum := 2
	defaultIconFile := "SHELL32.dll"

	icon := getValue(Command, "icon")
	if (icon = "") {
		Type := getValue(Command, "type", "")
		handler := getTypeMeta(Type)
		icon := getValue(handler, "icon")
	}

	if (icon = "classid") {
		; TODO-1: no registry access allowed issue prevents lookup of virtual folder icon
		StringReplace,classId,FileName,:,,All
		RegRead, icon, HKCU, Software\Classes\CLSID\%classID%\DefaultIcon

	} else if (icon = "Window") {
		wid := getValue(command, "wid")
		hIcon := Get_Window_Icon2(wid, icon, iconNum)
		
	} else if (icon = "url") {

		domain := getDomain(FileName)
		icon =  %A_WorkingDir%\favicons\%domain%.ico

		defaultIconNum := 13
		defaultIconFile := "SHELL32.dll"

	} else if (icon = "File") {
		icon := FileName
		iconNum := 0
	} 
	
	IfInString, icon, `,
	{
		StringSplit,iconArray,icon,`,
		icon := iconArray1
		iconNum := iconArray2
	}

	if (hIcon = "") AND (icon <> "") {
		hIcon := getIconFromFile(icon, iconNum, iconSize)
	}

	if (hIcon = 0) OR (hIcon = "") {
		hIcon := getIconFromFile(defaultIconFile, defaultIconNum, iconSize)
	}

	return hIcon
}

getIconFromFile(fileName, iconNum, iconSize) {

	if (iconNum = "") {
		VarSetCapacity(exFN, 260)
		exFN := FileName
		sfi_size = 352
		VarSetCapacity(sfi, sfi_size)
		if (iconSize = "Large") {
			flags := 0x100  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
		} else {
			flags := 0x101  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
		}

		if not DllCall("Shell32\SHGetFileInfoA", "str", exFN, "uint", 0, "str", sfi, "uint", sfi_size, "uint", flags)
		{
			log("fail:" . exFN)
		}
		else {
			hIcon = 0
			Loop 4
				hIcon += *(&sfi + A_Index-1) << 8*(A_Index-1)
		}
	} else {
		VarSetCapacity(fname, 260)
		fname := fileName
		hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, fname, UShortP, iconNum)
	}
	return hIcon
}

Get_Window_Icon2(wid, ByRef iconFile, ByRef iconNum) {
	Parent := Decimal_to_Hex( DllCall( "GetParent", "uint", wid ) )
	WinGet, Style_parent, Style, ahk_id %Parent%

	If (Parent and ! Style_parent)
		CPA_file_name := GetCPA_file_name( wid ) ; check if it's a control panel window
	Else
		CPA_file_name =

	If (CPA_file_name)
	{
		iconFile := CPA_file_name
		iconNum := 1

	} Else {

		; check status of window - if window is responding or "Not Responding"
		NR_temp =0 ; init
		Responding := DllCall("SendMessageTimeout", "UInt", wid, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 250, "UInt *", NR_temp) ; 150 = timeout in millisecs
		If (Responding)
		{
			; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2

			SendMessage, 0x7F, 1, 0,, ahk_id %wid%
			h_icon := ErrorLevel

			If ( ! h_icon )
			{
				SendMessage, 0x7F, 2, 0,, ahk_id %wid%
				h_icon := ErrorLevel
				If ( ! h_icon )
				{
					SendMessage, 0x7F, 0, 0,, ahk_id %wid%
					h_icon := ErrorLevel
					If ( ! h_icon )
						h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
					If ( ! h_icon )
						h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
					If ( ! h_icon )
						h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
				}
			}
		}
	}
	return h_icon
}

GetCPA_file_name( p_hw_target ) ; retrives Control Panel applet icon
{
	WinGet, pid_target, PID, ahk_id %p_hw_target%
	hp_target := DllCall( "OpenProcess", "uint", 0x18, "int", false, "uint", pid_target )
	hm_kernel32 := DllCall( "GetModuleHandle", "str", "kernel32.dll" )
	pGetCommandLineA := DllCall( "GetProcAddress", "uint", hm_kernel32, "str", "GetCommandLineA" )
	buffer_size = 6
	VarSetCapacity( buffer, buffer_size )
	DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pGetCommandLineA, "uint", &buffer, "uint", buffer_size, "uint", 0 )
	loop, 4
		ppCommandLine += ( ( *( &buffer+A_Index ) ) << ( 8*( A_Index-1 ) ) )
	buffer_size = 4
	VarSetCapacity( buffer, buffer_size, 0 )
	DllCall( "ReadProcessMemory", "uint", hp_target, "uint", ppCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )
	loop, 4
		pCommandLine += ( ( *( &buffer+A_Index-1 ) ) << ( 8*( A_Index-1 ) ) )
	buffer_size = 260
	VarSetCapacity( buffer, buffer_size, 1 )
	DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )
	DllCall( "CloseHandle", "uint", hp_target )
	IfInString, buffer, desk.cpl ; exception to usual string format
	return, "C:\WINDOWS\system32\desk.cpl"

logA("buffer:" . buffer)
	ix_b := InStr( buffer, "Control_RunDLL" )+16
	ix_e := InStr( buffer, ".cpl", false, ix_b )+3
	StringMid, CPA_file_name, buffer, ix_b, ix_e-ix_b+1
	if ( ix_e )
		return, CPA_file_name

	return, false
}


