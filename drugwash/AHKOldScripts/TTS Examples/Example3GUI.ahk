;-------------------------------------------------------------------------------
;
; This script demonstrates a number of techniques for monitoring the end of
; of a SpVoice stream.
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


;-- Constants for the WaitForSingleObject function
WAIT_ABANDONED:=0x80    ;-- 128
    ;-- The specified object is a mutex object that was not released by the
    ;   thread that owned the mutex object before the owning thread terminated.
    ;   Ownership of the mutex object is granted to the calling thread and the
    ;   mutex state is set to nonsignaled, so there is no need to release the
    ;   mutex.
    ;
    ;   If the mutex was protecting persistent state information, you should
    ;   check it for consistency.

WAIT_OBJECT_0:=0x0       ;-- 0
    ;-- The state of the specified object is signaled.

WAIT_TIMEOUT:=0x102      ;-- 258
    ;-- The time-out interval elapsed, and the object's state is nonsignaled.

WAIT_FAILED:=0xFFFFFFFF
    ;-- The function has failed. To get extended error information, call
    ;   GetLastError.



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



;*******************
;*                 *
;*    Build GUI    *
;*                 *
;*******************
gui -MinimizeBox
gui Margin,6,6
gui Add,GroupBox,xm y10 w290 h150,End-Of-Speech Examples
gui Add,Radio,xp+10 yp+20 h20 Section Checked vExample1,Example 1: Synchronous (Default)
gui Add,Radio,xs y+0 hp vExample2,Example 2: WaitUntilDone Method: No Timeout
gui Add,Radio,xs y+0 hp vExample3,Example 3: WaitUntilDone Method: Polling
gui Add,Radio,xs y+0 hp vExample4,Example 4: SpeakCompleteEvent Method (Win2K+)
gui Add,Radio,xs y+0 hp vExample5,Example 5: Polling with a Timer
gui Add,Radio,xs y+0 hp vExample6,Example 6: EndStream Event
gui Add,Button,xs+20 y+20 w80 h30 vSpeakButton gSpeak,Speak!
gui Add,Button,x+0 w80 hp Disabled vStopButton gStop,Stop
gui Add,Button,x+10 w70 hp gGUITest,GUI Test
gui Show,,Text-To-Speech via COM - Example 3
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


;[==============]
;[  Initialize  ]
;[==============]

;-- Collect form variables
gui Submit,NoHide


;-- Enable/Disable buttons
GUIControl Disable,SpeakButton
GUICOntrol Enable ,StopButton


;[=========================]
;[        Example 1        ]
;[  Synchronous (Default)  ]
;[=========================]
if Example1
    {
    ;-- Speak
    Text=Example 1. Synchronous.  This is the Text-To-Speech default.
    COM_Invoke(pSpVoice,"Speak",Text,SVSFDefault)
        ;-- Note: Because the Asynchronous flag is not used, the call does
        ;   not return until the text has been spoken.


    ;-- Wrap it up
    gosub Done
    return
    }

;-------------------------------------------------------------------------------
;
; Example 1 comments:
;
; This "wait for it" method is useful if speaking very short text or sound files
; (less than 1 second?) or if running a non-interactive script.
;
--------------------------------------------------------------------------------


;[========================]
;[        Example 2       ]
;[  WaitUntilDone Method  ]
;[      (No Timeout)      ]
;[========================]
if Example2
    {
    ;-- Speak
    Text=Example 2. Wait-Until-Done Method. No Time-out.
    COM_Invoke(pSpVoice,"Speak",Text,SVSFlagsAsync)
        ;-- Note: Because the Asynchronous flag is used, the call returns
        ;   immediately.


    ;-- Wait for it
    COM_Invoke(pSpVoice,"WaitUntilDone",-1)
        ;-- With a -1 timeout period (no timeout), this command will wait until
        ;   the voice is done speaking.


    ;-- Wrap it up
    gosub Done
    return
    }

