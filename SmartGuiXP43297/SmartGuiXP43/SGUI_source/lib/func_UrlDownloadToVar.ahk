; function originally by olfen www.autohotkey.com/forum/topic10466.html
; modified by Drugwash

;INTERNET_OPEN_TYPE_PRECONFIG						0	// use registry configuration
;INTERNET_OPEN_TYPE_DIRECT							1	// direct to net
;INTERNET_OPEN_TYPE_PROXY							3	// via named proxy
;INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY	4	// prevent using java/script/INS
;INTERNET_FLAG_RELOAD						0x80000000	// retrieve the original item

UrlDownloadToVar(ByRef res, URL, hPr="", Proxy="", ProxyBypass="")
{
at := A_AutoTrim
AutoTrim, Off
ln=16
len:="1111111111111111"
if !h := hModule := DllCall("GetModuleHandle", "Str","wininet.dll")
	if !hModule := DllCall("LoadLibrary", "Str", "wininet.dll")
		goto exit0
AccessType := (Proxy != "") ? 3 : 1
if !ioh := DllCall("wininet\InternetOpenA"
				, "Str"	, ""			; lpszAgent
				, "UInt"	, AccessType
				, "Str"	, Proxy
				, "Str"	, ProxyBypass
				, "UInt"	, 0)			; dwFlags
	goto exit1
if !iou := DllCall("wininet\InternetOpenUrlA"
				, "UInt"	, ioh
				, "Str"	, URL
				, "Str"	, ""			; lpszHeaders
				, "UInt"	, 0			; dwHeadersLength
				, "UInt"	, 0x80000000	; dwFlags: INTERNET_FLAG_RELOAD
				, "UInt"	, 0)			; dwContext
	goto exit2
iqda := DllCall("wininet\HttpQueryInfoA"
				, "UInt"	, iou			; hRequest
				, "UInt"	, 5			; dwInfoLevel: HTTP_QUERY_CONTENT_LENGTH
				, "Str"	, len			; lpvBuffer
				, "UIntP"	, ln			; lpdwBufferLength
				, "UInt"	, 0)			; lpdwIndex
if (!iqda OR !len)
	goto exit3
VarSetCapacity(res, len, 0)
VarSetCapacity(buffer, 512, 0)
idx=0
Loop
	{
	if (!idx && hPr)
		DllCall("SendMessage", "UInt", hPr,"UInt", 0x401, "UInt", 0, "UInt", 0x640000)	; PBM_SETRANGE 
	irf := DllCall("wininet\InternetReadFile"
				, "UInt", iou
				, "UInt", &buffer
				, "UInt", 512
				, "UIntP", bRead)
	if !bRead
		break
	DllCall("msvcrt\memcpy", "UInt", &res+idx, "UInt", &buffer, "UInt", bRead, "CDecl")
	idx += bRead
	if hPr
		DllCall("SendMessage", "UInt", hPr,"UInt", 0x402, "Int", 100*idx/len, "UInt", 0)	; PBM_SETPOS 
	}
VarSetCapacity(res, -1)
exit3:
DllCall("wininet\InternetCloseHandle",  "UInt", iou)
exit2:
DllCall("wininet\InternetCloseHandle",  "UInt", ioh)
exit1:
if !h
	DllCall("FreeLibrary", "UInt", hModule)
exit0:
AutoTrim, %at%
return len
}
