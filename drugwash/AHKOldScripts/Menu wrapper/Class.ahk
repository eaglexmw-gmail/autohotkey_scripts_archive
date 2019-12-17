/*

Class Library - add OOP to your programs

I want to send a BIG, BIG thanks to Lexikos for the template that make this possible.

This library is used by all classes to manipulate class data
*/

/*
DllCalls
*/

;returns a memory address to a Dll function (used to speed up DllCalls)
Class_LoadDllFunction(ThisFile, ThisFunction)
{
    ;note: this is not my code, and sadly I have forgotten who wrote it
    ;contact me and I'll add your name here to give proper credit
    if !(hModule := DllCall("GetModuleHandle", "uint", &ThisFile, "uint"))
    {
        hModule := DllCall("LoadLibrary", "uint", &ThisFile, "uint")
    }

    return DllCall("GetProcAddress", "uint", hModule, "uint", &ThisFunction, "uint")
}

Class_Alloc(size)
{
    static HeapAlloc, ProcessHeap

    if (!HeapAlloc)
    {
        HeapAlloc := Class_LoadDllFunction("Kernel32", "HeapAlloc")
        ProcessHeap := DllCall("GetProcessHeap")
    }

    start := subStr(size, 1,1 )

    if (start >= "0" && start <= "9")
    {
        ;if a number (alone) is specified, add 8 to size (+8 is for "class values")
        size += 8
    }
    else if (start = "a")
    {
        ;specify "a" followed by a number to allocate <number> bytes
        ;ex. a16 will allocate 16 bytes

        ;remove leading "a"
        StringTrimLeft, size, size, 1
    }

    ;GMEM_ZEROINIT = 0x40 - Initializes memory contents to zero.
    ;HEAP_ZERO_MEMORY 0x8 - The allocated memory will be initialized to zero.
    return DllCall(HeapAlloc, "uint", ProcessHeap, "uint", 0x8, "uint", size, "uint")
}

Class_ReAlloc(addr, size)
{
    static HeapReAlloc, ProcessHeap

    if (!HeapReAlloc)
    {
        AlreadyDone := true
        HeapReAlloc := Class_LoadDllFunction("Kernel32", "HeapReAlloc")
        ProcessHeap := DllCall("GetProcessHeap")
    }

    start := subStr(size, 1, 1)

    if (start >= "0" && start <= "9")
    {
        ;if a number (alone) is specified, add 8 to size (+8 is for "class values")
        size += 8
    }
    else if (start = "a")
    {
        ;specify "a" followed by a number to allocate <number> bytes
        ;ex. a16 will allocate 16 bytes

        ;remove leading "a"
        StringTrimLeft, size, size, 1
    }

    ;GMEM_ZEROINIT = 0x40 - Causes the additional memory contents to be
    ;initialized to zero if the memory object is growing in size.

    ;HEAP_ZERO_MEMORY 0x8 - If the reallocation request is for a larger size,
    ;the additional region of memory beyond the original size be initialized
    ;to zero. The contents of the memory block up to its original size are unaffected.
    return DllCall(HeapReAlloc, "uint", ProcessHeap, "uint", 0x8, "uint", addr, "uint", size, "uint")
}

Class_Free(addr)
{
    static HeapFree, ProcessHeap

    if (!HeapFree)
    {
        AlreadyDone := true
        HeapFree := Class_LoadDllFunction("Kernel32", "HeapFree")
        ProcessHeap := DllCall("GetProcessHeap")
    }

    DllCall(HeapFree, "uint", ProcessHeap, "uint", 0x0, "uint", addr)
}

;returns the null-terminated string at address
Class_toString(addr)
{
    static MulDiv

    if (!MulDiv)
        MulDiv := Class_LoadDllFunction("Kernel32", "MulDiv")

    ;MulDiv returns <Address> unmodified, but "str" causes AutoHotkey to
    ;interpret it as a string. Safe even if <Address> is NULL (0).
    return DllCall(MulDiv, "int", addr, "int",1,"int",1, "str")
}

;copies the string in <source> to destination address

