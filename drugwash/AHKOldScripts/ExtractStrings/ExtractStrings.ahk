Variable := "Contents of Variable"
MsgBox, % ExtractData(&Variable)

; Trying to retrieve two seperate strings located from 199988
; They seem to be A_AhkPath & A_ScriptFullPath for me!

MsgBox, % ExtractData( 199988 )          ; A_AhkPath ??!!!
MsgBox, % ExtractData( errorLevel+1 )    ; A_ScriptFullPath ??!!!

Return

ExtractData(pointer) {
Loop {
       errorLevel := ( pointer+(A_Index-1) )
       Asc := *( errorLevel )
       IfEqual, Asc, 0, Break ; Break if NULL Character
       String := String . Chr(Asc)
     }
Return String
}
