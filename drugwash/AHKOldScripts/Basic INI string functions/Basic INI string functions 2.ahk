/*
(C) Copyright 2007, 2008, 2009 Tuncay Devecioglu
   
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
; ATTENTION! THIS COMMENT BLOCK IS IN INI FORMAT AND COULD BE USED AS INI FILE.
[META]
Source =
Language =              en
Name =                  ini
Description =           Basic ini string functions - operate on strings formatted like an ini file.
Revision =              0.2
Status =                Beta
Date =                  2009-07-11 16:49
Author =                Tuncay Devecioglu <tuncay dot d at gmx dot de>
License =               GNU GPL, Version 3 <http://www.gnu.org/licenses/gpl-3.0.txt>
Category =              String Manipulation
Type =                  Library
AhkVersion =            1.0.48
Platform =              2000/XP
Standalone =            Yes
StdLibConform =         Yes
*/

/*
Functions
---------
Parameter 'Content' is the content of an ini file (also this can be one section only).
Parameter 'Section' is the unique name of the section.
Parameter 'Key' is the name of the variable from the section.
Parameter 'Replacement' is the new content to use.
Parameter 'PreserveSpace' should be set to 1 if spaces around the value of a key should be saved, otherwise they are lost.

The 'get' functions returns the desired contents without touching the variable.
The 'replace' functions changes the desired content directly and returns 1 for success and 0 otherwise.

    o   ini_getValue( Content, Section, Key, PreserveSpace )                            Read and return a value from a key.

    o   ini_getKey( Content, Section, Key, PreserveSpace )                              Read and return a complete key with key name and content.

    o   ini_getSection( Content, Section )                                              Read and return a complete section with section name.

    o   ini_replaceValue( Content, Section, Key, Replacement, PreserveSpace )           Changes a keys value.
                                                                                        Returns 1 if key is updated, and 0 otherwise.   

    o   ini_replaceKey( Content, Section, Key, Replacement, PreserveSpace )             Changes complete key with name and content.
                                                                                        Returns 1 if key is replace, and 0 otherwise. 

    o   ini_replaceSection( Content, Section, Replacement )                             Changes a complete section with section name.
                                                                                        Returns 1 if key is updated, and 0 otherwise.   
*/

ini_getValue(ByRef _Content, _Section, _Key, _PreserveSpace = False)
{
    RegEx = isU)^.*\[\s*\Q%_Section%\E\s*].*\R\s*\Q%_Key%\E\s*=(.*)\R.*$
    RegExMatch(_Content, RegEx, Value)
    If Not _PreserveSpace
        Value1 = %Value1% ; Trim spaces.
    Return Value1
}

ini_getKey(ByRef _Content, _Section, _Key, _PreserveSpace = False)
{
    If Not _PreserveSpace
    {
        RegEx = isU)^.*\[\s*\Q%_Section%\E\s*].*\R\s*(\Q%_Key%\E\s*)=\s*(.*)\s*\R.*$
        RegExMatch(_Content, RegEx, Value)
        If Value
            Value1 = %Value1%=%Value2%
    }
    Else
    {
        RegEx = isU)^.*\[\s*\Q%_Section%\E\s*].*\R\s*(\Q%_Key%\E\s*=.*)\R.*$
        RegExMatch(_Content, RegEx, Value)
    }
    Return Value1
}

ini_getSection(ByRef _Content, _Section)
{
    RegEx = isU)^.*(\[\s*\Q%_Section%\E\s*].*)(\R\[.*)*$
    RegExMatch(_Content, RegEx, Value)
    Return Value1
}
 
ini_replaceValue(ByRef _Content, _Section, _Key, _Replacement = "", _PreserveSpace = False)
{
    If Not _PreserveSpace
        _Replacement = %_Replacement% ; Trim spaces.
    RegEx = isU)^.*(\[\s*\Q%_Section%\E\s*].*\R\s*\Q%_Key%\E\s*=).*(\R).*$
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    Return isReplaced
}

ini_replaceKey(ByRef _Content, _Section, _Key, _Replacement = "", _PreserveSpace = False)
{
    If Not _PreserveSpace
        RegEx = isU)^.*(\[\s*\Q%_Section%\E\s*].*\R\s*)\Q%_Key%\E\s*=.*(\R).*$
    Else
        RegEx = isU)^.*(\[\s*\Q%_Section%\E\s*].*\R\s*)\Q%_Key%\E\s*=\s*(.*)\s*(\R).*$
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    Return isReplaced
}

ini_replaceSection(ByRef _Content, _Section, _Replacement = "")
{
    RegEx = isU)^.*(.*)\[\s*\Q%_Section%\E\s*].*(\R\[.*)*$
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    Return isReplaced
}
