;Google Language API by friese - 2009
; http://www.autohotkey.com/forum/viewtopic.php?t=42945
;credits to olfen for urldownloadtofile function

;Example: get clipboard, check what langugae the content of it is and translate it to english, when Insert is pressed:
Ins::
oldclip := clipboard
2charlang := getlang(clipboard)
lang := getcode(2charlang)
result := translate(clipboard, 2charlang, "en")
msgbox Clipboard contained %oldclip%`nThat is %lang% and means`n%result%
return


translate(search, from, to) ;Translation, from and to are googles language-codes got by getlang
{
per := "%"
url = http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=%search%&langpair=%from%%per%7C%to%
temp := urldownloadtovar(url)
StringReplace, temp, temp, {"responseData": {"translatedText":"
tmp = "}, "responseDetails": null, "responseStatus": 20
StringReplace, temp, temp, %tmp%
return temp
}

getlang(input) ;Returns Googles 2-character language-code, Input is text the language from should be outputted
{
url = http://ajax.googleapis.com/ajax/services/language/detect?v=1.0&q=%input%
temp := urldownloadtovar(url)
StringReplace, temp, temp, {"responseData": {"language":"
stringleft, temp, temp, 2
return temp
}

getcode(code) ;Input either 2-char code or Long name, Output is the opposite
{
list =
(
af|Afrikaans
sq|Albanian
am|Amharic
ar|Arabic
hy|Armenian
az|Azerbaijani
eu|Basque
be|Belarusian
bn|Bengali
bh|Bihari
xx-bork|Bork,bork,bork!
bs|Bosnian
br|Breton
bg|Bulgarian
km|Cambodian
ca|Catalan
zh-CN|Chinese(Simplified)
zh-TW|Chinese(Traditional)
co|Corsican
hr|Croatian
cs|Czech
da|Danish
nl|Dutch
xx-elmer|ElmerFudd
en|English
eo|Esperanto
et|Estonian
fo|Faroese
tl|Filipino
fi|Finnish
fr|French
fy|Frisian
gl|Galician
ka|Georgian
de|German
el|Greek
gn|Guarani
gu|Gujarati
xx-hacker|Hacker
iw|Hebrew
hi|Hindi
hu|Hungarian
is|Icelandic
id|Indonesian
ia|Interlingua
ga|Irish
it|Italian
ja|Japanese
jw|Javanese
kn|Kannada
kk|Kazakh
xx-klingon|Klingon
ko|Korean
ku|Kurdish
ky|Kyrgyz
lo|Laothian
la|Latin
lv|Latvian
ln|Lingala
lt|Lithuanian
mk|Macedonian
ms|Malay
ml|Malayalam
mt|Maltese
mr|Marathi
mo|Moldavian
mn|Mongolian
ne|Nepali
no|Norwegian
nn|Norwegian(Nynorsk)
oc|Occitan
or|Oriya
ps|Pashto
fa|Persian
xx-piglatin|PigLatin
xx-pirate|Pirate
pl|Polish
pt-BR|Portuguese(Brazil)
pt-PT|Portuguese(Portugal)
pa|Punjabi
qu|Quechua
ro|Romanian
rm|Romansh
ru|Russian
gd|ScotsGaelic
sr|Serbian
sh|Serbo-Croatian
st|Sesotho
sn|Shona
sd|Sindhi
si|Sinhalese
sk|Slovak
sl|Slovenian
so|Somali
es|Spanish
su|Sundanese
sw|Swahili
sv|Swedish
tg|Tajik
ta|Tamil
tt|Tatar
te|Telugu
th|Thai
ti|Tigrinya
to|Tonga
tr|Turkish
tk|Turkmen
tw|Twi
ug|Uighur
uk|Ukrainian
ur|Urdu
uz|Uzbek
vi|Vietnamese
cy|Welsh
xh|Xhosa
yi|Yiddish
yo|Yoruba
zu|Zulu
)
loop, parse, list, `n
{
ifinstring, A_LoopField, %code%
{
stringsplit, temp, A_LoopField,|
if temp1 = %code%
 result = %temp2%
if temp2 = %code%
 result = %temp1%
}
}
return result
}



;from olfen, needed for g-api
UrlDownloadToVar(URL, Proxy="", ProxyBypass="") {
AutoTrim, Off
hModule := DllCall("LoadLibrary", "str", "wininet.dll")

If (Proxy != "")
AccessType=3
Else
AccessType=1
;INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
;INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
;INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
;INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS

io_hInternet := DllCall("wininet\InternetOpenA"
, "str", "" ;lpszAgent
, "uint", AccessType
, "str", Proxy
, "str", ProxyBypass
, "uint", 0) ;dwFlags

iou := DllCall("wininet\InternetOpenUrlA"
, "uint", io_hInternet
, "str", url
, "str", "" ;lpszHeaders
, "uint", 0 ;dwHeadersLength
, "uint", 0x80000000 ;dwFlags: INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item
, "uint", 0) ;dwContext

If (ErrorLevel != 0 or iou = 0) {
DllCall("FreeLibrary", "uint", hModule)
return 0
}

VarSetCapacity(buffer, 512, 0)
VarSetCapacity(NumberOfBytesRead, 4, 0)
Loop
{
  irf := DllCall("wininet\InternetReadFile", "uint", iou, "uint", &buffer, "uint", 512, "uint", &NumberOfBytesRead)
  NOBR = 0
  Loop 4  ; Build the integer by adding up its bytes. - ExtractInteger
    NOBR += *(&NumberOfBytesRead + A_Index-1) << 8*(A_Index-1)
  IfEqual, NOBR, 0, break
  ;BytesReadTotal += NOBR
  DllCall("lstrcpy", "str", buffer, "uint", &buffer)
  res = %res%%buffer%
}
StringTrimRight, res, res, 2

DllCall("wininet\InternetCloseHandle",  "uint", iou)
DllCall("wininet\InternetCloseHandle",  "uint", io_hInternet)
DllCall("FreeLibrary", "uint", hModule)
AutoTrim, on
return, res
}
