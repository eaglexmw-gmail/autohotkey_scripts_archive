; Wrapper for BASS Plugin
; www.autohotkey.com/forum/topic55454.html
; for AHK 1.0.48.05
; by toralf
; Version 0.1 (2010-02-20)
; based on BASS Library	by k3ph 

; NEEDS:  "DLLName".dll (see below)  www.un4seen    

; #########################
; ##  List of functions  ##
; #########################
; BASS_AAC_Load([DLLPath])  ;loads plugin to BASS; specify path to DLL if not in same directory 
; BASS_AAC_Free()           ;frees plugin
; BASS_AAC([Modus])         ;returns Status: ""=HandleToPlugin, "Filter"=file filter, "Ext"=list of extentions

BASS_AAC_Load(DLLPath=""){     ;loads plugin to BASS
  Return BASS_AAC("Load", DLLPath)
}
BASS_AAC_Free(){            ;frees plugin
	Return BASS_AAC("Free")
}
BASS_AAC(Modus="", DLLPath=""){  ;returns Status: ""=HandleToPlugin, "Filter"=file filter, "Ext"=list of extentions
	static
  DLLName = bass_aac.dll
  Filter := "AAC (*.aac;*.mp4;*.m4a;*.m4b;*.m4p)"
  Ext := RegExReplace(Filter, "(.*)\(|\)")
  If (Modus = "Load"){               ;load plugin
    If (!hPlugin := BASS_PluginLoad(DLLPath . DLLName))
      MsgBox, 48, BASS error!,
        (LTrim
          Failed to load plugin %DLLName%
          Error: %ErrorLevel%
          Please ensure %DLLName% is in the correct path %DLLPath%
        )
    Return hPlugin
  }Else If (Modus = "Free"){         ;free plugin
    If !BASS_PluginFree(hPlugin)
      MsgBox, 48, BASS error!, Failed to free plugin %DLLName%.`n%ErrorLevel%
  	Return hPlugin := 0
  }Else If InStr(Modus,"Filter"){    ;return string of Filefilter
  	Return Filter
  }Else If InStr(Modus,"Ext"){       ;return string of extentions
  	Return Ext
  }Else If !Modus {      ;return handle; is False/Nothing when not loaded
    Return hPlugin
  }
}

;additional tags available from BASS_StreamGetTags
; BASS_TAG_APE := 6	; APE tags
; BASS_TAG_MP4 := 7 ; MP4/iTunes metadata
; BASS_AAC_STEREO := 0x400000 ; downmatrix to stereo

;BASS_CHANNELINFO type
; BASS_CTYPE_STREAM_AAC := 0x10b00 ; AAC
; BASS_CTYPE_STREAM_MP4 := 0x10b01 ; MP4

