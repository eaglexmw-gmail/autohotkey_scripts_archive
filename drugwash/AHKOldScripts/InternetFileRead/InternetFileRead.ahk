; http://www.autohotkey.com/forum/viewtopic.php?t=45718
/*
     _____       _                       _   _____                _ ______ _ _
    |_   _|     | |                     | | |  __ \              | |  ____(_) |
      | |  _ __ | |_ ___ _ __ _ __   ___| |_| |__) |___  __ _  __| | |__   _| |  ___
      | | | '_ \| __/ _ \ '__| '_ \ / _ \ __|  _  // _ \/ _` |/ _` |  __| | | | / _ \
     _| |_| | | | ||  __/ |  | | | |  __/ |_| | \ \  __/ (_| | (_| | |    | | ||  __/
    |_____|_| |_|\__\___|_|  |_| |_|\___|\__|_|  \_\___|\__,_|\__,_|_|    |_|_| \___|

                                  by SKAN ( Suresh Kumar A N, arian.suresh@gmail.com )
                                          Created: 24-Jun-2009 | LastEdit: 26-Jun-2009
   Included: InternetReadFile() & 3 examples,  DLP() - Download Progress,  VarZ_Save()
   Credit  : Thanks to Lexikos for providing the code/method to support FTP file read.
*/

#SingleInstance Force

; Example 1: Download the leading 100 bytes of default HTML and extract a part of text.
URL := "http://www.formyip.com/"
If ( InternetFileRead( IP, URL, 100, 100, "No-Progress" ) > 0 )
  MsgBox, 64, Your External IP Address
        , % IP := SubStr( IP,SP:=InStr(IP,"My ip address ")+17,InStr(IP," ",0,SP+1)-SP )


; Example 2, Download a binary file ( AHK Script Decompiler ) and save it.
URL := "http://www.autohotkey.com/download/Exe2Ahk.exe"
If ( InternetFileRead( binData, URL, False, 10240, "No-Progress" ) > 0 && !ErrorLevel )
  If VarZ_Save( binData, A_ScriptDir "\Exe2Ahk.exe" )
     MsgBox, 64, AHK Script Compiler Downloaded and Saved, % A_ScriptDir "\Exe2Ahk.exe"


; Example 3, Download a FTP file: EditPlus 3.11 Evaluation Version (1 MB) and save it.
URL := "ftp://ftp.editplus.com/epp311_en.exe"
If ( InternetFileRead( binData, URL ) > 0 && !ErrorLevel )
    If VarZ_Save( binData, A_Temp "\epp311_en.exe" ) {
         Sleep 500
         DLP( False ) ; or use Progress, off
         Run %A_Temp%\epp311_en.exe
       }
       
; AHK will automatically unload libraries on exit. If you are particular, here is a method
; to unload Wininet library without a handle.
DllCall( "FreeLibrary", UInt,DllCall( "GetModuleHandle", Str,"wininet.dll") )
Return ;                                                 // end of auto-execute section //

InternetFileRead( ByRef V,URL="", RB=0,bSz=1024, DLP="DLP",F=0x80000000, Prx="",PBP="" ) {
 Static LIB="WININET\", QRL=16, CL="00000000000000", N=""
 If ! DllCall( "GetModuleHandle", Str,"wininet.dll" )
      DllCall( "LoadLibrary", Str,"wininet.dll" )
 If ! hIO:=DllCall( LIB "InternetOpenA", Str,N, UInt,Prx ? 3:1, Str,Prx, Str,PBP, UInt,0 )
   Return -1
 If ! (( hIU:=DllCall( LIB "InternetOpenUrlA", UInt,hIO, Str,URL, Str,N, Int,0, UInt,F
                                                            , UInt,0 ) ) || ErrorLevel )
   Return 0 - ( !DllCall( LIB "InternetCloseHandle", UInt,hIO ) ) - 2
 If ! ( RB  )
 If ( SubStr(URL,1,4) = "ftp:" )
    CL := DllCall( LIB "FtpGetFileSize", UInt,hIU, UIntP,0 )
 Else If ! DllCall( LIB "HttpQueryInfoA", UInt,hIU, Int,5, Str,CL, UIntP,QRL, UInt,0 )
   Return 0 - ( !DllCall( LIB "InternetCloseHandle", UInt,hIU ) )
            - ( !DllCall( LIB "InternetCloseHandle", UInt,hIO ) ) - 4
 VarSetCapacity( V,64 ), VarSetCapacity( V,0 )
 SplitPath, URL, FN,,,, DN
 FN:=(FN ? FN : DN), CL:=(RB ? RB : CL), VarSetCapacity( V,CL,32 ), P:=&V,
 B:=(bSz>CL ? CL : bSz), TtlB:=0, LP := RB ? "Unknown" : CL,  %DLP%( True,CL,FN )
 Loop {
       If ( DllCall( LIB "InternetReadFile", UInt,hIU, UInt,P, UInt,B, UIntP,R ) && !R )
       Break
       P:=(P+R), TtlB:=(TtlB+R), RemB:=(CL-TtlB), B:=(RemB<B ? RemB : B), %DLP%( TtlB,LP )
       Sleep -1
 } TtlB<>CL ? VarSetCapacity( T,TtlB ) DllCall( "RtlMoveMemory", Str,T, Str,V, UInt,TtlB )
  . VarSetCapacity( V,0 ) . VarSetCapacity( V,TtlB,32 ) . DllCall( "RtlMoveMemory", Str,V
  , Str,T, UInt,TtlB ) . %DLP%( TtlB, TtlB ) : N
 If ( !DllCall( LIB "InternetCloseHandle", UInt,hIU ) )
  + ( !DllCall( LIB "InternetCloseHandle", UInt,hIO ) )
   Return -6
Return, VarSetCapacity(V)+((ErrorLevel:=(RB>0 && TtlB<RB)||(RB=0 && TtlB=CL) ? 0 : 1)<<64)
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following function is an add-on to provide "Download Progress" to InternetFileRead()
; InternetFileRead() calls DLP() dynamically, i.e., will not error-out if DLP() is missing
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DLP( WP=0, LP=0, Msg="" ) {
 If ( WP=1 ) {
 SysGet, m, MonitorWorkArea, 1
 y:=(mBottom-46-2), x:=(mRight-370-2), VarSetCapacity( Size,16,0 )
 DllCall( "shlwapi.dll\StrFormatByteSize64A", Int64,LP, Str,Size, UInt,16 )
 Size := ( Size="0 bytes" ) ? N : "«" Size "»"
 Progress, CWE6E3E4 CT000020 CBF73D00 x%x% y%y% w370 h46 B1 FS8 WM700 WS400 FM8 ZH8 ZY3
         ,, %Msg%  %Size%, InternetFileRead(), Tahoma
 WinSet, Transparent, 210, InternetFileRead()
 } Progress,% (P:=Round(WP/LP*100)),% "Memory Download: " wp " / " lp " [ " P "`% ]"
 IfEqual,wP,0, Progress, Off
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following function is a part of: VarZ 46L - Native Data Compression
; View topic : www.autohotkey.com/forum/viewtopic.php?t=45559
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

VarZ_Save( byRef V, File="" ) { ;   www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk
Return ( ( hFile :=  DllCall( "_lcreat", Str,File, UInt,0 ) ) > 0 )
                 ?   DllCall( "_lwrite", UInt,hFile, Str,V, UInt,VarSetCapacity(V) )
                 + ( DllCall( "_lclose", UInt,hFile ) << 64 ) : 0
}
