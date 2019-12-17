;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)

;create new document in memory
hDoc := HPDF_New("error","000")

;Creating a page, A4, Landscape
page := HPDF_AddPage(hDoc)
HPDF_Page_SetSize(page, "A4", "LANDSCAPE")

;Draw the actual grid
print_grid(hDoc,page,10,2,2)

;saving to file
HPDF_SaveToFile(hDoc, "example_grid_sheet.pdf")

;unload dll
HPDF_UnloadDLL(hDll)

ExitApp


