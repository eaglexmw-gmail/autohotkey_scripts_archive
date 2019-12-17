;-------------------------------------------------------------------------------
;
; This script tries to do almost everything that can be done with the SpVoice
; object.  Use a debugger to see all of the values.
;
;-------------------------------------------------------------------------------


;********************************
;*                              *
;*    AutoHotkey Environment    *
;*                              *
;********************************
#NoEnv
#SingleInstance Force
OnExit Exit


;*******************
;*                 *
;*    Constants    *
;*                 *
;*******************
#include TTSConstants.ahk


;***************
;*             *
;*    Start    *
;*             *
;***************

;-- Init COM
COM_Init()

;-- Create SpVoice object
pSpVoice:=COM_CreateObject("SAPI.SpVoice")
outputdebug pSpVoice=%pSpVoice%



;[=================]
;[  AlertBoundary  ]
;[=================]
;-- Get
outputdebug % "AlertBoundary (Before)="
    . COM_Invoke(pSpVoice,"AlertBoundary")
    ;-- Observation: The default AlertBoundry appears to be SVEWordBoundary (32)

;-- Set
COM_Invoke(pSpVoice,"AlertBoundary",SVESentenceBoundary)
    ;-- Observation: No value returned when setting parameter

;- Show change
outputdebug % "AlertBoundary (After) ="
    . COM_Invoke(pSpVoice,"AlertBoundary")



;[==========================================]
;[  AllowAudioOutputFormatChangesOnNextSet  ]
;[==========================================]
;-- Get
outputdebug % "AllowAudioOutputFormatChangesOnNextSet (Before)="
    . COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet")
    ;-- Observation:  Returns -1 when AllowAudioOutputFormatChangesOnNextSet is
    ;   True.  -1 tests as True.

;-- Set
COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet",false)
    ;-- Observation: No value returned when setting parameter


;- Show change
outputdebug % "AllowAudioOutputFormatChangesOnNextSet (After) ="
    . COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet")

;-- Set back to True.  Might be used by other methods
COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet",true)



;[==================]
;[  GetAudioOutput  ]
;[==================]
/*
SpVoice.GetAudioOutputs(
     [RequiredAttributes As String = ""],
     [OptionalAttributes As String = ""]
) As ISpeechObjectTokens

Parameters
----------
RequiredAttributes
    [Optional] Specifies the RequiredAttributes. To be returned by
    GetAudioOutputs, audio output tokens must contain all of the specific
    required attributes. If no tokens match the selection, the selection
    returned will not contain any elements. By default, no attributes are
    required and so the method returns all the tokens discovered.

OptionalAttributes
    [Optional] Specifies the OptionalAttributes. Returned tokens containing the
    RequiredAttributes are sorted by OptionalAttributes. If OptionalAttributes
    is specified, the tokens are listed with the OptionalAttributes first. By
    default, no attribute is specified and the list returned from the speech
    configuration database is in the order that attributes were discovered.


Return Value
------------
An ISpeechObjectTokens collection containing the selected outputs.


*/


RAttributes="Vendor=Microsoft"  ;-- Example
RAttributes=""
    ;-- With the exception of "Vendor", I'm not sure what attribute names are
    ;   value.


;-- Count
Count:=COM_Invoke(pSpVoice,"GetAudioOutputs(" . RAttributes . ").Count")
outputdebug GetAudioOutputs.Count=%Count%
loop %Count%
    {
    outputdebug ---------------
    outputdebug AudioOutput #%A_Index%
    outputdebug ---------------


    ;-- Build GetAudioOutputs command string
    GAOCommand:="GetAudioOutputs(" . RAttributes . ").Item(" . A_Index-1 . ")"

    ;-- Id
    outputdebug % "ID="
        . COM_Invoke(pSpVoice,GAOCommand . ".Id")  ;-- Registry key


    ;-- Category ID
    outputdebug % "Category.ID="
        . COM_Invoke(pSpVoice,GAOCommand . ".Category.ID")


    ;-- GetDescription
    outputdebug % "GetDescription="
        . COM_Invoke(pSpVoice,GAOCommand . ".GetDescription")


    ;----------------
    ;-- GetAttribute
    ;----------------
    ;-- Vendor
    outputdebug % "GetAttribute.Vendor="
        . COM_Invoke(pSpVoice,"GetAudioOutputs.Item(" . A_Index-1 . ").GetAttribute","Vendor")
    }

