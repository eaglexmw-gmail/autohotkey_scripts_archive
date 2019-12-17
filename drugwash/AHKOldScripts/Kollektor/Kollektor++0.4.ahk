
/*
; ---------------------------------------------------------------------
; Name:        Kollektor++
; Last update: 27/05/2007
; Version:     0.4
; -------------------------------
; Based on script:
; Name:            Kollektor 03
; Author:      Boskoop           
; Datum:       23.3.06
; see http://www.autohotkey.com/forum/viewtopic.php?t=2534
; Language:    German/English
; Platform:    tested with XP, 2000
; AHK-Version: 1.0.40
; -------------------------------
; Beschreibung:
; ---------------------------------------------------------------------

With Kollektor++ you can search in multiple taglists, or collections.

After you start the script you can activate the program by pressing the hotkey (CAPSLOCK by default).

Based on the active program title, a specific taglist can be loaded into memory and searched. By pressing ENTER, clicking OK or a double click on an item in the list the text is pasted in the active program.

You can also use the up and down keys to navigate trough the list or manually select a different taglist. If you choose a taglist from the dropdownlist, that file will remain active until you click the 'Reset' button.

To add to contents of the clipboard to a taglist, click on the ADD button.

German comments in the script came from the original script Kollektor_03.ahk (see link above). Most new/changed lines are marked with ; k++

Zeilenumbrüche werden durch das Zeichen ¤ ersetzt. ¤ ist gleichzeitig Trennzeichen
für Tabellenspalten. Mit dem ViewMode 1-2-3-4... werden die Zeilenumbrüche wieder restauriert.

; ---------------------------------------------------------------------

VARIABLEN

Hitlist: Suchen in der Datenbank: Liste der Zeilen mit Treffern. Wird von der Funktion SearchDB() erzeugt
Hitlist_N: Array. An der N-ten Position der Trefferliste steht die Zeile X. Z. B. Hitlist=1|4|8 Hitlist_3=8. Wird von der Subroutine Eingabe: erzeugt

Word: Inhalt der 1. Zelle einer Trefferzeile. Von Subroutine Eingabe: erzeugt
Wordlist: Liste von Wörtern der 1. Zelle aller Trefferzeilen .Z. B. rot|grün|blau. Von Subroutine Eingabe: erzeugt

Choice: Position des augewählten Items in der Listbox bzw. in der Hitlist. Von der Listbox in der GUI erzeugt (vChoice) oder von der Subroutine Eingabe auf 1 gesetzt.
Treffer: ist die Datenbankzeile des ausgewählten Listenitems. Lokale Variable der Funktion ShowDBLine()

LineCount: Zeilenzahl in der Liste/ Tabelle. Von ReadDBFile(DatabaseFile) erzeugt.

ViewOrder: Die anzuzeigenden Datenbankzellen mit der Syntax 1-2-3, Trenner zwischen Anzeigemodi: | Return: 1-2, Leerzeichen, kein Return: 1_-2 Leerzeichen Komma, kein Return 1,_-2
ModeNr: Die Nummer eines Anzeigemodus
Direction: Nächster/ Letzter Anzeigemodus

CursorIn :Die Control, in der sich beim GUI-Start der Cursor befindet
ActiveWindow :Das beim GUI-Start aktive Fenster

GUIStartKey: Hotkey, mit dem die GUI gestartet wird. Wird in der INI definiert. Default: Capslock

*/

;****************************************************
;*
;* INITALISIERUNG
;*
;****************************************************


;Initialisierung

SetTitleMatchMode, 3
;Menu, tray, icon, trayico.ico
#KeyHistory 0

; k++ addition
Changed=0 ; used to check if the active file list was changed by the user
ReadIni() ; Check & Read INI file, merged into one function
DBFile=%Default%

Hotkey, %GUIStartKey%, GUIStart
return

;************************************************
;*
;* AUTOEXECUTE
;*
;************************************************

GUIStart:

; k++ addition, the window title is used to determine which taglist should be loaded
WinGetActiveTitle, ActiveWindowTitle
; [] seem to be illegal characters, remove them from the string
StringReplace, ActiveWindowTitle, ActiveWindowTitle, [, -, All
StringReplace, ActiveWindowTitle, ActiveWindowTitle, ], -, All

; k++ addition, if the active file list was changed by the user, changed = 1
If Changed = 0   
   {
      DBFile=%Default% ; if we don't reset the default here the one from loop below will become the 'default', but we only want that in case there was no manual selection
      
      ; check if the ActiveWindowTitle matches a trigger if so change DBFile accordingly
      Loop, %NumberOfLists%
      {
         Trigger := Trigger%A_Index%
         File := File%A_Index%
         IfInString, ActiveWindowTitle, %Trigger%, SetEnv, DBFile, %File%
      }
   }

;Read lines from active file
ReadDBFile(DBFile, Separator)
StartList := MakeStartList()

; Get Active Window ID and Active Control
CursorIn := GetActiveControl()
ActiveWindow := GetActiveWindow()

; Will prevent error message when the window is already active in the background
   IfWinExist, %GUITitle%
   {
   IfWinNotActive, %GUITitle%

   {
      WinMinimize , %GUITitle%
      WinActivate , %GUITitle%
   }
   ;Gui destroy
   }
else
{
; k++ (re)moved some buttons, added DropDownList
Gui, Add, Text, x5 y8 w45 h15, &Search:
Gui, Add, Edit, gEingabe vEingabe x50 y5 w110 h20 +Left,
Gui, Add, Text, x5 y33 w45 h15, &File:
Gui, Add, DropDownList, x50 y30 w152 h15 gChangeActiveFile R7 SORT vDBFileChange, %FileList%
Gui, Add, ListBox, x5 y57 w197 h230 gChoice vChoice altsubmit ,%StartList%
Gui, Add, Edit, x5 y287 w197 h133 ReadOnly,
Gui, Add, Button, x167 y5 w35 h21 Default, &OK
Gui, Add, Button, x5 y425 w47 h21 , &Edit
Gui, Add, Button, x55 y425 w47 h21 , &Add
Gui, Add, Button, x105 y425 w47 h21, O&ptions
Gui, Add, Button, x155 y425 w47 h21, &Reset
Gui, Add, StatusBar,,
SB_SetParts(140)
SB_SetText(DBFile,1) ; show active file in statusbar
SB_SetText(LineCount . "/" LineCount,2) ; show how many hits / total lines there are in the active file
Gui, Show, x353 y55 h470 w207,%GUITitle%

; Creates a Hitlist and a Hitlist-Array, so that at GUIStart the lines can be shown in Edit2
Choice=1
      loop, %LineCount%
      {
         Hitlist=%Hitlist%|%A_Index%
         Hitlist_%A_Index%=%A_Index%
      }

ModeNr=1
Direction=0
   ;Anzeige(ViewOrder,ModeNr,Direction)
Show()
}
Return

;****************************************************
;*
;* HOTKEYS
;*
;****************************************************

#IfWinActive, Kollektor++ ahk_class AutoHotkeyGUI   ; Hotkeys only work in the just created GUI
Up::
ControlGetFocus, CheckEdit, %GUITitle%
If (CheckEdit="Edit1") {
   ControlSend, ListBox1, {Up}, %GUITitle%
   }
If (CheckEdit="ComboBox1") {
   ControlSend, ComboBox1, {Up}, %GUITitle%
   }
return

Down::
ControlGetFocus, CheckEdit, %GUITitle%
If (CheckEdit="Edit1") {
   ControlSend, ListBox1, {Down}, %GUITitle%
   }
If (CheckEdit="ComboBox1") {
   ControlSend, ComboBox1, {Down}, %GUITitle%
   }
return

Enter::
Gosub ButtonOK
Return

;F1:: ; used to open a HTML help page
;Gosub ButtonHelp
;Return

#IfWinActive

