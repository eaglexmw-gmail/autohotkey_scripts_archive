; http://www.autohotkey.com/forum/viewtopic.php?p=190481#190481

;#NoTrayIcon
#SingleInstance FORCE
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent
CoordMode Pixel, Screen  ; Interprets the coordinates below as relative to the screen rather than the active window.


;defaults
WDT := 320 ;width
HGT := 240 ;height
FPS := 15 ;frame per second
fileJPG = vidcap.jpg ;capture file name on the desktop - jpg
fileBMP = vidcap.bmp ;capture file name on the desktop - bmp
SENS := 80 ;motion detect sensitivity% (0%-100%)
MotionCheckTime := 500 ;msec - time period to check for motion
IniFile = %A_ScriptDir%\WebCam.ini
hModule := DllCall("LoadLibrary", "str", "avicap32.dll")

Gui, +lastfound
mainHwnd := WinExist()
Gui, Add, GroupBox, x4 y4 w492 h100 , Available Video Drivers
Gui, Add, ListView, x8 y20 w400 h80 gSelectDriver vCapDriversLV AltSubmit, Index|Name
Gui, Add, Picture, x434 y16 w32 h32 Icon204, %A_WinDir%\system32\shell32.dll
Gui, Add, Button, x412 y50 w80 h24 gRefreshDrivers, Refresh
Gui, Add, Button, x412 y76 w80 h24 gSelectDriver vSelectDriverB, Select
Gui, Add, GroupBox, x6 y110 w100 h160 , Preview
Gui, Add, CheckBox, x16 y130 w80 h30 vPreviewToggleState gPreviewToggle, Preview on/off
Gui, Add, Text, x16 y170 w50 h20 , width:
Gui, Add, Edit, x66 y170 w30 h20 vWDT gdoWDT, %WDT%
Gui, Add, Text, x16 y190 w50 h20 , height:
Gui, Add, Edit, x66 y190 w30 h20 vHGT gdoGHT, %HGT%
Gui, Add, Text, x16 y210 w50 h20 , fps:
Gui, Add, Edit, x66 y210 w30 h20 vFPS gdoFPS, %FPS%
Gui, Add, Button, x16 y240 w80 h20 gPreviewToggle, Change
Gui, Add, Button, x286 y130 w200 h20 gCopyToClipBoard, Snapshot to Clipboard
Gui, Add, Text, x286 y150 w60 h20 , Desktop\
Gui, Add, Edit, x336 y150 w70 h20 vfileJPG gdoJPG, %fileJPG%
Gui, Add, Button, x406 y150 w80 h20 gSenToFile2, Send to &JPG
Gui, Add, Text, x286 y170 w60 h20 , Desktop\
Gui, Add, Edit, x336 y170 w70 h20 vfileBMP gdoBMP, %fileBMP%
Gui, Add, Button, x406 y170 w80 h20 gSenToFile, Send to &BMP
Gui, Add, Text, x146 y130 w60 h20 , Sensitivity `%
Gui, Add, Edit, x206 y130 w30 h20 vSENS gdoSENS, %SENS%
Gui, Add, Text, x146 y160 w50 h30 , Motion check:
Gui, Add, Edit, x206 y160 w30 h20 vMotionCheckTime gdoMOT, %MotionCheckTime%
Gui, Add, Text, x206 y180 w30 h20 , msec
Gui, Add, Button, x146 y200 w90 h30 Disabled gMotionToggle, Motion  ON
Gui, Add, Button, x286 y290 w200 h30 gSenToAvi, Capture to &AVI
Gui, Add, Button, x376 y230 w110 h20 gSetupVideoFormat, Video Format
Gui, Add, Button, x376 y250 w110 h20 gSetupVideoCompression, Video Compression
Gui, Add, Button, x286 y230 w90 h20 gSetupVideoSource, Video Source
Gui, Add, Button, x286 y250 w90 h20 gSetupVideoDisplay, Video Display
Gui, Add, CheckBox, x286 y270 w200 h20 vSetupDefaultToggleState gSetupDefaultToggle, Save current video setup as Default
Gui, Font, cGray s14 bold, Arial
Gui, Add, Text, x146 y240 w90 h30 ,
Gui, Font
Gui, Add, GroupBox, x136 y110 w110 h170 , Motion Detection
Gui, Add, GroupBox, x276 y110 w220 h90 , Snapshot
Gui, Add, GroupBox, x276 y210 w220 h120 , Video Capture
; Generated using SmartGUI Creator 4.0
Gui, Show, x100 y125 h402 w502, Video For Windows for AutoHotkey - VFW4AHK

GoSub, RefreshDrivers
Return



doMOT:
   ControlGetText,MotionCheckTime,Edit7,A
Return

doSENS:
   ControlGetText,SENS,Edit6,A
Return

doWDT:
   ControlGetText,WDT,Edit1,A
Return

doGHT:
   ControlGetText,HGT,Edit2,A
Return

doJPG:
   ControlGetText,fileJPG,Edit4,A
Return

doBMP:
   ControlGetText,fileBMP,Edit5,A
Return

doFPS:
   ControlGetText,FPS,Edit3,A
Return

PreviewToggle:
  ControlGet,PreviewToggleState,Checked,,Button5,A
  If PreviewToggleState
  {
   Control,Enable,,Button10,A
   Gui, 2:Destroy
   Gui, 2:Add, Text, x0 y0 w%WDT% h%HGT% vVidPlaceholder
   GuiControl, +0x7, VidPlaceholder ; frame
   Gui 2:+LastFound
   previewHwnd := WinExist()
   Gui, 2:Show, x650 w%WDT% h%HGT%, Viewer
    GoSub ConnectToDriver
   GoSub SetSequenceSetup
   ;MsgBox, previewHwnd = %previewHwnd%  lwndC = %lwndC%
  }
  Else
  {
   Control,Disable,,Button10,A
   Gui, 2:Destroy
    GoSub DisconnectDriver
  }
Return

SetupDefaultToggle:
  ControlGet,SetupDefaultToggleState,Checked,,Button16,A
  If SetupDefaultToggleState
  {
    GoSub GetSequenceSetup
   MsgBox, DOES NOT WORK. Video setup is saved as Default
  }
  Else
  {
    Rect1 =
   MsgBox, Default video setup is deleted
  }
IniWrite, %Rect1%, %IniFile%, Settings, VideoSetup
Return

MotionToggle:
  If MotionToggleState
  {
   MotionToggleState =
   ControlSetText,Button10,Motion ON,ahk_id %mainHwnd%
   ControlSetText,Static10,,ahk_id %mainHwnd%
   Sleep % 2*MotionCheckTime
   ControlSetText,Static10,,ahk_id %mainHwnd%
  }
  Else
  {
   MotionToggleState = 1
   ControlSetText,Button10,Motion OFF,ahk_id %mainHwnd%
   GoSub, CompareImages
  }
Return

CompareImages:
   SetTimer, CompareImages, Off
    imagefile = %A_Desktop%\comp.BMP
    SendMessage, WM_CAP_FILE_SAVEDIB, 0, &imagefile, , ahk_id %capHwnd%
   Sensitivity := (100-SENS)/100*255
   ErrorLevel =
   ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%Sensitivity% *w%WDT% *h%HGT% %imagefile%
   IfEqual, ErrorLevel, 2
      ControlSetText,Static10,ERROR,ahk_id %mainHwnd%
   else IfEqual, ErrorLevel, 1
      ControlSetText,Static10,MOTION!!!,ahk_id %mainHwnd%
   else
      ControlSetText,Static10,STILL,ahk_id %mainHwnd%
   If MotionToggleState
      SetTimer, CompareImages, % MotionCheckTime
Return


ConnectToDriver:
  ; --- Connect and preview - hwnd, x, y, w, h
  capHwnd := Cap_CreateCaptureWindow(previewHwnd, 0, 0, WDT, HGT)

  WM_USER := 0x0400
  WM_CAP_START := WM_USER
  WM_CAP_GRAB_FRAME_NOSTOP := WM_USER + 61
  WM_CAP_FILE_SAVEDIB := WM_CAP_START + 25

  WM_CAP := 0x400
  WM_CAP_DRIVER_CONNECT := WM_CAP + 10
  WM_CAP_DRIVER_DISCONNECT := WM_CAP + 11
  WM_CAP_EDIT_COPY := WM_CAP + 30
  WM_CAP_SET_PREVIEW := WM_CAP + 50
  WM_CAP_SET_PREVIEWRATE := WM_CAP + 52
  WM_CAP_SET_SCALE := WM_CAP + 53

  WM_CAP_SEQUENCE := WM_CAP_START + 62
  WM_CAP_FILE_SET_CAPTURE_FILE := WM_CAP_START + 20

   WM_CAP_DLG_VIDEOFORMAT := WM_CAP_START + 41
   WM_CAP_DLG_VIDEOSOURCE := WM_CAP_START + 42
   WM_CAP_DLG_VIDEODISPLAY := WM_CAP_START + 43
   WM_CAP_DLG_VIDEOCOMPRESSION := WM_CAP_START + 46

   WM_CAP_SET_SEQUENCE_SETUP := WM_CAP_START + 64
   WM_CAP_GET_SEQUENCE_SETUP := WM_CAP_START + 65

   WM_CAP_SET_AUDIOFORMAT := WM_CAP_START + 35
   WM_CAP_GET_AUDIOFORMAT := WM_CAP_START + 36
   WM_CAP_GET_VIDEOFORMAT := WM_CAP_START + 44
   WM_CAP_SET_VIDEOFORMAT := WM_CAP_START + 45
   WM_CAP_SET_OVERLAY := WM_CAP_START + 51

;DRV_USER := &H4000
DRV_USER := 0x4000
ICM_RESERVED := DRV_USER + 0x1000
ICM_CONFIGURE := (ICM_RESERVED + 10)
ICM_GETSTATE := (ICM_RESERVED + 0)
ICM_SETSTATE := (ICM_RESERVED + 1)

  ; Connect to driver
  if SelectedDriver =
  {
   if foundDriver
      SelectedDriver = 0
   else
   {
       MsgBox, 16, Error!, You didn't select a video driver`, and there seems to be no driver present.
       Return
   }
  }
  SendMessage, WM_CAP_DRIVER_CONNECT, %SelectedDriver%, 0, , ahk_id %capHwnd%

  ; Set the preview scale
  SendMessage, WM_CAP_SET_SCALE, 1, 0, , ahk_id %capHwnd%

  ; Set the preview rate in milliseconds
  MSC := round((1/FPS)*1000)
  SendMessage, WM_CAP_SET_PREVIEWRATE, MSC, 0, , ahk_id %capHwnd%

  ; Start previewing the image from the camera
  SendMessage, WM_CAP_SET_PREVIEW, 1, 0, , ahk_id %capHwnd%
  SendMessage, WM_CAP_SET_OVERLAY, 1, 0, , ahk_id %capHwnd%