outputdebug ---------------



;[===============]
;[  AudioOutput  ]
;[===============]
;-- Get
outputdebug % "AudioOutput.GetDescription="
    . COM_Invoke(pSpVoice,"AudioOutput.GetDescription")

outputdebug % "AudioOutput.Category.ID="
    . COM_Invoke(pSpVoice,"AudioOutput.Category.ID")

outputdebug % "AudioOutput.ID="
    . COM_Invoke(pSpVoice,"AudioOutput.ID")

    ;-- Note:  Since I only have one AudioOutput, I was not able to test 
    ;   changing this property.  See the Example1GUI.ahk script for an example
    ;   of how it's done.



;[=====================]
;[  AudioOutputStream  ]
;[=====================]
;-------
;-- Get
;-------
outputdebug --------------- AudioOutputStream (Before)
outputdebug % "AudioOutputStream.Format.Type="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.Type")


;-------
;-- Set
;-------
;-- Turn AllowAudioOutputFormatChangesOnNextSet off
COM_Invoke(pSpVoice,"AllowAudioOutputFormatChangesOnNextSet",false)

;-- Set to new type
COM_Invoke(pSpVoice,"AudioOutputStream.Format.Type",SAFT12kHz16BitMono)  ;-- Range is 4 - 39
    ;-- No value returned when setting parameter

;-- Assign to self
COM_Invoke(pSpVoice,"AudioOutputStream","+" . COM_Invoke(pSpVoice,"AudioOutputStream"))
    ;-- This assignment is necessary so that SAPI picks up the new format


;---------------
;-- Show change
;---------------
outputdebug --------------- AudioOutputStream (After)
outputdebug % "AudioOutputStream.Format.Type="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.Type")


outputdebug % "AudioOutputStream.Format.Guid="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.Guid")
        ;-- the GUID of the default format.


;-------------------
;-- GetWaveFormatEx
;-------------------
outputdebug % "AudioOutputStream.Format.GetWaveFormatEx.AvgBytesPerSec="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.GetWaveFormatEx.AvgBytesPerSec")
        ;-- AvgBytesPerSec is the required average data-transfer rate for the
        ;   format tag in bytes per second.

outputdebug % "AudioOutputStream.Format.GetWaveFormatEx.BitsPerSample="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.GetWaveFormatEx.BitsPerSample")
        ;-- BitsPerSample is the bits per sample for the FormatTag format type.

outputdebug % "AudioOutputStream.Format.GetWaveFormatEx.BlockAlign="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.GetWaveFormatEx.BlockAlign")
        ;-- BlockAlign is the the block alignment in bytes.

outputdebug % "AudioOutputStream.Format.GetWaveFormatEx.Channels="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.GetWaveFormatEx.Channels")
        ;-- Channels is the number of channels in the waveform-audio data.

outputdebug % "AudioOutputStream.Format.GetWaveFormatEx.ExtraData="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.GetWaveFormatEx.ExtraData")
        ;-- ExtraData is extra format information.

outputdebug % "AudioOutputStream.Format.GetWaveFormatEx.FormatTag="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.GetWaveFormatEx.FormatTag")
        ;-- FormatTag is the waveform-audio format type.

outputdebug % "AudioOutputStream.Format.GetWaveFormatEx.SamplesPerSec="
    . COM_Invoke(pSpVoice,"AudioOutputStream.Format.GetWaveFormatEx.SamplesPerSec")
        ;-- SamplesPerSec is the sample rate at which each channel should be
        ;   played or recorded.



;[=============]
;[  DisplayUI  ]
;[=============]
;-- I'm not sure what value this method provides.


;[==================]
;[  EventInterests  ]
;[==================]
;-- Get
outputdebug % "EventInterests (Before)="
    . COM_Invoke(pSpVoice,"EventInterests")

;-- Set
COM_Invoke(pSpVoice,"EventInterests",SVEStartInputStream|SVEEndInputStream)

