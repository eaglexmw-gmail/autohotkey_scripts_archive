; Initialize/set our callback.
DllCallDebugger("OnDllCallFail")

; Should always succeed:
DllCall("MulDiv","int",1,"int",1,"int",1)
if ErrorLevel = 0
    MsgBox DllCall succeeded

; Should always fail:
DllCall("foo")
DllCall("MulDiv","int",1,"int",1)

OnDllCallFail() {
    MsgBox DllCall failed: %ErrorLevel%
}
