;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)

;create new document in memory
hDoc := HPDF_New("error","000")

;Setting Compression mode to HPDF_COMP_ALL (0x0F)
HPDF_SetCompressionMode(hDoc, "ALL")

;Draw the actual grid
placeImages(hDoc,3,5)

;saving to file
HPDF_SaveToFile(hDoc, "example_thumbnails.pdf")

;unload dll
HPDF_UnloadDLL(hDll)

ExitApp


placeImages(ByRef pdf,cols,rows)
{
   page_title := "Thumbnails"

   ;create default-font
   font := HPDF_GetFont(pdf, "Helvetica", 0)

shfld := ( (A_OSType in WIN32_WINDOWS) ? "" : "User " ) . "Shell Folders"
   RegRead, path, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\%shfld%, My Pictures
   StringReplace, path, path, `%USERPROFILE`%\, %A_MyDocuments%\

   pToken := Gdip_Startup()

   Loop, %path%\*.jpg, 0, 0
   {
      if mod(A_Index,cols*rows) = 1
      {
         page := HPDF_AddPage(pdf)
         HPDF_Page_SetSize(page, "A4", "PORTAIT")

         pWidth := HPDF_Page_GetWidth(page)
         pHeight := HPDF_Page_GetHeight(page)

         gapWidth := (pWidth * 0.2) / (cols+1)
         gapHeight := (pHeight * 0.2) / (rows+1)

         iWidth := (pWidth * 0.8) / cols
         iHeight := (pHeight * 0.8) / rows

         HPDF_Page_SetFontAndSize(page, font, 10)
         HPDF_Page_BeginText(page)
         tw := HPDF_Page_TextWidth(page, path)
         HPDF_Page_MoveTextPos(page, 5, 5)
         HPDF_Page_ShowText(page, path)
         HPDF_Page_EndText(page)

         x := 0
         y := pHeight-gapHeight
      }

      x+=gapWidth
      resampleImage(A_LoopFileFullPath,iWidth,iHeight)
      image%A_Index% := HPDF_LoadJpegImageFromFile(pdf, A_Temp "\temp.jpg")
      inw := HPDF_Image_GetWidth(image%A_Index%)
      inh := HPDF_Image_GetHeight(image%A_Index%)

      aspectRatio(iw,ih,inw,inh,iWidth,iHeight)

      HPDF_Page_DrawImage(page, image%A_Index%, x, y-ih, iw, ih)
      show_description(page, x, y-ih, A_LoopFileName)
      x+=iWidth

      if mod(A_Index,cols) = 0
      {
         x := 0
         y := y - gapHeight - iHeight
      }
   }

   Gdip_Shutdown(pToken)

}

resampleImage(filename,iWidth,iHeight,dpi=2)
{
   Global cnt
   w := Round(iWidth,0)*dpi
   h := Round(iHeight,0)*dpi

   pBitmapFile := Gdip_CreateBitmapFromFile(filename)

   Width := Gdip_GetImageWidth(pBitmapFile)
   Height := Gdip_GetImageHeight(pBitmapFile)

   aspectRatio(iw,ih,Width,Height,w,h)

   pBitmap := Gdip_CreateBitmap(iw, ih)
   G := Gdip_GraphicsFromImage(pBitmap)
   Gdip_DrawImage(G, pBitmapFile, 0, 0, iw, ih, 0, 0, Width, Height)
   Gdip_DisposeImage(pBitmapFile)
   Gdip_SaveBitmapToFile(pBitmap, A_Temp "\temp.jpg")
   Gdip_DisposeImage(pBitmap)
   Gdip_DeleteGraphics(G)
}


show_description(ByRef page, x, y, text)
{
   HPDF_Page_MoveTo(page, x, y - 10)
   HPDF_Page_LineTo(page, x, y + 10)
   HPDF_Page_MoveTo(page, x - 10, y)
   HPDF_Page_LineTo(page, x + 10, y)
   HPDF_Page_Stroke(page)

   HPDF_Page_SetFontAndSize(page, HPDF_Page_GetCurrentFont(page), 8)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x+5, y - 12)
   HPDF_Page_ShowText(page, text)
   HPDF_Page_EndText(page)
}

aspectRatio(Byref resWidth, Byref resHeight, inWidth,inHeight,outMaxWidth,outMaxHeight)
{
   objectar := inWidth/inHeight

   ; -- calculate image dimensions to ensure preservation of aspect ratio --
   imageh := outMaxHeight
   imagew := imageh*objectar

   if ( imagew > outMaxWidth )
   {
      imagew := outMaxWidth
      imageh := imagew/objectar
   }

   resWidth := imagew
   resHeight := imageh
}