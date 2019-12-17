#Include IEControl.ahk
#SingleInstance force

GoSub, GuiStart

Gui, +LastFound +Resize
Gui, Show, w800 h600 Center, WebBrowser
hWnd := WinExist()

CLSID_WebBrowser := "{8856F961-340A-11D0-A96B-00C04FD705A2}"
IID_IWebBrowser2 := "{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}"
pwb := CreateObject(CLSID_WebBrowser, IID_IWebBrowser2)

AtlAxAttachControl(pwb, hWnd)

IE_LoadURL(pwb, "http://www.autohotkey.com/")
Sleep 5000
IE_LoadURL(pwb, "http://www.autohotkey.com/forum/")
Sleep 5000
IE_GoBack(pwb)
Sleep 3000
IE_GoForward(pwb)
Return

GuiStart:
AtlAxWinInit()
CoInitialize()
Return

GuiClose:
Gui, %A_Gui%:Destroy
Release(pwb)
CoUninitialize()
AtlAxWinTerm()
ExitApp

;example
Gui, +lastfound
h := WinExist()

IE_Add( h, 0, 0, 500, 500)

; Must be equal to or larger than the IE_Add size
; or some of the displayed web page will be cut off.
Gui, Show, h500 w500

IE_LoadURL("www.yahoo.com")
return
