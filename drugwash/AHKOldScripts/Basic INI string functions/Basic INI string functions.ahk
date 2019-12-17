; http://www.autohotkey.com/forum/viewtopic.php?t=46226
; Basic ini string functions - operate on strings formatted like an ini file.
;fileread, f, path
f =
(
[Home]
Path=C:\
UserInfo=John Doe
[Settings]
AutoStart=1
)
msgbox % ini_getSection(f, "Settings")
ini_updateSection(f, "Settings", "[Section]`nKey=Value")
s := ini_getSection(f, "Home")
ini_updateValue(s, "Home", "Path", "test")
msgbox % ini_getValue(s, "Home", "Path")

; Read and return a value from a key.
ini_getValue(ByRef _content, _section, _key)
{
    regex = iU)[\s\Q%_section%\E\s].*\R\s*\Q%_key%\E\s*=(.*)\R
    RegExMatch(_content, regex, value)
    Return value1
}

; Read and return a complete section with section name.
; For further use with ini_getValue().
ini_getSection(ByRef _content, _section)
{
    regex = is)(\[\s?\Q%_section%\E\s?].+?)\[
    RegExMatch(_content . "[", regex, value)
    Return value1
}

; Changes a keys value.
; Returns 1 if key is updated, and 0 otherwise.
ini_updateValue(ByRef _content, _section, _key, _replacement = "")
{
    regex = iU)([\s\Q%_section%\E\s].*\R\s*\Q%_key%\E\s*=).*(\R)
    _content := RegExReplace(_content, regex, "$1" . _replacement . "$2", found, 1)
    Return found
}

; Changes a complete section with section name.
; Returns 1 if key is updated, and 0 otherwise.
ini_updateSection(ByRef _content, _section, _replacement = "")
{
    regex = is)(.*)\[\s?\Q%_section%\E\s?].+?\[(.*)
    _content := RegExReplace(_content . "[", regex, "$1" . _replacement . "$2", found, 1)
    Return found
}
