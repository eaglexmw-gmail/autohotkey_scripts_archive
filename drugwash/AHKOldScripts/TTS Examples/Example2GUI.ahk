;-------------------------------------------------------------------------------
;
; This script demonstrates the use of multiple SpVoice instances.  Under most
; circumstances, you only need one SpVoice instance.
;
;-------------------------------------------------------------------------------


;********************************
;*                              *
;*    AutoHotkey environment    *
;*                              *
;********************************
#NoEnv
OnExit Exit



;*******************
;*                 *
;*    Constants    *
;*                 *
;*******************
#include TTSConstants.ahk



;********************
;*                  *
;*    Initialize    *
;*                  *
;********************
;-- Init COM
COM_Init()


;-- Create 3 SpVoice instances
loop 3
    {
    pSpVoice%A_Index%:=COM_CreateObject("SAPI.SpVoice")
    outputdebug % "pSpVoice" . A_Index . "=" . pSpVoice%A_Index%
    }


;-- Create temporary SpVoice instance to collect information necessary for GUI
pSpVoiceGUI:=COM_CreateObject("SAPI.SpVoice")
outputdebug % "pSpVoiceGUI=" . pSpVoiceGUI%A_Index%


;-- Build list of Voices
VoiceList=
loop % COM_Invoke(pSpVoiceGUI,"GetVoices.Count")
    {
    Name:=COM_Invoke(pSpVoiceGUI,"GetVoices.Item(" . A_Index-1 . ")" . ".GetAttribute","Name")
    if VoiceList is Space
        VoiceList:=Name
     else
        VoiceList:=VoiceList . "|" . Name
    }



;*******************
;*                 *
;*    Build GUI    *
;*                 *
;*******************
;[==============]
;[  Instance 1  ]
;[==============]
gui Margin,6,6
gui Add,GroupBox,xm ym+4 w200 h280,Instance 1
gui Add
   ,Edit
   ,xp+10 yp+20 w180 h100
    || Section
    || vText1,
       (ltrim
        Jack and Jill went up the hill
        To fetch a pail of water.
        Jack fell down and broke his crown,
        And Jill came tumbling after.
       )

gui Add,Button,xs y+5 w60 h20        vSpeakButton1 gSpeak1,Speak
gui Add,Button,x+0 wp hp Disabled    vPauseButton1 gPause1,Pause
gui Add,Button,x+0 wp hp Disabled    vStopButton1  gstop1,Stop
gui Add,Radio,xs y+5 w60 h20 Checked vPriority1    gPriority1,Normal
gui Add,Radio,x+0 wp hp                            gPriority1,Alert
gui Add,Radio,x+0 wp hp                            gPriority1,Over

gui Add,Text,xs yp+30 w40 h20,Voice:
gui Add,DropDownList,x+0 w140 hp r5 vVoice1 gVoice1,%VoiceList%
GUIControl ChooseString,Voice1,% COM_Invoke(pSpVoiceGUI,"Voice.GetDescription")

gui Add,Text,xs yp+30 w40 h30,Rate:
gui Add,Slider,x+0 w140 hp
    || Range-10-10
    || TickInterval10
    || ToolTip
    || vRate1
    || gRate1
   ,% COM_Invoke(pSpVoiceGUI,"Rate")

gui Add,Text,xs+0 y+0 w40 hp,Vol:
gui Add,Slider,x+0 w140 hp
    || Range0-100
    || TickInterval10
    || ToolTip
    || vVolume1
    || gVolume1
   ,% COM_Invoke(pSpVoiceGUI,"Volume")


;[==============]
;[  Instance 2  ]
;[==============]
gui Add,GroupBox,xm+200 ym+4 w200 h280,Instance 2
gui Add,Edit,xp+10 yp+20 w180 h100
    || Section
    || vText2,
       (ltrim
        Little Miss Muffet
        sat on a tuffet,
        Eating her curds and whey;
        Along came a spider,
        Who sat down beside her
        And frightened Miss Muffet away.
       )

gui Add,Button,xs y+5 w60 h20        vSpeakButton2 gSpeak2,Speak
gui Add,Button,x+0 wp hp Disabled    vPauseButton2 gPause2,Pause
gui Add,Button,x+0 wp hp Disabled    vStopButton2  gstop2,Stop
gui Add,Radio,xs y+5 w60 h20 Checked vPriority2    gPriority2,Normal
gui Add,Radio,x+0 wp hp                            gPriority2,Alert
gui Add,Radio,x+0 wp hp                            gPriority2,Over

gui Add,Text,xs yp+30 w40 h20,Voice:
gui Add,DropDownList,x+0 w140 hp r5 vVoice2 gVoice2,%VoiceList%
GUIControl ChooseString,Voice2,% COM_Invoke(pSpVoiceGUI,"Voice.GetDescription")

