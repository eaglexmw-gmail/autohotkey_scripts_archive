;----------------------------------------------------------------------
; ScaleDown
;
; Programmed by Benjamin Harder in 2010
; with support of various members of the Autohotkey community
; Special thanks go to SKAN and keyboardfreak
;
; Running on OS Win XP, Vista, 7
; Supports Parameter startup with "up" and "down"
; Can be configured over a GUI accesible over the tray icon
;----------------------------------------------------------------------
;*******************************************************************************
;            Environment Variables            
;*******************************************************************************
lParam = %1%                  ; lParam will be a copy of 1st parameter
#SingleInstance, OFF          ; Allow many instances, instances are handled by the script
#NoTrayIcon                   ; Will be shown later if it is the 1st instance of script
#Persistent                 
DetectHiddenWindows, On   
CoordMode, Mouse, Screen
A_SFP := A_ScriptFullpath   
SetWinDelay, -1
SetBatchLines -1
SetWorkingDir, %A_ScriptDir%
SysGet, MonitorWorkArea, MonitorWorkArea, 1
RegRead, windowstheme, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\ThemeManager, ThemeActive
RegRead, win7orvista, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductName
if(instr(win7orvista, "Windows 7"))
 win7 = 1
if(not instr(win7orvista, "Windows XP"))
 win7orvista = 1
FileGetTime, version, %A_ScriptName%
FormatTime, version, %version%,  dd-MM-yyyy
scripttitle = ScaleDown
if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_2000  ; Note: No spaces around commas.
{
    MsgBox,,%scripttitle%, This script requires OS Windows XP or higher.
    ExitApp
}
;*******************************************************************************
;            Handling of Startup Parameters (code by SKAN)         
;*******************************************************************************
WinGet, Instance, List, %A_ScriptFullPath%        ; "Instance" contains No. of Instances
; IfGreater,Instance,1, IfEqual,lParam,, ExitApp    ; Force SingleInstance when first
                                                  ; Parameter is Null
If ( lParam != "" )  {                           
   VarSetCapacity( Label, 12, 0)                 ; Encode COPYDATASTRUCT Structure
   NumPut( StrLen(lParam)+1, Label, 4 )          ; with Length of Str ( +1 for Null T )
   NumPut( &lParam, Label, 8 )                   ; with Pointer
   ; 0x4A is WM_COPYDATA Message: http://msdn2.microsoft.com/en-us/library/ms649011.aspx
    SendMessage,0x4A,0,&Label,,ahk_id %Instance2% ; Instance2 will contain the hWnd of
    ExitApp                                       ; first instance in windows Z-ORDER
} Else {
   NumPut( &lParam, Label, 9 ) 
   ; 0x4A is WM_COPYDATA Message: http://msdn2.microsoft.com/en-us/library/ms649011.aspx
   SendMessage,0x4A,1,&Label,,ahk_id %Instance2% ; Instance2 will contain the hWnd of
   OnMessage( 0x4A, "GoSub" )                    ; Enable "GoSub" (only 1st instance)
}
                                                 
Menu, Tray, Icon                                 ; Shown only for the 1st Instance

;*******************************************************************************
;            Traytip                  
;*******************************************************************************
Menu, tray, NoStandard
Menu, tray, add, Preferences, Preferences
Menu, tray, add, About, About
Menu, tray, add, Uninstall, Uninstall
Menu, tray, add, Reload, Reload
Menu, tray, add, Exit, Exit
Menu, tray, Default, Preferences
Menu, tray, Icon, Shell32.dll, 99
Menu, tray, Tip, ScaleDown         

;*******************************************************************************
;            Create Settings   and Help File
;*******************************************************************************

