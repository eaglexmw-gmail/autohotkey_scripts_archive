;  <filter>
;    <type>filter</type>
;    <name>RSS Feeds</name>
;    <list>RSS</list>
;    <headers>name&#44;feed</headers>
;    <sort>name</sort>
;    <icon>res/rss.ico</icon>
;    <listName>Filters</listName>
;  </filter>
;  <filter>
;    <type>filter</type>
;    <name>RSS Documents</name>
;    <list>Default</list>
;    <typeFilter>type=rss</typeFilter>
;    <maxResults>200</maxResults>
;    <headers>name&#44;*</headers>
;    <user>Yes</user>
;    <sort>name</sort>
;    <icon>res/rss.ico</icon>
;    <listName>Filters</listName>
;  </filter>

rss_Initialize() {

	CommandRegister("RSS ImportFeed", "rss_ImportFeed")
	CommandRegister("RSS ImportAllFeeds", "rss_ImportAllFeeds")

	CommandRegister("RSS Process", "rss_Process")
}

rss_ImportFeed(A_Command, A_Args) {

	COMMAND("RSS Process", A_Args)
}

rss_ImportAllFeeds(A_Command, A_Args) {

	list := syslist_Get("RSS")
	Loop, Parse, list, `n
	{
		COMMAND("RSS Process", A_LoopField)
	}
}

rss_Process(A_Command, A_Args) {

	feed := getValue(A_Args, "feed")
	name := getValue(A_Args, "name")

	xkcdLocFeed = xkcd.xml ; local path
	UrlDownloadToFile, %feed%, %A_ScriptDir%\%xkcdLocFeed%
	
	if ErrorLevel = 1
	{
		syslist_Add("Errors", "/type:error /error:Unable to retrieve " . feed)
		Return
	}

	FileRead, rss, %A_ScriptDir%\%xkcdLocFeed%
;	FileDelete, %A_ScriptDir%\%xkcdLocFeed%

	xpath_load(rss)

	entries := xpath(rss, iter, "/rss/channel/item/count()")
	
	Loop,%entries%
	{
		Sleep, 50
		x := "/rss/channel/item[" . A_Index . "]/title/text()"
		title := XPath(rss, iter, x )
		x := "/rss/channel/item[" . A_Index . "]/link/text()"
		link := XPath(rss, iter, x)

		StringReplace, title, title, `;, %A_Space%, All
		StringReplace, link, link, `;,%A_Space%, All

		entry :=  "/name:" . title . "/type:rss /listName:Default /command:" . link
		syslist_Add("Default", entry)
	}
}

