;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)

;create new document in memory
hDoc := HPDF_New("error","000")

;Setting Compression mode to HPDF_COMP_ALL (0x0F)
HPDF_SetCompressionMode(hDoc, "COMP_ALL")

font := HPDF_GetFont(hDoc, "Helvetica", 0)

   ;Creating a page, A4, Landscape
   page := HPDF_AddPage(hDoc)
   HPDF_Page_SetWidth(page, 172)
   HPDF_Page_SetHeight(page, 80)

   HPDF_Page_BeginText(page)
   HPDF_Page_SetFontAndSize(page, font, 20)
   HPDF_Page_MoveTextPos(page, 220, HPDF_Page_GetHeight(page) - 70)
   HPDF_Page_ShowText(page, "RawImageDemo")
   HPDF_Page_EndText(page)

   ; load RGB raw-image file.
   image := HPDF_LoadRawImageFromFile(hDoc, "rawimage/32_32_rgb.dat", 32, 32, "RGB")

   x := 20
   y := 20

   ; Draw image to the canvas.(normal-mode with actual size.)
   HPDF_Page_DrawImage(page, image, x, y, 32, 32)

   ; load GrayScale raw-image file.
   image := HPDF_LoadRawImageFromFile(hDoc, "rawimage/32_32_gray.dat", 32, 32, "GRAY")

   x := 70
   y := 20

   ; Draw image to the canvas.(normal-mode with actual size.)
   HPDF_Page_DrawImage(page, image, x, y, 32, 32)

   ; load GrayScale raw-image(1bit) file from memory.
   str =
(LTrim Join
    0xff,0xff,0xff,0xfe,0xff,0xff,0xff,0xfc,
    0xff,0xff,0xff,0xf8,0xff,0xff,0xff,0xf0,
    0xf3,0xf3,0xff,0xe0,0xf3,0xf3,0xff,0xc0,
    0xf3,0xf3,0xff,0x80,0xf3,0x33,0xff,0x00,
    0xf3,0x33,0xfe,0x00,0xf3,0x33,0xfc,0x00,
    0xf8,0x07,0xf8,0x00,0xf8,0x07,0xf0,0x00,
    0xfc,0xcf,0xe0,0x00,0xfc,0xcf,0xc0,0x00,
    0xff,0xff,0x80,0x00,0xff,0xff,0x00,0x00,
    0xff,0xfe,0x00,0x00,0xff,0xfc,0x00,0x00,
    0xff,0xf8,0x0f,0xe0,0xff,0xf0,0x0f,0xe0,
    0xff,0xe0,0x0c,0x30,0xff,0xc0,0x0c,0x30,
    0xff,0x80,0x0f,0xe0,0xff,0x00,0x0f,0xe0,
    0xfe,0x00,0x0c,0x30,0xfc,0x00,0x0c,0x30,
    0xf8,0x00,0x0f,0xe0,0xf0,0x00,0x0f,0xe0,
    0xe0,0x00,0x00,0x00,0xc0,0x00,0x00,0x00,
    0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00
)


   fillMemory(RAW_IMAGE_DATA,str)

   image := HPDF_LoadRawImageFromMem(hDoc, &RAW_IMAGE_DATA, 32, 32, "GRAY", 1)

   x := 120
   y := 20

   ; Draw image to the canvas.(normal-mode with actual size.)
   HPDF_Page_DrawImage(page, image, x, y, 32, 32)


;saving to file
HPDF_SaveToFile(hDoc, "example_rawimage_demo.pdf")

;unload dll
HPDF_UnloadDLL(hDll)

ExitApp


fillMemory(ByRef var, str)
{
   VarSetCapacity(var,128,0)

   Loop, parse, str, `,
   {
      if A_LoopField =
         continue

      NumPut(A_LoopField,var,A_Index-1,"UChar")
   }
}