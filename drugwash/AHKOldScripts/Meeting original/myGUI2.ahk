Gui, 90:Add, GroupBox, x8 y1 w378 h260 , Settings
Gui, 90:Add, Text, x16 y15 w300 h20 +0x200, Select your preferred text editor:
Gui, 90:Add, Edit, x16 y37 w300 h20 +0x200 vmyeditor, 
Gui, 90:Add, Button, x318 y37 w60 h20 gselectedit, Browse
Gui, 90:Add, Text, x16 y59 w180 h20 +0x200, Hotkey for editor's 'Refresh' function:
Gui, 90:Add, Hotkey, x199 y59 w65 h20 vehk1, 
Gui, 90:Add, Hotkey, x266 y59 w50 h20 vehk2, 
Gui, 90:Add, Hotkey, x318 y59 w60 h20 vehk3, 
Gui, 90:Add, Text, x16 y81 w300 h20 +0x200, Select seriatim file for this event (leave blank to create new):
Gui, 90:Add, Edit, x16 y103 w300 h20 vGizmo, 
Gui, 90:Add, Button, x318 y103 w60 h20 gselectser, Browse
Gui, 90:Add, Text, x16 y125 w300 h20 +0x200, Select storage path for seriatim file (leave blank for app folder):
Gui, 90:Add, Edit, x16 y147 w300 h20 vfilepath, 
Gui, 90:Add, Button, x318 y147 w60 h20 gselfilepath, Browse
Gui, 90:Add, Text, x16 y169 w300 h20 +0x200, Select speaker list for this event (leave blank to create new):
Gui, 90:Add, Edit, x16 y191 w300 h20 vGomi, 
Gui, 90:Add, Button, x318 y191 w60 h20 gselectspk, Browse
Gui, 90:Add, Text, x16 y213 w300 h20 +0x200, Select storage path for speaker list (leave blank for app folder):
Gui, 90:Add, Edit, x16 y235 w300 h20 vspkpath, 
Gui, 90:Add, Button, x318 y235 w60 h20 gselspkpath, Browse
Gui, 90:Add, Text, x16 y267 w180 h30 +Center +Border +Border, Place for name && version,`npicture logo, etc.
Gui, 90:Add, Button, x206 y267 w110 h30 , &Run
Gui, 90:Add, Button, x318 y267 w60 h30 , E&xit
Gui, 90:+OwnDialogs
Gui, 90:Show, x350 y160 h305 w395, Settings
Return

selectedit:
FileSelectFile, myeditor, 3,, Select your preferred text editor (leave blank for default):, Application (*.exe)
IfNotExist, %myeditor%
	myeditor = Notepad
GuiControl,, myeditor, %myeditor%
return

selectser:
FileSelectFile, Gizmo, 3,, Select seriatim file for this event (leave blank to create new):, Text file (*.txt)
IfNotExist, %Gizmo%
	Gizmo = %A_MM%-%A_DD%.txt
GuiControl,, Gizmo, %Gizmo%
return

selectspk:
FileSelectFile, Gomi, 3,, Select speaker list for this event (leave blank to create new):, Text file (*.txt)
IfNotExist, %Gomi%
	{
	neededit=1
	Gomi = %A_Desktop%\00Speakerlist%A_MM%%A_DD%%A_Hour%%A_Min%.txt
	FileAppend,Speaker 1`r`nSpeaker 2 `r`nSpeaker 3 `r`nSpeaker 4 `r`n@Table,%Gomi% ;Creates a generic speaker list
	}
GuiControl,, Gomi, %Gomi%
return

selfilepath:
FileSelectFolder, filepath, *%A_WorkingDir%, 3, Select storage path for seriatim file (leave blank for app folder):
IfNotExist, %filepath%
	filepath := A_WorkingDir
filepath := RegExReplace(filepath, "\\$")
GuiControl,, filepath, %filepath%
return

selspkpath:
FileSelectFolder, spkpath, *%A_WorkingDir%, 3, Select storage path for speaker list (leave blank for app folder):
IfNotExist, %spkpath%
	spkpath := A_WorkingDir
spkpath := RegExReplace(spkpath, "\\$")
GuiControl,, spkpath, %spkpath%
return

90ButtonExit:
90GuiClose:
ExitApp

90ButtonRun:
Gui, Submit, NoHide ; needs double-check for filename/path errors
Gui, 90:Hide
Gizmo := filepath "\" Gizmo
Gomi := spkpath "\" Gomi
Rosie =
nn =
if neededit
	{
	Msgbox,%Gomi% is your speaker list.  Start by changing the examples to your actual speakers.  You may add as many as you wish.  Make them one name per line only. Numbers and Letters only`, no commas`,colons`, semicolons or any other funny business.  Periods are allowed. You may always revise the list and restart the program again too. Pls. note that one called `"table`" has no button and can be shaped and resized to resemble oh, say, a table.  You may create buttonless GUIs for this purpose by prefixing their name with the `"`@`" symbol.
	RunWait %myeditor% %Gomi%
	Sleep, 3000	; allow the OS to save the file properly
	}
MsgBox,You will need to turn on `"append mode under `"Record`/Play`" on the toolbar menu`, and you will also need to select `"show sound image`" either `"in panel`" or `"in separate window.`"  It is presumed that you have a working knowledge of Total Recorder prior to using this.  If so`, now would be a good time to start the recording.  If not`, you should exit this program and go learn your way around TR before trying this.

IfWinExist,ahk_class TotalRecorderWndClass
WinActivate,ahk_class TotalRecorderWndClass


