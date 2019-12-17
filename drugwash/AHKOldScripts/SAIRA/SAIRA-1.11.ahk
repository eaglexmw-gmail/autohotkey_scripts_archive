#SingleInstance, Force
SetBatchLines, -1
#NoTrayIcon
CoordMode, Mouse, Screen

#Include, Gdip.ahk

If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

AppName = SAIRA
VersionNum = 1.11

SysGet, MonitorPrimary, MonitorPrimary
Sysget, WA, MonitorWorkArea, %MonitorPrimary%
WaWidth := WARight-WALeft, WAHeight := WABottom-WATop

PenWidth := 2
pPenBlack :=Gdip_CreatePen(0xff000000, PenWidth), pPenWhite :=Gdip_CreatePen(0xffffffff, PenWidth)
pBrushFade1 := Gdip_BrushCreateSolid(0xea000000), pBrushFade2 := Gdip_BrushCreateSolid(0x33000000)

EW := 40, EH := 80
AW := 2

Format = jpg|bmp|tiff|png

Menu, Context, Add, Remove, Remove
Menu, Context, Add, Clear, Remove

Gui, 1: +LastFound +OwnDialogs
hwnd1 := WinExist()

Gui, 1: Add, Listview, x10 y10 w730 h400 Grid vListview gListView Altsubmit, File|Size (kB)|DPI|Original Size|Converted Size|Crop
LV_ModifyCol(1, 310)
LV_ModifyCol(2, 60)
LV_ModifyCol(3, 60)
LV_ModifyCol(4, 145)
LV_ModifyCol(5, 145)
LV_ModifyCol(6, 0)

Gui, 1: Add, Text, x10 y+40 w100, Resize to:
Gui, 1: Add, Edit, x+0 yp+0 w100 vResize gResize, 100
Gui, 1: Add, Text, x+10 yp+0 w10, `%

Gui, 1: Add, Checkbox, x+190 yp+0 w120 vConvert gConvert, Convert format
Loop, Parse, Format, |
Gui, 1: Add, Radio, % "x+0 yp+0 w50 Disabled v" A_LoopField ((A_Index = 1) ? " Checked Group" : ""), %A_LoopField%

Gui, 1: Add, Edit, x10 y+30 w560 vOutFolder, %A_WorkingDir%\Resize
Gui, 1: Add, Button, x+10 yp+0 w75 gBrowse, &Browse
Gui, 1: Add, Button, x+10 yp+0 w75 gGo, &Go

Gui, 1: Add, Picture, x10 y+20 w730 h20 0xE vProgress
GoSub, ClearProgress

Gui, 1: Show, AutoSize, %AppName% - v%VersionNum% by Tariq Porter
OnMessage(0x201, "WM_LBUTTONDOWN")
Return

;##############################################################################################

WM_LBUTTONDOWN()
{
	Global

	If (A_Gui = 2)
	{	
		If Control
		{
			FadeTime := A_TickCount
			Loop
			{
				SetTimer, GetPos, Off
				Alpha := 255-Round(255*((A_TickCount-FadeTime)/500))
				If (Alpha <= 5)
				{
					UpdateLayeredWindow(hwnd2, hdc, (WAWidth-ShowWidth-EW)//2, (WAHeight-ShowHeight-EH)//2, ShowWidth+EW, ShowHeight+EH, 0)
					Gui, 2: Destroy
					Gdip_DeleteGraphics(GPreview2), Gdip_DisposeImage(pBitmapPreview)
					Gdip_DeleteGraphics(G), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
					Break
				}
				UpdateLayeredWindow(hwnd2, hdc, "", "", "", "", Alpha)
			}
		}
		Else
		PostMessage, 0xA1, 2
	}
}

;##############################################################################################

Gdip_SetProgress(ByRef Variable, Percentage, Foreground, Background=0x00000000, Text="", TextOptions="x0p y15p s60p Center cff000000 r4 Bold", Font="Arial")
{
	Gui, 1: +OwnDialogs
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable

	pBrushFront := Gdip_BrushCreateSolid(Foreground), pBrushBack := Gdip_BrushCreateSolid(Background)
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh), Gdip_FillRectangle(G, pBrushFront, 4, 4, (Posw*(Percentage/100))-8, Posh-8)
	
	Gdip_TextToGraphics(G, (Text != "") ? Text : Round(Percentage) "`%", TextOptions, Font, Posw, Posh)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}