;-------------------------------------------------------------------------------
;
; Example 2 comments:
;
; The WaitUntilDone method with a -1 timeout period (no timeout) works the same
; same as Example 1 (Speak method without the Asynchronous flag).
;
--------------------------------------------------------------------------------


;[========================]
;[        Example 3       ]
;[  WaitUntilDone Method  ]
;[       (Polling)        ]
;[========================]
if Example3
    {
    ;-- Speak
    Text=Example 3. Wait-Until-Done Method.  Polling for time-out.
    COM_Invoke(pSpVoice,"Speak",Text,SVSFlagsAsync)
        ;-- Note: Because the Asynchronous flag is used, the call returns
        ;   immediately.


    ;-- Wait for it
    loop
        if COM_Invoke(pSpVoice,"WaitUntilDone",100)
            break
        

    ;-- Wrap it up
    gosub Done
    return
    }

;-------------------------------------------------------------------------------
;
;   Example 3 comments:
;
;   This example is the same as Example 2 but instead of waiting indefinately,
;   the script waits in 100 ms increments for the voice to finish speaking.
;   These "breaks" in the waiting cycle allow for the script to remain
;   interactive.
;
--------------------------------------------------------------------------------


;[=============================]
;[          Example 4          ]
;[  SpeakCompleteEvent Method  ]
;[=============================]
if Example4
    {
    ;-- Speak
    Text=Example 4. Speak; Complete; Event; Method. 
    COM_Invoke(pSpVoice,"Speak",Text,SVSFlagsAsync)
        ;-- Note: Because the Asynchronous flag is used, the call returns
        ;   immediately.


    ;-- SpeakCompleteEvent
    hSpeakCompleteEvent:=COM_Invoke(pSpVoice,"SpeakCompleteEvent")
        ;-- The SpeakCompleteEvent method returns an event handle which is used
        ;   by the WaitForSingleObject function.


    ;-- Wait for it
    loop
        if DllCall("WaitForSingleObject","Int",hSpeakCompleteEvent,"Int",100)=WAIT_OBJECT_0
            break

        ;-- See the WaitForSingleObject constants (above) for a list of values
        ;   that can be returned from the WaitForSingleObject function.
        ;
        ;   Note: The minimum OS version for this function is Windows 2000 
        ;   Professional.  For more information, see the
        ;   "WaitForSingleObject Function" page on msdn:
        ;
        ;       http://msdn.microsoft.com/en-us/library/ms687032.aspx


    ;-- Wrap it up
    gosub Done
    return
    }

;-------------------------------------------------------------------------------
;
;   Example 4 comments:
;
;   As written, this example works the same as Example 3.  If the timeout
;   period were set to -1 (no timeout), the example would work the same as
;   Example 2.
;
--------------------------------------------------------------------------------


;[========================]
;[        Example 5       ]
;[  Polling with a Timer  ]
;[========================]
if Example5
    {
    ;-- Speak
    Text=Example 5.  Polling with a timer.
    COM_Invoke(pSpVoice,"Speak",Text,SVSFlagsAsync)
        ;-- Note: Because the Asynchronous flag is used, the call returns
        ;   immediately.


    ;-- Use a timer to wait for it
    SetTimer WaitUntilDone,100
    return
    }

;-------------------------------------------------------------------------------
;
;   Example 5 comments:
;
;   This example works the same as Examples 3 and 4.  The difference is that
;   a timer is used to create an independent thread to periodically check to
;   see if the voice is done speaking.
;
--------------------------------------------------------------------------------


;[===================]
;[     Example 5     ]
;[  EndStream Event  ]
;[===================]
if Example6
    {
    ;-- Establish Sink (event interface)
    pSink:=COM_ConnectObject(pSpVoice,"On")
    outputdebug pSink=%pSink%


    ;-- Speak
    Text=Example 6.  End-Stream Event
    COM_Invoke(pSpVoice,"Speak",Text,SVSFlagsAsync)
        ;-- Note: Because the Asynchronous flag is used, the call returns
        ;   immediately.

    return
    }

