#include FcnLib.ahk
#include FcnLib-Clipboard.ahk

computerName:=Prompt("Which computer do you want to connect to?")
computerName:=StringUpper(computerName)

login=%computerName%\administrator

;Lynx password is now default. Other servers will have to be hardcoded in
;different work computers have different passwords
if (computername == "10.6.1.79")
{
   joe=Al3rtM3
   login=%computerName%\vendor-lynx
}
else if RegExMatch(computerName, "i)^(RUST|IRON|COPPER)$")
   joe:=SexPanther("work")
else if RegExMatch(computerName, "i)^LT\d$")
{
   joe:=SexPanther("work-lame")
   login=LAN\cameron
}
else
   joe:=SexPanther("lynx")
   ;if RegExMatch(computerName, "i)^(T-1|T-101|T-800|KP|BURNIN|RELEASE|LYNXGUIDE|PRIMARYFO|SECONDARYFO)$")

Clipboard := joe

RunProgram("C:\Windows\system32\mstsc.exe")
ForceWinFocus("Remote Desktop Connection", "Exact")
Sleep, 500

;expand the window if it isn't already expanded
WinGetActiveStats, no, winWidth, winHeight, no, no
Sleep, 1000
if (winHeight == 249)
   ClickButton("&Options")

;ClickButton("&Computer")
Sleep, 1000
Sleep, 1000
Sleep, 1000
Send, %computerName%
Sleep, 200
Send, {TAB}
Sleep, 200
Send, ^a
Sleep, 200
Send, %login%
Sleep, 200
Send, !a
Sleep, 200
ClickButton("Always &ask for credentials")
Sleep, 200
ClickButton("Co&nnect")

WinWaitActive, Windows Security
Sleep, 1000
paste()
;TODO might want to use SendViaClipboard instead
;Send, %joe%
Sleep, 100
Send, {ENTER}

