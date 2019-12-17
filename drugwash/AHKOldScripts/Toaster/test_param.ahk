p1=1
p2=2
p3=3
res=0
ret := myfunc(p1, p2, p3)
MsgBox, function returned %ret%, timer is on.
ExitApp

myfunc(param1, param2, param3)
   {
   LowLevel_init(),__static(param1),__static(param2),__static(param3)
   SetTimer, mytimer, -5000
   return res

mytimer:
res=1
MsgBox, Message2: %param1%, %param2%, %param3%
return
   }
