; Set up auto exporting of bookmarks in firefox3
; http://www.lytebyte.com/2008/06/19/how-to-auto-export-firefox-3-bookmarks-to-bookmarkshtml/

firefox_Initialize() {

	CommandRegister("Firefox Scan", "firefox_Scan")
}

firefox_Scan(A_Command, A_Args) {

	bmFile := getBookmarksFile()

	if (bmFile <> "") {
		FileRead, BookMarks, %bmFile%

		list := list_Create()
		Loop, Parse, BookMarks, `n, `r
		{
			RE = U)\QHREF="\E.*"
			RegExMatch(A_LoopField, RE, url)
			IfEqual, url,, Continue

			StringTrimLeft, url, url, 6
			StringTrimRight, url, url, 1

			RE = U)">.*\Q</A>\E
			RegExMatch(A_LoopField, RE, Tags)
			IfEqual, Tags,, Continue
			StringTrimLeft, Tags, Tags, 2
			StringTrimRight, Tags, Tags, 4

			Tags := Dec_XML(Tags)
			Tags := Enc_XML(Tags)

			if (RegExMatch(url, "^(((https?:|ftp:|gopher:)//))[-[:alnum:]?%,./&##!@:=+~_]+[A-Za-z0-9/]$") = 1) {
			
				COMMAND("Website DownloadIcon", "/url:" . url)

				url := Enc_XML(url)
				if (InStr(url, "%s")) {
					command := createNode("/type:webSearch /url:" . url)

					entry := createNode("/name:/" . Tags 
						. " /listName:Default"
						. " /description:" . Tags
						. " /type:slash")

					setNode(entry, "command", command)
					
				} else {
					entry := "/name:" . Tags 
						. " /listName:Default"
						. " /type:bookmark"
						. " /command:" . url
				}
				list_Add(list, entry)
			}
		}
		syslist_Merge("default", list)
	}
}

getBookmarksFile() {

	; http://kb.mozillazine.org/Profiles.ini_file

	mozillaData := A_AppData . "/Mozilla/Firefox"
	profilesIni := mozillaData . "/profiles.ini"

	profileNo := 0
	Loop {
		profile := "Profile" . profileNo
		IniRead, path, %profilesIni%, %profile%, Path
		if (path = "") OR (path = "ERROR") {
			break
		}
		IniRead, default, %profilesIni%, %profile%, Default

		nextProfile := "Profile" . A_Index
		IniRead, nextPath, %profilesIni%, %nextProfile%, Path
		if (default = 1) OR (nextPath = "ERROR") {
			IniRead, isRelative, %profilesIni%, %profile%, IsRelative
			
			if (isRelative = 1) {
				path := mozillaData . "/" . path
			}
			
			path := path . "/bookmarks.html"
			
			return path
		}
		
		profileNo++
		if (profileNo > 99) {
			; keep from looping forever
			break
		}
	}
	
	return ""
}

