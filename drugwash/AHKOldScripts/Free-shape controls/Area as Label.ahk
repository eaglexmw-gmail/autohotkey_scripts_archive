
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
DetectHiddenText, On
DetectHiddenWindows, On
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   Select Image Gui     
Gui, Add, Edit, x10 y10 w370 r1 vfile, 
Gui, Add, Button, x+5 w20 h20 gGetFile, ...
Gui, Add, Button, x10 y+10 gGetSize, Load Selected Image

Gui, Show,, Select Image
Return

getfile: ;  Select the image to use.
FileSelectFile, selectedfile, 1, , , Image(*.GIF;*.JPG;*.BMP;*.PNG)
GuiControl, ,  file, %selectedfile%
Return

GetSize:  ;;;;;;;;;;;;;;;;;;;;;;;     Get image dimensions gui.
Gui, Submit, NoHide
If file = 
	{
	GuiControl, , file, Please select an image first.
	Return
	}
If file = Please select an image first. 
	Return

result := ImageWxH(file)
Gui, Destroy
StringSplit, Size, result, x,
Gui, Add, Pic, x0 y0 w%Size1% h%Size2% vPic1 gPic1, %file% ;  Open image in new gui.

If Size1 < 200  ; Set minimum gui width
	Size1 = 200
;;;;;;;;;;;;;;;;;;     Add Tracing Controls     ;;;;;;;
gbw := Size1-10
ebw := Size1-20
Gui, Add, Edit, w%ebw% r1 Hidden vGuiNum, 10
Gui, Add, Edit, xs y+5 w%ebw% Hidden vGetPoints,
Gui, Add, GroupBox, x5 y%Size2% w%gbw% h96 ,
Gui, Add, Checkbox, xp+5 yp+10 w%ebw% Section Disabled vBox1 gBox1, Tracing Off.

Gui, Add, Edit, xs y+3 w%ebw% r1 vGuiName gGuiName, Name Your Gui ; GuiName
Gui, Add, Edit, xs y+2 w%ebw% r1 vControlName gControlName, Name Your Control ; ControlName

Gui, Add, Button, xs ys+63 w20 h20 gExit, X  
Gui, Add, Button, x+5 w20 h20 gHelp, ?
Gui, Add, Button, x+5 w70 h20 Disabled vAddControl gAddControl, Add Control 
Gui, Add, Button, x+5 w50 h20 gClear, Clear

Gui, +LastFound -Caption
ShowSize := Size2+100
Gui, Show, w%Size1% h%ShowSize%, Define Areas As Labels
WinGet, IDG1, ID, Area as Label
Return

AddControl:
GuiControl, , Box1, 0
GuiControl, Disable, Box1,
Gui, Submit, NoHide
IfNotExist , %GuiName%.ahk
	{
	GoSub AXtext
	FileAppend, %AXtext%, %GuiName%.ahk
	}
IfNotExist , MouseOverRules.ahk
	{
	GoSub MOText
	FileAppend, %MOText%, MouseOverRules.ahk
	}
Add_Control(GuiNum,Size1,Size2,ControlName,GuiName,GetPoints)
GuiControl, Disable, GuiName,
GuiControl, Disable, AddControl,

GoSub Clear
GoSub Box1
GuiControl, , ControlName, Name Your Control
Return

GuiName:
ControlName:
Gui, Submit, NoHide
If GuiName = 
	Return
If GuiName = Name Your Gui
	Return
If ControlName = 
	Return
If ControlName = Name Your Control
	Return
GuiControl, Enable, Box1, 
Return

Pic1:  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;     Move gui by clicking on your pic.
WinActivate, Area as Label
PostMessage, 0xA1, 2,,, A 
Loop, 
	{
	KeyIsDown := GetKeyState("LButton")
	If KeyIsDown = 1
		Sleep, 50
	If KeyIsDown = 0
		Break
	}
Return

Del::
GuiControl, , Box1, 0
Box1:
Gui, Submit, NoHide
If Box1 = 1
	{
	SetSystemCursor("IDC_Cross")
	GuiControl, , Box1, Tracing On. Mouse over here or Delete to stop.
	OnMessage(0x201, "WM_LBUTTONDOWN")
	}
