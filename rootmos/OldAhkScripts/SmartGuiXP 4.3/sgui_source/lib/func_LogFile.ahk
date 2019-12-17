; function to log script specific data to text file
; usage: Log(data, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, observations, output file name)
; data is the actual data to be logged
; line is the script line being run
; labl is currently executed label
; func is the currently run function
; obs can be user comments

LogFile(data, line, file, labl="autoexec",  func="", obs="", outfile="AHK_log.txt")
{
FormatTime, time,, yyyy.MM.dd HH:mm:ss
if !labl
	labl=autoexec
if func
	func := " [function: " func "() ]"
if obs
	obs := " (" obs ")"
if (file != A_ScriptFullPath)
	{
	SplitPath, file, inc, incdir
	log3 := " in include file " inc " (" incdir ")"
	}
labl := " [label " . labl . "]"
log1 := "[" time "] [line " line "]" labl func
log2 := data . obs
FileAppend, %log1%%log3%`n%log2%`n`n, %outfile%
}
