MsgBox % GetIfTable()


GetIfTable(bOrder = True)
{
   DllCall("iphlpapi\GetNumberOfInterfaces", "UintP", nIf)
   nSize := 4 + 860 * nIf + 8
   VarSetCapacity(tbl, nSize)
   DllCall("iphlpapi\GetIfTable", "Uint", &tbl, "UintP", nSize, "int", bOrder)

   Loop, %nIf%
         Interfaces .= DecodeInteger(&tbl + 4 + 512 + 860 * (A_Index - 1)) . " : " . DecodeInteger(&tbl + 4 + 516 + 860 * (A_Index - 1)) . " : " . DecodeInteger(&tbl + 4 + 544 + 860 * (A_Index - 1)) . "`n"

   Return Interfaces
}

DecodeInteger(ptr)
{
   Return *ptr | *++ptr << 8 | *++ptr << 16 | *++ptr << 24
}