Return


CopyToClipBoard:
  SendMessage, WM_CAP_EDIT_COPY, 0, 0, , ahk_id %capHwnd%
Return


SenToFile2:
   SendMessage, WM_CAP_EDIT_COPY, 0, 0, , ahk_id %capHwnd%
    RunWait, C:\Program Files\IrfanView\i_view32.exe /clippaste /convert=%A_Desktop%\%fileJPG%   ;copies from clipboard to file
Return


SenToFile:
    imagefile = %A_Desktop%\%fileBMP%
    SendMessage, WM_CAP_FILE_SAVEDIB, 0, &imagefile, , ahk_id %capHwnd%
return


SenToAvi:
    avifile = %A_Desktop%\CAPT.avi
    SendMessage, WM_CAP_FILE_SET_CAPTURE_FILE, 0, &avifile, , ahk_id %capHwnd%
   ToolTip, Press Esc or Click to Stop Avi Capture
    SendMessage, WM_CAP_SEQUENCE, 0, 0, , ahk_id %capHwnd%
   ToolTip
return

GetSequenceSetup:
   SendMessage,ICM_GETSTATE,0,0,,ahk_id %capHwnd%
   SSize := ErrorLevel
   ;MsgBox, SSize = %SSize%
   VarSetCapacity(Rect, SSize, 0)  ; A RECT is a struct with 24*4
   SendMessage,ICM_GETSTATE,&Rect,SSize,,ahk_id %capHwnd%


   ;SSize := 96
   ;VarSetCapacity(Rect, SSize, 0)  ; A RECT is a struct with 24*4
   ;SendMessage,WM_CAP_GET_SEQUENCE_SETUP,SSize,&Rect,,ahk_id %capHwnd%
   ;does not work  Res:=DllCall("avicap32.dll\capCaptureGetSetupA"
            ; , "UInt", previewHwnd
            ; , "UInt", &Rect
            ; , "Int", 96)  ; WinExist() returns an HWND.
   ;VarSetCapacity(Rect,-1)  ; Reset the length
   MyStructData =
   Loop, % round(SSize/4)
   {
      Offset := 4*(A_Index-1)
      Rect%A_Index% := NumGet(Rect,Offset)
      MyStructData := MyStructData . A_Tab . Rect%A_Index%
   }
   ;MsgBox, MyStructData = %MyStructData%
   Rect1 := SubStr(MyStructData,2)
