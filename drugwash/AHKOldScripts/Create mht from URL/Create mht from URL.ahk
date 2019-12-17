; http://www.autohotkey.com/community/./viewtopic.php?f=2&t=82247
/*
--------------------------------------------------------------------------------------------------------------------------------
FUNCTION: Url2Mhtml
--------------------------------------------------------------------------------------------------------------------------------
Creates a MHTML file from the given URL.
Requires Sean's COM Standard Library:  http://www.autohotkey.com/forum/viewtopic.php?t=22923

PARAMETERS:
~~~~~~~~~~~
URL         - Working URL.
destPath    - Destination file path (eg. C:\Users\XYZ\Desktop\file.mht)
flags       - MHTML flags, it can be the OR of the followings (leave it empty to suppress nothing):
              CdoSuppressImages         := 1
              CdoSuppressBGSounds       := 2
              CdoSuppressFrames         := 4
              CdoSuppressObjects        := 8
              CdoSuppressStyleSheets    := 16
              CdoSuppressAll            := 31
--------------------------------------------------------------------------------------------------------------------------------
COM INFO:
--------------------------------------------------------------------------------------------------------------------------------
IMessage Interface                                              - http://msdn.microsoft.com/en-us/library/ms526453(v=vs.85).aspx
CreateMHTMLBody Method                                          - http://msdn.microsoft.com/en-us/library/ms527024(v=vs.85).aspx
CdoMHTMLFlags Enum                                              - http://msdn.microsoft.com/en-us/library/ms526977(v=vs.85).aspx
GetStream Method                                                - http://msdn.microsoft.com/en-us/library/ms527348(v=vs.85).aspx
SaveToFile Method                                               - http://msdn.microsoft.com/en-us/library/ms676152(v=vs.85).aspx
SaveOptionsEnum                                                 - http://msdn.microsoft.com/en-us/library/ms676152(v=vs.85).aspx
--------------------------------------------------------------------------------------------------------------------------------
*/
Url2Mhtml(URL, destPath=0, flags=0) {
    ; Initializes COM and creates the CDO.IMessage object
    COM_Init()
    comObj := COM_CreateObject("{CD000001-8B95-11D1-82DB-00C04FB1625D}") ; IMessage Interface

    ; Parses the URL and creates the MHTML
    COM_Invoke( comObj
                , "CreateMHTMLBody"
                , URL
                , flags )
               
    ;, Obtains the ADODB.Stream object
    stream := COM_Invoke( comObj, "GetStream" )
   
    ; Saves the stream creating the .mht file
    COM_Invoke( stream
                , "SaveToFile"
                , (destPath) ? destPath : A_WorkingDir . "\url.mht"
                , adSaveCreateOverWrite:=2 )

    ; Releases the object and terminates COM
    COM_Release(comObj)
    COM_Term()
}
