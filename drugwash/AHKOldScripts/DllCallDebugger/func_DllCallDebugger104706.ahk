; http://www.autohotkey.com/forum/topic36665.html

; Requires AutoHotkey v1.0.47.06 and the appropriate version of LowLevel,
;  which can be found here:  http://www.autohotkey.com/forum/topic26300.html

DllCallDebugger(ErrorCallbackName="DllCallDebugger_DefaultHandler")
{
    static ErrorCallback
    if ErrorCallback
        return
    if !(ErrorCallback := RegisterCallback(ErrorCallbackName,"C F",3))
        return
   
    LowLevel_init()
    DllCallFunc := __findFunc("DllCall")
    DllCallBif := NumGet(DllCallFunc+4)
    ErrorLevelVar := __getVar(ErrorLevel)
   
    pbin:=__mcode("DllCall"
        ; void DllCall(ExprTokenType &aResultToken, ExprTokenType *aParam[], int aParamCount)
        ; {
        ;   DllCallBif(aResultToken, aParam, aParamCount);
        , "FF74240C"                                        ; push [esp+12]
        . "FF74240C"                                        ; push [esp+12]
        . "FF74240C"                                        ; push [esp+12]
        . "B9" DllCallDebugger_FormatPtr(DllCallBif)        ; mov ecx, DllCallBif
        . "FFD1"                                            ; call ecx
        ;   if (*ErrorLevelVar->mContents != '0')
        . "B9" DllCallDebugger_FormatPtr(ErrorLevelVar)     ; mov ecx, ErrorLevelVar
        . "8B09"                                            ; mov ecx, [ecx]
        . "0FBE09"                                          ; movsx ecx, byte ptr [ecx]
        . "83F930"                                          ; cmp ecx, '0'
        . "7407"                                            ; je +7
        ;       ErrorCallback();
        . "B9" DllCallDebugger_FormatPtr(ErrorCallback)     ; mov ecx, ErrorCallback
        . "FFD1"                                            ; call ecx
        ; }
        . "83C40C"                                          ; add esp, 12
        . "C3")                                             ; ret
   
    pbin2:=__mcode("DllCallDebugger_TokenValue"
    /*
    ExprTokenType *token = (ExprTokenType*) aParam[0]->value_int64;

    if (token->symbol == SYM_VAR)
    {
        aResultToken.symbol = SYM_OPERAND;
        aResultToken.marker = token->var->mContents;
    }
    else
    {
        aResultToken.symbol = token->symbol;
        aResultToken.value_int64 = token->value_int64;
    }
    */  , "8B4424088B088B018B50088B4C240483FA03750B428951088B108B028901C38951088B1089118B4004894104C3")

    ; WARNING: This will affect the entire page(s) containing our generated code.
    ; Make our code executable (for systems with Data Execution Prevention enabled):
    DllCall("VirtualProtect","uint",pbin,"uint",22,"uint",0x40,"uint*",0)
    DllCall("VirtualProtect","uint",pbin2,"uint",22,"uint",0x40,"uint*",0)
}

DllCallDebugger_FormatPtr(ptr) {
    FI := A_FormatInteger
    SetFormat, Integer, H
    ptr := RegExReplace(SubStr("00000000" SubStr(ptr+0, 3), -7), "(..)(..)(..)(..)", "$4$3$2$1")
    SetFormat, Integer, %FI%
    return ptr
}

; token MUST be the immediate integer result of a math expression or built-in function.
DllCallDebugger_TokenValue(token) {
    ; Implemented in machine code; see DllCallDebugger().
}

DllCallDebugger_DefaultHandler(aResultToken, aParam, aParamCount)
{
    ListLines
   
    Call = DllCall(
    Loop % aParamCount
        P:=NumGet(aParam+A_Index*4-4)
        ,V:=DllCallDebugger_TokenValue(P+0)
        ,T:=NumGet(P+8)
        ,Call.=(A_Index>1 ? ", ":"") . (T=1||T=2 ? V : """" V """")
    Call.=")"
   
    MsgBox DllCall failed with ErrorLevel = %ErrorLevel%`n`n     Specifically: %Call%
}
