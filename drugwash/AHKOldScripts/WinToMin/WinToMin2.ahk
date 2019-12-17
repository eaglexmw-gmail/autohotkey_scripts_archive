#NoEnv
#SingleInstance, Force
#("Suspend"),#("M","Tray", "Icon", "Shell32.dll",44)
timerseconds=0.5|1|2|3|5|8|10|15|20|30|60|120
customwidth=Min|160|320|640|800
customheight=Min|120|240
transparency=145
Width=160
height=27
Updatetimer=0.5
UpdatePicture=60
hModule := DllCall("LoadLibrary", "str", "gdi32.dll"),VarSetCapacity(file,2040),VarSetCapacity(col,2040),#("OE","IfExit")
#("CM", "Mouse", "Relative"),#("SBL",-1),#("SWD",50)
#("G","2:+LastFound"),#hwnd:=WinExist(),#("G","2:-Caption") ;,#("G","2:Show") ;,#("G","2:Hide")
;#("G","+Resize"),#("G","ADD","ListView","r10 w640 h480","PID|ID|CLASS|TITLE|X|Y|W|H|MinMax"),#("___GS", "Updatetimer"),#("G","Show")
Loop,Parse,timerseconds,|
	#("M","Timer","Add",A_LoopField,"Timer") ;,#("M","UpdatePicture","Add",A_LoopField,"UpdatePicture")
Loop 13
	#("M","Transparency","Add",A_Index*20-5,"Transparency")
Loop,Parse, customwidth,|
	#("M","Width","Add",A_LoopField,"Width")
Loop,Parse, customheight,|
	#("M","Height","Add",A_LoopField,"Height")
#("M","howto","Add","Click with right mouse onto min`, max or close symbol of a window","Return"),#("M","howto","Add"),#("M","howto","Add","Instead of Minimize - Minisize will happen","Return"),#("M","howto","Add","Instead of Maximize - AlwaysOnTop will be toggled","Return"),#("M","howto","Add","Instead of Close - Transparency is toggled","Return"),#("M","howto","Add"),#("M","howto","Add","Hotkey LButton && RButton willopen that menu","Return"),#("M","howto","Add","Press and hold left and click 2 x right button to restore all","Return"),#("M","howto","Add","Press and hold left and click 3 x right button to minisize all","Return"),#("M","Tray","Add","Ho&wTo?",":howto"),#("M","Tray","Add"),#("M","Tray","Add","&UpdateWindows (sec)",":Timer"),#("M_Notused at the moment","Tray","Add","U&pdatePicture (sec)",":UpdatePicture"),#("M","Tray","Add","&Transparency (0-255)",":Transparency"),#("M","Tray","Add"),#("M","Tray","Add","&Width in pixel",":Width"),#("M","Tray","Add","&Height in pixel",":Height"),#("M","Tray","Add"),#("M","RapidHotkey","Add","U&se LButton && RButton MultiHotkey","ToggleHotkey"),#("M","Tray","Add","Hot&key",":RapidHotkey"),#("M","Tray","Add"),#("M","Tray","Add","&Minimize all","minall"),#("M","Tray","Add","&Restore All","maxall"),#("M","Tray","Add"),#("M","Tray","Add","&Pause","Stop"),#("M","Tray","Add"),#("M","Tray","Add","Re&load","Reloadapp"),#("M","Tray","Add","&Exit","Leave"),#("M","Tray","NoStandard"),#("GS","ToggleHotkey")
#("M","Width","Check","160"),#("M","height","Check","Min"),#("M","transparency","check","135"),#("M","timer","Check","0.5") ;,#("M","UpdatePicture","Check","5")
#("ST", "Updatetimer", Updatetimer*10000),#("ST","ShowToolTip",2000)
#("Suspend")
Return
Stop:
Suspended:=!suspended,#("Suspend"),#("M","Tray","UnCheck","&Pause"),(suspended ? #("M","Tray","Check","&Pause") :)
Return
Leave:
ExitApp
Return
Reloadapp:
Reload
Return
Width:
Loop,Parse, customwidth,|
	#("M","Width","UnCheck",A_LoopField)
width:=A_ThisMenuItem="Min" ? MinW : A_ThisMenuItem,#("M","width","Check",A_ThisMenuItem)
Return
Height:
Loop,Parse, customheight,|
	#("M","Height","UnCheck",A_LoopField)
height:=A_ThisMenuItem="Min" ? MinH : A_ThisMenuItem,#("M","height","Check",A_ThisMenuItem)
Return
Transparency:
Loop 13
	#("M","Transparency","UnCheck",A_Index*20-5)
transparency:=A_ThisMenuItem,#("M","Transparency","Check",A_ThisMenuItem)
Return
UpdatePicture: ;not used at the moment, Picture is update if window is resized
Loop,Parse,timerseconds,|
	#("M", "UpdatePicture","UnCheck", A_LoopField)
UpdatePicture:=A_ThisMenuItem,#("M","UpdatePicture","check",A_ThisMenuItem)
Timer:
Loop,Parse,timerseconds,|
	#("M", "timer","UnCheck", A_LoopField)
