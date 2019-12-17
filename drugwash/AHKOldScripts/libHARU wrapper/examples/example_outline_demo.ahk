;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)

;create new document in memory
hDoc := HPDF_New("error","000")

;set compression mode
HPDF_SetCompressionMode(hDoc, "COMP_ALL")

;create default-font
font := HPDF_GetFont(hDoc, "Helvetica", 0)

   ;Set page mode to use outlines.
   HPDF_SetPageMode(hDoc, "USE_OUTLINE")

   ; Add 3 pages to the document.
   page[0] := HPDF_AddPage(hDoc)
   HPDF_Page_SetFontAndSize(page[0], font, 30)
   print_page(page[0], 1)

   page[1] := HPDF_AddPage(hDoc)
   HPDF_Page_SetFontAndSize(page[1], font, 30)
   print_page(page[1], 2)

   page[2] := HPDF_AddPage(hDoc)
   HPDF_Page_SetFontAndSize(page[2], font, 30)
   print_page(page[2], 3)

   ; create outline root.
   root := HPDF_CreateOutline(hDoc, NULL, "OutlineRoot", NULL)
   HPDF_Outline_SetOpened(root, 1)

   outline[0] := HPDF_CreateOutline(hDoc, root, "page1", NULL)
   outline[1] := HPDF_CreateOutline(hDoc, root, "page2", NULL)
   outline[2] := HPDF_CreateOutline(hDoc, root, "page3", NULL)

   ; create destination objects on each pages
   ; and link it to outline items.
   dst := HPDF_Page_CreateDestination(page[0])

   HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(page[0]), 1)
   HPDF_Outline_SetDestination(outline[0], dst)

   dst := HPDF_Page_CreateDestination(page[1])
   HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(page[1]), 1)
   HPDF_Outline_SetDestination(outline[1], dst)

   dst := HPDF_Page_CreateDestination(page[2])
   HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(page[2]), 1)
   HPDF_Outline_SetDestination(outline[2], dst)



;saving to file
HPDF_SaveToFile(hDoc, "example_outline_demo.pdf")

;unload dll
HPDF_UnloadDLL(hDll)

ExitApp


print_page(ByRef page, page_num)
{
   HPDF_Page_SetWidth(page, 800)
   HPDF_Page_SetHeight(page, 800)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 30, 740)

   buf := "Page: " page_num
   HPDF_Page_ShowText(page, buf)
   HPDF_Page_EndText(page)
}