; http://www.autohotkey.com/forum/viewtopic.php?t=42005
; Look up anywhere
; by keyboardfreak
; v1.2 (modded by Drugwash)
;________________________________________________
;________________ DECLARATIONS __________________
#NoEnv
delay_to_hide = 10
gui_width = 500
gui_height = 300
browser_margin = 5
hide_distance = 50
dummytext := "some dummy text"
gui_id =
gui_title := "quick info lookup"
sources_num = 0
current_source = 1
;________________________________________________
;__________________ AUTOEXEC ____________________
add_source("Wikipedia", "http://en.wikipedia.org/wiki/Special:Search?search=", "document.getElementById('column-one').style.display='none';document.getElementById('content').style.marginLeft=0")

add_source("Google Define", "http://www.google.com/search?ie=utf-8&oe=utf-8&hl=en&q=define:", "document.getElementById('header').style.display='none';document.getElementById('tsf').style.display='none';document.getElementById('ssb').style.display='none'")

add_source("IMDb", "http://www.imdb.com/find?s=all&q=", "document.getElementById('nb15').style.display='none'")

add_source("Leo.de", "http://dict.leo.org/ende?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&search=", "document.getElementById('mainnavigation').style.display='none';document.getElementById('searchrow').style.display='none';document.getElementById('header').style.display='none';if(document.getElementById('subnavigation')){document.getElementById('subnavigation').style.display='none';}var tds=document.getElementsByTagName('td');for (var i = 0; i < tds.length; i++)if(tds[i].className == 'sidebar') tds[i].style.display='none'")

Gui, +LastFound  -SysMenu +Owner
Gui, Color, 66CCFF
Gui, Add, Text, section, Text:
Gui, Add, Edit, ys vText gTextChanged

list =
Loop, %sources_num%
	{
	name := sources%a_index%_name
	if (list == "")
		list = %name%
	else
		list = %list%|%name%
	}

Gui, Add, DropDownList, ys Choose%current_source% vSource gSourceChanged, %list%
Gui, Add, Button, ys gpopout, &Pop out
Return
;________________________________________________
;___________________ HOTKEYS ____________________
$esc::
  if gui_visible
	gosub guihide
  else
	send {esc}
Return

pause::
F7::
  oldclipboard := clipboard
  clipboard := dummytext
  SendInput ^c
  Sleep, 500  
  expression := clipboard
  clipboard := oldclipboard
  if (expression == dummytext)
	expression :=

  PosGui(gui_width, gui_height)					; call the active monitor detection function
  Gui, Show, x%gui_x% y%gui_y% w%gui_width% h%gui_height% , %gui_title%
  DllCall("SetCursorPos", int, gui_cx, int, gui_cy)	; this works better in multi-monitor environments (MouseMove fails)

  GuiControl, Focus, Text
  GuiControl,,Text, %expression%
  SendInput {end}

  if (expression <> "")
	GuiControl, Focus, Source

  if (gui_id == "")
	{
	top_margin = 30
	IE_Init()
	gui_id := WinExist(gui_title)
	pweb := IE_Add(gui_id, browser_margin, browser_margin + top_margin, gui_width - (2 * browser_margin), gui_height - (2 * browser_margin) - top_margin)
	}

  if (expression <> "")
	load_url()

  SetTimer, hidegui, %delay_to_hide%
  gui_visible := true
Return

;________________________________________________
;_________________ SUBROUTINES __________________
hidegui:
  MouseGetPos x, y
  if (x < -hide_distance or x > (gui_width  + hide_distance) or y < -hide_distance or y > (gui_height + hide_distance))
	gosub guihide
Return

textchanged:
  SetTimer, textchanged_idle, 500
Return

textchanged_idle:
  SetTimer, textchanged_idle, off
  GuiControlGet, expression,,text
  if (expression <> "")
	load_url()
Return

wait_for_page_load:
  if (IE_ReadyState(pweb) == 4)
	{
	SetTimer, wait_for_page_load, off
	COM_Invoke(pweb, "document.parentwindow.execscript", "try{" . sources%current_source%_pagefix . "}catch(e){}")
	}
Return

guihide:
  Gui, Hide
  gui_visible := false
  SetTimer, hidegui, off
  SetTimer, wait_for_page_load, off
Return

GuiClose:
  COM_Release(pweb)
  Gui, Destroy
  IE_Term()
Return

SourceChanged:
  SetTimer, sourcechanged_idle, 500
Return

SourceChanged_idle:
  SetTimer, sourcechanged_idle, off
  GuiControlGet, source_name, , source
  Loop, %sources_num%
	{
	if (source_name == sources%a_index%_name)
		{
		current_source := a_index
		break
		}
	}
  load_url()
Return

popout: 
  gosub guihide
  Run % IE_GetUrl(pweb)
Return

;________________________________________________
;__________________ FUNCTIONS ___________________
add_source(name, url, pagefix = "")
{
  global
  sources_num++
  sources%sources_num%_name := name
  sources%sources_num%_url := url
  sources%sources_num%_pagefix := pagefix
}

get_url()
{
  global
  Return sources%current_source%_url . expression
}

load_url()
{
  global
  IE_LoadURL(pweb, get_url())
  if (sources%current_source%_pagefix <> "")
	SetTimer, wait_for_page_load, 100
  else
	SetTimer, wait_for_page_load, off 
}

;________________________________________________
;___________ MULTI-MONITOR DETECTION ____________
PosGui(GW, GH)				; pass GUI size as parameters
{
  Global gui_x, gui_y, gui_cx, gui_cy	; top-left corner and center of the GUI (the latter is used for positioning the mouse)
  WinGetPos, AX, AY, AW, AH, A	; get active window coordinates
  AcenH := AX + AW//2			; get active window horizontal center
  AcenV := AY + AH//2			; get active window vertical center
  SysGet, Tmon, 80				; find total number of monitors
  Loop, %Tmon%
	{
	SysGet, Mon%A_Index%, MonitorWorkArea, %A_Index%										; get working area for monitor %A_Index%
	Mcen%A_Index%H := Mon%A_Index%Left + (Mon%A_Index%Right - Mon%A_Index%Left) // 2		; get monitor horizontal center
	Mcen%A_Index%V := Mon%A_Index%Top + (Mon%A_Index%Bottom - Mon%A_Index%Top) // 2	; get monitor vertical center
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
