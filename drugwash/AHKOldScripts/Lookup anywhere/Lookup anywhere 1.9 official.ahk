; Look information up anywhere by keyboardfreak
;
; $LastChangedDate: 2009-03-29 21:09:54 +0200 $
;
; http://www.autohotkey.com/forum/viewtopic.php?t=42005
;
; Contributors:
;   Drugwash
;

#NoEnv

; OS version check for alternate options
if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME
   w9x := true

; user config --------------------------------------------------------

; list of source names you want to use separated by |
; (e.g. Wikipedia|Google|IMDb)
;
; only those sources appear in the dropdown box which are present in
; this list and they appear in the given order
;
; if you leave it empty then all sources appear in the order they are
; created in the script
sources_to_use =

; time to wait after copy for the copied contents to appear on the
; clipboard (ms)
;
; set this to a non-zero value if the tool doesn't pick up the
; selected text when pressing the hotkey
sleep_after_copy := (w9x = true) ? 500 : 0

; delay after which the browser windows is updated when the expression
; or the source is changed
update_browser_delay = 1000

; width of the info window (pixels)
gui_width = 600

; height of the info window (pixels)
gui_height = 400

; width of margin around the browser window (pixels)
browser_margin = 5

; the mouse position is checked this often to see if the popup window
; should be hidden (ms)
delay_to_hide = 10

; if the mouse is further away than this distance from the info window
; then it is hidden automatically (pixels)
hide_distance = 50

; enable automatic popup of help window for selection (needs
; javascript support)
enable_automatic_popup := false

; add a checkbox to the gui which can be used to change to value of
; enable_automatic_popup on the fly
add_popup_control := false


; put your settings for the above variables into this file if you
; don't want to modify the script every time a new version comes out
#include *i localconfig.ahk

; initialization ------------------------------------------------------

gui_id =
gui_title := "quick info lookup"
dummytext := "some dummy text"

sources_num = 0
current_source = 1

add_sources()


Gui, +LastFound  -SysMenu +Owner
Gui, Color, 66CCFF
Gui, Add, Text, section, Text:
Gui, Add, Edit, ys vText gTextChanged

list =

if (sources_to_use == "")
  loop %sources_num%
  {
    name := sources%a_index%_name

    if (list == "")
      list = %name%
    else
      list = %list%|%name%
  }
else
  loop parse, sources_to_use, |
  {
    name := A_LoopField

    if (list == "")
      list = %name%
    else
      list = %list%|%name%
  }
 

Gui, Add, DropDownList, ys Choose%current_source% vSource gSourceChanged, %list%

Gui, Add, Button,ys ggoback, Back

Gui, Add, Button,ys gpopout, &Pop out

if (add_popup_control)
  Gui, Add, CheckBox, ys+5 gautopopup vAutopopup, Auto popup
   
; we need this as workaround for SlimBrowser
MouseGetPos, MoldX, MoldY

if (enable_automatic_popup)
{
  if (add_popup_control)
    GuiControl,,Autopopup, 1
 
  gosub start_selection_monitoring
}


; hotkeys -------------------------------------------------------------

$esc::
  if gui_visible
    gosub guihide
  else
    send {esc}
  return


pause::
  oldclipboard := clipboard
  clipboard := dummytext

  sendinput ^c
  Sleep, % sleep_after_copy
  expression := clipboard

  if (clipboard == dummytext)
    expression =

  clipboard := oldclipboard

  gui_shown_automatically := false
  gosub showgui

  return


; subroutines and functions -------------------------------------------

showgui:

  PosGui(gui_width, gui_height)  ; call the active monitor detection function
  Gui, Show, x%gui_x% y%gui_y% w%gui_width% h%gui_height% , %gui_title%
  DllCall("SetCursorPos", int, gui_cx, int, gui_cy)


  guicontrol,,Text, %expression%
  guicontrol focus, Text
  sendinput {end}

  if (expression <> "")
    guicontrol focus, Source

  if (gui_id == "")
  {
    top_margin = 30

    IE_Init()
    gui_id := WinExist(gui_title)
    pweb := IE_Add(gui_id, browser_margin, browser_margin + top_margin
                   , gui_width - (2 * browser_margin)
                   , gui_height - (2 * browser_margin) - top_margin)
    COM_Invoke(pweb, "Silent", True)
  }

  if (expression <> "")
    load_url()

  settimer hidegui, %delay_to_hide%
  gui_visible := true

  return


