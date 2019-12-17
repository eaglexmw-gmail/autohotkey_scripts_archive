;
; AutoHotkey (Tested) Version: 1.1.13.01
; Author:         Joe DF  |  http://joedf.co.nr  |  joedf@users.sourceforge.net
; Date:           September 8th, 2013
;
;	LibCon.ahk Usage Example
;
;/////////////////////////////////////////////////////////////

#SingleInstance,Off
#Include LibCon.ahk ;Needed
SetBatchLines,-1 ;suggested
LibConDebug:=1 ;let the user know about errors

SmartStartConsole() ;Shows the Console and 'initializes' the library

if (args) {
	putsf("argc = %s",args[0]) ;use args[0] or argc
	loop % args[0]
		putsf("%s: %s",A_Index,args[A_Index])
	putsf("args (CSV Format): %s",args.CSV)
	newline()
}

puts("-------------------------------------------")
newline() ;Skip to new line
puts("SPUTNIK DDOS CANNON, CREATED WITH LOVE.")
newline() ;Skip to new line
puts("-------------------------------------------")

print("[+] Attack: ")
putsf("`n[+] %s!", (gets(Name)=="") ? "Attacking:" : Name)
setFGColor(Green) ;Set Foreground Color to Green (the text color)

;Create Fake loading bar...
Loop % (barmax:=70)+1 {
	printf("Loading `%s`r",sProgressBar(50,A_Index-1,barmax))
	Sleep 30
}

newline() ;Skip to new line
Sleep 5000000
Return