gui Add,Text,xs yp+30 w40 h30,Rate:
gui Add,Slider,x+0 w140 hp
    || Range-10-10
    || TickInterval10
    || ToolTip
    || vRate2
    || gRate2
   ,0
gui Add,Text,xs+0 y+0 w40 hp,Vol:
gui Add,Slider,x+0 w140 hp
    || Range0-100
    || TickInterval10
    || ToolTip
    || vVolume2
    || gVolume2
   ,100


;[==============]
;[  Instance 3  ]
;[==============]
gui Add,GroupBox,xm+400 ym+4 w200 h280,Instance 3
gui Add,Edit,xp+10 yp+20 w180 h100
    || Section
    || vText3,
       (ltrim
        Mary, Mary, quite contrary,
        How does your garden grow?
        With silver bells, and cockle shells,
        And pretty maids all in a row.
       )

gui Add,Button,xs y+5 w60 h20        vSpeakButton3 gSpeak3,Speak
gui Add,Button,x+0 wp hp Disabled    vPauseButton3 gPause3,Pause
gui Add,Button,x+0 wp hp Disabled    vStopButton3  gstop3,Stop
gui Add,Radio,xs y+5 w60 h20 Checked vPriority3    gPriority3,Normal
gui Add,Radio,x+0 wp hp                            gPriority3,Alert
gui Add,Radio,x+0 wp hp                            gPriority3,Over

gui Add,Text,xs yp+30 w40 h20,Voice:
gui Add,DropDownList,x+0 w140 hp r5 vVoice3 gVoice3,%VoiceList%
GUIControl ChooseString,Voice3,% COM_Invoke(pSpVoiceGUI,"Voice.GetDescription")

gui Add,Text,xs yp+30 w40 h30,Rate:
gui Add,Slider,x+0 w140 hp
    || Range-10-10
    || TickInterval10
    || ToolTip
    || vRate3
    || gRate3
   ,0
gui Add,Text,xs+0 y+0 w40 hp,Vol:
gui Add,Slider,x+0 w140 hp
    || Range0-100
    || TickInterval10
    || ToolTip
    || vVolume3
    || gVolume3
   ,100


;[===========]
;[  Show it  ]
;[===========]
gui Show,,Text-To-Speech via COM - Example 2: Multiple SpVoice Instances


;-- Release temporary SpVoice instance
COM_Release(pSpVoiceGUI)
return



;******************
;*                *
;*    GUI Exit    *
;*                *
;******************
GUIClose:
GUIEscape:
ExitApp



;***************
;*             *
;*    Speak    *
;*             *
;***************
Speak1:
Speak2:
Speak3:
Critical  ;-- Insures that this routine is not interrupted 
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


;[==============]
;[  Initialize  ]
;[==============]
PauseRequest%ThisInstance%:=false
StopRequest%ThisInstance%:=false


;-- Collect form variables
gui Submit,NoHide


;-- Bounce if there is no text
if Text%ThisInstance% is Space
    return


;-- If necessary, establish Sink (event interface)
if not pSink%ThisInstance%
    {
    pSink%ThisInstance%:=COM_ConnectObject(pSpVoice%ThisInstance%,ThisInstance . "On")
    outputdebug % "pSink" . ThisInstance . "=" . pSink%ThisInstance%
    }


;-- Enable/Disable GUI objects
GUIControl Disable,SpeakButton%ThisInstance%
GUIControl Enable, PauseButton%ThisInstance%
GUIControl Enable, StopButton%ThisInstance%
GUIControl Disable,Voice%ThisInstance%


;-- Set focus
GUIControl Focus,PauseButton%ThisInstance%


;[=========]
;[  Speak  ]
;[=========]
StreamForpSpVoice%ThisInstance%:=COM_Invoke(pSpVoice%ThisInstance%,"Speak",Text%ThisInstance%,SVSFlagsAsync)


;-- Return to sender
return



;***************
;*             *
;*    Pause    *
;*             *
;***************
Pause1:
Pause2:
Pause3:
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


if PauseRequest%ThisInstance%
    {
    COM_Invoke(pSpVoice%ThisInstance%,"Resume")
    PauseRequest%ThisInstance%:=false
    GUIControl,,PauseButton%ThisInstance%,Pause
    }
 else
    {
    COM_Invoke(pSpVoice%ThisInstance%,"Pause")
    PauseRequest%ThisInstance%:=true
    GUIControl,,PauseButton%ThisInstance%,Resume
    }

return



;**************
;*            *
;*    Stop    *
;*            *
;**************
Stop1:
Stop2:
Stop3:
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


;-- Resume if paused (keeps the stream from getting lost/stuck)
if PauseRequest%ThisInstance%
    COM_Invoke(pSpVoice%ThisInstance%,"Resume")


;-- Disable GUI objects
GUIControl Disable,PauseButton%ThisInstance%
GUIControl,,PauseButton%ThisInstance%,Pause
GUIControl Disable,StopButton%ThisInstance%


