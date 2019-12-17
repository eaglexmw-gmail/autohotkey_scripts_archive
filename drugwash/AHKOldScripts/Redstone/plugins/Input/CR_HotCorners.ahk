; Hot Corners by Hotfoot
; September 16, 2005
;
; Activation: Move the mouse to different corners of the
; screen to trigger commands. The mouse is moved to the
; center of the screen before triggering the command to
; prevent triggering the command multiple times. If you want
; the mouse to be moved to a specific position after
; triggering a Hot Corner, modify the MouseMove position.
; If you want a command to be repeatedly triggered,
; remove the MouseMove command. It is possible to
; trigger multiple Hot Corners if you want by setting
; the mouse to move to a different Hot Corner after
; execution of one Hot Corner.
;
; Commands: Example commands are shown below. Hold down
; Shift, Control, or Alt keys for additional commands.
; Modify them for your needs.

; Top Left Corner:
;  without keys:       (example of repeating command)
;  with Control key:   Show Desktop command
;  with Alt key:       (add your own command)
;  with Shift key:     (add your own command)
;
; Top Right Corner:
;  without keys:       Minimize window, give focus to next window
;  with Control key:   (add your own command)
;  with Alt key:       (add your own command)
;  with Shift key:     (add your own command)
;
; Bottom Left Corner:
;  without keys:       Close window
;  with Control key:   (add your own command)
;  with Alt key:       (add your own command)
;  with Shift key:     (add your own command)
;
; Bottom Right Corner:
;  without keys:       Left Mouse Click after 2 second delay
;  with Control key:   (add your own command)
;  with Alt key:       (add your own command)
;  with Shift key:     (add your own command)



hotCorners_Initialize() {

	NotifyRegister("UI Created", "hotCorners_OnStartup")
}


hotCorners_OnStartup(A_Command, A_Args) {
	; Timer to check mouse position
	SetTimer, CheckMouse, 500
	Return
	
	CheckMouse:                   ; check mouse position
		global inCorner
		
		T = 4   ; adjust tolerance value if desired
	
		CoordMode, Mouse, Screen
		MouseGetPos, MouseX, MouseY
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;Commands for top left corner
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		if (MouseY < T and MouseX < T)
		{
			if (inCorner = 0) {
				inCorner = 1
				NOTIFY("HotCorner Activated", "/corner:TopLeft")
			}
		} else {
			inCorner = 0
		}
		
	Return
}

