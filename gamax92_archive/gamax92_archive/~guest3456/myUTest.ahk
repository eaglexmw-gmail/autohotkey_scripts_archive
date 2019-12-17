/* Group:  About
      o v0.3 by majkinetor.
      o v0.3a by guest3456 (search 'guest3456' for changes)
      o Includes LowLevel.ahk by Lexikos. See <http://www.autohotkey.com/forum/topic26300.html>
      o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
 */


/* Title: UTest 
		  Unit testing framework.

		  (see Utest.png)

 Usage:	
		 UTest will scan the script for functions which name starts with "Test_". Test functions have no parameter and use one of the 
		 Assert functions. If Assert function fails, test will fail and you will see that in the result CSV (or in ListView representing that CSV).
		 Result shows the test state, the function name, line number and test name if you have it. 

		 To test your script, use the following template :

		(start code)
			#include UTest.ahk
			return

			Test_MyTest1() {
			}

			Test_MyTest2() {
			}
			...
			...
			#include FunctionToTest.ahk
		(end code)

 Remarks:
		By default, executing the test script will show the GUI with the results. To get the same results in textual form you can set NoGui option and 
		query Result variable from UTest storage:

		>  UTest("NoGUI", true)
		>  #include UTest.ahk
		>  msgbox  UTest("Result")	
		
 CSV:
		Result	- Test result (OK | FAIL).
		Test	- Test function name.
		Line	- Line number of the test.
		Name	- List of names that failed. Name is the Assert user label. Give name to the Assert function if you have multiple Assert functions inside single test.
		Param	- List of parameters which failed (Assert_True, Assert_False)

		Additionally, if you use Gui, tests that failed will be selected and if any of the test failed, complete operation will be marked as failed at the bottom of the gui.
*/
#SingleInstance, force

UTest("Result", UTest_Start( UTest("NoGui") ))	;execute tests

/*
 Function: Assert_Equal 
      ( by guest3456 )
      takes two expressions and compares if they are equal
      first parameter is the actual value 
      second parameter is the expected output 
*/
Assert_Equal(b1="", b2="", Name="") {
   if (b1 != b2) {
      UTest_setFail(Name, "", b2, b1)
   }
}
/*
 Function: Assert
       ( by guest3456 )
       wrapper for Assert_Equal
*/
Assert( b1="", b2="", Name="") {
   Assert_Equal( b1, b2, Name)
}

/*
 Function: Assert_True 
		   Check if conditions are true. 
		   All parameters must be expressions except the first one which may be the string representing the test name.
 */
Assert_True( b1="", b2="", b3="", b4="", b5="", b6="", b7="", b8="", b9="", b10="") {
	bName := b1 + 0 = "", Name := bName ? b1 : ""
	loop, 10
		if (A_Index = 1) && (Name != "")
			 continue
		else ifNotEqual, b%A_Index%,,ifNotEqual, b%A_Index%, 1
			 b := UTest_setFail( "", A_Index - (bName ? 1 : 0))

	if b
		UTest_setFail( Name, "," )
}
/*
 Function: Assert_False
 		   Check if conditions are false.
		   All parameters must be expressions except the first one which may be the string representing the test name.
 */
Assert_False( b1="", b2="", b3="", b4="", b5="", b6="", b7="", b8="", b9="", b10="" ) {
	Name := b1 + 0 = "" ? b1 : ""
	loop, 10
		ifNotEqual, b%A_Index%,, ifNotEqual, b%A_Index%, 0
			b := UTest_setFail( Name, A_Index - (bName ? 1 : 0))
	
	if b
		UTest_setFail( Name, "," )
}
/*
 Function:	Assert_Empty 
			Check if variable is empty.
 */
Assert_Empty( Var, Name="" ){
	if (Var != "")
		UTest_setFail( Name )
}
/*
 Function: Assert_NotEmpty 
		   Check if variable is not empty.
 */
Assert_NotEmpty( Var, Name="" ){
	if (Var = "")
		UTest_setFail( Name )
}
/*
 Function: Assert_Contains 
 		   Check if variable contains string.
 */
Assert_Contains(Var, String, Name=""){
	if !InStr(Var, String)
		UTest_setFail( Name )
}

/*
 Function:  Assert_StartsWith
 			Check if variable starts with string.
 */
Assert_StartsWith(Var, String, Name=""){
	if SubStr(Var, 1, Strlen(String)) != String
		UTest_SetFail( Name )
}
/*
 Function: Assert_EndsWith
 		   Check if variable ends with string.
 */
