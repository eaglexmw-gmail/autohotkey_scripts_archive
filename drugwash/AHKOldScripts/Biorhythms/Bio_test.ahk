#NoEnv
#SingleInstance force
#Persistent
SendMode Input
                       
;#Include, Data.ahk
;
; Since this build is not ready for the data file (Data.ahk),
; HelpText and AboutText will temporarily reside here.

HelpText =
(Join`n

The Cycles:

`tPhysical: 23-day Cycle
`tIndicator of strength, endurance, coordination and resistance to illness or infection.

`tEmotional: 28-day Cycle
`tIndicator of emotional state, passion, empathy, courage, enthusiasm, general
`toutlook and ability to deal with stress.

`tIntellectual: 33-day Cycle
`tIndicator of intellegence, alertness, memory, concentration and creativity.                                            `n

What they mean:

`tHigh (+):
`tHigh days occur when the graph is in the upper half of the chart.
`tYour capabilities and potential can be expected to be better than what is normal for you.

`tLow (-):
`tLow days occur when the graph is in the lower half of the chart.
`tYour capabilities and potential can be expected to be lower than what is normal for you.

`tCritical:
`tCritical days occur when the curve crosses the 'normal' line, whether moving up or down.
`tCritical days are a time of transition, flux, uncertainty, confussion and risk.
`tCritical days are the least stable day in any cycle.
)

AboutText =
(Join`n
Soggy Dog's Biorhythm Calculator v2.0.0.3         `n
Copyright (c) 2009

Coded by: Shannon D Gerton
Build Date: 03.09.09
)


; ------------------------------------------------------------------- CREATE RESOURCES / ICONS
ifNotExist %A_ScriptDir%\Resources\
{
    fileCreateDir, %A_ScriptDir%\Resources\
}

;ifNotExist %A_ScriptDir%\Resources\Icon.ico
;{
;    writeFile("Resources\Icon.ico","Icon_Piece1|Icon_Piece2")   
;}

; --------------------------------------------------------------------------- CREATE TRAY MENU
trayMenu:
;menu, Tray, Icon, Resources\Icon.ico
menu, Tray, noStandard
menu, Tray, Add, Help, Help
menu, Tray, default, Help
menu, Tray, Add
menu, Tray, Add, Exit, CloseApp