If Box1 = 0
	{
	GuiControl, , Box1, Tracing Off.
	RestoreCursors()
	}
Return


WM_LBUTTONDOWN()
	{
	Gui, Submit, NoHide
	If A_Gui = 1
		{
		Start_Trace()
		}

	}
Return

Clear:
Gui, Submit, NoHide
GuiControlGet, ControlName
WinClose, %ControlName%
Gui, %GuiNum%:Destroy
Gdip_Shutdown(pToken)
Return

Help:

Return

Esc::
Exit:
GuiClose:
Gui, Destroy
Gdip_Shutdown(pToken)
ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;          Functions          ;;;;;;;;;;;;;;;;;
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     Retrieve Image Size Function   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ImageWxH(ImageFile) {
;Supports only GIF, JPG, BMP and PNG
IfNotExist, %ImageFile%
  Return ""
Size=2592
DHW:=A_DetectHiddenWindows
DetectHiddenWindows, ON
Gui, 99:-Caption
Gui, 99:Margin, 0, 0
Gui, 99:Show,Hide w%Size% h%Size%, ImageWxH.Temporary.GUI
Gui, 99:Add, Picture, x0 y0 , % ImageFile
Gui, 99:Show,AutoSize Hide, ImageWxH.Temporary.GUI
WinGetPos, , ,w,h, ImageWxH.Temporary.GUI
Gui, 99:Destroy
DetectHiddenWindows, %DHW%
Return w "x" h
}	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     Cursor Functions     ;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;     Cursor Functions           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RestoreCursors()
{
   SPI_SETCURSORS := 0x57
   DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

SetSystemCursor( Cursor = "", cx = 0, cy = 0 )
{
   BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init
   
   SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
   ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
   ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
   ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP
   
   If Cursor = ; empty, so create blank cursor
   {
      VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
      BlankCursor = 1 ; flag for later
   }
   Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
   {
      Loop, Parse, SystemCursors, `,
      {
         CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
         CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
         SystemCursor = 1
         If ( CursorName = Cursor )
         {
            CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )   
            Break               
         }
      }   
      If CursorHandle = ; invalid cursor name given
      {
         Msgbox,, SetCursor, Error: Invalid cursor name
         CursorHandle = Error
      }
   }   
   Else If FileExist( Cursor )
   {
      SplitPath, Cursor,,, Ext ; auto-detect type
      If Ext = ico
         uType := 0x1   
      Else If Ext in cur,ani
         uType := 0x2     
      Else ; invalid file ext
      {
         Msgbox,, SetCursor, Error: Invalid file type
         CursorHandle = Error
      }     
      FileCursor = 1
   }
   Else
   {   
      Msgbox,, SetCursor, Error: Invalid file path or cursor name
      CursorHandle = Error ; raise for later
   }
   If CursorHandle != Error
   {
      Loop, Parse, SystemCursors, `,
      {
         If BlankCursor = 1
         {
            Type = BlankCursor
            %Type%%A_Index% := DllCall( "CreateCursor"
            , Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
            CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
            DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
         }         
         Else If SystemCursor = 1
         {
            Type = SystemCursor
            CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )   
            %Type%%A_Index% := DllCall( "CopyImage"
            , Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )     
            CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
            DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
         }
         Else If FileCursor = 1
         {
            Type = FileCursor
            %Type%%A_Index% := DllCall( "LoadImageA"
            , UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 )
            DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )         
         }         
      }
   }   
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     Line Functions     ;;;;;;;;;;;;;;;;;;
Start_Trace()
	{
	GuiControlGet, Box1
	If Box1 = 0
		Return
	If !pToken := Gdip_Startup()
		{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
		}
	WinGetPos , ShowX, ShowY, ShowW, ShowH, Define Areas As Labels
	Gui, 2: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
	Gui, 2: Show, x%ShowX% y%ShowY% w%ShowW% h%ShowH% NA, TraceLayer ; Show the window
	hwnd1 := WinExist() ; Get a handle to this window we have created in order to update it later
	Clicked = 0
	Pen := Gdip_CreatePen(0xffffffff,1)
	MouseGetPos, MouseX, MouseY, 
	Points = %MouseX%,%MouseY%
	LastPoint = %MouseX%,%MouseY%
	Loop, 
		{
		GuiControlGet, Box1
		If Box1 = 0
			Break
		MouseGetPos, , Mover
		Lbreak := ShowH-96
		If Mover > %Lbreak%
			{
			GuiControl, , Box1, 0
			GoSub, Box1
			}
		WinActivate , Define Areas As Labels
		GetKeyState, State, LButton  
		If State = D
			{
			Clicked := Clicked+1
			If Clicked > 1
				{
				Points = %PrevPoints%|%NowX%,%NowY%
				Draw_White_Lines(Points)
				GuiControl, , Text1, %Points%
				}
			PrevPoints = %Points%
			MouseGetPos, MouseX, MouseY
			}
		hbm := CreateDIBSection(ShowW, ShowH) ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
		hdc := CreateCompatibleDC() ; Get a device context compatible with the screen
		obm := SelectObject(hdc, hbm) ; Select the bitmap into the device context
		G := Gdip_GraphicsFromHDC(hdc) ; Get a pointer to the graphics of the bitmap, for use with drawing functions
		
		MouseGetPos, NowX, NowY
		Gdip_DrawLine(G, Pen, MouseX, MouseY, NowX, NowY)
		
		UpdateLayeredWindow(hwnd1, hdc, ShowX, ShowY, ShowW, ShowH)
		
		}
	
	Gdip_DeletePen(Pen)
	SelectObject(hdc, obm) ; Select the object back into the hdc
	DeleteObject(hbm) ; Now the bitmap may be deleted
	DeleteDC(hdc) ; Also the device context related to the bitmap may be deleted
	Gdip_DeleteGraphics(G) ; The graphics may now be deleted
	Points = %Points%|%LastPoint%
	Draw_White_Lines(Points)
	StringReplace, RegionPoints, Points, |, %A_Space%, All 
	StringReplace, RegionPoints, RegionPoints, `,, -, All 
	NewRegion(RegionPoints)
	Gui, 2:Destroy 
	Gui, 3:Destroy 
	GuiControl, 1:, GetPoints, %RegionPoints%
	}

Draw_White_Lines(Points)
	{

	WinGetPos , ShowX, ShowY, ShowW, ShowH, Define Areas As Labels
	; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	Gui, 3: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
	Gui, 3: Show, x%ShowX% y%ShowY% w%ShowW% h%ShowH% NA, Layer1 ; Show the window
	hwnd3 := WinExist() ; Get a handle to this window we have created in order to update it later
	hbm := CreateDIBSection(ShowW, ShowH) ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hdc := CreateCompatibleDC() ; Get a device context compatible with the screen
	obm := SelectObject(hdc, hbm) ; Select the bitmap into the device context
	G := Gdip_GraphicsFromHDC(hdc) ; Get a pointer to the graphics of the bitmap, for use with drawing functions
	Pen := Gdip_CreatePen(0xffDAE80F,1)

	Gdip_DrawLines(G, Pen, Points)
	WinGet, IDG1, ID, Drag Lines Test
	WinGet, IDG2, ID, Layer1
	DockA(IDG1, IDG2, "x(0) y(0) w() h()")
	Gdip_DeletePen(Pen)
	UpdateLayeredWindow(hwnd3, hdc, ShowX, ShowY, ShowW, ShowH)

	SelectObject(hdc, obm) ; Select the object back into the hdc
	DeleteObject(hbm) ; Now the bitmap may be deleted
	DeleteDC(hdc) ; Also the device context related to the bitmap may be deleted
	Gdip_DeleteGraphics(G) ; The graphics may now be deleted
	}


NewRegion(Points)
	{
	GuiControlGet, GuiName
	GuiControlGet, ControlName
	If ControlName = 
		Return
	If ControlName =  Name Your Control
		Return
	GuiControl, 1:Enable, AddControl,
	GuiControlGet, GuiNum
	NewGui:= GuiNum+1
	GuiControl, 1:, GuiNum, %NewGui%
	WinGetPos , ShowX, ShowY, ShowW, ShowH, Define Areas As Labels
	Gui, %NewGui%:Color, Black
	Gui, %NewGui%:+LastFound +Toolwindow -Caption
	Gui, %NewGui%:Show, x%ShowX% y%ShowY% w%ShowW% h%ShowH%, %ControlName%
	WinSet, Transparent, 150, %ControlName%
	WinSet, Region, %Points%, %ControlName%
	WinGet, IDG1, ID, Define Areas As Labels
	WinGet, IDG, ID, %ControlName%
	DockA(IDG1, IDG, "x(0) y(0) w() h()")

	}

Add_Control(GNum,GW,GH,GName,G1Name,Points)
	{
	RegionText = 
	(Join 
	WinGetPos , ShowX, ShowY, ShowW, ShowH, %G1Name%`n
Gui, %GNum%:Color, Black`n
Gui, %GNum%:Show, x`%ShowX`% y`%ShowY`% w`%ShowW`% h`%ShowH`% Hide, %GName%`n
WinSet, Transparent, 1, %GName%`n
WinSet, Region, %Points%, %GName%`n
Gui, %GNum%:+LastFound +Toolwindow -Caption`n
Gui, %GNum%:Show, , %GName%`n
WinGet, IDG1, ID, %G1Name%`n
WinGet, IDG, ID, %GName%`n
DockA(IDG1, IDG, "x(0) y(0) w() h()")`n	
`n
	)
	FileAppend, %RegionText%, %G1Name%.ahk
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;      Text Copy     ;;;;;;;;;;;;;;;;;;;;;;;;;;

AXtext:
SplitPath, file, FileName
AXtext = 
(Join 
#NoEnv`nSendMode Input`nSetWorkingDir `%A_ScriptDir`%`n#SingleInstance , Force`nDetectHiddenWindows, On
`n`n
Gui, Add, Pic, x0 y0 w%Size1% h%Size2% vMoveGui gPic1, %FileName%`n
Gui, +LastFound -Caption`n
Gui, Show, w%Size1% h%Size2%, %GuiName%`n
GoSub AddControls`n
SetTimer, OnMouseOver, 100`n
OnMessage(0x201, "WM_LBUTTONDOWN")`n
Return`n
`n
#Include MouseOverRules.ahk`n
`n
WM_LBUTTONDOWN()`n
	{`n
	MouseGetPos, , , OverWin,`n
	WinGetTitle, title, ahk_id`%OverWin`%`n
	StringReplace, title, title, `%A_Space`%, _, All `n
	If IsLabel(title)`n
		Gosub, `%title`%`n
	}`n
Return`n

Esc::`n
Exit:`n
GuiClose:`n
Gui, Destroy`n
ExitApp`n
`n
Pic1:`n
WinActivate, %GuiName%`n
PostMessage, 0xA1, 2,,, A `n
Loop, `n
	{`n
	KeyIsDown := GetKeyState("LButton")`n
	If KeyIsDown = 1`n
		Sleep, 50`n
	If KeyIsDown = 0`n
		Break`n
	}`n
Return`n
`n
AddControls:`n
)
Return

MOText:
MOText = 
(Join
OnMouseOver:`n
MouseGetPos, , , OverWin, `n
WinGetTitle, title, ahk_id `%OverWin`%`n
MOList = `n
IfInString, MOList, `%title`%`n
	{`n
	Loop, 100`n
		{`n
		SetTrans := A_Index+1`n
		If SetTrans = 100`n
			Break`n
		WinSet, Transparent, `%SetTrans`%, `%title`%`n
		}`n
	Loop, 100`n
		{`n
		SetTrans := 100-A_Index`n
		If SetTrans = 1`n
			Break`n
		WinSet, Transparent, `%SetTrans`%, `%title`%`n
		}`n
	}`n
Return`n
`n
)
Return

	
