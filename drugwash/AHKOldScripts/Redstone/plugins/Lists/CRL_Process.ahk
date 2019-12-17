; based on...
; shimanov : http://www.autohotkey.com/forum/viewtopic.php?t=9000&start=0&postdays=0&postorder=asc&highlight=

process_Initialize() {
	CommandRegister("Process ProcessList", "process_Refresh")
	
	NotifyRegister("UI BuildMenu", "process_OnBuildMenu")
	NotifyRegister("Lister ColClick", "process_OnColumnClick")

	process_EnableSomething()
}

process_OnBuildMenu(A_Command, A_Args) {
	entry := getNestedNode(A_Args, "Entry")
	type := getPrimitiveType(entry)

	if (type = "process") {

	 	command := commandCreate("Process Terminate")
	 	setNode(command, "Args", entry)
		menuAdd(A_Args, "/item:Terminate", command)

;		<command>
;		  <type>command</type>
;		  <command>Process Terminate</command>
;		  <Args>
;		    <listName>Process</listName>
;		    <type>process</type>
;		    <pid>836</pid>
;		    <name>GoogleUpdate.exe</name>
;		    <command>C:\Program Files\Google\Update\GoogleUpdate.exe</command>
;		    <commandLine>&quot;C:\Program Files\Google\Update\GoogleUpdate.exe&quot;</commandLine>
;		  </Args>
;		</command>
	}
}

process_Refresh(A_Command, filter) {

	list := process_GetList()
	syslist_Set("Process", list)
	ShowResults(filter, list)

	SetTimer, ProcessRefreshTimer, 1000
	
	Return

	ProcessRefreshTimer:
		filter := STATE_GET("Lister CurrentFilter")
		listName := getValue(filter, "list", "Default")
		if (listName <> "Process") {
			SetTimer, ProcessRefreshTimer, Off
		} else {
			process_UpdateList(filter)
		}
	Return
}

process_GetCPU(pid) {
	global
	value := PROC_C%pid%
	return value
}

process_OnColumnClick(A_Command, A_Args) {

	filter := STATE_GET("Lister CurrentFilter")
	listName := getValue(filter, "list", "Default")
	if (listName = "Process") {
		column := getValue(A_Args, "column")
		oldColumn := getValue(filter, "sort")
		sortDir := getValue(filter, "sortDir")
		if (column <> oldColumn) {
			sortDir := "Asc"
		} else if (sortDir = "Asc") {
			sortDir := "Desc"
		} else {
			sortDir := "Asc"
		}
		replaceValue(filter, "sort", column)
		replaceValue(filter, "sortDir", sortDir)

		STATE_SET("Lister CurrentFilter", filter)
	}
}

process_UpdateList(filter) {

	pcount := process_GetTimes()
	count := LV_GetCount()

	if (pcount <> count) {
		NOTIFY("List Update", "/listName:Process")
		Return
	}
	
	pidCol := lister_GetHeaderIndex(filter, "pid")
	cpuCol := lister_GetHeaderIndex(filter, "cpu")
	Loop, %count%
	{
		LV_GetText(pid, A_Index, pidCol)
		LV_GetText(oldCpu, A_Index, cpuCol)

		newCpu := process_GetCPU(pid)
		if (newCpu <> oldCpu) {
			LV_Modify(A_Index, "Col" . cpuCol , newCpu)
		}
	}
	column := getValue(filter, "sort", filter)
	sortDir := getValue(filter, "sortDir")

	if (column <> "") {
		index := lister_GetHeaderIndex(filter, column)
		LV_ModifyCol(index, sortDir = "Asc" ? "Sort" : "SortDesc")
	}
}

process_GetTimes() {

	global
	
	local pid_list, h_process, pid, oldEntry, oldKrnlTime, oldUserTime, CreationTime, Format_Float

	count := EnumProcesses( pid_list )

	loop, parse, pid_list, |
	{
		pid := A_LoopField

		h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", pid )
		if ( ErrorLevel = 0) AND ( h_process <> 0 )
		{
			DllCall("GetProcessTimes", "Uint", h_process, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime)
			DllCall( "CloseHandle", h_process )

			oldKrnlTime := PROC_K%pid%
			oldUserTime := PROC_U%pid%
			Format_Float := A_FormatFloat
			SetFormat, Float, 4
			PROC_C%pid% := (newKrnlTime - oldKrnlTime + newUserTime - oldUserTime) / 200000
			SetFormat, Float, %Format_Float%
			PROC_K%pid% := newKrnlTime
			PROC_U%pid% := newUserTime
		}
	}
	
	return count
}