Assert_EndsWith(Var, String, Name=""){
	ifEqual, String,,return
	if SubStr(Var, -1*Strlen(String)+1) != String
		UTest_setFail( Name )
}

/*
 Function: Assert_Match
		   Check if variable content matches RegEx pattern.
 */
Assert_Match(Var, RegEx, Name=""){
	if !RegExMatch(Var, RegEx) 
		UTest_setFail( Name )
}


/*
 Function: UTest_Edit
		   Open editor with given file and go to line number.
		   Required to be implemented by the user in order for double click in GUI to work.
 */
UTest_Edit( Path, LineNumber ) 
{
	Run, "d:\Utils\Edit Plus\EditPlus.exe" "%Path%"
	WinWait, EditPlus
	WinMenuSelectItem,,,Search, Go To, 1&
	Send %LineNumber%{Enter}
}

;===================================================== PRIVATE ======================================


UTest_runTests(){
	tests := UTest_GetTests(), bNoGui := UTest("NoGui")
	if  (tests = "") {
		msgbox No tests found !
		ExitApp
	}

	bTestsFail := 0
	loop, parse, tests, `n
	{
		StringSplit, f, A_LoopField, %A_Space%
		%f1%()		
		bFail := UTest("F"), Param := UTest("Param"), Name := UTest("Name"), fName := SubStr(f1,6)
		expected := UTest("expected"), actual := UTest("actual") ;// guest3456
		ifEqual, bFail, 1, SetEnv, bTestsFail, 1

		s .= (bFail ? "FAIL" : "OK") "," fName "," f2 "," Name "," Param "`n"
		UTest("F", 0),	UTest("Param", ""), UTest("Name", ""), UTest("expected", ""), UTest("actual", "") ;// guest3456

		if !bNoGui
			LV_Add(bFail ? "Select" : "", bFail ? "FAIL" : "OK", fName, f2, expected, actual, Name, Param) ;// guest3456
	}
	if !bNoGui
		LV_ModifyCol(), LV_ModifyCol(1, 50), LV_ModifyCol(3, 50), LV_ModifyCol(4, 50), LV_ModifyCol(5, 50), LV_ModifyCol(6, 150), LV_ModifyCol(7, 50) ;// guest3456

	UTest("TestsFail", bTestsFail)
	return SubStr(s, 1, -1)
}

UTest_getTests() {
	s := UTest_GetFunctions()
	loop, parse, s, `n
	{
		if SubStr(A_LoopField, 1, 5)="Test_"
			t .= A_LoopField "`n"
	}
	return SubStr(t, 1, -1)
}

UTest_getFunctions() {
   LowLevel_init()
   func_ptr := __getFirstFunc()
   LN_OFFSET := A_AhkVersion <= "1.0.48.05.L52" ? 8 : 4
   loop{
      ; line_ptr :=   NumGet(func_ptr+4, 0, "Uint"), lineno := NumGet(line_ptr+8, 0, "Uint")
      line_ptr :=   NumGet(func_ptr+4), lineno := NumGet(line_ptr+LN_OFFSET)
      fNames .= DllCall("MulDiv", "Int", NumGet(func_ptr+0, 0, "UInt"), "Int",1, "Int",1, "str") " " lineno "`n"
      func_ptr := NumGet(func_ptr+44, 0, "UInt")
      ifEqual, func_ptr, 0, break
   }
   return SubStr(fNames, 1, -1)
}

UTest_getFreeGuiNum(){
	loop, 99  {
		Gui %A_Index%:+LastFoundExist
		IfWinNotExist
			return A_Index
	}
	return 0
}

UTest_start( bNoGui = false) {
	if !bNoGui
		hGui := UTest_CreateGui()
	s := UTest_RunTests()
	
	if (hGui){
		Result := UTest("TestsFail") ? "FAIL" : "OK"
		;// guest3456 - change text background color
		ControlGet, texthwnd, hwnd,, Static1, ahk_id %hGui%
		if UTest("TestsFail") {
			Result := " FAIL"
			CColor(texthwnd, "red")
		} else {
			Result := " OK"
			CColor(texthwnd, "green")
		}
		ControlSetText,Static1, %Result%, ahk_id %hGui%
	}
	return s
}

