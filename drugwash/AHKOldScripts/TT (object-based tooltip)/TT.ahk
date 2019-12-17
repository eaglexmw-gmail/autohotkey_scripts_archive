;: Title: TT.ahk Object based ToolTip Library by HotKeyIt
;

; Function: TT() - Object based ToolTip Library by HotKeyIt
; Description:
;      TT is based on AHK_L Objects and supports both, ANSI and UNICODE version, so to use it you will require <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Lexikos AutoHotkey_L.exe</a> or other versions based on it that supports objects.<br><br>TT is used to work with ToolTip controls. You can create standalone ToolTips but also ToolTips for Controls of your GUI.
; Syntax: TTObj:=TT(Options,Text,Title)
; Parameters:
;	   TTObj - ToolTip Object to control ToolTip using its functions and ToolTip messages.
;	   <b>Options</b> - <b>Description</b> (If Options is a digit or hexadecimal number TT will assume this is the parent window)
;	   <b>Options requiring a value</b> - All these options need to be followed by = and a value. For example Parent=99
;	   GUI/PARENT - Parent HWND or Gui Id (Parent can be 1-99 as well). When no Parent or GUI ID is given, GUI +LastFound will be used, when you do not want to have a parent use PARENT=0 (OnShow,OnClick,OnClose is only possible if PARENT is an AutoHotkey window)
;	   AUTOPOP / INITIAL / RESHOW - Option for Control ToolTips.<br>AUTOPOP - How long to remain visible.<br>INITIAL - Delay showing.<br>RESHOW - Delay showing between tools.<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760404.aspx>TTM_SETDELAYTIME Message</a>.
;	   MAXWIDTH - Maximum tooltip window width, or -1 to allow any width.<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760408.aspx>TTM_SETMAXTIPWIDTH Message</a>.
;	    ICON - 0=none 1=info 2=warning 3=error (> 3 = hIcon).<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760414.aspx>TTM_SETTITLE Message</a>.
;	   Color - RGB color for ToolTip text color.<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760413.aspx>TTM_SETTIPTEXTCOLOR Message</a>.
;	   BackGround - RGB ToolTip background color.<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760411.aspx>TTM_SETTIPBKCOLOR  Message</a>.
;	   OnClose/OnClick - A function to be launched when a ToolTip was closed or a link was clicked. ParseLinks option will be set automatically.<br><br>Links are created using <a [action]>Text</a>.<br>Your OnClick function can accept up to two parameters ToolTip_Message(action[,Tool]).<br>When action is not specified Text will be used.<br>Tool is your ToolTip object that you can access inside your function.<br>OnClose uses same parameters but first passed parameter will be empty.
;	   <b>Options not requiring a value<b> - <b>HWND CENTER RTL SUB TRACK ABSOLUTE TRANSPARENT PARSELINKS</b> - For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760256.aspx>TOOLINFO Structure</a><br> - <b>CloseButton</b> for your ToolTip<br> - <b>ClickTrough</b> will enable clicking trough ToolTip<br> - <b>Balloon</b> ToolTip<br> - <b>Style</b> uses themed hyperlinks.<br> - <b>NoFade</b> disables fading.<br> - <b>NoAnimate</b> disables sliding on Win2000.<br> - <b>NoPrefix</b> Prevents the system from stripping ampersand characters from a string or terminating a string at a tab character.<br> - <b>AlwaysTip</b> - Indicates that the tooltip control appears even if the tooltip control's owner window is inactive.
;	   <b>ToolTip functions</b> - <b>All function beside Add, Del, Show, Color, Remove and Text are ToolTip messages, for reference see <a href=http://msdn.microsoft.com/en-us/library/ff486069.aspx>ToolTip Messages</a>.<br>To call them use for example TTObj.TRACKACTIVATE(x,y)</b>
;	   ToolTip.<b>Add()</b> - ToolTip.Add(Control[,text,uFlags/options,parent])<br> - <b>Control</b> can be text like Button1 or hwnd of control.<br> - <b>Text</b> to be displayed.<br> - <b>uFlags/options</b> can be a value or list of strings <b>HWND CENTER RTL SUB TRACK ABSOLUTE TRANSPARENT PARSELINKS</b>.<br> - <b>Parent</b> can be a parent window, default is set in TT function, see above.
;	   ToolTip.<b>Remove()</b> - Removes a ToolTip object and all control associations. Call TT_Remove() to remove all ToolTips (will be called automatically when scripts exits).
;	   ToolTip.<b>Del()</b> - ToolTip.Del(Control)<br>Delete a ToolTip associated with a control only, other ToolTips will remain.
;	   ToolTip.<b>Show()</b> - ToolTip.Show([Text,x,y,title,icon,iconIdx])<br>Show a ToolTip. x and y can be TrayIcon to show ToolTip at TrayIcon coordinates of your app.
;	   ToolTip.<b>Hide()</b> - Hides a ToolTip. Same as ToolTip.TrackPosition(0).
;	   ToolTip.<b>Color()</b> - ToolTip.Color(textcolor,backgroundcolor)<br>Used to set both colors and string colors like White,Black,Yellow,Red,Blue.... You can also use wrapped message straight away: TTObj.SETTIPBKCOLOR(RGBValue) and ToolTip.SETTIPTEXTCOLOR(RGBValue)
;	   ToolTip.<b>Text()</b> - ToolTip.Text(text)<br>Update text for main ToolTip (created when TT() is called).
;	   ToolTip.<b>Title()</b> - ToolTip.Title([title,icon,iconIdx])<br>Update title and icon for ToolTip. Icon can be 0 - 3 or a hIcon or a file path and iconIdx if it is an exe,dll or cur file.<br>IconIdx must be an empty string ("") if you want to load an icon from jpg, png, bmp, gif or other supported files by gdi as well as from HEX string.<br>Otherwise associated icon for given file type will be loaded.
;	   ToolTip.<b>Icon()</b> - ToolTip.Icon([icon,iconIdx])<br>Update only icon for ToolTip. Icon can be a file path, see title function. TT_GetIcon can be used to get a hIcon.
; Return Value:
;     TT returns a ToolTip object that can be used to perform all action on a ToolTip.
; Remarks:
;		When no Parent is given when calling TT(), Gui +LastFound will be used, when first parameter of TT(0x283475) is digit or xdigit, it will be used as parent.<br>Options TRACK and NOPREFIX are forced by default, to disable use TRACK=0 NOPREFIX=0.
; Related:
; Example:
;		file:TT_Example.ahk
;