;-- Stop request
StopRequest%ThisInstance%:=true
COM_Invoke(pSpVoice%ThisInstance%,"Speak","",SVSFlagsAsync|SVSFPurgeBeforeSpeak)
    ;-- Send empty string with SVSFPurgeBeforeSpeak flag to stop playback.

return



;******************
;*                *
;*    Priority    *
;*                *
;******************
Priority1:
Priority2:
Priority3:
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


;-- Collect form variables
gui Submit,NoHide


;-- Set Priority
COM_Invoke(pSpVoice%ThisInstance%,"Priority",Priority%ThisInstance%-1)
    ;-- Note: Setting the priority can be done at any time but if it's done 
    ;   while a Voice is active (speaking, paused, or interrupted), the
    ;   operation will interrupt/reset the voice stream.

return



;***************
;*             *
;*    Voice    *
;*             *
;***************
Voice1:
Voice2:
Voice3:
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


;-- Collect form variables
gui Submit,NoHide


;-- Set Voice
COM_Invoke(pSpVoice%ThisInstance%,"Voice","+" . COM_Invoke(pSpVoice%ThisInstance%,"GetVoices(" . """" . "Name=" . Voice%ThisInstance% . """" . ").Item(0)")) 
    ;-- Note: Setting the voice can be done at any time but the new voice does
    ;   take effect unless/until the Voice instance is inactive.

return



;**************
;*            *
;*    Rate    *
;*            *
;**************
Rate1:
Rate2:
Rate3:
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


;-- Collect form variables
gui Submit,NoHide


;-- Set Rate
COM_Invoke(pSpVoice%ThisInstance%,"Rate",Rate%ThisInstance%)
return



;****************
;*              *
;*    Volume    *
;*              *
;****************
Volume1:
Volume2:
Volume3:
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


;-- Collect form variables
gui Submit,NoHide


;-- Set Volume
COM_Invoke(pSpVoice%ThisInstance%,"Volume",Volume%ThisInstance%)
return



;**************
;*            *
;*    Done    *
;*            *
;**************
Done1:
Done2:
Done3:
outputdebug Subroutine: %A_ThisLabel%

ThisInstance:=SubStr(A_ThisLabel,StrLen(A_ThisLabel))


;-- Resume if paused (keeps the stream from getting lost/stuck)
if PauseRequest%ThisInstance%
    COM_Invoke(pSpVoice%ThisInstance%,"Resume")


;-- Enable/Disable GUI objects
GUIControl Enable, SpeakButton%ThisInstance%
GUIControl Disable,PauseButton%ThisInstance%
GUIControl,,PauseButton%ThisInstance%,Pause
GUIControl Disable,StopButton%ThisInstance%
GUIControl Enable, Voice%ThisInstance%


;-- Set focus
GUIControl Focus,SpeakButton%ThisInstance%


;-- Return to sender
return



;**************
;*            *
;*    Exit    *
;*            *
;**************
Exit:
outputdebug Subroutine: %A_ThisLabel%
loop 3
    {
    if pSink%A_Index%
        COM_Release(pSink%A_Index%)

    if pSpVoice%A_Index%
        COM_Release(pSpVoice%A_Index%)
    }


;-- Terminate COM
COM_Term()
ExitApp



;***************************
;*                         *
;*                         *
;*        Functions        *
;*                         *
;*                         *
;***************************
;;;;;1OnStartStream(prms,this)
;;;;;    {
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;;;;;    outputdebug A_ThisFunc=%A_ThisFunc%
;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;;;;;    return
;;;;;    }


1OnEndStream(prms,this)
    {
    Global StopRequest1

    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    outputdebug A_ThisFunc=%A_ThisFunc%

    ;-- Bounce if StopRequest
    if StopRequest1
        {
        StopRequest1:=false
        outputdebug Stop Request - Bounced!
        outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
        return
        }

    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
        . COM_DispGetParam(prms,0)
    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
        . COM_DispGetParam(prms,1)
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


    gosub Done1
    return
    }

2OnEndStream(prms,this)
    {
    Global StopRequest2

    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    outputdebug A_ThisFunc=%A_ThisFunc%

    ;-- Bounce if StopRequest
    if StopRequest2
        {
        StopRequest2:=false
        outputdebug Stop Request - Bounced!
        outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
        return
        }

    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
        . COM_DispGetParam(prms,0)
    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
        . COM_DispGetParam(prms,1)
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


    gosub Done2
    return
    }


3OnEndStream(prms,this)
    {
    Global StopRequest3

    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    outputdebug A_ThisFunc=%A_ThisFunc%

    ;-- Bounce if StopRequest
    if StopRequest3
        {
        StopRequest3:=false
        outputdebug Stop Request - Bounced!
        outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
        return
        }

    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
        . COM_DispGetParam(prms,0)
    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
        . COM_DispGetParam(prms,1)
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


    gosub Done3
    return
    }

