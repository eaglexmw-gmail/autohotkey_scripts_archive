;: Title: Struct.ahk by HotKeyIt
;

; Function: Struct
; Description:
;      Struct is based on AHK_L Objects and supports both, ANSI and UNICODE version, so to use it you will require <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Lexikos AutoHotkey_L.exe</a> or other versions based on it that supports objects.<br><br>Struct is used to create new structure. You can create predefined structures that are saved as static variables inside the function or pass you own structure definition.<br>Struct.ahk supportes structure in structure as well as Arrays of structures and Vectors.<br>Visit <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Struct.ahk at AutoHotkey</a> forum, any feedback is welcome.
; Syntax: Struct(Structure_Definition,Address)
; Parameters:
;	   General Design - Struct function will create Object(s) that will manage fields of structure(s), for example RC := Struct("RECT") creates a RECT structure with fields left,top,right,bottom. To pass structure its pointer to a function or DllCall or SendMessage you will need to use RC[""] or RC[].<br><br>To access fields you can use usual Object syntax: RC.left, RC.right ...<br>To set a field of the structure use RC.top := 100.
;	   Field types - All AutoHotkey and Windows Data Types are supported<br>AutoHotkey Data Types<br> Int, Uint, Int64, UInt64, Char, UChar, Short, UShort, Fload and Double.<br>Windows Data Types<br> - note, TCHAR and CHAR return actual character rather than the value, where UCHAR will return the value of character: Asc(char)<br>ATOM,BOOL,BOOLEAN,BYTE,CHAR,COLORREF,DWORD,DWORDLONG,DWORD_PTR,<br>DWORD32,DWORD64,FLOAT,HACCEL,HALF_PTR,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,<br>HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,<br>HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRESULT,HRGN,HRSRC,HSZ,HWINSTA,HWND,INT,<br>INT_PTR,INT32,INT64,LANGID,LCID,LCTYPE,LGRPID,LONG,LONGLONG,LONG_PTR,LONG32,LONG64,LPARAM,LPBOOL,<br>LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,<br>LPWORD,LPWSTR,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,<br>PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,<br>PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_64,POINTER_SIGNED,POINTER_UNSIGNED,PSHORT,PSIZE_T,<br>PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,<br>PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,<br>SHORT,SIZE_T,SSIZE_T,TBYTE,TCHAR,UCHAR,UHALF_PTR,UINT,UINT_PTR,UINT32,UINT64,ULONG,ULONGLONG,<br>ULONG_PTR,ULONG32,ULONG64,USHORT,USN,WCHAR,WORD,WPARAM
;	   <b>Mode</b> - <b>Description</b>
;	   User defined - To create a user defined structure you will need to pass a string of predefined types and field names.<br>Default type is UInt, so for example for a RECT structure type can be omited: <b>"left,top,right,left"</b>, which is the same as <b>"Uint left,Uint top,Uint right,Uint bottom"</b><br><br>You can also use Structure contstructor that can be obtained by calling Struct("")<br>Using constructor you can define structures very similar to C#/C++ syntax, see example how to use.
;	   Global - Global variables can be used to save structures, easily pass name of that variable as first parameter, e.g. Struct("MyStruct") where MyStruct must be a global variable with structure definition.
;	   Static - Struct() function holds some example structure definitions like RECT or POINT, to create such a structure you will need to pass a string containing the name of desired structure, same as for Global mode, for example p:=Struct("POINT").<br>You can also define static structures dynamically, therefore enter Name of structure followed by : before structure definition, e.g. Struct("MyStruct:length,width").
;	   Array - To create an array of structures include a digit in the end of your string enclosed in squared brackets.<br>For example "RECT[2]" would create an array of 2 structures.<br>This feature can also be used for user defined arrays, for example "Int age,TCHAR name[10]".
;	   Union - Using {} you can create union, for example: <br>AHKVar:="{Int64 ContentsInt64,Double ContentsDouble,object},...
;	   Pointer - To create a pointer you can use *, for example: CHR:="char *str" will hold a pointer to a character. Same way you can have a structure in structure so you can call for example Label.NextLabel.NextLabel.JumpToLine
;	   <b>Other</b> - <b>Special call modes</b>
;	   Struct:=Struct(StructObject,<b>pointer</b>) - Pass a pointer as second parameter to occupy existing strucure.
;	   <b>size</b>:=Struct(StructObject) - Pass a structure prevoiusly create with Struct() to receive the size of your sructure.
;	   <b>ConstructorObj</b><br>:=Struct("") - get contstructor object that can be used to define and create structures
; Return Value:
;     In create mode Structure Object is returned, else you can receive the size of your structure
; Remarks:
;		Sctruct_Count() and Struct_getVar() are used internally by Struct. , Struct_Get() and Struct_Put() are meta functions used to set and get fields of structure, these do not need to be called by the user.<br><br><b>NOTE!!! accessing a field that does not exist will crash your application, these errors are not catched for performance reasons.</b>
; Related:
; Example:
;		file:Struct_Example.ahk
;
Struct(@def,@obj="",@name="",@offset=0,@TypeArray=0,@Encoding=0){
	static ;static mode, so structure definitions can be declared statically if waited
  ;argument size
  static PTR:=A_PtrSize,UPTR:=PTR,SHORT:=2,USHORT:=SHORT,INT:=4,UINT:=INT,INT64:=8,UINT64:=INT64,DOUBLE:=INT64,FLOAT:=INT,CHAR:=1,UCHAR:=CHAR
  ;base for user structures
  static @Struct:=Object("base",Object("__Get","Struct","__Set","Struct")) ;struct will be global, used to create structures
  ;struct constructor object
  static @base:=Object("__Get","Struct_Get","__Set","Struct_Put"),data_types:=Object("SHORT",2,"USHORT",2,"INT",4,"UINT",4,"INT64",8,"UINT64",8,"DOUBLE",8,"FLOAT",4,"CHAR",1,"UCHAR",1)
  ;Windows Data Types
  static VOID="PTR",TBYTE=A_IsUnicode?"USHORT":"UCHAR",TCHAR=A_IsUnicode?"USHORT":"UCHAR",HALF_PTR=A_PtrSize=8?"INT":"SHORT",UHALF_PTR=A_PtrSize=8?"UINT":"USHORT"
  static BOOL="Int",INT32="Int",LONG="Int",LONG32="Int",LONGLONG="Int64",LONG64="Int64",USN="Int64",HFILE="PTR",HRESULT="PTR",INT_PTR="PTR",LONG_PTR="PTR",POINTER_64="PTR",POINTER_SIGNED="PTR"
  static SSIZE_T="PTR",WPARAM="PTR",BOOLEAN="UCHAR",BYTE="UCHAR",COLORREF="UInt",DWORD="UInt",DWORD32="UInt",LCID="UInt",LCTYPE="UInt",LGRPID="UInt",LRESULT="UInt",PBOOL="UInt",PBOOLEAN="UInt"
  static PBYTE="UInt",PCHAR="UInt",PCSTR="UInt",PCTSTR="UInt",PCWSTR="UInt",PDWORD="UInt",PDWORDLONG="UInt",PDWORD_PTR="UInt",PDWORD32="UInt",PDWORD64="UInt",PFLOAT="UInt",PHALF_PTR="UInt",UINT32="UInt"
  static ULONG="UInt",ULONG32="UInt",DWORDLONG="UInt64",DWORD64="UInt64",ULONGLONG="UInt64",ULONG64="UInt64",DWORD_PTR="UPTR",HACCEL="UPTR",HANDLE="UPTR",HBITMAP="UPTR",HBRUSH="UPTR"
  static HCOLORSPACE="UPTR",HCONV="UPTR",HCONVLIST="UPTR",HCURSOR="UPTR",HDC="UPTR",HDDEDATA="UPTR",HDESK="UPTR",HDROP="UPTR",HDWP="UPTR",HENHMETAFILE="UPTR",HFONT="UPTR",HGDIOBJ="UPTR",HGLOBAL="UPTR"
  static HHOOK="UPTR",HICON="UPTR",HINSTANCE="UPTR",HKEY="UPTR",HKL="UPTR",HLOCAL="UPTR",HMENU="UPTR",HMETAFILE="UPTR",HMODULE="UPTR",HMONITOR="UPTR",HPALETTE="UPTR",HPEN="UPTR",HRGN="UPTR",HRSRC="UPTR"
  static HSZ="UPTR",HWINSTA="UPTR",HWND="UPTR",LPARAM="UPTR",LPBOOL="UPTR",LPBYTE="UPTR",LPCOLORREF="UPTR",LPCSTR="UPTR",LPCTSTR="UPTR",LPCVOID="UPTR",LPCWSTR="UPTR",LPDWORD="UPTR",LPHANDLE="UPTR",LPINT="UPTR"
  static LPLONG="UPTR",LPSTR="UPTR",LPTSTR="UPTR",LPVOID="UPTR",LPWORD="UPTR",LPWSTR="UPTR",PHANDLE="UPTR",PHKEY="UPTR",PINT="UPTR",PINT_PTR="UPTR",PINT32="UPTR",PINT64="UPTR",PLCID="UPTR",PLONG="UPTR",PLONGLONG="UPTR"
  static PLONG_PTR="UPTR",PLONG32="UPTR",PLONG64="UPTR",POINTER_32="UPTR",POINTER_UNSIGNED="UPTR",PSHORT="UPTR",PSIZE_T="UPTR",PSSIZE_T="UPTR",PSTR="UPTR",PTBYTE="UPTR",PTCHAR="UPTR",PTSTR="UPTR",PUCHAR="UPTR",PUHALF_PTR="UPTR"
  static PUINT="UPTR",PUINT_PTR="UPTR",PUINT32="UPTR",PUINT64="UPTR",PULONG="UPTR",PULONGLONG="UPTR",PULONG_PTR="UPTR",PULONG32="UPTR",PULONG64="UPTR",PUSHORT="UPTR",PVOID="UPTR",PWCHAR="UPTR",PWORD="UPTR",PWSTR="UPTR"
  static SC_HANDLE="UPTR",SC_LOCK="UPTR",SERVICE_STATUS_HANDLE="UPTR",SIZE_T="UPTR",UINT_PTR="UPTR",ULONG_PTR="UPTR",ATOM="Ushort",LANGID="Ushort",WCHAR="Ushort",WORD="Ushort"
  ;Common structures
	static RECT="left,top,right,bottom",POINT="x,y",POINTS="Short x,Short y",FILETIME="dwLowDateTime,dwHighDateTime"
  static SYSTEMTIME="Short wYear,Short wMonth,Short wDayOfWeek,Short wDay,Short wHour,Short wMinute,Short wSecond,Short Milliseconds"
  static WIN32_FIND_DATA="dwFileAttributes,FILETIME ftCreationTime,FILETIME ftLastAccessTime,FILETIME ftLastWriteTime,nFileSizeHigh,nFileSizeLow,dwReserved0,dwReserved1,TCHAR cFileName[260],TCHAR cAlternateFileName[14]"
  ;AHK structures
  static AHKLine="UChar ActionType,UChar Argc,UShort FileIndex,Arg,LineNumber,Attribute,*AHKLine PrevLine,*AHKLine NextLine,RelatedLine,ParentLine"
  static AHKLabel="name,*AHKLine JumpToLine,*AHKLabel PrevLabel,*AHKLabel NextLabel"
  static AHKArgStruct="UChar type,UChar is_expression,UShort length,text,{*AHKDerefType deref,*AHKVar var},*AHKExprTokenType postfix"
  static AHKDerefType="marker,{*AHKVar var,*AHKFunc func},Char is_function,UChar param_count,UShort length"
  static AHKExprTokenType="{Int64 value_int64,Double value_double,*AHKVar var,marker},buf,Int symbol,*AHKExprTokenType circuit_token"
  static AHKFuncParam="*AHKVar var,UShort is_byref,UShort default_type,{default_str,Int64 default_int64,Double default_double}"
  static AHKRCCallbackFunc="na1,na2,na3,callfuncptr,na4,Short na5,UChar actual_param_count,UChar create_new_thread,event_info,*AHKFunc func"
  static AHKFunc="Name,{BIF,*AHKLine JumpToLine},*AHKFuncParam Param,Int ParamCount,Int MinParams,*AHKVar var,*AHKVar LazyVar,Int VarCount,Int VarCountMax,Int LazyVarCount,Int Instances,*AHKFunc NextFunc,Char DefaultVarType,Char IsBuiltIn"
  static AHKVar="{Int64 ContentsInt64,Double ContentsDouble,object},Contents,{Length,AliasFor},{Capacity,BIV},UChar HowAllocated,UChar Attrib,Char IsLocal,UChar Type,Name"
	;local variables
  local @key,@value,@enum,@size,@subdef,@split,@split1,@split2,@split3,@StructObj,@union,@unionoff,@unionoffset=0,@pointer,@suboffset,@field,@array
  If IsObject(@def){ ;used as structure creator + get size of structure + internal recrusive calls
		If (@name=1){ ;correct offset for structures in structures
			@enum:=@def._NewEnum()
			While @enum[@key,@value] 
				If IsObject(@value)
					@value[""]:=(@def[""])+@value[""],Struct(@value,0,1)
		} else If (@name=2){ ;set pointer back to offset
			@enum:=@def._NewEnum() 
			While @enum[@key,@value]
				If IsObject(@value)
          Struct(@value,0,2),@value[""]:=@value[""]-@def[""]
    } else if (@obj && @name=""){ ;constructor create structure
      Return Struct(@obj)
    } else if (@obj && @name){ ;constructor define structure
        @split2:=@obj,@split1:=@name
      	Loop,Parse,@split1,`n,`r`t%A_Space%
      	{
          @field=
          Loop,parse,A_LoopField,`,`;,`t%A_Space%
          {
            If RegExMatch(A_LoopField,"^\s*//") ;break on comments
              break
            If (A_LoopField){
              If (!@field && @split3:=RegExMatch(A_LoopField,"\w\s+\w"))
                @field:=RegExReplace(A_LoopField,"\w\K\s+.*$")
              If Instr(A_LoopField,"{")
                @union++
              else If InStr(A_LoopField,"}")
                @split.="}"
              else {
                If @union
                  Loop % @union
                    @array.="{"
                @split.=(@split ? "," : "") (!@split3?(@field " "):"") @array A_LoopField
                @array:="",@union:=""
              }
            }
          }
        }
        %@split2%:=@split
        Return
    } else ;Struct_GetSize used to count size of Structure
			Return Struct_GetSize(@def) ;had to be excluded from Struct() since it needs to use local mode
    Return
	} else if @def= ;return structure constructor object
    return @struct
  If InStr(@def,":") && RegExMatch(@subdef:=SubStr(@def,1,InStr(@def,":")-1),"^\w+$") ;define static structure
		StringTrimLeft,@def,@def,% InStr(@def,":"),%@subdef%:=SubStr(@def,InStr(@def,":")+1)
  @StructObj:=IsObject(@obj) ? @obj : Object() ;create object for new structure
  If (IsObject(@obj) && @name) ;create new object and use it in this function
		@StructObj[@name,""]:=@offset,@StructObj:=@StructObj[@name]
  @subdef:=((RegExMatch(@def,"^\w+$") && (%@def%)) ? (%@def%) : @def) ;resolve definition
  If RegExMatch(@subdef,"^(\w+)\s*\[(\d+)\]$",@split){ ;array
    If @split1 in Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCVOID,LPDWORD,LPHANDLE,LPINT,LPLONG,LPVOID,LPWORD,,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,
      @split3 := 1 ;NumPut/NumGet
    else if @split1 in TCHAR,Char,UChar
      @split3 := 2,@Encoding := (@split1="TCHAR" ? (A_IsUnicode ? "UTF-16" : "CP0") : "CP0") ;Asc/Chr
    else if @split1 in LPCSTR,LPCTSTR,LPCWSTR,LPSTR,LPTSTR,LPWSTR
    {
      @split3 := 3 ;StrGet/StrPut
      if @split1 in LPTSTR,LPCTSTR
        @Encoding := A_IsUnicode ? "UTF-16" : "CP0"
      else if @split1 in LPWSTR,LPCWSTR
        @Encoding := "UTF-16"
      else
        @Encoding := "CP0"
    }
    if @split1 in BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,LPWORD,LPWSTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,TCHAR
      @split1:=%@split1%
    Loop % @split2
        @field.=(@field ? "," : "") @split1 " " A_Index
    Return Struct(@field,@obj,"",0,@split3,@Encoding)
  }
  @offset:=0
  Loop,Parse,@subdef,`,,%A_Space%
  {
    If (Asc(A_LoopField)=123 && @union && @unionoff:=1){
      StringTrimLeft,@field,A_LoopField,1
    } else if (Asc(A_LoopField)=123 && (@union:=1)){
      StringTrimLeft,@field,A_LoopField,1
    } else if (SubStr(A_LoopField,0)="}"){
      StringTrimRight,@field,A_LoopField,% SubStr(A_LoopField,-1)="}}"?2:1
    } else
      @field:=A_LoopField
    If (Asc(@field)=123 && @unionoff:=1){
      StringTrimLeft,@field,@field,1
    }
    If ( InStr(@field,"*") && @pointer:=1)
      @field:=RegExReplace(@field,"(\s)?\*(\s)?","$1$2")
    else @pointer:=0
    @split1:="",@split2:="",@split3:="" ; empty before filling in RegExMatch
    RegExMatch(@field,"^([^\s]+)\s*([A-Za-z0-9_]+)?\[?(\d+)?\]?$",@split)
    If (!@pointer && RegExMatch(@split2,"^[A-Za-z0-9_]+$") && %@split1%){
      If @split1 not in Char,UChar,Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,LPWORD,LPWSTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,TCHAR
      {
        If @split3{
          @StructObj[@split2 ? @split2 : @split1,""]:=@offset
          Loop % @split3
          {
            @size:=Struct(@split1,@StructObj[@split2 ? @split2 : @split1],A_Index,@offset) ;create structure in structure
            If (@union)
              @union:=@union<(@size-@offset)?@size-@offset:@union,@unionoffset:=(@unionoff?(@unionoffset+(@size-@offset)):0)
            else
              @offset+=@size
          }
          @StructObj[@split2 ? @split2 : @split1].base:=@base
          Continue
        } else {
          @size:=Struct(@split1,@StructObj,@split2 ? @split2 : @split1,@offset) ;create structure in structure
          If (@union)
              @union:=@union<(@size-@offset)?@size-@offset:@union,@unionoffset:=(@unionoff?(@unionoffset+(@size-@offset)):0)
          else
            @offset+=@size
          Continue
        }
      }
    }
    If (!@split3 && !pointer){ ;not an array so set operator
      If @TypeArray {
        @StructObj["`f" (@split2 ? @split2 : @split1)] := @TypeArray ;NumPut/NumGet
        , @StructObj["`v" (@split2 ? @split2 : @split1)] := @Encoding
      } else If !@split2 ;no type given, default to Uint
        @StructObj["`f" @split1] := 1 ;NumPut/NumGet
        , @StructObj["`v" @split1] := 0
      else If @split1 in UChar,Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCVOID,LPDWORD,LPHANDLE,LPINT,LPLONG,LPVOID,LPWORD,,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE
        @StructObj["`f" @split2] := 1 ;NumPut/NumGet
        , @StructObj["`v" @split2] := 0
      else if @split1 in TCHAR,CHAR
        @StructObj["`f" @split2] := 2 ;Asc/Chr
        , @StructObj["`v" @split2] := @split1="TCHAR" ? (A_IsUnicode ? "UTF-16" : "CP0") : "CP0"
      else if @split1 in LPCSTR,LPCTSTR,LPCWSTR,LPSTR,LPTSTR,LPWSTR
      {
        @StructObj["`f" @split2] := 3 ;StrGet/StrPut
        if @split1 in LPTSTR,LPCTSTR
          @StructObj["`v" @split2] := A_IsUnicode ? "UTF-16" : "CP0"
        else if @split1 in LPWSTR,LPCWSTR
          @StructObj["`v" @split2] := "UTF-16"
        else
          @StructObj["`v" @split2] := "CP0"
      }
    }
    if (@split2!="" || @split3){ ;a type was given in @split1 or array 
      If @split3
        @TypeArray:=@split1
      if @split1 in BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,LPWORD,LPWSTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,TCHAR
        @split1:=%@split1% ;Resolve Windows Data Types
    }
    @split:=@split2 ? @split2 : @split1
    If (@split3 && !@pointer){
      @field=
      Loop % @split3
        @field.=(@field ? "," : "") (@split2 ? (@split1) : "") " " A_Index
      @split3=
      If @TypeArray in UChar,Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCVOID,LPDWORD,LPHANDLE,LPINT,LPLONG,LPVOID,LPWORD,,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE
        @split3 := 1 ;NumPut/NumGet
      else if @TypeArray in TCHAR,CHAR
        @split3 := 2,@Encoding := (@TypeArray="TCHAR" ? (A_IsUnicode ? "UTF-16" : "CP0") : "CP0") ;Asc/Chr
      else if @TypeArray in LPCSTR,LPCTSTR,LPCWSTR,LPSTR,LPTSTR,LPWSTR
      {
        @split3 := 3 ;StrGet/StrPut
        if @TypeArray in LPTSTR,LPCTSTR
          @Encoding := A_IsUnicode ? "UTF-16" : "CP0"
        else if @TypeArray in LPWSTR,LPCWSTR
          @Encoding := "UTF-16"
        else
          @Encoding := "CP0"
      }
      @size:=Struct(@field,@StructObj,@split,@offset,@split3,@Encoding) ;create structure in structure
       If (@union)
        @union:=@union<(@size-@offset)?@size-@offset:@union,@unionoffset:=(@unionoff?(@unionoffset+(@size-@offset)):0)
      else
        @offset+=@size
      @TypeArray=
      Continue
    }
    @StructObj._Insert("`t" @split,"") ;local memory for strings
    @StructObj["`a" @split] := @pointer
    @StructObj["`n" @split] := @offset+@unionoffset ;offset
    @StructObj["`r" @split] := (@split2 ? @split1 : "UInt") ;type
    @offset:=@offset+(@union ? 0 : (@pointer ? A_PtrSize : (@split2 ? %@split1% : 4))) ;current offset
    If (@union){
      If (@split2=""){
        If @union<4
        @union:=4,@unionoffset:=(@unionoff?(@unionoffset+4):0)
      } else if (@pointer) {
        If (@union<A_PtrSize)
          @union:=A_PtrSize,@unionoffset:=(@unionoff?(@unionoffset+A_PtrSize):0)
      } else if @split1 is digit
        @union:=@union<@split1?@split1:@union,@unionoffset:=(@unionoff?(@unionoffset+@split1):0)
      else
        @union:=@union<%@split1%?%@split1%:@union,@unionoffset:=(@unionoff?(@unionoffset+%@split1%):0)
      If (@unionoff && @unionoffset>@union)
        @union:=@unionoffset
    }
    If (SubStr(A_LoopField,0)="}" && (@unionoff?((@unionoff:=0)+(@unionoffset:=0)):1) || SubStr(A_LoopField,-1)="}}")
      @offset:=@offset+@union,@union:=0
  }
  If (!@obj) ;create memory for main structure only
		@StructObj._SetCapacity("`n",@offset)
		,@StructObj[""]:=@StructObj._GetAddress("`n")
    ,DllCall("RtlFillMemory","Uint",@StructObj[""],"UInt",@offset,"UChar",0)
	 else if !IsObject(@obj)
		@StructObj[""]:=@obj
	If !@name
		Struct(@StructObj,0,1) ;correct offset for structures in structures
  @StructObj.base:=@base
	return IsObject(@obj) ? @offset : @StructObj ;Struct() is used by it self to create structures then offset must be returned.
}