UTest_createGui() {
	w := 500, h := 400
	n := UTest_getFreeGuiNum() 

	Gui, %n%: +LastFound +LabelUTest_
	hGui := WinExist()
	Gui, %n%: Add, ListView, w%w% h%h% gUTest_OnList, Result|Test|Line|expected|actual|Name|Param ;// guest3456
	Gui, %n%: Font, s20 bold cRED, Courier New
	Gui, %n%: Add, Text, w%w% h40
	Gui, %n%: Show,autosize, UTest - %A_ScriptName%
	UTest("GUINO", n)

	Hotkey, ifWinActive, ahk_id %hGui%
	Hotkey, ESC, UTest_Close
	Hotkey, ifWinActive
	return hGui

 UTest_Close:
 	ExitApp
 return
}

UTest_setFail(Name="", Param="", expected="", actual="") {
	UTest("Param", UTest("Param") " " Param)
	UTest("Name",  UTest("Name") " " Name)
	;// guest3456 - expected/actual used in conjunction with Assert_Equal()
	UTest("expected",  UTest("expected") " " expected)
	UTest("actual",  UTest("actual") " " actual)
	UTest("F", 1 )
	return 1
}

UTest_onList:
	ifNotEqual, A_GuiEvent, DoubleClick, return

	LV_GetText(lineNumber, LV_GetNext(), 3)
	UTest_Edit(A_ScriptFullPath, lineNumber)
return

UTest(var="", value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
return
}


;====================== LowLevel.ahk =====================
; LowLevel
; http://www.autohotkey.com/forum/topic26300.html
; LowLevel
; http://www.autohotkey.com/forum/topic26300.html

LowLevel_init() {
    if InStr(A_AhkVersion,"L") && A_AhkVersion < "1.0.48.03.L31"
    {
        MsgBox 49, LowLevel, LowLevel is unsupported on this version of AutoHotkey (%A_AhkVersion%). Use at your own risk.
        ifMsgBox Cancel
            ExitApp
    }
    __init()
}

; Declare functions to be implemented in machine code
; __INIT MUST BE CALLED AT LEAST ONCE FOR THESE TO WORK:
__static(var) {
}
__getVar(var) {
}
__alias(alias, alias_for) {
}
__cacheEnable(var) {
}
__getTokenValue(token) {
}

__init() {
    Global
    ; __getFirstFunc must be called at least once before (or by) __mcode, or it won't work properly later on.
    __getFirstFunc()
    __mcode("__getVar","8B4C24088B0933C08379080375028B018B4C2404998901895104C3")
    __mcode("__static","8B4424088B008378080375068B0080481504C3")
    __mcode("__alias","8B4C24088B01837808038B4904751D8B51088B005633F64A74044A4A75028B3185F60F94C189700C8848175EC3")
    __mcode("__cacheEnable","8B4424088B0083780803750F8B008078170075038B400C8060157FC3")
    __mcode("__getTokenValue","8B4424088B0083780801753D8B088B510883FA0375128B098A41158AD080E23074280FB6D2C1EA048B4424048950088B1189108B490489480483780805750A8B008B10508B4204FFD0C3A8028B442404740DC74008050000008B118910EBDAC74008040000008B49088908EB")
    __mcode("__init","C3"), __mcode("LowLevel_init","C3") ; C3 = RET
}