;##############################################################################################

ListView:
Gui, 1: Default
;Tooltip, %A_GuiEvent%
If (A_GuiEvent = "RightClick")
Menu, Context, Show
Else If (A_GuiEvent = "DoubleClick")
{
	GuiControl, Disable, Listview
	GoSub, ShowCrop
	GuiControl, Enable, Listview
}
Return

;##############################################################################################

ShowCrop:
Critical
If !Row := LV_GetNext()
Return

Rx := Ry := ""
WinGetPos, Rx, Ry,,, ahk_id %hwnd2%
Gui, 2: Destroy

If IsWIndowVisible(hwnd2)
{
	Gdip_DeleteGraphics(GPreview2), Gdip_DisposeImage(pBitmapPreview)
	Gdip_DeleteGraphics(G), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
}

LV_GetText(PreviewLocation, Row, 1)
If !pBitmapPreview := Gdip_CreateBitmapFromFile(PreviewLocation)
Return
WidthPreview := Gdip_GetImageWidth(pBitmapPreview), HeightPreview := Gdip_GetImageHeight(pBitmapPreview)

If (WidthPreview > WAWidth//2) || (HeightPreview > WAHeight//2)
{
	If (WidthPreview/(WAWidth//2) >= HeightPreview/(WAHeight//2))
	ShowWidth := WAWidth//2, ShowHeight := (ShowWidth/WidthPreview)*HeightPreview
	Else
	ShowHeight := WAHeight//2, ShowWidth := (ShowHeight/HeightPreview)*WidthPreview
}
Else
ShowWidth := WidthPreview, ShowHeight := HeightPreview

Gui, 2: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +Owner1 +Resize
Gui, 2: Show, NA
hwnd2 := WinExist()

pBitmapPreview2 := Gdip_CreateBitmap(ShowWidth, ShowHeight), GPreview2 := Gdip_GraphicsFromImage(pBitmapPreview2), Gdip_SetSmoothingMode(GPreview2, 4)
Gdip_DrawImage(GPreview2, pBitmapPreview, 0, 0, ShowWidth, ShowHeight, 0, 0, WidthPreview, HeightPreview)

Gdip_DisposeImage(pBitmapPreview)
pBitmapPreview := pBitmapPreview2

hbm := CreateDIBSection(ShowWidth+EW, ShowHeight+EH), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm), G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4)

Gdip_FillRoundedRectangle(G, pBrushFade1, 0, 0, ShowWidth+EW, ShowHeight+EH, 12)

Gdip_DrawImage(G, pBitmapPreview, EW//2, EH//2, ShowWidth, ShowHeight, 0, 0, ShowWidth, ShowHeight)

1RC := Gdip_TextToGraphics(G, "x", "s15 x0 y10 Right cbbffffff h100p w" ShowWidth+EW-15, "Arial", ShowWidth+EW, ShowHeight+EH)
StringSplit, 1RC, 1RC, |

2RC := Gdip_TextToGraphics(G, "OK", "s15 x0 y" ShowHeight+(EH//2)+5 "Right cbbffffff h100p w" ShowWidth-EW+5, "Arial", ShowWidth+EW, ShowHeight+EH)
StringSplit, 2RC, 2RC, |

3RC := Gdip_TextToGraphics(G, "Cancel", "s15 x" 2RC1+2RC3+5 "y" ShowHeight+(EH//2)+5 "Left cbbffffff h100p w" ShowWidth, "Arial", ShowWidth+EW, ShowHeight+EH)
StringSplit, 3RC, 3RC, |

Rx := Rx ? Rx : (WAWidth-ShowWidth-EW)//2
Ry := Ry ? Ry : (WAHeight-ShowHeight-EH)//2
FadeTime := A_TickCount
Loop
{
	Alpha := Round(255*((A_TickCount-FadeTime)/400))
	;Tooltip, %Alpha%
	If (Alpha >= 250)
	{
		UpdateLayeredWindow(hwnd2, hdc, Rx, Ry, ShowWidth+EW, ShowHeight+EH, 255)
		Break
	}
	If (A_Index = 1)
	UpdateLayeredWindow(hwnd2, hdc, Rx, Ry, ShowWidth+EW, ShowHeight+EH, Alpha)
	Else
	UpdateLayeredWindow(hwnd2, hdc, "", "", "", "", Alpha)
}

SetTimer, GetPos, 30
;SetTimer, DrawCrop, 30
Return

;##############################################################################################

GetPos:
;Critical
MouseGetPos, x, y, Win
WinGetPos, Winx, Winy,,, ahk_id %hwnd2%
x -= Winx, y -= Winy

Control := 0
Loop, 3
{
	i := A_Index
	If (x >= %i%RC1) && (x < %i%RC1+%i%RC3) && (y >= %i%RC2) && (y < %i%RC2+%i%RC4)
	{
		Control := i
		Break
	}
}
If (Control = OldControl)
Return

Loop, % ((OldControl) && (Control != 0)) ? 2 : 1		;%
{
	LC := ((A_Index = 1) && (Control != 0)) ? Control : OldControl
	Gdip_SetCompositingMode(G, 1)
	Gdip_SetClipRect(G, %LC%RC1-5, %LC%RC2-5, %LC%RC3+10, %LC%RC4+10)	
	Gdip_FillRectangle(G, pBrushFade1, %LC%RC1-7, %LC%RC2-7, %LC%RC3+14, %LC%RC4+14)
	Gdip_SetCompositingMode(G, 0)
	
	If (LC = 1)
	Options := "s15 x0 y10 Right h100p w" ShowWidth+EW-15 ((LC = Control) ? " Bold UnderLine cffffffff" : " cbbffffff"), Text := "x"
	Else If (LC = 2)
	Options := "s15 x0 y" ShowHeight+(EH//2)+5 " Right caaffffff h100p w" ShowWidth-EW+5 ((LC = Control) ? " Bold UnderLine cffffffff" : " cbbffffff"), Text := "OK"
	Else If (LC = 3)
	Options := "s15 x" 2RC1+2RC3+5 " y" ShowHeight+(EH//2)+5 " Left caaffffff h100p w" ShowWidth ((LC = Control) ? " Bold UnderLine cffffffff" : " cbbffffff"), Text := "Cancel"
	
	If (LC = Control)
	{
		TpBitmap1 := Gdip_CreateBitmap(ShowWidth+EW, ShowHeight+EH), TG := Gdip_GraphicsFromImage(TpBitmap1)

		NewOptions := RegExReplace(Options, "i)C(?!(entre|enter))([a-f0-9]{8})", "cff599bb1", Count, 1)
		
		Gdip_TextToGraphics(TG, Text, NewOptions, "Arial", ShowWidth+EW, ShowHeight+EH)
		TpBitmap2 := Gdip_BlurBitmap(TpBitmap1, 7)
		Gdip_DrawImage(G, TpBitmap2, 0, 0, ShowWidth+EW, ShowHeight+EH)

		Gdip_DeleteGraphics(TG)
		Gdip_DisposeImage(TpBitmap1), Gdip_DisposeImage(TpBitmap2)
	}
	
	Gdip_TextToGraphics(G, Text, Options, "Arial", ShowWidth+EW, ShowHeight+EH)
}

UpdateLayeredWindow(hwnd2, hdc)
Gdip_ResetClip(G)
OldControl := Control
Return

;##############################################################################################

2GuiSize:
WinGetPos, tx, ty, tw, th, ahk_id %hwnd2%
tw -= EW, th -= EH



If !pBitmapPreview := Gdip_CreateBitmapFromFile(PreviewLocation)
Return
WidthPreview := Gdip_GetImageWidth(pBitmapPreview), HeightPreview := Gdip_GetImageHeight(pBitmapPreview)

; If (th/tw <= HeightPreview/WidthPreview)
; tw := tw, th := Round(tw*(HeightPreview/WidthPreview)), t := 1
; Else
; th := th, tw := Round(th*(WidthPreview/HeightPreview)), t := 2

;Tooltip, %t%
Tooltip, % tw "`n" th "`n" th/tw "`n" HeightPreview/WidthPreview "`n" t		;%



Gdip_DeleteGraphics(GPreview2)
Gdip_DeleteGraphics(G), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)

pBitmapPreview2 := Gdip_CreateBitmap(tw, th), GPreview2 := Gdip_GraphicsFromImage(pBitmapPreview2), Gdip_SetSmoothingMode(GPreview2, 4)
Gdip_DrawImage(GPreview2, pBitmapPreview, 0, 0, tw, th, 0, 0, WidthPreview, HeightPreview)

Gdip_DisposeImage(pBitmapPreview)
pBitmapPreview := pBitmapPreview2

hbm := CreateDIBSection(tw+EW, th+EH), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm), G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4)

Gdip_FillRoundedRectangle(G, pBrushFade1, 0, 0, tw+EW, th+EH, 12)

; Gdip_DrawImage(G, pBitmapPreview, EW//2, EH//2, tw, th, 0, 0, tw, th)

; 1RC := Gdip_TextToGraphics(G, "x", "s15 x0 y10 Right cbbffffff h100p w" tw+EW-15, "Arial", tw+EW, th+EH)
; StringSplit, 1RC, 1RC, |

; 2RC := Gdip_TextToGraphics(G, "OK", "s15 x0 y" th+(EH//2)+5 "Right cbbffffff h100p w" tw-EW+5, "Arial", tw+EW, th+EH)
; StringSplit, 2RC, 2RC, |

; 3RC := Gdip_TextToGraphics(G, "Cancel", "s15 x" 2RC1+2RC3+5 "y" th+(EH//2)+5 "Left cbbffffff h100p w" tw, "Arial", tw+EW, th+EH)
; StringSplit, 3RC, 3RC, |

UpdateLayeredWindow(hwnd2, hdc, "", "", tw+EW, th+EH)
Return

;##############################################################################################

DrawCrop:
Critical
Gui, 2: Default
Gui, 2: +OwnDialogs

If !GetKeyState("LButton", "P")
{
	Sx := Sy := 0
	Return
}

MouseGetPos, x, y, Win, Control
If (Win != hwnd2)
Return

Sx := Sx ? Sx : x, Sy := Sy ? Sy : y

tx := (x >= Sx) ? Sx : x
ty := (y >= Sy) ? Sy : y
w := (x >= Sx) ? x-Sx : Sx-x
h := (y >= Sy) ? y-Sy : Sy-y

Gdip_DrawImage(G, pBitmapPreview, 0, 0, ShowWidth, ShowHeight)

Gdip_SetClipRect(G, tx+Round(1.5*PenWidth), ty+Round(1.5*PenWidth), w-Round(3*PenWidth), h-Round(3*PenWidth), 4)
Gdip_FillRectangle(G, pBrushFade2, 0, 0, ShowWidth, ShowHeight)

Gdip_DrawRectangle(G, pPenWhite, tx, ty, w, h)
Gdip_DrawRectangle(G, pPenBlack, tx+PenWidth, ty+PenWidth, w-(2*PenWidth), h-(2*PenWidth))
UpdateLayeredWindow(hwnd2, hdc, (WAWidth-ShowWidth)//2, (WAHeight-ShowHeight)//2, ShowWidth, ShowHeight)

Gdip_ResetClip(G)
Return

;##############################################################################################

IsWIndowVisible(hwnd)
{
	Return, DllCall("IsWindowVisible", "UInt", hwnd)
}

;##############################################################################################

Remove:
If (A_ThisMenuItem = "Clear")
LV_Delete()
Else If (A_ThisMenuItem = "Remove")
{
	Loop, % LV_GetCount()			;%
	Row := LV_GetNext(Row), LV_Delete(Row)
}
Return

;##############################################################################################

Convert:
Gui, 1: Default
Gui, 1: +OwnDialogs
Gui, 1: Submit, NoHide
Loop, Parse, Format, |
GuiControl, % Convert ? "Enable" : "Disable", %A_LoopField%
Return

;##############################################################################################

Resize:
Gui, 1: Default
Gui, 1: +OwnDialogs
Gui, 1: Submit, NoHide
Resize := Resize/100
Loop, % LV_GetCount()		;%
{
	LV_GetText(Resolution, A_Index, 4)
	Pos := RegExMatch(Resolution, "(\d+) x (\d+) / (\d+) x (\d+) cm", Resolution)
	LV_Modify(A_Index, "Col5", Round(Resolution1*Resize) " x " Round(Resolution2*Resize) " / " Round(Resolution3*Resize) " x " Round(Resolution4*Resize) " cm")
}
Return

;##############################################################################################

Go:
Gui, 1: Default
Gui, 1: +OwnDialogs
Gui, 1: Submit, NoHide

ChosenFormat := ""
Loop, Parse, Format, |
{
	If !Convert || ChosenFormat
	Break
	ChosenFormat := %A_LoopField% ? A_LoopField : ""
}

Resize := Resize/100

If !Rows := LV_GetCount()
Return

If !FileExist(OutFolder)
FileCreateDir, %OutFolder%

Loop, %Rows%
{
	LV_GetText(File, A_Index, 1)
	If !pBitmap := Gdip_CreateBitmapFromFile(File)
	Continue
	
	G := Gdip_GraphicsFromImage(pBitmap)
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	
	StringSplit, File, File, \
	StringSplit, Extension, File%File0%, .
	FileName := SubStr(File%File0%, 1, StrLen(File%File0%)-StrLen(Extension%Extension0%)-1)
	If !ChosenFormat
	ChosenFormat := Extension%Extension0%
	
	If (Resize != 1)
	{
		pBitmapNew := Gdip_CreateBitmap(Round(Width*Resize), Round(Height*Resize)), GNew := Gdip_GraphicsFromImage(pBitmapNew)
		Gdip_SetInterpolationMode(GNew, 7)
		
		Gdip_DrawImage(GNew, pBitmap, 0, 0, Round(Width*Resize), Round(Height*Resize), 0, 0, Width, Height)
		Gdip_SaveBitmapToFile(pBitmapNew, OutFolder "\" FileName "." ChosenFormat)
		
		Gdip_DeleteGraphics(GNew), Gdip_DisposeImage(pBitmapNew)
	}
	Else
	Gdip_SaveBitmapToFile(pBitmap, OutFolder "\" FileName "." ChosenFormat)
	
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
	
	Gdip_SetProgress(Progress, Round(A_Index*(100/Rows)), 0xff0993ea, 0xffbde5ff)
	Sleep, 500
}
Gdip_SetProgress(Progress, "", 0xff0993ea, 0xffbde5ff, "Done!")
SetTimer, ClearProgress, -3000
Return

;##############################################################################################

ClearProgress:
;GuiControl,, Progress, 0
Gdip_SetProgress(Progress, 0, 0xff0993ea, 0xffbde5ff, " ")
Return

;##############################################################################################

GuiDropFiles:
Gui, 1: Default
Gui, 1: +OwnDialogs
Gui, 1: Submit, NoHide
Resize := Resize/100
Loop, Parse, A_GuiEvent, `n
{
	If !pBitmap := Gdip_CreateBitmapFromFile(A_LoopField)
	Continue
	FileGetSize, Size, %A_LoopField%, k
	
	G := Gdip_GraphicsFromImage(pBitmap)
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	
	DpiX := Round(Gdip_GetDpiX(G)), DpiY := Round(Gdip_GetDpiY(G))
	
	LV_Add("", A_LoopField, Size, DpiX, Width " x " Height " / " Round(2.5*(Width/DpiX)) " x " Round(2.5*(Height/DpiY)) " cm", Round(Resize*Width) " x " Round(Resize*Height) " / " Round(Resize*2.5*(Width/DpiX)) " x " Round(Resize*2.5*(Height/DpiY))  " cm")
	
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
}
Return

;##############################################################################################

Browse:
Gui, 1: Default
Gui, 1: +OwnDialogs
Gui, 1: Submit, NoHide
FileSelectFolder, Folder,,, Select the output folder to save the images
If !Folder
Return
GuiControl,, OutFolder, %Folder%
Return

;##############################################################################################

Esc::
GuiClose:
Exit:
Gdip_DeletePen(pPenBlack), Gdip_DeletePen(pPenWhite)
Gdip_DeleteBrush(pBrushFade1), Gdip_DeleteBrush(pBrushFade2)
Gdip_Shutdown(pToken)
ExitApp
Return