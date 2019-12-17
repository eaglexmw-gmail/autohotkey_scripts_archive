;-------------------------------------------------------------------------------
;
; This script attempts to duplicate most of the functionality of the TTSApp
; demo that is provided with the Microsoft Speech SDK 5.1.  Some of the methods
; for accomplishing the tasks were extracted from the TTSAppMain.frm (Visual
; Basic source) file.
;
; To display the microphone annimation, this script uses icon files stored in a
; "Res" sub-folder.
;
;-------------------------------------------------------------------------------


;********************************
;*                              *
;*    AutoHotkey environment    *
;*                              *
;********************************
#NoEnv
SetBatchLines 100ms  ;-- A little bump in speed.  Not sure if it's necessary.
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


;-- Create SpVoice instance
pSpVoice:=COM_CreateObject("SAPI.SpVoice")
outputdebug % "pSpVoice=" . pSpVoice


;-- Build list of Voices
VoiceList=
loop % COM_Invoke(pSpVoice,"GetVoices.Count")
    {
    Name:=COM_Invoke(pSpVoice,"GetVoices.Item(" . A_Index-1 . ")" . ".GetAttribute","Name")
    if VoiceList is Space
        VoiceList:=Name
     else
        VoiceList:=VoiceList . "|" . Name
    }


;-- Build list of Audio Outputs
AudioOutputList=
loop % COM_Invoke(pSpVoice,"GetAudioOutputs.Count")
    {
    Name:=COM_Invoke(pSpVoice,"GetAudioOutputs.Item(" . A_Index-1 . ")" . ".GetDescription")
    if AudioOutputList is Space
        AudioOutputList:=Name
     else
        AudioOutputList:=AudioOutputList . "|" . Name
    }



;*******************
;*                 *
;*    Build GUI    *
;*                 *
;*******************
gui Margin,6,6
gui Add
   ,Picture
   ,xm y10
        || +0x1000  ;-- Half-sunken border
        || +AltSubmit
        || +BackgroundTrans
        || vMicFull
   ,Res/mic.ico

gui Add
   ,Picture
   ,xp yp wp hp
        || +0x1000  ;-- Half-sunken border
        || +AltSubmit
        || +BackgroundTrans
        || vMicEyes

gui Add
   ,Picture
   ,xp yp wp hp
        || +0x1000  ;-- Half-sunken border
        || +AltSubmit
        || +BackgroundTrans
        || vMicMouth

gui Add
   ,Edit
   ,x+10 ym w300 h170
        || +0x100   ;-- ES_NOHIDESEL  
        || vText,
   (ltrim
    This old man, he played one,
    He played knick-knack on my thumb,
    With a knick-knack paddywhack, give a dog a bone,
    This old man came rolling home.
   )


gui Add
   ,Button
   ,x+10 ym w80 h20
        || Section
        || vSpeakButton
        || gSpeak
   ,Speak

gui Add
   ,Button
   ,y+0 wp hp
        || Disabled
        || vPauseButton
        || gPause
   ,Pause

gui Add
   ,Button
   ,y+0 wp hp
        || Disabled
        || vStopButton
        || gstop
   ,Stop


gui Add
   ,Button
   ,y+0 w40 hp
        || Disabled
        || vSkipButton
        || gSkip
   ,Skip

gui Add
   ,Edit
   ,x+0 w40 hp
        || vSkip

gui Add,UpDown,x+0 w20 hp


gui Add
   ,Button
   ,xs y+10 w80 h20
        || vOpenFileButton
        || gOpenFile
   ,Open file...

gui Add
   ,Button
   ,y+0 wp hp
        || vSpeakFileButton
        || gSpeakFile
   ,Speak file...


gui Add
   ,Button
   ,y+0 wp hp
        || vSaveToFileButton
        || gSaveToFile
,Save to...


gui Add
   ,Button
   ,xs y+0 wp hp
        || gReload
   ,Reload