__mcode(Func, Hex)
{
    if !(pFunc := ((Func+0) ? Func : __findFunc(Func)))
        || !(pbin := DllCall("GlobalAlloc","uint",0,"uint",StrLen(Hex)//2))
        return 0
    Loop % StrLen(Hex)//2
        NumPut("0x" . SubStr(Hex,2*A_Index-1,2), pbin-1, A_Index, "char")
    ptr := A_PtrSize ? "ptr" : "uint"
    DllCall("VirtualProtect", ptr, pbin, ptr, StrLen(Hex)//2, uint, 0x40, uintp, 0)
    NumPut(pbin,pFunc+4), NumPut(1,pFunc+49,0,"char")
    return pbin
}

; Helper function: Format a pointer for inclusion in a hex string.
__mcodeptr(p) {
    sprintf:=A_IsUnicode ? "swprintf":"sprintf"
    VarSetCapacity(buf, 20), DllCall("msvcrt\" sprintf, "str", buf, "str", "%08X"
        , "int", p>>24&255 | (p>>16&255)<<8 | (p>>8&255)<<16 | (p&255)<<24, "cdecl")
    return buf
}

__getGlobalVar(__gGV_sVarName)
{
    global
    return __getVar(%__gGV_sVarName%)
}

__getBuiltInVar(sVarName)
{
    static pDerefs, DerefCount
    if !pDerefs ;= label->mJumpToLine->mArg[0]->deref
    {
        pDerefs := NumGet(NumGet(NumGet(__findLabel("__getBuiltInVar_vars"),4),4),8)
        Loop
            if ! NumGet(pDerefs+(A_Index-1)*12) {
                DerefCount := A_Index-1
                break
            }
    }
    low := 0
    high := DerefCount - 1
    Loop {
        if (low > high)
            break
        mid := (low+high)//2
        i := DllCall("shlwapi\StrCmpNIA","uint",NumGet(pDerefs+mid*12),"str",sVarName,"int",NumGet(pDerefs+mid*12,10,"ushort"))
        if i > 0
            high := mid - 1
        else if i < 0
            low := mid + 1
        else
            return NumGet(pDerefs+mid*12,4)
    }
    return 0
__getBuiltInVar_vars:
    return % 0,
    ( Join`s
A_AhkPath A_AhkVersion A_AppData A_AppDataCommon A_AutoTrim A_BatchLines
A_CaretX A_CaretY A_ComputerName A_ControlDelay A_Cursor A_DD A_DDD A_DDDD
A_DefaultMouseSpeed A_Desktop A_DesktopCommon A_DetectHiddenText
A_DetectHiddenWindows A_EndChar A_EventInfo A_ExitReason A_FormatFloat
A_FormatInteger A_Gui A_GuiControl A_GuiControlEvent A_GuiEvent A_GuiHeight
A_GuiWidth A_GuiX A_GuiY A_Hour A_IconFile A_IconHidden A_IconNumber A_IconTip
A_Index A_IPAddress1 A_IPAddress2 A_IPAddress3 A_IPAddress4 A_IsAdmin
A_IsSuspended A_KeyDelay A_Language A_LastError A_LineFile A_LineNumber
A_LoopField A_LoopFileAttrib A_LoopFileDir A_LoopFileExt A_LoopFileFullPath
A_LoopFileLongPath A_LoopFileName A_LoopFileShortName A_LoopFileShortPath
A_LoopFileSize A_LoopFileSizeKb A_LoopFileSizeMb A_LoopFileTimeAccessed
A_LoopFileTimeCreated A_LoopFileTimeModified A_LoopReadLine A_MDay A_Min A_MM
A_MMM A_MMMM A_Mon A_MouseDelay A_MSec A_MyDocuments A_Now A_NowUtc
A_NumBatchLines A_OSType A_OSVersion A_PriorHotkey A_ProgramFiles A_Programs
A_ProgramsCommon A_ScreenHeight A_ScreenWidth A_ScriptDir A_ScriptFullPath
A_ScriptName A_Sec A_Space A_StartMenu A_StartMenuCommon A_Startup
A_StartupCommon A_StringCaseSense A_Tab A_Temp A_ThisFunc A_ThisHotkey
A_ThisLabel A_ThisMenu A_ThisMenuItem A_ThisMenuItemPos A_TickCount A_TimeIdle
A_TimeIdlePhysical A_TimeSincePriorHotkey A_TimeSinceThisHotkey
A_TitleMatchMode A_TitleMatchModeSpeed A_UserName A_WDay A_WinDelay A_WinDir
A_WorkingDir A_YDay A_Year A_YWeek A_YYYY Clipboard ClipboardAll ComSpec false
ProgramFiles true
    )
}

__getVarInContext(sVarName, pScopeFunc=0)
{
    static pThisFunc
    if pVar:=__getBuiltInVar(sVarName)
        return pVar
    if !pScopeFunc
        return __getGlobalVar(sVarName)
    if !pThisFunc && !(pThisFunc := __getFuncUDF(A_ThisFunc))
        return ; ERROR!
    
    ; Copy assume-local/global mode. Since it only affects double-derefs,
    ; it doesn't need to be restored to its previous value later.
    NumPut(NumGet(pScopeFunc+48,0,"char"),pThisFunc+48,0,"char")
    
    ; Back up this function's properties,
    VarSetCapacity(ThisFuncProps, 20)
    , DllCall("RtlMoveMemory","uint",&ThisFuncProps,"uint",pThisFunc+20,"uint",20)
    ; then overwrite them with the other function's properties:
    ;   mVar, mLazyVar, mVarCount, mVarCountMax, mLazyVarCount
    , DllCall("RtlMoveMemory","uint",pThisFunc+20,"uint",pScopeFunc+20,"uint",20)
    
; WARNING:
    ; If the thread is interrupted at this point and __getVarInContext is called
    ; again, the wrong set of local variables will be backed up and restored, so
    ; the second instance of __getVarInContext will overwrite the local vars
    ; of the first instance. Merging the lines (with ", ") prevents AutoHotkey
    ; from checking for messages, thus reducing the risk of interruption.
    ; (This would not work fully if __getVar were implemented in script.)
    
    ; Now resolve %sVarName% in the scope of the other func!
    , pVar := __getVar(%sVarName%)
    
    ; Update pScopeFunc's properties.
    , DllCall("RtlMoveMemory","uint",pScopeFunc+20,"uint",pThisFunc+20,"uint",20)
    
    ; Restore this function's properties.
    , DllCall("RtlMoveMemory","uint",pThisFunc+20,"uint",&ThisFuncProps,"uint",20)
    
    return pVar
}

__findFunc(FuncName, FirstFunc=0)
{
    if !FirstFunc {
        ; __getFuncUDF, in-line:
        if pCb := RegisterCallback(FuncName) {
            pFunc := NumGet(pCb+28)
            DllCall("GlobalFree","uint",pCb)
            if pFunc
                return pFunc
        } ; end __getFuncUDF.
        if !(FirstFunc := __getFirstFunc())
            return 0
    }
    pFunc := FirstFunc
    Loop {
        if __str(NumGet(pFunc+0)) = FuncName ; pFunc->mName
            return pFunc
        if ! pFunc := NumGet(pFunc+44) ; pFunc->mNextFunc
            return 0
    }
}
; How __findFunc works:
; - If we weren't given a list to search (via FirstFunc), try RegisterCallback.
;   RegisterCallback fails if the function is built-in or has ByRef parameters.
; - Built-in functions do not exist in the linked list until they are either
;   referenced in script or "searched for" by calling RegisterCallback.
; - To access the linked list of functions, __getFirstFunc searches through all
;   function derefs in the script. We then search the linked list.


__getFirstFunc()
{
    static pFirstFunc, LINE_ARG_OFFSET
    if !pFirstFunc {
        LINE_ARG_OFFSET := A_AhkVersion <= "1.0.48.05.L52" ? 4 : 8 ; Arg and LineNumber were swapped to optimize for 8-byte alignment in 64-bit builds. (64-bit isn't supported by this script, but 32-bit is also affected.)
        if !(pLine := __getFirstLine())
            return 0
        Loop {
            Loop % NumGet(pLine+1,0,"uchar") { ; pLine->mArgc
                pArg := NumGet(pLine+LINE_ARG_OFFSET) + (A_Index-1)*16  ; pLine->mArg[A_Index-1]
                if (NumGet(pArg+0,0,"uchar") != 0) ; pArg->type != ARG_TYPE_NORMAL
                    continue ; arg has no derefs (only a Var*)
                Loop {
                    pDeref := NumGet(pArg+8) + (A_Index-1)*12  ; pArg->deref[A_Index-1]
                    if (!NumGet(pDeref+0)) ; pDeref->marker (NULL terminates list)
                        break
                    if (NumGet(pDeref+8,0,"uchar")) ; pDeref->is_function
                    {
                        ; The first function is either the first defined function,
                        ; or if no explicitly #included UDFs exist, the first
                        ; built-in function referenced in code.
                        pFunc := NumGet(pDeref+4)
                        if (NumGet(pFunc+49,0,"uchar")) { ; pFunc->mIsBuiltIn
                            if !pFirstBIF
                                pFirstBIF := pFunc
                        } else { ; UDF
                            pFuncLine := NumGet(pFunc+4)
                            FuncLine := NumGet(pFuncLine+8)
                            FuncFile := NumGet(pFuncLine+2,0,"ushort")
                            if !pFirstFunc or (FuncFile < FirstFuncFile || (FuncFile = FirstFuncFile && FuncLine < FirstFuncLine))
                                pFirstFunc:=pFunc, FirstFuncLine:=FuncLine, FirstFuncFile:=FuncFile
                        }
                    }
                }
            }
            if !(pLine:=NumGet(pLine+20)) ; pLine->mNextLine
                break
        }
        if pFirstBIF
        {   ; Usually the first UDF will be before the first BIF, but not if
            ; only auto-included/stdlib UDFs exist *AND* the first BIF is
            ; referenced in code before the first UDF.
            if pFirstFunc
            {   ; Look for the BIF using the UDF as a starting point.
                pFunc := pFirstFunc
                Loop {
                    if !(pFunc := NumGet(pFunc+44)) ; pFunc->mNextFunc
                        break
                    ; If the BIF is found, the UDF must precede it in the list.
                    if (pFunc = pFirstBIF)
                        return pFirstFunc
                }
            ; If we got here, the BIF was not found, so is probably the first Func.
            }
            pFirstFunc := pFirstBIF
            return pFirstFunc
        }
    }
    return pFirstFunc
}

__findLabel(LabelName, FirstLabel=0)
{
    if !FirstLabel && !(FirstLabel := __getFirstLabel())
        return 0
    pLabel := FirstLabel
    Loop {
        if __str(NumGet(pLabel+0)) = LabelName
            return pLabel
        if ! pLabel := NumGet(pLabel+12)
            return 0
    }
}

__getFirstLabel()
{
    static pFirstLabel
    if !pFirstLabel {
        if !(pLine := NumGet(__getFuncUDF(A_ThisFunc)+4))
            return 0
        Loop {
            act := NumGet(pLine+0,0,"char")
            if (act = 96 || act = 95) ; ACT_GOSUB || ACT_GOTO
                break
            if !(pLine:=NumGet(pLine+20)) ; pLine->mNextLine
                return 0
        }
        pFirstLabel := NumGet(pLine+24)
        Loop {
            if ! pPrevLabel:=NumGet(pFirstLabel+8)
                break
            pFirstLabel := pPrevLabel
        }
    }
    return pFirstLabel
    ; Since Labels are in a doubly-linked list, we can find the first label
    ; by getting the Label associated with the goto line below.
    __getFirstLabel_label:
    goto __getFirstLabel_label
}

__getFirstLine()
{
    static pFirstLine
    if (pFirstLine = "") {
        if pThisFunc := __getFuncUDF(A_ThisFunc) {
            if pFirstLine := NumGet(pThisFunc+4) ; mJumpToLine
            Loop {
                if !(pLine:=NumGet(pFirstLine+16)) ; mPrevLine
                    break
                pFirstLine := pLine
            }
        }
    }
    return pFirstLine
}

__getFuncUDF(FuncName) {
    if pCb := RegisterCallback(FuncName) {
        func := NumGet(pCb+28)
        DllCall("GlobalFree","uint",pCb)
    }
    return func
}

__str(addr,len=-1) {
    if !addr
        return "__ERROR_NULL__"
    if len<0
        return DllCall("MulDiv","uint",addr,"int",1,"int",1,"str")
    VarSetCapacity(str,len), DllCall("lstrcpyn","str",str,"uint",addr,"int",len+1)
    return str
}

/*
__expr(expr, pScopeFunc=0)
{
    static pFunc, pThisFunc
    if !pFunc
        pFunc:=__getFuncUDF("__expr_sub"), pThisFunc:=__getFuncUDF(A_ThisFunc), __init()
    
    nInst := NumGet(pThisFunc+40)
    ; Using __static ensures the Line is never deleted. Attempting to view a
    ;   a deleted line with ListLines would crash the script.
    ; Using a static *array* allows recursion of __expr.
    ; Using nInst (recursion depth) as an array index preserves memory by
    ;   only allocating up to the maximum number of resursive instances, while
    ;   also ensuring that no other instance is using the same block of memory.
    VarSetCapacity(Line%nInst%,44,0), __static(Line%nInst%), pLine:=&Line%nInst%

    if ! __ParseExpressionArg(expr, pArg:=&Line%nInst%+32, pScopeFunc)
        return
    
    NumPut(pArg,NumPut(1,NumPut(102,pLine+0,0,"char"),0,"char"),2)
    , NumPut(pLine,NumPut(pLine,pLine+16))
    , NumPut(pLine,pFunc+4)
    , ret := __expr_sub()
    , NumPut(0,pLine+1,0,"char")
    , DllCall("GlobalFree","uint",NumGet(pArg+4)) ; text
    , DllCall("GlobalFree","uint",NumGet(pArg+8)) ; deref
    return ret
}
__expr_sub() {
    global
    ; Contents replaced at run-time by __expr.
}

; Was __MakeExpressionArg. Changed to accept arg pointer rather than allocating
; memory, since all args for a given command must be contiguous in memory.
__ParseExpressionArg(expr, pArg, pScopeFunc=0)
{
    ; This function needs to be reworked to actually parse and tokenize the expression.
    return false
}
*/

; More explicit aliases for __linePool.
__lineAlloc() {
    return __linePool()
}
__lineFree(pline) {
    __linePool(pline)
}
__linePool(pline=0)
{
    static pool, line_struct_size
    if !line_struct_size
        line_struct_size := InStr(A_AhkVersion,"L") ? 36 : 32  ; Support for AutoHotkey_L.
    if pline
        ; Clear the Line for consistency (returned lines will always be empty)
        ; and to be sure ListLines doesn't attempt to access invalid args, etc.
        DllCall("RtlZeroMemory","uint",pline,"uint",32), pool .= pline . ","
    else if i:=InStr(pool,",")
        ; Remove and return a Line from the pool.
        return pline:=SubStr(pool,1,i-1), pool:=SubStr(pool,i+1)
    else
    {   ; No Lines currently in the pool, so allocate a bunch.
        pline := DllCall("GlobalAlloc","uint",0x40,"uint",32*line_struct_size)
        pool =
        Loop, 31    ; exclude the first Line.
            pool .= pline+A_Index*line_struct_size . ","
        return pline
    }
}

__malloc(size)
{
    static init, empty
    ; Allocate 64+ bytes at least once so v never gets "simple alloc" memory.
    if init =
        VarSetCapacity(v, 64), VarSetCapacity(v, 0), init:=true
    ; Let AutoHotkey do malloc(size), then claim ownership of the memory.
    ; -1 for size because VarSetCapacity doesn't include the NULL-terminator.
    VarSetCapacity(v,size-1),p:=&v,NumPut(0,NumPut(0,NumPut(&empty,__getVar(v),8)))
    return p
}

__free(ptr)
{
    ; mHowAllocated = ALLOC_MALLOC, mCapacity = non-zero, mContents = ptr
    NumPut(2,NumPut(1,NumPut(ptr,__getVar(v),8),4),0,"char")
    ; AutoHotkey frees v's memory when the function returns.
}

__addVar(var, func)
{
    mVar         := NumGet(func+20)
    mVarCount    := NumGet(func+28)
    mVarCountMax := NumGet(func+32)
    
    if (mVarCount == mVarCountMax)
    {
        if !mVarCountMax
            allocCount = 100
        else if mVarCountMax <= 100000
            allocCount := mVarCountMax * 10
        else
            allocCount := mVarCountMax + 1000000
        
        temp := __malloc(allocCount*4)
        if !temp
            return
        DllCall("RtlMoveMemory", "uint", temp, "uint", mVar, "uint", mVarCount*4)
        NumPut(temp,       func+20) ; mVar
        NumPut(allocCount, func+32) ; mVarCountMax
        __free(mVar)
        mVar         := temp
        mVarCountMax := allocCount
    }

    varName := __str(NumGet(var+24))
    
    low := 0
    high := mVarCount
    Loop {
        if (low >= high)
            break
        mid := (low + high) // 2
        if __str(NumGet(NumGet(mVar+mid*4)+24)) < varName
            low := mid + 1
        else
            high := mid
    }
    
    if low < %mVarCount%
        DllCall("RtlMoveMemory", "uint", mVar+(low+1)*4, "uint", mVar+low*4, "uint", (mVarCount-low)*4)
    
    NumPut(var, mVar+low*4)
    NumPut(mVarCount+1, func+28)
}
 
;====================== END - LowLevel.ahk =====================

;// guest3456 - added to change text background color
;// http://www.autohotkey.com/forum/topic39055.html
CColor(Hwnd, Background="", Foreground="") {
	return CColor_(Background, Foreground, "", Hwnd+0)
}

CColor_(Wp, Lp, Msg, Hwnd) { 
	static 
	static WM_CTLCOLOREDIT=0x0133, WM_CTLCOLORLISTBOX=0x134, WM_CTLCOLORSTATIC=0x0138
		  ,LVM_SETBKCOLOR=0x1001, LVM_SETTEXTCOLOR=0x1024, LVM_SETTEXTBKCOLOR=0x1026, TVM_SETTEXTCOLOR=0x111E, TVM_SETBKCOLOR=0x111D
		  ,BS_CHECKBOX=2, BS_RADIOBUTTON=8, ES_READONLY=0x800
		  ,CLR_NONE=-1, CSILVER=0xC0C0C0, CGRAY=0x808080, CWHITE=0xFFFFFF, CMAROON=0x80, CRED=0x0FF, CPURPLE=0x800080, CFUCHSIA=0xFF00FF, CGREEN=0x8000, CLIME=0xFF00, COLIVE=0x8080, CYELLOW=0xFFFF, CNAVY=0x800000, CBLUE=0xFF0000, CTEAL=0x808000, CAQUA=0xFFFF00
 		  ,CLASSES := "Button,ComboBox,Edit,ListBox,Static,RICHEDIT50W,SysListView32,SysTreeView32"
	
	If (Msg = "") {      
		if !adrSetTextColor
			adrSetTextColor	:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "Gdi32.dll"), "str", "SetTextColor")
		   ,adrSetBkColor	:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "Gdi32.dll"), "str", "SetBkColor")
		   ,adrSetBkMode	:= DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "Gdi32.dll"), "str", "SetBkMode")
	
      ;Set the colors (RGB -> BGR)
		BG := !Wp ? "" : C%Wp% != "" ? C%Wp% : "0x" SubStr(WP,5,2) SubStr(WP,3,2) SubStr(WP,1,2) 
		FG := !Lp ? "" : C%Lp% != "" ? C%Lp% : "0x" SubStr(LP,5,2) SubStr(LP,3,2) SubStr(LP,1,2)

	  ;Activate message handling with OnMessage() on the first call for a class 
		WinGetClass, class, ahk_id %Hwnd% 
		If class not in %CLASSES% 
			return A_ThisFunc "> Unsupported control class: " class

		ControlGet, style, Style, , , ahk_id %Hwnd% 
		if (class = "Edit") && (Style & ES_READONLY) 
			class := "Static"
	
		if (class = "Button")
			if (style & BS_RADIOBUTTON) || (style & BS_CHECKBOX) 
				 class := "Static" 
			else return A_ThisFunc "> Unsupported control class: " class
		
		if (class = "ComboBox") { 
			VarSetCapacity(CBBINFO, 52, 0), NumPut(52, CBBINFO), DllCall("GetComboBoxInfo", "UInt", Hwnd, "UInt", &CBBINFO) 
			hwnd := NumGet(CBBINFO, 48)		;hwndList
			%hwnd%BG := BG, %hwnd%FG := FG, %hwnd% := BG ? DllCall("CreateSolidBrush", "UInt", BG) : -1

			IfEqual, CTLCOLORLISTBOX,,SetEnv, CTLCOLORLISTBOX, % OnMessage(WM_CTLCOLORLISTBOX, A_ThisFunc) 

			If NumGet(CBBINFO,44)	;hwndEdit
				Hwnd :=  Numget(CBBINFO,44), class := "Edit"
		} 

		if class in SysListView32,SysTreeView32
		{
			m := class="SysListView32" ? "LVM" : "TVM" 
			SendMessage, %m%_SETBKCOLOR, ,BG, ,ahk_id %Hwnd%
			SendMessage, %m%_SETTEXTCOLOR, ,FG, ,ahk_id %Hwnd%
			SendMessage, %m%_SETTEXTBKCOLOR, ,CLR_NONE, ,ahk_id %Hwnd%
			return
		}

		if (class = "RICHEDIT50W")
			return f := "RichEdit_SetBgColor", %f%(Hwnd, -BG)

		if (!CTLCOLOR%Class%)
			CTLCOLOR%Class% := OnMessage(WM_CTLCOLOR%Class%, A_ThisFunc) 

		return %Hwnd% := BG ? DllCall("CreateSolidBrush", "UInt", BG) : CLR_NONE,  %Hwnd%BG := BG,  %Hwnd%FG := FG
   } 
 
 ; Message handler 
	critical					;its OK, always in new thread.

	Hwnd := Lp + 0, hDC := Wp + 0
	If (%Hwnd%) { 
		DllCall(adrSetBkMode, "uint", hDC, "int", 1)
		if (%Hwnd%FG)
			DllCall(adrSetTextColor, "UInt", hDC, "UInt", %Hwnd%FG)
		if (%Hwnd%BG)
			DllCall(adrSetBkColor, "UInt", hDC, "UInt", %Hwnd%BG)
		return (%Hwnd%)
	}
}