; http://www.autohotkey.com/forum/viewtopic.php?p=182170#182170
; by SKAN

File = %1%
Loop %File%
  File := A_LoopFileLongPath
ATC := A_TickCount
IfNotExist, %File%, Return
FileGetSize, dataSz , %File%
FileRead, BinData , %File%
hexData := Bin2Hex( &BinData, dataSz )
hFile := DllCall( "_lcreat", Str,File ".txt", Int,0 )
DllCall( "_lwrite", Int,hFile, Int, &hexData, Int,dataSz*2 )
DllCall( "_lclose", Int,hFile )
MsgBox,64, % "Binary to Hex [ DONE! ]", %File%.txt
Return

/*

  Bin2Hex() and Hex2Bin()

  Machine code functions: Bit Wizardry [ By Laszlo Hars ]

  Topic : http://www.autohotkey.com/forum/viewtopic.php?t=21172
  Post  : http://www.autohotkey.com/forum/viewtopic.php?p=180469#180469

*/

Bin2Hex(addr,len) { ; Bin2Hex(&x,4)

   Static fun
   If (fun = "")
      Hex2Bin(fun,"8B4C2404578B7C241085FF7E2F568B7424108A06C0E8042C0A8AD0C0EA05"
      . "2AC2044188018A06240F2C0A8AD0C0EA052AC2410441468801414F75D75EC601005FC3")
   VarSetCapacity(hex,2*len+1)
   dllcall(&fun, "uint",&hex, "uint",addr, "uint",len, "cdecl")
   VarSetCapacity(hex,-1) ; update StrLen
   Return hex
}

Hex2Bin(ByRef bin, hex) { ; Hex2Bin(fun,"8B4C24") = MCode(fun,"8B4C24")
   Static fun
   If (fun = "") {
      h:="568b74240c8a164684d2743b578b7c240c538ac2c0e806b109f6e98ac802cac0e104880f8"
       . "a164684d2741a8ac2c0e806b309f6eb80e20f02c20ac188078a16474684d275cd5b5f5ec3"
      VarSetCapacity(fun,StrLen(h)//2)
      Loop % StrLen(h)//2
         NumPut("0x" . SubStr(h,2*A_Index-1,2), fun, A_Index-1, "Char")
   }
   VarSetCapacity(bin,StrLen(hex)//2)
   dllcall(&fun, "uint",&bin, "Str",hex, "cdecl")
}
