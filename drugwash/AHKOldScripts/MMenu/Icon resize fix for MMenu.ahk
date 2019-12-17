; by Deo http://www.autohotkey.com/forum/viewtopic.php?p=353194#353194

MMenu_loadIcon(pPath, pSize=0)
{
   idx := InStr(pPath, ":", 0, 0)

   if idx >=4
   {
      resPath := SubStr( pPath, 1, idx-1)
      resIdx  := Substr( pPath, idx+1, 8)

;~       return MMenu_GetIcon( resPath, resIdx )
      return DllCall("user32\CopyImage"
                        , "UInt", MMenu_GetIcon(resPath,resIdx) ;icon handle
                        , "uint", 2      ; IMAGE_ICON
                        , "int", pSize
                        , "int", pSize
                        , "UInt",0x8)   ;LR_COPYDELETEORG
   }
   return,  DllCall( "LoadImage"
                     , "uint", 0
                     , "str", pPath
                     , "uint", 2                ; IMAGE_ICON
                     , "int", pSize
                     , "int", pSize
                     , "uint", 0x10 | 0x20)     ; LR_LOADFROMFILE | LR_TRANSPARENT
}