; k++ If you press ALT-A or click the ADD button, you can add the marked text to the currently active file
ButtonAdd:
ClipSaved := ClipboardAll ; Save clipboard
send, ^c
StringLeft, ShowClip, Clipboard, 450 ; We need to trim text because MsgBox might become to large to fit on screen
MsgBox, 4, ADD to file?, Do you want to add the text below to %DBFile%`n`n%ShowClip% ...
IfMsgBox Yes
   {
   StringReplace, clipboard, clipboard, `r`n,%Separator%, All ;Replaces CR LF by %Separator%
   FileAppend, %Clipboard%`n, %DBFile%
   }
Clipboard := ClipSaved ; Restore the original clipboard.
ClipSaved =            ; Free the memory ^
ShowClip =
GUI destroy
Return   

;****************************************************
;*
;* SUBROUTINEN
;*
;****************************************************

Return

ButtonOK:      ; Insert the selected/found text in the active window
   ClipSaved := ClipboardAll ; Save clipboard
   ControlGetText, Clipboard ,Edit2, %GUITitle%
   GUI destroy ; Before sending the contents of the clipboard, the GUI must be removed because many windows will not accept ControlSend when the window is active in the background
   ControlSend, %CursorIn%,{Control down}v{Control up}, AHK_ID%ActiveWindow%   ; On some systems only {Control down}v{Control up} works correcly and not ^v
   Clipboard := ClipSaved ; Restore the original clipboard.
   ClipSaved = ; Free the memory
Return

GuiEscape:      ; Gui dissappears, program remains active in memory
   GUI destroy      
Return

GuiClose:      ; Programm is closed
   ExitApp

; K++ addition, new function to load new file
ChangeActiveFile:
  Gui, Submit
  DBFile = %DBFileChange%
   GUI destroy
   Changed=1 ; remember the active file was changed manually
   Gosub GUIStart ; reload gui to load active file
Return
   
; --------------------------------------------------------------------------

ButtonOptions:
   runwait, %Editor% KollektorPP.ini
   sleep, 500
   ReadIni()
     Return

;ButtonHelp:
;   run, .\Help\Kollektor_Hilfe.htm
;Return

ButtonEdit:
   runwait, %Editor% %DBFile%
   GUI destroy
   Gosub GUIStart
  Return
   
ButtonReset:
   Changed=0 ; if you reload the app, forget manually selected file
   GUI destroy
   Gosub GUIStart
  Return

; --------------------------------------------------------------------------
   
EINGABE:
; Enter text to search for, show list of found items in listbox
Gui, Submit, noHide
SearchFor=
Loop
{   ; Sometimes you type to fast for the computer
   If SearchFor=%Eingabe%
      break
   SearchFor=%Eingabe%

   ;Erstellen der Trefferliste
   Hitlist := SearchDB(SearchFor,CaseSensitive,WholeWordCheck,WhichColumn,WordStart)
   word=
   wordlist=
   ; K++ addition ; HowManyHits is used to show how many items were found in the Statusbar
   HowManyHits =
   loop, parse, Hitlist,|
   {
      Word := DB%A_LoopField%_1
      Wordlist =%Wordlist%|%word%
      Hitlist_%A_Index%=%A_LoopField%
     ; K++ addition
      HowManyHits := A_Index
   }
   ; K++ addition
   HowManyHits-=1
   SB_SetText(HowManyHits . "/" . LineCount,2)      
   
   ; Check if there is another entry
   GUI, Submit, noHide
}

; Special cases
If (Wordlist="")         ; Nothing found, empty the Listbox
   Wordlist=|

If (SearchFor="")         ; Show start list when the input box is empty
   {
   Wordlist=|%StartList%
   ; K++ addition, restore statusbar to start values
        SB_SetText(LineCount . "/" . LineCount,2)         
   }
   
; Listbox with found items is shown
GuiControl,, ListBox1, %wordlist%   
Choice=1
Direction=0
ModeNr=1
;Anzeige(ViewOrder,ModeNr, Direction)
Show()
return

; --------------------------------------------------------------------------

CHOICE:
; Used by navigation in the Listbox (up/down keys)

Gui, submit, NoHide
Direction=0
ModeNr=1
;Anzeige(ViewOrder,ModeNr,Direction)
Show()

; Doubleclick on item in the list, same as Button OK
if A_GuiControlEvent = DoubleClick
    Gosub ButtonOK
return



;****************************************************
;*
;* GUI_FUNKTIONEN
;*
;****************************************************

Show()
; Shows the lines in the preview window, correcting any linebreaks (separator)
{
   global  Hitlist, Choice,
   Treffer := Hitlist_%Choice%         ; "Treffer" is the number of the selected item in the list
   Line := DBLine_%Treffer%
   StringReplace, ToShow, Line, ¤, `n, All
   GuiControl,, Edit2, %ToShow%
   return
}


