CompressFileName(p_FileFullPath,p_Max=40)
    {
    ;-- Assign, trim, convert, etc.
    l_FileFullPath=%p_FileFullPath%  ;-- AutoTrim
    StringReplace l_FileFullPath,l_FileFullPath,/,\,All

    ;-- Length of full path <= p_Max?
    if StrLen(l_FileFullPath)<=p_Max
        Return l_FileFullPath

    ;-- Extract directory and drive
    SplitPath l_FileFullPath,l_FileName,l_Dir,,,l_Drive

    ;-- If it exists, remove drive from l_Dir
    if l_Drive is not Space
        StringReplace l_Dir,l_Dir,%l_Drive%

    ;-- Add "\" to the beginning and end of l_Dir
    l_Dir:="\" . l_Dir . "\"

    ;-- Reduce l_Dir until short enough or until all folders have been converted
    Loop
        {
        ;-- Are we done yet?
        if StrLen(l_FileFullPath)<=p_Max
            Break

        l_Continue:=False
        Loop Parse,l_Dir,\
            {
            if A_LoopField is Space
                Continue
            
            if (A_LoopField="...")
                Continue

            ;-- Convert folder name to ellipsis
            StringReplace l_Dir,l_Dir,\%A_LoopField%\,\...\

            ;-- Convert double ellipsis to single
            StringReplace l_Dir,l_Dir,\...\...\,\...\

            ;-- Reassemble l_FileFullPath
            l_FileFullPath:=l_Drive . SubStr(l_Dir,2,-1) . "\" . l_FileName
            l_Continue:=True
            Break
            }
    
        if not l_Continue
            Break
        }

    ;-- Still too long?
    if StrLen(l_FileFullPath)>p_Max
        l_FileFullPath:=SubStr(l_FileFullPath,1,p_Max-3) . "..."

    ;-- Return compressed file name
    Return l_FileFullPath
    }
