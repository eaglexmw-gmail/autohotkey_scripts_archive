Loop { 
   InputBox code,Evaluate AHK expression,% "Result = " __expr(code),,300,120,,,,,%code% 
   IfEqual ErrorLevel,1, Break 
} 
#include lowlevel.ahk