gui Add
   ,CheckBox
   ,xm+10 y150
        || vAnimate
        || gAnimate
   ,Animate

gui Add
   ,Text
   ,xm y190 w50 h30
        || Section
   ,Voice:

gui Add
   ,DropDownList
   ,x+0 w200 hp r5
        || vVoice
        || gVoice
   ,%VoiceList%

GUIControl
    ,ChooseString
    ,Voice
    ,% COM_Invoke(pSpVoice,"Voice.GetDescription")

gui Add
   ,Text
   ,xm y+0 w50 h30
   ,Rate:

gui Add
   ,Slider
   ,x+0 w200 hp
        || Range-10-10
        || TickInterval10
        || ToolTip
        || vRate
        || gRate
   ,% COM_Invoke(pSpVoice,"Rate")

gui Add
   ,Text
   ,xm y+0 w50 h30
   ,Volume:

gui Add
   ,Slider
   ,x+0 w200 hp
        || Range0-100
        || TickInterval10
        || ToolTip
        || vVolume
        || gVolume
   ,% COM_Invoke(pSpVoice,"Volume")

gui Add
   ,Text
   ,xm y+0 w50 h30
   ,Format:

gui Add
   ,DropDownList
   ,x+0 w200 hp r5
        || +AltSubmit
        ||  vAudioOutputStreamFormatType
        ||  gAudioOutputStreamFormatType
   ,%AudioOutputStreamFormatTypeDescriptionList%

GUIControl
    ,Choose
    ,AudioOutputStreamFormatType
    ,% COM_Invoke(pSpVoice,"AudioOutputStream.Format.Type")-3

gui Add
   ,Text
   ,xm y+0 w50 h30
   ,Audio Output:

gui Add
   ,DropDownList
   ,x+0 w200 hp
        || +AltSubmit
        || vAudioOutput
        || gAudioOutput
   ,%AudioOutputList%

GUIControl
    ,ChooseString
    ,AudioOutput
    ,% COM_Invoke(pSpVoice,"AudioOutput.GetDescription")


gui Add
   ,GroupBox
   ,x270 ys w260 h100
   ,Speak Flags

gui Add,Checkbox
   ,xp+10 yp+20 w120
        || Section
        || Checked
        || vFlagsAsync
        || gSpeakFlags
   ,Asynchronous

gui Add
   ,CheckBox
   ,x+0 wp
        || Checked
        || vPurgeBeforeSpeak
        || gSpeakFlags
   ,Purge Before Speak

gui Add
   ,Checkbox
   ,xs+0 y+10 wp
        || vIsFilename
        || gSpeakFlags
   ,Is Filename

gui Add
   ,CheckBox
   ,x+0 wp
        || vIsXML
        || gSpeakFlags
   ,Is XML

gui Add
   ,Checkbox
   ,xs+0 y+10 wp
        || vPersistXML
        || gSpeakFlags
   ,Persist XML

gui Add
   ,CheckBox
   ,x+0 wp
        || vNLPSpeakPunc
        || gSpeakFlags
   ,NLP Speak Punc



;-- Set initial SpeakFlags
gosub SpeakFlags


;-- Set focus
GUIControl Focus,SpeakButton


;-- Show it
gui Show,,Text-To-Speech via COM - Example 1


;-- Identify window handle
gui +LastFound
WinGet Example1GUI_hWnd,ID
return



;*******************
;*                 *
;*    GUI Close    *
;*                 *
;*******************
GUIEscape:
GUIClose:
ExitApp



;***************
;*             *
;*    Speak    *
;*             *
;***************
Speak:
outputdebug Subroutine: %A_ThisLabel%


;-- Collect form variables
gui Submit,NoHide


;[==========]
;[  Verify  ]
;[==========]
;-- Bounce if there is no text
if Text is Space
    return


