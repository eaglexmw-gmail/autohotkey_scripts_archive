website_Initialize() {

	searchURL := STATE_GET("Search URL")

	if (searchURL = "") {
		STATE_SET("Search URL", "http://www.google.com/search?q=%s")
	}

	CommandRegister("Website Run", "website_Run")
	CommandRegister("Website Search", "website_Search")
	CommandRegister("Website DownloadIcon", "website_DownloadIcon")
	
	; Doesn't microsoft have to make everything difficult ?
;	RegRead, defaultScope, HKCU, Software\Microsoft\Internet Explorer\SearchScopes, DefaultScope
;log("defaultScope:" . defaultScope)
;	RegRead, searchURL, HKCU, Software\Microsoft\Internet Explorer\SearchScopes\%defaultScope%, URL
	
;log("url:" . searchURL)
	;http://www.google.com/search?q=
;HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\SearchUrl
}

;InternetCheckConnection(Url="",FIFC=1) {
;Return DllCall("Wininet.dll\InternetCheckConnectionA", Str,Url, Int,FIFC, Int,0)
;} 

website_DownloadIcon(A_Command, A_Args) {
	url := getValue(A_Args, "url")

	if (RegExMatch(url, "^(((https?:|ftp:|gopher:)//))[-[:alnum:]?%,./&##!@:=+~_]+[A-Za-z0-9/]$") = 1) {
		domain := getDomain(url)
	
		iconFile := A_ScriptDir . "/favicons/" . domain . ".ico"
		IfNotExist, %iconFile%
		{
			defaultIcon := A_ScriptDir . "\res\shell32.dll_14.ico"

			iconUrl := "http://" . domain . "/favicon.ico"
			URLDownloadToFile,%iconUrl%,%iconFile%
			if ErrorLevel = 1
				FileCopy, %defaultIcon%, %iconFile%,1
			else {
				static LR_LOADFROMFILE = 16
				hIcon := DllCall("LoadImage", "UInt", NULL
					, "Str", iconFile
					, "UInt", 1
					, "Int", 32
					, "Int", 32
					, "UInt", LR_LOADFROMFILE
					, "UInt")
				if (hIcon = 0) {
					FileCopy, %defaultIcon%, %iconFile%, 1
				}
			}
		}
	}
}

website_Search(A_Command, A_Args) {
	
	searchURL := getValue(A_Args, "url")
	if (searchURL = "") {
		searchURL := STATE_GET("Search URL")
	}	

	searchTerm := getValue(A_Args, "term")
	StringReplace, url, searchURL, `%s , %searchTerm%, All 

	COMMAND("UI Hide")
	Run, %url%,, UseErrorLevel
;	COMMAND("Command HistoryAdd", A_Args)
}

website_Run(A_Command, A_Args) {

	url := getValue(A_Args, "command")

	COMMAND("UI Hide")
	Run, %url%,, UseErrorLevel
	COMMAND("Command HistoryAdd", A_Args)
	COMMAND("Website DownloadIcon", "/url:" . url)
}
