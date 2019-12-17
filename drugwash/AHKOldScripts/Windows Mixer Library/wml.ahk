/*
    Windows Mixer Library
			by k3ph
    
    version: pre-release

	< License >
	  http://www.autohotkey.net/~k3ph/license.txt
	  
	< Documentation >
  	http://msdn.microsoft.com/en-us/library/ms705739(VS.85).aspx
*/

; Windows Constants
CALLBACK_WINDOW := 0x10000
MIXER_OBJECTF_AUX := 0x50000000
MIXER_OBJECTF_HMIDIIN := 0xC0000000
MIXER_OBJECTF_HMIDIOUT := 0xB0000000
MIXER_OBJECTF_HMIXER := 0x80000000
MIXER_OBJECTF_HWAVEIN := 0xA0000000
MIXER_OBJECTF_HWAVEOUT := 0x90000000
MIXER_OBJECTF_MIDIIN := 0x40000000
MIXER_OBJECTF_MIDIOUT := 0x30000000
MIXER_OBJECTF_MIXER := 0x0
MIXER_OBJECTF_WAVEIN := 0x20000000
MIXER_OBJECTF_WAVEOUT := 0x10000000

MIXER_SETCONTROLDETAILSF_CUSTOM := 0x1
MIXER_SETCONTROLDETAILSF_VALUE := 0x0

MIXER_GETCONTROLDETAILSF_LISTTEXT := 0x1
MIXER_GETCONTROLDETAILSF_VALUE := 0x0

MIXER_GETLINECONTROLSF_ALL := 0x0
MIXER_GETLINECONTROLSF_ONEBYID := 0x1
MIXER_GETLINECONTROLSF_ONEBYTYPE := 0x2

MIXER_GETLINEINFOF_COMPONENTTYPE := 0x3
MIXER_GETLINEINFOF_DESTINATION := 0x0
MIXER_GETLINEINFOF_LINEID := 0x2
MIXER_GETLINEINFOF_SOURCE := 0x1
MIXER_GETLINEINFOF_TARGETTYPE := 0x4

; Return values
MMSYSERR_ALLOCATED := 0x4
MMSYSERR_BADDEVICEID := 0x2
MMSYSERR_INVALFLAG := 0xA
MMSYSERR_INVALHANDLE := 0x5
MMSYSERR_INVALPARAM := 0xB
MMSYSERR_NODRIVER := 0x6
MMSYSERR_NOMEM := 0x7

MIXERR_INVALCONTROL := 0x401
MMSYSERR_BADDEVICEID := 0x2
MMSYSERR_INVALFLAG := 0xA
MMSYSERR_INVALHANDLE := 0x5
MMSYSERR_INVALPARAM := 0xB
MMSYSERR_NODRIVER := 0x6

; The DllCalls
/*
http://msdn.microsoft.com/en-us/library/ms712134(VS.85).aspx

MMRESULT mixerOpen(
  LPHMIXER  phmx,        
  UINT      uMxId,       
  DWORD_PTR dwCallback,  
  DWORD_PTR dwInstance,  
  DWORD     fdwOpen      
);
*/
mixerOpen(phmx,uMxId,dwCallback,dwInstance,fdwOpen){
  Return DllCall("winmm.dll\mixerOpen", UInt, &phmx, UInt, &uMxId, UInt, dwCallback, UInt, dwInstance, UInt, fdwOpen)
}

/*
http://msdn.microsoft.com/en-us/library/ms712134(VS.85).aspx

MMRESULT mixerClose(
  HMIXER hmx  
);
*/
mixerOpen(hmx){
  Return DllCall("winmm.dll\mixerClose", UInt, hmx)
}

/*
http://msdn.microsoft.com/en-us/library/ms712137(VS.85).aspx

MMRESULT mixerSetControlDetails(
  HMIXEROBJ hmxobj,             
  LPMIXERCONTROLDETAILS pmxcd,  
  DWORD fdwDetails              
);
*/
mixerSetControlDetails(hmxobj,pmxcd,fdwDetails){
	Return DllCall("winmm.dll\mixerSetControlDetails", UInt, hmxobj, UInt, &pmxcd, UInt, fdwDetails)
}

/*
http://msdn.microsoft.com/en-us/library/ms712112(VS.85).aspx

MMRESULT mixerGetControlDetails(
  HMIXEROBJ hmxobj,             
  LPMIXERCONTROLDETAILS pmxcd,  
  DWORD fdwDetails              
);
*/
mixerGetControlDetails(hmxobj,pmxcd,fdwDetails){
	Return DllCall("winmm.dll\mixerGetControlDetails", UInt, hmxobj, UInt, &pmxcd, UInt, fdwDetails)
}