process_GetList() {

	total := EnumProcesses( pid_list )

	list := list_Create()
	loop, parse, pid_list, |
	{
		pid := A_LoopField

		entry := "/listName:Process /type:process /pid:" . pid 

		h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", pid )
		if ( ErrorLevel = 0) AND ( h_process <> 0 )
		{
			name_size = 255
			VarSetCapacity( fileName, name_size )
if A_OSVersion in WIN_95,WIN_98,WIN_ME
	filename := GetProcessName(h_process)
else
			result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str", fileName, "uint", name_size )
			if (result <> 0) AND (fileName <> "") {
				SplitPath, fileName, FName
				entry := entry . " /name:" . FName . " /command:" . fileName
			} else {
				entry := entry . " /name:System"
			}

			DllCall("GetProcessTimes", "Uint", h_process, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime)
			DllCall( "CloseHandle", h_process )

			cpu := process_GetCPU(pid)
			if (cpu <> "") {
				entry := entry . " /cpu:" . cpu
			}

			commandLine := GetRemoteCommandLine(pid)
			if (commandLine <> "") {
				commandLine := Enc_XML(commandLine)
				entry := entry . " /commandLine:" . commandLine
			}
		} else if (pid = 0) {
			entry := entry . " /name:System Idle Process"
		}
		list_Add(list, entry)
	}
	Return list
}

EncodeInteger4(p_value, p_size, p_address, p_offset) {
	loop, %p_size%
		DllCall( "RtlFillMemory", "uint", p_address+p_offset+A_Index-1, "uint", 1, "uchar", p_value >> ( 8*( A_Index-1 ) ) )
}

ReportError( p_title, p_extra ) {
	syslist_Add("Errors", "/type:error /error:" ErrorLevel . " le:" . A_LastError . " extra:" . p_extra)
}

EnumProcesses(byref r_pid_list) {
	if A_OSVersion in WIN_95,WIN_98,WIN_ME 
	{
;		MsgBox, This Windows version (%A_OSVersion%) is not supported.
		return, false
	}

	pid_list_size := 4*1000
	VarSetCapacity( pid_list, pid_list_size )

	status := DllCall( "psapi.dll\EnumProcesses", "uint", &pid_list, "uint", pid_list_size, "uint*", pid_list_actual )
	if ( ErrorLevel or !status )
		return, false

	total := pid_list_actual//4

	r_pid_list=
	address := &pid_list
	loop, %total%
	{
		r_pid_list := r_pid_list "|" ( *( address )+( *( address+1 ) << 8 )+( *( address+2 ) << 16 )+( *( address+3 ) << 24 ) )
		address += 4
	}

	StringTrimLeft, r_pid_list, r_pid_list, 1

	return, total
}

GetRemoteCommandLine( p_pid_target )
{
	hp_target := DllCall( "OpenProcess"
		, "uint", 0x10                              ; PROCESS_VM_READ
		, "int", false
		, "uint", p_pid_target )

	if ( ErrorLevel or hp_target = 0 ) {
		return
	}

	hm_kernel32 := DllCall( "GetModuleHandle", "str", "kernel32.dll" )

	pGetCommandLineA := DllCall( "GetProcAddress", "uint", hm_kernel32, "str", "GetCommandLineA" )

	buffer_size = 6 
	VarSetCapacity( buffer, buffer_size ) 

	success := DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pGetCommandLineA, "uint", &buffer, "uint", buffer_size, "uint", 0 )
	if ( ErrorLevel or !success )
	{
		Gosub, return
	}

	loop, 4
		ppCommandLine += ( ( *( &buffer+A_Index ) ) << ( 8*( A_Index-1 ) ) )

	buffer_size = 4
	VarSetCapacity( buffer, buffer_size, 0 ) 

	success := DllCall( "ReadProcessMemory", "uint", hp_target, "uint", ppCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )
	if ( ErrorLevel or !success )
	{
		Gosub, return
	}

	loop, 4
		pCommandLine += ( ( *( &buffer+A_Index-1 ) ) << ( 8*( A_Index-1 ) ) )

	buffer_size = 32768
	VarSetCapacity( result, buffer_size, 1 )

	success := DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pCommandLine, "uint", &result, "uint", buffer_size, "uint", 0 )
	if ( !success )
	{
		loop, %buffer_size%
		{
			success := DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pCommandLine+A_Index-1, "uint", &result, "uint", 1, "uint", 0 )

			if ( !success or Asc( result ) = 0 )
			{
				buffer_size := A_Index
				break
			}
		}
		success := DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pCommandLine, "uint", &result, "uint", buffer_size, "uint", 0 )
		if ( ErrorLevel or !success )
		{
			result := ""
			Gosub, return
		}
	}

	return:
		DllCall( "CloseHandle", "uint", hp_target )

	return, result
}

