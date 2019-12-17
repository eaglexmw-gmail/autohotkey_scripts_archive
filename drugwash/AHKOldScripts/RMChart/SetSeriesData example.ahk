
;first initialize your chart as the other examples demonstrate

NUMPOINTS := 60 ;replace 60 with the number of points you want
numBits := NUMPOINTS * 8
varSetCapacity(valArr, numBits, 0) ;valArr is an array that will store your series
   
GuiControlGet, expression,, expression ;this line doesn't really apply to
                                         ;anyone else. It just initializes "expression"

i = 0
loop, %NUMPOINTS% {
   input := 127 / (NUMPOINTS - 1) * i ;replace these two lines with a
   val := map(expression, input)   ;function that sets val to your ith point.
   NumPut(val, valArr, i * 8, "double") ;inserts val into the ith element of valArr
   i++
}

result := DLLCall("rmchart.dll\RMC_SETSERIESDATA"
                , "UInt", 1001
                , "UInt", 1
                , "UInt", 1
                , "UInt" , &valArr
                , "UInt", NUMPOINTS
                , "UInt", 0     )
   
DLLCall("rmchart.dll\RMC_DRAW"
                , "UInt", 1001     )
