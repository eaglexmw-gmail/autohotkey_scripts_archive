; http://www.autohotkey.com/forum/viewtopic.php?p=474365#474365
#NoEnv
OnExit, Exit
pToken := Gdip_Startup()

If !FileExist("temp.gif")
   UrlDownloadToFile, % "http://www.autohotkey.com/docs/images/AutoHotkey_logo.gif", temp.gif

pBitmap := Gdip_CreateBitmapFromFile("temp.gif")
Gdip_GetDimensions(pBitmap, w, h)

Gui, 1:Add, Slider, x0 y0 w%w% Range0-256 vMySlider gMyLabel AltSubmit, % MySlider:=128
Gui, 1: Add, Picture, x0 y24 w%w% h%h% 0xE hwndMyPic
Gui, 1: Show, w%w% h%h% , % "threshold:" MySlider

pBrush0 := Gdip_BrushCreateSolid(0xFFFFFFFF)
pBitmap0 := Gdip_CreateBitmap(w, h), G0 := Gdip_GraphicsFromImage(pBitmap0), Gdip_SetSmoothingMode(G0, 3)
Gdip_FillRectangle(G0, pBrush0, 0, 0, w, h)

MyLabel:
R := 0.299 , G := 0.587 , B := 0.114 , k:=1000
; k is a fix for ARGB32 format, we need B*k*255 > 255, same for R and G if smaller, else it's not a binary threshold but a mask,
R:=R*k*255 , G:=G*k*255 , B:=B*k*255 , T:=-k*(MySlider-1)

m:= R "|" R "|" R "|0|0|"
m.= G "|" G "|" G "|0|0|"
m.= B "|" B "|" B "|0|0|"
m.= 0 "|" 0 "|" 0 "|1|0|"
m.= T "|" T "|" T "|0|1"

;m := "76245|76245|76245|0|0|149685|149685|149685|0|0|29070|29070|29070|0|0|0|0|0|1|0|-127000|-127000|-127000|0|1"
Gdip_DrawImage(G0, pBitmap, 0, 0, w, h, 0, 0, w, h, m)

hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap0)
SetImage(MyPic, hBitmap)
;DeleteObject(hBitmap)
WinSetTitle, % "threshold:" MySlider
return

;Gdip_LockBits(pBitmap0, 0, 0, w, h, Stride, Scan0, BitmapData)
;Loop, %h%
;{
;  Loop, %w%
;  {
;    ARGB:=NumGet(Scan0+0, y*Stride+(A_Index-1)*4)
;    A := (0xff000000 & ARGB) >> 24
;    R := (0x00ff0000 & ARGB) >> 16
;    G := (0x0000ff00 & ARGB) >> 8
;    B := (0x000000ff & ARGB)
;  }
;}
;Gdip_UnlockBits(pBitmap0, BitmapData)

GuiClose:
Exit:
Gdip_DisposeImage(pBitmap), Gdip_DeleteBrush(pBrush0)
Gdip_DeleteGraphics(G0), Gdip_DisposeImage(pBitmap0), DeleteObject(hBitmap)
Gdip_Shutdown(pToken)
ExitApp
