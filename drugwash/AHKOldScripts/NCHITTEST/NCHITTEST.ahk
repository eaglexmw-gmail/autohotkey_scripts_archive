; heresy
;
; Thanks to Sean for http://www.autohotkey.com/forum/viewtopic.php?t=22178#141704

#NoEnv
#NoTrayIcon
SetWinDelay, -1
CoordMode, Mouse, Screen
ToolTip("Script Started")
EmptyMem()

*~RButton::NCHITTEST()

NCHITTEST(){
    MouseGetPos, x, y, hwnd
    SendMessage, 0x84, 0, (x&0xFFFF) | (y&0xFFFF) << 16,, ahk_id %hwnd%
    RegExMatch("ERROR TRANSPARENT NOWHERE CLIENT CAPTION SYSMENU SIZE MENU HSCROLL VSCROLL MINBUTTON MAXBUTTON LEFT RIGHT TOP TOPLEFT TOPRIGHT BOTTOM BOTTOMLEFT BOTTOMRIGHT BORDER OBJECT CLOSE HELP", "(?:\w+\s+){" . ErrorLevel+2&0xFFFFFFFF . "}(?<AREA>\w+\b)", HT)
    ;if GetKeyState("Alt") reserved for winmove in dual monitor environment
    ;if GetKeyState("Shift") reserved
    ;if GetKeyState("LWin") reserved
    if htarea in CLIENT,CAPTION,SYSMENU,HSCROLL,VSCROLL,OBJECT,HELP,ERROR,TRANSPARENT,NOWHERE
        Return
    else if (GetKeyState("CTRL") && htarea="CLOSE"){
        ToolTip, Script will exit in 3 secs..
        Sleep, 3000
        Exitapp
    }
    else if (htarea="CLOSE"){
        WinGet, tVal, Transparent, ahk_id %hwnd%
        WinSet, Trans, % (tVal!=127) ? 127 : 255, ahk_id %hwnd%
    } else if (htarea="MAXBUTTON"){
        WinGet, aVal, ExStyle, ahk_id %hwnd%
        WinSet, AlwaysOnTop, % (aVal & 0x8) ? "Off" : "On", ahk_id %hwnd%
        ToolTip((aVal & 0x8) ? "Always On Top : Off" : "Always On Top : On")
    } else if (htarea="MINBUTTON")
        tooltip("reserved")
    else if (GetKeyState("CTRL") && htarea="TOPLEFT")
        SizeWin(hwnd, "LTOP")
    else if (htarea="TOPLEFT")
        MoveWin(hwnd)
    else if (GetKeyState("CTRL") && htarea="TOP")
        SizeWin(hwnd, "TOP")
    else if (htarea="TOP")
        MoveWin(hwnd, "U")
    else if (GetKeyState("CTRL") && htarea="TOPRIGHT")
        SizeWin(hwnd, "RTOP")
    else if (htarea="TOPRIGHT")
        MoveWin(hwnd, "RU")
    else if (GetKeyState("CTRL") && htarea="RIGHT")
        SizeWin(hwnd, "RIGHT")
    else if (htarea="RIGHT")
        MoveWin(hwnd, "R")
    else if (GetKeyState("CTRL") && (htarea="BOTTOMRIGHT" || A_Cursor="SizeNWSE"))
        SizeWin(hwnd, "RBOTTOM")
    else if (htarea="BOTTOMRIGHT" || A_Cursor="SizeNWSE")
        MoveWin(hwnd, "RB")
    else if (GetKeyState("CTRL") && htarea="BOTTOM")
        SizeWin(hwnd, "BOTTOM")
    else if (htarea="BOTTOM")
        MoveWin(hwnd, "B")
    else if (GetKeyState("CTRL") && htarea="BOTTOMLEFT")
        SizeWin(hwnd, "LBOTTOM")
    else if (htarea="BOTTOMLEFT")
        MoveWin(hwnd, "LB")
    else if (GetKeyState("CTRL") && htarea="LEFT")
        SizeWin(hwnd, "LEFT")
    else if (htarea="LEFT")
        MoveWin(hwnd, "L")
    else if (GetKeyState("CTRL") && htarea="MENU"){
        WinGet, MMState, MinMax, ahk_id %hwnd%
        if MMState=1
            WinRestore, ahk_id %hwnd%
        SizeWin(hwnd, "CENTER")
    } else if (htarea="MENU"){
        WinGet, MMState, MinMax, ahk_id %hwnd%
        if MMState=1
            WinRestore, ahk_id %hwnd%
        MoveWin(hwnd, "Center")
    }
}

MoveWin(wHwnd, Pos="LU"){
    WinGetPos,,, W, H, ahk_id %wHwnd%
    SysGet, m, MonitorWorkArea
    if (pos="LU")
        WinMove, ahk_id %wHwnd%,, 0, 0
    else if (pos="L")
        WinMove, ahk_id %wHwnd%,, 0, % (mBottom-H)//2
    else if (pos="LB")
        WinMove, ahk_id %wHwnd%,, 0, % mBottom-H
    else if (pos="B")
        WinMove, ahk_id %wHwnd%,, % (mRight-W)//2, % mBottom-H
    else if (pos="RB")
        WinMove, ahk_id %wHwnd%,, % mRight-W, % mBottom-H
    else if (pos="R")
        WinMove, ahk_id %wHwnd%,, % mRight-W, % (mBottom-H)//2
    else if (pos="RU")
        WinMove, ahk_id %wHwnd%,, % mRight-W, 0
    else if (pos="U")
        WinMove, ahk_id %wHwnd%,, % (mRight-W)//2, 0
    else if (pos="Center")
        WinMove, ahk_id %wHwnd%,, % (mRight-W)//2, % (mBottom-H)//2
}

SizeWin(wHwnd, Pos){
    WinGetPos,,, W, H, ahk_id %wHwnd%
    SysGet, m, MonitorWorkArea
    if (pos="TOP")
        WinMove, ahk_id %wHwnd%,, 0, 0, %mRight%, % mBottom//2
    else if (pos="LEFT")
        WinMove, ahk_id %wHwnd%,, 0, 0, % mRight//2, %mBottom%
    else if (pos="BOTTOM")
        WinMove, ahk_id %wHwnd%,, 0, % mBottom//2, %mRight%, % mBottom//2
    else if (pos="RIGHT")
        WinMove, ahk_id %wHwnd%,, % mRight//2, 0, % mRight//2, %mBottom%
    else if (pos="CENTER")
        WinMove, ahk_id %wHwnd%,, % (mRight//2)//2, % (mBottom//2)//2, % mRight//2, % mBottom//2
    else if (pos="LTOP")
        WinMove, ahk_id %wHwnd%,, 0, 0, % mRight//2, % mBottom//2
    else if (pos="LBOTTOM")
        WinMove, ahk_id %wHwnd%,, 0, % mBottom//2, % mRight//2, % mBottom//2
    else if (pos="RTOP")
        WinMove, ahk_id %wHwnd%,, % mRight//2, 0, % mRight//2, % mBottom//2
    else if (pos="RBOTTOM")
        WinMove, ahk_id %wHwnd%,, % mRight//2, % mBottom//2, % mRight//2, % mBottom//2
}

ToolTip(S, Seconds=2500, X="", Y="") {
    SetTimer, Off, %Seconds%
    ToolTip, %S%, %X%, %Y%
    Return
   
    Off:
    ToolTip
    SetTimer, Off, Off
    Return
}

EmptyMem(PID="AHK Rocks"){
    pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}
