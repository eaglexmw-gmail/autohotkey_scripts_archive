text := "This document is password protected."

;load the library
hpdfDllFile := A_ScriptDir "\libhpdf.dll"
hDll := HPDF_LoadDLL(hpdfDllFile)


;create new document in memory
hDoc := HPDF_New("error","000")

;Setting password, permissions and encryption
;owner-pass: owner
;user-pass: user
HPDF_SetPassword(hDoc, "owner", "user")

HPDF_SetPermission(hDoc, "READ")
HPDF_SetEncryptionMode(hDoc, "R3", 16)

;Creating a page, A4, Landscape
;+get dimensions for further usage
page := HPDF_AddPage(hDoc)
HPDF_Page_SetSize(page, "A4", "LANDSCAPE")
height := HPDF_Page_GetHeight(page)
width := HPDF_Page_GetWidth(page)


;Load a Standard-font
font := HPDF_GetFont(hDoc, "Helvetica", 0)

;Write the text to the page
HPDF_Page_BeginText(page)
HPDF_Page_SetFontAndSize(page, font, 20)
tw := HPDF_Page_TextWidth(page, text)                       ;get px-width of the text

HPDF_Page_MoveTextPos(page, (width-tw)/2, (height-20)/2)    ;use page-dimensions & textwidth to write to the center of the page
HPDF_Page_ShowText(page, text)
HPDF_Page_EndText(page)

;saving to file
HPDF_SaveToFile(hDoc, "example_permission.pdf")


;unload dll
HPDF_UnloadDLL(hDll)