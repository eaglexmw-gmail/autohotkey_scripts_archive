; http://www.autohotkey.com/forum/topic32824.html

AnimateWindow(hwnd,time,options){
    local H:=65536, A:=131072, C:=16, B:=524288, S:=262144, R:=1, L:=2, D:=4, U:=8, O:="HACBSLURD", opt=0, format:=""
    format:= A_FormatInteger
    SetFormat, integerfast, Hex
    Loop,parse,Options
        If InStr(O,A_LoopField)
            opt := opt + %A_LoopField%
    If opt
        DllCall("AnimateWindow", "UInt", hwnd, "Int", time, "UInt", opt)
    SetFormat, integerfast,%format%
}
