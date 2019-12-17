_CreateImageButton_(HWND, BC, TC = "", 3D = "", GC = "") {
   ; ---------------------------------------------------------------------------
   ; _CreateImageButton_()
   ; Author:               (de)nick
   ; AHK Version:          1.47.06
   ; OS Version:           Win XP Sp2
   ; History:              Version 1.0.0 (initial release)
   ;
   ; Function:
   ;     Create a bitmap from a button and set it as the button's image
   ; Parameter:
   ;     HWND              Button's HWND
   ;     BC                Background color (6-digit RGB color value)
   ;     TC    Optional    Text color (6-digit RGB color value)
   ;                       Default = 000000 (black)
   ;     3D    Optional    3D presentation (0 = none | 1 = raised | 2 = 3D)
   ;                       Default = 0
   ;     GC    Optional    Start/End color for 3D (6-digit RGB color value)
   ;                       Default = 202020 (dark gray)
   ; Returnvalue:
   ;     hBITMAP           Handle to the bitmap, the bitmap should be deleted
   ;                       with   DllCall("DeleteObject", "UInt", hBITMAP)
   ;                       before the program exits.
   ; Special features:
   ;     Optional parameters default values can be changed by function call
   ;     with HWND = "Set", BC = "Parameter" and TC = "New Value".
   ;     Because a function expects expressions all values have to be
   ;     enclosed in double quotes!
   ; ---------------------------------------------------------------------------
   ; Windows constants
   Static BS_CHECKBOX := 0x2
   Static BS_RADIOBUTTON := 0x8

   Static BS_RIGHTBUTTON := 0x20
   Static BS_BITMAP := 0x80
   Static BM_SETIMAGE := 0xF7
   Static IMAGE_BITMAP := 0x0
   Static GRADIENT_FILL_RECT_V := 0x1
   Static WM_GETFONT := 0x31
   Static DT_LEFT := 0x0
   Static DT_CENTER := 0x1
   Static DT_RIGHT := 0x2
   Static DT_SINGLELINE := 0x20
   Static DT_VCENTER := 0x4
   Static TRANSPARENT := 0x1
   Static BITSPIXEL := 0xC
   ; Default values
   Static SETDEFAULTS := "Set"
   Static DEFAULTS := "|TC|3D|GC|"
   Static DEFTC := "000000"
   Static DEF3D := 0
   Static DEFGC := "202020"
   ; ---------------------------------------------------------------------------
   ; Get new default values
   If (HWND = SETDEFAULTS) {
      If InStr(DEFAULTS, "|" BC "|") {
         DEF%BC% := TC
         Return True
      } Else {
         Return False
      }
   }
   ; Set default values if necessary
   If (TC = "") {
      TC := DEFTC
   }
   If (3D = "") {
      3D := DEF3D
   }
   If (GC = "") {
      GC := DEFGC
   }
   ; Get the button's font
   SendMessage, WM_GETFONT, 0, 0, , ahk_id %HWND%
   hFONT := ErrorLevel
   ; Get button's caption
   VarSetCapacity(TX, 256, 0)
   DllCall("GetWindowText", "UInt", HWND, "Str", TX, "Int", 255)
   VarSetCapacity(TX, -1)
   ; Get button's dimensions
   VarSetCapacity(RC, 16, 0)
   DllCall("GetClientRect", "UInt", HWND, "UInt", &RC)
   W := NumGet(RC,8), H := NumGet(RC,12)
   ; Create a compatible device context (DC)
   hDC := DllCall("CreateCompatibleDC")
   ; Get the color depth
   BP := DllCall("GetDeviceCaps", "UInt", hDC, "Int", BITSPIXEL)
   ; Create a DIBSection
   ; BI : BITMAPINFO
   VarSetCapacity(BI, 40, 0)
   NumPut(40,BI,0)
   NumPut(W,BI,4)
   NumPut(-H,BI,8)
   NumPut(1,BI,12,"UShort")
   NumPut(BP,BI,14,"UShort")
   NumPut(0,BI,16)
   hBM := DllCall("CreateDIBSection"
                , "UInt" , hDC
                , "UInt" , &BI
                , "UInt" , 0
                , "UInt*", 0
                , "UInt" , 0
                , "UInt" , 0)
   ; Select the DIBSection for use in DC
   DllCall("SelectObject"
         , "Uint", hDC
         , "UInt", hBM)
   ; Split the background color into R, G, B
   R := "0x" SubStr(BC, 1, 2) "00"
   G := "0x" SubStr(BC, 3, 2) "00"
   B := "0x" SubStr(BC, 5, 2) "00"
   ; Werte für 3D setzen
   If (3D = 0) {
      SR := ER := R
      SG := EG := G
      SB := EB := B
      HG := 0
   } Else {
      SR := ER := "0x" SubStr(GC, 1, 2) "00"
      SG := EG := "0x" SubStr(GC, 3, 2) "00"
      SB := EB := "0x" SubStr(GC, 5, 2) "00"
      HG := (3D = 1 ? H // 6 : H // 2)
   }
   ; Now the DIBSection gets a gradient filling
   ; TV : TRIVERTEX
   VarSetCapacity(TV, 16 * 6, 0)
   ; TV1
   NumPut(0,TV,0,"Int"),NumPut(0,TV,4,"Int"),NumPut(SR,TV,8,"UShort")
   NumPut(SG,TV,10,"UShort"),NumPut(SB,TV,12,"UShort"),NumPut(0,TV,14,"UShort")
   ; TV2
   NumPut(W,TV,16,"Int"),NumPut(HG-1,TV,20,"Int"),NumPut(R,TV,24,"UShort")
   NumPut(G,TV,26,"UShort"),NumPut(B,TV,28,"UShort"),NumPut(0,TV,30,"UShort")
   ; TV3
   NumPut(0,TV,32,"Int"),NumPut(HG-1,TV,36,"Int"),NumPut(R,TV,40,"UShort")
   NumPut(G,TV,42,"UShort"),NumPut(B,TV,44,"UShort"),NumPut(0,TV,46,"UShort")
   ; TV4
   NumPut(W,TV,48,"Int"),NumPut(H-HG,TV,52, "Int"),NumPut(R,TV,56,"UShort")
   NumPut(G,TV,58,"UShort"),NumPut(B,TV,60,"UShort"),NumPut(0,TV,62,"UShort")
   ; TV5
   NumPut(0,TV,64,"Int"),NumPut(H-HG,TV,68,"Int"),NumPut(R,TV,72,"UShort")
   NumPut(G,TV,74,"UShort"),NumPut(B,TV,76,"UShort"),NumPut(0,TV,78,"UShort")
   ; Tv6
   NumPut(W,TV,80,"Int"),NumPut(H,TV,84,"Int"),NumPut(ER,TV,88,"UShort")
   NumPut(EG,TV,90,"UShort"),NumPut(EB,TV,92,"UShort"),NumPut(0,TV,94,"UShort")
   ; GR : GRADIENT_RECT
   VarSetCapacity(GR, 24, 0)
   ; GR1
   NumPut(0,GR,0),NumPut(1,GR,4)
   ; GR2
   NumPut(2,GR,8),NumPut(3,GR,12)
   ; GR3
   NumPut(4,GR,16),NumPut(5,GR,20)
   ; BOOL GradientFill(
   ;   HDC hdc,                   // handle to DC
   ;   PTRIVERTEX pVertex,        // array of vertices
   ;   ULONG dwNumVertex,         // number of vertices
   ;   PVOID pMesh,               // array of gradients
   ;   ULONG dwNumMesh,           // size of gradient array
   ;   ULONG dwMode               // gradient fill mode
   ; );
   DllCall("msimg32.dll\GradientFill"
         , "Uint", hDC
         , "UInt", &TV
         , "UInt", 6
         , "UInt", &GR
         , "UInt", 3
         , "UInt", GRADIENT_FILL_RECT_V)
   ; Select the font for use in DC
   DllCall("SelectObject", "Uint", hDC, "UInt", hFONT)
   ; Set the background of text to transparent
   DllCall("SetBkMode", "UInt", hDC, "UInt", TRANSPARENT)
   ; Set the text color
   COLORREF := "0x00" SubStr(TC, 5) SubStr(TC, 3, 2) SubStr(TC, 1, 2)
   DllCall("SetTextColor", "UInt", hDC, "UInt", COLORREF)
   ; Check how the text has to be aligned horizontally
   ControlGet, Style, Style, , , ahk_id %HWND%
   IF (Style & BS_RADIOBUTTON) Or (Style & BS_CHECKBOX) {
      If (Style & BS_RIGHTBUTTON) {
         DT_HALIGN := DT_RIGHT
      } Else {
         DT_HALIGN := DT_LEFT
      }
   } Else {
      DT_HALIGN := DT_CENTER
   }
   ; And now we may draw the text
   ; int DrawText(
   ;   HDC hDC,          // handle to DC
   ;   LPCTSTR lpchText, // text to draw
   ;   int nCount,       // text length
   ;   LPRECT lpRect,    // formatting dimensions
   ;   UINT uFormat      // text-drawing options
   ; );
   DllCall("DrawText"
         , "UInt", hDC
         , "Str", TX
         , "Int", -1
         , "UInt", &RC
         , "UInt", DT_HALIGN | DT_VCENTER | DT_SINGLELINE)
   ; Get the bitmap from the DC
   ; BM : BITMAP
   VarSetCapacity(BM, 24, 0)
   DllCall("GetObject", "UInt", hBM, "Int", 24, "UInt", &BM)
   ; Create a new bitmap object with the values gotten
   hBITMAP := DllCall("CreateBitmapIndirect", "Uint", &BM)
   ; The DIBSection may be deleted
   DllCall("DeleteObject", "UInt", hBM)
   ; The DC may be deleted
   DllCall("DeleteDC", "UInt", hDC)
   ; Set button's style to BS_BITMAP
   Control, Style, +%BS_BITMAP%, , ahk_id %HWND%
   ; Assign the bitmap to the button
   SendMessage, BM_SETIMAGE, IMAGE_BITMAP, hBITMAP, , ahk_id %HWND%
   ; Return hBITMAP for subsequent DeleteObject()
   Return hBITMAP
}
