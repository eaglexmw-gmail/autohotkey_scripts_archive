ToolTip(99,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 4 . " Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
While, end < 3
{
   ToolTip(99,"","This ToolTip will be destroyed in " .  4 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(99,"")

#include tooltip advanced 5.ahk
