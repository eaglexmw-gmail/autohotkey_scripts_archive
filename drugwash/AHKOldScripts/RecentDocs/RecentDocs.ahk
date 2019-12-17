#Persistent
CoordMode Mouse, Screen
CoordMode Menu,  Screen
If A_OSType in WIN32	; enables this script in Win95/98/ME
	Recent = %A_WinDir%\Recent
else
	Recent = %HOME%\Recent              ; = %USERPROFILE%\Recent

XX := 0 "," 190 "," A_ScreenWidth -185 "," A_ScreenWidth -2 "," 9999
StringSplit XX, XX, `,              ; Region boundaries
YY := 0 "," 190 "," A_ScreenHeight-185 "," A_ScreenHeight-2 "," 9999
StringSplit YY, YY, `,

Loop 5                              ; MenuXY <- desired menu.
   Menu1%A_Index% = LeftMenu        ; 11 21 31 41 51    Left  1Y
Loop 5                              ; 12 22 32 42 52    Right 5Y
   Menu%A_Index%1 = TopMenu         ; :    ....    :    Top   X1
                                    ; 15 25 35 45 55    Botm  X5
Menu TopMenu, Add, WinWord, RUN
Menu TopMenu, Add, NotePad, RUN
Menu TopMenu, Add, CMD,     RUN
Menu TopMenu, Add, Calc,    RUN
Menu TopMenu, Add, www.autohotkey.com, RUN
; ... further menu items
                                    ; EDIT BELOW: ,FileType>Application Path
Types= AHK>C:\Program Files\Multi-Edit 9.10\Mew32.exe
      ,DOC>C:\Program Files\Microsoft Office\OFFICE11\WinWord.exe
      ,MHT>C:\Program Files\Internet Explorer\IEXPLORE.EXE
      ,PDF>C:\Program Files\Adobe\Acrobat 6.0\Acrobat\Acrobat.exe
      ,PPT>C:\Program Files\Microsoft Office\OFFICE11\POWERPNT.EXE
      ,RTF>C:\Program Files\Microsoft Office\OFFICE11\WinWord.exe
      ,TXT>C:\WINDOWS\NOTEPAD.EXE
      ,XLS>C:\Program Files\Microsoft Office\OFFICE11\EXCEL.EXE

Menu LeftMenu,Add,[recent],LeftAgain ; Item1 = title
Menu LeftMenu,Add                    ; Separator
Loop Parse, Types, `,
{
   StringSplit t, A_LoopField, >
   Menu LeftMenu, Add, %t1%, ShowRecent
   App%t1% = %t2%                   ; Setup AppXXX vars for fast call
}
Menu LeftMenu,Add                   ; Separator
Menu LeftMenu,Add,ShowAll>, ShowAll ; After extensions, other menu items
Menu LeftMenu,Add,DelLink>, DelLink
Menu LeftMenu,Add,CleanUp>, CleanUp
; ... further menu items

Menu DocMenu, Add                   ; Dummy entry for 1st DeleteAll
Pcount = 1

SetTimer Edge, 250
Return

Edge:
   MouseGetPos X, Y
   P0 = %Pos%                       ; Previous mouse position
   Loop 5
      If (X <= XX%A_Index%) {
         Pos = %A_Index%            ; X region
         Break
      }
   Loop 5
      If (Y <= YY%A_Index%) {
         Pos = %Pos%%A_Index%       ; Position = XregionYregion
         Break
      }
   Pcount := Pcount*(P0=Pos) + 1    ; How long in this region
   If (Pcount <> 4 or Menu%Pos% = "")
      Return
   Menu % Menu%Pos%, Show
Return

RUN:
   Run %A_ThisMenuItem%
Return

LeftAgain:                          ; No real selection: re-show menu
   Menu leftMenu, Show, %X%, %Y%
Return

DelLink:
   Action = DeleteLink
   Goto Show
ShowAll:
   Action = RunLink
Show:
   Menu DocMenu, DeleteAll
   Loop %Recent%\*.lnk
   {
      StringTrimRight file,A_LoopFileName,4  ; remove .lnk
      Menu DocMenu, Add, %file%, %Action%
   }
   Menu DocMenu, Show, 0            ; Show still on the left
Return

RunLink:                            ; Run default application with document
   FileGetShortcut %Recent%\%A_ThisMenuItem%.lnk, file
   Run "%file%"
Return

DeleteLink:                         ; Delete selected link
   FileGetShortcut %Recent%\%A_ThisMenuItem%.lnk, file
   MsgBox 4,,Delete Shortcut to`n%file%
   IfMsgBox Yes
      FileDelete %Recent%\%A_ThisMenuItem%.lnk
GoTo LeftAgain                       ; Re-show Left menu

ShowRecent:
   Menu DocMenu, DeleteAll
   type = %A_ThisMenuItem%          ; Used in Open:
   Loop %Recent%\*.%type%.lnk
   {
      StringTrimRight file,A_LoopFileName,4  ; remove .lnk
      Menu DocMenu, Add, %file%, Open
   }
   Menu DocMenu, Show, 0            ; Show still on the left
Return

Open:                               ; Open linked file
   FileGetShortcut %Recent%\%A_ThisMenuItem%.lnk, file
   Run % App%type% " """ file """"
Return

CleanUp:                            ; Remove broken links
   Loop %Recent%\*.lnk
   {
      FileGetShortcut %A_LoopFileFullPath%, file
      If !FileExist(file) {
         ToolTip Deleting %A_LoopFileFullPath%
         FileDelete %A_LoopFileFullPath%
         Sleep 100
      }
      ToolTip                       ; Remove last tooltip
   }
Return