Struct_GetSize(@object,o=0){
  static PTR:=A_PtrSize,UPTR:=A_PtrSize,Short:=2,UShort:=2,Int:=4,UInt:=4,Int64:=8,UInt64:=8,Double:=8,Float:=4,Char:=1,Uchar:=1
  e:=@object._NewEnum()
  While e[@key,@value]
  {
    If (Asc(@key)=13){ ;`r
      If @object["`a" SubStr(@key,2)]
        @value=UInt
      p:=@object["`n" SubStr(@key,2)]
      If (p_%p%="" || %@value%>p_%p%){
        If p_%p%
          o:=o-p_%p%
        p_%p%:=%@value%
        o:=o + %@value%
      }else if !p_%p%
        o:=o + %@value%
    } else if IsObject(@value){
      size:=Struct_GetSize(@value)
      p:=Abs(@value[""] - @object[""])
      If (p_%p%="" || size>p_%p%){
        If p_%p%
          o:=o-p_%p%
        p_%p%:=size
        o:=o + size
      }else if !p_%p%
        o:=o + size
    }
	}
  Return o
}

Struct_Get(obj,@key="",opt="~"){
  If @key=
    Return obj[""]
  type:=obj["`r" @key]
	If (obj["`a" @key]){ ;Pointer
    If Asc(opt)=126
      Return Struct(type,NumGet(obj[""]+0,obj["`n" @key]+0))
    else
      Return obj[@key][opt]
	} else if (obj["`f" @key]=1 || obj["`f" @key]=3) {
    Return NumGet(obj[""]+0,obj["`n" @key]+0,type)
	} else if obj["`f" @key]=2
		Return StrGet(obj[""]+obj["`n" @key],1,obj["`v" @key])
}