;-- Show change
outputdebug % "EventInterests (After) ="
    . COM_Invoke(pSpVoice,"EventInterests")

;-- Observation: Setting EventInterests property doesn't do anything here
;   because there is no way (that I know ) to trap events using the
;   language-driven "WithEvents" method (?) that uses the EventInterests
;   property to filter which events will be triggered.  However, events can
;   be trapped by establishing a Sink (outgoing interface) by calling
;   COM_ConnectObject for the desired SpVoice object and writing the functions
;   for the desired events.


pSink:=COM_ConnectObject(pSpVoice,"On")
outputdebug pSink=%pSink%
    ;-- This establishes a Sink (events interface) to the SpVoice object
    ;   (pSpVoice) so that event notifications can be received and acted upon.
    ;   If they have been written, functions for each event will be called when
    ;   the event is triggered.
    ;
    ;   The following events from the SpVoice object can be trapped:
    ;
    ;       AudioLevel
    ;           Occurs when the TTS engine detects an audio level change while
    ;           speaking a stream for the SpVoice object.
    ;
    ;       Bookmark
    ;           Occurs when the TTS engine detects a bookmark while speaking a
    ;           stream for the SpVoice object.
    ;
    ;       EndStream
    ;           Occurs when the TTS engine reaches the end of a stream it is
    ;           speaking for the SpVoice object.
    ;
    ;       EnginePrivate
    ;           Occurs when a private TTS engine detects a custom event
    ;           condition boundary while speaking a stream for the SpVoice
    ;           object.
    ;
    ;       Phoneme
    ;           Occurs when the TTS engine detects a phoneme boundary while
    ;           speaking a stream for the SpVoice object.
    ;
    ;       Sentence
    ;           Occurs when the TTS engine detects a sentence boundary while
    ;           speaking a stream for the SpVoice object.
    ;
    ;       StartStream
    ;           Occurs when the TTS engine begins speaking a stream for the
    ;           SpVoice object.
    ;
    ;       Viseme
    ;           Occurs when the TTS engine detects a viseme boundary while
    ;           speaking a stream for the SpVoice object.
    ;
    ;       VoiceChange
    ;           Occurs when the TTS engine detects a change of voice while
    ;           speaking a stream for the SpVoice object.
    ;
    ;       Word
    ;           Occurs when the TTS engine detects a word boundary while
    ;           speaking a stream for the SpVoice object.
    ;
    ;
    ;   In this example, the function name will be prefixed with "On".  So, to
    ;   create an action for the EndStream event, write a function named
    ;   "OnOnEndStream".  See the msdn documention on
    ;   "SpVoice (Events)" for a list of parameters (different for each event)
    ;   that is passed when an event is triggered:
    ;
    ;       http://msdn.microsoft.com/en-us/library/ms723587(VS.85).aspx



;[=============]
;[  GetVoices  ]
;[=============]
/*
SpVoice.GetVoices(
     [RequiredAttributes As String = ""],
     [OptionalAttributes As String = ""]
) As ISpeechObjectTokens

Parameters
----------
RequiredAttributes
    [Optional] Specifies the RequiredAttributes. All voices selected will match
    these specifications. If no voices match the selection, the selection
    returned will contain no voices. By default, no attributes are required and
    so the list returns all the tokens discovered.

OptionalAttributes
    [Optional] Specifies the OptionalAttributes. Voices which match these
    specifications will be returned at the front of the selection. By default,
    no attribute is specified and the list returned from the speech
    configuration database is in the order that attributes were discovered.


Return Value
------------
An ISpeechObjectTokens variable containing the collection of voice tokens
selected.


Remarks
-------
The format of selection criteria is "Attribute = Value" and
"Attribute != Value." Voice attributes include "Gender," "Age," "Name,"
"Language," and "Vendor."

*/

RAttributes="Gender=Female"  ;-- Example
    ;-- If only one parameter is needed, this format appears to work.

RAttributes="Gender != Female"  ;-- Example
    ;-- If only one "NOT"  parameter is needed, this format appears to work.
    ;   Note that spaces around the "not equal" symbols (i.e. " != ") are
    ;   required.

RAttributes="[Age=Adult],[Name != Microsoft Mike]"  ;-- Example
    ;-- For multiple parameters, this format appears to work.  Note that spaces
    ;   around the "not equal" symbols (i.e. " != ") are required.

