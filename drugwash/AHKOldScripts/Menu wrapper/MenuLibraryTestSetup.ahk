;project specific files go here

;initializes the Menu library
MenuLibrarySetup()

;set the user-defined size for a Menu and MenuObject object
Menu_setUserDefinedSize(1)
MenuItem_setUserDefinedSize(2)

;Your code goes here
;getters/setters for user-defined values
Menu_getValue(MenuObject)
{
    return Class_getValue(MenuObject, 1, "int")
}

Menu_setValue(MenuObject, Value = 0)
{
    Class_setValue(MenuObject, 1, Value, "int")
}

MenuItem_getValue1(MenuItemObject)
{
    return Class_getString(MenuItemObject, 1)
}

MenuItem_setValue1(MenuItemObject, Value1 = "")
{
    Class_setString(MenuItemObject, 1, Value1)
}

MenuItem_getValue2(MenuItemObject)
{
    return Class_getValue(MenuItemObject, 2, "uint")
}

MenuItem_setValue2(MenuItemObject, Value2 = 0)
{
    Class_setValue(MenuItemObject, 2, Value2, "uint")
}


;these functions MUST be included for propper functionality

;these functions are to free up resources for the data associated with a Menu / Menu Item
;leave blank if there are no values (but the functions must still exist)

;destroy user-defined values for a Menu object
Menu_destroy_private(MenuObject)
{
    Menu_setValue(MenuObject)
}

;destroy user-defined values for a MenuItem object
MenuItem_destroy_private(MenuItemObject)
{
    MenuItem_setValue1(MenuItemObject)
    MenuItem_setValue2(MenuItemObject)
}

;allows setting MenuItemLabel to a "custom" value if blank
;(used automatically when menu item is added)

;default AHK behavior
;if MenuItemLabel is blank, uses MenuItemName
/*
Menu_fixUpMenuLabel(AtIndex, MenuName, MenuItemName, MenuItemLabel)
{
    if (MenuItemLabel != "")
        return MenuItemLabel

    return MenuItemName
}
*/

;if MenuItemLabel is blank, uses MenuItemName (with spaces removed)
;I personnaly use this behavior, so I included it for yal
Menu_fixUpMenuLabel(AtIndex, MenuName, MenuItemName, MenuItemLabel)
{
    if (MenuItemLabel != "")
        return MenuItemLabel

    ;remove all spaces
    StringReplace, MenuItemLabel, MenuItemName, %A_Space%, , All

    return MenuItemLabel
}