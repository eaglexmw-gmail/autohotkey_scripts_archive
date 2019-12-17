_CreateImageButton_(HWND, BC, TC = "", 3D = "", GC = "") {
   ; ---------------------------------------------------------------------------
   ; _CreateImageButton_()
   ; Author:               (de)nick
   ; AHK Version:          1.0.48.00
   ; OS Version:           Win XP Sp2
   ; History:              Version 1.0.0 (initial release)
   ;     2009-03-25        Version 2.0.0 (ImageList + Multiline + Theme)
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
   ;     In case of call with HWND = "Set" the function returns false,
   ;     if the action fails, otherwise always true.
   ; Special features:
   ;     Optional parameters default values can be changed by function call
   ;     with HWND = "Set", BC = "Parameter" and TC = "New Value".
   ;     Because a function expects expressions all values have to be
   ;     enclosed in double quotes!
   ; ---------------------------------------------------------------------------
   ; Windows Constants
   Static BCM_FIRST := "0x1600"
   Static BCM_GETIDEALSIZE := "0x1601"    ; BCM_FIRST + 0x1
   Static BCM_SETIMAGELIST := "0x1602"    ; BCM_FIRST + 0x2
   Static BITSPIXEL := "0xC"
   Static BS_CHECKBOX := "0x2"
   Static BS_RADIOBUTTON := "0x4"
   Static BS_GROUPBOX := "0x7"
   Static BS_AUTORADIOBUTTON := "0x9"
   Static BS_RIGHTBUTTON := "0x20"
   Static BS_LEFT := "0x100"
   Static BS_RIGHT := "0x200"
   Static BS_CENTER := "0x300"
   Static BS_TOP := "0x400"
   Static BS_BOTTOM := "0x800"
   Static BS_VCENTER := "0xC00"
   Static BS_MULTILINE := "0x2000"
   Static BM_SETIMAGE := "0xF7"
   Static BUTTON_IMAGELIST_ALIGN_CENTER := "4"
   Static DT_LEFT := "0x0"
   Static DT_TOP := "0x0"
   Static DT_CENTER := "0x1"
   Static DT_RIGHT := "0x2"
   Static DT_VCENTER := "0x4"
   Static DT_BOTTOM := "0x8"
   Static DT_SINGLELINE := "0x20"
   Static DT_NOCLIP := "0x100"
   Static DT_CALCRECT := "0x400"
   Static GRADIENT_FILL_RECT_V := "0x1"
   Static ILC_COLORDDB := "0xFE"          ; device dependend color depth
   Static TRANSPARENT := "0x1"
   Static WM_GETFONT := "0x31"
   ; Defaults
   Static SETDEFAULTS := "Set"
   Static DEFAULTS := "|TC|3D|GC|"
   Static DEFTC := "000000"
   Static DEF3D := 0
   Static DEFGC := "C0C0C0"
   ; RadioButtons and CheckBoxes
   RCBUTTONS := BS_CHECKBOX | BS_RADIOBUTTON | BS_AUTORADIOBUTTON
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
   ; Get the button's font ...
   SendMessage, WM_GETFONT, 0, 0, , ahk_id %HWND%
   hFONT := ErrorLevel
   ; ... and it's caption.
   VarSetCapacity(TX, 256, 0)
   DllCall("GetWindowText", "UInt", HWND, "Str", TX, "Int", 255)
   VarSetCapacity(TX, -1)
   ; Get button's client rectangle ...
   VarSetCapacity(RC, 16, 0)
   DllCall("GetClientRect", "UInt", HWND, "UInt", &RC)
   W := NumGet(RC, 8)
   H := NumGet(RC, 12)
   ; ... the width of a small icon ...
   SysGet, SMIW, 49
   ; .. and the button styles ...
   ControlGet, S, Style, , , ahk_id %HWND%
   ; ... and now the rectangle may be adjusted type dependend:
   ; You may play a little in the Else branch. Reasonable values are even
   ; numbers between 0 and 8. The values affect the visibility of Windows
   ; built-in button animation.
   If (S & RCBUTTONS)
      W -= (SMIW)
   Else
      W -= 8, H -= 8
   NumPut(W, RC, 8)
   NumPut(H, RC, 12)
   ; Create a compatible device context (DC) ...
   hDC := DllCall("CreateCompatibleDC", "UInt", 0)
   ; ... get the color depth ...
   BP := DllCall("GetDeviceCaps", "UInt", hDC, "Int", BITSPIXEL)
   ; ... and create a DIBSection
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
   ; Check the 3D parameter
   If (3D = 0) {
      ; The background is a plain filled rectangle
      ; HBRUSH CreateSolidBrush(
      ;   __in  COLORREF crColor
      ; );
      ; int FillRect(
      ;   __in  HDC hDC,
      ;   __in  const RECT *lprc,
      ;   __in  HBRUSH hbr
      ; );
      COLORREF := "0x00" SubStr(BC, 5) SubStr(BC, 3, 2) SubStr(BC, 1, 2)
      hBR := DllCall("CreateSolidBrush", "UInt", COLORREF)
      DllCall("FillRect", "UInt", hDC, "UInt", &RC, "UInt", hBR)
      DllCall("DeleteObject", "UInt", hBR)
   } Else {
      ; The background needs a gradient fill
      SR := ER := "0x" SubStr(GC, 1, 2) "00"
      SG := EG := "0x" SubStr(GC, 3, 2) "00"
      SB := EB := "0x" SubStr(GC, 5, 2) "00"
      HG := (3D = 1 ? 2 : H // 2)
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
      NumPut(W,TV,48,"Int"),NumPut(H-HG-1,TV,52,"Int"),NumPut(R,TV,56,"UShort")
      NumPut(G,TV,58,"UShort"),NumPut(B,TV,60,"UShort"),NumPut(0,TV,62,"UShort")
      ; TV5
      NumPut(0,TV,64,"Int"),NumPut(H-HG-1,TV,68,"Int"),NumPut(R,TV,72,"UShort")
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
   }
   ; Select the font for use in DC
   DllCall("SelectObject", "Uint", hDC, "UInt", hFONT)
   ; Set the background of text to transparent
   DllCall("SetBkMode", "UInt", hDC, "UInt", TRANSPARENT)
   ; Set the text color
   COLORREF := "0x00" SubStr(TC, 5) SubStr(TC, 3, 2) SubStr(TC, 1, 2)
   DllCall("SetTextColor", "UInt", hDC, "UInt", COLORREF)
   ; Check how the text has to be aligned horizontally
   DT_HALIGN := (S & BS_CENTER) = BS_CENTER ? DT_CENTER
              : (S & BS_CENTER) = BS_RIGHT  ? DT_RIGHT
              : (S & BS_CENTER) = BS_LEFT  ? DT_LEFT
              : (S & RCBUTTONS) ? DT_LEFT
              : DT_Center
   ; Calculate the text's rectangle ...
   ; int DrawText(
   ;   HDC hDC,          // handle to DC
   ;   LPCTSTR lpchText, // text to draw
   ;   int nCount,       // text length
   ;   LPRECT lpRect,    // formatting dimensions
   ;   UINT uFormat      // text-drawing options
   ; );
   VarSetCapacity(CR, 16, 0)
   DllCall("DrawText"
         , "UInt", hDC
         , "Str", TX
         , "Int", -1
         , "UInt", &CR
         , "UInt", DT_HALIGN | DT_CALCRECT)
   ; ... and adjust rectangle's position if necessary
   If (NumGet(CR, 12) < H)
      NumPut((H - NumGet(CR, 12) + 1) // 2, RC, 4)
   ; Now the text may be drawn
   DllCall("DrawText"
         , "UInt", hDC
         , "Str", TX
         , "Int", -1
         , "UInt", &RC
         , "UInt", DT_HALIGN)
   ; Get the bitmap from the DC
   ; BM : BITMAP
   VarSetCapacity(BM, 24, 0)
   DllCall("GetObject", "UInt", hBM, "Int", 24, "UInt", &BM)
   ; Create a new bitmap object with the gotten values
   hBITMAP := DllCall("CreateBitmapIndirect", "Uint", &BM)
   ; The DIBSection may be deleted
   DllCall("DeleteObject", "UInt", hBM)
   ; The DC may be deleted
   DllCall("DeleteDC", "UInt", hDC)
   ; Create an ImageList
   hIL := DllCall("ImageList_Create"
                , "UInt", W
                , "UInt", H
                , "UInt", ILC_COLORDDB
                , "UInt", 8
                , "UInt", 0)
   ; Here's some playground again: If only one bitmap is added to the ImageList
   ; it will be used for all button states, but you may add a separate bitmap
   ; for each button state. MSDN points out 6 states for PushButtons:
   ; enum PUSHBUTTONSTATES {
   ;    PBS_NORMAL = 1,
   ;    PBS_HOT = 2,
   ;    PBS_PRESSED = 3,
   ;    PBS_DISABLED = 4,
   ;    PBS_DEFAULTED = 5,
   ;    PBS_STYLUSHOT = 6,    (Tablet PC only)
   ; };
   ; In contrast RadioButtons have 8 states and CheckBoxes up to 12.
   Loop, 1
      DllCall("ImageList_Add", "UInt", hIL, "UInt", hBITMAP, "UInt", 0)
   ; Create a BUTTON_IMAGELIST structure
   ; typedef struct {
   ;    HIMAGELIST himl;
   ;    RECT margin;
   ;    UINT uAlign;
   ; } BUTTON_IMAGELIST, *PBUTTON_IMAGELIST;
   VarSetCapacity(BIL, 24, 0)
   NumPut(hIL, BIL)
   Numput(BUTTON_IMAGELIST_ALIGN_CENTER, BIL, 20)
   ; Assign the ImageList to the button
   SendMessage, BCM_SETIMAGELIST, 0, &BIL, , ahk_id %HWND%
   ; Delete buttons's primary caption
   ControlSetText, , , ahk_ID %HWND%
   ; The bitmap may be deleted
   DllCall("DeleteObject", "UInt", hBITMAP)
   ; Done!
   Return True
}