; Write Script Settings if not existent
ifnotexist, ScaleDownConfig.ini
{
 MsgBox, 4,%scripttitle%, This ist the first time you run %scripttitle%.`n`nThe use of this program is at your own risk and the author does not take any responsabilities for any damage that might be caused by this program.`n`nOnly continue if you agree with that.
  IfMsgBox no
   exitapp
 gosub, makereco
 gosub, WriteConfig
 MsgBox, 4,%scripttitle%, By default the program will respond to F11`, F12`, Windows+D and show a button in the Windows taskbar. Changes can be made in the setup which may be accessed over the tray icon.`nWindows that should not be scaled down can be defined in the ScaleDownExeptions.ini.`n`nIn addition`, the script can be executed by parameters "up" and "down".`n`nWould you like this program to start with Windows?
  IfMsgBox yes
   RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, ScaleDown, %A_ScriptFullPath%
 else
  RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, ScaleDown
 Loop
 {
 ifexist, ScaleDown Help.txt
  FileRecycle, ScaleDown Help.txt
 else
  break
 }
 FileAppend,
(
This is the help file for %scripttitle%

Button Transparency 

Defines how transparent the Windows 7 replacement button is. To be set between, 1 (transparent) and 255 (solid).

Button Color

Defines the color of the button in the taskbar with which the script can be triggered.
FFFFFF (White) is standard, but if you don't use styles in the taskbar (the old Win2000 taskbar), use a different color, such as 0000FF (Blue) or C0C0C0 (Silver) and vary the transparency.
A list with all color values can be found here: http://www.autohotkey.com/docs/commands/Progress.htm#colors

Button Width

Defines the width of the button. For Windows 7 normally 15, XP 10, or, if used with classical Theme, 21.
                     
Show Button

defines whether the button is shown in the taskbar or not. Even if the button is not show, clicking with the mouse there where it would be still activates ScaleDown.
If you don't want the button to work, put the button size to 0.

Offset from taskbar

Defines how much over the taskbar the windows are arranged.

A complete list of all hotkeys can be found here:
http://www.autohotkey.com/docs/KeyList.htm
   
   
Startup of the program with parameters

The script can be launched with the following parameters:
Down: Scales down the windows
Up: Does the contrary.
Example: Create a shortcut with the following command line: "C:\Programs\%scripttitle%\%scripttitle%.exe up" and the windows will scale up with this shortcut.
 ), ScaleDown Help.txt
 Loop
  ifexist, ScaleDownExeptions.ini
   FileRecycle, ScaleDownExeptions.ini
  else
   break
 FileAppend,
(
[AhkClass]
1 = SideBar_AppBarBullet
2 = BasicWindow

[Title]
1 = Windows Sidebar

[HowToUse]
You can find the title or the ahkclass of the window you don't want to scale by using "AutoIt3 Window Spy", which you can download for free from www.autohotkey.com (~1 Megabyte).

), ScaleDownExeptions.ini
}

;----------------------------------------------------------------------
; Load Script Settings
; =====================================================================
gosub, LoadConfig
; =====================================================================

;*******************************************************************************
;            Define Taskbar Position   
;*******************************************************************************
; Check where taskbar is
WinGetPos, taskbar_x, taskbar_y, taskbar_w, taskbar_h, ahk_class Shell_TrayWnd
if ((taskbar_x > 0) and (taskbar_y <= 0)) ; Taskbar is on the right
{
 overlay_width := taskbar_w
 overlay_height := buttonsize
 overlay_x := A_ScreenWidth - overlay_width
 overlay_y := A_ScreenHeight - overlay_height
 target_y_pos := A_Screenheight - Offset_from_taskbar
 min_x_targetmousearea := A_ScreenWidth - overlay_width
 max_x_targetmousearea := A_ScreenWidth 
 min_y_targetmousearea := A_ScreenHeight - overlay_height
 max_y_targetmousearea := A_ScreenHeight
; msgbox, %taskbar_x% %taskbar_y% right
 }
