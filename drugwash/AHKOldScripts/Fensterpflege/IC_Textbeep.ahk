;====================================================================================
;======================================= Textbeep ===================================
;====================================================================================
; AutoHotkey Version 1.0.47.06
; Language:           German Comments
; Platform:           Win XP, läuft auch unter Vista
; Author:             Halweg (halweg|at|gmx.de)
;
; Script Function:  
; Diese Funktion zeigt Tooltips an und macht Geräusche dazu. Damit können 
; (Hintergrund-)Funktionen eines Skripts leicht visualisiert werden. 
; Die Hintergrund- und Vordergrundfarbe der Tooltips kann eingestellt werden. 
; Die Tooltips verschwinden nach eine einstellbaren Vorhaltezeit wieder.
; Wird die Funktion erneut aufgerufen, während noch ein Tooltip angezeigt wird,  
; so wird der neue Text darunter geschrieben und die Vorhaltezeit beginnt von vorn.
;
; Nach der Anzeige des Tooltips ertönt ein einstellbarer Beep. Dieser wird über das
; Schlüsselwort beeptype ausgewählt. Neue beeptypes können leicht ergänzt werden, 
; aktuell sind die Piepser aus meinen Skripten eingestellt.
; Gegenwärtige Begrenzung: Jede Beep-Folge besteht maximal aus 6 Einzeltönen (einstellbarer Frequenz und Pause.)
;
; Die Anzeige des Tooltips kann mit drücken der ß-Taste (einstellbar) eingefroren werden bzw. 
; nach einer einstellbaren Vorhaltezeit noch einmal aufgerufen werden. Erneutes drücken von ß
; löscht die Meldung wieder
;
; Test und Aufrufbeispiele (standardmäßig auskommentiert)
; #5:: TextBeep()                     ; kein Text, nur Klickgeräusch
; #6:: TextBeep("","verschieben")     ; kein Text, nur Surren-Geräusch
; #7:: TextBeep("Standard-Tooltip mit Standard-Beep-Geräusch.")
; #8:: TextBeep("Das ist ein Tooltip ohne Geräusch.","leise")
; #9:: TextBeep("Das ist schön Blau und wird lange Zeit angezeigt, außerdem ertönt eine Melodie.","hello",10000,"Blue")
; #0:: TextBeep("Das könnte eine Fehlermeldung sein.","fehler")

