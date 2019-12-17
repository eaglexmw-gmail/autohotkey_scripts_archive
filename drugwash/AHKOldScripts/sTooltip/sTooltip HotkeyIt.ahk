sTooltip("Tooltip with custom Backgroundcolor",5,0xff8000)

sTooltip(sTooltipTxt,seconds=5,bg=0xFFFFE7,fg=0x0,x=-1,y=-1, tt=1) {
   ; (w) derRaphael / zLib Style released
   if (Seconds+0=0)
      Seconds = 5
   StartTime := EndTime := A_Now
   EnvAdd,EndTime,Seconds,Seconds
   
   fg := ((fg&255)<<16)+(((fg>>8)&255)<<8)+(fg>>16) ; rgb -> bgr
   bg := ((bg&255)<<16)+(((bg>>8)&255)<<8)+(bg>>16) ; rgb -> bgr
   
   tooltip,% (ttID:="TooltipColor " A_TickCount)
   ;tThWnd1:=WinExist(ttID ahk_class tooltips_class32)
   Process, Exist
   WinGet, tThWnd1, List, ahk_pid %ErrorLevel%
   Loop, %tThWnd1%
   {
      WinGetClass   tThWnd1, % "ahk_id " tThWnd1%A_Index%
      If tThWnd1 = tooltips_class32
      {
         tThWnd1 := tThWnd1%A_Index%
         break
      }
   }
   ; remove border
   ;WinSet,Style,-0x800000,ahk_id %tThWnd1%
   SendMessage, 0x400+19, bg,fg,, ahk_id %tThWnd1%
   ToolTip, %sTooltipTxt%
   MouseGetPos, lastx, lasty
   Loop,
    if (EndTime=A_Now)
      Break
    else {
      MouseGetPos, x, y
      if (lastx != x) || (lasty != y) {
       ToolTip, %sTooltipTxt%
       lastx := x, lasty := y
     }
     sleep, 50
   }
   ToolTip
}
