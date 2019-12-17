#Include, %A_ScriptDir%\ahkstructlib2.ahk

StructCreate("MEMORYSTATUS"
, "dwLength         as long"
, "dwMemoryLoad      as long"
, "dwTotalPhys      as long"
, "dwAvailPhys      as long"
, "dwTotalPageFile   as long"
, "dwAvailPageFile   as long"
, "dwTotalVirtual   as long"
, "dwAvailVirtual   as long")

DllCall("GlobalMemoryStatus", "Str", MEMORYSTATUS)
Struct?("MEMORYSTATUS")

MEMORYSTATUS?dwTotalPhys       :=   Round(MEMORYSTATUS?dwTotalPhys / 1024 / 1024, 2)
MEMORYSTATUS?dwAvailPhys       :=   Round(MEMORYSTATUS?dwAvailPhys / 1024 / 1024, 2)
MEMORYSTATUS?dwTotalPageFile    :=   Round(MEMORYSTATUS?dwTotalPageFile / 1024 / 1024, 2)
MEMORYSTATUS?dwAvailPageFile    :=   Round(MEMORYSTATUS?dwAvailPageFile / 1024 / 1024, 2)
MEMORYSTATUS?dwTotalVirtual    :=   Round(MEMORYSTATUS?dwTotalVirtual / 1024 / 1024, 2)
MEMORYSTATUS?dwAvailVirtual    :=   Round(MEMORYSTATUS?dwAvailVirtual / 1024 / 1024, 2)

MsgBox,
(
System Memory Status:

Memory Load:	%MEMORYSTATUS?dwMemoryLoad%`%
Total Physical:	%MEMORYSTATUS?dwTotalPhys%	MB
Available Physical:	%MEMORYSTATUS?dwAvailPhys%	MB
Total Pagefile:	%MEMORYSTATUS?dwTotalPageFile%	MB
Available Pagefile:	%MEMORYSTATUS?dwAvailPageFile%	MB
Total Virtual:	%MEMORYSTATUS?dwTotalVirtual%	MB
Available Virtual:	%MEMORYSTATUS?dwAvailVirtual%	MB
)