;-- If IsFilename flag is set, verify that the file exists 
if IsFilename
    IfNotExist %Text%
        {
        if StrLen(Text)>256
            Text={Long Text Field}

        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,File Not Found,
               (ltrim
                Cannot find the specified file:  %A_Space%
                %Text%  %A_Space%
                `nPlease enter a valid file name or clear the 'Is FileName" flag.  %A_Space%
               )
    
        return
        }


;[==============]
;[  Initialize  ]
;[==============]
PauseRequest:=false
StopRequest:=false

;-- If necessary, establish Sink (event interface)
if not pSink
    {
    pSink:=COM_ConnectObject(pSpVoice,"On")
    outputdebug pSink=%pSink%
    }


;-- Turn off animation?
if not FlagsAsync
    Animate:=false


;-- Enable/Disable GUI objects
GUIControl Disable,SpeakButton
GUIControl Enable, PauseButton
GUIControl Enable, StopButton
GUIControl Enable, SkipButton
GUIControl Disable,OpenFileButton
GUIControl Disable,SpeakFileButton
GUIControl Disable,SaveToFileButton
GUIControl Disable,Voice
GUIControl Disable,AudioOutputStreamFormatType
GUIControl Disable,AudioOutput


;-- Set focus
GUIControl Focus,PauseButton


;[=========]
;[  Speak  ]
;[=========]
StreamForpSpVoice:=COM_Invoke(pSpVoice,"Speak",Text,SpeakFlags)


;-- Return to sender
return



;***************
;*             *
;*    Pause    *
;*             *
;***************
Pause:
outputdebug Subroutine: %A_ThisLabel%

if PauseRequest
    {
    COM_Invoke(pSpVoice,"Resume")
    PauseRequest:=false
    GUIControl,,PauseButton,Pause
    }
 else
    {
    COM_Invoke(pSpVoice,"Pause")
    PauseRequest:=true
    GUIControl,,PauseButton,Resume
    }

return




;**************
;*            *
;*    Stop    *
;*            *
;**************
Stop:
outputdebug Subroutine: %A_ThisLabel%


;-- Resume if paused (keeps the stream from getting lost/stuck)
if PauseRequest
    COM_Invoke(pSpVoice,"Resume")


;-- Disable GUI objects
GUIControl Disable,PauseButton
GUIControl,,PauseButton,Pause
GUIControl Disable,StopButton


;-- Stop request
StopRequest:=true
COM_Invoke(pSpVoice,"Speak","",SVSFlagsAsync|SVSFPurgeBeforeSpeak)
    ;-- Send empty string with SVSFPurgeBeforeSpeak flag to stop playback.

return



;**************
;*            *
;*    Skip    *
;*            *
;**************
Skip:
outputdebug Subroutine: %A_ThisLabel%

;-- Collect form variables
gui Submit,NoHide


;-- Bounce if Skip=0
if Skip=0
    return


;-- Bounce if Voice is not speaking (paused, interrupted, etc.)
if COM_Invoke(pSpVoice,"Status.RunningState")<>SRSEIsSpeaking
    return


;-- Skip
outputdebug % "Skip="
    . COM_Invoke(pSpVoice,"Skip","Sentence",Skip)
    ;-- The value retured is the number of object types skipped.
    ;   Note: The only type currently supported is "Sentence".

return



;***************
;*             *
;*    Voice    *
;*             *
;***************
Voice:
outputdebug Subroutine: %A_ThisLabel%


;-- Collect form variables
gui Submit,NoHide


;-- Set Voice
COM_Invoke(pSpVoice,"Voice","+" . COM_Invoke(pSpVoice,"GetVoices(" . """" . "Name=" . Voice . """" . ").Item(0)")) 
    ;-- Note: Setting the voice can be done at any time but the new voice does
    ;   take effect unless/until the Voice instance is inactive.

return




;**************
;*            *
;*    Rate    *
;*            *
;**************
Rate:
outputdebug Subroutine: %A_ThisLabel%

;-- Collect form variables
gui Submit,NoHide


;-- Set Rate
COM_Invoke(pSpVoice,"Rate",Rate)
return



;****************
;*              *
;*    Volume    *
;*              *
;****************
Volume:
outputdebug Subroutine: %A_ThisLabel%


;-- Collect form variables
gui Submit,NoHide


;-- Set Volume
COM_Invoke(pSpVoice,"Volume",Volume)
return



;*************************************
;*                                   *
;*    AudioOutputStreamFormatType    *
;*                                   *
;*************************************
AudioOutputStreamFormatType:
outputdebug Subroutine: %A_ThisLabel%


;-- Collect form variables
gui Submit,NoHide


;---------------------
;-- AudioOutputStream
;---------------------
;-- Turn AllowAudioOutputFormatChangesOnNextSet off
COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet",false)

;-- Set to new type
COM_Invoke(pSpVoice,"AudioOutputStream.Format.Type",AudioOutputStreamFormatType+3)

;-- Assign to self
COM_Invoke(pSpVoice,"AudioOutputStream","+" . COM_Invoke(pSpVoice,"AudioOutputStream"))
    ;-- This assignment is necessary so that SAPI picks up the new format

;-- Turn AllowAudioOutputFormatChangesOnNextSet back on
COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet",true)

return




;*********************
;*                   *
;*    AudioOutput    *
;*                   *
;*********************
AudioOutput:
outputdebug Subroutine: %A_ThisLabel%


;-- Collect form variables
gui Submit,NoHide


;-- Set AudioOutput
COM_Invoke(pSpVoice,"AudioOutput","+" . COM_Invoke(pSpVoice,"GetAudioOutputs.Item(" . AudioOutput-1 . ")"))


;-- Changing the output may also change the format, so reset the format
gosub AudioOutputStreamFormatType

return



;**********************
;*                    *
;*    Animate Flag    *
;*                    *
;**********************
Animate:
outputdebug Subroutine: %A_ThisLabel%


;-- Collect form variables
gui Submit,NoHide


return



;*********************
;*                   *
;*    Speak Flags    *
;*                   *
;*********************
SpeakFlags:
outputdebug Subroutine: %A_ThisLabel%


;-- Collect form variables
gui Submit,NoHide


;-- Set SpeakFlags
SpeakFlags:=SVSFDefault

if FlagsAsync
    SpeakFlags:=SpeakFlags+SVSFlagsAsync

if PurgeBeforeSpeak
    SpeakFlags:=SpeakFlags+SVSFPurgeBeforeSpeak

if IsFilename
    SpeakFlags:=SpeakFlags+SVSFIsFilename

if IsXML
    SpeakFlags:=SpeakFlags+SVSFIsXML

if PersistXML
    SpeakFlags:=SpeakFlags+SVSFPersistXML

if NLPSpeakPunc
    SpeakFlags:=SpeakFlags+SVSFNLPSpeakPunc


outputdebug SpeakFlags:=%SpeakFlags%

return



;**************
;*            *
;*    Done    *
;*            *
;**************
Done:
outputdebug Subroutine: %A_ThisLabel%

;-- Resume if paused (keeps the stream from getting lost/stuck)
if PauseRequest
    COM_Invoke(pSpVoice,"Resume")


;-- Reset Picture
;;;;;GUIControl -Redraw,MicFull
GUIControl -Redraw,MicEyes
GUIControl -Redraw,MicMouth
GUIControl,,MicEyes
GUIControl,,MicMouth
GUIControl +Redraw,MicFull
GUIControl +Redraw,MicEyes
GUIControl +Redraw,MicMouth


;-- Enable/Disable GUI objects
GUIControl Enable, SpeakButton
GUIControl Disable,PauseButton
GUIControl,,PauseButton,Pause
GUIControl Disable,StopButton
GUIControl Disable,SkipButton
GUIControl Enable, OpenFileButton
GUIControl Enable, SpeakFileButton
GUIControl Enable, SaveToFileButton
GUIControl Enable, Voice
GUIControl Enable, AudioOutputStreamFormatType
GUIControl Enable, AudioOutput


;-- Set focus
GUIControl Focus,SpeakButton


;-- Return to sender
return



;*******************
;*                 *
;*    Open File    *
;*                 *
;*******************
OpenFile:
outputdebug Subroutine: %A_ThisLabel%

;-- Attach messages and dialogs to the current GUI
gui +OwnDialogs


;-- Initialize OpenFilePath
;;;;;if OpenFilePath is Space
;;;;;    OpenFilePath:=A_MyDocuments

if OpenFilePath is Space
    OpenFilePath:=A_ScriptDir


;[=================]
;[  Browse for it  ]
;[=================]
FileSelectFile
    ,OpenFileFileName                           ;-- OutputVar
    ,1                                          ;-- Options. 1=File must exist
    ,%OpenFilePath%                             ;-- Starting path
    ,Open Text File...                          ;-- Prompt
    ,Text, XML Files (*.txt;*.xml)              ;-- Filter

;-- Cancel?
If ErrorLevel
    return


;-- Redefine OpenFilePath
SplitPath OpenFileFileName,,OpenFilePath


;-- Read into variable
FileRead TextFileData,%OpenFileFileName%


;-- Copy to Text object
GUIControl,,Text,%TextFileData%


;-- Clear IsFileName Flag
GUIControl,,IsFileName,0
gosub SpeakFlags


;[================]
;[  Housekeeping  ]
;[================]
TextFileData=

;-- Return to sender
outputdebug End Subrou: %A_ThisLabel%
return



;********************
;*                  *
;*    Speak File    *
;*                  *
;********************
SpeakFile:
outputdebug Subroutine: %A_ThisLabel%

;-- Attach messages and dialogs to the current GUI
gui +OwnDialogs


;-- Initialize SpeakFilePath
;;;;;if SpeakFilePath is Space
;;;;;    SpeakFilePath:=A_MyDocuments

if SpeakFilePath is Space
    SpeakFilePath:=A_ScriptDir


;[=================]
;[  Browse for it  ]
;[=================]
FileSelectFile
    ,SpeakFileName                              ;-- OutputVar
    ,1                                          ;-- Options. 1=File must exist
    ,%SpeakFilePath%                            ;-- Starting path
    ,Speak Text or Wave Files                   ;-- Prompt
    ,Text, Wave Files (*.txt;*.xml;*.wav)       ;-- Filter

;-- Cancel?
If ErrorLevel
    return


;-- Redefine SpeakFilePath
SplitPath SpeakFileName,,SpeakFilePath


;-- Copy path to Text object
GUIControl,,Text,%SpeakFileName%


;-- Select IsFileName Flag
GUIControl,,IsFileName,1
gosub SpeakFlags

;-- Speak
gosub Speak


;-- Return to sender
outputdebug End Subrou: %A_ThisLabel%
return



;********************
;*                  *
;*    Save to...    *
;*                  *
;********************
SaveToFile:
outputdebug Subroutine: %A_ThisLabel%

;-- Attach messages and dialogs to the current GUI
gui +OwnDialogs


;-- Initialize SaveToFilePath
;;;;;if SaveToFilePath is Space
;;;;;    SaveToFilePath:=A_MyDocuments

if SaveToFilePath is Space
    SaveToFilePath:=A_ScriptDir


;[=================]
;[  Browse for it  ]
;[=================]
FileSelectFile
    ,SaveToFileName                     ;-- OutputVar
    ,S16                                ;-- Options. 16=Prompt to overWrite file
    ,%SaveToFilePath%                   ;-- Starting path
    ,Save to Wave File...               ;-- Prompt
    ,Wave Files (*.wav)                 ;-- Filter

;-- Cancel?
If ErrorLevel
    return


;-- Redefine SaveToFilePath
SplitPath SaveToFileName,,SaveToFilePath


;-- Collect form variables
gui Submit,NoHide


;-- Create SpFileStream instance
pSpFileStream:=COM_CreateObject("SAPI.SpFileStream.1")
outputdebug % "pSpFileStream=" . pSpFileStream


;-- Set output format to the selected format
COM_Invoke(pSpFileStream,"Format.Type",AudioOutputStreamFormatType+3)


;-- Open the file for write
SSFMCreateForWrite:=3
COM_Invoke(pSpFileStream,"Open",SaveToFileName,SSFMCreateForWrite,false)


;-- Set the output stream to the file stream
COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet",false)
COM_Invoke(pSpVoice,"AudioOutputStream","+" . pSpFileStream)


;-- Speak using the given flags
COM_Invoke(pSpVoice,"Speak",Text,SpeakFlags)


;-- Wait until done
rWaitUntilDone:=COM_Invoke(pSpVoice,"WaitUntilDone",-1)
outputdebug Save complete.  rWaitUntilDone=%rWaitUntilDone%


;-- Reset AudioOutput which will also reset the AudioOutputStream
gosub AudioOutput


;-- Close the file stream
COM_Invoke(pSpFileStream,"Close")


;-- Release the SpFileStream instance
COM_Release(pSpFileStream)


;-- Inform the user
MsgBox
    ,64  ;-- 64 = 0 (Ok Button) + 64 (Info icon)
    ,File Saved
    ,Wave file successfully written to:  %A_Space%`n%SaveToFileName%  %A_Space%


;-- Return to sender
outputdebug End Subrou: %A_ThisLabel%
return



;****************
;*              *
;*    Reload    *
;*              *
;****************
Reload:
Reload
return



;**************
;*            *
;*    Exit    *
;*            *
;**************
Exit:
Outputdebug Subroutine: Exit
if pSink
    COM_Release(pSink)

if pSpVoice
    COM_Release(pSpVoice)

COM_Term()
ExitApp





;*********************************
;*                               *
;*                               *
;*        Event Functions        *
;*                               *
;*                               *
;*********************************
;*********************
;*                   *
;*    StartStream    *
;*                   *
;*********************
OnStartStream(prms,this)
    {
    Global NLTable
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    outputdebug A_ThisFunc=%A_ThisFunc%
;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)

    NLTable=
        ;-- This table is used by the OnWord function

    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    return
    }


;****************
;*              *
;*    Viseme    *
;*              *
;****************
OnViseme(prms,this)
    {
    Global Animate
    Static LastVisemeId

    ;-- Bounce if Animate is not enabled
    if not Animate
        return


;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;;;;;    outputdebug A_ThisFunc=%A_ThisFunc%
;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)
;;;;;    outputdebug % "COM_DispGetParam(prms,2) (Duration)="
;;;;;        . COM_DispGetParam(prms,2)
;;;;;    outputdebug % "COM_DispGetParam(prms,3) (NextVisemeId)="
;;;;;        . COM_DispGetParam(prms,3)


    VisemeId:=COM_DispGetParam(prms,3)


    ;-- Bounce if the VisemeId has not changed
    if (VisemeId=LastVisemeId)
        {
;;;;;        outputdebug Same VisemId as last.  Bounced!
;;;;;        outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
        return
        }

    LastVisemeId:=VisemeId

    ;-- Redraw off
;;;;;    GUIControl -Redraw,MicFull
    GUIControl -Redraw,MicEyes
    GUIControl -Redraw,MicMouth

    if VisemeId=0
        {
        GUIControl,,MicEyes
        GUIControl,,MicMouth
        RedrawMicFull:=true
        }
     else
        {
        ;-- Eyes
        if Mod(VisemeId,6)=2
            GUIControl,,MicEyes,res\mic_eyes_closed.ico
          else
            if Mod(VisemeId,6)=5
                GUIControl,,MicEyes,res\mic_eyes_narrow.ico
             else
                {
                GUIControl,,MicEyes
                RedrawMicFull:=true
                }


        ;-- Mouth
        if VisemeId in 1,2,3,5,11,21
            ID:=11
         else
            if VisemeId=4
                ID:=10
             else
                if VisemeId in 6,9,12,20
                    ID:=9
                 else
                    if VisemeId=7
                        ID:=2
                     else
                        if VisemeId=8
                            ID:=13
                         else
                            if VisemeId=10
                                ID:=12
                             else
                                if VisemeId=13
                                    ID:=3
                                 else
                                    if VisemeId=14
                                        ID:=6
                                     else
                                        if VisemeId=15
                                            ID:=7
                                         else
                                            if VisemeId=16
                                                ID:=8
                                             else
                                                if VisemeId=17
                                                    ID:=5
                                                 else
                                                    if VisemeId=18
                                                        ID:=4
                                                     else
                                                        if VisemeId=19
                                                            ID:=7
                                                         else
                                                            if VisemeId=21
                                                                ID:=1


        GUIControl,,MicMouth,res\mic_mouth_%ID%.ico
        }


    ;-- Redraw on
    GUIControl +Redraw,MicEyes
    GUIControl +Redraw,MicMouth

    if RedrawMicFull
        {
        GUIControl +Redraw,MicFull
        RedrawMicFull:=false
        }

;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    return
    }



