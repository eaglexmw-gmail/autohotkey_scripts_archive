; by Lexicos http://www.autohotkey.com/forum/viewtopic.php?p=168951#168951
IndexOfIconResource(Filename, ID)
{
ID := Abs(ID) ; added by Drugwash
    hmod := DllCall("GetModuleHandle", "str", Filename)
    ; If the DLL isn't already loaded, load it as a data file.
    loaded := !hmod
        && hmod := DllCall("LoadLibraryEx", "str", Filename, "uint", 0, "uint", 0x2)
   
    enumproc := RegisterCallback("IndexOfIconResource_EnumIconResources","F")
    VarSetCapacity(param,12,0), NumPut(ID,param,0)
    ; Enumerate the icon group resources. (RT_GROUP_ICON=14)
    DllCall("EnumResourceNames", "uint", hmod, "uint", 14, "uint", enumproc, "uint", &param)
    DllCall("GlobalFree", "uint", enumproc)
   
    ; If we loaded the DLL, free it now.
    if loaded
        DllCall("FreeLibrary", "uint", hmod)
   
    return NumGet(param,8) ? NumGet(param,4) : 0
}

IndexOfIconResource_EnumIconResources(hModule, lpszType, lpszName, lParam)
{
    NumPut(NumGet(lParam+4)+1, lParam+4)

    if (lpszName = NumGet(lParam+0))
    {
        NumPut(1, lParam+8)
        return false    ; break
    }
    return true
}