/*
http://msdn.microsoft.com/en-us/library/ms712117(VS.85).aspx

MMRESULT mixerGetID(
  HMIXEROBJ  hmxobj,  
  UINT FAR * puMxId,  
  DWORD      fdwId    
);
*/
mixerGetID(hmxobj,ByRef puMxId,fdwId){
  Return DllCall("winmm.dll\mixerGetID", UInt, hmxobj, UInt, &puMxId, UInt, fdwId)
}

/*
http://msdn.microsoft.com/en-us/library/ms712119(VS.85).aspx

MMRESULT mixerGetLineControls(
  HMIXEROBJ hmxobj,           
  LPMIXERLINECONTROLS pmxlc,  
  DWORD fdwControls           
);
*/
mixerGetLineControls(hmxobj,pmxlc,fdwControls){
  Return DllCall("winmm.dll\mixerGetLineControlsA", UInt, hmxobj, UInt, &pmxlc, UInt, fdwControls)
}

/*
http://msdn.microsoft.com/en-us/library/ms712120(VS.85).aspx

MMRESULT mixerGetLineInfo(
  HMIXEROBJ hmxobj,  
  LPMIXERLINE pmxl,  
  DWORD fdwInfo      
);
*/
mixerGetLineInfo(hmxobj,pmxl,fdwInfo){
  Return DllCall("winmm.dll\mixerGetLineInfoA", UInt, hmxobj, UInt, &pmxl, UInt, fdwInfo)
}

/*
http://msdn.microsoft.com/en-us/library/ms712115(VS.85).aspx

MMRESULT mixerGetDevCaps(
  UINT_PTR    uMxId,    
  LPMIXERCAPS pmxcaps,  
  UINT        cbmxcaps  
);
*/
mixerGetDevCaps(uMxId,ByRef pmxcaps,cbmxcaps){
  Return DllCall("winmm.dll\mixerGetDevCapsA", UInt, uMxId, UInt, &pmxcaps, UInt, cbmxcaps)
}

/*
http://msdn.microsoft.com/en-us/library/ms712104(VS.85).aspx

typedef struct { 
    DWORD cbStruct; 
    DWORD dwControlID; 
    DWORD cChannels; 
    union { 
        HWND  hwndOwner; 
        DWORD cMultipleItems; 
    }; 
    DWORD  cbDetails; 
    LPVOID paDetails; 
} MIXERCONTROLDETAILS; 

VarSetCapacity(MIXERCONTROLDETAILS, 24, 0)

; typedef struct {
    MIXERCONTROLDETAILS_cbStruct := NumGet(MIXERCONTROLDETAILS, 0, "UInt")
    MIXERCONTROLDETAILS_dwControlID := NumGet(MIXERCONTROLDETAILS, 4, "UInt")
    MIXERCONTROLDETAILS_cChannels := NumGet(MIXERCONTROLDETAILS, 8, "UInt")
    ; union {
        MIXERCONTROLDETAILS_hwndOwner := NumGet(MIXERCONTROLDETAILS, 12, "UInt")
        MIXERCONTROLDETAILS_cMultipleItems := NumGet(MIXERCONTROLDETAILS, 12, "UInt")
    ; }
    MIXERCONTROLDETAILS_cbDetails := NumGet(MIXERCONTROLDETAILS, 16, "UInt")
    MIXERCONTROLDETAILS_paDetails := NumGet(MIXERCONTROLDETAILS, 20, "UInt")
; }

; typedef struct {
    NumPut(MIXERCONTROLDETAILS_cbStruct, MIXERCONTROLDETAILS, 0, "UInt")
    NumPut(MIXERCONTROLDETAILS_dwControlID, MIXERCONTROLDETAILS, 4, "UInt")
    NumPut(MIXERCONTROLDETAILS_cChannels, MIXERCONTROLDETAILS, 8, "UInt")
    ; union {
        NumPut(MIXERCONTROLDETAILS_hwndOwner, MIXERCONTROLDETAILS, 12, "UInt")
        NumPut(MIXERCONTROLDETAILS_cMultipleItems, MIXERCONTROLDETAILS, 12, "UInt")
    ; }
    NumPut(MIXERCONTROLDETAILS_cbDetails, MIXERCONTROLDETAILS, 16, "UInt")
    NumPut(MIXERCONTROLDETAILS_paDetails, MIXERCONTROLDETAILS, 20, "UInt")
; }
*/