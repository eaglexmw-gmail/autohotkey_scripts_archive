;********************
;*                  *
;*    MRUManager    *
;*                  *
;********************
;
;   Description
;   ===========
;   This function manages a most recently used (MRU) list.  It is similar to
;   many stack functions except:
;
;       1)  Duplicate and empty (null) items are removed by default.
;
;       2)  The MRU list can be limited to a maximum number of items.
;
;       3)  The item delimiter (default "|") can be determined by the developer.
;
;   See the "Usage Notes" section for more information.
;
;
;   Parameters
;   ==========
;
;       Name            Description
;       ----            -----------
;       r_MRU           MRU list variable.  This parameter must contain a
;                       variable name.
;
;       p_Command       Valid commands include (in alphabetical order):
;
;                         Command   Description
;                         -------   -----------
;                         Clear     Remove all items from the MRU list.
;
;                         Contains  Determine if a particular item is in MRU
;                                   list.  Similar to the "Search" command.
;
;                         Count     Determine the number of items in the MRU
;                                   list.
;
;                         Empty     Determine if the MRU list is empty. The
;                                   synonym "IsEmpty" is also accepted.
;
;                         Peek      Return a copy of the top item in the MRU
;                                   list.
;
;                         Pop       Remove and return the top item from the
;                                   MRU list.
;
;                         Push      Add the value of p_Item to the top of the
;                                   MRU list.
;
;                         Search    Search for the value of p_Item.
;
;       p_Item          Value to search for or to push. [Optional].  Used by
;                       the "Contains", "Push", and "Search" commands.
;
;       p_Delimiter     The character that delimits each list item. [Optional]
;                       The default is "|".  Important: If defined, this
;                       parameter must only contain one character.
;
;       p_MaxItems      Maximum number of items. [Optional] The default is 0
;                       (no limit).  This parameter is only used by the "Push"
;                       command.
;
;
;   Usage Notes
;   ===========
;    *  All "Clean Up" tasks (deleting duplicates and empty (null) items and
;       enforcing the p_MaxItems parameter) are only performed when the"Push"
;       command is used.  This is to insure that the function:
;
;        1) Operates as quickly as possible.
;
;        2) Does not return a pointer to a item that no longer exists because
;           the list has been truncated.
;
;    *  The "Contains" and "Search" tests are not case sensitive.
;
;    *  No special characters/attributes are added to the MRU variable by this
;       function.  If needed, the MRU variable can be used to populate GUI
;       controls (DDL, ComboBox, ListBox, etc.) without modification.  A
;       standard "Loop,Parse" command can be used to get item values from list
;       without removing ("Pop"ing) the item from the list.
;
;
;   Return
;   ======
;   The value returned is determined by the p_Command parameter.
;
;     Command     Returns
;     -------     -------
;     Clear       (None)
;
;     Contains    TRUE if the value of p_Item is found in the MRU list,
;                 otherwise FALSE.
;
;     Count       The number if items in the MRU list.
;
;     Peek        The value of the top item in the MRU list.
;
;     Pop         The value of the top item in the MRU list.
;
;     Push        (None)
;
;     Search      If found, the 1-based position in the MRU list where the value
;                 of p_Item is located, otherwise 0.
;
;-------------------------------------------------------------------------------
MRUManager(ByRef r_MRU,p_Command,p_Item="",p_Delimiter="",p_MaxItems=0)
    {
    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    p_Command=%p_Command%      ;-- AutoTrim
    if StrLen(p_Delimiter)=0
        p_Delimiter:="|"

    ;[=========]
    ;[  Clear  ]
    ;[=========]
    if p_Command=Clear
        {
        r_MRU:=""
        Return
        }

    ;[============]
    ;[  Contains  ]
    ;[============]
    if p_Command=Contains
        Return InStr(p_Delimiter . r_MRU . p_Delimiter,p_Delimiter . p_Item . p_Delimiter) ? True:False

    ;[=========]
    ;[  Count  ]
    ;[=========]
    if p_Command=Count
        {
        l_Count:=0
        loop parse,r_MRU,%p_Delimiter%
            l_Count++

        Return l_Count
        }

    ;[=========]
    ;[  Empty  ]
    ;[=========]
    if p_Command in Empty,IsEmpty
        Return StrLen(r_MRU)=0 ? True:False

    ;[=============]
    ;[  Peek, Pop  ]
    ;[=============]
    if p_Command in Peek,Pop
        {
        ;-- Find first delimiter position
        l_DelimiterPos:=InStr(r_MRU,p_Delimiter)

        ;-- 0 or 1 item in the list?
        if l_DelimiterPos=0
            {
            l_Item:=r_MRU
            if p_Command=Pop
                r_MRU:=""
            }
         else
            {
            ;-- Get the first item
            l_Item:=SubStr(r_MRU,1,l_DelimiterPos-1)
            if p_Command=Pop
                StringTrimLeft r_MRU,r_MRU,l_DelimiterPos
            }

        return l_Item
        }

    ;[==========]
    ;[  Search  ]
    ;[==========]
    if p_Command=Search
        {
        l_Pos:=0
        loop parse,r_MRU,%p_Delimiter%
            if (p_Item=A_LoopField)
                {
                l_Pos:=A_Index
                break
                }

        Return l_Pos
        }

    ;[========]
    ;[  Push  ]
    ;[========]
    ;-- Remove duplicates (if any)
    if StrLen(p_Item)
        {
        ;-- Add temporary delimiter borders
        r_MRU:=p_Delimiter . r_MRU . p_Delimiter

        ;-- Remove all occurrences of p_Item, if any
        StringReplace
            ,r_MRU
            ,r_MRU
            ,% p_Delimiter . p_Item . p_Delimiter
            ,% p_Delimiter
            ,All

        ;-- Remove temporary borders
        r_MRU:=SubStr(r_MRU,2,-1)
        }

    ;-- Remove null items (if needed)
    loop
        {
        StringReplace
            ,r_MRU
            ,r_MRU
            ,% p_Delimiter . p_Delimiter
            ,% p_Delimiter
            ,UseErrorLevel

        if ErrorLevel=0
            break
        }

    ;-- Remove leading/trailing delimiters if they exist
    if SubStr(r_MRU,1,1)=p_Delimiter
        StringTrimLeft r_MRU,r_MRU,1

    if SubStr(r_MRU,0)=p_Delimiter
        StringTrimRight r_MRU,r_MRU,1

    ;-- Push (add to top of the list)
    if StrLen(r_MRU)=0
        r_MRU:=p_Item
     else
        r_MRU:=p_Item . p_Delimiter . r_MRU 

    ;-- Truncate list (if needed)
    if p_MaxItems
        {
        l_DelimiterPos:=0
        loop parse,r_MRU,%p_Delimiter%
            {
            l_DelimiterPos += StrLen(A_LoopField)+1
            if (A_Index+1>p_MaxItems)
                {
                r_MRU:=SubStr(r_MRU,1,l_DelimiterPos-1)
                break
                }
            }
        }

    return
    }