TextBeep(text_to_show="",beeptype="klick",Textbeep_showtime_ms="",Textbeep_textcolor="")
  {

  ; Einstellungsvariablen GLOBAL definieren, damit die nachfolgenden Einstellungen ins Hauptskript verschoben werden können
  GLOBAL Textbeep_silent_mode, Textbeep_max_rows, Textbeep_x, Textbeep_y, Textbeep_default_frequency
  GLOBAL Textbeep_default_textcolor, Textbeep_background_color, Textbeep_tooltip_width, Textbeep_leading_text
  GLOBAL Textbeep_default_showtime, Pause_mode, Textbeep_max_length

  ; Sonstige globale und statische Variablen
  GLOBAL Hotkey_to_freeze_the_tooltip                                           ; Hotkey, mit dem die Verbalisierungstexte noch mal aufgerufen werden können 
  IF NOT Hotkey_to_freeze_the_tooltip                                           ; Falls im Hauptprogramm nicht definiert ...
    Hotkey_to_freeze_the_tooltip := "ß"                                         ; ... die Taste "ß" als Standard setzen
  GLOBAL Textbeep_aftershow_time := 10000                                       ; Vorhaltezeit der angezeigten Texte nach ihrer Anzeige (in dieser Zeit Reaktivierung mit Hotkey ß)
  GLOBAL Tooltip_text                                                           ; Aktueller Tooltip-Text
  STATIC Rows_count                                                             ; Anzahl der bereits für den Text verbauchten Zeilen
  
  ; Einstellungen setzen, sofern nicht im Hauptskript geschehen 
  IFEQUAL,Textbeep_leading_text,,     SETENV,Textbeep_leading_text,%A_SCRIPTNAME% ; Führender Text, um zu erkennen, woher die Tooltips kommen
  IFEQUAL,Textbeep_silent_mode,,      SETENV,Textbeep_silent_mode,         0    ; Alles Piepsen unterdrücken?
  IFEQUAL,Textbeep_max_rows,,         SETENV,Textbeep_max_rows,           25    ; Wieviele Tooltip-Zeilen sollen maximal gleichzeitig angezeigt werden?
  IFEQUAL,Textbeep_x,,                SETENV,Textbeep_x,                  10    ; An welcher x-Position (Pixel) auf dem Bildschirm soll der Text beginnen
  IFEQUAL,Textbeep_y,,                SETENV,Textbeep_y,                 500    ; An welcher y-Position (Pixel) auf dem Bildschirm soll der Text beginnen
  IFEQUAL,Textbeep_default_frequency,,SETENV,Textbeep_default_frequency,1400    ; Welche Basis-Frequenz soll für das Piepsen verwendet werden
  IFEQUAL,Textbeep_default_showtime,, SETENV,Textbeep_default_showtime, 4000    ; Standard Anzeigedauer der Tooltipps
  IFEQUAL,Textbeep_default_textcolor,,SETENV,Textbeep_default_textcolor,BLACK   ; Standardtextfarbe
  IFEQUAL,Textbeep_background_color,, SETENV,Textbeep_background_color, E1FFE1  ; Hintergrundfarbe, E1FFE1 = helles Grün
  IFEQUAL,Textbeep_max_length,,       SETENV,Textbeep_max_length,120            ; Maxmimale Länge des Tooltip
  
  ; Aktuelle Werte einsetzen, die nicht an die Funktion übergeben wurden 
  IFEQUAL, Textbeep_showtime_ms,,SETENV, Textbeep_showtime_ms,%Textbeep_default_showtime%   ; Wenn keine Anzeigdauer übergeben - Standardanzeigedauer übernehmen
  IFEQUAL, Textbeep_textcolor,,  SETENV, Textbeep_textcolor,  %Textbeep_default_textcolor%  ; Wenn keine Textfarbe übergeben - Standard-TExtfarbe nehmen 

  ; Sonstige Werte
  IFEQUAL,beeptype, fehler,           SETENV,Textbeep_textcolor,        CC0000  ; Bei Fehlern dunkelrote TEXTFARBE
  Pause_mode =                                                                  ; Pausenmodus (lange Anzeige des Textes) ist am Anfang eines neuen textes erst mal aus
  

  IF (text_to_show AND Textbeep_max_rows)                                       ; Soll überhaupt Text angezeigt werden
    {
    IF (STRLEN(text_to_show) > Textbeep_max_length)                             ; wenn der anzuzeigende Text länger als die vorgesehene Maximalzeichenzahl ist, diesen kürzen
      {
      nkurz := FLOOR((Textbeep_max_length-5)/2)                                 ; Ermitteln, wie lang der Text vor und nach den drei Punkten sein darf
      text_to_show := SUBSTR(text_to_show,1,nkurz) . " ... " . SUBSTR(text_to_show,-nkurz+1,nkurz)
      }
    SETTIMER, Remove_tooltip, OFF                                               ; Timer zum Schließen des Tooltips vorübergehend deaktivieren
      {
      IF (Tooltip_text AND Rows_count < Textbeep_max_rows)                      ; Vorherigen Text berücksichtigen und neuen dazu stellen
        {
        Rows_count += 1
        Tooltip_text .= "`n" . text_to_show 
        }
      ELSE                                                                      ; Text neu beginnen
        {
        Rows_count = 1
        Tooltip_text := Textbeep_leading_text . " (Einfrieren der Meldung mit " . Hotkey_to_freeze_the_tooltip . "-Taste):`n" . text_to_show
        }
      IF NOT Textbeep_tooltip_width                                             ; Länge des Textes (und damit des Tooltips) erstmalig ermitteln
        Textbeep_tooltip_width := T_width(Textbeep_leading_text)+20
      current_width := T_width(Text_to_show)
      IFGREATER, current_width, %Textbeep_tooltip_width%, SETENV, Textbeep_tooltip_width, %current_width%
      PROGRESS , 2:B1 X%Textbeep_x% Y%Textbeep_y% W%Textbeep_tooltip_width% CW%Textbeep_background_color% C00 CT%Textbeep_textcolor% FM8 WM500 ZX0 ZY2 ZH0, ,%Tooltip_text%
      SETTIMER, Remove_Hotkey_to_freeze_the_tooltip, OFF                        ; Der Timer zum Hotkey-deaktiveren wird durch den Timer 
      SETTIMER, Remove_tooltip, -%Textbeep_showtime_ms%                         ; Timer zum Schließen des Tooltips neu starten
      HOTKEY, IFWINACTIVE                                                       ; Sicherstellen, dass ein allgemeingültige Hotkey erstellt wird (also keine spezielle IFWINACTIVE-Sitaution) 
      HOTKEY,$%hotkey_to_freeze_the_tooltip%, Freeze_tooltip, USEERRORLEVEL ON  ; Hotkey zum Einfrieren des Tooltips vorab setzen
;       Xbeep(200,1000,30,200,1500,0)
      }
    }
  IF NOT Textbeep_silent_mode
    {
    IFEQUAL,      beeptype,autoaktiv,           SETENV, temp, % Xbeep(70, 0,50,70)                                       ; zweimal kurz
    ELSE IFEQUAL, beeptype,befehlgestartet,     SETENV, temp, % Xbeep(30, -200)                                          ; einmal kurz tiefer
    ELSE IFEQUAL, beeptype,befehlbeendet,       SETENV, temp, % Xbeep(70, -350)                                          ; einmal kurz noch tiefer
    ELSE IFEQUAL, beeptype,fehler,              SETENV, temp, % Xbeep(70, 0,50,70,0,50,70,0,50,70,0,50,70)               ; fünfmal kurz
    ELSE IFEQUAL, beeptype,hello,               SETENV, temp, % Xbeep(100,-350,50,  100,0,50,     100,-200,50, 100,+200,50, 100)                  ; Eröffnungsmelodie Komforteingabe
    ELSE IFEQUAL, beeptype,klick,               SETENV, temp, % Xbeep(30)                                                ; einmal kurz
    ELSE IFEQUAL, beeptype,leise,               SETENV, temp, 20                                                         ; kein Geräusch
    ELSE IFEQUAL, beeptype,nixgetan,            SETENV, temp, % Xbeep(70, +200)                                          ; einmal kurz hoch
    ELSE IFEQUAL, beeptype,pflegestufe_an,      SETENV, temp, % Xbeep(30,-500,100,60,0)                                  ; tief hoch
    ELSE IFEQUAL, beeptype,pflegestufe_aus,     SETENV, temp, % Xbeep(30,0,100,60,-500)                                  ; hoch tief
    ELSE IFEQUAL, beeptype,start_autostart,     SETENV, temp, % Xbeep(150,-8,75,    450,123,300,  150,187,75,  225,298,75,  600,259)              ; Eröffnungsmelodie Autostart
    ELSE IFEQUAL, beeptype,start_fensterpflege, SETENV, temp, % Xbeep(70,-100,50,  70,-100,150,   70,0,50,70,  0,150,70,    100,50,70,  100,150)  ; Eröffnungsmelodie Fensterpflege
    ELSE IFEQUAL, beeptype,test,                SETENV, temp, % Xbeep(2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1)               ; surren
    ELSE IFEQUAL, beeptype,verschieben,         SETENV, temp, % Xbeep(10,0,10,10,0,10,10,0,10,10,0,10,10,0,10)           ; surren
    ELSE IFEQUAL, beeptype,wasgetan,            SETENV, temp, % Xbeep(500,-350)                                          ; einmal lang noch tiefer
    ELSE Textbeep("Beepsignal vom Typ """ . beeptype . """ ist nicht definiert","fehler")
    }
  }

  
Xbeep(ms1="",freq1=0,wait1=0,ms2="",freq2=0,wait2=0,ms3="",freq3=0,wait3=0,ms4="",freq4=0,wait4=0,ms5="",freq5=0,wait5=0,ms6="",freq6=0,wait6=0)
  {
  ; Führt eine Reihe von Piepsen mit der Standardfrequenz aus.
  ; Die Beeps werden über jeweils drei Werte definiert: Dauer (ms), Abweichung von der Standardfrequenz, Pause (ms)
  ; Beispiel: Xbeep(70,0,50,70,-200):
  ; Piepst einmal 70ms mit der Standardfrequenz (Textbeep_frequency), wartet 50ms und piepst einmal 70ms mit der um 200 veringerten Standardfrequenz
  GLOBAL Textbeep_default_frequency
  LOOP, 6
    {
    IF (ms%A_INDEX%)
      SOUNDBEEP, Textbeep_default_frequency+freq%A_INDEX% ,ms%A_INDEX%
    IF (wait%A_INDEX%)
      SLEEP, % wait%A_INDEX%
    }
  }


; Ermittelt die für einen Text benötigte ungefähre Breite eines PROGRESS-Fensters
T_width(text)
  {
  IF INSTR(text,"`n")                                                           ; Wenn der anzuzeigende Text Zeilenumbrüche enthält ...
    {
    length := 0
    LOOP, PARSE, text,`n                                                        ; ... dann über alle Textzeilen ...
      IF (STRLEN(A_LOOPFIELD)> length)                                          ; ... nachschaun, welches die längste Zeile ist ...
        {
        length := STRLEN(A_LOOPFIELD)                                           ; ... und deren Länge ...
        text_to_measure := A_LOOPFIELD                                          ; ... und Text für die spätere Ermittlung merken
        }
    }
  ELSE
    text_to_measure := text
  length := STRLEN(text_to_measure)
  STRINGREPLACE, temp, text_to_measure,%A_SPACE%,,USEERRORLEVEL                 ; Leerzeichen in der Textzeile zählen ...
  number_of_spaces := ERRORLEVEL                                                ; ... damit danch ein bisschen Breite pro Leerzeichen abgezogen werden kann.
  RETURN, 5.3*length + 15 - number_of_spaces*1.4                                ; Diese Berechnung muss angepasst werden, sollte es zu Zeilenumbrüchen kommen.
  }


; Einfrieren der Anzeige 
; Wird der Hotkey (Standardmäßig ß) innerhalb der Vorhaltezeit betätigt, so wird der Tooltip reaktiviert.
Freeze_tooltip:                                                                 
  IF (A_PRIORHOTKEY= "$" . Hotkey_to_freeze_the_tooltip  AND A_TIMESINCEPRIORHOTKEY < 300)    ; Doppelklick des Hotkeys erkennen und ggf. an zweites laufendes Skript weiterleiten
    SEND, %Hotkey_to_freeze_the_tooltip%
  ELSE
    {
    Xbeep(30)
    Pause_mode := NOT Pause_Mode                                                ; Pause_mode wird eingeschaltet (wenn vorher aus) und ausgeschaltet, wenn er schon an war
    IF Pause_mode                                                               ; Pause_mode wurde eingeschaltet ==> Tooltip besser lesbar machen
      PROGRESS , 2:B1 X%Textbeep_x% Y%Textbeep_y% W%Textbeep_tooltip_width% CWBlack C00 CTWhite FM8 WM500 ZX0 ZY2 ZH0, ,%Tooltip_text%
    ELSE
      GOSUB, Remove_tooltip                                                     ; Pause_mode wurde ausgeschaltet ==> Tooltip soll nun entfernt werden
    }
RETURN
  
Remove_tooltip:                                                                 ; Schließt den Tooltip-Text und setzt die Textdaten dafür zurück
  IF NOT Pause_mode                                                             ; nur, wenn wir nicht gerade im Pause_mode sind
    {
    PROGRESS, 2:OFF                                                             ; Tooltip ausschalten
    SETTIMER, Remove_Hotkey_to_freeze_the_tooltip, -%Textbeep_aftershow_time%   ; 10 s Nachlaufzeit für den letzten Tooltip
    }
RETURN

Remove_Hotkey_to_freeze_the_tooltip:
IF NOT Pause_mode                                                               ; nur, wenn wir nicht grade im Pause_mode sind
  {
  Hotkey,$%Hotkey_to_freeze_the_tooltip%,OFF,USEERRORLEVEL                      ; Hotkey zum Einfrieren des Tooltips deaktivieren
  Tooltip_text =                                                                ; Texte für neuen Tooltip frei machen
  Rows_count = 0
  Textbeep_tooltip_width = 0
  }
RETURN