/* 
; < Go > Go where you wanna go, instantly!
Version = 1.04
; (Added pictures, streamlined script)
; Script created using Autohotkey (http://www.autohotkey.com) 
; AUTHOR: sumon @ the Autohotkey forums, < simon.stralberg (@) gmail.com>
; Edited-by:
; Changes:
v 1.05
	- Rearranged GoSettings GUI and made it white
	- Removed (hid) unused functions
	- Improved import ("Add/import")
v 1.04
	- Fixed the compiling images
	- Added default sites
	- Some more fixing
v 1.03
	- Fixed hotkeys (ctrl 1 - alt 9)
	- If there is no searchstring, go to main site (base off adress)
	- Added @x@ & @c@ for some clipboardaction
	- Fixed input behaviour - now considers strings with A_Space "triggers", and replaces them with a new one. If no trigger, search string.
V 1.02
	- Added basic intellisense (type shortkey -> space), hotkeys, etc.
	- Added change history. 
; LEGAL: Your may freely edit and use this code for personal use. However: Unless granted permission by the original author, you may ONLY redistribute it using the official Autohotkey forums, Autohotkey.net, or to friends. I retain authorship over the original code & idea. If you have any questions, please contact me at my above stated email. Regards, Simon.
;
; To-do-list: 
* Add icons for places without favicons
; * Add separate GoSettings [done]
; * Configurability (?), ability to add own searchpaths [done]
; * For searchengines, specify f.ex. G1:milk to go to the first hit of milk.
;
; Known bugs: 
; * No validation
; * Removing sites doesn't move the rest up in the list, annoying
*/
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force


; ******* Auto-Execute ******* ------------------------------------------------------

#IfWinActive, Go ; All hotkeys are "local"

; Commandline support: Provide one or two parameters. If two, the first is the "trigger". ":" is optional.
If 0 > 0
	Gosub, CommandLineSupport

IfNotExist, data\legal.txt
{
	Gui, 33:Default
	Gui, +owner
	gui, font, s10, Verdana  ; Set 10-point Verdana.
	Gui, Add, Text,, This is the first time you run Go `n`nExtract data to "/data" directory?
	Gui, Add, Button, x10 w125 h40 gGuiInstall default, Sure!
	Gui, Add, Button, x135 w125 yp h40 gGuiClose, No thanks!
	Gui, -Caption +Border
	Gui, Color, ffFFff
	Gui, Show
	return
}

; ******* Autorun Labels ******* ------------------------------------------------------
; Initializing
Initialize:
Menu, Tray, Nostandard
Menu, Tray, Icon, data\img\ico\go_icon.ico
Menu, Tray, Tip, Go! - Go anywhere
Menu, Tray, Add, Go, Search
	Menu, Tray, Icon, Go, data\img\ico\go_icon.ico,, 32
Menu, Tray, Add, Settings, SettingsGUI
	Menu, Tray, Icon, Settings, data\img\ico\settings.ico,, 32
Menu, Tray, Add, Help
	Menu, Tray, Icon, Help, data\img\ico\help.ico,, 32
Menu, Tray, Add ; ------
Menu, Tray, Add, Feedback
	Menu, Tray, Icon, Feedback, data\img\ico\feedback.ico,, 32
Menu, Tray, Add, Exit
	Menu, Tray, Icon, Exit, data\img\ico\exit.ico,, 32
ini_load(GoSites, "data\gosites.ini")