;-------------------------------------------------------------------------------
;
;   Example 6 comments:
;
;   This example uses the COM_ConnectObject function to establish an event
;   interface for SpVoice.  When an event occurs, the function is designed to
;   call a developer-created function (if it exists) with a name that contains a
;   designated prefix ("On" in this example) and the name of the event. For
;   example, if there is a "PeekABoo" event, the "OnPeekABoo" function would be
;   called when the "PeekABoo" event occured.
;
;   In this example, a "OnEndStream" function has been written to handle the
;   "EndStream" event which occurs when the voice has finished speaking.
;
;   For a list of SpVoice events and the parameters that are passed with each
;   event, check out the following:
;
;       http://msdn.microsoft.com/en-us/library/ms723587(VS.85).aspx
;
;
;   This is the most efficient of all of the examples but the extra code and
;   maintenance may not be worth it for short/simple scripts.
;
--------------------------------------------------------------------------------


;-- Return to sender
return



;**************
;*            *
;*    stop    *
;*            *
;**************
Stop:
outputdebug Subroutine: %A_ThisLabel%
COM_Invoke(pSpVoice,"Speak","",SVSFlagsAsync|SVSFPurgeBeforeSpeak)
    ;-- Send empty string with SVSFPurgeBeforeSpeak flag to stop playback.

return



;*************************
;*                       *
;*    Wait Until Done    *
;*                       *
;*************************
WaitUntilDone:
outputdebug Subroutine: %A_ThisLabel%

;-- Bounce if voice is active (speaking, paused, or interrupted)
if COM_Invoke(pSpVoice,"Status.RunningState")<>SRSEDone
    return


;-- Turn off timer
SetTimer WaitUntilDone,Off


;-- Finish it off
gosub Done
return




;**************
;*            *
;*    Done    *
;*            *
;**************
Done:
outputdebug Subroutine: %A_ThisLabel%


;-- Enable/Disable buttons
GUIControl Enable ,SpeakButton
GUIControl Disable,StopButton


;-- Set focus
GUIControl Focus,SpeakButton


;-- If necessary, release everything and reestablish.
;
;   Note: These drastic steps are necessary to remove the event interface and
;   callbacks that were established in Example 6.  Without these steps, some
;   of the examples may not work correctly after Example 6 was run.  In most
;   real-world conditions, it is not necessary to remove the event interface
;   once it has been established.
;
if pSink
    {
    ;-- Release pSink
    COM_Release(pSink)
    pSink:=0


    ;-- Release pSpVoice
    COM_Release(pSpVoice)


    ;-- Terminate COM
    COM_Term()


    ;-- Re-init COM
    COM_Init()


    ;-- Establish new pSpVoice instance
    pSpVoice:=COM_CreateObject("SAPI.SpVoice")
    outputdebug % "pSpVoice=" . pSpVoice
    }


;-- Return to sender
return


;******************
;*                *
;*    GUI Test    *
;*                *
;******************
GUITest:
outputdebug Subroutine: %A_ThisLabel%
gui +OwnDialogs
msgBox 64,GUI Test,
   (ltrim join`s
    Try to click the "GUI Test" button while one of the test voices is speaking.
    If you immediately see this message, it means that the GUI is still
    active while the voice is speaking.  If you see this message only after the
    voice has finished speaking, it means that a command has taken all of the
    attention of the script.
   )
return



;**************
;*            *
;*    Exit    *
;*            *
;**************
Exit:
outputdebug Subroutine: %A_ThisLabel%
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
OnEndStream(prms,this)
    {
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    outputdebug Function: %A_ThisFunc%
;;;;;    outputdebug % "COM_DispGetParam(prms,0) (StreamNumber)="
;;;;;        . COM_DispGetParam(prms,0)
;;;;;    outputdebug % "COM_DispGetParam(prms,1) (StreamPosition)="
;;;;;        . COM_DispGetParam(prms,1)
    outputdebug -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


    ;-- Wrap it up
    gosub Done
    return
    }
