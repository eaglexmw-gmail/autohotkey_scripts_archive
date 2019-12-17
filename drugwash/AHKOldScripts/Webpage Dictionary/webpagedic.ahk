#NoEnv

delay_to_appear = 500
delay_to_hide = 10

gui_width = 500
gui_height = 300
browser_margin = 5
mouse_overlap = 5

;----------------------------------------------------------------------

SysGet, Screen, Monitor

gui_id =
gui_visible := false
gui_title := "dummy title because the windows is not found without it for some reason"

sources_num = 0
current_source = 1

add_source("Wikipedia", "http://en.wikipedia.org/wiki/Special:Search?search=", "document.getElementById('column-one').style.display='none';document.getElementById('content').style.marginLeft=0")
add_source("Google Define", "http://www.google.com/search?ie=utf-8&oe=utf-8&hl=en&q=define:", "document.getElementById('header').style.display='none';document.getElementById('tsf').style.display='none';document.getElementById('ssb').style.display='none'")
add_source("IMDb", "http://www.imdb.com/find?s=all&q=", "document.getElementById('nb15').style.display='none'")



coordmode, mouse, screen

Gui, +LastFound  -Caption -SysMenu +Owner
Gui, Color, 66CCFF
Gui, Add, Text, section, Text:
Gui, Add, Edit, ys vText gTextChanged

list =

loop %sources_num%
{
  name := sources%a_index%_name
 
  if (list == "")
    list = %name%
  else
    list = %list%|%name%
}

Gui, Add, DropDownList, ys Choose%current_source% vSource gSourceChanged, %list%

set_delay(delay_to_appear)


checkword:
  if (a_timeidle < delay)
    return
 
  if (gui_visible)
  {
    mousegetpos x, y
   
    if (x < gui_x or x > (gui_x + gui_width) or y < gui_y or y > (gui_y + gui_height))
    {
      gui, hide
      gui_visible := false
      set_delay(delay_to_appear)
      SetTimer wait_for_page_load, off
    }
  }
  Else
  {
    WinGetClass class, A
   
    if (class <> "OpWindow" and class <> "MozillaUIWindowClass")
      return
   
    WinGetTitle title, A
   
    pos := RegExMatch(title, ".*\[(.+)\].*", match)
   
    if (pos == 0)
      return
   
    word := match1
   
    pos := RegExMatch(word, "^FIXME")
   
    if (pos > 0)
      return
   
    mousegetpos x, y
   
    gui_x := x - mouse_overlap
   
    if (gui_x + gui_width > ScreenRight)
      gui_x := x - gui_width + mouse_overlap
   
    gui_y := y - gui_height + mouse_overlap
   
    if (gui_y < ScreenTop)
      gui_y := y - mouse_overlap
   
   
    Gui, Show, x%gui_x% y%gui_y% w%gui_width% h%gui_height% , %gui_title%
   
    guicontrol,,Text, %word%
    guicontrol focus, Text
    sendinput {end}
   
    if (gui_id == "")
    {
      top_margin = 30
     
      IE_Init()
      gui_id := WinExist(gui_title)
      pweb := IE_Add(gui_id, browser_margin, browser_margin + top_margin, gui_width - (2 * browser_margin), gui_height - (2 * browser_margin) - top_margin)
    }
   
    gui_visible := true
    set_delay(delay_to_hide)
   
    load_url()
  }
 
  return
 
 
load_url()
{
  global
 
  IE_LoadURL(pweb, sources%current_source%_url . word)
 
  if (sources%current_source%_pagefix <> "")
    SetTimer wait_for_page_load, 100
  else
    SetTimer wait_for_page_load, off 
}
   

textchanged:
  if (not gui_visible)
    return
 
  settimer textchanged_idle, 500
  return
 
 
textchanged_idle:
  settimer textchanged_idle, off
 
  guicontrolget word,,text
  if (word <> "")
    load_url()
   
  Return 
 
 

wait_for_page_load:
  if (IE_ReadyState(pweb) == 4)
  {
    settimer wait_for_page_load, off
    COM_Invoke(pweb, "document.parentwindow.execscript", sources%current_source%_pagefix)
  }
  return
 
 
GuiClose:
  COM_Release(pweb)
  Gui, Destroy
  IE_Term()
return


set_delay(new_delay)
{
  global delay
  delay := new_delay
  settimer checkword, %delay%

}




SourceChanged:
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



add_source(name, url, pagefix = "")
{
  global
 
  sources_num++
 
  sources%sources_num%_name := name
  sources%sources_num%_url := url
  sources%sources_num%_pagefix := pagefix
}
