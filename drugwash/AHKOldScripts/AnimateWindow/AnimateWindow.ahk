; http://www.autohotkey.com/forum/topic32824.html

AnimateWindow(hwnd,time,options){
    local H:=0x10000, A:=0x20000,C:=0x10, B:= 0x80000,S:=0x40000,R:= 0x1, L:=0x2, D:=0x4, U:=0x8,O:="HACBSLURD",opt:="",format:=""
    format:= A_FormatInteger
    SetFormat, integerfast, Hex
    opt := 0x0 + 0
    Loop,parse,Options
        If InStr(O,A_LoopField)
            opt |= %A_LoopField%
msgbox, options: %opt%
    If opt
        DllCall("AnimateWindow", "UInt", hwnd, "Int", time, "UInt", opt)
    SetFormat, integerfast,%format%
}
