;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)

;create new document in memory
hDoc := HPDF_New("error","000")

;Creating a page, A4, Landscape
page := HPDF_AddPage(hDoc)
;HPDF_Page_SetSize(page, "A4", "LANDSCAPE")
HPDF_Page_SetWidth(page, 550)
HPDF_Page_SetHeight(page, 500)

;Setting Compression mode to HPDF_COMP_ALL (0x0F)
HPDF_SetCompressionMode(hDoc, "ALL")

;Draw the actual grid
placeImages(hDoc,page)

;saving to file
HPDF_SaveToFile(hDoc, "example_image_demo.pdf")

;unload dll
HPDF_UnloadDLL(hDll)

ExitApp



placeImages(ByRef pdf, ByRef page)
{
   page_title := "Image Demo"

   ;create default-font
   font := HPDF_GetFont(pdf, "Helvetica", 0)

   ;OnOpening: Zoom to 100% at the top left corner
   dst := HPDF_Page_CreateDestination(page)
   HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(page), 1)
   HPDF_SetOpenAction(pdf, dst)

   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_BeginText(page)
   tw := HPDF_Page_TextWidth(page, page_title)
   HPDF_Page_MoveTextPos(page, (HPDF_Page_GetWidth(page)-tw)/2, HPDF_Page_GetHeight(page) - 30)
   HPDF_Page_ShowText(page, page_title)
   HPDF_Page_EndText(page)

   image := HPDF_LoadPngImageFromFile(pdf, "pngsuite/basn3p02.png")
   iw := HPDF_Image_GetWidth(image)
   ih := HPDF_Image_GetHeight(image)
;   iw := 48
;   ih := 48
   image1 := HPDF_LoadPngImageFromFile(pdf, "pngsuite/basn3p02.png")
   image2 := HPDF_LoadPngImageFromFile(pdf, "pngsuite/basn0g01.png")
   image3 := HPDF_LoadPngImageFromFile(pdf, "pngsuite/maskimage.png")


   HPDF_Page_SetLineWidth(page, 0.5)

   x := 50
   y := HPDF_Page_GetHeight(page) - 100

   ;Draw image to the canvas. (normal-mode with actual size.)
   HPDF_Page_DrawImage(page, image, x, y, iw, ih)

   show_description(page, x, y, "Actual Size")

   x += 150

   ;Resizing image (X direction)
   HPDF_Page_DrawImage(page, image, x, y, iw * 1.5, ih)
   show_description(page, x, y, "Resizing image (X direction)")

   x += 150

   ;Resizing image (Y direction).
   HPDF_Page_DrawImage(page, image, x, y, iw, ih * 1.5)
   show_description(page, x, y, "Resizing image (Y direction)")

   x := 50
   y -= 100


   ;Skewing image.
   angle1 := 10
   angle2 := 20
   rad1 := angle1 / 180 * 3.141592
   rad2 := angle2 / 180 * 3.141592

   HPDF_Page_GSave(page)

   HPDF_Page_Concat(page, iw, tan(rad1) * iw, tan(rad2) * ih, ih, x, y)

   HPDF_Page_ExecuteXObject(page, image)
   HPDF_Page_GRestore(page)

   show_description(page, x, y, "Skewing image")

   x += 150


   ;Rotating image
   angle := 30
   rad := angle / 180 * 3.141592

   HPDF_Page_GSave(page)

   HPDF_Page_Concat(page, iw * cos(rad), iw * sin(rad), ih * -sin(rad), ih * cos(rad), x, y)

   HPDF_Page_ExecuteXObject(page, image)
   HPDF_Page_GRestore(page)

   show_description(page, x, y, "Rotating image")

   x += 150

   ;draw masked image
   ;Set image2 to the mask image of image1
   HPDF_Image_SetMaskImage(image1, image2)

   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x - 6, y + 14)
   HPDF_Page_ShowText(page, "MASKMASK")
   HPDF_Page_EndText(page)

   HPDF_Page_DrawImage(page, image1, x - 3, y - 3, iw + 6, ih + 6)

   show_description(page, x, y, "masked image")

   x := 50
   y -= 100

   ;color mask
   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x - 6, y + 14)
   HPDF_Page_ShowText(page, "MASKMASK")
   HPDF_Page_EndText(page)

   HPDF_Image_SetColorMask(image3, 0, 255, 0, 0, 0, 255)
   HPDF_Page_DrawImage(page, image3, x, y, iw, ih)

   show_description(page, x, y, "Color Mask")

   x += 150

   ;draw jpg image
   imageJPG := HPDF_LoadJpegImageFromFile(pdf, "images/rgb.jpg")

   ;Draw image to the canvas
   HPDF_Page_DrawImage(page, imageJPG, x, y-(HPDF_Image_GetHeight(imageJPG)/2), HPDF_Image_GetWidth(imageJPG)/2, HPDF_Image_GetHeight(imageJPG)/2)
   show_description(page, x, y+40, "24bit color image, JPEG, y+40")

   x += 150

   ;draw jpg image
   imageJPG := HPDF_LoadJpegImageFromFile(pdf, "images/gray.jpg")

   ;Draw image to the canvas
   HPDF_Page_DrawImage(page, imageJPG, x, y-(HPDF_Image_GetHeight(imageJPG)/2), HPDF_Image_GetWidth(imageJPG)/2, HPDF_Image_GetHeight(imageJPG)/2)
   show_description(page, x, y+40, "8bit grayscale image, JPEG, y+40")


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

   buf := "(x=" round(x,2) ",y=" round(y,2) ")"

   HPDF_Page_MoveTextPos(page, x+5, y - 12)
   HPDF_Page_ShowText(page, buf)
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x+5, y - 27)
   HPDF_Page_ShowText(page, text)
   HPDF_Page_EndText(page)
}