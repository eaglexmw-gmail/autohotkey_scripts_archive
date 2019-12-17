ToolTip(100,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 4 . " Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
end=
While, end < 10
{
   ToolTip(100,"In this example text and Title are updated continuously.`nTickCount:" . A_TickCount,"This ToolTip will be destroyed in " .  11 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(100)


end=
ToolTip(100,"In this example only position is tracked.","This ToolTip will be destroyed in 10 Seconds","D10 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
ToolTip(100)



end=
ToolTip(100,"`nHere only title is being changed"
   ,"This ToolTip will be destroyed in 10 Seconds","I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
While, end < 10
{
   ToolTip(100,"","This ToolTip will be destroyed in " .  11 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(100)
ExitApp

#include Tooltip advanced 9.ahk