Return

SetSequenceSetup:
   VarSetCapacity(Rect, 96)  ; A RECT is a struct consisting of four 32-bit integers (i.e. 4*4=16).
   IfNotExist, %IniFile%
      Return
   IniRead, Rect1, %IniFile%, Settings, VideoSetup
   If not Rect1
      Return
   Loop, Parse, Rect1, %A_Tab%
   {
      Offset := 4*(A_Index-1)
      NumPut(%A_LoopField%,Rect,Offset)
   }
   SendMessage,WM_CAP_SET_SEQUENCE_SETUP,96,&Rect,,ahk_id %capHwnd%
   ; DllCall("avicap32.dll\capCaptureSetSetupA"
            ; , "UInt", previewHwnd
            ; , "UInt", &Rect
            ; , "Int", 96)  ; WinExist() returns an HWND.
   MsgBox, DOES NOT WORK. Default video setup is loaded.
Return

SetupVideoSource:
    SendMessage, WM_CAP_DLG_VIDEOSOURCE, 0, 0, , ahk_id %capHwnd%
Return


SetupVideoDisplay:
    SendMessage, WM_CAP_DLG_VIDEODISPLAY, 0, 0, , ahk_id %capHwnd%
Return


SetupVideoFormat:
    SendMessage, WM_CAP_DLG_VIDEOFORMAT, 0, 0, , ahk_id %capHwnd%
