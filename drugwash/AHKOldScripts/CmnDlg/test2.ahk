
Gui, Margin, 10, 10
Gui, Add, Text    , xm+35 ym+3   w70 h20                            , Front Color
Gui, Add, Text    , xm+95 ym+3   w70 h20                            , Back Color
Gui, Add, Text    , xm    ym+23  w25 h20                            , Note:
Gui, Add, Text    , xm+35 ym+20  w50 h20 vmyColorText_1 gChooseColor, ; Dummy control since we can't gLabel a Progress control.
Gui, Add, Progress, xm+35 ym+20  w50 h20 vmyColorWell_1             ,
Gui, Add, Text    , xm+95 ym+20  w50 h20 vmyColorText_2 gChooseColor, ; Dummy control since we can't gLabel a Progress control.
Gui, Add, Progress, xm+95 ym+20  w50 h20 vmyColorWell_2             ,

; Set saved colors.
myPrevColor_1 := 0x0000ff ; e.g. read in from an INI file.
myPrevColor_2 := 0xffff00 ; e.g. read in from an INI file.
GuiControl,                  , myColorWell_1, +100
GuiControl, +c%myPrevColor_1%, myColorWell_1
GuiControl,                  , myColorWell_2, +100
GuiControl, +c%myPrevColor_2%, myColorWell_2


Gui +LastFound
hGui := WinExist()
Gui, Show
Return

ChooseColor:
{
    CmnDlg_Color( myColor, hgui )
    OutputDebug, %myColor%
    If ( A_GuiControl = "myColorText_1" )
    {
        GuiControl,            , myColorWell_1, +100
        GuiControl, +c%myColor%, myColorWell_1,
    }
    Else If ( A_GuiControl = "myColorText_2" )
    {
        GuiControl,            , myColorWell_2, +100
        GuiControl, +c%myColor%, myColorWell_2,
    }
}
Return

GuiEscape:
GuiClose:
{
    ExitApp
}
Return

; From: http://www.autohotkey.com/forum/topic17230.html
CmnDlg_Color(ByRef pColor, hGui=0){
  ;covert from rgb
    clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF)

    VarSetCapacity(sCHOOSECOLOR, 0x24, 0)
    VarSetCapacity(aChooseColor, 64, 0)

    NumPut(0x24,       sCHOOSECOLOR, 0)      ; DWORD lStructSize
    NumPut(hGui,       sCHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal").
    NumPut(clr,          sCHOOSECOLOR, 12)     ; clr.rgbResult
    NumPut(&aChooseColor,sCHOOSECOLOR, 16)     ; COLORREF *lpCustColors
    NumPut(0x00000103,    sCHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT

    nRC := DllCall("comdlg32\ChooseColorA", str, sCHOOSECOLOR)  ; Display the dialog.
    if (errorlevel <> 0) || (nRC = 0)
       return  false

 
    clr := NumGet(sCHOOSECOLOR, 12)
   
    oldFormat := A_FormatInteger
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format.

 ;convert to rgb
    pColor := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16)
    StringTrimLeft, pColor, pColor, 2
    loop, % 6-strlen(pColor)
      pColor=0%pColor%
    pColor=0x%pColor%
    SetFormat, integer, %oldFormat%

   return true
}