else if ((taskbar_x <= 0) and (taskbar_y <= 0) and (taskbar_h > 300)) ; Taskbar is on the left
{
 overlay_width := taskbar_w
 overlay_height := buttonsize
 overlay_x := 0
 overlay_y := A_ScreenHeight - overlay_height
 target_y_pos := A_Screenheight - Offset_from_taskbar
 min_x_targetmousearea := 0
 max_x_targetmousearea := overlay_width 
 min_y_targetmousearea := A_ScreenHeight - overlay_height
 max_y_targetmousearea := A_ScreenHeight
; msgbox, %taskbar_x% %taskbar_y% %A_Screenheight%  %taskbar_h%  left
}
else if ((taskbar_x <= 0) and (taskbar_y > 0)) ; Taskbar is on the bottom
{
 overlay_width := buttonsize
 overlay_height := taskbar_h
 overlay_x := A_ScreenWidth - overlay_width
 overlay_y := A_ScreenHeight - overlay_height
 target_y_pos := A_Screenheight - Offset_from_taskbar - taskbar_h
 min_x_targetmousearea := A_ScreenWidth - overlay_width
 max_x_targetmousearea := A_ScreenWidth
 min_y_targetmousearea := A_ScreenHeight - overlay_height
 max_y_targetmousearea := A_ScreenHeight
; msgbox, %taskbar_x% %taskbar_y% %A_Screenheight%  %taskbar_h% bottom
}
else ; Taskbar is on the top
{
 overlay_width := buttonsize
 overlay_height := taskbar_h
 overlay_x := A_ScreenWidth - overlay_width
 overlay_y := 0
 target_y_pos := A_Screenheight - Offset_from_taskbar
 min_x_targetmousearea := A_ScreenWidth - overlay_width
 max_x_targetmousearea := A_ScreenWidth 
 min_y_targetmousearea := 0
 max_y_targetmousearea := overlay_height
; msgbox, %taskbar_x% %taskbar_y% top
}

;*******************************************************************************
;            Create Taskbar Buttons
;*******************************************************************************

; Overlay Windows 7 Show Desktop Button
if showintaskbar = 1
{ ; need to overlay the Windows 7 Desktop Button
 Gui  +ToolWindow +LastFound -Caption -Resize -MaximizeBox -MinimizeBox +Alwaysontop +disabled -Border +BackgroundTrans
 Gui, Show, x%overlay_x% y%overlay_y% h%overlay_height% w%overlay_width% NoActivate, overlaygui_1
 Gui,1: Color, %buttoncolor%
 WinSet, Transparent, %transparency%, overlaygui_1
 if win7orvista <> 1 ; Parents the Gui 1 to taskbar - Parenting does not work for Win7, workaround with Mouse button Up
 {
  Sleep, 100
  GUI_ID := WinExist()               
  WinGet, TaskBar_ID, ID, ahk_class Shell_TrayWnd
  DllCall("SetParent", "uint", GUI_ID, "uint", Taskbar_ID)
 }
 Gui, 2: +ToolWindow +LastFound -Caption -Resize -MaximizeBox -MinimizeBox +Alwaysontop +disabled -Border +BackgroundTrans +Owner
 Gui, 2: Show, x%overlay_x% y%overlay_y% h0 w%overlay_width% NoActivate, overlaygui_2
 Gui,2: Color, %buttoncolor%
 WinSet, Transparent, 1, overlaygui_2
 WinMove, overlaygui_2,, %overlay_x%, %overlay_y%, %overlay_width%, %overlay_height%,
}
;
; window data fields
;
field_id = 1
field_x = 2
field_y = 3
field_width = 4
field_height = 5
Settimer, Scriptreloader, -1
;*******************************************************************************
;            Load Hotkeys
;*******************************************************************************
Hotkey, %toggle_1%, scriptstart   
Hotkey, %toggle_2%, scriptstart
Hotkey, %desktoppeek%, peekstartdown
Hotkey, %desktoppeek% UP, peekstartup
~LButton::goto, mousescriptstart ; put ";" in front of this line if you don't want to activate the script by clicking into the bottom right corner of the screen with the mouse (as Win7)
~LButton UP::goto, Buttonblockontop ; Overlays the windows 7 show desktop button again when taskbar had been used
~RButton UP::goto, Buttonblockontop ; Overlays the windows 7 show desktop button again when taskbar had been used
; =====================================================================

;*******************************************************************************
;            Begin of Script Functions   
;*******************************************************************************
; Script start peek
peekstartdown:
if already_scaled = yes
 return
