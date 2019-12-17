
#SingleInstance, Force
#NoEnv
SetBatchLines, -1
#Include, Gdip.ahk

If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
   ExitApp
}

Gui, 1: Add, Picture, x10 y20 w400 h200 0xE vProgressBar
Gui, 1: Show, Example 9 - gdi+ progress bar

OnMessage(0x200, "WM_MOUSEMOVE")
Return


Gdip_SetProgress(ByRef Variable)
{
  global
   GuiControlGet, Pos, Pos, Variable
   GuiControlGet, hwnd, hwnd, Variable

   pBrushFront := Gdip_BrushCreateSolid(0xff00AAFF)
   pBrushBack := Gdip_BrushCreateSolid(0xFF000000)

   pBitmap := Gdip_CreateBitmap(Posw, Posh)
  G := Gdip_GraphicsFromImage(pBitmap)
  Gdip_SetSmoothingMode(G, 4)
 
  Gdip_FillPolygon(G, pBrushBack, "53,0|159,0|212,90|159,180|53,180|0,90")

  if (One = 1)
    Gdip_FillPolygon(G, pBrushFront, "106,90|159,0|53,0|106,90")
  if (Two = 1)
    Gdip_FillPolygon(G, pBrushFront, "106,90|159,0|212,90")
  if (Three = 1)
    Gdip_FillPolygon(G, pBrushFront, "106,90|159,180|212,90")
  if (Four = 1)
    Gdip_FillPolygon(G, pBrushFront, "106,90|159,180|53,180")
  if (Five = 1)
    Gdip_FillPolygon(G, pBrushFront, "106,90|53,180|0,90")
  if (Six = 1)
    Gdip_FillPolygon(G, pBrushFront, "106,90|53,0|0,90")
 
   hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
;   SetImage(hwnd1, hBitmap)
   SetImage(hwnd, hBitmap)
   Gdip_DeleteBrush(pBrushFront)
   Gdip_DeleteBrush(pBrushBack)
   Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
   Return, 0
}

;#######################################################################

GuiClose:
Exit:
; gdi+ may now be shutdown
Gdip_Shutdown(pToken)
ExitApp
Return



WM_MOUSEMOVE(wParam, lParam)
{
  global
    x := lParam & 0xFFFF
    y := lParam >> 16

    cenx := 116
    ceny := 110
    x := x - cenx
   
    if (y < ceny)
      y := abs(y - ceny)
     
    if (y > ceny)
    {
      tmp := mod(y,ceny)
      y := tmp - (tmp * 2)
    }
   
    One = 0
    Two = 0
    Three = 0
    Four = 0
    Five = 0
    Six = 0
 
    if (triangle(-53,90,53,90,0,0,x,y) = 1)
      One = 1
    if (triangle(53,90,105,0,0,0,x,y) = 1)
      Two = 1
    if (triangle(105,0,53,-90,0,0,x,y) = 1)
      Three = 1
    if (triangle(53,-90,-53,-90,0,0,x,y) = 1)
      Four = 1
    if (triangle(-53,-90,-105,0,0,0,x,y) = 1)
      Five = 1
    if (triangle(-105,0,-53,90,0,0,x,y) = 1)
      Six = 1
     
  Gdip_SetProgress(ProgressBar)
  Sleep 20
  Return
}

triangle(x1,y1,x2,y2,x3,y3,xx,yy)
{
a0 := abs((x2-x1)*(y3-y1)-(x3-x1)*(y2-y1))
a1 := abs((x1-xx)*(y2-yy)-(x2-xx)*(y1-yy))
a2 := abs((x2-xx)*(y3-yy)-(x3-xx)*(y2-yy))
a3 := abs((x3-xx)*(y1-yy)-(x1-xx)*(y3-yy))

return (abs(a1+a2+a3-a0) <= 1/256)
}