;According to lstrcpy Function docs:
;The buffer (destination) must be large enough to contain the string,
;including the terminating null character.
Class_CopyString(Destination, ByRef Source)
{
    static lstrcpy

    if (!lstrcpy)
        lstrcpy := Class_LoadDllFunction("Kernel32", "lstrcpy")

    DllCall(lstrcpy, "uint", Destination, "uint", &Source)
}

;Moves a block of memory from one location to another.
;Note: The source and destination blocks may overlap.
;Todo: need to test
Class_MoveMemory(Destination, Source, Length)
{
    static RtlMoveMemory

    if (!RtlMoveMemory)
        RtlMoveMemory := Class_LoadDllFunction("Kernel32", "RtlMoveMemory")

    DllCall(RtlMoveMemory, "uint", Destination, "uint", Source, "uint", Length)
}

Class_MoveLeft(DataObject, Start, End, Count = 1)
{
    if (Start = End)
        return

    Source := DataObject + 4 * Start
    Destination := Source - 4 * Count
    Length := 4* (End - Start)

    Class_MoveMemory(Destination, Source, Length)
}

Class_MoveRight(DataObject, Start, End, Count = 1)
{
    if (Start = End)
        return

    Source := DataObject + 4 * Start
    Destination := Source + 4 * Count
    Length := 4* (End - Start)

    Class_MoveMemory(Destination, Source, Length)
}

