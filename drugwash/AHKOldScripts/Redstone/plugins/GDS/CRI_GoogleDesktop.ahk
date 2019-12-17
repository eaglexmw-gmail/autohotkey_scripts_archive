; http://code.google.com/apis/desktop/docs/queryapi.html

googledesktop_Initialize() {

	RegRead, gdsURL, HKCU, Software\Google\Google Desktop\API, search_url

	if (gdsURL <> "") {
		CommandRegister("GoogleDesktop Search", "googledesktop_Search")
		CommandRegister("GoogleDesktop BackgroundSearch", "googledesktop_BackgroundSearch")
		STATE_SET("GDS URL", gdsURL)
	}
}

googledesktop_Search(A_Command, A_Args) {
  
	COMMAND("List Clear", "/listName:Google")
	COMMAND("Filter Apply", "/name:Google Desktop")

; TODO-1: get background commands working in plugins
;	BACKGROUND_COMMAND("GoogleDesktop BackgroundSearch", A_Args)
	COMMAND("GoogleDesktop BackgroundSearch", A_Args)
}

googledesktop_BackgroundSearch(A_Command, A_Args) {

	term := getValue(A_Args, "term") 
	url := STATE_GET("GDS URL")
	
	feed := url . term . "&format=xml&num=10"

	xkcdLocFeed = xkcd.xml ; local path
	UrlDownloadToFile, %feed%, %A_ScriptDir%\%xkcdLocFeed%

	if ErrorLevel = 1
	{
		syslist_Add("Errors", "/type:error /error:Unable to retrieve " . feed)
		Return
	}
	
	COMMAND("Status Display", "/status:Retrieving Results")

	FileRead, results, %A_ScriptDir%\%xkcdLocFeed%
	FileDelete, %A_ScriptDir%\%xkcdLocFeed%

	xpath_load(results)
	logA("list:" . xpath_save(results))

	if (results = "") {
		syslist_Add("Errors", "/type:error /error:Google Desktop Search produced no results")
		COMMAND("Command CheckErrors")
		Return
	}

	Loop
	{
		result := list_Iterate(results, iter)
		if (result = "") {
			break
		}
		title := getValue(result, "title")
		category := getValue(result, "category")
		time := getValue(result, "time")

		; TODO-2: need html transformer
		StringReplace,title,title,<b>,,All
		StringReplace,title,title,</b>,,All
;		StringReplace, title, title, `;, %A_Space%, All

		; TODO-2: test other return types
		if (category = "File") {
			link := getValue(result, "url")
			entry := createNode("/name:" . Enc_XML(title)
				. " /type:file /command:" . Enc_XML(link) 
				. " /category:File /date:" . time)
		} else { ; if (category = "Email") {
			link := getValue(result, "cache_url")
			link := Dec_Uri(link)
			i := InStr(link, "redir?url=")
			if (i <> -1) {
				link := SubStr(link, i+10)
			}
			from := getValue(result, "from")
			entry := createNode("/name:" . Enc_XML(title) 
				. " /type:website /command:" . Enc_XML(link) 
				. "/category:" . category 
				. " /from:" . Enc_XML(from) 
				. " /date:" . time)
		}

		syslist_Add("Google", entry)
	}
	COMMAND("Status Display")
}

