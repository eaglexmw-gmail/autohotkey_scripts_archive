/*
1)
Ctrl+Shift+Z starts new color zoomer, i.e., can have multiple balloon windows.
LeftClick picks the color.
Shift+LeftClick cancels the color zoomer.
Esc or RightClick close the active balloon window.
Shift+Esc or Shift+RightClick close the active balloon window, after copying the color to the clipboard.
Ctrl+Alt+Shift closes all the balloon windows.

Also may use Alt+Space, i.e. SysMenu.

2)
Ctrl+Shift+A starts the magnifier.
Ctrl+Shift+Q starts the magnifier, with Color-Inversion.
Esc closes the magnifier.
*/
#NoEnv
SetWinDelay, 10
CoordMode, Mouse
DetectHiddenWindows, On

^+A::Magnifier()
^+Q::Magnifier(1)
^+Z::Zoomer()
#IfWinActive, ahk_group Balloons
+Esc::
+RButton::
Clipboard := GetColor()
~RButton Up::
~Esc::GroupClose, Balloons, R
#IfWinActive
^!Shift::GroupClose, Balloons, A


Zoomer()
{
   nZ := 6                      ; Zoom Factor
   nR := 108//2//nZ*nZ - 1      ; Rectangle of the Zoomer

   VarSetCapacity(nColor,63)
   nColor := A_Space
   VarSetCapacity(ti, 40, 0)
   ti := Chr(40)
    NumPut(0x20, ti, 4, "UInt")
    NumPut(&nColor, ti, 36, "UInt")

   hWnd := DllCall("CreateWindowEx", "Uint", 0x08000008, "str", "tooltips_class32", "str", "", "Uint", 0x3, "int", 0, "int", 0, "int", 0, "int", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0)

   DllCall("SetClassLong", "Uint", hWnd, "int", -12, "int", DllCall("LoadCursor", "Uint", 0, "Uint", 32515))

   SendMessage, 1028, 0, &ti,, ahk_id %hWnd%
   SendMessage, 1041, 1, &ti,, ahk_id %hWnd%
   SendMessage, 1036, 0, &ti,, ahk_id %hWnd%

   hDC_SC := DllCall("GetDC", "Uint",    0)
   hDC_TT := DllCall("GetDC", "Uint", hWnd)

   Loop
   {
      MouseGetPos, xCursor, yCursor
      DllCall("StretchBlt", "Uint", hDC_TT, "int", 0, "int", 0, "int", 2*nR, "int", 2*nR, "Uint", hDC_SC, "int", xCursor-nR//nZ, "int", yCursor-nR//nZ, "int", 2*nR//nZ, "int", 2*nR//nZ, "Uint", 0x00CC0020)
      WinMove, ahk_id %hWnd%,, xCursor-(nR+1), yCursor-(nR+1), 2*(nR+1), 2*(nR+1)   ; 1-pixel border

      If GetKeyState("LButton")
         Break
   }
   nColor := DllCall("GetPixel", "Uint", hDC_SC, "int", xCursor, "int", yCursor)

   DllCall("ReleaseDC", "Uint",    0, "Uint", hDC_SC)
   DllCall("ReleaseDC", "Uint", hWnd, "Uint", hDC_TT)

   DllCall("SetClassLong", "Uint", hWnd, "int", -12, "int", DllCall("LoadCursor", "Uint", 0, "Uint", 32512))

   If GetKeyState("Shift")
   {
      WinClose, ahk_id %hWnd%
      Return
   }

   WinSet, ExStyle, -0x08000000, ahk_id %hWnd%
   WinSet,   Style, -0x00800000, ahk_id %hWnd%
   WinSet,   Style, +0x000800C0, ahk_id %hWnd%

   SendMessage, 1042, 0, (xCursor & 0xFFFF) | (yCursor & 0xFFFF) << 16,, ahk_id %hWnd%
   SendMessage, 1043, nColor, 0,, ahk_id %hWnd%
   SendMessage, 1044,~nColor & 0xFFFFFF, 0,, ahk_id %hWnd%

   pt := "Color @(" . xCursor . "," . yCursor . ")"
   DllCall("wsprintf", "str", nColor, "str", " 0x%06X    (#BBGGRR) ", "Uint", nColor, "Cdecl")

   SendMessage, 1056, 0, &pt,, ahk_id %hWnd%
   SendMessage, 1036, 0, &ti,, ahk_id %hWnd%

   GroupAdd, Balloons, ahk_id %hWnd%
}

Magnifier(bInvert = False)
{
   nZ := 3                               ; Zoom Factor
   nW := A_ScreenWidth // 2 //2//nZ      ; Width  of (small) Target Rectangle
   nH := A_ScreenHeight// 6 //2//nZ      ; Height of (small) Target Rectangle

   ToolTip, %A_Space%
   WinGet, hWnd, ID, ahk_class tooltips_class32
   WinClose, ahk_class SysShadow      ; Comment it out to have the DropShadow
/*
   hDC_SC := DllCall("GetDC", "Uint",    0)
   hDC_LW := DllCall("GetDC", "Uint", hWnd)
   hDC_TT := DllCall("GetDC", "Uint", hWnd)
*/
hDC_SC := DllCall("GetDC", "Uint",    0)
hDC_LW := DllCall("CreateCompatibleDC", "Uint", hDC_SC)
hBM := DllCall("CreateCompatibleBitmap", "Uint", hDC_SC, "int", 2*nW, "int", 2*nH)
oBM := DllCall("SelectObject", "Uint", hDC_LW, "Uint", hBM)
hDC_TT := DllCall("GetDC", "Uint", hWnd)
   DllCall("SetStretchBltMode", "Uint", hDC_TT, "int", 4)

   Loop
   {
      If GetKeyState("Esc")
         Break
      MouseGetPos, xCursor, yCursor
 ;     DllCall("BitBlt", "Uint", hDC_LW, "int", 0, "int", 0, "int", 2*nW, "int", 2*nH, "Uint", hDC_SC, "int", xCursor-nW, "int", yCursor-nH, "Uint", 0x40CC0020)
      DllCall("BitBlt", "Uint", hDC_LW, "int", 0, "int", 0, "int", 2*nW, "int", 2*nH, "Uint", hDC_SC, "int", xCursor-nW, "int", yCursor-nH, "Uint", 0x00CC0020)
      If bInvert
      DllCall("BitBlt", "Uint", hDC_LW, "int", 0, "int", 0, "int", 2*nW, "int", 2*nH, "Uint", 0, "int", 0, "int", 0, "Uint", 0x00550009)
      Cursor(hDC_LW, nW, nH)      ; Capture magnified mouse cursor.
      DllCall("StretchBlt", "Uint", hDC_TT, "int", 0, "int", 0, "int", 2*nW*nZ, "int", 2*nH*nZ, "Uint", hDC_LW, "int", 0, "int", 0, "int", 2*nW, "int", 2*nH, "Uint", 0x00CC0020)
;      Cursor(hDC_TT, nW*nZ, nH*nZ)   ; Capture un-magnified mouse cursor.
      WinMove, ahk_id %hWnd%,, xCursor-(nW*nZ+1), yCursor+nH, 2*(nW*nZ+1), 2*(nH*nZ+1)

   }
DllCall("SelectObject", "Uint", hDC_LW, "Uint", oBM)
DllCall("DeleteObject", "Uint", hBM)
DllCall("DeleteDC", "Uint", hDC_LW)
DllCall("ReleaseDC", "Uint",    0, "Uint", hDC_SC)
DllCall("ReleaseDC", "Uint", hWnd, "Uint", hDC_TT)

/*
   DllCall("ReleaseDC", "Uint",    0, "Uint", hDC_SC)
   DllCall("ReleaseDC", "Uint", hWnd, "Uint", hDC_LW)
   DllCall("ReleaseDC", "Uint", hWnd, "Uint", hDC_TT)
*/
   WinClose, ahk_id %hWnd%
}


Cursor(hDC, xCenter, yCenter)
{
   VarSetCapacity(mi, 20, 0)
   mi := Chr(20)
   DllCall("GetCursorInfo", "Uint", &mi)

   ptr := &mi + 4
   bShow   := *ptr++ | *ptr++ << 8 | *ptr++ << 16 | *ptr++ << 24
   hCursor := *ptr++ | *ptr++ << 8 | *ptr++ << 16 | *ptr++ << 24

   DllCall("GetIconInfo", "Uint", hCursor, "Uint", &mi)

   ptr := &mi + 4
   xHotspot := *ptr++ | *ptr++ << 8 | *ptr++ << 16 | *ptr++ << 24
   yHotspot := *ptr++ | *ptr++ << 8 | *ptr++ << 16 | *ptr++ << 24
   hBMMask  := *ptr++ | *ptr++ << 8 | *ptr++ << 16 | *ptr++ << 24
   hBMColor := *ptr++ | *ptr++ << 8 | *ptr++ << 16 | *ptr++ << 24

   DllCall("DeleteObject", "Uint", hBMMask)
   DllCall("DeleteObject", "Uint", hBMColor)

   If bShow
   DllCall("DrawIcon", "Uint", hDC, "int", xCenter - xHotspot, "int", yCenter - yHotspot, "Uint", hCursor)
}

GetColor()
{
   VarSetCapacity(nColor, 8)
   SendMessage, 1046, 0, 0,, A
   DllCall("wsprintf", "str", nColor, "str", "0x%06X", "Uint", ErrorLevel, "Cdecl")
   Return nColor
}