Updatetimer:=A_ThisMenuItem,#("M","timer","check",A_ThisMenuItem)
Return
IfExit:
	Loop, Parse, #_ID, |
		cid:=A_LoopField,(#_w_%cid%_hidden ? #("GS","Max") :),DllCall("gdi32\DeleteDC", UInt,hdc_%cid%_buffer),DllCall("gdi32\DeleteDC", UInt,hdc_%cid%_frame ),DllCall("gdi32\DeleteObject", UInt,hbm_%cid%_buffer),#("WS","Transparent",255,"ahk_id " cid),#("WS","Redraw","","ahk_id " cid)
	DllCall("FreeLibrary", "UInt", hModule)
	ExitApp
Return
RapidHotkey:
RapidHotkey("Showmenu""maxall""minall",1,0.2,1)
return
ToggleHotkey:
hotkey:=!hotkey,#("H", "~LButton & ~RButton","Rapidhotkey",hotkey ? "ON" : "Off")(hotkey ? #("M","Rapidhotkey","Check","U&se LButton && RButton MultiHotkey") : #("M","Rapidhotkey","UnCheck","U&se LButton && RButton MultiHotkey"))
Return
ShowMenu:
Menu, tray, Show
Return
minall:
	#("T","NoTimers")
	Loop,Parse,#_ID,|
		cid:=A_LoopField,(A_LoopField ? (#("GS","Min"),#("WS", "ExStyle", "^0x00000020","ahk_id " cid)) :)
Return
maxall:
	#("T","NoTimers")
	Loop,Parse,#_ID,|
		cid:=A_LoopField,(A_LoopField ? (#("GS","Max"),#("WS", "ExStyle", "-0x00000020","ahk_id " cid)) :)
Return
^F1::ListVars
/*
RButton::
	#("T","NoTimers"),#("MGP", "x","y","cid"),#("WA","ahk_id " cid),#("WWA","ahk_id " cid),#("MGP", "x","y","cid"),#("WGP","","","w","h","ahk_id " cid)
	If (!#_w_%cid%_A or x<0 or y<0 or x<30 or y>28 or (!#_w_%cid%_hidden and (w-x)>#Button_))
		#("C","R","D"),#("KW","RButton"),#("C","R","U"),#("E")
	If (w-x>#Button_)
		#("CM","Mouse","Screen"),h:=(#_w_%cid%_PH * ( width / #_w_%cid%_PW )),#("MGP","x","y"),#("CM","Mouyse","Relative"),#("G","2:+AlwaysOnTop"),#("G","2:Show","x" . x-width/2 . " y" . y . " w" . width . " h" . h ),DllCall("gdi32\StretchBlt", UInt,hdc_%cid%_frame, Int,0, Int,0, Int,width, Int,h, UInt,hdc_%cid%_buffer, Int, 0, Int,0, Int,#_w_%cid%_PW, Int,#_w_%cid%_PH ,UInt,0xCC0020),#("KW","RButton"),#("G","2:-AlwaysOnTop"),#("G","2:Hide")
	else If (w-x>#ButtonM)
		#("C","D"),#("KW","RButton"),#("WS","Disable","","ahk_id " cid),#("C","U"),#("WS","Enable","","ahk_id " cid),(#_w_%cid%_hidden ? #("GS","Max") : #("GS","Min"))
	else if (w-x>#ButtonX)
		#("C","D"),#("KW","RButton"),#("WS","Disable","","ahk_id " cid),#("C","U"),#("WS","Enable","","ahk_id " cid),#("WS","AlwaysOnTop","Toggle","ahk_id " cid)
	Else
		#("C","D"),#("KW","RButton"),#("WS","Disable","","ahk_id " cid),#("C","U"),#("WS","Enable","","ahk_id " cid),(!#_w_%cid%_Trans ? (#("WS","Transparent", transparency,"ahk_id " cid),#_w_%cid%_Trans:=1) : (#("WS","Transparent", 255,"ahk_id " cid),#_w_%cid%_Trans:=""))
Return
*/
$RButton::NCHITTEST()

Min:
	temp:=((#_w_%cid%_A and !#_w_%cid%_hidden) ? ((#_w_%cid%_MinMax!=0 ? #("WR","ahk_id " #_w_%cid%_ID) :),#("WS","AlwaysOnTop","ON","ahk_id " #_w_%cid%_ID),#("WS","Transparent",transparency,"ahk_id " #_w_%cid%_ID),(#_w_%cid%_Trans:=1),(#_w_%cid%_hidden:=1),#("WM","ahk_id " . #_w_%cid%_ID,"",A_ScreenWidth-width,"",width,height),#("WGP","","","#_isW"),(#_isW!=width ? #("WM","ahk_id " . #_w_%cid%_ID,"",A_ScreenWidth-#_isW,"",#_isW,height) :)) :)
Return
Max:
	If (#_w_%cid%_A and #_w_%cid%_hidden)
	#("WS","AlwaysOnTop","OFF","ahk_id " cid),#("WS","Transparent",255,"ahk_id " #_w_%cid%_ID),(#_w_%cid%_Trans:=""),(#_w_%cid%_hidden:=""),#("WM","ahk_id " cid,"",#_w_%cid%_x,#_w_%cid%_y,#_w_%cid%_w,#_w_%cid%_h),#("WS","Redraw","","ahk_id " cid),(#_w_%cid%_MinMax ? #("WMAX","ahk_id " . #_w_%cid%_ID) : (#_w_%cid%_MinMax=-1 ? #("WMIN","ahk_id " cid) :))
Return
Updatetimer:
	#("ST","Updatetimer","OFF"),LV_Delete(),#("SG","ScreenWidth",78),#("SG","ScreenHight",79),#("SG","MinW",28),#("SG","MinH",29),(width<MinW ? width:=MinW :),((height-8)<MinH ? height:=MinH :)
	Loop, Parse, #_PID, |
		#_CLASS_%PID%=
	#_PID:="",#("WG","#_w_","list") ;,LV_Delete()
	Loop % #_w_
	{
		;Get Windows information
		id := #_w_%A_Index%,#("WGC","#_w_" . id . "_class","ahk_id " id)
		If #_w_%id%_class in Progman,tooltips_class32,#32770,#32768,#32771,MsoCommandBarPopup,bosa_sdm_Mso96,Shell_TrayWnd,DV2ControlHost,BaseBar,WorkerW,ShockwaveFlashFullScreen
			Continue
		If (id = #hwnd)
			continue
		If (!#_w_%id%_hidden)
			#_w_%id%_ID:=id,#("WGTT","#_w_" . id . "_title","ahk_id " id),#("WGP","#_w_" . id . "_x","#_w_" . id . "_y","#_w_" . id . "_w","#_w_" . id . "_h","ahk_id " id),#("WG","#_w_" . id . "_MinMax","MinMax","ahk_id " . id),#("WG","#_w_" . id . "_PID","PID","ahk_id " . id),(#_w_%id%_MinMax=1 ? (#_w_%id%_W:=ScreenWidth,#_w_%id%_H:=ScreenHeight) :)
		If !#_w_%id%_Title
			continue
		#_w_%id%_A:=1,(#_w_%id%_H<MinH ? #("WM","ahk_id " id,"","","","",(#_w_%id%_H:=A_ScreenHeight)) :)
		,(!InStr(#_ID,"|" . id) ? (#_ID .= "|" . id) :)
		pid:=#_w_%id%_PID,(!InStr(#_CLASS_%PID%,"|" . #_w_%id%_Class) ? (#_CLASS_%pid% .= "|" . #_w_%id%_Class) :),(!InStr(#_PID, "|" . pid) ? (#_PID.="|" . pid) :)
		If ((!#_w_%id%_hidden and #_w_%id%_H!=height and #_w_%cid%_MinMax!=-1 and ((#_w_%id%_PW . #_w_%id%_PH=""))) or (#_w_%id%_PW!=#_w_%id%_W or #_w_%id%_PH!=#_w_%id%_H) and #_w_%cid%_MinMax!=-1)
			Gosub, pic
		;LV_Add("",#_w_%id%_PID,#_w_%id%_ID,#_w_%id%_Class,#_w_%id%_Title,#_w_%id%_x,#_w_%id%_y,#_w_%id%_w,#_w_%id%_h,#_w_%id%_MinMax)
	}
	#("ST","Updatetimer",Updatetimer*1000)
	;LV_ModifyCol()
Return
pic:
	DllCall("gdi32\DeleteDC", UInt,hdc_%id%_buffer),DllCall("gdi32\DeleteDC", UInt,hdc_%id%_frame ),DllCall("gdi32\DeleteObject", UInt,hbm_%id%_buffer)
	hdc_%id%_frame := DllCall( "GetDC", UInt, #hwnd )
	hdc_%id%_buffer := DllCall("gdi32\CreateCompatibleDC", UInt,  hdc_%id%_frame)  ; buffer
	hbm_%id%_buffer := DllCall("gdi32\CreateCompatibleBitmap", UInt,hdc_%id%_frame, Int,A_ScreenWidth, Int,A_ScreenHeight)
	DllCall( "gdi32\SelectObject", UInt,hdc_%id%_buffer, UInt,hbm_%id%_buffer)
	; comment this line for speed but less quality
	DllCall( "gdi32\SetStretchBltMode", "uint", hdc_%id%_frame, "int", 4 )  ; Halftone better quality with stretch
	Sleep, 100
	DllCall("PrintWindow", UInt,id, UInt,hdc_%id%_buffer, UInt,0)
	h:=Round(#_w_%id%_H * ( width / #_w_%id%_W ))
	DllCall("gdi32\StretchBlt", UInt,hdc_%id%_frame, Int,0, Int,0, Int,width, Int,h, UInt,hdc_%id%_buffer, Int, 0, Int,0, Int,#_w_%id%_W, Int,#_w_%id%_H ,UInt,0xCC0020)
	;#("TT",#_w_%id%_class),#("S",500)
	#_w_%id%_P:=A_TickCount,#_w_%id%_PW := #_w_%id%_W,#_w_%id%_PH := #_w_%id%_H,#("WS","Transparent",255,"ahk_id " id),#("WS","Redraw","","ahk_id " id)
Return
GuiClose:
ExitApp

ShowToolTip:
	Thread, NoTimers
	CoordMode, Mouse, Screen
    MouseGetPos, x, y, hwnd
	IfNotInString, #_ID, |%hwnd%
		Return
    SendMessage, 0x84, 0, (x&0xFFFF) | (y&0xFFFF) << 16,, ahk_id %hwnd%
    RegExMatch("ERROR TRANSPARENT NOWHERE CLIENT CAPTION SYSMENU SIZE MENU HSCROLL VSCROLL MINBUTTON MAXBUTTON LEFT RIGHT TOP TOPLEFT TOPRIGHT BOTTOM BOTTOMLEFT BOTTOMRIGHT BORDER OBJECT CLOSE HELP", "(?:\w+\s+){" . ErrorLevel+2&0xFFFFFFFF . "}(?<AREA>\w+\b)", HT)
    ;if GetKeyState("Alt") reserved for winmove in dual monitor environment 
    ;if GetKeyState("Shift") reserved
    ;if GetKeyState("LWin") reserved
	;WinGetTitle	output,ahk_id %hwnd%
	;ToolTip % output
	#("MGP", "x","y","cid"),#("WGP","","","w","h","ahk_id " cid)
    if htarea in CLIENT,SYSMENU,HSCROLL,VSCROLL,OBJECT,HELP,ERROR,TRANSPARENT,NOWHERE
        Return
    else if (GetKeyState("CTRL") && htarea="CLOSE"){
        Return
    }
    else if (htarea="CLOSE"){
        ToolTip(#_w_%cid%_Trans ? "Transparency : On" : "Transparency : Off",2500)
    } else if (htarea="MAXBUTTON"){
        WinGet, aVal, ExStyle, ahk_id %hwnd%
        ToolTip((aVal & 0x8) ? "Always On Top : On" : "Always On Top : Off",2500)
	} else if (htarea="MINBUTTON")
		ToolTip(#_w_%cid%_hidden ? "Restore" : "MiniSize",2500)
	CoordMode, Mouse, Relative
Return

NCHITTEST(){
	global
	Thread, NoTimers
	CoordMode, Mouse, Screen
	Loop,Parse,#_ID,|
		cid:=A_LoopField,(cid ? (#("WS", "ExStyle", "-0x00000020","ahk_id " cid)) :)
    MouseGetPos, x, y, cid
	IfNotInString, #_ID, |%cid%
		#("C","R","D"),#("KW","RButton"),#("C","R","U"),#("E")
	WinActivate, ahk_id %cid%
    SendMessage, 0x84, 0, (x&0xFFFF) | (y&0xFFFF) << 16,, ahk_id %cid%
    RegExMatch("ERROR TRANSPARENT NOWHERE CLIENT CAPTION SYSMENU SIZE MENU HSCROLL VSCROLL MINBUTTON MAXBUTTON LEFT RIGHT TOP TOPLEFT TOPRIGHT BOTTOM BOTTOMLEFT BOTTOMRIGHT BORDER OBJECT CLOSE HELP", "(?:\w+\s+){" . ErrorLevel+2&0xFFFFFFFF . "}(?<AREA>\w+\b)", HT)
    ;if GetKeyState("Alt") reserved for winmove in dual monitor environment 
    ;if GetKeyState("Shift") reserved
    ;if GetKeyState("LWin") reserved
	;ToolTip % htarea
    if htarea in CLIENT,SYSMENU,HSCROLL,VSCROLL,OBJECT,HELP,ERROR,TRANSPARENT,NOWHERE
	{
		if #_w_%cid%_hidden
			h:=(#_w_%cid%_PH * ( width / #_w_%cid%_PW )),#("MGP","x","y"),#("CM","Mouyse","Relative"),#("G","2:+AlwaysOnTop"),#("G","2:Show","x" . x-width/2 . " y" . y+5 . " w" . width . " h" . h ),DllCall("gdi32\StretchBlt", UInt,hdc_%cid%_frame, Int,0, Int,0, Int,width, Int,h, UInt,hdc_%cid%_buffer, Int, 0, Int,0, Int,#_w_%cid%_PW, Int,#_w_%cid%_PH ,UInt,0xCC0020),#("KW","RButton"),#("G","2:-AlwaysOnTop"),#("G","2:Hide")
		else
			#("C","R","D"),#("KW","RButton"),#("C","R","U")
	}
	#("WGP","wx","wy","w","h","ahk_id " cid),#("MGP","x","y","cid")
    If (htarea="CLOSE"){
        #("C","D"),#("KW","RButton"),#("WS","Disable","","ahk_id " cid),#("C","U"),#("WS","Enable","","ahk_id " cid),ToolTip(#_w_%cid%_Trans ? "Transparency : Off" : "Transparency : On"),(!#_w_%cid%_Trans ? (#("WS","Transparent", transparency,"ahk_id " cid),#_w_%cid%_Trans:=1,#("WS", "ExStyle", "^0x00000020","ahk_id " cid),#("WS","AlwaysOnTop","ON","ahk_id " cid)) : (#("WS","Transparent", 255,"ahk_id " cid),#_w_%cid%_Trans:="",#("WS", "ExStyle", "-0x00000020","ahk_id " cid)))
	} else if (htarea="MAXBUTTON"){
		#("C","D"),#("KW","RButton"),#("WS","Disable","","ahk_id " cid),#("C","U"),#("WS","Enable","","ahk_id " cid)
        WinGet, aVal, ExStyle, ahk_id %cid%
        WinSet, AlwaysOnTop, % (aVal & 0x8) ? "Off" : "On", ahk_id %cid%
        ToolTip((aVal & 0x8) ? "Always On Top : Off" : "Always On Top : On")
	} else if (htarea="MINBUTTON")
		#("C","D"),#("KW","RButton"),#("WS","Disable","","ahk_id " cid),#("C","U"),#("WS","Enable","","ahk_id " cid),(#_w_%cid%_hidden ? #("GS","Max") : #("GS","Min"))
	else if htarea = SYSMENU
		#("C","R","D"),#("KW","RButton"),#("C","R","U")
    else if #_w_%cid%_hidden
	{
		#("CM","Mouse","Screen"),h:=(#_w_%cid%_PH * ( width / #_w_%cid%_PW )),#("MGP","x","y"),#("CM","Mouyse","Relative"),#("G","2:+AlwaysOnTop"),#("G","2:Show","x" . x-width/2 . " y" . y+5 . " w" . width . " h" . h ),DllCall("gdi32\StretchBlt", UInt,hdc_%cid%_frame, Int,0, Int,0, Int,width, Int,h, UInt,hdc_%cid%_buffer, Int, 0, Int,0, Int,#_w_%cid%_PW, Int,#_w_%cid%_PH ,UInt,0xCC0020)
		Loop
			If (!GetKeyState("RButton","P") or (#("MGP","cx","cy"),((cx!=x and cy!=y) ? (#("WM","ahk_id " cid,"",cx-(x-wx),cy-(y-wy)),#("G","2:Show","x" . cx-width/2 . " y" . cy+5 . " w" . width . " h" . h )) :)))
				break
	}
	Else
		#("C","R","D"),#("KW","RButton"),#("C","R","U")
	Loop,Parse,#_ID,|
		win:=A_LoopField,(#_w_%win%_hidden ? (#("WS", "ExStyle", "^0x00000020","ahk_id " win)) :)
	#("G","2:-AlwaysOnTop"),#("G","2:Hide")
	CoordMode, Mouse, Relative
	#("ST","ShowToolTip",2000)
	/*
    else if (GetKeyState("CTRL") && htarea="TOPLEFT")
        SizeWin(hwnd, "LTOP")
    else if (htarea="TOPLEFT")
        MoveWin(hwnd)
    else if (GetKeyState("CTRL") && htarea="TOP")
        SizeWin(hwnd, "TOP")
    else if (htarea="TOP")
        MoveWin(hwnd, "U")
    else if (GetKeyState("CTRL") && htarea="TOPRIGHT")
        SizeWin(hwnd, "RTOP")
    else if (htarea="TOPRIGHT")
        MoveWin(hwnd, "RU")
    else if (GetKeyState("CTRL") && htarea="RIGHT")
        SizeWin(hwnd, "RIGHT")
    else if (htarea="RIGHT")
        MoveWin(hwnd, "R")
    else if (GetKeyState("CTRL") && (htarea="BOTTOMRIGHT" || A_Cursor="SizeNWSE"))
        SizeWin(hwnd, "RBOTTOM")
    else if (htarea="BOTTOMRIGHT" || A_Cursor="SizeNWSE")
        MoveWin(hwnd, "RB")
    else if (GetKeyState("CTRL") && htarea="BOTTOM")
        SizeWin(hwnd, "BOTTOM")
    else if (htarea="BOTTOM")
        MoveWin(hwnd, "B")
    else if (GetKeyState("CTRL") && htarea="BOTTOMLEFT")
        SizeWin(hwnd, "LBOTTOM")
    else if (htarea="BOTTOMLEFT")
        MoveWin(hwnd, "LB")
    else if (GetKeyState("CTRL") && htarea="LEFT")
        SizeWin(hwnd, "LEFT")
    else if (htarea="LEFT")
        MoveWin(hwnd, "L")
    else if (GetKeyState("CTRL") && htarea="MENU"){
        WinGet, MMState, MinMax, ahk_id %hwnd%
        if MMState=1
            WinRestore, ahk_id %hwnd%
        SizeWin(hwnd, "CENTER")
    } else if (htarea="MENU"){
        WinGet, MMState, MinMax, ahk_id %hwnd%
        if MMState=1
            WinRestore, ahk_id %hwnd%
        MoveWin(hwnd, "Center")
	}
	*/
}

ToolTip(S, Seconds=2000, X="", Y="") {
    SetTimer, Off, %Seconds%
    ToolTip, %S%, %X%, %Y%
    Return
    
    Off:
    ToolTip
    SetTimer, Off, Off
    Return
}

#(p1,p2="",p3="",p4="",p5="",p6="",p7="",p8="",p9="",p10="",p11="",p12="",p13="",p14="",p15="",p16="",p17="",p18="",p19="",p20=""){
	global
	local t, ifcount, loopcount, out, p0,count
	If IsLabel(p1)
		GoTo % p1
	else
		Return "`tCheck Syntax:" . "`t" . p1 . "," . p2 . "," . p3 . "," . p4 . "," . p5 . "," . p6 . "," . p7
				. "," . p8 . "," . p9 . "," . p10 . "," . p11 . "," . p12 . "," . p13 . "," . p14 . "," . p15 . "," . p16
				. "," . p17 . "," . p18 . "," . p19 . "," . p20 "`n"
	Return
	Return: ;enter return value for debuging
	Return  ;A_Tab . "ErrorLevel: " . Errorlevel . "`t" . p1 . "," . p2 . "," . p3 . "," . p4 . "," . p5 . "," . p6 . "," . p7 . "," . p8 . "," . p9 . "," . p10 . "," . p11 . "," . p12 . "," . p13 . "," . p14 . "," . p15 . "," . p16 . "," . p17 . "," . p18 . "," . p19 . "," . p20 "`n"
	AT:
	AutoTrim:
	  AutoTrim, %p2%
	Goto, Return
	BI:
	BlockInput:
		BlockInput, %p2%
	Goto, Return
	C:
	Click:
		Click %p2%, %p3%, %p4%
	Goto, Return
	CW:
	ClipWait:
	  ClipWait, %p2%, %p3%
	Goto, Return
	CTRL:
	Control:
	  Control, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	CC:
	ControlClick:
	  ControlClick, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	CF:
	ControlFocus:
	  ControlFocus, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	CG:
	ControlGet:
	  ControlGet, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	CGF:
	ControlGetFocus:
	  ControlGetFocus, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	CGP:
	ControlGetPos:
		ControlGetPos, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%, %p10%
Goto, Return
	CMO:
	ControlMove:
		ControlMove, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%, %p10%
	Goto, Return
	CGT:
	ControlGetText:
	  ControlGetText, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	CS:
	ControlSend:
	  ControlSend, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	CSR:
	ControlSendRaw:
	  ControlSendRaw, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	CST:
	ControlSetText:
	  ControlSetText, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	CM:
	CoordMode:
	  CoordMode, %p2%, %p3%
Goto, Return
	CR:
	Critical:
		Critical, %p2%
Goto, Return
	DHT:
	DetectHiddenText:
	  DetectHiddenText, %p2%
	Goto, Return
	DHW:
	DetectHiddenWindows:
	  DetectHiddenWindows, %p2%
	Goto, Return
	D:
	Drive:
	  Drive, %p2%, %p3%, %p4%
	Goto, Return
	DG:
	DriveGet:
	  DriveGet, %p2%, %p3%,%p4%
	Goto, Return
	DSF:
	DriveSpaceFree:
		DriveSpaceFree, %p2%, %p3%
	Goto, Return
	ES:
	EnvSet:
	  EnvSet, %p2%, %p3%
	Goto, Return
	EG:
	EnvGet:
	  EnvGet, %p2%, %p3%
	Goto, Return
	EU:
	EnvUpdate:
	  EnvUpdate
	Goto, Return
	ESU:
	EnvSub:
	  EnvSub, %p2%, %p3%
	Goto, Return
	EA:
	EnvAdd:
	  EnvAdd, %p2%, %p3%
	Goto, Return
	ED:
	EnvDiv:
	  EnvDiv, %p2%, %p3%
	Goto, Return
	EM:
	EnvMult:
	  EnvMult, %p2%, %p3%
	Goto, Return
	E:
	Exit:
	  Exit, %p2%
	Goto, Return
	EAP:
	ExitApp:
	  ExitApp
	Goto, Return
	FA:
	FileAppend:
	  FileAppend, %p2%, %p3%
	Goto, Return
	FC:
	FileCopy:
	  FileCopy, %p2%, %p3%, %p4%
	Goto, Return
	FCD:
	FileCopyDir:
	  FileCopyDir, %p2%, %p3%, %p4%
	Goto, Return
	FCDIR:
	FileCreateDir:
	  FileCreateDir, %p2%
	Goto, Return
	FCS:
	FileCreateShortcut:
		FileCreateShortcut, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%, %p10%
	Goto, Return
	FD:
	FileDelete:
	  FileDelete, %p2%
	Goto, Return
	FGA:
	FileGetAttrib:
	  FileGetAttrib, %p2%, %p3%
	Goto, Return
	FGS:
	FileGetSize:
	  FileGetSize, %p2%, %p3%, %p4%
	Goto, Return
	FGSH:
	FileGetShortcut:
		p3:=!p3 ? "t" : p3,p4:=!p4 ? "t" : p4,p5:=!p5 ? "t" : p5,p6:=!p6 ? "t" : p6,p7:=!p7 ? "t" : p7,p8:=!p8 ? "t" : p8,p9:=!p9 ? "t" : p9
		FileGetShortcut, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	FGT:
	FileGetTime:
	  FileGetTime, %p2%, %p3%, %p3%
	Goto, Return
	FGV:
	FileGetVersion:
		FileGetVersion, %p2%, %p3%
	Goto, Return
	FM:
	FileMove:
	  FileMove, %p2%, %p3%, %p4%
	Goto, Return
	FMD:
	FileMoveDir:
	  FileMoveDir, %p2%, %p3%, %p4%
	Goto, Return
	FR:
	FileRead:
	  FileRead, %p2%, %p3%
	Goto, Return
	FRL:
	FileReadLine:
	  FileReadLine, %p2%, %p3%, %p4%
	Goto, Return
	FRC:
	FileRecycle:
		FileRecycle, %p2%
	Goto, Return
	FRE:
	FileRecycleEmpty:
		FileRecycleEmpty, %p2%
	Goto, Return
	FRD:
	FileRemoveDir:
		FileRemoveDir, %p2%, %p3%
	Goto, Return
	FSF:
	FileSelectFile:
	  FileSelectFile, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	FSD:
	FileSelectFolder:
	  FileSelectFolder, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	FSA:
	FileSetAttrib:
	  FileSetAttrib, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	FST:
	FileSetTime:
	  FileSetTime, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	FT:
	FormatTime:
	  FormatTime, %p2%, %p3%, %p4%
	Goto, Return
	GKS:
	GetKeyState:
		GetKeyState, %p2%, %p3%, %p4%
	Goto, Return
	GA:
	GroupActivate:
	  GroupActivate, %p2%, %p3%
	Goto, Return
	GADD:
	GroupAdd:
	  GroupAdd, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	GCL:
	GroupClose:
	  GroupClose, %p2%, %p3%
	Goto, Return
	H:
	Hotkey:
		Hotkey, %p2%, %p3%, %p4%
	Goto, Return
	GS:
	GoSub:
		GoSub, %p2%
	Goto, Return
	GT:
	GoTo:
		Goto, %p2%
	Goto, Return
	IMB:
	IfMsgBox:
	IfMsgBox, %p2%
	{
		count = 3
		Loop 18
		{
			p%A_Index% := p%count%
			count++
		}
		If IsLabel(p1)
			GoSub, %p1%
	}
	Goto, Return
	IEQ:
	INEQ:
	IG:
	IGOE:
	IL:
	ILOE:
	IIS:
	INIS:
	IWA:
	IWNA:
	IWE:
	IWNE:
	IE:
	INE:
	IfEqual:
	IfNotEqual:
	IfGreater:
	IfGreaterOrEqual:
	IfLess:
	IfLessOrEqual:
	IfInString:
	IfNotInString:
	IfWinActive:
	IfWinNotActive:
	IfWinExist:
	IfWinNotExist:
	IfExist:
	IfNotExist:
	{
	loopcount=
	If (p1 = "IfEqual" || p1 = "IEQ")
	{
		IfEqual, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfNotEqual" || p1 = "INEQ")
	{
		IfNotEqual, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfLess" || p1 = "IL")
	{
		IfLess, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfLessOrEqual" || p1 = "ILOE")
	{
		IfLessOrEqual, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfGreater" || p1 = "IG")
	{
		IfGreater, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfGreaterOrEqual" || p1 = "IGOE")
	{
		IfGreaterOrEqual, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfInString" || p1 = "IIS")
	{
		IfInString, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfNotInString" || p1 = "INIS")
	{
		IfNotInString, %p2%, %p3%
		{
			ifcount=4
			loopcount=17
			out = %p4%
			p0 -= 3
		}
		else
			Goto, Return
	}
	If (p1 = "IfWinActive" || p1 = "IWA")
	{
		IfWinActive, %p2%, %p3%, %p4%, %p5%
		{
			ifcount=6
			loopcount=15
			out = %p6%
			p0 -= 5
		}
		else
			Goto, Return
	}
	If (p1 = "IfWinNotActive" || p1 = "IWNA")
	{
		IfWinNotActive, %p2%, %p3%, %p4%, %p5%
		{
			ifcount=6
			loopcount=15
			out = %p6%
			p0 -= 5
		}
		else
			Goto, Return
	}
	If (p1 = "IfWinExist" || p1 = "IWE")
	{
		IfWinExist, %p2%, %p3%, %p4%, %p5%
		{
			ifcount=6
			loopcount=15
			out = %p6%
			p0 -= 5
		}
		else
			Goto, Return
	}
	If (p1 = "IfWinNotExist" || p1 = "IWNE")
	{
		IfWinNotExist, %p2%, %p3%, %p4%, %p5%
		{
			ifcount=6
			loopcount=15
			out = %p6%
			p0 -= 5
		}
		else
			Goto, Return
	}
	If (p1 = "IfExist" || p1 = "IE")
	{
		IfExist, %p2%
		{
			ifcount=3
			loopcount=18
			out = %p3%
			p0 -= 2
		}
		else
			Goto, Return
	}
	If (p1 = "IfNotExist" || p1 = "INE")
	{
		IfNotExist, %p2%
		{
			ifcount=3
			loopcount=18
			out = %p3%
			p0 -= 2
		}
		else
			Goto, Return
	}
	Loop %loopcount%
	{
		p%A_Index% := p%ifcount%
		ifcount++
	}
	out =
	If loopcount =
		Goto, Return
	IsLabel(p1)
			GoSub, %p1%
	loopcount=
	Goto, Return
	}
	KW:
	KeyWait:
	  KeyWait, %p2%, %p3%
	Goto, Return
	M:
	Menu:
	  Menu, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	MC:
	MouseClick:
	  MouseClick, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%
	Goto, Return
	MCD:
	MouseClickDrag:
	  MouseClickDrag, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%
	Goto, Return
	MGP:
	MouseGetPos:
		p2:=!p2 ? "t" : p2,p3:=!p3 ? "t" : p3,p4:=!p4 ? "t" : p4,p5:=!p5 ? "t" : p5
		MouseGetPos, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	MM:
	MouseMove:
	  MouseMove, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	MB:
	MsgBox:
		checkifmsgboxfull := p3 p4 p5
		IfNotEqual, checkifmsgboxfull, , SetEnv, checkifmsgboxfull, 1
		If p2 is digit
		{
			If checkifmsgboxfull = 1 
			{
					;MsgBox % p2
					If p2 < 1
						MsgBox, 0, %p3%, %p4%, %p5%
					else if p2 = 1
					{
						MsgBox, 1, %p3%, %p4%, %p5%
					}
					else if p2 = 2
					{
						MsgBox, 2, %p3%, %p4%, %p5%
					}
					else if p2 = 3
					{
						MsgBox, 3, %p3%, %p4%, %p5%
					}
					else if p2 = 4
					{
						MsgBox, 4, %p3%, %p4%, %p5%
					}
					else if p2 = 5
					{
						MsgBox, 5, %p3%, %p4%, %p5%
					}
					else if p2 = 6
					{
						MsgBox, 6, %p3%, %p4%, %p5%
					}
					else if p2 = 262144
					{
						MsgBox, 262144, %p3%, %p4%, %p5%
					}
					else if p2 = 262145
					{
						MsgBox, 262145, %p3%, %p4%, %p5%
					}
					else if p2 = 262146
					{
						MsgBox, 262146, %p3%, %p4%, %p5%
					}
					else if p2 = 262147
					{
						MsgBox, 262147, %p3%, %p4%, %p5%
					}
					else if p2 = 262148
					{
						MsgBox, 262148, %p3%, %p4%, %p5%
					}
					else if p2 = 262149
					{
						MsgBox, 262149, %p3%, %p4%, %p5%
					}
					else if p2 = 262150
					{
						MsgBox, 262150, %p3%, %p4%, %p5%
					}
			}
			else
			{
				MsgBox, %p2% %p3% %p4% %p5% %p6% %p7% %p8% %p9% %p10% %p11% %p12% %p13% %p14% %p15% %p16% %p17% %p18% %p19% %p20%
			}
		}
		else
	  {
		MsgBox, %p2% %p3% %p4% %p5% %p6% %p7% %p8% %p9% %p10% %p11% %p12% %p13% %p14% %p15% %p16% %p17% %p18% %p19% %p20%
	  }
	Goto, Return
	OE:
	OnExit:
	  OnExit, %p2%
	Goto, Return
	PGC:
	PixelGetColor:
	  PixelGetColor, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	PS:
	PixelSearch:
	  PixelSearch, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%, %p10%
	Goto, Return
	PWC:
	PixelWaitColor:  ;(ByRef p2, ByRef p3, p_x1, p_y1, p_x2, p_y2, p_color, p_shades="", p_opts="", p_waitms=0, p_checkinterval="")
	{
		if (RegExMatch(p8, "i)^[0-9a-f]{6}$"))
			p8:="0x" p8
		p8_bkp:=p8
		p8:=RegExReplace(p8, "i)\bSlow\b")
		if (p8=p8_bkp)
			p8:=p8 " Fast"
		p8_bkp:=p8
		p8:=RegExReplace(p8, "i)\bBGR\b")
		if (p8=p8_bkp)
			p8:=p8 " RGB"
		if (p12="")
			p12=519
		ts:=A_TickCount
		Loop 
		{
			PixelSearch, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%, %p10%
			if (errorlevel=0 || p11 && A_TickCount-ts>=p11)
				break
			if (p11 && (A_TickCount-ts)+p12>=p11)
				p12:=(p11-(A_TickCount-ts))/2
			if (p12>19)
				Sleep, %p12%
		}
		Goto, Return
	}
	PR:
	Process:
	  Process, %p2%, %p3%, %p4%
	Goto, Return
	R:
	Run:
	  p5:=!p5 ? "t" : p5
	  Run, %p2%, %p3%, %p4%,%p5%
	Goto, Return
	RA:
	RunAs:
		If p2 =
			RunAs
		else
			RunAs, %p2%, %p3%, %p4%
	Goto, Return
	RW:
	RunWait:
		p5:=!p5 ? "t" : p5
		RunWait, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	SN:
	Send:
	  Send, %p2%
	Goto, Return
	SP:
	SendPlay:
		SendPlay, %p2%
	Goto, Return
	SI:
	SendInput:
		SendInput, %p2%
	Goto, Return
	SRAW:
	SendRaw:
		SendRaw, %p2%
	Goto, Return
	SEV:
	SendEvent:
		SendEvent, %p2%
	Goto, Return
	RND:
	Random:
	  Random, %p2%, %p3%, %p4%
	Goto, Return
	SE:
	SetEnv:
	  SetEnv, %p2%, %p3%
	Goto, Return
	SF:
	SetFormat:
		SetFormat, %p2%, %p3%
	Goto, Return
	SMOD:
	SendMode:
	  SendMode, %p2%
	Goto, Return
	SKD:
	SetKeyDelay:
	  SetKeyDelay, %p2%, %p3%, %p4%
	Goto, Return
	SMD:
	SetMouseDelay:
	  SetMouseDelay, %p2%, %p3%
	Goto, Return
	STMM:
	SetTitleMatchMode:
	  SetTitleMatchMode, %p2%
	Goto, Return
	SWD:
	SetWinDelay:
	  SetWinDelay, %p2%
	Goto, Return
	SD:
	Shutdown:
	  Shutdown, %p2%
	Goto, Return
	S:
	Sleep:
	  Sleep, %p2%
	Goto, Return
	SO:
	Sort:
	  Sort, %p2%, %p3%
	  If p3 = U
	Goto, Return
	SPP:
	SplitPath:
	  p3:=!p3 ? "t" : p3,p4:=!p4 ? "t" : p4,p5:=!p5 ? "t" : p5,p6:=!p6 ? "t" : p6,p7:=!p7 ? "t" : p7
	  SplitPath, %p2%,%p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	SBGT:
	StatusBarGetText:
	  StatusBarGetText, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	SBW:
	StatusBarWait:
	  StatusBarWait, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	SCS:
	StringCaseSense:
	  StringCaseSense, %p2%
	Goto, Return
	SGP:
	StringGetPos:
	  StringGetPos, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	SL:
	StringLeft:
	  StringLeft, %p2%, %p3%, %p4%
	Goto, Return
	SLEN:
	StringLen:
	  StringLen, %p2%, %p3%
	Goto, Return
	SLOW:
	StringLower:
	  StringLower, %p2%, %p3%, %p4%
	Goto, Return
	SM:
	StringMid:
	  StringMid, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	SRPL:
	StringReplace:
	  StringReplace, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	SR:
	StringRight:
	  StringRight, %p2%, %p3%, %p4%
	Goto, Return
	SS:
	StringSplit:
	  StringSplit, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	STL:
	StringTrimLeft:
	  StringTrimLeft, %p2%, %p3%, %p4%
	Goto, Return
	STR:
	StringTrimRight:
	  StringTrimRight, %p2%, %p3%, %p4%
	Goto, Return
	SUP:
	StringUpper:
	  StringUpper, %p2%, %p3%, %p4%
	Goto, Return
	SG:
	SysGet:
	  SysGet, %p2%, %p3%, %p4%
	Goto, Return
	TT:
	ToolTip:
	  ToolTip, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	TRT:
	TrayTip:
	  TrayTip, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	TR:
	Transform:
	  Transform, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	UDTF:
	UrlDownloadToFile:
	  UrlDownloadToFile, %p2%, %p3%
	Goto, Return
	VSC:
	VarSetCapacity:
		VarSetCapacity(%p2%, p3, p4)
	Goto, Return
	WA:
	WinActivate:
	  WinActivate, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	WAB:
	WinActivateBottom:
	  WinActivateBottom, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	WC:
	WinClose:
	  WinClose, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WGAT:
	WinGetActiveTitle:
	  WinGetActiveTitle, %p2%
	Goto, Return
	WGC:
	WinGetClass:
	  WinGetClass, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WG:
	WinGet:
	  WinGet, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WGP:
	WinGetPos:
	  p2:=!p2 ? "t" : p2,p3:=!p3 ? "t" : p3,p4:=!p4 ? "t" : p4,p5:=!p5 ? "t" : p5
	  WinGetPos, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	WGT:
	WinGetText:
	  WinGetText, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WGTT:
	WinGetTitle:
	  WinGetTitle, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WH:
	WinHide:
	  WinHide, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	WK:
	WinKill:
	  WinKill, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WMSI:
	WinMenuSelectItem:
	  WinMenuSelectItem, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%, %p10%, %p11%, %p12%
	Goto, Return
	WM:
	WinMove:
	  WinMove, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	WSH:
	WinShow:
	  WinShow, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	WS:
	WinSet:
	  WinSet, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	  If (p2 = "Style" or p2 = "Exstyle" or p2 = Polygon)
	Goto, Return
	WST:
	WinSetTitle:
	  WinSetTitle, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WW:
	WinWait:
	  WinWait, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WWA:
	WinWaitActive:
	  WinWaitActive, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WWC:
	WinWaitClose:
	  WinWaitClose, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WWNA:
	WinWaitNotActive:
	  WinWaitNotActive, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WMAX:
	WinMaximize:
	  WinMaximize, %p2%, %p3%, %p4%
	Goto, Return
	WMIN:
	WinMinimize:
	  WinMinimize, %p2%, %p3%, %p4%
	Goto, Return
	WR:
	WinRestore:
	  WinRestore, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	IS:
	ImageSearch:
	  ImageSearch, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%
	Goto, Return
	ID:
	IniDelete:
	  IniDelete, %p2%, %p3%, %p4%
	Goto, Return
	IR:
	IniRead:
	  IniRead, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	IW:
	IniWrite:
	  IniWrite, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	I:
	Input:
	  If p2
		Input, %p2%, %p3%, %p4%, %p5%
	  else
		Input
	Goto, Return
	IB:
	InputBox:
	  InputBox, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%, , %p11%, %p12%
	Goto, Return
	G:
	Gui:
		Gui, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	GD:
	GroupDeactivate:
		GroupDeactivate, %p2%, %p3%
	Goto, Return
	GC:
	GuiControl:
		GuiControl, %p2%, %p3%, %p4%
	Goto, Return
	GuiControlGet:
		GuiControlGet, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	If:
		If p3 = is
		{
			If (%p2% is %p4%)
			{
				GoTo, RunCommand
			}
		}
		else if p3 = is not
		{
			If (%p2% is not %p4%)
			{
				GoTo, RunCommand
			}
		}
		else If p3 = <
		{
			If (%p2% < %p4%)
			{
				GoTo, RunCommand
			}
		}
		else If p3 = =
		{
			If (%p2% = %p4%)
			{
				GoTo, RunCommand
			}
		}
		else If p3 = >
		{
			If %p2% > %p4%
			{
				GoTo, RunCommand
			}
		}
	Goto, Return
	RunCommand:
		count = 5
		Loop 16
		{
			p%A_Index% := p%count%
			count++
		}
		If IsLabel(p1)
			GoTo, %p1%
	Goto, Return
	KH:
	KeyHistory:
		KeyHistory
	Goto, Return
	LH:
	ListHotkeys:
		ListHotkeys
	Goto, Return
	LV:
	ListVars:
		ListVars
	Goto, Return
	OD:
	OutputDebug:
		OutputDebug, %p2%
	Goto, Return
	P:
	Pause:
		Pause, %p2%, %p3%
	Goto, Return
	PM:
	PostMessage:
		PostMessage, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	SMSG:
	SendMessage:
		SendMessage, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%, %p8%, %p9%
	Goto, Return
	PRG:
	Progress:
		Progress, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	SIM:
	SplashImage:
		SplashImage, %p2%, %p3%, %p4%, %p5%, %p6%, %p7%
	Goto, Return
	RD:
	RegDelete:
		Regdelete, %p2%, %p3%, %p4%
	Goto, Return
	REM:
	RegExMatch:
		RegExMatch(%p2%, %p3%, %p4%, %p5%)
	Goto, Return
	RER:
	RegExReplace:
		RegExReplace(%p2%, %p3%, %p4%, %p5%, %p6%, %p7%)
	Goto, Return
	RC:
	RegisterCallback:
		RegisterCallback(%p2%, %p3%, %p4%, %p5%)
	Goto, Return
	RR:
	RegRead:
		RegRead, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	RWR:
	RegWrite:
		RegWrite, %p2%, %p3%, %p4%, %p5%, %p6%^
	Goto, Return
	RL:
	Reload:
		Reload
	Goto, Return
	SBL:
	SetBatchLines:
		SetBatchLines, %p2%
	Goto, Return
	SCD:
	SetControlDelay:
		SetControlDelay, %p2%
	Goto, Return
	SDMS:
	SetDefaultMouseSpeed:
		SetDefaultMouseSpeed, %p2%
	Goto, Return
	SNLS:
	SetNumLockState:
	 SetNumLockState, %p2%
	Goto, Return
	SCLS:
	SetCapsLockState:
		SetCapsLockState, %p2%
	Goto, Return
	SSLS:
	SetScrollLockState:
		SetScrollLockState, %p2%
	Goto, Return
	SSCM:
	SetStoreCapslockMode:
		SetStoreCapslockMode, %p2%
	Goto, Return
	ST:
	SetTimer:
		SetTimer, %p2%, %p3%, %p4%
	Goto, Return
	SWDIR:
	SetWorkingDir:
		SetWorkingDir, %p2%
	Goto, Return
	SB:
	SoundBeep:
		SoundBeep, %p2%, %p3%
	Goto, Return
	SOG:
	SoundGet:
		SoundGet, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	SGWV:
	SoundGetWaveVolume:
		SoundGetWaveVolume, %p2%, %p3%, %p4%
	Goto, Return
	SPL:
	SoundPlay:
		SoundPlay, %p2%, %p3%
	Goto, Return
	SOS:
	SoundSet:
		SoundSet, %p2%, %p3%, %p4%, %p5%
	Goto, Return
	SSWV:
	SoundSetWaveVolume:
		SoundSetWaveVolume, %p2%, %p3%
	Goto, Return
	STOF:
	SplashTextOff:
		SplashTextOff
	Goto, Return
	STON:
	SplashTextOn:
		SplashTextOn, %p2%, %p3%, %p4%, %p5% 
	Goto, Return
	SU:
	Suspend:
		Suspend, %p2%
	Goto, Return
	T:
	Thread:
		Thread, %p2%, %p3%
	Goto, Return
	WGAS:
	WinGetActiveStats:
		WinGetActiveStats, %p2%, %p3%, %p4%, %p5%, %p6%
	Goto, Return
	WMA:
	WinMinimizeAll:
		WinMinimizeAll
	Goto, Return
	WMAU:
	WinMinimizeAllUndo:
		WinMinimizeAllUndo
	Goto, Return
}

RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
	Pattern := Morse(delay*1000)
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue = 1, times = 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
	Loop % times
		backspace .= "{Backspace}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
		Send % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		Send % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}	
Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951 (Modified to return: KeyWait %key%, T%tout%)
   tout := timeout/1000
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
   IfInString, key, %A_Space%
	StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
   Loop {
      t := A_TickCount
      KeyWait %key%, T%tout%
	  Pattern .= A_TickCount-t > timeout
	  If(ErrorLevel)
		Return Pattern
	  KeyWait %key%,DT%tout%
      If (ErrorLevel)
         Return Pattern
   }
}