;**************
;*            *
;*    Word    *
;*            *
;**************
OnWord(prms,this)
    {
    Global IsFileName,Example1GUI_hWnd,NLTable,Text

;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;;;;;    outputdebug A_ThisFunc=%A_ThisFunc%
;;;;;
;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)
;;;;;    outputdebug % "COM_DispGetParam(prms,2) (CharacterPosition)="
;;;;;        . COM_DispGetParam(prms,2)
;;;;;    outputdebug % "COM_DispGetParam(prms,3) (Length)="
;;;;;        . COM_DispGetParam(prms,3)
;;;;;
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


    ;-- Bounce if IsFileName=True
    if IsFileName
        return


    ;-- Build NLTable
    if NLTable is Space
        {
        NLPos:=1
        loop
            {
            NLPos:=InStr(Text,"`n",false,NLPos)
            if NLPos=0
                break

            if NLTable is Space
                NLTable:=NLPos-1
             else
                NLTable:=NLTable . "|" . NLPos-1

            NLPos++
            }

        outputdebug NLTable=%NLTable%
        }


    ;-- Collect StartPos
    StartPos:=COM_DispGetParam(prms,2)


    ;-- Factor in CR characters (Yes, I said CR characters)
    NLCount:=0
    loop parse,NLTable,|
        if (StartPos>A_LoopField)
            NLCount++
         else
            break

    StartPos:=StartPos+NLCount


    ;-- Select it
    SendMessage
        ,0xB1                                   ;-- EM_SETSEL
        ,%StartPos%                             ;-- Start position
        ,% StartPos+COM_DispGetParam(prms,3)    ;-- End position
        ,Edit1
        ,ahk_id %Example1GUI_hWnd%


    ;-- Scroll if necessary
    SendMessage
        ,0xB7                                   ;-- EM_SCROLLCARET
        ,0
        ,0
        ,Edit1
        ,ahk_id %Example1GUI_hWnd%

    return
    }



;*******************
;*                 *
;*    EndStream    *
;*                 *
;*******************
OnEndStream(prms,this)
    {
    Global StopRequest

;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;;;;;    outputdebug A_ThisFunc=%A_ThisFunc%

    ;-- Bounce if StopRequest
    if StopRequest
        {
        StopRequest:=false
;;;;;        outputdebug Stop Request - Bounced!
;;;;;        outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
        return
        }

;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


    ;-- Final stuff
    gosub Done
    return
    }
