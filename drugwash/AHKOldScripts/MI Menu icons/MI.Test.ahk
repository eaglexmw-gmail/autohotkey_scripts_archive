#NoEnv
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%

; Menu functions:   SetMenuItemBitmap, SetMenuStyle, GetMenuHandle
#Include MI.Menus.ahk

; Image functions:  LoadImage, CopyImage
; Icon functions:   GetIconBitmaps, GetIconSize
; Bitmap functions: GetBitmapSize, GetDIBits, SetDIBits, CreateDIBSection
#Include MI.Image.ahk

; Vista-only:       GetBitmapFromIcon32Bit
#Include MI.Vista.ahk

; Owner-drawing:    SetMenuItemOwnerDrawnIcon, ShowOwnerDrawnMenu
#Include MI.OwnerDraw.ahk


Tests =
(
SimpleIconToBitmapTest
VistaBitmapTest
FakeAlphaTest
FakeAlphaBasedOnMaskTest
FakeAlphaBasedOnShadeTest
)

; Load the test icon.
gosub LoadSampleIcon

;
; Build the owner-draw test menu.
; (Seperate from the main menu because owner-drawing disables Vista's menu styling.)
;
Menu, MOD, Add, OwnerDrawnItem, ItemClicked
h_menu_od := GetMenuHandle("MOD")
SetMenuStyle(h_menu_od, 0x04000000) ; MNS_CHECKORBMP
SetMenuItemOwnerDrawnIcon(h_menu_od, 1, h_icon)

;
; Build the main test menu.
;
Loop, Parse, Tests, `n
{
    Menu, M, Add, %A_LoopField%, ItemClicked
    NumTests += 1
}

Menu, M, Add
Menu, M, Add, OwnerDrawTest, :MOD
Menu, M, Add
Menu, M, Add, E&xit, Exit

h_menu := GetMenuHandle("M")
SetMenuStyle(h_menu, 0x04000000) ; MNS_CHECKORBMP

SetMenuItemBitmap(h_menu, NumTests+4, 8) ; Exit icon

; used by "fake alpha" tests
cwin := DllCall("GetSysColor", "int", 4) ; COLOR_MENU
; used by *some* "fake alpha" tests
    cwin_r := (cwin&0x0000FF)
    cwin_g := (cwin&0x00FF00)>>8
    cwin_b := (cwin&0xFF0000)>>16


Loop, Parse, Tests, `n
{
    gosub %A_LoopField%
    SetMenuItemBitmap(h_menu, A_Index, hbm)
}

; Icon is not deleted because it is used by owner-drawn icon test menu.
; (Also, if h_icon refers to a system icon, DestroyIcon does nothing.)
;DllCall("DestroyIcon", "uint", h_icon)


;Menu, M, Show
; Required only for the owner-drawn test sub-menu.
ShowOwnerDrawnMenu(h_menu)

Exit:
ExitApp

ItemClicked:
    MsgBox Clicked %A_ThisMenuItem%
ExitApp


GetSampleIcon()
{
/*
32512 ; IDI_APPLICATION
32513 ; IDI_HAND
32514 ; IDI_QUESTION
32515 ; IDI_EXCLAMATION
32516 ; IDI_ASTERISK
*/
    return DllCall("LoadImage"
        , "uint", 0
        , "uint", 32513 ; IDI_HAND
        , "uint", 1     ; IMAGE_ICON
        , "int", 32
        , "int", 32
        , "uint", 0x8000) ; LR_SHARED (required to load system icons)
    
    ;return LoadImage("test.ico", 1) ; load an icon
}

LoadSampleIcon:
    h_icon := GetSampleIcon()
    if (!h_icon) {
        MsgBox, Failed to load sample icon. :(
        ExitApp
    }
return


; Simply retrieves an icon's colour bitmap, with no transparency information.
SimpleIconToBitmapTest:
    GetIconBitmaps(h_icon, hbm, hbm_m)
    
    ; Delete temporary mask bitmap.
    DllCall("DeleteObject", "uint", hbm_m)
return


; Converts an icon to a 32-bit DIB. On Windows Vista, this is alpha-blended
; (i.e. the icon can have transparency.)
VistaBitmapTest:
    ; Note: this is called by GetBitmapFromIcon() automatically
    ; if (A_OSVersion = "WIN_VISTA").
    hbm := GetBitmapFromIcon32Bit(h_icon)
return


; Blends the menu colour into the bitmap to fake transparency.
; If the icon has alpha data, it is used, otherwise the icon's mask is used.
FakeAlphaTest:
    GetIconBitmaps(h_icon, hbm, hbm_m)
    
    GetBitmapSize(hbm, width, height)

    GetDIBits(hbm, 32, bits)
    
    has_alpha := false
    Loop, % width*height
        if (NumGet(bits, (A_Index-1)*4) & 0xFF000000) {
            has_alpha := true
            break
        }
    
    if ! has_alpha
        goto FakeAlphaBasedOnMask
    
    offset = 0
    Loop, % width*height
    {
        clr := NumGet(bits, offset)
    
        ; Note the order of the bytes is the reverse of normal Win32 colours (like GetSysColor()).
        r := (clr&0xFF0000) >> 16
        g := (clr&0x00FF00) >>  8
        b := (clr&0x0000FF)
        
        a := (clr&0xFF000000) >> 24
        
        ; Blend the colour of this pixel with the menu colour.
        clr := ((r*a + cwin_r*(255-a)) // 255) << 16
             | ((g*a + cwin_g*(255-a)) // 255) << 8
             |  (b*a + cwin_b*(255-a)) // 255
        
        NumPut(clr, bits, offset)
        
        offset += 4
    }

    SetDIBits(hbm, 32, bits)
    
    ; Delete temporary mask bitmap.
    DllCall("DeleteObject", "uint", hbm_m)
return


; Blends the menu colour into the bitmap to fake transparency.
; Ignores alpha data and uses the icon's mask.
FakeAlphaBasedOnMaskTest:
    GetIconBitmaps(h_icon, hbm, hbm_m)
    
    GetBitmapSize(hbm, width, height)
    
    GetDIBits(hbm, 32, bits)

FakeAlphaBasedOnMask:
    GetDIBits(hbm_m, 32, bits_m)
    
    offset = 0
    Loop, % width*height
    {
        ; A positive mask pixel value means the pixel is transparent.
        ; In this case, set the pixel to the menu colour.
        if (NumGet(bits_m, offset))
        ; Note: GetSysColor values are ABGR, while DIB values are ARGB.
            NumPut(cwin_r<<16 | cwin_g<<8 | cwin_b, bits, offset)
        
        offset += 4
    }
    
    SetDIBits(hbm, 32, bits)
    
    ; Delete temporary mask bitmap.
    DllCall("DeleteObject", "uint", hbm_m)
return


; Blends the menu colour into the bitmap based on the shade of each pixel.
FakeAlphaBasedOnShadeTest:
    GetIconBitmaps(h_icon, hbm, hbm_m)

    ; Delete temporary mask bitmap.
    DllCall("DeleteObject", "uint", hbm_m)
    
    GetBitmapSize(hbm, width, height)
    
    GetDIBits(hbm, 32, bits)
    
    offset = 0
    Loop, % width*height
    {
        clr := NumGet(bits, offset)
    
        ; Note the order of the bytes is the reverse of normal Win32 colours (like GetSysColor()).
        r := (clr&0xFF0000) >> 16
        g := (clr&0x00FF00) >>  8
        b := (clr&0x0000FF)
        
        ; Calculate alpha/transparency based on shade.
        a := ((r+g+b)//3)
        
        ; Blend the colour of this pixel with the menu colour.
        clr := ((r*a + cwin_r*(255-a)) // 255) << 16
             | ((g*a + cwin_g*(255-a)) // 255) << 8
             |  (b*a + cwin_b*(255-a)) // 255
        
        NumPut(clr, bits, offset)
        
        offset += 4
    }
    
    SetDIBits(hbm, 32, bits)
return
