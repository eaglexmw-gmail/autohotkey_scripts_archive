#include FcnLib.ahk

fatalIfNotThisPC("baustian-09pc-OLD")

RunProgram("C:\Program Files\HyCam2\HyCam2.exe")
ForceWinFocus("HyperCam")
SleepSeconds(1)
Send, {F2}

SleepMinutes(5)

Send, {F2}
WinWait, HyperCam, , 1
WinClose, HyperCam
SleepSeconds(1)
ProcessCloseAll("HyCam2.exe")