process_EnableSomething() {

	success := DllCall( "advapi32.dll\LookupPrivilegeValueA"
		, "uint", 0
		, "str", "SeDebugPrivilege"
		, "int64*", luid_SeDebugPrivilege )

	if (success = 0) OR (ErrorLevel <> 0) {
		ReportError( "LookupPrivilegeValue: SeDebugPrivilege", "success = " success )
		return
	}

	Process, Exist
	pid_this := ErrorLevel

	hp_this := DllCall( "OpenProcess"
		, "uint", 0x400                                 ; PROCESS_QUERY_INFORMATION
		, "int", false
		, "uint", pid_this )

	if (hp_this = 0) OR (ErrorLevel <> 0) {
		ReportError( "OpenProcess: pid_this", "hp_this = " hp_this )
		Return
	}

	success := DllCall( "advapi32.dll\OpenProcessToken"
		, "uint", hp_this
		, "uint", 0x20                                 ; TOKEN_ADJUST_PRIVILEGES
		, "uint*", ht_this )

	if (success = 0) OR (ErrorLevel <> 0) {
		ReportError( "OpenProcessToken: hp_this", "success = " success )
		Return
	}

	VarSetCapacity( token_info, 4+( 8+4 ), 0 )
	EncodeInteger4( 1, 4, &token_info, 0 )
	EncodeInteger4( luid_SeDebugPrivilege, 8, &token_info, 4 )
	EncodeInteger4( 2, 4, &token_info, 12 )                           ; SE_PRIVILEGE_ENABLED

	success := DllCall( "advapi32.dll\AdjustTokenPrivileges"
		, "uint", ht_this
		, "int", false
		, "uint", &token_info
		, "uint", 0
		, "uint", 0
		, "uint", 0 )

	if (success = 0) OR (ErrorLevel <> 0) {
		ReportError( "AdjustTokenPrivileges: ht_this; SeDebugPrivilege ~ SE_PRIVILEGE_ENABLED", "success = " success )
		Return
	}

	DllCall( "CloseHandle", "uint", ht_this )
	DllCall( "CloseHandle", "uint", hp_this )
}

GetProcessName(p_pid)
{
  Return GetProcessInformation(p_pid, "Str", 0xFF, 36)  ; TCHAR szExeFile[MAX_PATH]
}

GetProcessInformation(p_pid, CallVariableType, VariableCapacity, DataOffset)
{
  hSnapshot := DLLCall("CreateToolhelp32Snapshot", "UInt", 2, "UInt", 0)  ; TH32CS_SNAPPROCESS = 2
  if (hSnapshot >= 0)
  {
    VarSetCapacity(PE32, 304, 0)  ; PROCESSENTRY32 structure -> http://msdn2.microsoft.com/ms684839.aspx
    if A_OSVersion in WIN_95,WIN_98,WIN_ME
	    DllCall("radmin32.dll\RtlFillMemoryUlong", "UInt", &PE32, "UInt", 4, "UInt", 304)  ; Set dwSize
   else
    DllCall("ntdll.dll\RtlFillMemoryUlong", "UInt", &PE32, "UInt", 4, "UInt", 304)  ; Set dwSize
    VarSetCapacity(th32ProcessID, 4, 0)
    if (DllCall("Process32First", "UInt", hSnapshot, "UInt", &PE32))  ; http://msdn2.microsoft.com/ms684834.aspx
      Loop
      {
        DllCall("RtlMoveMemory", "UInt *", th32ProcessID, "UInt", &PE32 + 8, "UInt", 4)  ; http://msdn2.microsoft.com/ms803004.aspx
        if (p_pid = th32ProcessID)
        {
          VarSetCapacity(th32DataEntry, VariableCapacity, 0)
          DllCall("RtlMoveMemory", CallVariableType, th32DataEntry, "UInt", &PE32 + DataOffset, "UInt", VariableCapacity)
          DllCall("CloseHandle", "UInt", hSnapshot)  ; http://msdn2.microsoft.com/ms724211.aspx
          Return th32DataEntry  ; Process data found
        }
        if not DllCall("Process32Next", "UInt", hSnapshot, "UInt", &PE32)  ; http://msdn2.microsoft.com/ms684836.aspx
          Break
      }
    DllCall("CloseHandle", "UInt", hSnapshot)
  }
  Return  ; Cannot find process
}
