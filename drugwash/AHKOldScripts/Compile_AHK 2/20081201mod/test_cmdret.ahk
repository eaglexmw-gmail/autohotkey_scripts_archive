cmd_in := "reshacker.exe -script ChangeIcon.script" 
t1 := A_TickCount
cmd_out1 := CMDret_RunReturn(cmd_in)
cmd_in := "reshacker.exe -script ChangeVersionInfo.script" 
cmd_out2 := CMDret_RunReturn(cmd_in)
t2 := A_TickCount - t1
wtime := TConv(t2)
MsgBox, Operation finished in %wtime% (%t2%ms)`nExecuted: %cmd_out1%`nExecuted: %cmd_out2%

GuiClose:
ExitApp

TConv(milli)
{
	hour := Floor(milli / 3600000)
	hour := hour < 10 ? "0" . hour : hour
	min  := Mod(Floor(milli / 60000), 60)
	min := min < 10 ? "0" . min : min
	sec  := Mod(Floor( milli / 1000), 60)
	sec := sec < 10 ? "0" . sec : sec
	msec  := Mod(milli, 1000)
	msec := msec < 100 ? "0" . msec : msec
	msec := msec < 10 ? "0" . msec : msec
	Return hour "h" min "m" sec "s" msec "ms"
}

#include cmdret_ahk.ahk