Anzeige(ViewOrder,ModeNr, Direction)
; Zeigt die Feldinhalte in Edit2 formatiert an und erlaubt, zwischen verschiedenen Anzeigemodi der Feldinhalte zu wechseln.
; ViewOrder:    1-2-3    (Felder 1, 2 und 3 werden in eigenen Zeilen angezeigt)
;            1_-2-3   (Felder 1 und 2 werden in der gleichen Zeile, durch Leerzeichen getrennt angezeigt)
;            1,_-2-3   (Felder 1 und 2 werden in der gleichen Zeile, durch Komma und Leerzeichen getrennt angezeigt)
; ModeNr: Nummer des gerade angezeigten Modus
; Direction: Nächster oder vorheriger Modus.
; Lokale Variablen: a (Zählvariable), ToShow_%a%(Anzuzeigender Inhalt)


{
   global ColCount, Hitlist, Choice
   
   Treffer := Hitlist_%Choice%         ; "Treffer" is the number of the selected item in the list

   ModeNr := ModeNr+Direction
      
   ViewModeCount=0
   loop, parse,ViewOrder,|
      {
         ViewModeCount := ViewModeCount + 1      ;Zählt die Anzeigen-Modi
         a=%A_Index%
         ToShow_%a% =
   
         Loop, Parse,A_LoopField,-
         {
            If A_LoopField is integer
            {
               ToShow_%a% := ToShow_%a% . DB%Treffer%_%A_LoopField% . "`n"
            }            

            else
            {
               FieldNr := LeaveOnlyNumbers(A_LoopField)         ; Nur die Feldnummer bleibt übrig, alle anderen Zeichen werden entfernt
               if (Instr(A_LoopField,",_")>0)                       ; Komma Unterstrich für Komma, Leerzeichen,kein Zeilenumbruch
                  ToShow_%a% := ToShow_%a% . DB%Treffer%_%FieldNr% . "," . A_Space               
               else if (Instr(A_LoopField,"_")>0)                  ;Unterstrich für, Leerzeichen,kein Zeilenumbruch
                  ToShow_%a% := ToShow_%a% . DB%Treffer%_%FieldNr% . A_Space
               else
                  ToShow_%a% := ToShow_%a% . DB%Treffer%_%FieldNr% . "`n"      ;Alle weiteren Nicht-Integers werden ignoriert            
            }   
               
         }
      }

   ; Am Listenende: Sprung an den Anfang/ Am Listenanfang: Sprung ans Ende der Liste
   If (ModeNr<1)
      ModeNr= %ViewModeCount%
   If (ModeNr>ViewModeCount)
      ModeNr=1
      
   ;Anzeige des gewählten Modus   
   GuiControl,, Edit2, % ToShow_%ModeNr%
   
   ;Rückgabe der ModusNummer
   Return ModeNr
}

; --------------------------------------------------------------------------

MakeStartList()
;erstellt eine Liste aller Items, die beim Programmstart angezeigt wird
{
   global LineCount
   Startlist=
   Loop, %LineCount%
   {
      word := DB%A_Index%_1
      Startlist =%Startlist%%word%|
   }
   return StartList
}


;****************************************************
;*
;* SUCH-FUNKTIONEN
;*
;****************************************************