TT(options="",text="",title=""){
	; Options
	;WS_POPUP=0x80000000,TTS_ALWAYSTIP=0x1,TTS_NOPREFIX=0x2,TTS_USEVISUALSTYLE=0x100,TTS_NOFADE=0x20,TTS_NOANIMATE=0x10
	static TOOLINFO="cbSize,uFlags,hwnd,UPTR uId,RECT rect,UPTR hinst,LPTSTR lpszText,UPTR lParam,void *lpReserved"
	,HWND_TOPMOST=0xffffffff,SWP_NOMOVE=0x2, SWP_NOSIZE=0x1, SWP_NOACTIVATE=0x10
	; Objects
	,base:=Object("Color","TT_Color","Show","TT_Show","Hide","TTM_Trackactivate","Add","TT_Add","AddTool","TTM_AddTool"
			,"Del","TT_Del","Title","TTM_SetTitle","Text","TT_Text","ACTIVATE","TTM_ACTIVATE","Set","TT_Set"
			,"ADDTOOL","TTM_ADDTOOL","Remove","TT_Remove","Icon","TT_Icon"
			,"ADJUSTRECT","TTM_ADJUSTRECT","DELTOOL","TTM_DELTOOL","ENUMTOOLS","TTM_ENUMTOOLS","GETBUBBLESIZE","TTM_GETBUBBLESIZE"
			,"GETCURRENTTOOL","TTM_GETCURRENTTOOL","GETDELAYTIME","TTM_GETDELAYTIME","GETMARGIN","TTM_GETMARGIN"
			,"GETMAXTIPWIDTH","TTM_GETMAXTIPWIDTH","GETTEXT","TTM_GETTEXT","GETTIPBKCOLOR","TTM_GETTIPBKCOLOR"
			,"GETTIPTEXTCOLOR","TTM_GETTIPTEXTCOLOR","GETTITLE","TTM_GETTITLE","GETTOOLCOUNT","TTM_GETTOOLCOUNT"
			,"GETTOOLINFO","TTM_GETTOOLINFO","HITTEST","TTM_HITTEST","NEWTOOLRECT","TTM_NEWTOOLRECT","POP","TTM_POP"
			,"POPUP","TTM_POPUP","RELAYEVENT","TTM_RELAYEVENT","SETDELAYTIME","TTM_SETDELAYTIME","SETMARGIN","TTM_SETMARGIN"
			,"SETMAXTIPWIDTH","TTM_SETMAXTIPWIDTH","SETTIPBKCOLOR","TTM_SETTIPBKCOLOR","SETTIPTEXTCOLOR","TTM_SETTIPTEXTCOLOR"
			,"SETTITLE","TTM_SETTITLE","SETTOOLINFO","TTM_SETTOOLINFO","SETWINDOWTHEME","TTM_SETWINDOWTHEME"
			,"TRACKACTIVATE","TTM_TRACKACTIVATE","TRACKPOSITION","TTM_TRACKPOSITION","UPDATE","TTM_UPDATE"
			,"UPDATETIPTEXT","TTM_UPDATETIPTEXT","WINDOWFROMPOINT","TTM_WINDOWFROMPOINT"
			,"GetAddress","GetAddress","_NewEnum","_NewEnum","__Delete","__Delete","base",Object("__Call","TT_Set","__Delete","TT_Delete"))
	,@:=Object()
	If options=9223372036854775808 
		Return @
	else if options is xdigit
		Parent:=options
	else If (options){
		Loop,Parse,options,%A_Space%,%A_Space%
			If istext {
				If (SubStr(A_LoopField,0)="'")
					%istext%:=string A_Space SubStr(A_LoopField,1,StrLen(A_LoopField)-1),istext:="",string:=""
				else
					string.= A_Space A_LoopField
			} else If A_LoopField contains AUTOPOP,INITIAL,PARENT,RESHOW,MAXWIDTH,ICON,Color,BackGround,OnClose,OnClick,OnShow,GUI,NOPREFIX,TRACK
			{
				RegExMatch(A_LoopField,"^(\w+)=?(.*)?$",option)
				If ((Asc(option2)=39 && SubStr(A_LoopField,0)!="'") && (istext:=option1) && (string:=SubStr(option2,2)))
					Continue
				%option1%:=option2
			} else if A_LoopField
				%A_LoopField% := 1
	}
	If (Parent && Parent<100 && !DllCall("IsWindow","UPTR",Parent)){
		Gui,%Parent%:+LastFound
		Parent:=WinExist()
	} else if (GUI){
		Gui, %GUI%:+LastFound
		Parent:=WinExist()
	} else if (Parent=""){
		Gui +LastFound
		Parent:=WinExist()
	}
	T:=Object("base",base)
	T.HWND := DllCall("CreateWindowEx", "UPTR", (ClickTrough?0x20:0)|0x8, "str", "tooltips_class32", "UPTR", 0
         , "UPTR",0x80000000|(Style?0x100:0)|(NOFADE?0x20:0)|(NoAlimate?0x10:0)|NOPREFIX+1?(NOPREFIX?0x2:0x2):0x2|(AlwaysTip?0x1:0)|(ParseLinks?0x1000:0)|(CloseButton?0x80:0)|(Balloon?0x40:0)
         , "int",0x80000000,"int",0x80000000,"int",0x80000000,"int",0x80000000, "UPTR",Parent?Parent:0,"UPTR",0,"UPTR",0,"UPTR",0)
	DllCall("SetWindowPos","UPTR",T.HWND,"UInt",HWND_TOPMOST,"Int",0,"Int",0,"Int",0,"Int",0
                           ,"UPTR",SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE)
	@.Insert(T)
	T.SETMAXTIPWIDTH(MAXWIDTH?MAXWIDTH:A_ScreenWidth)
	If !(AUTOPOP INITIAL RESHOW)
		T.SETDELAYTIME()
	else T.SETDELAYTIME(AUTOPOP?AUTOPOP*1000:-1),T.SETDELAYTIME(INITIAL?INITIAL*1000:-1),T.SETDELAYTIME(RESHOW?RESHOW*1000:-1)
	T.fulltext:=text,T.maintext:=RegExReplace(text,"<a\K[^<]*?>",">")
	If ((T.OnClick:=OnClick)||(T.OnClose:=OnClose)||(T.OnShow:=OnShow)),T.OnClose:=OnClose,T.OnShow:=OnShow,T.ClickHide:=ClickHide
		OnMessage(0x4e,"TT_OnMessage")
	If OnClick
		ParseLinks:=1
	T.rc:=Struct("RECT") ;for TTM_SetMargin
	;Tool for Main ToolTip
	T.P:=Struct(TOOLINFO),P:=T.P,P.cbSize:=Struct(T.P)
	P.uFlags:=(HWND?0x1:0)|(Center?0x2:0)|(RTL?0x4:0)|(SUB?0x10:0)|(Track+1?(Track?0x20:0):0x20)|(Absolute?0x80:0)|(TRANSPARENT?0x100:0)|(ParseLinks?0x1000:0)
	P.hwnd:=Parent,P.uId:=Parent,P.lpszText:=T.GetAddress("maintext"),T.AddTool(P[])
	If Color
		T.SETTIPTEXTCOLOR(Color)
	If Background
		T.SETTIPBKCOLOR(BackGround)
	T.SetTitle(T.maintitle:=title,icon)
	Sleep,100
	Return T
}

