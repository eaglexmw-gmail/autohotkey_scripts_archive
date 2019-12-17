Gui, Add, ListView, w60 h20 -E0x200 +Border -hdr +ReadOnly vColor BackgroundFE22AA 
Gui, Show 
Sleep 2000 
NewColor=FFFFFF 
GuiControl, +BackGround%NewColor%, Color 
Return
