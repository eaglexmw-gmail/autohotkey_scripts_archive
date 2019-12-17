; http://www.autohotkey.com/forum/topic36665.html

; Requires AutoHotkey pre-v1.0.48 beta and the appropriate version of LowLevel,
;  which can be found here:  http://www.autohotkey.com/forum/topic26300.html

/*
    Function: DebugBIF
   
        Registers a user-defined function to be called when a built-in function either
        sets ErrorLevel to a non-zero value or returns an empty string, as appropriate.
   
    Syntax:
       
        DebugBIF( [ func_to_debug, func_to_call, event_info ] )
   
    Parameters:
       
        func_to_debug   - The name of the built-in function to debug.
                          If omitted or empty, all applicable functions are affected.
       
        func_to_call    - The name of a user-defined function to call.
                          If omitted or empty, DebugBIF_DefaultHandler is used.
       
        event_info      - An integer to pass via A_EventInfo.
                          If omitted or empty, A_EventInfo contains a boolean value
                          indicating whether ErrorLevel triggered the current call.
*/

DebugBIF(func_to_debug="", func_to_call="", event_info="")
{
    static DebugErrorLevel, DebugResult
   
    if func_to_call =
        func_to_call = DebugBIF_DefaultHandler
   
    if func_to_debug =
    {
        func_to_debug = RegExMatch,RegExReplace,NumGet,NumPut,GetKeyState
                    ,Mod,ASin,ACos,Sqrt,Log,Ln,RegisterCallback,DllCall
        Loop, Parse, func_to_debug, `,
            DebugBIF(A_LoopField, func_to_call)
        return
    }
   
    if func_to_debug in DllCall,RegExMatch,RegExReplace
        use_error_level := true
    else
        use_error_level := false
   
    if event_info =
        event_info := use_error_level
   
    LowLevel_init()
    if !(bif := __findFunc(func_to_debug)) || !NumGet(bif+49,0,"char")
    || !(callback := RegisterCallback(func_to_call,"C F",4,event_info))
        return
   
    bif_native := NumGet(bif+4)
   
    if !VarSetCapacity(DebugErrorLevel)
    {
        VarSetCapacity(DebugErrorLevel, 56), NumPut(0xC35D5E5F, NumPut(0x10C4830C, NumPut(0x55FF5756, NumPut(0x1C75FF20, NumPut(0x75FF0E74, NumPut(0x3038800C, NumPut(0xC4830840, NumPut(0x8B08458B, NumPut(0x1055FF56, NumPut(0x1C75FF3E, NumPut(0x8B2075FF, NumPut(0x5718758B, NumPut(0x56EC8B55, NumPut(&DebugErrorLevel+4, DebugErrorLevel))))))))))))))
        VarSetCapacity(DebugResult, 60), NumPut(0x0000C35D, NumPut(0x5E5F10C4, NumPut(0x830855FF, NumPut(0x57561875, NumPut(0xFF1C75FF, NumPut(0x0E750038, NumPut(0x80068B15, NumPut(0x7500087E, NumPut(0x830CC483, NumPut(0x0C55FF56, NumPut(0x1875FF3E, NumPut(0x8B1C75FF, NumPut(0x5714758B, NumPut(0x56EC8B55, NumPut(&DebugResult+4, DebugResult)))))))))))))))
    }
   
    if use_error_level
        __mcode(func_to_debug, ""
            . "68" __mcodeptr(bif_native)
            . "68" __mcodeptr(callback)
            . "68" __mcodeptr(__getVar(ErrorLevel))
            . "FF15" __mcodeptr(&DebugErrorLevel)
            . "83C40C"
            . "C3")
    else
        __mcode(func_to_debug, ""
            . "68" __mcodeptr(bif_native)
            . "68" __mcodeptr(callback)
            . "FF15" __mcodeptr(&DebugResult)
            . "83C408"
            . "C3")
}

DebugBIF_DefaultHandler(aName, aResultToken, aParam, aParamCount)
{
    static IgnoreRegisterCallback[DllCall]:=2
    RealErrorLevel := ErrorLevel
    ; If the first two errors are RegisterCallback("DllCall"), assume it is due to the
    ; usual workings of LowLevel.ahk, and ignore them.
    if IgnoreRegisterCallback[DllCall]
        if __str(aName)="RegisterCallback" && __getTokenValue(NumGet(aParam+0))="DllCall"
            return "", --IgnoreRegisterCallback[DllCall]
        else
            IgnoreRegisterCallback[DllCall] := 0
   
    ListLines
    FileAppend, BEGIN DEBUG CODE ~~~~~~~~~~~~~~~~~~~~, NUL
   
    s := __str(aName)
    Loop % aParamCount
    {
        t := NumGet(aParam+(A_Index-1)*4)
        sym := NumGet(t+8)
        s .= "`n   [" A_Index "]: "
        if sym = 3 ; SYM_VAR
            s .= __str(NumGet(NumGet(t+0)+24)) " := "
        v := __getTokenValue(t+0)
        if (sym=0 || sym=3 || (sym=4 && !NumGet(t+4)))
        {
            StringReplace, v, v, ", "", All
            v = "%v%"
        }
        s .= v
    }
    v := __getTokenValue(aResultToken+0)
    if v !=
    {
        sym := NumGet(aResultToken+8)
        if (sym=0 || (sym=4 && !NumGet(aResultToken+4)))
        {
            StringReplace, v, v, ", "", All
            v = "%v%"
        }
        s .= "`n   ret: " v
    }
    else if !A_EventInfo
        s .= "`n`nReturned an empty string."
    if RealErrorLevel && A_EventInfo
        s .= "`n`nErrorLevel = " RealErrorLevel
    MsgBox, 16, %A_ScriptName% - Built-in Function Error, %s%

    ErrorLevel := RealErrorLevel
    FileAppend, ~~~~~~~~~~~~~~~~~~~~ END DEBUG CODE, NUL
}
