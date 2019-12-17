SetBatchLines -1
Loop, HKEY_LOCAL_MACHINE, Enum\MONITOR, 1, 1
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
		found%num% := value
		}
	}
Loop, %num%
	MsgBox, % "found= " found%A_Index%
return

; HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Class\Monitor\0000 > 0007

;******** search monitor names ********
  ; Makes searching occur at maximum speed.
RegSearchTarget = DeviceDesc  ; Tell the subroutine what to search for.
Gosub, RegSearch
MsgBox, Finished searching.
ExitApp
return

RegSearch:
ContinueRegSearch = y
Loop, HKEY_LOCAL_MACHINE, Enum\MONITOR\*, 1, 1
{
    Gosub, CheckThisRegItem
    if ContinueRegSearch = n ; It told us to stop.
        return
}
return

CheckThisRegItem:
;if A_LoopRegType = KEY  ; Remove these two lines if you want to check key names too.
;    return
RegRead, RegValue
if ErrorLevel
    return
IfInString, RegValue, %RegSearchTarget%
{
    MsgBox, 4, , The following match was found:`n%A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%`nValue = %RegValue%`n`nContinue?
    IfMsgBox, No
        ContinueRegSearch = n  ; Tell our caller to stop searching.
}
return