SearchDB(SearchFor,CaseSensitive,WholeWordCheck,WhichColumn,WordStart)
; Sucht nach dem als Parameter (SearchFor) übergebenen String. Gibt die Zeilen, in der
; der Suchstring gefunden wurde, als Liste der Zeilennummern im Format 1|3| u.s.w. zurueck ("Hitlist")

; Der Parameter CaseSensitive bestimmt, ob bei der Suche die Groß/Kleinschreibung beachtet wird.

; Der Parameter WholeWordCheck bestimmt, ob bei der nur nach ganze Wörtern (on) oder auch nach
; Wortfragmenten gesucht wird. Zum Prüfen wird die Funktion IsWholeWord(SearchIn,SearchFor) aufgerufen.
;   
; Der Parameter WhichColumn gibt an, welche Spalten durchsucht werden sollen. ALL=Alle Spalten.
; 1 oder 2 oder ...: Die explizit benannte Spalte. Default ist 1

; Der Parameter WordStart bestimmt, ob der Suchtext am Zellenanfang stehen muß.
;
; Die Parameterübergabe (global, local, was muss deklariert werden, was nicht) ist etwas unlogisch.
; Näheres in der AHK-Dokumentation (Functions-Local Variables and Global Variables)

{
   global LineCount, ColCount         ;Bestehende globale Variablen müssen bei Verwendung innerhalb einer Funktion als global deklariert werden
   ;global counter
   ;Counter := counter+1
   
   ; FEHLERBEHANDLUNG
   If (WhichColumn>ColCount and WhichColumn<>"ALL")         ;Suche in einer nicht existierenden Spalte
      {
         ;msgbox, Die Tabelle enthält nur %ColCount% Spalten.`nDie %WhichColumn%. Spalte kann also nicht durchsucht werden.`nDie Anwendung wird beendet.
         msgbox, The Table only contains %ColCount% columns.`nThe %WhichColumn% column can not be searched.`nThe search will be stopped.
         exitapp
      }
      
   ; SUCHE
   Loop, %LineCount%
   {
      L_Index=%A_Index%            ;L_Index: Zeilennummer
      
      Loop, %ColCount%
      {
         ;In welchen Spalten?
         If WhichColumn=ALL         ;Alle Spalten werden durchsucht
            C_Index=%A_Index%      ;C_Index: Spaltennummer
         Else   
            C_Index=%WhichColumn%   ;nur die spezifizierte Spalte wird durchsucht
         
         SearchIn :=  DB%L_Index%_%C_Index%
         Position := InStr( SearchIn,SearchFor,CaseSensitive )      ;Position des Suchbegriffes. O= Suchbegriff nicht gefunden. >=1 Treffer irgendwo in SearchIn. =1 Treffer steht am Anfang
         
         If (Position = 0)      
            continue
         
         ;Bedingungen abfragen
         If (Position=1 AND WholeWordCheck="ON" AND WordStart="ON")      ;Es wird nach ganzem Wort am Zellanfang gesucht
         {
            WholeWord := IsWholeWord(SearchIn,SearchFor)
            If WholeWord=1
            {
               Hitlist=%Hitlist%%L_Index%|
               break
            }
         }
         
         If (Position>=1 AND WholeWordCheck="ON" AND WordStart="OFF")   ;Es wird nach ganzem Wort irgendwo in der Zelle gesucht
         {
            WholeWord := IsWholeWord(SearchIn,SearchFor)
            If WholeWord=1
            {
               Hitlist=%Hitlist%%L_Index%|
               break
            }
         }

         If (Position=1 AND WholeWordCheck="OFF" AND WordStart="ON")   ;der Zelleninhalt beginnt mit dem Suchbegriff
         {
            Hitlist=%Hitlist%%L_Index%|
            break
         }

         If (Position>=1 AND WholeWordCheck="OFF" AND WordStart="OFF")   ;Suchbegriff hat beliebige Position
         {
            Hitlist=%Hitlist%%L_Index%|
            Break
         }
         If (WhichColumn<>"ALL")      ;Beendt die Suche nach einer Spalte, wenn nur eine durchsucht werden soll   
         {
            Break
         }         
      }
   }
   return Hitlist
}


