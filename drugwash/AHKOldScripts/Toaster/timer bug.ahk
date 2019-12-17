p1=1
p2=2
p3=3
result := myfunc(p1, p2, p3)
;wait()
MsgBox, Result is %result%
ExitApp

myfunc(param1, param2, param3)
	{
	static var1, var2, var3, GID
	res=0
	var1:=param1
	var2:=param2
	var3:=param3
;	Gui, Show, Hide, mygui
	MsgBox, Message1: %param1%, %param2%, %param3%
	SetTimer, mytimer, -5000
	WinWait, %A_ScriptName%
	return res

mytimer:
	res=1
	MsgBox, Message2: %param1%, %param2%, %param3%
	MsgBox, Message3: %var1%, %var2%, %var3%
	return
	}

wait(GID="")
	{
	If not (GID)
		GID := WinExist("mygui")
	WinWaitClose, ahk_id %GID%
	}