else goto scriptstart

peekstartup:
if already_scaled = no
 return
else goto scriptstart

; Script start mouse
scriptstartmouse:
 WinGet, WindowList, List
 List =
 WinActivate, ahk_id %WindowList3%
 goto scriptstart
 
; Script Start with Parameters
down:
if already_scaled = yes
 return
goto scriptstart
up:
if already_scaled <> yes
 return
goto scriptstart

; Script start independent of how initiated
scriptstart:
DetectHiddenWindows, Off
if already_scaled <> yes
{
; ************************************* BEHAVIOR IF NOT SCALED YET*************************************
;
; enumerate windows on the screen and store their information
 numwindows = 0
 active_window = 0
; GET ALL OTHER WINDOWS AND THEIR CURRENT POSITION
 winget, ids, list, , , Program Manager
 loop, %ids%
 {
  stringtrimright, id, ids%a_index%, 0
  wingettitle, title, ahk_id %id%
  WinGetClass, class, %title%
; don't add windows with empty titles
  if((title = "") or (title = "overlaygui_2") or (title = "overlaygui_1") or (title = "ViStart_Edit"))
   continue
  if(instr(blockedclasses, class) or instr(blockedtitles, title))
   continue
  if class = ThunderRT6FormDC ; to prevent incompatibilies with the application Vistart
   continue
  numwindows += 1
  wingetpos, x, y, width, height, ahk_id %id%
  windows%numwindows% = %id%#%x%#%y%#%width%#%height%
; store the index of the initially active window
  ifwinactive, ahk_id %id%
   active_window = %numwindows%
 }
 if numwindows = 1 ; No Windows to scale
  return
; scale the windows on the screen
 loop, %numwindows%
 {
  stringtrimleft, windata, windows%a_index%, 0
  stringsplit, windata, windata,#
  stringtrimleft, id, windata%field_id%, 0
  stringtrimleft, x, windata%field_x%, 0
  winmove, ahk_id %id%, , %x%, %target_y_pos%
 }
 already_scaled = yes
}
else
; ************************************* BEHAVIOR IF ALREADY SCALED*************************************
{
; Restore Active Window
 index = %active_window%
 gosub, restorewindow
; Restore Other Windows
 loop, %numwindows%
 {
; it's already restored
  if a_index = %active_window%
   continue 
  index = %a_index%
  gosub, restorewindow
 }
 already_scaled = no
}
return


;*******************************************************************************
;            Begin of Main Script Related Subfunctions
;*******************************************************************************

; ======================RESTOREWINDOW================================
 ; Restores the scaled windows
restorewindow:
stringtrimleft, windata, windows%index%, 0
stringsplit, windata, windata,#
stringtrimleft, id, windata%field_id%, 0
stringtrimleft, x, windata%field_x%, 0
stringtrimleft, y, windata%field_y%, 0
stringtrimleft, width, windata%field_width%, 0
stringtrimleft, height, windata%field_height%, 0
; Check if window has been moved manually
wingetpos, xvaluenew, yvaluenew, widthvaluenew, heighvaluenew, ahk_id %id%
if yvaluenew <> %target_y_pos%
 return
alternative_y_pos := target_y_pos + Offset_from_taskbar - height
if y <> %target_y_pos%
 winmove, ahk_id %id%, , %x%, %y%, %width%, %height%
else
 winmove, ahk_id %id%, , %x%, %alternative_y_pos%, %width%, %height%  ; In case that the window was not restored normally, align it above the taskbar
return

; ======================Mousescriptstart================================
; Checks if the mouse has been clicked in the bottom right corner of the screen
mousescriptstart:
MouseGetPos, mousex, mousey
if((mousex>min_x_targetmousearea) and (mousey>min_y_targetmousearea) and (mousex<=max_x_targetmousearea) and (mousey<=max_y_targetmousearea))
 goto, scriptstartmouse
return

