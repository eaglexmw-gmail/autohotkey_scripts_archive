#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance , Force
DetectHiddenWindows, On
Gui, Color, 145707
Gui, Add, Pic, x0 y0 w400 h325 0x4000000 hwndIDG0 vMoveGui Center, Ev.png

Gui, Font, s13
Gui, Add, Text, x265 y18 w110 h85 Center BackgroundTrans vMOver, Go ahead.`nPoke an eye.`nYou know you`nwant to.

Gui, Show, w400 h325 Hide, Evolution Gui
Gui, +LastFound
IDG1 := WinExist()
GoSub AddControls
WinSet, TransColor, 145707 175, Evolution Gui
Gui, -Caption
Gui, Show, w400 h325, Evolution Gui
SetTimer, OnMouseOver, 100
OnMessage(0x201, "Find_Label")
Return

#Include EvMouseOverRules.ahk

Find_Label()
	{
	MouseGetPos, , , OverWin, 
	WinGetTitle, title, ahk_id %OverWin%
	StringReplace, title, title, %A_Space%, _, All 
	If IsLabel(title)
		Gosub, %title%
	
	}
Return
Esc::
Exit:
GuiClose:
Gui, Destroy
ExitApp

SetParent(hChild, hParent=0)
{
DllCall("SetParent", "UInt", hChild, "UInt", hParent)
}

AddControls:
WinGetPos , ShowX, ShowY, ShowW, ShowH, Evolution Gui

Gui, 12:+LastFound +Toolwindow -Caption
Gui, 12:Color, Black
IDG := WinExist()
Gui, 12:Show, x0 y0 w%ShowW% h%ShowH% NA Hide, Left Eye
WinSet, Region, 99-156 91-154 85-149 80-139 78-128 76-114 77-101 80-86 86-75 92-69 98-68 105-70 110-73 114-81 118-88 119-98 120-109 120-119 117-136 113-147 110-152 104-155 101-155 99-156, Left Eye
SetParent(IDG, IDG1)
;WinSet, Transparent, 1, Left Eye
Gui, 12:Show

Gui, 13:+LastFound +Toolwindow -Caption
Gui, 13:Color, Black
IDG := WinExist()
Gui, 13:Show, x0 y0 w%ShowW% h%ShowH% NA Hide, Center Eye
WinSet, Region, 155-127 147-122 141-113 137-104 135-91 135-79 136-67 139-54 143-47 146-44 149-40 155-39 165-40 169-46 174-53 177-65 179-76 179-92 177-102 172-114 168-122 162-126 155-127, Center Eye
SetParent(IDG, IDG1)
;WinSet, Transparent, 1, Center Eye
Gui, 13:Show

Gui, 14:+LastFound +Toolwindow -Caption
Gui, 14:Color, Black
IDG := WinExist()
Gui, 14:Show, x0 y0 w%ShowW% h%ShowH% NA Hide, Right Eye
WinSet, Region, 214-155 202-148 199-140 194-132 193-119 192-112 194-99 195-90 199-81 205-72 208-69 214-69 225-72 231-82 236-91 239-107 235-135 225-150 218-157 214-155, Right Eye
SetParent(IDG, IDG1)
;WinSet, Transparent, 100, Right Eye
Gui, 14:Show

Gui, 15:+LastFound +Toolwindow -Caption
Gui, 15:Color, Black
IDG := WinExist()
Gui, 15:Show, x0 y0 w%ShowW% h%ShowH% NA Hide, Mouth
WinSet, Region, 57-213 65-229 78-252 91-264 110-276 131-284 151-287 172-286 199-278 217-268 235-252 246-238 252-224 252-224 255-213 266-217 272-215 271-210 265-204 257-199 243-194 236-193 233-196 233-202 239-207 244-210 245-215 235-229 218-248 195-262 173-269 147-269 115-261 99-249 75-222 66-208 78-202 57-213, Mouth
SetParent(IDG, IDG1)
;WinSet, Transparent, 1, Mouth
Gui, 15:Show

Gui, 6:+LastFound +Toolwindow -Caption + AlwaysOnTop
Gui, 6:Color, 0xE54F4F
IDG := WinExist()
Gui, 6:Show, x115 y270 w88 h50 NA Hide, Rude
WinSet, Region, 2-2 3-2 4-3 5-3 6-4 8-4 9-5 11-5 12-6 15-6 16-7 19-7 20-8 25-8 26-9 33-9 34-10 53-10 54-9 61-9 62-8 67-8 68-7 71-7 72-6 75-6 76-5 78-5 79-4 81-4 82-3 83-3 84-2 85-2 86-3 86-5 85-6 85-9 84-10 84-12 83-13 83-14 82-15 82-17 81-18 81-19 80-20 80-21 79-22 79-23 78-24 78-25 77-26 77-27 75-29 75-30 70-35 70-36 63-43 62-43 60-45 59-45 58-46 57-46 56-47 54-47 53-48 50-48 49-49 38-49 37-48 34-48 33-47 31-47 30-46 29-46 28-45 27-45 25-43 24-43 17-36 17-35 12-30 12-29 10-27 10-26 9-25 9-24 8-23 8-22 7-21 7-20 6-19 6-18 5-17 5-15 4-14 4-13 3-12 3-10 2-9 2-6 1-5 1-3 , Rude
SetParent(IDG, IDG0)

Return

Left_Eye:
WinGetPos , ShowX, ShowY, ShowW, ShowH, Evolution Gui
Gui, 7:Color, Black
Gui, 7:+LastFound +Toolwindow -Caption
Gui, 7:Show, w%A_ScreenWidth% h%A_ScreenHeight% , Cover
SetTimer, OnMouseOver, Off
GuiControl, 1:, MOver, Oh yeah,`nThat's what`nhappens.
Sleep, 1000
WinActivate, Evolution Gui
Sleep, 2000
GuiControl, 1:, MOver, Hold on.`nI'll fix it.
Sleep, 1000
WinActivate, Cover
GuiControl, 1:, MOver, There`,`nall better.
Sleep, 1000
Gui, 7:Destroy
Sleep, 500
SetTimer, OnMouseOver, 100
Return

Center_Eye:
Gui, 6:Show
SetTimer, RudeOff, 1500
Return

Right_Eye:
SetTimer, OnMouseOver, Off
GuiControl, 1:, MOver, Bye`, Bye.
Gui, 12:Destroy
Gui, 13:Destroy
Gui, 14:Destroy
Gui, 15:Destroy
Sleep, 500
GoSub SneekyExit
GoTo Exit
Return

SneekyExit:
Loop, 25
	{
	WinSet, TransColor, % "145707 " 175+A_Index*3, Evolution Gui
	Sleep, 15
	}
Sleep, 1000
Loop, 85
	{
	WinSet, TransColor, % "145707 " 255-A_Index*3, Evolution Gui
	Sleep, 15
	}
Return

Mouth:
PostMessage, 0xA1, 2,,, ahk_id %IDG1%
Return

RudeOff:
SetTimer, RudeOff, off
Gui, 6:Hide
WinSet, Redraw,, ahk_id %IDG1%
return