RAttributes="Name=Microsoft Mary"  ;-- Example

RAttributes=""


;-- Count
Count:=COM_Invoke(pSpVoice,"GetVoices(" . RAttributes . ").Count")
outputdebug GetVoices.Count=%Count%

loop %Count%
    {
    outputdebug ---------------
    outputdebug Voice #%A_Index%
    outputdebug ---------------


    ;-- Build GetVoices command string
    GVCommand:="GetVoices(" . RAttributes . ").Item(" . A_Index-1 . ")"


    ;-- Id
    outputdebug % "Id=" 
        . COM_Invoke(pSpVoice,GVCommand . ".Id")  ;-- Registry key


;;;;;    ;-- Category ID
;;;;;    outputdebug % "Category.ID=" 
;;;;;        . COM_Invoke(pSpVoice,GVCommand . ".Category.ID")


    ;-- GetDescription
    outputdebug % "GetDescription="
        . COM_Invoke(pSpVoice,GVCommand . ".GetDescription")


    ;----------------
    ;-- GetAttribute
    ;----------------
    ;-- Age
    outputdebug % "GetAttribute.Age="
        . COM_Invoke(pSpVoice,GVCommand . ".GetAttribute","Age")


    ;-- Gender
    Gender:=COM_Invoke(pSpVoice,GVCommand . ".GetAttribute","Gender")
    outputdebug GetAttribute.Gender=%Gender%


    ;-- Language
    outputdebug % "GetAttribute.Language="
        . COM_Invoke(pSpVoice,GVCommand . ".GetAttribute","Language")


    ;-- Name
    outputdebug % "GetAttribute.Name="
        . COM_Invoke(pSpVoice,GVCommand . ".GetAttribute","Name")


    ;-- Vendor
    outputdebug % "GetAttribute.Vendor="
        . COM_Invoke(pSpVoice,"GetVoices.Item(" . A_Index-1 . ").GetAttribute","Vendor")
    }

outputdebug ---------------



;[=================]
;[  IsUISupported  ]
;[=================]
;-- I'm not sure what value this method provides.



;[============]
;[  Priority  ]
;[============]
;-- Get
outputdebug % "Priority (Before)="
    . COM_Invoke(pSpVoice,"Priority")

;-- Set
COM_Invoke(pSpVoice,"Priority",SVPAlert)
    ;-- Observation: No value returned when setting parameter
    ;
    ;   Note: Setting the priority can be done at any time but if it's done 
    ;   while a Voice is active (speaking, paused, or interrupted), the
    ;   operation will interrupt/reset the voice stream.


;-- Show change
outputdebug % "Priority (After) ="
    . COM_Invoke(pSpVoice,"Priority")



;[=========]
;[  Voice  ]
;[=========]
;-- Get
outputdebug % "Voice (Before)="
    . COM_Invoke(pSpVoice,"Voice.GetDescription")

;-- Set
Attribute="Name=Microsoft Mary"  ;-- Example
Attribute=
COM_Invoke(pSpVoice,"Voice","+" . COM_Invoke(pSpVoice,"GetVoices(" . Attribute . ").Item(0)")) 
    ;-- Observation: No value returned when setting parameter

;-- Show change
outputdebug % "Voice (After) ="
    . COM_Invoke(pSpVoice,"Voice.GetDescription")

    ;-- Observation: Setting the Voice can be done at any time but the speaking
    ;   voice does not change unless/until the voice object is inactive.  You
    ;   can, however, change the voice in the middle of a speech if the
    ;   instructions are included in the XML.



;[=========]
;[  Speak  ]
;[=========]
txt=
   (ltrim
    Sentence number 1.
    Number 2 here.
    This be number 3.
    On to number 4.
    What else you got number 5?
   )
rSpeak:=COM_Invoke(pSpVoice,"Speak",txt,SVSFlagsAsync)
outputdebug rSpeak=%rSpeak%
    ;-- The stream number is returned. When a voice enqueues more than one
    ;   stream by speaking asynchronously, the stream number is necessary to
    ;   associate events with the appropriate stream.
    ;
    ;-- Stream 1