hidegui:
  MouseGetPos x, y

  if (x < -hide_distance
      or x > (gui_width  + hide_distance)
      or y < -hide_distance
      or y > (gui_height + hide_distance))
    gosub guihide

  Return


get_url()
{
  global

  return sources%current_source%_url . expression
}


load_url()
{
  global
 
  IE_LoadURL(pweb, get_url())
 
  start_load_monitoring_if_needed()
}
 

start_load_monitoring_if_needed()
{
  global
 
  SetTimer wait_for_page_load, off
  SetTimer check_if_new_page_is_loading, off
 
  if (sources%current_source%_pagefix <> "")
    SetTimer wait_for_page_load, 100
}


textchanged:
  settimer textchanged_idle, % update_browser_delay
  return


textchanged_idle:
  settimer textchanged_idle, off

  guicontrolget expression,,text
  if (expression <> "")
  {
    if (sources%current_source%_suggestions)
    {
      func := "get_suggestions_" . sources%current_source%_name
      result := %func%(expression)
    }
    else
      result =

    if (result == ""
        or regexmatch(result, "\|.*\|") == 0) ; only one
      load_url()
    else
    {
      html := "<h3>Suggestions:</h3><ul id=""suggestionlist""></ul>"
      IE_LoadHTML(pweb, html)
     
      while (IE_ReadyState(pweb) <> 4)
      {
        sleep 10
      }
     
      Loop, parse, result, |
      {
        COM_Invoke(pweb, "document.parentwindow.execscript"
        , "ul=document.getElementById('suggestionlist');"
        . "li=document.createElement('li');"
        . "ul.appendChild(li);"
        . "a=document.createElement('a');"
        . "li.appendChild(a);"
        . "a.appendChild(document.createTextNode('" . A_LoopField . "'));"
        . "a.href='http://en.wikipedia.org/wiki/" .  A_LoopField . "'")
      }
   
      start_load_monitoring_if_needed()
    }   
  }

  Return



wait_for_page_load:
  if (IE_ReadyState(pweb) == 4)
  {
    settimer wait_for_page_load, off
    COM_Invoke(pweb, "document.parentwindow.execscript"
               , "try{" . sources%current_source%_pagefix . "}catch(e){}")
    settimer check_if_new_page_is_loading, 100
  }
  return


check_if_new_page_is_loading:
  if (IE_ReadyState(pweb) <> 4)
  {
    settimer check_if_new_page_is_loading, off
    start_load_monitoring_if_needed()
  }
  return


guihide:
  gui, hide
  gui_visible := false
  SetTimer hidegui, off
  SetTimer wait_for_page_load, off
  SetTimer check_if_new_page_is_loading, off

  ; if GUI was shown automatically and current window is Opera or
  ; SlimBrowser, then cancel the selection, so that the GUI doesn't
  ; appear again automatically
  if (gui_shown_automatically)
  {
    WinWaitNotActive ahk_class gui_id
    WinGetClass class, A

    if (class == "OpWindow")
      send {esc}
    else if class in SlimBrowser MainFrame
    {
      ; SlimBrowser doesn't react to ESC in ANY way
      ; so we need to send a mouse click to cancel selection
      SendInput {click, MoldX, MoldY}
      sleep, 2*%sleep_after_copy%
    }
  }

  return



GuiClose:
  COM_Release(pweb)
  Gui, Destroy
  IE_Term()
return




SourceChanged:
  SetTimer sourcechanged_idle, % update_browser_delay
  return


SourceChanged_idle:
  SetTimer sourcechanged_idle, off

  GuiControlGet source_name,,source

  loop %sources_num%
  {
    if (source_name == sources%a_index%_name)
    {
      current_source := a_index
      break
    }
  }

  load_url()

  Return


goback:
  IE_GoBack(pweb)
  start_load_monitoring_if_needed()
  return


popout:
  gosub guihide

  Run % IE_GetUrl(pweb)

  return


check_selection_in_title:
  if !w9x
  {
    if (A_TimeIdle < 500)
      return
  }
  else
  {
    MouseGetPos, McurX, McurY
    if ((McurX != MoldX) || (McurY != MoldY))
    {
      Tlast := A_TickCount
      MoldX := McurX
      MoldY := McurY
    }
    Itime := A_TickCount - Tlast
    if (Itime < 500)
      return
  }
 
  WinGetTitle title, A
  pos := RegExMatch(title, "\{([^}]+)\}.*", match)
  if (pos == 0)
    Return

  MouseGetPos, MoldX, MoldY
 
  expression := match1
  gui_shown_automatically := true
  gosub showgui

  return
 
 