; ======================Buttonblockontop================================
; Checks if the Button covering the Windows 7 Button is above the latter
Buttonblockontop:
Sleep 20
if showintaskbar = 1
 if win7orvista = 1
 {
 ifWinNotActive, ahk_class Shell_TrayWnd
    {
   WinGet, Style, Style, A
     ifnotinstring, style, 000000 ; Check if a Fullscreen App is running, only put gui on top if not so
      Gui, 1: +AlwaysOnTop
     else if (WinActive("ahk_class Progman") or WinActive("ahk_class SideBar_AppBarBullet"))  ; Desktop is a fullscreen app too, exeption: put gui1 on top
        Gui, 1: +AlwaysOnTop
     else
     {
      Gui, 1: -AlwaysOnTop
      WinSet, Top,,A
     }
    }
    else
     Gui, 1: +AlwaysOnTop
 }
Gui, 2: +AlwaysOnTop
return

; ======================Scriptrelaoder==================================
; Checks if the taskbar ceases to exist and reloads script after taskbar reappears
Scriptreloader:
WinWaitclose, ahk_class Shell_TrayWnd
 WinWait, ahk_class Shell_TrayWnd
Sleep, 4000
  reload
Sleep, 3000
msgbox,,%scripttitle%,Reload Failed
return
;*******************************************************************************
;            Functions of Traytip
;*******************************************************************************

About:                              
Msgbox,,%scripttitle%,This program partly is based on the source code of the "expose"-script of "keyboardfreak"`, who published it in the forums of Autohotkey (www.autohotkey.com).`n`nLater this program was written by Benjamin Harder.`n`nThis program allows to access the desktop by using a hotkey in a way that permits that new files and folders can be opened without loosing the possibility to maximize the previously minimized windows after that once again. `nThe built-in show-desktop-function of Windows does not allow this`, as it minimizes the newly opened windows rather than maximizing the previously minimized ones. Thus, with the built-in Windows-function the minimized windows remain minimized and have to be maximized by hand once again..`n`nThe code that made it possible to start the program with parameters was made possible by "SKAN"`, and other community members of Autohotkey helped to improve this script. Thanks to all of you.`n`nThis is version %version%.
return

Uninstall:                              
 MsgBox, 4,%scripttitle%,Are you sure you want to uninstall this program? Personal settings will be lost.
  IfMsgBox no
   Return
  RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %scripttitle%   
  Gui, Destroy
  Gui, 3: Destroy
  FileDelete, ScaleDownConfig.ini
  FileDelete, ScaleDown Help.txt
  FileDelete, ScaleDownExeptions.ini
  Msgbox,,%scripttitle%,Uninstallation succesful. Installation file is still in your program directory for possible future use.
  exitapp

Reload:
   reload
return

Exit:
      exitapp

;*******************************************************************************
;            Settings GUI (part of Traytip)
;*******************************************************************************
Preferences:               
if guishow = 1
{
  WinActivate, %scripttitle%,
  return
}
else
 guishow = 1
gosub, LoadConfig
Gui, 3: Add, Text, x10 y10 w100, Switch to Desktop                  
Gui, 3: Add, Text, yp+25 w100, Peek to Desktop         
Gui, 3: Add, Text, yp+25 w100, Button Transparency         
Gui, 3: Add, Text, yp+25 w100, Button Color   
Gui, 3: Add, Text, yp+25 w100, Button Width      
Gui, 3: Add, Text, yp+25 w100, Offset from Taskbar
Gui, 3: Add, Text, yp+25 w100, Show Button      
Gui, 3: Add, Text, yp+25 w100, Replace Win + D   
Gui, 3: Add, Text, yp+25 w100, Start with Windows         
Gui, 3: Add, Button, yp+25 w100 gReLoadReco, Load Defaults               
Gui, 3: Add, Button, yp+25 w100 Default gSave, Save
Gui, 3: Add, Text, yp+30 w200 cRed, Warning! Hotkeys will stop working if invalid key names are entered            
Gui, 3: Add, Text, yp+30 w200 cBlue gKeyNames, Click here for a list of key names   
Gui, 3: Add, Edit, x110 y10 w100 vtoggle_1, %toggle_1%            
Gui, 3: Add, Edit, yp+25 w100 vdesktoppeek, %desktoppeek%            
Gui, 3: Add, Edit, yp+25 w100 vtransparency, %transparency%            
Gui, 3: Add, Edit, yp+25 w100 vbuttoncolor, %buttoncolor%   
Gui, 3: Add, Edit, yp+25 w100 vbuttonsize, %buttonsize%   
Gui, 3: Add, Edit, yp+25 w100 vOffset_from_taskbar, %Offset_from_taskbar%   
if showintaskbar = 1
 Gui, 3: Add, CheckBox, yp+25 w100 vshowintaskbar checked,