TT_Delete(t=""){ ;delete all ToolTips (will be executed OnExit)
	TT_Remove(),TT_GetIcon() ;delete ToolTips and Destroy all icon handles
}

TT_Remove(T=""){
	static @:=TT(9223372036854775808) ;Get main object that holds all ToolTips
	If !T
		Loop % @.MaxIndex()
		{
			T:=@[A_Index]
			@.Remove(A_Index)
			for id,tool in T.T
				T.DelTool(tool[])
			T.DelTool(T.P[])
			DllCall("DestroyWindow","UPTR",T.HWND)
		}
	else
		for id,Tool in @
		{
			If (T=Tool){
				@[id]:=@[@.MaxIndex()],@.Remove(id)
				for id,tools in Tool.T
					Tool.DelTool(tools[])
				Tool.DelTool(Tool.P[])
				DllCall("DestroyWindow","UPTR",Tool.HWND)
				break
			}
		}
}

TT_OnMessage(wParam,lParam,msg,hwnd){
	static TTN_FIRST:=0xfffffdf8, @:=TT(9223372036854775808) ;Get main object that holds all ToolTips
	Loop 4
		m += *(lParam + 8 + A_Index-1) << 8*(A_Index-1)
	m:=TTN_FIRST-m
	If m not between 1 and 3
		Return
	Loop 4
		p += *(lParam + 0 + A_Index-1) << 8*(A_Index-1)
	If (m=3)
		Loop 4
			option += *(lParam + 16 + A_Index-1) << 8*(A_Index-1)
	for id,T in @
		If (p=T.hwnd)
			break
	text:=T.fulltext
	If (m=1){ 							;Show
		If IsFunc(T.OnShow)
			T.OnShow("",T)
	} else If (m=2){ 					;Close
		If IsFunc(T.OnClose)
			T.OnClose("",T)
		T.TRACKACTIVATE(0,T.P[])
	} else If InStr(text,"<a"){	;Click
		Loop % option+1
			StringTrimLeft,text,text,% InStr(text,"<a")+1
		If T.ClickHide
			T.TRACKACTIVATE(0,T.P[])
		action:=SubStr(text,1,InStr(text,">")-1)
		If !(action){
			StringTrimLeft,text,text,% InStr(text,">")
			text:=SubStr(text,1,InStr(text,"</a>")-1)
			action:=text
		} else
			action=%action%
		If IsFunc(T.OnClick)
			T.OnClick(action,T)
	}
	Return true
}

