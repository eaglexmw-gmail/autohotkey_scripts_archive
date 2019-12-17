#NoEnv ;Must be specified to work - tried to find out why, no luck
#Include MenuLibraryTestSetup.ahk

;Example taken from Lexikos' menu icons (and modified to show off menu wrapper functionality
;
; Icons in the Tray menu!
;
; Refer to a menu by handle for efficiency.
hTM := MI_GetMenuHandle("Tray")

SplitPath, A_AhkPath,, SpyPath
SpyPath = %SpyPath%\AU3_Spy.exe

MI_SetMenuItemIcon(hTM, 1, A_AhkPath, 1, 16) ; open
MI_SetMenuItemIcon(hTM, 2, A_WinDir "\hh.exe", 1, 16) ; help
;-
MI_SetMenuItemIcon(hTM, 4, SpyPath,   1, 16) ; spy
; reload - icon needed!
MI_SetMenuItemIcon(hTM, 6, A_AhkPath, 2, 16) ; edit
;-
MI_SetMenuItemIcon(hTM, 8, A_AhkPath, 3, 16) ; suspend
MI_SetMenuItemIcon(hTM, 9, A_AhkPath, 4, 16) ; pause
MI_SetMenuItemBitmap(hTM, 10, 8) ; exit


;Menu wrapper functionality

MenuItem := Menu_Add("Menu1", "Item1", "OutputSelection1")
MI_SetMenuItemIcon("Menu1", 1, A_AhkPath, 1, 16)
Menu, Menu1, default, Item1
MenuItem_setValue1(MenuItem, "Menu1->Item1")
MenuItem_setValue2(MenuItem, 1)

MenuItem := Menu_Add("Menu1", "Item2", "OutputSelection2")
Menu, Menu1, check, Item2
MI_SetMenuItemIcon("Menu1", 2, A_AhkPath, 2, 16)
MenuItem_setValue1(MenuItem, "Menu1->Item2")
MenuItem_setValue2(MenuItem, 2)

MenuItem := Menu_Add("Menu1", "Item3", "OutputSelection3")
MI_SetMenuItemIcon("Menu1", 3, A_AhkPath, 3, 16)
MenuItem_setValue1(MenuItem, "Menu1->Item3")
MenuItem_setValue2(MenuItem, 3)

MenuItem := Menu_Add("Menu1", "Item4", "OutputSelection4")
MI_SetMenuItemIcon("Menu1", 4, A_AhkPath, 4, 16)
MenuItem_setValue1(MenuItem, "Menu1->Item4")
MenuItem_setValue2(MenuItem, 4)

MenuItem := Menu_Add("Menu1", "Item5", "OutputSelection5")
MI_SetMenuItemIcon("Menu1", 5, A_AhkPath, 5, 16)
MenuItem_setValue1(MenuItem, "Menu1->Item5")
MenuItem_setValue2(MenuItem, 5)

; Menu_NoDefault("tray")

;1) insert menu items in the middle of a menu
Menu_Insert(1, "tray", "Menu1", ":Menu1")

;2) move a menu item within the same menu - 0 "wraps" to be MenuSize + 0 (i.e end of list)
;move "item1" to the end of the menu
Menu_Move("Menu1", 1, 0)

;3) move a menu item to another menu
;move "item2"
Menu_MoveEx("Menu1", 1, "Menu2", 0)

;since "item2" is checked, this will return a non-zero
;the final parameter says that the 0 is a position (not a MenuItemName)
MsgBox, % "isChecked? " . Menu_isChecked("Menu2", 0, true)

Menu_Insert(2, "tray", "Menu2", ":Menu2")
;4) since MenuItemLabel is empty, it uses Menu_fixUpMenuLabel to determine the label
;the current function removes spaces, that's why it works
MenuItem := Menu_Insert(3, "tray", "Make This Selection")
MenuItem_setValue1(MenuItem, "See how it removes the spaces - you told it too in Menu_fixUpMenuLabel")
MenuItem_setValue2(MenuItem, 42)

;set menu values
Menu_setValue(Menu_getMenuObject("tray"), 178)
Menu_setValue(Menu_getMenuObject("Menu1"), -15)
Menu_setValue(Menu_getMenuObject("Menu2"), -10247)

return

MakeThisSelection:
OutputSelection1:
OutputSelection2:
OutputSelection3:
OutputSelection4:
OutputSelection5:
{
    MenuObject := Menu_getMenuObject(A_ThisMenu)
    MenuItemObject := Menu_getMenuItemObject(A_ThisMenu, A_ThismenuItemPos)

    MsgBox, % A_ThisMenu
        . "`n" . A_ThisMenuItem
        . "`n" . A_ThisMenuItemPos
        . "`n" . A_ThisLabel
        
    MsgBox, % "Menu object data"
        . "`nMenuName (Built-in): " . Menu_getMenuName(MenuObject)
        . "`n" . Menu_getValue(MenuObject)
        . "`n"
        . "`nMenuItem object data"
        . "`nLabel-or-SubMenu (Built-in): " . MenuItem_getMenuItemLabel(MenuItemObject)
        . "`n" . MenuItem_getValue1(MenuItemObject)
        . "`n" . MenuItem_getValue2(MenuItemObject)
        
    return
}