Search:
Gui, Destroy ; Refresh if needed
Gui, font, s10, Verdana
Gui, Add, Edit, x10 vSearchString w195,
SearchString_TT:="Enter searchstring and press site to search with"
; Pictures below
Column:=10 ; For first picture column
SitesList := ini_getAllSectionNames(GoSites)
Loop, Parse, SitesList, `,
{
	Trigger_%A_LoopField% := ini_getValue(GoSites, A_LoopField, "Trigger")
	SearchString_%A_LoopField% := ini_getValue(GoSites, A_LoopField, "SearchString")
	%Trigger%_TT := A_LoopField ; Hovering the icon with vTrigger shows correct TT
	Column := Column+20
	;~ Check := (A_Index-1)/10 ; New column each 10th item
	If (A_Index = 1 OR A_Index = 11 OR A_Index = 21) ; New column each 10th item
	{
		Column := 10
		IfExist, data\img\favico\%A_LoopField%.ico
			Gui, Add, Picture, x%column% w16 h16 gInsertString v%Trigger%, data\img\favico\%A_LoopField%.ico
		else
			Gui, Add, Picture, x%column% w16 h16 gInsertString v%Trigger%, data\img\favico\noicon.ico	
	}
	else
	{
		IfExist, data\img\favico\%A_LoopField%.ico
			Gui, Add, Picture, x%column% yp w16 h16 gInsertString v%Trigger%, data\img\favico\%A_LoopField%.ico
		else
			Gui, Add, Picture, x%column% yp w16 h16 gInsertString v%Trigger%, data\img\favico\noicon.ico			
	}
	; Below: Hotkeys Ctrl+1-9 to the first row (except #10, which has no hotkey) and Alt+1-9 to second
	If (A_Index < 10)
		Hotkey, ^%A_Index%, InsertString ; Adds a hotkey for launching with the site, ^1 - ^9
	If (A_Index > 10 AND A_Index < 20)
	{
		Key := A_Index - 10
		Hotkey, !%Key%, InsertString
	}
	
}

Gui, Add, Picture, x10 yp+30 vSettings gSettings, data\img\gui\settings.jpg
Settings_TT:="Settings"
Gui, Add, Button, x35 yp-6 h30 vGo gSubmit w145 Default, Go!
Gui, Add, Picture, x185 yp+6 vHelp gHelp, data\img\gui\help.jpg
Help_TT:="Help?"
OnMessage(0x200, "WM_MOUSEMOVE") ; Show tooltip
Gui, -Caption +Border
Gui, Color, ffffff
Gui, +LastFound +ToolWindow
Gui, Show,, Go
go_hwnd := WinExist()
WinSet, Transparent, 5, ahk_id %go_hwnd%
FadeIn(250, "ahk_id " . go_hwnd)
Hotkey, Space, CheckTrigger
return

; ******* Called Labels ******* ------------------------------------------------------

CheckTrigger: ; On pressing space, Performs a check on the trigger (in searchfield) to see if it can be expanded
Gui, Submit, Nohide
Trigger_Triggered := ""
SitesList := ini_getAllSectionNames(GoSites)
Loop, Parse, SitesList, `,
{
	Trigger := ini_getValue(GoSites, A_LoopField, "Trigger")
	if (SearchString = Trigger)
	{
		GuiControl,, SearchString, %A_LoopField%%A_Space%
		Trigger_Triggered := 1 ; True, to send space if false
		Trigger_Assigned := 1 ; True, for the InsertString subroutine
		Send {end}
		Break
	}
}
If (!Trigger_Triggered)
	Send, %A_Space%
return