Struct_Put(obj,@key="",@value=9223372036854775809,opt="~"){
  If (@value=9223372036854775809){
    Struct(obj,0,2) ;set pointer back to offset
    ,obj._SetCapacity("`n",0)
    ,obj[""]:=@key ;set new address
    ,Struct(obj,0,1) ;set offset back to pointer
    Return
  }
	type:=obj["`r" @key]
  If (obj["`a" @key]) {
    NumPut(@value,obj[""]+0,obj["`n" @key]+0,A_PtrSize ? "UInt64" : "UInt")
  } else if (obj["`f" @key]=3){
    v:=Struct("AHKVar",Struct_getVar(@value))
    If (v.Contents && StrGet(v.Contents)="") ;its a value not a string, assume new address
      Return NumPut(@value,obj[""]+obj["`n" @key],(A_PtrSize=8 ? "UInt64" : "UInt"))
    obj._SetCapacity("`t" @key,(obj["`v" @key]="CP0" ? 1 : 2)*StrLen(@value)+2)
    StrPut(@value,obj._GetAddress("`t" @key),StrLen(@value)+1,obj["`v" @key])
    Return NumPut(obj._GetAddress("`t" @key),obj[""]+obj["`n" @key],(A_PtrSize=8 ? "UInt64" : "UInt"))
  } else if (obj["`f" @key] = 2) {
    StrPut(@value,obj[""]+obj["`n" @key],StrLen(@value),obj["`v" @key])
  } else {
    NumPut(@value,obj[""]+0,obj["`n" @key]+0,type)
  }
  Return @value
}

Struct_getVar(var) {
  static getVarFuncHex:="8B4C24088B0933C08379080375028B018B4C2404998901895104C3"
         ,pcb,pFunc:=NumGet((pcb:=RegisterCallback("Struct_getVar"))+28)
         ,pcb:=DllCall("GlobalFree","uint",pCb),init:=Struct_getVar("")
  if !(pbin := DllCall("GlobalAlloc","uint",0,"uint",StrLen(getVarFuncHex)//2))
      return 0
  Loop % StrLen(getVarFuncHex)//2
      NumPut("0x" . SubStr(getVarFuncHex,2*A_Index-1,2), pbin-1, A_Index, "char")
  DllCall("VirtualProtect", "PTR", pbin, "PTR", StrLen(getVarFuncHex)//2, uint, 0x40, uintp, 0)
  NumPut(pbin,pFunc+4), NumPut(1,pFunc+49,0,"char")
  return pbin
}