/*
		BASS_Unicode Example
		  	by k3ph
			
      special thanks to: Lexikos!
      
  This example doesn't uses current trunk version, no library dependancy, requires only bass.dll
  
  For win9x support read: http://www.microsoft.com/downloads/details.aspx?familyid=73ba7bd7-ed06-4f0d-80a4-2a7eeaee17e2&displaylang=en


    < License >
      BASS Library is licensed under BSD.
      http://www.autohotkey.net/~k3ph/license.txt

      BASS is free for non-commercial use.
        If you are a non-commercial entity (eg. an individual) and you are not
      charging for your product, and the	product has no other commercial
      purpose, then you can use BASS in it for free.
        If you wish to use BASS in commercial products, read more details at:
          http://www.un4seen.com
    	
      Usage of BASS and BASS Library indicates that you agree to the above conditions.
    	All trademarks and other registered names contained in the BASS package are the
      property of their respective owners.
*/
#SingleInstance Force
#Persistent
SetBatchLines,-1
Thread, NoTimers
onexit, exit

#include bass.ahk

; Caller must ensure sufficient space at DestPtr.
CopyAnsiToUnicode(Source, DestPtr, Len)
{   ; Not sure how well this works on 9x/ME:
    return DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &Source, "int", Len + 1, "Uint", DestPtr, "int", Len + 1)
}

if !FileExist(BASS_DLLPATH . BASS_DLL)
	msgbox %BASS_DLL% wasn't found in: %BASS_DLLPATH%
BASS_Load()
BASS_Init()

Filter := "BASS Streamable built-in (*.mp3;*.mp2;*.mp1;*.ogg;*.oga;*.wav;*.aif;*.aiff;*.aifc;)|*.mp3;*.mp2;*.mp1;*.ogg;*.oga;*.wav;*.aif;*.aiff;*.aifc;|All files (*.*)|*.*"
; Convert pipe-delimited ANSI filter string to null-delimited Unicode string.
VarSetCapacity(wFilter, StrLen(Filter)*2+2)
ptr := &wFilter
Loop, Parse, Filter, |
    ptr += 2 * CopyAnsiToUnicode(A_LoopField, ptr, StrLen(A_LoopField))
NumPut(0, ptr+0, "short")
VarSetCapacity(wFile,(nMaxFile:=65535)*2)
; Initialize filename to empty unicode string.
NumPut(0, wFile, "short")
VarSetCapacity(ofn, 88, 0)
if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME
  NumPut(76, ofn)
else NumPut(88, ofn)
NumPut(&wFilter, ofn, 12)
NumPut(&wFile, ofn, 28)
NumPut(nMaxFile, ofn, 32)
NumPut((OFN_HIDEREADONLY:=0x4)|(OFN_EXPLORER:=0x80000), ofn, 52)
; Unicode support on 9x/ME (WIN32_WINDOWS) by Lexikos
DllCall((A_OSType="WIN32_WINDOWS" ? "unicows" : "comdlg32") . "\GetOpenFileNameW", "uint", &ofn)

/* SplitPath,file,,,ext,,drive
  NumGet(ofn, 56, "UShort") is the offset of the filename (excluding path)
*/

stream:=BASS_StreamCreateFile(false,&wFile,0,0,0x80000000) ; 0x80000000 BASS_Unicode
BASS_ChannelPlay(stream)
return

exit:
  BASS_Free()
	ExitApp