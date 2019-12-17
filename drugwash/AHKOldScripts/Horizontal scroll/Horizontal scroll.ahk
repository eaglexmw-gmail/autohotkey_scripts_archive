; by Chris http://www.autohotkey.com/forum/viewtopic.php?p=1006#1006

~RButton & WheelUp:: ; Scroll left. 
ControlGetFocus, control, A 
SendMessage, 0x114, 0, 0, %control%, A ; 0x114 is WM_HSCROLL 
return 

~RButton & WheelDown:: ; Scroll right. 
ControlGetFocus, control, A 
SendMessage, 0x114, 1, 0, %control%, A ; 0x114 is WM_HSCROLL 
return
