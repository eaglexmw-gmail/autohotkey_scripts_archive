#NoEnv
SetBatchLines, -1
SetFormat, Float, 0.15

Loop, 100
 matchlist .= A_Index . ","
needle = 50

T()
If needle IN %matchlist%
 time1 := T() . " seconds."
 
T()
If InStr("," . Matchlist, "," . Needle . ",")
 time2 := T() . " seconds."

T()
Loop, Parse, matchlist, `,
 If (A_LoopField = needle) {
  time3 := T() . " seconds."
  break
 }

MsgBox, The "IN" operator took:`t%time1%`nInStr() function took:`t%time2%`nThe parsing loop took:`t%time3%
ExitApp

T() {
   Static freq, last_count
   if !freq
      DllCall("QueryPerformanceFrequency","int64*",freq)
   DllCall("QueryPerformanceCounter","int64*",count)
   return (count-last_count)/freq, last_count:=count
}
