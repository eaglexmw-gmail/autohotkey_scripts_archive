; example call
sTooltip("Tooltip with custom Colors",5,0xff00ff,0xEEFFEE)

sTooltip(sTooltipTxt,seconds=5,bg=0xFFFFE7,fg=0x0,x=-1,y=-1) {
   ; (w) derRaphael / zLib Style released / v 0.3
   if (Seconds+0=0)
      Seconds = 5
   StartTime := EndTime := A_Now
   EnvAdd,EndTime,Seconds,Seconds
   
   fg := ((fg&255)<<16)+(((fg>>8)&255)<<8)+(fg>>16) ; rgb -> bgr
   bg := ((bg&255)<<16)+(((bg>>8)&255)<<8)+(bg>>16) ; rgb -> bgr
   
   tooltip,% (ttID:="TooltipColor " A_TickCount)
   tThWnd1:=WinExist(ttID ahk_class tooltips_class32)
   ; remove border
   ; WinSet,Style,-0x800000,ahk_id %tThWnd1%
   SendMessage, 0x413, bg,0,, ahk_id %tThWnd1%   ; 0x413 is TTM_SETTIPBKCOLOR
   SendMessage, 0x414, fg,0,, ahk_id %tThWnd1%   ; 0x414 is TTM_SETTIPTEXTCOLOR
   ; according to http://msdn.microsoft.com/en-us/library/bb760411(VS.85).aspx
   ; there is no limitation on vista for this.
   Loop,
   {
      if (EndTime=A_Now)
         Break
      else
         if (x<0) || (y<0)
            ToolTip, %sTooltipTxt%
         else
            ToolTip, %sTooltipTxt%, %x%, %y%
      sleep, 50
   }
   ToolTip
}
