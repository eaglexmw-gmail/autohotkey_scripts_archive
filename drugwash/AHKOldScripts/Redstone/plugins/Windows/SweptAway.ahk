#include CR_PluginClient.ahk

; Swept Away
; Author:         Adam Pash <adam@lifehacker.com>
; A simple implementation of Spirited Away (http://www.versiontracker.com/dyn/moreinfo/macosx/24877) for Windows
; for Windows:
; Script Function:
;	Designed to minimize unused windows after a pre-defined time 
;	useful for uncluttering your active desktop
;	

collection=
disable := 0

Return

sweptAway_Initialize() {

	global PollTime := 1000

	CommandRegister("SweptAway MenuItem", "sweptAway_MenuItem")
	CommandRegister("SweptAway Exclude", "sweptAway_Exclude")
	CommandRegister("SweptAway Include", "sweptAway_Include")

	NotifyRegister("UI BuildMenu", "sweptaway_OnBuildMenu")
	NotifyRegister("List Update", "sweptaway_OnListUpdate")

	SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
	SetWorkingDir, "%A_ScriptDir%"
	DetectHiddenWindows,Off
	Gosub,READINI
	Gosub,TRAYMENU
	Gosub,RESOURCES

	SetTimer, Start, %PollTime%
}

sweptaway_OnBuildMenu(A_Command, A_Args) {

	type := getValue(A_Args, "type")

	if (type = "Window") {
		menu := removeValue(A_Args, "menu")
		wid := getValue(A_Args, "wid")
		WinGet,processName,ProcessName,ahk_id %wid%

		if (syslist_Get("SweptAwayExcludes", "/single:Yes /filter:name=" . processName) = "") {
			COMMAND("Menu Add", "/menu:" . menu . " /item:Exclude from SweptAway /menuCommand:SweptAway Exclude /type:Window /Name:" . ProcessName)
		} else {
			COMMAND("Menu Add", "/menu:" . menu . " /item:Include in SweptAway /menuCommand:SweptAway Include /type:Window /Name:" . ProcessName)
		}
	}
}

sweptaway_OnListUpdate(A_Command, A_Args) {

	updatedListName := getValue(A_Args, "listName")
	if (updatedListName = "Windows") {
		sweptaway_ActiveWindow()
	}
}

sweptaway_ActiveWindow() {
	global

	windows := syslist_Get("Windows")
	Loop, Parse, windows, `n
	{
		windowID := getValue(A_LoopField, "wid")
		StringTrimLeft,windowID,windowID,0
		if collection not contains %windowID%
		{
			collection = %collection%,%windowID%
			%windowID%_Now = %A_Now%
		}
		IfWinActive, ahk_id %windowID%
		{
			%windowID%_Now = %A_Now%
		}
	}
}

START:
	Loop,Parse,collection,CSV
	{
		windowID := A_LoopField
		diff := %windowID%_Now
		EnvSub,diff,A_Now,seconds
		Transform,diff,Abs,diff
		if diff > %sweepTime%
		{
			WinGet,processName,ProcessName,ahk_id %windowID%
			if processName not contains .scr
			{
				if (syslist_Get("SweptAwayExcludes", "/single:Yes /filter:name=" . processName) = "")
				{
					WinGet,mini,MinMax,ahk_id %windowID% 
					if mini != -1 
					{
						IfWinNotActive,ahk_id %windowID%
						{
							PostMessage, 0x112, 0xF020,,, ahk_id %windowID% ; 0x112 = WM_SYSCOMMAND, 0xF020 = SC_MINIMIZE
						}
					}
				}
			}
			StringReplace,collection,collection,`,%windowID%,,All
		}
	}
return

TRAYMENU:
	COMMAND("Menu Add", "/menu:SweptAway /item:Preferences /menuCommand:SweptAway MenuItem /option:Preferences")
	COMMAND("Menu Add", "/menu:SweptAway /item:Help /menuCommand:SweptAway MenuItem /option:Help")
	COMMAND("Menu Add", "/menu:SweptAway")
	COMMAND("Menu Add", "/menu:SweptAway /item:About /menuCommand:SweptAway MenuItem /option:About")
	COMMAND("Menu Add", "/menu:SweptAway /item:Disable /menuCommand:SweptAway MenuItem /option:Disable")
	if disable = 1
		COMMAND("Menu Action", "/menu:SweptAway /action:Check /item:Disable")
	COMMAND("Menu Add", "/menu:Tray /item:Swept Away /submenu:SweptAway")
