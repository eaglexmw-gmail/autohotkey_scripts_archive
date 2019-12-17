;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)

;create new document in memory
hDoc := HPDF_New("error","000")

;Creating a page, A4, Landscape
;+get dimensions for further usage
page := HPDF_AddPage(hDoc)

HPDF_Page_SetHeight(page, 220)
HPDF_Page_SetWidth(page, 200)
print_grid(hDoc, page)


    ;draw pie chart
    ;
    ;   A: 45% Red
    ;   B: 25% Blue
    ;   C: 15% green
    ;   D: other yellow
    ;

    ; A
    HPDF_Page_SetRGBFill(page, 1.0, 0, 0)
    HPDF_Page_MoveTo(page, 100, 100)
    HPDF_Page_LineTo(page, 100, 180)
    HPDF_Page_Arc(page, 100, 100, 80, 0, 360 * 0.45)
    pos = HPDF_Page_GetCurrentPos(page)
    HPDF_GetPoint(pos, posx, posy)
    HPDF_Page_LineTo(page, 100, 100)
    HPDF_Page_Fill(page)

    ; B
    HPDF_Page_SetRGBFill(page, 0, 0, 1.0)
    HPDF_Page_MoveTo(page, 100, 100)
    HPDF_Page_LineTo(page, posx, posy)
    HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.45, 360 * 0.7)
    pos = HPDF_Page_GetCurrentPos(page)
    HPDF_GetPoint(pos, posx, posy)
    HPDF_Page_LineTo(page, 100, 100)
    HPDF_Page_Fill(page)

    ; C
    HPDF_Page_SetRGBFill(page, 0, 1.0, 0)
    HPDF_Page_MoveTo(page, 100, 100)
    HPDF_Page_LineTo(page, posx, posy)
    HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.7, 360 * 0.85)
    pos = HPDF_Page_GetCurrentPos(page)
    HPDF_GetPoint(pos, posx, posy)
    HPDF_Page_LineTo(page, 100, 100)
    HPDF_Page_Fill(page)

    ;D
    HPDF_Page_SetRGBFill(page, 1.0, 1.0, 0)
    HPDF_Page_MoveTo(page, 100, 100)
    HPDF_Page_LineTo(page, posx, posy)
    HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.85, 360)
    pos = HPDF_Page_GetCurrentPos(page)
    HPDF_GetPoint(pos, posx, posy)
    HPDF_Page_LineTo(page, 100, 100)
    HPDF_Page_Fill(page)

    ;draw center circle
    HPDF_Page_SetGrayStroke(page, 0)
    HPDF_Page_SetGrayFill(page, 1)
    HPDF_Page_Circle(page, 100, 100, 30)
    HPDF_Page_Fill(page)

;saving to file
HPDF_SaveToFile(hDoc, "example_arc.pdf")


;unload dll
HPDF_UnloadDLL(hDll)