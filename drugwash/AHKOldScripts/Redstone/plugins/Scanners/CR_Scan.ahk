scan_Initialize() {
	CommandRegister("Scan Directory", "scan_Directory")
	CommandRegister("Scan Run", "scan_Run")
	CommandRegister("Scan Refresh", "scan_Refresh")
	ClientCommandRegister("Scan Refresh", "scan_Refresh")

	CommandRegister("Scan Start", "scan_OnStart")
}

scan_Run(A_Command, A_Args) {

	command := getValue(A_Args, "command")
	COMMAND(command, A_Args)
}

scan_OnStart(A_Command, A_Args) {

	IfNotExist, %A_ScriptDir%\config\Default.xml
	{
		COMMAND("Scan Refresh")
	}

; TODO: A_TimeIdlePhysical
	SetTimer, ScanTimer, 5000
}

ScanTimer:
	SetTimer, ScanTimer, Off
	SetBatchLines, 50        ; set at slow speed
	COMMAND("Scan Refresh", "/mode:background")
	SetTimer, ScanTimer, 90000

	COMMAND("AHK CompactMemory")
Return

scan_Refresh(A_Control, A_Args) {

	mode := getValue(A_Args, "mode")
	
	if (mode <> "background") {
		SplashTextOn,300,60,RedStone, `nGenerating Index
	}

	syslist_Set("Default", "")
	list := syslist_Read("Scan")

	Loop
	{
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		COMMAND("Command Run", entry)
		COMMAND("AHK CompactMemory")
	}

	list := syslist_Get("Default")
	list_Write(list, "Default.xml")
	syslist_Set("Default", list_Create())

	if (mode <> "background") {
		SplashTextOff
	}
	CLIENT_NOTIFY("Scan Refreshed")
}

scan_Directory(A_Command, A_Args) {

	directory := getValue(A_Args, "directory")

	directory := ExpandVars(directory)
	name := getValue(A_Args, "name")

	IfExist, %directory%
	{
		list := list_Create()

		includeTypes := getValue(A_Args, "includeTypes")
		recurse := getValue(A_Args, "recurse")
		includeDirs := getValue(A_Args, "includeDirs")

		recurse := (recurse = "Yes") ? 1 : 0
		includeDirs := (includeDirs = "Yes") ? 1 : 0

		Loop, %directory%\*.*, %includeDirs%, %recurse%
		{
			if A_LoopFileAttrib contains H
				continue
			if A_LoopFileAttrib contains D
			{
				entry := "/listName:Default"
					. " /name:" . Enc_XML(A_LoopFileName) 
					. " /type:folder"
					. " /command:" . Enc_XML(A_LoopFileLongPath)
				
			} else {

				SplitPath, A_LoopFileFullPath, FName, FDir, FExt, FNameNoExt, FDrive

				if includeTypes <>
					if FExt not in %includeTypes%
						Continue

				entry := "/listName:Default"
					. " /name:" . Enc_XML(FNameNoExt) 
					. " /type:file"
					. " /command:" . Enc_XML(A_LoopFileFullPath)
			}
			list_Add(list, entry)
		}
		syslist_Merge("default", list)
	} else {
		syslist_Add("Errors", "/type:error /error:Scan Directory does not exist:" . directory)
	}
}

;Chris made this long ago!
ExpandVars(Var)
{
   var_new = %var%
   in_reference = n
   Loop, parse, var_new, `%
   {
      if in_reference = n
      {
         in_reference = y
         continue
      }
      ; Otherwise, A_LoopField is a variable reference:
      StringTrimLeft, ref_contents, %A_LoopField%, 0
      StringReplace, var_new, var_new, `%%A_LoopField%`%, %ref_contents%, all
      in_reference = n
   }
   Return, var_new
}
