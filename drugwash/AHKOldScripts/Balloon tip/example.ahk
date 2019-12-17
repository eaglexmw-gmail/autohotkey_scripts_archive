gui, 1:add , edit, h30 number -multi vE1 w120, 1234
gui, 1:add , edit, multi vE2 w120, Text
gui, 1:add , hotkey
gui, 1: show
return

F1::
i++
BalloonTip("Balloontip n°" i, "some text")
KeyWait F1
return

F2::
BalloonTip()
return

#include BalloonTip.ahk
