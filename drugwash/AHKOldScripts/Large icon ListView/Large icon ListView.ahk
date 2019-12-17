; http://www.autohotkey.com/forum/viewtopic.php?t=26855

#Singleinstance, force

   ILC_COLOR := 0, ILC_COLOR4 := 0x4, ILC_COLOR8 := 0x8, ILC_COLOR16 := 0x10, ILC_COLOR24 := 0x18, ILC_COLOR32 := 0x20
 
   isize := 128
   color := ILC_COLOR16

   Gui, Add, ListView, w600 h600 Icon HWNDhLV, icon
   
   hIml := ImageList_Create(isize, isize, color, 100, 100)

   LV_SetImageList(hIml)
   loop, c:\windows\*
   {
      hIcon := LoadIcon(A_LoopFileFullPath, 1, isize)     ; LR_LOADFROMFILE
      if !hIcon
         continue
     i := ImageList_AddIcon( hIml, hIcon )
      LV_Add("Icon" i+1, i " "A_LoopFileName)
   }
   Gui, Show, autosize
return

ListView_SetImageList( hwnd, hIml, iImageList=0) {
   SendMessage, 0x1000+3, iImageList, hIml, , ahk_id %hwnd%
   return ErrorLevel
}

ImageList_Create(cx,cy,flags,cInitial,cGrow){
   return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow)
}

ImageList_Add(hIml, hbmImage, hbmMask=""){
   return DllCall("comctl32.dll\ImageList_Add", "uint", hIml, "uint",hbmImage, "uint", hbmMask)
}

ImageList_AddIcon(hIml, hIcon) {
   return DllCall("comctl32.dll\ImageList_ReplaceIcon", "uint", hIml, "int", -1, "uint", hIcon)
}

API_ExtractIcon(Icon, Idx=0){
   return DllCall("shell32\ExtractIconA", "UInt", 0, "Str", Icon, "UInt",Idx)
}


API_LoadImage(pPath, uType, cxDesired, cyDesired, fuLoad) {
   return,  DllCall( "LoadImage", "uint", 0, "str", pPath, "uint", uType, "int", cxDesired, "int", cyDesired, "uint", fuLoad)
}

LoadIcon(Filename, IconNumber, IconSize) {
   DllCall("PrivateExtractIcons"
          ,"str",Filename,"int",IconNumber-1,"int",IconSize,"int",IconSize
            ,"uint*",h_icon,"uint*",0,"uint",1,"uint",0,"int")
   if !ErrorLevel
         return h_icon
}
