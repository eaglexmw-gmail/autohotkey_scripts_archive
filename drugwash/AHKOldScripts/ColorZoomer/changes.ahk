; http://www.autohotkey.com/forum/viewtopic.php?p=275917#275917

Before the loop:
Code (Copy):
hDC_TT := DllCall("GetDC", "Uint", hWnd)
hDC_SC := DllCall("GetDC", "Uint",    0)
hDC_LW := DllCall("CreateCompatibleDC", "Uint", hDC_SC)
hBM := DllCall("CreateCompatibleBitmap", "Uint", hDC_SC, "int", 2*nW, "int", 2*nH)
oBM := DllCall("SelectObject", "Uint", hDC_LW, "Uint", hBM)
DllCall("SetStretchBltMode", "Uint", hDC_TT, "int", 4)
 

After the loop:
Code (Copy):
DllCall("SelectObject", "Uint", hDC_LW, "Uint", oBM)
DllCall("DeleteObject", "Uint", hBM)
DllCall("DeleteDC", "Uint", hDC_LW)
DllCall("ReleaseDC", "Uint",    0, "Uint", hDC_SC)
DllCall("ReleaseDC", "Uint", hWnd, "Uint", hDC_TT)
 