start_selection_monitoring:
  if w9x
    Tlast := A_TickCount
 
  SetTimer check_selection_in_title, 100
 
  Return

autopopup:
  enable_automatic_popup := !enable_automatic_popup
 
  if (enable_automatic_popup)
    gosub start_selection_monitoring
  else
    SetTimer check_selection_in_title, off
 
  return
 
; MULTI-MONITOR DETECTION  -----------------------------------------

PosGui(GW, GH)            ; pass GUI size as parameters
{
  ; top-left corner and center of the GUI
  ; (the latter is used for positioning the mouse)
  Global gui_x, gui_y, gui_cx, gui_cy
  WinGetPos, AX, AY, AW, AH, A   ; get active window coordinates
  AcenH := AX + AW//2         ; get active window horizontal center
  AcenV := AY + AH//2         ; get active window vertical center
  SysGet, Tmon, 80            ; find total number of monitors
  Loop, %Tmon%
  {
   ; get working area for monitor %A_Index%
   SysGet, Mon%A_Index%, MonitorWorkArea, %A_Index%
   ; get monitor horizontal center
   Mcen%A_Index%H := Mon%A_Index%Left + (Mon%A_Index%Right - Mon%A_Index%Left) // 2
   ; get monitor vertical center
   Mcen%A_Index%V := Mon%A_Index%Top + (Mon%A_Index%Bottom - Mon%A_Index%Top) // 2
   if (AcenH <= Mon%A_Index%Right && AcenH >= Mon%A_Index%Left)
      {
      gui_x := Mcen%A_Index%H - GW//2
      gui_y := Mcen%A_Index%V - GH//2
      gui_cx := gui_x + GW//2
      gui_cy := gui_y + GH//2
      break
      }
   }
 }
 
 
; sources ----------------------------------------------------------
 
add_sources()
{
add_source("Wikipedia"
,"http://en.wikipedia.org/wiki/Special:Search?search="
,"document.getElementById('column-one').style.display='none';"
. "document.getElementById('content').style.marginLeft=0"
, false)

add_source("Google"
,"http://www.google.com/search?ie=utf-8&oe=utf-8&hl=en&q="
,"document.getElementById('header').style.display='none';"
. "document.getElementById('tsf').style.display='none';"
. "document.getElementById('ssb').style.display='none'")

add_source("Google Define"
,"http://www.google.com/search?ie=utf-8&oe=utf-8&hl=en&q=define:"
,"document.getElementById('header').style.display='none';"
. "document.getElementById('tsf').style.display='none';"
. "document.getElementById('ssb').style.display='none'")

add_source("IMDb"
,"http://www.imdb.com/find?s=all&q="
,"document.getElementById('nb15').style.display='none'")
 
add_source("Youtube"
,"http://www.youtube.com/results?aq=f&search_query="
,"document.getElementById('masthead').style.display='none'")

add_source("Leo.de"
,"http://dict.leo.org/ende?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&search="
,"document.getElementById('mainnavigation').style.display='none';"
. "document.getElementById('searchrow').style.display='none';"
. "document.getElementById('header').style.display='none';"
. "if(document.getElementById('subnavigation')){"
. "document.getElementById('subnavigation').style.display='none';}"
. "var tds=document.getElementsByTagName('td');"
. "for (var i = 0; i < tds.length; i++)"
. "if(tds[i].className == 'sidebar') tds[i].style.display='none'")
}


add_source(name, url, pagefix = "", suggestions = false)
{
  global

  sources_num++

  sources%sources_num%_name := name
  sources%sources_num%_url := url
  sources%sources_num%_pagefix := pagefix
  sources%sources_num%_suggestions := suggestions
}


get_suggestions_wikipedia(expression)
{
  url := "http://en.wikipedia.org/w/api.php?action=opensearch&search=" . expression
  tempfile := A_Temp . "\wikipedia_lookup_temp"
 
  UrlDownloadToFile, %url%, % tempfile
 
  Fileread suggestions, % tempfile
 
  pos := RegExMatch(suggestions, "^.*\[(.+?)\].*", match)
 
  if (pos == 0)
    return ""
 
  suggestions := match1
 
  StringReplace, suggestions, suggestions, `"`,`", ^, All
  StringTrimLeft suggestions, suggestions, 1
  StringTrimRight suggestions, suggestions, 1
   
  list =
 
  Loop, parse, suggestions, ^
  {
     if (list == "")
      list = %A_LoopField%
    else
      list = %list%|%A_LoopField%
  }
 
  return list
}
