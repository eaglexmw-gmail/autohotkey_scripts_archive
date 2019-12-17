
; gdi+ ahk tutorial 1 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
;
; Tutorial to draw a single ellipse and rectangle to the screen

#SingleInstance, Force
#NoEnv
SetBatchLines, -1

; Uncomment if Gdip.ahk is not in your standard library
#Include, Gdip.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
   ExitApp
}
OnExit, Exit

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
Width := 600, Height := 400

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs

; Show the window
Gui, 1: Show, NA

; Get a handle to this window we have created in order to update it later
hwnd1 := WinExist()


; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
hbm := CreateDIBSection(Width, Height)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G := Gdip_GraphicsFromHDC(hdc)

; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
Gdip_SetSmoothingMode(G, 4)

; Create a slightly transparent (66) blue brush (ARGB = Transparency, red, green, blue) to draw a rectangle


; //////////////////////////////////////////////////////////////////////
; Change variables here                                         ////////
LineWidth = 25
LineColor := "0xFF0000FF"
x1 = 130
y1 = 240
x2 = 200
y2 = 300

; Call function here
Gdip_DrawRoundedLine(G, x1, y1, x2, y2, LineWidth, LineColor)
;                                                               ////////
; //////////////////////////////////////////////////////////////////////

; Or just do it like this
Gdip_DrawRoundedLine(G, 100, 200, 95, 100, LineWidth, 0xFFFF00FF)

Gdip_DrawRoundedLine(G, 300, 200, 250, 100, LineWidth, 0xFF00FFFF)

Gdip_DrawRoundedLine(G, 500, 200, 350, 100, LineWidth, 0xFFFFFFFF)

Gdip_DrawRoundedLine(G, 200, 200, 150, 200, LineWidth, 0xFFFF0000)

Gdip_DrawRoundedLine(G, 250, 200, 250, 170, LineWidth, 0xFFFFFF00)


; The function
Gdip_DrawRoundedLine(G, x1, y1, x2, y2, LineWidth, LineColor)
{
 
  ;EndLoc
  pBrush := Gdip_BrushCreateSolid(LineColor)
  pPen := Gdip_CreatePen(LineColor, LineWidth)
 
  ; Calculations
  Slope := (y2 -y1) / (x2 -x1)
  Angle := ((ATan(Slope)) * 180/3.14159265)
 
  DiffX := (x1 - x2) / 100
  DiffY := (y1 - y2) / 100
 
  if (x1=x2)
  {
    if (y2<y1)
    {
      tmp := y1
      y1 := y2
      y2 := tmp
    }
    Pie1Angle := Angle + 180
    Pie2Angle := Angle
    PieX1 := x1 - (LineWidth / 2)
    PieY1 := y1 - (LineWidth / 2) + 1
    PieX2 := x2 - (LineWidth / 2)
    PieY2 := y2 - (LineWidth / 2) - 1
    GoTo, ContinueHere
  }
  if (y1=y2)
  {
    if (x2<x1)
    {
      tmp := x1
      x1 := x2
      x2 := tmp
    }
    Pie1Angle := Angle + 90
    Pie2Angle := Angle + 270
    PieX1 := x1 - (LineWidth / 2) + 1
    PieY1 := y1 - (LineWidth / 2)
    PieX2 := x2 - (LineWidth / 2) - 1
    PieY2 := y2 - (LineWidth / 2)
    GoTo, ContinueHere
  }
  if ((x1 > x2) && (y1 > y2))
  {
    Pie1Angle := Angle + 270
    Pie2Angle := Angle + 90
    PieX1 := x1 - (LineWidth / 2) - DiffX
    PieY1 := y1 - (LineWidth / 2) - DiffY
    PieX2 := x2 - (LineWidth / 2) + DiffX
    PieY2 := y2 - (LineWidth / 2) + DiffY
    GoTo, ContinueHere
  }
  if ((x1 > x2) && (y1 < y2))
  {
    Pie1Angle := Angle + 270
    Pie2Angle := Angle + 90
    PieX1 := x1 - (LineWidth / 2) - DiffX
    PieY1 := y1 - (LineWidth / 2) - DiffY
    PieX2 := x2 - (LineWidth / 2) + DiffX
    PieY2 := y2 - (LineWidth / 2) + DiffY
    GoTo, ContinueHere
  }
  if ((x1 < x2) && (y1 > y2))
  {
    Pie1Angle := Angle + 90
    Pie2Angle := Angle + 270
    PieX1 := x1 - (LineWidth / 2) - DiffX
    PieY1 := y1 - (LineWidth / 2) - DiffY
    PieX2 := x2 - (LineWidth / 2) + DiffX
    PieY2 := y2 - (LineWidth / 2) + DiffY
    GoTo, ContinueHere
  }
  if ((x1 < x2) && (y1 < y2))
  {
    Pie1Angle := Angle + 90
    Pie2Angle := Angle + 270
    PieX1 := x1 - (LineWidth / 2) - DiffX
    PieY1 := y1 - (LineWidth / 2) - DiffY
    PieX2 := x2 - (LineWidth / 2) + DiffX
    PieY2 := y2 - (LineWidth / 2) + DiffY
    GoTo, ContinueHere
  }
 
  ContinueHere:
  Gdip_DrawLine(G, pPen, x1, y1, x2, y2)
 
  Gdip_FillPie(G, pBrush, PieX1, PieY1, LineWidth, LineWidth, Pie1Angle, 180)
  Gdip_FillPie(G, pBrush, PieX2, PieY2, LineWidth, LineWidth, Pie2Angle, 180)
 
  Gdip_DeletePen(pPen)
  Gdip_DeleteBrush(pBrush)
}




; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; So this will position our gui at (0,0) with the Width and Height specified earlier
UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)


; Select the object back into the hdc
SelectObject(hdc, obm)

; Now the bitmap may be deleted
DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc)

; The graphics may now be deleted
Gdip_DeleteGraphics(G)
Return

;#######################################################################

Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return

#End::Reload