Return


SetupVideoCompression:
    SendMessage, WM_CAP_DLG_VIDEOCOMPRESSION, 0, 0, , ahk_id %capHwnd%
Return


DisconnectDriver:
  SendMessage, WM_CAP_DRIVER_DISCONNECT, 1, 0, , ahk_id %capHwnd%
Return


RefreshDrivers:
  foundDriver = 0
  LV_Delete()
  Loop
  {
    thisInfo := Cap_GetDriverDescription(A_Index-1)
    If thisInfo
    {
      foundDriver = 1
      LV_Add("", A_Index-1, thisInfo)
    }
    Else
      Break
  }
  If !foundDriver
  {
    LV_Delete()
    LV_Add("", "", "Could not get video drivers")
    GuiControl, Disable, CapDriversLV
    GuiControl, Disable, SelectDriverB
  }
Return


SelectDriver:
  FocusedRowNumber := LV_GetNext(0, "F")  ; Find the focused row.
  if not FocusedRowNumber  ; No row is focused.
    return
  LV_GetText(SelectedDriver, FocusedRowNumber, 1)
Return


Cap_CreateCaptureWindow(previewHwnd, x, y, w, h)
{
Global lwndC

  WS_CHILD := 0x40000000
  WS_VISIBLE := 0x10000000

  lpszWindowName := "test"

  lwndC := DLLCall("avicap32.dll\capCreateCaptureWindowA"
                  , "Str", lpszWindowName
                  , "UInt", WS_VISIBLE | WS_CHILD ; dwStyle
                  , "Int", x
                  , "Int", y
                  , "Int", w
                  , "Int", h
                  , "UInt", previewHwnd
                  , "Int", 0)

  Return lwndC
}


Cap_GetDriverDescription(wDriver)
{
  VarSetCapacity(lpszName, 100)
  VarSetCapacity(lpszVer, 100)
  res := DLLCall("avicap32.dll\capGetDriverDescriptionA"
                  , "Short", wDriver
                  , "Str", lpszName
                  , "Int", 100
                  , "Str", lpszVer
                  , "Int", 100)
  If res
    capInfo := lpszName ; " | " lpszVer
  Return capInfo
}


GuiClose:
  GoSub, DisconnectDriver
  DllCall("FreeLibrary", "str", hModule)
  ExitApp
Return



/*
WM_CAP_SET_SEQUENCE_SETUP

The WM_CAP_SET_SEQUENCE_SETUP message sets the configuration parameters used with streaming capture. You can send this message explicitly or by using the capCaptureSetSetup macro.

WM_CAP_SET_SEQUENCE_SETUP
wParam = (WPARAM) (wSize);
lParam = (LPARAM) (LPVOID) (LPCAPTUREPARMS) (psCapParms);

Parameters

wSize

Size, in bytes, of the structure referenced by s.

psCapParms

Pointer to a CAPTUREPARMS structure.

Return Values

Returns TRUE if successful or FALSE otherwise.



CAPTUREPARMS structure:

typedef struct {
    DWORD dwRequestMicroSecPerFrame;
    BOOL  fMakeUserHitOKToCapture;
    UINT  wPercentDropForError;
    BOOL  fYield;
    DWORD dwIndexSize;
    UINT  wChunkGranularity;
    BOOL  fUsingDOSMemory;
    UINT  wNumVideoRequested;
    BOOL  fCaptureAudio;
    UINT  wNumAudioRequested;
    UINT  vKeyAbort;
    BOOL  fAbortLeftMouse;
    BOOL  fAbortRightMouse;
    BOOL  fLimitEnabled;
    UINT  wTimeLimit;
    BOOL  fMCIControl;
    BOOL  fStepMCIDevice;
    DWORD dwMCIStartTime;
    DWORD dwMCIStopTime;
    BOOL  fStepCaptureAt2x;
    UINT  wStepCaptureAverageFrames;
    DWORD dwAudioBufferSize;
    BOOL  fDisableWriteCache;
    UINT  AVStreamMaster;
} CAPTUREPARMS;

 */

;#Include ws4ahk.ahk
