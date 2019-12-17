; http://www.autohotkey.com/forum/viewtopic.php?t=3719

Gui, Show, w300 h100, Text to Talk
Gui, Add, Text, x5 y5 w30 h20, Text:
Gui, Add, Edit, vTXT x40 y5 w245 R4,Type text in here, And Press TALK.
Gui, Add, Button, w60 h20, TALK
return

GuiClose:
ExitApp

ButtonTALK:
Gui, Submit, NoHide
TEMPFILE = %TEMP%\TALK.vbs
IfExist, %TEMPFILE%
   FileDelete, %TEMPFILE%
FileAppend, Dim Talk`nSet Talk = WScript.CreateObject("SAPI.SpVoice")`nTalk.Speak "%TXT%", %TEMPFILE%
RunWait, %TEMPFILE%
FileDelete, %TEMPFILE%
Return
