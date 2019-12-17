SetBatchLines, -1

Loop, 100000
 matchlist .= A_Index ","
needle = 100000

Start_Time := A_TickCount
If needle IN %matchlist%
{
 Stop_Time := A_TickCount
 time1 := (Stop_Time - Start_Time)/1000 " seconds."
}

Start_Time := A_TickCount
Loop, Parse, matchlist, `,
 If (A_LoopField = needle)
 {
  Stop_Time := A_TickCount
  time2 := (Stop_Time - Start_Time)/1000 " seconds."
 }

MsgBox, The "IN" operator took:`t%time1%`nThe parsing loop took:`t%time2%
