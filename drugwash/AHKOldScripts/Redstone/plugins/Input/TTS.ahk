; foom : http://www.autohotkey.com/forum/topic16552.html

TTS(sSpeechText, dwFlags=0)
{
    ;For info on the dwFlags bitmask see the SAPI helpfile:
    ;http://download.microsoft.com/download/speechSDK/SDK/5.1/WXP/EN-US/sapi.chm

    static TTSInitialized, ppSpVoice, pSpeak

    wSpeechTextBufLen:=VarSetCapacity(wSpeechText, StrLen(sSpeechText)*2+2,0)
    DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "Str", sSpeechText, "Int", -1, "UInt", &wSpeechText, "Int", wSpeechTextBufLen)

    if !TTSInitialized
    {
        ComInit := DllCall("ole32\CoInitialize", "Uint", 0)
        if ComInit not in 0,1
            return "CoInitialize() failed: " ComInit

        sCLSID_SpVoice:="{96749377-3391-11D2-9EE3-00C04F797396}"
        sIID_ISpeechVoice:="{269316D8-57BD-11D2-9EEE-00C04F797396}"
        ;Make space for unicode representations.
    	VarSetCapacity(wCLSID_SpVoice, StrLen(sCLSID_SpVoice)*2+2)
    	VarSetCapacity(wIID_ISpeechVoice, StrLen(sIID_ISpeechVoice)*2+2)
    	;Convert to unicode
    	DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "Str",sCLSID_SpVoice, "Int",-1, "UInt",&wCLSID_SpVoice, "Int",StrLen(sCLSID_SpVoice)*2+2)
    	DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "Str",sIID_ISpeechVoice, "Int",-1, "UInt",&wIID_ISpeechVoice, "Int",StrLen(sIID_ISpeechVoice)*2+2)
        
        ;Convert string representations to originals.
        VarSetCapacity(CLSID_SpVoice, 16)
        VarSetCapacity(IID_ISpeechVoice, 16)
        if ret:=DllCall("ole32\CLSIDFromString", "str", wCLSID_SpVoice, "str", CLSID_SpVoice)
        {
            DllCall("ole32\CoUninitialize")
            return "CLSIDFromString() failed: " ret
        }
        if ret:=DllCall("ole32\IIDFromString", "str", wIID_ISpeechVoice, "str", IID_ISpeechVoice)
        {
            DllCall("ole32\CoUninitialize")
            return "IIDFromString() failed: " ret
        }
    
        ;Obtain ISpeechVoice Interface.
        if ret:=DllCall("ole32\CoCreateInstance", "Uint", &CLSID_SpVoice, "Uint", 0, "Uint", 1, "Uint", &IID_ISpeechVoice, "UintP", ppSpVoice)
        {
            DllCall("ole32\CoUninitialize")
            return "CoCreateInstance() failed: " ret
        }
        ;Get pointer to interface.
        DllCall("ntdll\RtlMoveMemory", "UintP", pSpVoice, "Uint", ppSpVoice, "Uint", 4)
        ;Get pointer to Speak().
        DllCall("ntdll\RtlMoveMemory", "UintP", pSpeak, "Uint", pSpVoice + 4*28, "Uint", 4)      

        
        if ret:=DllCall(pSpeak, "Uint", ppSpVoice, "str" , wSpeechText, "Uint", dwFlags, "Uint", 0)
        {
            DllCall("ole32\CoUninitialize")
            return "ISpeechVoice::Speak() failed: " ret
        }

        DllCall("ole32\CoUninitialize")

        TTSInitialized = 1
        return
    }

    if ret:=DllCall(pSpeak, "Uint", ppSpVoice, "str" , wSpeechText, "Uint", dwFlags, "Uint", 0)
        return "ISpeechVoice::Speak() failed: " ret
}