TT_ADD(T,Control,Text="",uFlags="",Parent=""){
	;	uFlags http://msdn.microsoft.com/en-us/library/bb760256.aspx
	; TTF_ABSOLUTE=0x80, TTF_CENTERTIP=0x0002, TTF_IDISHWND=0x1, TTF_PARSELINKS=0x1000 ,TTF_RTLREADING = 0x4
	; TTF_SUBCLASS=0x10, TTF_TRACK=0x20, TTF_TRANSPARENT=0x100
	static TOOLINFO="cbSize,uFlags,hwnd,UPTR uId,RECT rect,UPTR hinst,LPTSTR lpszText,UPTR lParam,void *lpReserved"
	DetectHiddenWindows:=A_DetectHiddenWindows
	DetectHiddenWindows,On
	if (Parent){
		If (Parent && Parent<100 and !DllCall("IsWindow","UPTR",Parent)){
			Gui %Parent%:+LastFound
			Parent:=WinExist()
		}
		T["T",Abs(Parent)]:=Struct(TOOLINFO),Tool:=T["T",Abs(Parent)]
		Tool.uId:=Parent,Tool.hwnd:=Parent,Tool.uFlags:=(0|16)
		DllCall("GetClientRect","UPTR",T.HWND,"UInt", T[Abs(Parent)].rect[])
		T.ADDTOOL(T["T",Abs(Parent)][])
	}
	If text=
		ControlGetText,text,%Control%,% "ahk_id " (Parent?Parent:T.P.hwnd)
	If Control is not Xdigit
		If Control is not digit
			ControlGet,Control,Hwnd,,%Control%,% "ahk_id " (Parent?Parent:T.P.hwnd)
	If uFlags
		If uFlags is not digit
		{
			Loop,Parse,uflags,%A_Space%,%A_Space%
				If A_LoopField
					%A_LoopField% := 1
			uFlags:=(HWND?0x1:HWND=""?0x1:0)|(Center?0x2:0)|(RTL?0x4:0)|(SUB?0x10:0)|(Track?0x20:0)|(Absolute?0x80:0)|(TRANSPARENT?0x100:0)|(ParseLinks?0x1000:0)|16
		}
	T["T",Abs(Control)]:=Struct(TOOLINFO)
	Tool:=T.T[Abs(Control)]
	Tool.cbSize:=Struct(Tool)
	T[Abs(Control),"text"]:=RegExReplace(text,"<a\K[^<]*?>",">")
	Tool.uId:=Control,Tool.hwnd:=Parent?Parent:T.P.hwnd,Tool.uFlags:=uFlags?(uFlags|16):(1|0x1000|16)
	Tool.lpszText:=T[Abs(Control)].GetAddress("text")
	DllCall("GetClientRect","UPTR",T.HWND,"UInt",Tool.rect[])
	T.ADDTOOL(Tool[])
	DetectHiddenWindows,%DetectHiddenWindows%
}

TT_DEL(T,Control){
	If !Control
		Return 0
	If Control is not Xdigit
		If Control is not digit
			ControlGet,Control,Hwnd,,%Control%,% "ahk_id " t.P.hwnd
   T.DELTOOL(T.T[Abs(Control)][]),T.T.Remove(Abs(Control))
}

TT_Color(T,Color="",Background=""){
	static TTM_SETTIPBKCOLOR=0x413,TTM_SETTIPTEXTCOLOR=0x414
		,Black=0x000000,Green=0x008000,Silver=0xC0C0C0,Lime=0x00FF00,Gray=0x808080,Olive=0x808000
		,White=0xFFFFFF,Yellow=0xFFFF00,Maroon=0x800000,Navy=0x000080,Red=0xFF0000,Blue=0x0000FF
		,Purple=0x800080,Teal=0x008080,Fuchsia=0xFF00FF,Aqua=0x00FFFF
	If (Color!="")
		T.SETTIPTEXTCOLOR(Color)
	If (BackGround!="")
		T.SETTIPBKCOLOR(BackGround)
}

