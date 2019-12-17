/*
	Title: Advanced Benchmark
	
	Function: qpc2
	
	Benchmarks each section of code with a very high precision timer and
	calculates the standard deviation and performance ranks for comparison.
	For examples visit <http://www.autohotkey.com/forum/viewtopic.php?t=19174>.
	
	Parameters:
		c - any valid AutoHotkey code, if this is a file path it's contents will be used
		t - any one of the following options:
				- *"pre"*: adds the code to the header section which is run before the test (e.g. initializing variables)
				- *"inc"*: post-test code to execute (e.g. deleting temporary files)
				- *"test" (default)*: a code section to benchmark
	
	Returns:
		A TSV report.
	
	About: License
		- Version 2.0 by Titan <http://www.autohotkey.net/~Titan/#advbenchmark>.
		- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.

*/

qpc2(c = "", t = "test") {
	static scr, pre, inc, i = 0
	dc = `nDllCall("QueryPerformanceCounter", "Int64P",
	v = __qpc2
	a = ``,
	IfExist, %c%
		FileRead, c, %c%
	If not c + 1 and c != ""
	{
		If t = test
		{
			i++
			scr = %scr%`nLoop, `%%v%`% {`n%c%`n}%dc% t%i%)
		}
		Else If t = pre
			pre .= "`n" . c
		Else If (t = true or t = "inc")
			inc .= "`n" . c
	}
	Else {
		DllCall("QueryPerformanceFrequency", "Int64P", freq)
		loc = %A_Temp%\%v%~%A_Now%
		locx = %loc%x
		sb = #!qpc2:
		Loop, % i + 1
			res .= a . "%t" . A_Index - 1 . "%", var .= "t" . A_Index - 1 " := "
		scr =
		( LTrim
			#SingleInstance ignore
			#MaxMem 1
			#ErrorStdOut
			#NoTrayIcon
			Process, Priority, , R
			%pre%
			%var%0x00000000
			%dc% t0)
			%scr%
			FileAppend, %sb%%res%, *
			%inc%
		)
		j := c + 1 ? c : 10
		Loop {
			FileDelete, %loc%
			FileAppend, %v% = %j%`n%scr%, %loc%
			RunWait, %ComSpec% /c ""%A_AhkPath%" "%loc%" > "%locx%"", %A_Temp%, Hide
			FileRead, dat, %locx%
			FileDelete, %loc%
			FileDelete, %locx%
			If InStr(dat, sb) != 1
				Return, "Error: " . dat
			StringTrimLeft, dat, dat, StrLen(sb) + 1
			StringSplit, d, dat, %a%
			Loop, %i%
				x := A_Index, y := x + 1, d%x% := d%y% - d%x%
			If c =
			{
				j = 0
				Loop, %i%
					j += d%A_Index%
				j := Ceil(1 / (j / freq)) * 2
				c = 1
				Continue
			}
			d := "	"
			m = 0
			Loop, %i%
				s += d%A_Index%
			m := s / i
			Loop, %i%
				sd += (d%A_Index% - m) ** 2
			res = Test%d%Time%d%Deviation%d%Rank
			Loop, %i%
				res .= "`n" . A_Index . d . Round(d%A_Index% / freq * 1000)
					. d . Round((d%A_Index% - m) / freq, 2)
					. d . Ceil((1 - (d%A_Index% / s)) * 100) . "%"
			sd := Round(Sqrt(sd / --i) / freq, 2)
			scr := pre := inc := i := ""
			Return, res . "`n`nIterations " . d . j . "`nStandard deviation" . d . sd
		}
	}
}