InsertString: ; When a picture is clicked, insert equalivent string - or if string is inserted, go-to-link
If (A_ThisHotkey AND (A_TimeSinceThisHotkey < 500)) ; Insert by hotkey (ctrl+1 etc.). Note: Sime-since hotkey is because otherwise the previous hotkey was used on clicking pix.
{
	If InStr(A_ThisHotkey, "^")
		StringTrimLeft, Hotkey, A_ThisHotkey, 1
	else ; Else it's alt+something, so add +10
	{
		StringTrimLeft, Hotkey, A_ThisHotkey, 1
		Hotkey := Hotkey + 10
	}
	Loop, Parse, SitesList, `,
	{
		If (Hotkey = A_Index) ; Then this is the site we want
		{
			Site := A_LoopField
			break 
		} ; Else continue looping
	}
}
else ; Insert by GUI picture
	SplitPath, A_GuiControl,,,, Site ; Gets site name
Gui, Submit, Nohide
StringSplit, Output, SearchString, %A_Space%
Errorcheck := Output0
Trigger := Output1
Search1 := Output2
If (Output4)
	Search1 := Output2 . " " . Output3 . " " . Output4
Else if (Output3)
	Search1 := Output2 . " " . Output3
Else
	Search1 := Output2

If (Trigger and (!InStr(SearchString, A_Space))) ; If trigger was entered,but not a search is there
{
	GuiControl,, SearchString, %Site%%A_Space%%SearchString% ; inputs site name as "trigger"
	Gosub, Submit
}
else
{
GuiControl,, SearchString, %Site%%A_Space%
Send {End} ; To move the marker to the end
}
return

#include Feedback.ahk ; Feedback, FeedbackSubmit, FeedbackSendEmail [return]

Settings:
#include GoSettings.ahk

return
Help:
MsgBox, 32, Go Help!, Go lets you easely and define website (or file/folder!) shortcuts that may include a search phrase so you can not only visit a site`, but also search it directly.`n`nYou have four ways of inserting a site name: `n1) Type the full site name out ("Google")`n2) Click the icon for the site before or after typing your search`n3) Type the short letter out ("G") and press space`n4) Use Control+1 to Control+9 to launch site 1-9 (or Alt+1 -> 9 for 11-19, second row) before or after typing.`n`nSites and searchpatterns are entered using the settings dialog`, which you can access by clicking the asterisk to the left.
return

HideTrayTip:
TrayTip
return

Submit:
Gui, Submit
StringSplit, Output, SearchString, %A_Space%
Errorcheck := Output0
Trigger := Output1
Search1 := Output2
If (Output4)
	SearchString := Output2 . " " . Output3 . " " . Output4
Else if (Output3)
	SearchString := Output2 . " " . Output3
Else
	SearchString := Output2
if (Trigger)
{
	MainSiteSearch := ini_getValue(GoSites, Trigger, "SearchString") ; For use with below loop
	If (!SearchString AND !InStr(MainSiteSearch, "@c@") AND !InStr(MainSiteSearch, "@x@")) ; Trigger, but no searchstring or clipboardintention
	{
		MainSite := RegExMatch(MainSiteSearch, "(htt(p|ps)://)?(www\.)(.*)/", Match)
		Run % Match3 . Match4
		return ; !
	}
	
	AllSections := ini_getAllSectionNames(GoSites)
	Loop, Parse, AllSections, `,
	{
		If ((Trigger = A_LoopField) or (Trigger = ini_getValue(Gosites, A_LoopField, "Trigger")))
		{
			Search := ini_getValue(GoSites, A_LoopField, "SearchString")
			StringReplace, Search, Search, @s@, %SearchString%, All
			StringReplace, Search, Search, `%s, %SearchString%, All
			StringReplace, Search, Search, @c@, %Clipboard%, All
			If (SearchString)
				StringReplace, Search, Search, @x@, %SearchString%, All
			else
				StringReplace, Search, Search, @x@, %Clipboard%, All
			Run, %Search%
		}
	}
}
else ; If no Trigger was provided
	{
	SearchString := Trigger
	If (InStr(Searchstring, "www"))
		Run, %SearchString%
	else
		Loop, Parse, SitesList, `,
	{
		If (A_LoopField = SearchString)
			Run %SearchString%
	}
		Run, http://www.google.com/search?&q=%SearchString%
	}
Gosub, Exit
return

;~ ~Esc::
GuiEscape:
GuiClose:
Exit:
FadeOut(250, "ahk_id " . go_hwnd)
; ini_saveini("data\GoSites.ini")
Sleep 1000
ExitApp
return

GuiInstall:
Gui, 33: Destroy
Gosub, InstallFiles
Return


SetupIcons:
MsgBox Hint! Run GoSettings first to import premade sites.
TrayTip, Go:, Downloading icons, 3, 1
Loop, 21
{
	If (IconDownload_%A_Index%)
	{
		icon:=icon_%A_Index%
		UrlDownloadToFile, % IconDownload_%A_Index%, data\img\%icon%.ico
	}
	else
		Icon_%A_Index%:="data\img\standardicon.ico"
}
TrayTip
return

CommandLineSupport:

CommandlineN := %0%
CommandLine1 := %1%
CommandLine2 := %2%
If (CommandLineN = 1)
{
	StringReplace, CommandLine1, CommandLine1, :,, All
	SearchString := CommandLine1 . ":" . CommandLine2
	Traytip, Go, You provided %SearchString%, 5
	Gosub, Submit
}
Sleep 4000
return

InstallFiles:
Notify("Go:", "Extracting...", 2)
FileCreateDir, data
	FileInstall, data\legal.txt, data\legal.txt
	FileInstall, data\GoSites_default.ini, data\GoSites.ini ; Note: Default sites: Google/Google Pix/Wikipedia/Youtube/Google Maps
FileCreateDir, data\img
FileCreateDir, data\img\gui
	FileInstall, data\img\gui\addicon.jpg, data\img\gui\addicon.jpg
	FileInstall, data\img\gui\export.jpg, data\img\gui\export.jpg
	FileInstall, data\img\gui\exported.jpg, data\img\gui\exported.jpg
	FileInstall, data\img\gui\help.jpg, data\img\gui\help.jpg
	FileInstall, data\img\gui\import.jpg, data\img\gui\import.jpg
	FileInstall, data\img\gui\imported.jpg, data\img\gui\imported.jpg
	FileInstall, data\img\gui\settings.jpg, data\img\gui\settings.jpg
	FileInstall, data\img\gui\delete.jpg, data\img\gui\delete.jpg
	FileInstall, data\img\gui\deleted.jpg, data\img\gui\deleted.jpg
	FileInstall, data\img\gui\settings_header.jpg, data\img\gui\settings_header.jpg
FileCreateDir, data\img\favico
	FileInstall, data\img\favico\google.ico, data\img\favico\google.ico
	FileInstall, data\img\favico\google_pictures.ico, data\img\favico\google_pictures.ico
	FileInstall, data\img\favico\google_maps.ico, data\img\favico\google_maps.ico
	FileInstall, data\img\favico\ahk_cmd.ico, data\img\favico\ahk_cmd.ico
	FileInstall, data\img\favico\youtube.ico, data\img\favico\youtube.ico
	FileInstall, data\img\favico\wikipedia.ico, data\img\favico\wikipedia.ico
FileCreateDir, data\img\ico
	FileInstall, data\img\ico\feedback.ico, data\img\ico\feedback.ico
	FileInstall, data\img\ico\go_icon.ico, data\img\ico\go_icon.ico
	FileInstall, data\img\ico\settings.ico, data\img\ico\settings.ico
	FileInstall, data\img\ico\help.ico, data\img\ico\help.ico
	FileInstall, data\img\ico\exit.ico, data\img\ico\exit.ico
	; 
	FileInstall, data\img\ico\add_site.ico, data\img\ico\add_site.ico
	FileInstall, data\img\ico\config.ico, data\img\ico\config.ico
	FileInstall, data\img\ico\export_all.ico, data\img\ico\export_all.ico
	FileInstall, data\img\ico\import_all.ico, data\img\ico\import_all.ico
	FileInstall, data\img\ico\import.ico, data\img\ico\import.ico
	FileInstall, data\img\ico\save.ico, data\img\ico\save.ico
FileCreateDir, data\sites
Notify("Go:", "Done!", 3)
Gosub, Initialize
return

; ****** FUNCTIONS *** ***
ResetMouse:
return

WM_MOUSEMOVE() ; NOT FUNCTIONING CORRECTLY
{
	Text := A_GuiControl
	If (InStr(A_GuiControl, "\"))
	{
		SplitPath, A_GuiControl,,,, OutNameNoExt
		StringReplace, Text, OutNameNoExt, _, %A_Space%, All
	}
	If A_GuiControl
		SB_SetText(Text)
	else
		SB_SetText("...")
	return
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
	If (CurrControl = PrevControl)
		return
	If (InStr(A_GuiControl, "."))
	{
		SplitPath, CurrControl,,,, Site ; Gets site name
		TT := Trigger_%Site% . ": " . Site
	}
	else
		TT := %CurrControl%_TT
	Tooltip
	SetTimer, DisplayTooltip, 100
	PrevControl = CurrControl
	/*
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 100
        PrevControl := CurrControl
    } 
	*/
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip %TT%  ; The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 2000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

FadeIn(GUI_TRANS, WinName)
{
	transL := 0
	Loop, 10
	{
		transL += GUI_TRANS//10
		WinSet, Transparent, %transL%, %WinName%
		Sleep, 10
	}
}

FadeOut(GUI_TRANS, WinName)
{
	transL := GUI_TRANS
	Loop, 10
	{
		transL -= GUI_TRANS//10
		WinSet, Transparent, %transL%, %WinName%
		Sleep, 10
	}
}