else
 Gui, 3: Add, CheckBox, yp+25 w100 vshowintaskbar,
if winreplace = 1
 Gui, 3: Add, CheckBox, yp+25 w100 vwinreplace checked,
else
 Gui, 3: Add, CheckBox, yp+25 w100 vwinreplace,
if windowsstartupcheck = 1
 Gui, 3: Add, CheckBox, yp+25 w100 vwindowsstart checked,
else
 Gui, 3: Add, CheckBox, yp+25 w100 vwindowsstart,
Gui, 3: Add, Button, yp+25 w100 gHelp, Help   
Gui, 3: Add, Button, yp+25 w100 gCancel, Cancel                           
Gui, 3: Show,,%scripttitle%
return                              
                              
;*******************************************************************************
;            Begin of Gui Related Subfunctions
;*******************************************************************************

; ======================Save================================
; Submits the data filled in the preferences Gui
Save:      
Gui,3: Submit                           
gosub, WriteConfig
if windowsstart = 1      
  RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %scripttitle%, %A_ScriptFullPath%
 else
  RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %scripttitle%
Reload                              

; =====================Cancel===============================
; Cancels and closes the preferences Gui

~ESC::
IfWinNotActive, %scripttitle%   
   return                        
Cancel:                              
Gui,3: Cancel                           
Gui,3: Destroy
guishow = 0
return                              

; ====================Keynames===============================
; Runs the Help page for the Hotkeys in the preferences Gui                     
Keynames:                              
Run, http://www.autohotkey.com/docs/KeyList.htm               
return

; ======================Help=================================
; Runs the Help page for the configuration options of the preferences Gui      
Help:
   run, notepad.exe %A_Workingdir%\ScaleDown Help.txt
return

; =====================ReLoadReco============================
; Loads the recommended settings again into the preferences Gui
ReLoadReco:
Gui, 3: Destroy
guishow = 0
gosub, MakeReco
gosub, WriteConfig
gosub, LoadConfig
goto, Preferences
return


;*******************************************************************************
;            Begin of Settings functions
;*******************************************************************************

; =====================MakeReco============================
; Defines the parameters of the recommended settings
MakeReco:
transparency = 55
 if windowstheme = 1
  buttoncolor = FFFFFF
 else
  buttoncolor = 0000FF
 if((win7orvista = 1) and (windowstheme <> 0) and (win7 = 1)) ; WIN7 and Visual Styles Active
  buttonsize = 15
 else if((win7orvista = 1) and (windowstheme <> 0) and (win7 <> 1)) ; WIN Vista and Visual Styles Active
  buttonsize = 11
 else if windowstheme <> 0 ; WinXp and Visual Styles Active
  buttonsize = 10
 else if((win7orvista = 1) and (windowstheme = 0) and (win7 = 1)) ; WIN7 and Visual Styles not active
  buttonsize = 21
 else if((win7orvista = 1) and (windowstheme = 0) and (win7 <> 1)) ; WIN Vista and Visual Styles not active
  buttonsize = 21
 else if windowstheme = 0 ; Not WIN7 and Visual Styles not active
  buttonsize = 10
Offset_from_taskbar = 20
showintaskbar = 1
winreplace = 1
toggle_1 = F12
desktoppeek = F11
return

; =====================WriteConfig============================
; Writes the chosen settings into the configuration file.
WriteConfig:
ifnotexist, ScaleDownConfig.ini
 FileAppend,
