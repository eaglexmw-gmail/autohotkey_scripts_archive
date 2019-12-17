#SingleInstance, Force
SetBatchLines, -1

#Include, Gdip.ahk

Size := 1	; that's the resizing ratio. can be 0.1 to 1
FileType = png
Font = Arial

If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
   ExitApp
}
OnExit, Exit

Hotkey, ^], SaveScreen, On
Return

;####################################################################################

SaveScreen:
pBitmap := Gdip_BitmapFromScreen()
Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
if size = 1
	{
	pBitmapResized := pBitmap
	G := Gdip_GraphicsFromImage(pBitmapResized)
	}
else
	{
	PBitmapResized := Gdip_CreateBitmap(Round(Width*Size), Round(Height*Size)), G := Gdip_GraphicsFromImage(pBitmapResized), Gdip_SetInterpolationMode(G, 7)
	Gdip_DrawImage(G, pBitmap, 0, 0, Round(Width*Size), Round(Height*Size), 0, 0, Width, Height)
	}
Gdip_TextToGraphics(G, A_Hour ":" A_Min ":" A_Sec "  " A_DD "/" A_MM "/" A_YYYY, "x0 y0 r4 cff000000 s5p", Font, Round(Width*Size), Round(Height*Size))
Gdip_SaveBitmapToFile(PBitmapResized, A_Now "." FileType)
Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapResized)
Gdip_DisposeImage(pBitmap)
Return

;####################################################################################

Exit:
Gdip_Shutdown(pToken)
ExitApp
Return