;***************************************************************************************************

ReadDBFile(DatabaseFile,Separator)
; Schreibt den Inhalt einer Semicolon-getrennten Datenbankdatei in ein Array.
; Array-Syntax:DBZeilennummer_Spaltennummer=Feldinhalt
; DBLine_Zeilennummer: Zeileninhalt
; Liefert außerdem die Anzahl von Zeilen und Spalten in der Datenbank-Datei zurück (ebenfalls als globale Variablen).
; Die Funktion hat keinen direkten Rückgabewert.
;
; GLOBALE VARIABLEN:
; LineCount: Anzahl der Zeilen in der Datenbank-Datei
; ColCount: Spaltenzahl (Anzahl der Felder in der längsten Zeile)
; DB%L_Index%_%A_Index%: Array, in dem die Datenbankfelder gespeichert sind: Zeilennummer_Spaltennummer
; %L_Index%ColCount: Spaltenzahl in der L-ten Zeile. Wird nicht weiter gebraucht, läßt sich aber leider auch nicht als lokale Variable definieren

{
   global                     ;Alle Variablen dieser Funktion sind global
   local L_Index               ;Diese Variablen sind lokal (gelten nur innerhalb der Funktion)
   LineCount = 0
   ColCount = 0
   
   ;Krücke. Nach dem Löschen der Liste bleibt das Array im Speicher. Die 1. Zeile wird geleert, um zu verhindern, daß sie in der Edit2 angezeigt wird.
   IfNotExist, %DBFile%
      DBLine_1 =
      
   
   Loop, read, %DBFile%
   {
      DBLine_%A_Index%=%A_LoopReadLine%
      L_Index=%A_Index%
      %L_Index%ColCount = 0
      LineCount += 1
      ;Loop, parse, A_LoopReadLine, %Separator% ;This is the original line in the script
      Loop, parse, A_LoopReadLine,`n
      {
         DB%L_Index%_%A_Index% = %A_LoopField%
         %L_Index%ColCount += 1         ;Die Variable %L_Index%ColCount ist NICHT identisch mit ColCount!
         if( ColCount < %L_Index%ColCount )
         ColCount := %L_Index%ColCount
      }
   }
}


;*******************************************************************************************************

IsWholeWord(SearchIn,SearchFor)
; Überprüft ob der zu suchenden Begriff "SearchFor" als eigenes vollständiges Wort in "SearchIn"
; vorkommt.
; Wenn ja, wird WholeWord=1 zurückgegeben, wenn nicht WholeWord=0

{
   BorderChar=,,,.,%A_Space%,%A_Tab%,-,:            ;Liste von Zeichen, die vor oder nach einem Wort stehen können. Reihenfolge der Liste ist wichtig!
   SearchLength := StrLen(SearchFor)
   FieldLength := StrLen( SearchIn)
   Position := InStr( SearchIn, SearchFor)
   
   if SearchLength = %FieldLength%                ;SearchIn enthält nur das Suchwort
   {
      WholeWord=1
   }
   
   else if Position=1                        ;SearchIn beginnt mit dem Suchwort                           
   {
      StringMid, TailChar, SearchIn, % Position+SearchLength, 1   ;TailChar: erstes Zeichen nach "SearchFor"
      if TailChar contains %BorderChar%         
      {
         WholeWord=1
      }
      else
       {
          WholeWord=0
       }
   }
   
   else if (Position+SearchLength-1=FieldLength)   ;SearchIn endet mit dem Suchwort
   {
      StringMid, LeadChar, SearchIn, % Position - 1, 1
      if LeadChar contains %BorderChar%
      {
         WholeWord=1
      }
      else
      {
          WholeWord=0
      }
   }
   
   else                                 ;SearchFor steht mitten in SearchIn
   {
      StringMid, LeadChar, SearchIn, % Position - 1, 1
      if LeadChar contains %BorderChar%
      {
         StringMid, TailChar, SearchIn, % Position+SearchLength, 1   ;TailChar: erstes Zeichen nach "SearchFor"
         if TailChar contains %BorderChar%         
         {
            WholeWord=1
         }
         else
         {
            WholeWord=0
         }
      }
      else
      {
          WholeWord=0
      }
   }   
   return WholeWord
}


;****************************************************
;*
;* SONSTIGE FUNKTIONEN
;*
;****************************************************

LeaveOnlyNumbers(String)
;Entfernt alle Zeichen außer den Ziffern aus dem String
{
   stringlen, Laenge, String
   stringsplit, Stringarray, string
   Loop, %Laenge%
   {
   if stringarray%A_Index% is not integer
      {
      Stringarray%A_Index%=
      }
      x:= stringarray%A_Index%
      NewString=%NewString%%x%
   }
   String=%NewString%
   Return %String%
}

; --------------------------------------------------------

CharacterCount(String, Character)
;Zählt, wie oft das Zeichen "Character" im String vorkommt und gibt diese Anzahl zurück
{
   x=0
   StringLen, Laenge, String
   StringSplit, Stringarray, string
   Loop, %Laenge%
   {
   if stringarray%A_Index% contains %Character%
      {
      x := x+1
      }
   }
   Return x
}

; --------------------------------------------------------

GetActiveControl()
;Gibt den Namen der aktiven Control zurück
{
WinGet, Active_Window_ID, ID, A               
ControlGetFocus, ActiveControl, A,
Return,  ActiveControl
}

; --------------------------------------------------------

GetActiveWindow()
; Gibt die ID-Nummer des gerade aktiven Fensters zurück
{
WinGet, Active_Window_ID, ID, A               
return, Active_Window_ID
}

; --------------------------------------------------------

; k++ completely new function
ReadIni()
{
global
; check if there is an ini file, if not create one
IfNotExist,KollektorPP.ini
   {
      ini=
(
[SETTINGS]
GUITitle=Kollektor++
GUIStartKey=CAPSLOCK
Editor=notepad.exe

[SEARCH]
CaseSensitive=0
WholeWordCheck=OFF
WordStart=OFF
WhichColumn=1
Separator=¤

[VIEW]
ViewOrder=1
ModeNr=1
Direction=0

[LISTS]
Default=Default.txt
)
  FileAppend,%ini%,KollektorPP.ini
  ini=
   }

; read general settings
IniRead,GUITitle,KollektorPP.ini,SETTINGS,GUITitle,Kollektor++
IniRead,GUIStartKey,KollektorPP.ini,SETTINGS,GUIStartKey,CAPSLOCK
IniRead,Editor,KollektorPP.ini,SETTINGS,Editor,notepad

; read search settings
IniRead,CaseSensitive,KollektorPP.ini,SEARCH,CaseSensitive,0
IniRead,WholeWordCheck,KollektorPP.ini,SEARCH,WholeWordCheck,OFF
IniRead,WordStart,KollektorPP.ini,SEARCH,WordStart,OFF
IniRead,WhichColumn,KollektorPP.ini,SEARCH,WhichColumn,1
IniRead,Separator,KollektorPP.ini,SEARCH,Separator,¤

; read view settings
IniRead,ViewOrder,KollektorPP.ini,VIEW,ViewOrder,1
IniRead,ModeNr,KollektorPP.ini,VIEW,ModeNr,1
IniRead,Direction,KollektorPP.ini,VIEW,Direction,0

; read default list
IniRead,Default,KollektorPP.ini,LISTS,Default,Default.txt

; read triggers & associated files   
FileList = %Default%
Loop
 {
  NumberOfLists:=A_Index
  IniRead,Trigger%NumberOfLists%,KollektorPP.ini,LISTS,Trigger%NumberOfLists%
  IniRead,File,KollektorPP.ini,LISTS,File%NumberOfLists%
  If (File = "ERROR") {
      Break
   }
   File%NumberOfLists% := File
   FileList .= "|" . File
 }
NumberOfLists-=1
}