Return

sweptAway_MenuItem(A_Command, A_Args) {
	option := getValue(A_Args, "option")
	if (option = "Preferences") {
		gosub,PREFS
	} else if (option = "Help") {
		Run,http://lifehacker.com/software//lifehacker-code-swept-away-windows-255055.php
	} else if (option = "About") {
		gosub,ABOUT
	} else if (option = "Disable") {
		gosub,DISABLE
	}
}

PREFS:
	Gui,Destroy
	Gui, Add, Text, x226 y40 w-10 h-10 , Text
	Gui, Add, UpDown, x33266 y33010 w-33270 h-34060 , UpDown
	Gui, Font, S12 CDefault, Arial
	Gui, Add, Text, x16 y10 w170 h20 , Time before minimizing:
	Gui, Add, Edit, vSeconds x26 y30 w100 h30 , %sweepTime%
	IniRead,PollTime,sweptaway.ini,Preferences,PollTime
	Gui, Add, Text, x16 y70 w330 h20 , Polling time in milliseconds:
	Gui, Font, S10 CDefault, Arial
	;Gui, Add, Text, x26 y90 h40 w330, This setting determines how often Swept Away checks out which windows are active.  If you're having CPU problems, try adjusting the poll time to a higher number.
	Gui, Add, Text, x186 y10 w80 h20 , (in seconds)
	Gui, Add, Text, x210 y70 w120 h20 ,(requires restart)
	Gui, Add, Text, x130 y100 w120 h20 , (1000 = 1 second)
	Gui, Font, S12 CDefault, Arial
	Gui, Add, Edit, vPoll x26 y90 w100 h30 , %PollTime%
	Gui, Font, S10 CDefault, Arial
	Gui, Add, Button, x156 y180 w100 h30 gOK default,&OK
	Gui, Add, Button, x266 y180 w90 h30 gCANCEL, Cancel
	; Generated using SmartGUI Creator 4.0
	Gui, Show, h215 w363,Swept Away Preferences

	Return

	OK:
		Gui,Submit
		Gui,Destroy
		IniWrite,%Seconds%,sweptaway.ini,Preferences,Timer
		IniWrite,%Poll%,sweptaway.ini,Preferences,PollTime
		Gosub,READINI
	return

	CANCEL:
		Gui,Destroy
	return
Return

sweptAway_Exclude(A_Command, A_Args) {
	syslist_Add("SweptAwayExcludes", A_Args)
}

sweptAway_Include(A_Command, A_Args) {
	syslist_Remove("SweptAwayExcludes", A_Args)
}

ABOUT:
	Gui,2: Destroy
	Gui,2: Add, Picture, x16 y20 w60 h60 , sweptaway_logo.png
	Gui,2: Font, S28 CDefault Bold, Verdana
	Gui,2: Add, Text, x96 y20 w340 h60 , Swept Away 0.3
	Gui,2: Font, S8 CDefault, Arial
	Gui,2: Add, Text, x36 y100 w380 h60 , Swept Away monitors your applications and minimizes any windows that have been inactive for a user-defined period of time.
	Gui,2: Add, Text, x36 y145 w380 h70 , Swept Away is written by Adam Pash and distributed by Lifehacker under the GNU Public License.  For detail on how to use Swept Away`, check out the
	Gui,2: Font, S8 Cblue Underline, Arial
	Gui,2: Add, Text, x116 y175 w170 h30 gHELP, Swept Away homepage
	; Generated using SmartGUI Creator 4.0
	Gui,2: Show, h225 w459, About Swept Away
Return

DISABLE:
	COMMAND("Menu Action", "/menu:SweptAway /action:ToggleCheck /item:Disable")
	disable := 1 - disable
	if disable = 1
	{
		loop
			if disable = 0
				break
			else
				sleep,1000
	}
	else
		Goto,Start
return

READINI:
	sweepTime := GetValFromIni("Preferences","Timer",300)
	PollTime := GetValFromIni("Preferences","PollTime",3000)
return

GetValFromIni(section, key, default)
{
	IniRead,IniVal,sweptaway.ini,%section%,%key%
	if IniVal = ERROR
	{

		IniWrite,%default%,sweptaway.ini,%section%,%key%
		IniVal := default
	}
	return IniVal
}

RESOURCES:
	FileInstall,swept away logo.png,%A_ScriptDir%\sweptaway_logo.png,0
return