TT_Text(T,text){
	static TTM_UPDATETIPTEXT=0x400+(A_IsUnicode?57:12),TTM_UPDATE=0x400+29
	T.fulltext:=text,T.maintext:=RegExReplace(text,"<a\K[^<]*?>",">"),T.P.lpszText:=T.GetAddress("maintext")
	T.UPDATETIPTEXT(T.P[])
}
TT_Icon(T,icon=0,icon#=1){
   static TTM_SETTITLE = 0x400 + (A_IsUnicode ? 33 : 32)
	If icon
		If icon is not digit
			icon:=TT_GetIcon(icon,icon#)
   Return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETTITLE,"UPTR",icon,"UPTR",T.GetAddress("maintitle")),T.UPDATE()
}

TT_GetIcon(File="",Icon#=1){
   static hIcon:=Object(),AW:=A_IsUnicode?"W":"A"
			,SHFILEINFO:="HICON hIcon,iIcon,DWORD dwAttributes,TCHAR szDisplayName[260],TCHAR szTypeName[80]"
			,static si:=DllCall( "LoadLibrary", Str,"gdiplus" ),temp:=VarSetCapacity(si, 16, 0), si := Chr(1)
   If !sfi {
      sfi:=Struct(SHFILEINFO),sfi_size:=Struct(sfi)
		SysGet, SmallIconSize, 49
		DllCall( "gdiplus\GdiplusStartup", UIntP,pToken, UInt,&si, UInt,0 )
	}
	If !File {
		for file,obj in hIcon
			If IsObject(obj){
				for icon,handle in obj
					DllCall("DestroyIcon","UInt",handle)
			} else 
				DllCall("DestroyIcon","UInt",handle)
		DllCall( "gdiplus\GdiplusShutdown", UInt,pToken ),sfi:=""
		Return
	}
	If hIcon[File,Icon#]
		Return hIcon[file,Icon#] 
	else
		SplitPath, File,,, Ext
   If ext in cur
	{
		Return hIcon[file,Icon#]:=DllCall("LoadImage", uint, 0, str, File
, uint, ext="cur"?2:1, int, 0, int, 0, uint, 0x10)
	} if Ext in EXE,ICO,DLL
   {
      If ext=LNK
      {
         FileGetShortcut,%File%,Fileto,,,,FileIcon,FileIcon#
         File:=!FileIcon ? FileTo : FileIcon
      }
      SplitPath, File,,, Ext
	   DllCall("PrivateExtractIcons", "Str", File, "Int", Icon#-1, "Int", SmallIconSize, "Int", SmallIconSize, "UInt*", Icon, "UInt*", 0, "UInt", 1, "UInt", 0, "Int")
		Return hIcon[File,Icon#]:=Icon
	} else if (Icon#=""){
		If !FileExist(File){ 
			if File is xdigit ;assume Hex string
			{
				nSize := StrLen(File)//2
				VarSetCapacity( Buffer,nSize ) 
				Loop % nSize 
				  NumPut( "0x" . SubStr(File,2*A_Index-1,2), Buffer, A_Index-1, "Char" )
			} else Return
		} else {
			FileGetSize,nSize,%file%
			FileRead,Buffer,*c %file%
		}
		hData := DllCall("GlobalAlloc", UInt,2, UInt, nSize )
		pData := DllCall("GlobalLock",  UInt,hData )
		DllCall( "RtlMoveMemory", UInt,pData, UInt,&Buffer, UInt,nSize )
		DllCall( "GlobalUnlock", UInt,hData )
		DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
		DllCall( "gdiplus\GdipCreateBitmapFromStream", UInt,pStream, UIntP,pBitmap )
		DllCall( "gdiplus\GdipCreateHBITMAPFromBitmap", UInt,pBitmap, UIntP,hBitmap, UInt,0 )
		DllCall( "gdiplus\GdipDisposeImage", UInt,pBitmap )
		ii:=struct("BOOL fIcon,DWORD xHotspot,DWORD yHotspot,HBITMAP hbmMask,HBITMAP hbmColor")
		ii.ficon:=1,ii.hbmMask:=hBitmap,ii.hbmColor:=hBitmap
		return hIcon[File]:=DllCall("CreateIconIndirect","UInt",ii[])
	} else {
		If hIcon[File]
			Return hIcon[file]
		else If DllCall("Shell32\SHGetFileInfo" AW, "str", File, "uint", 0, "UPTR", sfi[], "uint", sfi_size, "uint", 0x101){
			Return hIcon[Ext] := sfi.hIcon
      }
	}
}

TT_Show(T,text="",x="",y="",title="",icon="",icon#=1){
	If Text!=
		T.Text(text)
	If (title!="")
		T.SETTITLE(title,icon,icon#)
	If (x="TrayIcon" || y="TrayIcon"){
		DetectHiddenWindows:=A_DetectHiddenWindows
		DetectHiddenWindows,On
		Process, Exist
		PID:=ErrorLevel
		hWndTray:=WinExist("ahk_class Shell_TrayWnd")
		ControlGet,hWndToolBar,Hwnd,,ToolbarWindow321,ahk_id %hWndTray%
		WinGet, procpid, PID,ahk_id %hWndToolBar%
		VarSetCapacity(lpdata,20),VarSetCapacity(dwExtraData,8)
		DataH   := DllCall( "OpenProcess", "uint", 0x38, "int", 0, "uint", procpid) ;0x38 = PROCESS_VM_OPERATION+READ+WRITE
		bufAdr  := DllCall( "VirtualAllocEx", "UPTR", DataH, "UPTR", 0, "uint", 20, "uint", MEM_COMMIT:=0x1000, "uint", PAGE_READWRITE:=0x4)
		Loop % DllCall("SendMessage","UPTR",hWndToolBar,"UInt",0x418,"UPTR",0,"UPTR",0)
		{
			DllCall("SendMessage","UPTR",hWndToolBar,"UInt",0x417,"UPTR",A_Index-1,"UPTR",bufAdr)
			DllCall("ReadProcessMemory", "UPTR", DataH, "UPTR", bufAdr, "UPTR", &lpdata, "uint", 20, "uint", 0)
			DllCall("ReadProcessMemory", "UPTR", DataH, "UPTR", NumGet(lpData,12), "UPTR", &dwExtraData, "UInt", 8, "UInt", 0)
			WinGet,BWPID,PID,% "ahk_id " NumGet(dwExtraData,0)
			If (BWPID!=PID)
				continue
			DllCall("SendMessage","UPTR",hWndToolBar,"UInt",0x41d,"UPTR",A_Index-1,"UPTR",bufAdr)
			If (NumGet(lpData,8)>7){
				ControlGetPos,xc,yc,xw,yw,Button2,ahk_id %hWndTray%
				xc+=xw/2, yc+=yw/4
			} else {
				DllCall( "ReadProcessMemory", "UPTR", DataH, "UPTR", bufAdr, "UPTR", &lpdata, "uint", 20, "uint", 0 )
				ControlGetPos,xc,yc,,,ToolbarWindow321,ahk_id %hWndTray%
				halfsize:=NumGet(lpdata,12)/2
				xc+=NumGet(lpdata,0)+ halfsize
				yc+=NumGet(lpdata,4)+ (halfsize/2)
			}
			WinGetPos,xw,yw,,,ahk_id %hWndTray%
			xc+=xw,yc+=yw
			break
		}
		DllCall( "VirtualFreeEx", "UPTR", DataH, "UPTR", bufAdr, "uint", 0, "uint", MEM_RELEASE:=0x8000)
		DllCall( "CloseHandle", "UPTR", DataH )
		DetectHiddenWindows % DetectHiddenWindows
		If x=TrayIcon
			x:=xc
		If y=TrayIcon
			y:=yc
	}
	If (x="" || y=""){
		VarSetCapacity(xc, 20, 0), xc := Chr(20)
		DllCall("GetCursorInfo", "UPTR", &xc)
		If (y=""){
			y := NumGet(xc,16)
			SysGet,yl,77
			SysGet,yr,79
			y+=15
			If y not between %yl% and %yr%
				y:=y<yl ? yl : yr
		}
		If (x=""){
			x := NumGet(xc,12)
			SysGet,xr,78
			SysGet,xl,76
			x+=15
			If x not between %xl% and %xr%
				x:=x<xl ? xl : xr
		}
	}
	T.TRACKPOSITION(x,y)
	T.TRACKACTIVATE(1)
}

TT_Set(T,option="",OnOff=1){
	static Style=0x100,NOFADE=0x20,NoAlimate=0x10,NOPREFIX=0x2,AlwaysTip=0x1,ParseLinks=0x1000,CloseButton=0x80,Balloon=0x40
			,ClickTrough=0x20
	ListLines
	If option in Style,NOFADE,NoAnimate,NOPREFIX,AlwaysTip,ParseLinks,CloseButton,Balloon
		DllCall("SetWindowLong","UPTR",T.HWND,"UInt",-16,"UInt",DllCall("GetWindowLong","UPTR",T.HWND,"UInt",-16)+(OnOff?(%option%):(-%option%)))
	else If option in ClickTrough
		DllCall("SetWindowLong","UPTR",T.HWND,"UInt",-20,"UInt",DllCall("GetWindowLong","UPTR",T.HWND,"UInt",-20)+(OnOff?(%option%):(-%option%)))
	else
		MsgBox Invalid option: %option%
	T.Update()
}

TTM_ACTIVATE(T,Activate=0){
   static TTM_ACTIVATE = 0x400 + 1
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_ACTIVATE,"UPTR",activate,"UPTR",0)
}

TTM_ADDTOOL(T,pTOOLINFO){
   static TTM_ADDTOOL = A_IsUnicode ? 0x432 : 0x404
   Return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_ADDTOOL,"UPTR",0,"UPTR",pTOOLINFO)
}

TTM_ADJUSTRECT(T,action,prect){
   static TTM_ADJUSTRECT = 0x41f
   Return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_ADJUSTRECT,"UPTR",action,"UPTR",prect)
}
TTM_DELTOOL(T,pTOOLINFO){
   static TTM_DELTOOL = A_IsUnicode ? 0x433 : 0x405
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_DELTOOL,"UPTR",0,"UPTR",pTOOLINFO)
}
TTM_ENUMTOOLS(T,idx,pTOOLINFO){
   static TTM_ENUMTOOLS = A_IsUnicode?0x43a:0x40e
   Return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_ENUMTOOLS,"UPTR",idx,"UPTR",pTOOLINFO)
}
TTM_GETBUBBLESIZE(T,pTOOLINFO){
   static TTM_GETBUBBLESIZE = 0x41e
   Return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETBUBBLESIZE,"UPTR",0,"UPTR",pTOOLINFO)
}
TTM_GETCURRENTTOOL(T,pTOOLINFO){
   static TTM_GETCURRENTTOOL = 0x400 + (A_IsUnicode ? 59 : 15)
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETCURRENTTOOL,"UPTR",0,"UPTR",pTOOLINFO)
}
TTM_GETDELAYTIME(T,whichtime){
	;TTDT_RESHOW = 1; TTDT_AUTOPOP = 2; TTDT_INITIAL = 3
   static TTM_GETDELAYTIME = 0x400 + 21
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETDELAYTIME,"UPTR",whichtime,"UPTR",0)
}
TTM_GETMARGIN(T,pRECT){
   static TTM_GETMARGIN = 0x41b
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETMARGIN,"UPTR",0,"UPTR",pRECT)
}
TTM_GETMAXTIPWIDTH(T,wParam=0,lParam=0){
   static TTM_GETMAXTIPWIDTH = 0x419
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETMAXTIPWIDTH,"UPTR",0,"UPTR",0)
}
TTM_GETTEXT(T,buffer,pTOOLINFO){
   static TTM_GETTEXT = A_IsUnicode?0x438:0x40b
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETTEXT,"UPTR",buffer,"UPTR",pTOOLINFO)
}
TTM_GETTIPBKCOLOR(T,wParam=0,lParam=0){
   static TTM_GETTIPBKCOLOR = 0x416
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETTIPBKCOLOR,"UPTR",0,"UPTR",0)
}
TTM_GETTIPTEXTCOLOR(T,wParam=0,lParam=0){
   static TTM_GETTIPTEXTCOLOR = 0x417
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETTIPTEXTCOLOR,"UPTR",0,"UPTR",0)
}
TTM_GETTITLE(T,pTTGETTITLE){
	;struct("TTGETTITLE:DWORD dwSize,UPTR uTitleBitmap,UPTR cch,WCHAR *pszTitle")
   static TTM_GETTITLE = 0x423
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETTITLE,"UPTR",0,"UPTR",pTTGETTITLE)
}
TTM_GETTOOLCOUNT(T,wParam=0,lParam=0){
   static TTM_GETTOOLCOUNT = 0x40d
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETTOOLCOUNT,"UPTR",0,"UPTR",0)
}
TTM_GETTOOLINFO(T,pTOOLINFO){
   static TTM_GETTOOLINFO = 0x400 + (A_IsUnicode ? 53 : 8)
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_GETTOOLINFO,"UPTR",0,"UPTR",pTOOLINFO)
}
TTM_HITTEST(T,pTTHITTESTINFO){
	;struct("TTHITTESTINFO:HWND hwnd,POINT pt,TOOLINFO ti")
   static TTM_HITTEST = A_IsUnicode?0x437:0x40a
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_HITTEST,"UPTR",0,"UPTR",pTTHITTESTINFO)
}
TTM_NEWTOOLRECT(T,pTOOLINFO=0){
   static TTM_NEWTOOLRECT = 0x400 + (A_IsUnicode ? 52 : 6)
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_NEWTOOLRECT,"UPTR",0,"UPTR",pTOOLINFO?pTOOLINFO:T.P[])
}
TTM_POP(T,wParam=0,lParam=0){
   static TTM_POP = 0x400 + 28 
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_POP,"UPTR",0,"UPTR",0)
}
TTM_POPUP(T,wParam=0,lParam=0){
   static TTM_POPUP = 0x422
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_POPUP,"UPTR",0,"UPTR",0)
}
TTM_RELAYEVENT(T,wParam=0,lParam=0){
	;struct("MSG:HWND hwnd,UPTR message,WPARAM wParam,LPARAM lParam,DWORD time,POINT pt")
   static TTM_RELAYEVENT = 0x407
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_RELAYEVENT,"UPTR",0,"UPTR",0)
}
TTM_SETDELAYTIME(T,whichTime=0,mSec=-1){
	;TTDT_AUTOMATIC = 0; TTDT_RESHOW = 1; TTDT_AUTOPOP = 2; TTDT_INITIAL = 3
   static TTM_SETDELAYTIME = 0x400 + 3
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETDELAYTIME,"UPTR",0,"UPTR",mSec)
}
TTM_SETMARGIN(T,top=0,left=0,bottom=0,right=0){
   static TTM_SETMARGIN = 0x41a
	rc:=T.rc,rc.top:=top,rc.left:=left,rc.bottom:=bottom,rc.right:=right
	DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETMARGIN,"UPTR",0,"UPTR",rc[])
}
TTM_SETMAXTIPWIDTH(T,maxwidth=-1){
   static TTM_SETMAXTIPWIDTH = 0x418
   return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETMAXTIPWIDTH,"UPTR",0,"UPTR",maxwidth)
}
TTM_SETTIPBKCOLOR(T,color=0){
   static TTM_SETTIPBKCOLOR = 0x413
			,Black:=0x000000,    Green:=0x008000,		Silver:=0xC0C0C0,		Lime:=0x00FF00
			,Gray:=0x808080,    	Olive:=0x808000,		White:=0xFFFFFF,   	Yellow:=0xFFFF00
			,Maroon:=0x800000,	Navy:=0x000080,		Red:=0xFF0000,    	Blue:=0x0000FF
			,Purple:=0x800080,   Teal:=0x008080,		Fuchsia:=0xFF00FF,	Aqua:=0x00FFFF
	If color is alpha
		If (%color%)
			Color:=%color%
	Color := (StrLen(Color) < 8 ? "0x" : "") . Color
	Color := ((Color&255)<<16)+(((Color>>8)&255)<<8)+(Color>>16) ; rgb -> bgr
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETTIPBKCOLOR,"UPTR",color,"UPTR",0)
}
TTM_SETTIPTEXTCOLOR(T,color=0){
   static TTM_SETTIPTEXTCOLOR = 0x414
			,Black:=0x000000,    Green:=0x008000,		Silver:=0xC0C0C0,		Lime:=0x00FF00
			,Gray:=0x808080,    	Olive:=0x808000,		White:=0xFFFFFF,   	Yellow:=0xFFFF00
			,Maroon:=0x800000,	Navy:=0x000080,		Red:=0xFF0000,    	Blue:=0x0000FF
			,Purple:=0x800080,   Teal:=0x008080,		Fuchsia:=0xFF00FF,	Aqua:=0x00FFFF
	If color is alpha
		If (%color%)
			Color:=%color%
	Color := (StrLen(Color) < 8 ? "0x" : "") . Color
	Color := ((Color&255)<<16)+(((Color>>8)&255)<<8)+(Color>>16) ; rgb -> bgr
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETTIPTEXTCOLOR,"UPTR",color,"UPTR",0)
}
TTM_SETTITLE(T,title="",icon="",Icon#=1){
   static TTM_SETTITLE = 0x400 + (A_IsUnicode ? 33 : 32)
	If icon
		If icon is not digit
			icon:=TT_GetIcon(icon,Icon#)
	T.maintitle := (StrLen(title) < 96) ? title : (Chr(133) SubStr(title, -97))
	If Icon!=
		lastIcon:=Icon
   Return DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETTITLE,"UPTR",icon,"UPTR",T.GetAddress("maintitle")),T.UPDATE(),lastIcon:=Icon
}
TTM_SETTOOLINFO(T,pTOOLINFO=0){
   static TTM_SETTOOLINFO = A_IsUnicode?0x436:0x409
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_SETTOOLINFO,"UPTR",0,"UPTR",pTOOLINFO?pTOOLINFO:T.P[])
}
TTM_SETWINDOWTHEME(T,theme=""){
   DllCall("SendMessage","UPTR",T.HWND,"UInt",0x200b,"UPTR",0,"UPTR",&theme)
}
TTM_TRACKACTIVATE(T,activate=0,pTOOLINFO=0){
   DllCall("SendMessage","UPTR",T.HWND,"UInt",0x411,"UPTR",activate,"UPTR",pTOOLINFO?pTOOLINFO:T.P[])
}
TTM_TRACKPOSITION(T,x=0,y=0){
	DllCall("SendMessage","UPTR",T.HWND,"UInt",0x412,"UPTR",0,"UPTR",(x & 0xFFFF)|(y & 0xFFFF)<<16)
}
TTM_UPDATE(T){
   DllCall("SendMessage","UPTR",T.HWND,"UInt",0x41D,"UPTR",0,"UPTR",0)
}
TTM_UPDATETIPTEXT(T,pTOOLINFO=0){
   static TTM_UPDATETIPTEXT = A_IsUnicode?0x439:0x40c
   DllCall("SendMessage","UPTR",T.HWND,"UInt",TTM_UPDATETIPTEXT,"UPTR",0,"UPTR",pTOOLINFO?pTOOLINFO:T.P[])
}
TTM_WINDOWFROMPOINT(T,pPOINT){
   Return DllCall("SendMessage","UPTR",T.HWND,"UInt",0x410,"UPTR",0,"UPTR",pPOINT)
}
