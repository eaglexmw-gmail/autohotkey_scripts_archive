; MovieData.ahk by SKAN, 06-Sep-2011,      www.autohotkey.com/forum/viewtopic.php?t=76237

#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
Movie=%1%

IfNotExist, MovieData.ico, URLDownloadToFile
          , http://www.autohotkey.net/~Skan/Sample/MovieData/MovieData.ico, MovieData.ico
IfNotExist, MovieData.htm, URLDownloadToFile
          , http://www.autohotkey.net/~Skan/Sample/MovieData/MovieData.htm, MovieData.htm

Menu, Tray, UseErrorLevel
Menu, Tray, Icon, MovieData.ico

uPrompt := "Enter Movie Name:`n`neg: The+Gods+Must+Be+Crazy+1981"

UserInput:

IfEqual,Movie,,InputBox, Movie, IMDb, %uPrompt%,, 400, 160,,,,,%Defa%
If ( Movie="" || ErrorLevel<>0 )
  ExitApp, 1

URLDownloadToFile,http://www.imdbapi.com/?t=%movie%&r=JSON&plot=full, imdbapi.txt
FileRead, Response, *c imdbapi.txt
FileDelete, imdbapi.txt

If ( A_IsUnicode && ( ErrorLevel := "StrGet" ) )
 Response := %ErrorLevel%( &Response, "utf-8" )

StringReplace, Response, Response, % """,""" , % """|""",  All
StringReplace, Response, Response, % """:""" , % """`n""", All

Loop, Parse, Response, |`n,, """"{}
 A_Index & 1 ? ( errorLevel := A_LoopField ) : ( %errorLevel% := A_LoopField )

If ( Response <> "True" ) {
 uPrompt := "Enter Movie Name:`n`n'" Movie "' Not Found!" , Defa := Movie, Movie := ""
 GoTo, UserInput
}
 
IfExist,%ID%.hta, GoTo, RunHTA

FileRead, HTA, *c MovieData.htm
If ( A_IsUnicode && ( ErrorLevel := "StrGet" ) )
 HTA := %ErrorLevel%( &HTA, "" )

If ( Poster <> "N/A" )
 Poster := SubStr( Poster,1,InStr( Poster, "._V1" )-1 ) . "._V1._SX362_CR0,0,362,500_.jpg"

SysGet, SM_CXFRAME, 32
SysGet, SM_CYCAPTION, 4
SysGet, SM_CYEDGE, 46
SysGet, SM_CXVSCROLL, 2
Width  := 725 + SM_CXFRAME + SM_CYEDGE + SM_CYEDGE + SM_CXFRAME + SM_CXVSCROLL
Height := 500 + SM_CXFRAME + SM_CYEDGE + SM_CYCAPTION + SM_CYEDGE + SM_CXFRAME
StringReplace, HTA, HTA, 888, % Width , All
StringReplace, HTA, HTA, 666, % Height, All

Par := "ID|Poster|Title|Year|Rated|Released|Genre|Director|"
     . "Writer|Actors|Runtime|Rating|Votes|Plot"
Loop, Parse, Par, |
 StringReplace, HTA, HTA, _%A_LoopField%, % %A_LoopField%, All

FileAppend, %HTA%, %ID%.hta

RunHTA:

Run %ID%.hta
ExitApp, 0


; by SKAN http://www.autohotkey.com/forum/viewtopic.php?t=76237
movie := "Pirates+Caribbean+Stranger+Tides" 
URLDownloadToFile, http://www.imdbapi.com/?t=%movie%&r=JSON&plot=full, imdb.txt 
FileRead, Response, *c imdb.txt 
If ( A_IsUnicode && ( ErrorLevel := "StrGet" ) ) 
 Response := %ErrorLevel%( &Response, "utf-8" ) 
StringReplace, Response, Response, % """,""" , % """|""",  All 
StringReplace, Response, Response, % """:""" , % """`n""", All 
Loop, Parse, Response, |`n,, """"{} 
 A_Index & 1 ? ( errorLevel := A_LoopField ) : ( %errorLevel% := A_LoopField ) 

ListVars 
WinWaitClose, %A_ScriptFullpath% 
