
#include TTS.ahk

TTS("You can read simple text o")

xmltext=
(
<xml version="1.0">
    <SAPI>
        If the first character of the text is a less then character and th dwFlags param is 0 the text will be parsed as xml.
        With the use of xml markup
        <VOICE REQUIRED="NAME=Microsoft Sam">you can</VOICE>
        <VOICE REQUIRED="NAME=Microsoft mike">choose</VOICE>
        <VOICE REQUIRED="NAME=Microsoft Mary">which voice</VOICE>
        <VOICE REQUIRED="NAME=Microsoft Sam">you wish to hear. And much more.</VOICE>
    </SAPI>
</xml>
)
TTS(xmltext)


FileAppend ,
(
You can also specify a fully qualified path to a file and set the dwFlags param to 4. This way the files text will be read.
), tmpspeech.txt
TTS(A_ScriptDir "\tmpspeech.txt", 0 | 4)
FileDelete, tmpspeech.txt


TTS("There are even more features. For details read the speech API documentation.")