(
[ScaleDownSettings]

[Version]
), ScaleDownConfig.ini
IniWrite, %transparency%, ScaleDownConfig.ini, ScaleDownSettings, transparency
IniWrite, %buttoncolor%, ScaleDownConfig.ini, ScaleDownSettings, buttoncolor
IniWrite, %buttonsize%, ScaleDownConfig.ini, ScaleDownSettings, buttonsize
IniWrite, %Offset_from_taskbar%, ScaleDownConfig.ini, ScaleDownSettings, Offset_from_taskbar
IniWrite, %showintaskbar%, ScaleDownConfig.ini, ScaleDownSettings, showintaskbar
IniWrite, %winreplace%, ScaleDownConfig.ini, ScaleDownSettings, winreplace
IniWrite, %toggle_1%, ScaleDownConfig.ini, ScaleDownSettings, toggle_1
IniWrite, %desktoppeek%, ScaleDownConfig.ini, ScaleDownSettings, desktoppeek
IniWrite, %version%, ScaleDownConfig.ini, Version, Version
return

; =====================LoadConfig============================
; Loads the settings from the configuration file. 
LoadConfig:
RegRead, windowsstartupcheck, HKEY_LOCAL_MACHINE,  SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %scripttitle%
if windowsstartupcheck <>
 windowsstartupcheck = 1
IniRead, transparency, ScaleDownConfig.ini, ScaleDownSettings, transparency
IniRead, buttoncolor, ScaleDownConfig.ini, ScaleDownSettings, buttoncolor
IniRead, buttonsize, ScaleDownConfig.ini, ScaleDownSettings, buttonsize
IniRead, Offset_from_taskbar, ScaleDownConfig.ini, ScaleDownSettings, Offset_from_taskbar
IniRead, showintaskbar, ScaleDownConfig.ini, ScaleDownSettings, showintaskbar
IniRead, winreplace, ScaleDownConfig.ini, ScaleDownSettings, winreplace
IniRead, toggle_1, ScaleDownConfig.ini, ScaleDownSettings, toggle_1
IniRead, desktoppeek, ScaleDownConfig.ini, ScaleDownSettings, desktoppeek
Loop
{
 IniRead, readblockedclasses, ScaleDownExeptions.ini, ahkclass, %A_Index%
 if ((readblockedclasses = "Error") or (readblockedclasses = ""))
  break
 blockedclasses = %readblockedclasses%,%blockedclasses%
}
Loop
{
 IniRead, readblockedtitles, ScaleDownExeptions.ini, title, %A_Index%
 if ((readblockedtitles = "Error") or (readblockedtitles = ""))
  break
 blockedtitles = %readblockedtitles%,%blockedtitles%
}
if winreplace = 1
 toggle_2 = #D
else
 toggle_2 = +!^F7
return


;*******************************************************************************
;            Subfunction for Parameter Startup
;*******************************************************************************
GoSub( wParam, lParam, Msg, hWnd ) {             ; Function to handle WM_COPYDATA Message
  if wparam = 1
   exitapp
  WinGetTitle, Title, ahk_id %hWnd%              ; Check whether Msg is from same script
  IfNotInString, Title, %A_SFP%, Return False    ; else ignore and Return False to caller

  ; Decoding COPYDATASTRUCT:  http://msdn2.microsoft.com/en-us/library/ms649010.aspx
  lpData  := NumGet( lParam+8 )                  ; Get Data pointer from COPYDATASTRUCT
  dLength := NumGet( lParam+4 )                  ; Get length of Source String and Set
  VarSetCapacity( Routine, dLength)              ; length of Local Var to match source.
  DllCall( "lstrcpy", Str,Routine, UInt,lpData ) ; Copy string to Local Variable "Routine"
   If IsLabel( Routine )                         ; Only if "Routine" a Valid subroutine,
      SetTimer, %Routine%, -1                    ; start "Routine" in seperate thread so
Return True                                      ; as to reply with a TRUE to Caller, ASAP
}