txt:="One. Two. Three. Four. Five. Six. Seven."
rSpeak:=COM_Invoke(pSpVoice,"Speak",txt,SVSFlagsAsync)
outputdebug rSpeak=%rSpeak%
    ;-- Stream 2

txt:="8. 9. 10"
rSpeak:=COM_Invoke(pSpVoice,"Speak",txt,SVSFlagsAsync)
outputdebug rSpeak=%rSpeak%
    ;-- Stream 3


;-- Allow the stream to progress a bit
sleep 2000



;[==========]
;[  Status  ]
;[==========]
outputdebug % "Status.CurrentStreamNumber="
    . COM_Invoke(pSpVoice,"Status.CurrentStreamNumber")
    ;-- CurrentStreamNumber is the number of the text input stream being spoken
    ;   by the TTS engine.

outputdebug % "Status.InputSentenceLength="
    . COM_Invoke(pSpVoice,"Status.InputSentenceLength")
    ;-- InputSentenceLength is the length of the sentence currently being spoken
    ;   by the TTS engine.

outputdebug % "Status.InputSentencePosition="
    . COM_Invoke(pSpVoice,"Status.InputSentencePosition")
    ;-- InputSentencePosition is the position one character prior to the
    ;   beginning of the sentence currently being spoken by the TTS engine.

outputdebug % "Status.InputWordLength="
    . COM_Invoke(pSpVoice,"Status.InputWordLength")
    ;-- Retrieves the length of the word currently being spoken by the TTS
    ;   engine.

outputdebug % "Status.InputWordPosition="
    . COM_Invoke(pSpVoice,"Status.InputWordPosition")
    ;-- InputWordPosition is the position one character prior to the beginning
    ;   of the word currently being spoken by the TTS engine.

outputdebug % "Status.LastBookmark="
    . COM_Invoke(pSpVoice,"Status.LastBookmark")
    ;-- LastBookmark is the string value of the last bookmark encountered by the
    ;   TTS engine.

outputdebug % "Status.LastBookmarkId="
    . COM_Invoke(pSpVoice,"Status.LastBookmarkId")
    ;-- LastBookmarkId is the ID of the last bookmark encountered by the TTS
    ;   engine.

outputdebug % "Status.LastHResult="
    . COM_Invoke(pSpVoice,"Status.LastHResult")
    ;-- LastHResult is the HResult, or internal status code, from the last Speak
    ;   or SpeakStream operation performed by the TTS engine.

outputdebug % "Status.LastStreamNumberQueued="
    . COM_Invoke(pSpVoice,"Status.LastStreamNumberQueued")
    ;-- LastStreamNumberQueued is the number of the last audio stream spoken by
    ;   the TTS engine.

outputdebug % "Status.PhonemeId="
    . COM_Invoke(pSpVoice,"Status.PhonemeId")
    ;-- PhonemeId is the ID of the current phoneme being spoken by the TTS
    ;   engine.

outputdebug % "Status.RunningState="
    . COM_Invoke(pSpVoice,"Status.RunningState")
    ;-- RunningState is the run state of the voice, which indicates whether the
    ;   voice is speaking or inactive. See the RunningState constants at the top
    ;   for a list of possible values.

outputdebug % "Status.VisemeId="
    . COM_Invoke(pSpVoice,"Status.VisemeId")
    ;-- VisemeId is the ID of the current viseme being spoken by the TTS engine.



;[===========================]
;[  SynchronousSpeakTimeout  ]
;[===========================]
;-- Get
outputdebug % "SynchronousSpeakTimeout (Before)="
    . COM_Invoke(pSpVoice,"SynchronousSpeakTimeout")
    ;-- Observation: The default appears to be 10,000 ms (10 seconds).  Not sure
    ;   where the default is set.

;-- Set
COM_Invoke(pSpVoice,"SynchronousSpeakTimeout",15000) ;-- 15 seconds 

;-- Show change
outputdebug % "SynchronousSpeakTimeout (After) ="
    . COM_Invoke(pSpVoice,"SynchronousSpeakTimeout")



;[========]
;[  Rate  ]
;[========]
;-- Get
outputdebug % "Rate (Before)="
    . COM_Invoke(pSpVoice,"Rate")