; -------------------------------------------------------------------------- BUILD RMCHART.DLL
ifNotExist %A_ScriptDir%\Resources\rmchart.dll
{
splashImage,, W250 H80 B1,
    , Soggy Dog Biorhythms`n`nInstalling Dependencies...`nPlease wait.,
writeFile("Resources\rmchart.dll","Chunk")   
splashImage, Off
}

Start:

; ---------------------------------------------------------------------------------- BUILD GUI
gui, Add, Tab, x10 y10 w660 h450 left buttons
   , Profiles|Chart|Compatibility|Options|Quick Start

gui, Tab, Profiles
gui, Add, groupBox, w620 h430, Profile Editor
gui, Font, Bold
gui, Add, Text, x66 y60, New Profile:
gui, Font
gui, Add, Edit, x136 y90 w220 h20 vnewProfileName,
gui, Add, Text, x66 y90 w70 h20 , Profile Name
gui, Add, DateTime, x136 y120 w220 h20 vnewProfileDate,
gui, Add, Text, x66 y120 w70 h20 , Date of Birth
gui, Add, Button, x316 y150 w40 h20 , Build
gui, Font, Bold
gui, Add, Text, x66 y180, Saved Profiles:
gui, Font
goSub, buildProfileList
gui, add, DropDownList, x66 y210 w200 gGetData vprofile, %List%
gui, add, Edit, x+10 w80 readOnly vprofileDate
gui, Font, s10 Bold
gui, Add, Text, x550 y400 w100 h40, Under Development
gui, Font

gui, Tab, Chart
gui, Add, groupBox, w620 h430, Biorhythm Chart
gui, Font, s10 Bold
gui, Add, Text, x60 y40 w100 h40, Under Development
gui, Font

gui, Tab, Compatibility
gui, Add, groupBox, w620 h430, Compatibility
gui, Font, s10 Bold
gui, Add, Text, x60 y40 w100 h40, Under Development
gui, Font

gui, Tab, Options
gui, Add, groupBox, w620 h430, Options
gui, Font, s10 Bold
gui, Add, Text, x60 y40 w100 h40, Under Development
gui, Font

gui, Tab, Quick start
gui, Add, groupBox, w620 h430, Biorhythms Quick Start
gui, Add, Text, x60 y40 , %helpText%

;menu, fileMenu, add, &New Profile, newProfile
;menu, fileMenu, add, &Load Profile, loadProfile
;menu, fileMenu, add, &Save Profile, saveProfile
menu, fileMenu, add, E&xit, closeApp
;menu, helpMenu, add, &Quick start, Help
menu, helpMenu, add, &About, About
menu, myMenuBar, add, &File, :fileMenu
menu, myMenuBar, add, &Help, :helpMenu

gui, Menu, myMenuBar
gui, Add, statusBar, ,Soggy Dog Biorhythms
gui, Show, h490 w680, Soggy Dog Biorhythms
return

; -------------------------------------------------------------------------------------- BUILD
buttonBuild:
msgBox, , Build is..., Under Development
return

; -------------------------------------------------- LABELS THAT HAVE NOT YET BEEN ESTABLISHED
; ------------------------------------------------------------- AND WILL LIKELY GO AWAY ANYWAY
newProfile:
loadProfile:
saveProfile:
2buttonHelp:
return

; --------------------------------------------------------------------------------------- HELP
Help:
msgBox,64,Help, %HelpText%,
return

; -------------------------------------------------------------------------------------- ABOUT
About:
msgBox,64,About, %AboutText%
return

; ------------------------------------------------------------------------- BUILD PROFILE LIST
buildProfileList:
List =
profileList =
ifNotExist %A_ScriptDir%\Resources\Profiles.ini
   list = No Saved Profiles
else
{
fileRead, profileList, %A_ScriptDir%\Resources\Profiles.ini
loop Parse, profileList, [
   {
   IfInString, A_LoopField, ]
      {
      StringSplit, Field, A_LoopField, ]
      List .= Field1 . "|"
      }
   }
StringTrimRight, list, list, 1
}
return

; ---------------------------------------------------------------------- RETRIEVE PROFILE DATA
getData:           ;-- Used to be called 'RetreiveIt'
iniRead, profileDate, %A_ScriptDir%\Resources\Profiles.ini, %profile%, DOB
guiControl, , profileDate, %profileDate%
return

; -------------------------------------------------------------------------- UPDATE STATUS BAR
updateStatusBar:
SB_SetText("Born on " . DisplayBirth . ", you are " . days . " days old today!", 1)
return

; --------------------------------------------------------------------------------------- EXIT
closeApp:
guiClose:
exitApp

; ---------------------------------------------------------------------------------- FUNCTIONS
; Veovis
; http://www.autohotkey.com/forum/viewtopic.php?t=10957
WriteFile(file,pieces)
{
   global
   local Handle,data,hex
   Handle :=  DllCall("CreateFile","str",file,"Uint",0x40000000
                  ,"Uint",0,"UInt",0,"UInt",4,"Uint",0,"UInt",0)
   Loop,parse,pieces,|
   {
     piece := %A_loopfield%
     data := data piece
   }
   Loop,
   {
     if strlen(data) = 0
         break
     StringLeft, Hex, data, 2
     StringTrimLeft, data, data, 2
     Hex = 0x%hex%
     DllCall("WriteFile","UInt", Handle,"UChar *", Hex
     ,"UInt",1,"UInt *",UnusedVariable,"UInt",0)
   }
   DllCall("CloseHandle", "Uint", Handle)
   return
  }
