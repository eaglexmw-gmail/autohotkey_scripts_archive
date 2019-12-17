; function to replace RunWait in Win9x
; parameters are:
; file = process filename (with extension, without path)
; time = time to wait until aborting (in seconds)
; force = force kill process on timeout
; ph = progressbar height
; pw = progressbar width
/*
fileRun := "ResHacker.exe"
comm := "bla"
RunWaitEx(fileRun, comm, 10, 1, 15, 250)
MsgBox, Status: %res%`n%errMsg%
ExitApp
*/
RunWaitEx(file, cmmd, time, force=0, ph=10, pw=100)
{
Global res, errMsg
pr = 0
res = 0
inc := 100 / time
RunWait, %cmmd%,, UseErrorLevel Hide
;RunWait, C:\Windows\command.com /c "ResHacker.exe -script ChangeIcon.script",, UseErrorLevel
MsgBox, Process launched:`n%cmmd%
Process, Wait, %file%
MsgBox, Process found.
progress, B ZH%ph% ZX0 ZY0 W%pw% CB000000 CWFFFFFF
Loop
	{
	Process, Exist, %file%
	if (!ErrorLevel || pr >= 100)
		break
	progress, %pr%
	pr += inc
	sleep, 1000
	}
progress, off
if (pr >= 100)
	{
	res ++
	if force
		{
		Process, Close, %file%
		if !ErrorLevel
			res ++
		}
	}
if res = 1
	errMsg := "Process " . file . " killed successfully !"
else if res  = 2
	errMsg := "Error killing process " . file . " !"
else
	errMsg := "Process " . file . " ended in time."
return res, errMsg
}
