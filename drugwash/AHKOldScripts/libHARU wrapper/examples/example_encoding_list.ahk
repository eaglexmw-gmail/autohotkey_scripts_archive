;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)

;create new document in memory
hDoc := HPDF_New("error","000")

;set compression mode
HPDF_SetCompressionMode(hDoc, "COMP_ALL")
HPDF_SetPageMode(hDoc, "USE_OUTLINE")
font := HPDF_GetFont(hDoc, "Helvetica", 0)

   PAGE_WIDTH := 420
   PAGE_HEIGHT := 400
   CELL_WIDTH := 20
   CELL_HEIGHT := 20
   CELL_HEADER := 10

   encodings = StandardEncoding,MacRomanEncoding,WinAnsiEncoding,ISO8859-2,ISO8859-3,ISO8859-4,ISO8859-5,
   encodings = %encodings%ISO8859-9,ISO8859-10,ISO8859-13,ISO8859-14,ISO8859-15,ISO8859-16,
   encodings = %encodings%CP1250,CP1251,CP1252,CP1254,CP1257,KOI8-R,Symbol-Set,ZapfDingbats-Set

   font_name := HPDF_LoadType1FontFromFile(hDoc, "type1\\a010013l.afm", "type1\\a010013l.pfb")

   ;create outline root.
   root := HPDF_CreateOutline(hDoc, NULL, "Encoding list", NULL)
   HPDF_Outline_SetOpened(root, 1)

   loop, parse, encodings, `,
   {
      page := HPDF_AddPage(hDoc)

      HPDF_Page_SetWidth(page, PAGE_WIDTH)
      HPDF_Page_SetHeight(page, PAGE_HEIGHT)

      outline := HPDF_CreateOutline(hDoc, root, A_LoopField, NULL)
      dst := HPDF_Page_CreateDestination(page)
      HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(page), 1)

      HPDF_Outline_SetDestination(outline, dst)

      HPDF_Page_SetFontAndSize(page, font, 15)
      draw_graph(page)

      HPDF_Page_BeginText(page)
      HPDF_Page_SetFontAndSize(page, font, 20)
      HPDF_Page_MoveTextPos(page, 40, PAGE_HEIGHT - 50)
      HPDF_Page_ShowText(page, A_LoopField)
      HPDF_Page_ShowText(page, " Encoding")
      HPDF_Page_EndText(page)

      if(A_LoopField == "Symbol-Set")
         font2 := HPDF_GetFont(hDoc, "Symbol", 0)
      else if(A_LoopField == "ZapfDingbats-Set")
         font2 := HPDF_GetFont(hDoc, "ZapfDingbats", 0)
      else
         font2 := HPDF_GetFont2(hDoc, font_name, A_LoopField)

      HPDF_Page_SetFontAndSize(page, font2, 14)

      draw_fonts(page)

      i++
   }

;saving to file
HPDF_SaveToFile(hDoc, "example_encoding_list.pdf")

;unload dll
HPDF_UnloadDLL(hDll)

ExitApp




; Draw 16 X 15 cells
draw_graph(ByRef page)
{
   PAGE_WIDTH := 420
   PAGE_HEIGHT := 400
   CELL_WIDTH := 20
   CELL_HEIGHT := 20
   CELL_HEADER := 10

   ; Draw vertical lines.
   HPDF_Page_SetLineWidth(page, 0.5)

   loop, 18
   {
      i := A_Index-1
      x := i * CELL_WIDTH + 40

      HPDF_Page_MoveTo(page, x, PAGE_HEIGHT - 60)
      HPDF_Page_LineTo(page, x, 40)
      HPDF_Page_Stroke(page)

      if(i > 0 && i <= 16)
      {
         HPDF_Page_BeginText(page)
         HPDF_Page_MoveTextPos(page, x + 5, PAGE_HEIGHT - 75)

         buf := i-1
         if buf = 10
            buf = A
         if buf = 11
            buf = B
         if buf = 12
            buf = C
         if buf = 13
            buf = D
         if buf = 14
            buf = E
         if buf = 15
            buf = F

         HPDF_Page_ShowText(page, buf)
         HPDF_Page_EndText(page)
      }
   }

   loop, 16
   {
      i := A_Index - 1
      y := i * CELL_HEIGHT + 40

      HPDF_Page_MoveTo(page, 40, y)
      HPDF_Page_LineTo(page, PAGE_WIDTH - 40, y)
      HPDF_Page_Stroke(page)

      if(i < 14)
      {
         HPDF_Page_BeginText(page)
         HPDF_Page_MoveTextPos(page, 45, y + 5)

         buf := 15-i
         if buf = 10
            buf = A
         if buf = 11
            buf = B
         if buf = 12
            buf = C
         if buf = 13
            buf = D
         if buf = 14
            buf = E
         if buf = 15
            buf = F


         HPDF_Page_ShowText(page, buf)
         HPDF_Page_EndText(page)
      }
   }
}


draw_fonts(ByRef page)
{
   PAGE_WIDTH := 420
   PAGE_HEIGHT := 400
   CELL_WIDTH := 20
   CELL_HEIGHT := 20
   CELL_HEADER := 10

   HPDF_Page_BeginText(page)

   ; Draw all character from 0x20 to 0xFF to the canvas.
   loop, 16
   {
      i := A_Index

      loop, 16
      {
         j := A_Index

         y := PAGE_HEIGHT - 55 - ((i - 1) * CELL_HEIGHT)
         x := j * CELL_WIDTH + 50

         char := (i - 1) * 16 +(j - 1)
         if(char >= 32)
         {
             d := x - HPDF_Page_TextWidth(page,chr(char)) / 2
             HPDF_Page_TextOut(page, d, y,chr(char))
         }
     }
   }

   HPDF_Page_EndText(page)
}