;-- Set
COM_Invoke(pSpVoice,"Rate",-2)  ;-- Slow it down a bit
    ;-- Observation: No value returned when setting parameter

;-- Show change
outputdebug % "Rate (After) ="
    . COM_Invoke(pSpVoice,"Rate")



;[========]
;[  Skip  ]
;[========]
outputdebug % "Skip="
    . COM_Invoke(pSpVoice,"Skip","Sentence",3)
    ;-- The value retured is the number of object types skipped.
    ;   Note: The only type currently supported is "Sentence".


;[==========]
;[  Volume  ]
;[==========]
;-- Get
outputdebug % "Volume (Before)="
    . COM_Invoke(pSpVoice,"Volume")

;-- Set
COM_Invoke(pSpVoice,"Volume",80)  ;-- Volume range is 0 (mute?) to 100 (max)
    ;-- Observation: No value returned when setting parameter

;-- Show change
outputdebug % "Volume (After) ="
    . COM_Invoke(pSpVoice,"Volume")



;[=================]
;[  WaitUntilDone  ]
;[=================]
outputdebug About to wait for 1 second using WaitUntilDone...
rWaitUntilDone:=COM_Invoke(pSpVoice,"WaitUntilDone",1000)
outputdebug rWaitUntilDone=%rWaitUntilDone%
    ;-- Return values is a boolean variable indicating which case terminated the
    ;   call. If True, the voice finished speaking; if False, the time interval
    ;   elapsed.

    ;-- Observation:  Function returns -1 when the voice finished speaking
    ;   normally. -1 tests as True



;[======================]
;[  SpeakCompleteEvent  ]
;[======================]
rSpeakCompleteEvent:=COM_Invoke(pSpVoice,"SpeakCompleteEvent")
outputdebug rSpeakCompleteEvent=%rSpeakCompleteEvent%
    ;-- The SpeakCompleteEvent method returns an event handle which is used
    ;   by the WaitForSingleObject function.
    ;
    ;   See the Example3GUI.ahk script for more information on this method.


;[=========]
;[  Pause  ]
;[=========]
outputdebug About to Pause for 4 seconds...
COM_Invoke(pSpVoice,"Pause")
    ;-- Observation: No value returned for this method

sleep 4000
    ;-- Allow the pause to occur and allow the user to identify that the pause
    ;   has occured.


;[==========]
;[  Resume  ]
;[==========]
outputdebug Resuming...
COM_Invoke(pSpVoice,"Resume")
    ;-- Observation: No value returned for this method



MsgBox Click OK when the speech has stopped.  %A_Space%
ExitApp



;**************
;*            *
;*    Exit    *
;*            *
;**************
Exit:
COM_Release(pSink)
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
OnStartStream(prms,this)
    {
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
    outputdebug A_ThisFunc=%A_ThisFunc%
    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
        . COM_DispGetParam(prms,0)
    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
        . COM_DispGetParam(prms,1)
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    return
    }


OnEndStream(prms,this)
    {
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    outputdebug A_ThisFunc=%A_ThisFunc%
    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
        . COM_DispGetParam(prms,0)
    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
        . COM_DispGetParam(prms,1)
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    return
    }



;;;;;OnSentence(prms,this)
;;;;;    {
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
;;;;;    outputdebug A_ThisFunc=%A_ThisFunc%
;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)
;;;;;    outputdebug % "COM_DispGetParam(prms,2) (CharacterPosition)="
;;;;;        . COM_DispGetParam(prms,2)
;;;;;    outputdebug % "COM_DispGetParam(prms,3) (Length)="
;;;;;        . COM_DispGetParam(prms,3)
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;;;;;    return
;;;;;    }




;;;;;OnWord(prms,this)
;;;;;    {
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
;;;;;    outputdebug A_ThisFunc=%A_ThisFunc%
;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)
;;;;;    outputdebug % "COM_DispGetParam(prms,2) (CharacterPosition)="
;;;;;        . COM_DispGetParam(prms,2)
;;;;;    outputdebug % "COM_DispGetParam(prms,3) (Length)="
;;;;;        . COM_DispGetParam(prms,3)
;;;;;    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;;;;;    return
;;;;;    }

