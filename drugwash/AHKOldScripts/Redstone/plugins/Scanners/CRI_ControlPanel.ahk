controlPanel_Initialize() {

	CommandRegister("ControlPanel Scan", "controlPanel_Scan")
}

controlPanel_Scan(A_Command, A_Args) {

	; http://doc.ddart.net/msdn/header/include/cpl.h.html
	static CPL_INIT = 1
	static CPL_GETCOUNT = 2
	static CPL_INQUIRE = 3
	static CPL_EXIT = 7

	list := list_Create()
	
	Loop, %A_WinDir%\System32\*.cpl
	{
		hLib := DllCall("LoadLibrary", "str", A_LoopFileFullPath)

		if (hLib <> 0) {

			CplCall := DllCall("GetProcAddress", UInt, hLib, Str, "CPlApplet")

			if (CplCall) {
				init := DllCall(CplCall, "uint", 0, "uint", CPL_INIT, "uint", 0, "uint", 0)

      			if (init <> 0) {

					count := DllCall(CplCall, "uint", 0, "uint", CPL_GETCOUNT, "uint", 0, "uint", 0)
					Loop, %count%
					{
						VarSetCapacity(info, 48, 0)

						index := A_Index-1
						DllCall(CplCall, "uint", 0, "uint", CPL_INQUIRE, "uint", index, "uint", &info)

						;typedef struct tagCPLINFO
						;{
						;    int     idIcon;     /* icon resource id, provided by CPlApplet() */
						;    int     idName;     /* name string res. id, provided by CPlApplet() */
						;    int     idInfo;     /* info string res. id, provided by CPlApplet() */
						;    LONG    lData;      /* user defined data */
						;} CPLINFO, *LPCPLINFO;

						icon := NumGet(info, 0)
;						logA("icon:" . icon)
						icon := 0
						name := NumGet(info, 4)

						if (name <> 0) AND (name <> "") {
							VarSetCapacity(buf, 256)
							Result := DllCall("LoadString", "uint", hLib, "uint", name, "str", buf, "int", 128)
	
							if (buf <> "") {
								command := Enc_XML("rundll32.exe shell32.dll,Control_RunDLL """ . A_WinDir . "\System32\" . A_LoopFileName . """," . Enc_XML(buf))
								entry := "/name:" . Enc_XML(buf) . " /listName:Default /type:applet /command:" . command . " /icon:" . Enc_XML(A_LoopFileFullPath . "," . icon)
								list_Add(list, entry)
							}
						}
					}
				}
				DllCall(CplCall, "uint", 0, "uint", CPL_EXIT, "uint", 0, "uint", 0)
			}
			DllCall("FreeLibrary", "uint", hLib)
		}
	}
	syslist_Merge("default", list)
}