;calls the destroy function for the ClassObject dynamically
;(for when you don't know the ClassName in advance)
Class_destroyThis(ClassObject)
{
    if (!ClassObject)
        return

    if (ClassName := Class_getClassName(ClassObject))
    {
        %ClassName%_destroy(ClassObject)
    }
}

;returns true if value is not locked (i.e. ready to delete)
;returns false if value is locked (i.e. not ready to delete)
;(call only in %ClassName%_destroy function)
Class_readyToDelete(ClassObject)
{
    LockCount := Class_getLockCount(ClassObject)

    if (LockCount > 0)
    {
        Class_decreaseLockCount(ClassObject)
        LockCount--
    }

    return (LockCount = 0)
}

;These functions are usable by any class object
;the setters should only be called within the class
;   (not by the user of the class)

;Class value has this structure: "ClassName(Options)"
;Options is a comma-delimented list (there can be spaces between items)
;however, such spaces only waste memory (a small bit, granted), and serve no purpose

Class_getClass(ClassObject)
{
    if (!ClassObject)
        return

    ;returns the ClassName as a String
    return Class_toString(NumGet(ClassObject+0))
}

;returns ClassName used to call Class functions dynamically
Class_getClassName(ClassObject)
{
    if (!ClassObject)
        return

    Class := Class_getClass(ClassObject)

    RegExMatch(Class, "^(?P<Name>\w+)", Class)

    return ClassName
}

Class_isWrapper(ClassObject)
{
    if (!ClassObject)
        return

    Class := Class_getClass(ClassObject)

    if !RegExMatch(Class, "^(?P<Name>\w+?(?P<_Node>_Node)?)(?:\((?P<Options>.*?)\))?$", Class)
        return false

    Loop, Parse, ClassOptions, `, , %A_Space%%A_Tab%
    {
        if (A_LoopField = "Wrapper")
            return ClassName
    }

    return false
}

Class_hasLockCount(ClassObject)
{
    ;returns whether ClassObject has a LockCount
    ;all Classes except Class_Nodes (e.g. CDDL_Node) have a LockCount
    ;specify "NoLockCount" in Class options if Class doesn't store the lock count

    if (!ClassObject)
        return

    Class := Class_getClass(ClassObject)

    if !RegExMatch(Class, "^(?P<Name>\w+?(?P<_Node>_Node)?)(?:\((?P<Options>.*?)\))?$", Class)
        return false

    if (Class_Node)
        return false

    Loop, Parse, ClassOptions, `, , %A_Space%%A_Tab%
    {
        if (A_LoopField = "NoLockCount")
            return false
    }

    return true
}

Class_isClassNode(ClassObject)
{
    if (!ClassObject)
        return

    Class := Class_getClass(ClassObject)

    return RegExMatch(Class, "^\w+_Node")
}

Class_setClass(ClassObject, ClassName)
{
    if (!ClassObject)
        return

    ;stores the address to the ClassName for <ClassObject>
    ;<ClassName> should be the return value from %ClassName%_initClass()

    NumPut(ClassName, ClassObject+0)
}

Class_getBuiltInSize(ClassObject)
{
    if (!ClassObject)
        return

    return NumGet(ClassObject+4, 0, "uchar")
}

Class_setBuiltInSize(ClassObject, BuiltInSize)
{
    if (!ClassObject)
        return

    NumPut(BuiltInSize, ClassObject+4, 0, "uchar")
}

Class_getSize(ClassObject)
{
    if (!ClassObject)
        return

    return NumGet(ClassObject+5, 0, "uchar")
}

Class_setUserDefinedSize(ClassObject, UserDefinedSize)
{
    if (!ClassObject)
        return

    NumPut(UserDefinedSize, ClassObject+5, 0, "uchar")
}

Class_getLockCount(ClassObject)
{
    if !Class_hasLockCount(ClassObject)
        return

    return NumGet(ClassObject+6, 0, "ushort")
}

Class_decreaseLockCount(ClassObject)
{
    if !Class_hasLockCount(ClassObject)
        return

    LockCount := NumGet(ClassObject+6, 0, "ushort")

    if (LockCount > 0)
        NumPut(LockCount - 1, ClassObject+6, 0, "ushort")
}

Class_increaseLockCount(ClassObject)
{
    if !Class_hasLockCount(ClassObject)
        return

    LockCount := NumGet(ClassObject+6, 0, "ushort")

    if (LockCount < 0xFFFF)
        NumPut(LockCount + 1, ClassObject+6, 0, "ushort")
}

;for use with %ClassName%_Node objects
Class_getNode(ClassObject)
{
    if !Class_isClassNode(ClassObject)
        return

    return Class_getValue(ClassObject, "a4", "obj")
}

;for use with %ClassName%_Node objects
Class_getNodeAddress(ClassObject)
{
    if !Class_isClassNode(ClassObject)
        return

    return NumGet(ClassObject+4)
}

;for use with %ClassName%_Node objects
Class_setNode(ClassObject, node)
{
    if !Class_isClassNode(ClassObject)
        return

    Class_setValue(ClassObject, "a4", node, "obj")
}

;for use with %ClassName%_Node objects
Class_replaceNode(ClassObject, node)
{
    if !Class_isClassNode(ClassObject)
        return

    Class_setValue(ClassObject, "a4", node, "robj")
}

;for use with %ClassName%_Node objects
;only called from a destroy function
Class_clearNode(ClassObject)
{
    if !Class_isClassNode(ClassObject)
        return

    NumPut(0, ClassObject+4)
}

;capacity is a replacement for Class_getSize if size is > 254
;(size MUST be set to -1 via Class_setUserDefinedSize(ClassObject, -1)
Class_getCapacity(ClassObject)
{
    ;0xFF = (UChar) -1
    if (Class_getSize(ClassObject) !=  0xFF)
        return

    return NumGet(ClassObject+8, 0, "uint")
}

Class_setCapacity(ClassObject, Capacity)
{
    ;0xFF = (UChar) -1
    if (Class_getSize(ClassObject) != 0xFF)
        return

    NumPut(Capacity, ClassObject+8, 0, "uint")
}

/*
Value getter and setters
*/

Class_getIndex(ThisIndex, ThisSize)
{
	;converts a one-based index to a valid index

	;if ThisSize = 0, returns 0

	;if ThisIndex = 0, then ThisSize is returned
    ;if ThisIndex > ThisSize, then ThisSize is returned
    ;negative numbers wrap (e.g. -1 -> ThisSize - 1)
	;if result <= 0 (after wrap), then 1 is returned
    ;else, ThisIndex is returned

	if (ThisSize = 0)
        return 0
    else if (ThisIndex > 0)
        return (ThisIndex > ThisSize ? ThisSize : ThisIndex)
    else if (!ThisIndex)
        return ThisSize
    else if (ThisIndex < 0)
    {
        ThisIndex += ThisSize

        return ThisIndex <= 0 ? 1 : ThisIndex
    }
}

Class_getOffset(ClassObject, index)
{
    start := subStr(index, 1, 1)

    if (start >= "0" && start <= "9")
    {
        ;index for user-specific values

        end := subStr(index, 0)

        if (end >= "a" && end <= "z")
        {
            ;convert to lower case
            StringLower, end, end

            ;remove trailing character
            StringTrimRight, index, index, 1

            ;convert to one-based offset ("a" -> 1)
            end := asc(end) - asc("a") + 1
        }
        else
            end := 0

        ;-1 converts index from one-based to zero-based
        ;(+8 for the first 8 bytes reserved in each Class for "Class values")
        index := 4 * (index - 1) + end + Class_getBuiltInSize(ClassObject) + 8
    }
    else if (start = "b")
    {
        ;index for built-in values

        ;remove leading "b"
        StringTrimLeft, index, index, 1

        end := subStr(index, 0)

        if (end >= "a" && end <= "z")
        {
            ;convert to lower case
            StringLower, end, end

            ;remove trailing character
            StringTrimRight, index, index, 1

            ;convert to one-based offset ("a" -> 1)
            end := asc(end) - asc("a") + 1
        }
        else
            end := 0

        ;(+8 for the first 8 bytes reserved in each Class for "Class values")
        index := 4 * (index - 1) + end + 8
    }
    else if (start = "a")
    {
        ;index is the pure address offset (no modification)

        ;remove leading "a"
        StringTrimLeft, index, index, 1
    }

    return index
}

Class_getString(ClassObject, index)
{
    return Class_getValue(ClassObject, index, "String")
}

Class_getValue(ClassObject, index, Type = "uint")
{
    ;get user-entered numeric values

    if (!ClassObject)
        return

    index := Class_getOffset(ClassObject, index)

    if (Type = "String")
    {
        return Class_toString(NumGet(ClassObject+index))
    }
    else if (Type = "obj")  ;(does not modify LockCount)
    {
        ThisClassObject := NumGet(ClassObject+index)

        if (ClassName := Class_isWrapper(ThisClassObject))
        {
            ;unwrap value in wrapper
            if (ClassName = "String")
                return Class_toString(NumGet(ThisClassObject+8))
            else if (ClassName = "Int" || ClassName = "UInt"
                || ClassName = "Float" || ClassName = "Double")
            {
                return NumGet(ThisClassObject+8, 0, ClassName)
            }
            else
                return NumGet(ThisClassObject+4, 0, ClassName)
        }

        return ThisClassObject
    }

    ;Extract data
    return NumGet(ClassObject+index, 0, Type)
}

Class_setString(ClassObject, index, data)
{
    Class_setValue(ClassObject, index, data, "String")
}

Class_setValue(ClassObject, index, data, Type = "uint")
{
    ;set user-entered numeric values

    if (!ClassObject)
        return

    index := Class_getOffset(ClassObject, index)

    if (Type = "String")
    {
        ;Free previous data.
        if (addr := NumGet(ClassObject+index))
        {
            old_value := Class_toString(addr)
            Class_free(addr)

            ;Store NULL pointer to represent empty string when data = "",
            ;or in case error-handling is added and the function returns early.
            NumPut(0, ClassObject+index)
        }

        if (data = "")
            return old_value

        ;Allocate buffer for string.
        ClassObject_data := Class_Alloc("a" . (StrLen(data)+1))

        ;Copy string into buffer.
        Class_CopyString(ClassObject_data, data)

        ;Store pointer to string.
        NumPut(ClassObject_data, ClassObject+index)

        return old_value
    }
    else if (Type = "obj")  ;must be used to keep lock count valid
    {
        Type := "uint"

        if (data = old_data := NumGet(ClassObject+index))
            return false

        if (old_data)
            Class_destroyThis(old_data)

        ;old_data is invalid, function returns true to signify success
        old_data := true
        
        if (data)
            Class_increaseLockCount(data)
    }
    else if (Type = "robj")
    {
        Type := "uint"

        if (data = old_data := NumGet(ClassObject+index))
            return false

        if (old_data)
            Class_decreaseLockCount(old_data)

        if (data)
            Class_increaseLockCount(data)
    }
    else
    {
        ;basic type
        old_data := NumGet(ClassObject+index, 0, Type)
    }

    ;Store data
    NumPut(data, ClassObject+index, 0, Type)
    
    return old_data
}