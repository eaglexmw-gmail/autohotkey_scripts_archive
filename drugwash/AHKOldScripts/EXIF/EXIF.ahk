/*     ______      _  __   _____                           _______    _     _
      |  ____|    (_)/ _| |  __ \                         |__   __|  | |   | | v2.11
      | |__  __  ___| |_  | |  | |_   _ _ __ ___  _ __ ______| | __ _| |__ | | ___
      |  __| \ \/ / |  _| | |  | | | | | '_ ` _ \| '_ \______| |/ _` | '_ \| |/ _ \
      | |____ >  <| | |   | |__| | |_| | | | | | | |_) |     | | (_| | |_) | |  __/
      |______/_/\_\_|_|   |_____/ \__,_|_| |_| |_| .__/      |_|\__,_|_.__/|_|\___|
                                                 | |      _   _     _   _   _   _
      SKAN ( Suresh Kumar A N )                  |_|     / \ / \   / \ / \ / \ / \
      arian.suresh@gmail.com                            ( b | y ) ( S | K | A | N )
      CD: 07-Apr-2008 / LM: 15-Jan-2010                  \_/ \_/   \_/ \_/ \_/ \_/

      AutoHotkey Forum Topic :      www.autohotkey.com/forum/viewtopic.php?t=58342

      Usage Example :

          ExifTable := Exif( "somefile.jpg" )
          ExifTable := Exif( "somefile.jpg", ThumbNail := True )

      Credit :

          Laszlo Hars ( Laszlo ) for BSwap16() / BSwap32() machine code
          www.autohotkey.com/forum/viewtopic.php?p=135302#135302
         
          Yuri Popov ( YMP ) for Return() machine code
          www.autohotkey.com/forum/viewtopic.php?p=359046#359046

 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  - - - - - - - - - - - - - - - Exif Dump-Table Ver 2.11 - - - - - - - - - - - - - - - -
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 EXIF() is a 'Stand-alone' function that will parse a DSC Jpeg file and shall return the
 EXIF table in a human-readable 'text-table' format.
 
 Optionally, EXIF() can copy 'Internal Thumbnail' into a variable when 'Variable := True'
 is passed as parameter 2

 The structure for the 'returned' Exif-table is as follows:
 
  [*] Each row of data is fixed at 95 characters length and delimited with linefeed
  [*] Each row is made up of 7 fixed-length fields and delimited with
      Chr(160) ( a.k.a non-breaking space )

   structure for one row of data:
   +---+--------------------------------------------------+----------+
   | F#| description                                      | substr() |
   +---+--------------------------------------------------+----------+
   | 0 | hTag    : hex tag                                | 01,04    |
   | 1 | Tagname : tag name                               | 06,28    |
   | 2 | FrameO  : absolute frame offset ( in file ) ***  | 35,07    |
   | 3 | DataO   : absolute data offset ( in file )  ***  | 43,07    |
   | 4 | Bytes   : length of data                         | 51,06    |
   | 5 | Type    : type of data ( see note-1 )            | 58,05    |
   | 6 | Value   : partial data ( see note-2 )            | 64,32    |
   +---+--------------------------------------------------+----------+

  *** With absolute offsets ( fields 2 & 3 ), one can post-process a 'Frame' or 'Data'
  with FileReadEx()/FileWriteEx() : www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk

  note-1 : The data-type can be 'one' of the following:

          1) unsigned byte
          2) ascii string
          3) unsigned short
          4) unsigned long
          5) unsigned rational
          6) signed byte
          7) undefined
          8) signed short
          9) signed long
         10) signed rational
         11) single float
         12) double float
         
         EXIF() will ignore data-types 11 & 12
         
  note-2 : 'Value' field will contain 'actual raw value' for 90% of tags upto 32 chars.
           In case the 'Bytes' fields is indicating a size > 32 or the 'Type' field
           is indicating 7 ( undefined ) and value field is empty, then you have to use
           FileReadEx() to process that particular tag.

           Data-types 5 and 10 are made of two integers ( numerator/denominator ) and so,
           each share 16 characters of 'Value field'.

           Ver 2.10: When Data contains series of numerator/denominator, the values are
                     derived and expressed as comma seperated values.
           
           On some instances ( like InteropOffset / ThumbnailOffset ) the 'Value' would be
           relative offset to tiff header. You may workout the absolute offset as follows:
           
           AbsoluteOffset := SubStr( ExifTable, 92,4 ) + RelativeOffset

  About Thumnail :

           Once the Image data is loaded into a variable, you may display it in a GUI
           using GDI+ as demonstrated here:

           How to convert Image data (JPEG/PNG/GIF) to hBITMAP ?
           www.autohotkey.com/forum/viewtopic.php?p=147052#147052
           
           Or if you want to write the buffer into disk, you may use FileWriteEx() like in
           following example:
           
           ExifTable := Exif( "somefile.jpg", ThumbVar := True )
           FileWriteEx( "thm_somefile.jpg", ThumbVar, VarSetCapacity( ThumbVar ) )
           

  About EXIF_Get() :  You may use EXIF_Get() to search for 'htag' and retrieve, either an
                      entire 'Row' or just a 'Field' from ExifTable
  
          Example :
          
          ExifTable := EXIF( "somefile.jpg" )
          DateTimeRow := Exif_Get( ExifTable, 0132, -1 ) ; Extract the DateTime Row
          DataTimeVal := Exif_Get( ExifTable, 0132, 6  ) ; Extract Value ( Field# 6 )
*/

EXIF( file="", byref thm=0 ) { ; Version 2.00
 static init,tem,de,data,htag,var,s32, bc1,bc2,bc3,bc4,bc5,bc6,bc7,bc8,bc9,bc10,bc11,bc12
 static bswap, noswp, bswp16, bswp32, tags,
 critical
; local exif,tiff,ben,ifd1p,ifd0,ifd0p,ifd0c,gpstag,tag,typ,cnt,off,val,dsz,outp
; local t513,t514,t259,t34665,t34853
 
 if ! (init) {
 init:=true, tem:="++", de:=chr(160), varsetcapacity(data,64,1)
 varsetcapacity( htag,5,1 ), varsetcapacity(var,4096,1), varsetcapacity( s32,32,32 )
 bc1:=1,bc2:=1,bc3:=2,bc4:=4,bc5:=8,bc6:=1,bc7:=1,bc8:=2,bc9:=4,   bc10:=8,bc11:=4,bc12:=8
 varsetcapacity( bswap,16,0 ),  numput( 0x00C3C80F, numput( 0xC18BC3C5, numput( 0x8AE18AC3
 ,numput( 0x0424448B, bswap )))), noswp := &bswap, bswp16 := &bswap+5, bswp32 := &bswap+10
  tags=
 ( ltrim join ;                                             source www.exiv2.org/tags.html
  |0001-InteropIndex|0002-InteropVersion|000B-ProcessingSoftware|00FE-SubfileType|00FF-Old
  SubfileType|0100-ImageWidth|0101-ImageHeight|0102-BitsPerSample|0103-Compression|0106-Ph
  otometricInterpretation|0107-Thresholding|0108-CellWidth|0109-CellLength|010A-FillOrder|
  010D-DocumentName|010E-ImageDescription|010F-Make|0110-Model|0111-PreviewImageStart|0112
  -Orientation|0115-SamplesPerPixel|0116-RowsPerStrip|0117-PreviewImageLength|0118-MinSamp
  leValue|0119-MaxSampleValue|011A-XResolution|011B-YResolution|011C-PlanarConfiguration|0
  11D-PageName|011E-XPosition|011F-YPosition|0120-FreeOffsets|0121-FreeByteCounts|0122-Gra
  yResponseUnit|0123-GrayResponseCurve|0124-T4Options|0125-T6Options|0128-ResolutionUnit|0
  129-PageNumber|012C-ColorResponseUnit|012D-TransferFunction|0131-Software|0132-DateTime|
  013B-Artist|013C-HostComputer|013D-Predictor|013E-WhitePoint|013F-PrimaryChromaticities|
  0140-ColorMap|0141-HalftoneHints|0142-TileWidth|0143-TileLength|0144-TileOffsets|0145-Ti
  leByteCounts|0146-BadFaxLines|0147-CleanFaxData|0148-ConsecutiveBadFaxLines|014A-SubIFD|
  DataOffset|014C-InkSet|014D-InkNames|014E-NumberofInks|0150-DotRange|0151-TargetPrinter|
  0152-ExtraSamples|0153-SampleFormat|0154-SMinSampleValue|0155-SMaxSampleValue|0156-Trans
  ferRange|0157-ClipPath|0158-XClipPathUnits|0159-YClipPathUnits|015A-Indexed|015B-JPEGTab
  les|015F-OPIProxy|0190-GlobalParametersIFD|0191-ProfileType|0192-FaxProfile|0193-CodingM
  ethods|0194-VersionYear|0195-ModeNumber|01B1-Decode|01B2-DefaultImageColor|0200-JPEGProc
  |0201-ThumbnailImageStart|0201-JpgFromRawStart|0201-JpgFromRawStart|0201-OtherImageStart
  |0202-ThumbnailImageLength|0203-JPEGRestartInterval|0205-JPEGLosslessPredictors|0206-JPE
  GPointTransforms|0207-JPEGQTables|0208-JPEGDCTables|0209-JPEGACTables|0211-YCbCrCoeffici
  ents|0212-YCbCrSubSampling|0213-YCbCrPositioning|0214-ReferenceBlackWhite|022F-StripRowC
  ounts|02BC-ApplicationNotes|1000-RelatedImageFileFormat|1001-RelatedImageWidth|1002-Rela
  tedImageHeight|4746-Rating|4749-RatingPercent|800D-ImageID|80A4-WangAnnotation|80E3-Matt
  eing|80E4-DataType|80E5-ImageDepth|80E6-TileDepth|827D-Model2|828D-CFARepeatPatternDim|8
  28E-CFAPattern2|828F-BatteryLevel|8290-KodakIFD|8298-Copyright|829A-ExposureTime|829D-FN
  umber|82A5-MDFileTag|82A6-MDScalePixel|82A7-MDColorTable|82A8-MDLabName|82A9-MDSampleInf
  o|82AA-MDPrepDate|82AB-MDPrepTime|82AC-MDFileUnits|830E-PixelScale|83BB-IPTC-NAA|847E-In
  tergraphPacketData|847F-IntergraphFlagRegisters|8480-IntergraphMatrix|8482-ModelTiePoint
  |84E0-Site|84E1-ColorSequence|84E2-IT8Header|84E3-RasterPadding|84E4-BitsPerRunLength|84
  E5-BitsPerExtendedRunLength|84E6-ColorTable|84E7-ImageColorIndicator|84E8-BackgroundColo
  rIndicator|84E9-ImageColorValue|84EA-BackgroundColorValue|84EB-PixelIntensityRange|84EC-
  TransparencyIndicator|84ED-ColorCharacterization|84EE-HCUsage|84EF-TrapIndicator|84F0-CM
  YKEquivalent|8546-SEMInfo|8568-AFCP_IPTC|85D8-ModelTransform|8602-WB_GRGBLevels|8606-Lea
  fData|8649-PhotoshopSettings|8769-ExifOffset|8773-ICC_Profile|87AC-ImageLayer|87AF-GeoTi
  ffDirectory|87B0-GeoTiffDoubleParams|87B1-GeoTiffAsciiParams|8822-ExposureProgram|8824-S
  pectralSensitivity|8825-GPSInfo|8827-ISO|8828-Opto-ElectricConvFactor|8829-Interlace|882
  A-TimeZoneOffset|882B-SelfTimerMode|885C-FaxRecvParams|885D-FaxSubAddress|885E-FaxRecvTi
  me|888A-LeafSubIFD|9000-ExifVersion|9003-DateTimeOriginal|9004-CreateDate|9101-Component
  sConfiguration|9102-CompressedBitsPerPixel|9201-ShutterSpeedValue|9202-ApertureValue|920
  3-BrightnessValue|9204-ExposureCompensation|9205-MaxApertureValue|9206-SubjectDistance|9
  207-MeteringMode|9208-LightSource|9209-Flash|920A-FocalLength|920B-FlashEnergy|920C-Spat
  ialFrequencyResponse|920D-Noise|920E-FocalPlaneXResolution|920F-FocalPlaneYResolution|92
  10-FocalPlaneResolutionUnit|9211-ImageNumber|9212-SecurityClassification|9213-ImageHisto
  ry|9214-SubjectLocation|9215-ExposureIndex|9216-TIFF-EPStandardID|9217-SensingMethod|923
  F-StoNits|927C-MakerNote|9286-UserComment|9290-SubSecTime|9291-SubSecTimeOriginal|9292-S
  ubSecTimeDigitized|935C-ImageSourceData|9C9B-XPTitle|9C9C-XPComment|9C9D-XPAuthor|9C9E-X
  PKeywords|9C9F-XPSubject|A000-FlashpixVersion|A001-ColorSpace|A002-ExifImageWidth|A003-E
  xifImageHeight|A004-RelatedSoundFile|A005-InteropOffset|A20B-FlashEnergy|A20C-SpatialFre
  quencyResponse|A20D-Noise|A20E-FocalPlaneXResolution|A20F-FocalPlaneYResolution|A210-Foc
  alPlaneResolutionUnit|A211-ImageNumber|A212-SecurityClassification|A213-ImageHistory|A21
  4-SubjectLocation|A215-ExposureIndex|A216-TIFF-EPStandardID|A217-SensingMethod|A300-File
  Source|A301-SceneType|A302-CFAPattern|A401-CustomRendered|A402-ExposureMode|A403-WhiteBa
  lance|A404-DigitalZoomRatio|A405-FocalLengthIn35mmFormat|A406-SceneCaptureType|A407-Gain
  Control|A408-Contrast|A409-Saturation|A40A-Sharpness|A40B-DeviceSettingDescription|A40C-
  SubjectDistanceRange|A420-ImageUniqueID|A480-GDALMetadata|A481-GDALNoData|A500-Gamma|BC0
  1-PixelFormat|BC02-Transformation|BC03-Uncompressed|BC04-ImageType|BC80-ImageWidth|BC81-
  ImageHeight|BC82-WidthResolution|BC83-HeightResolution|BCC0-ImageOffset|BCC1-ImageByteCo
  unt|BCC2-AlphaOffset|BCC3-AlphaByteCount|BCC4-ImageDataDiscard|BCC5-AlphaDataDiscard|C42
  7-OceScanjobDesc|C428-OceApplicationSelector|C429-OceIDNumber|C42A-OceImageLogic|C44F-An
  notations|C4A5-PrintIM|C612-DNGVersion|C613-DNGBackwardVersion|C614-UniqueCameraModel|C6
  15-LocalizedCameraModel|C616-CFAPlaneColor|C617-CFALayout|C618-LinearizationTable|C619-B
  lackLevelRepeatDim|C61A-BlackLevel|C61B-BlackLevelDeltaH|C61C-BlackLevelDeltaV|C61D-Whit
  eLevel|C61E-DefaultScale|C61F-DefaultCropOrigin|C620-DefaultCropSize|C621-ColorMatrix1|C
  622-ColorMatrix2|C623-CameraCalibration1|C624-CameraCalibration2|C625-ReductionMatrix1|C
  626-ReductionMatrix2|C627-AnalogBalance|C628-AsShotNeutral|C629-AsShotWhiteXY|C62A-Basel
  ineExposure|C62B-BaselineNoise|C62C-BaselineSharpness|C62D-BayerGreenSplit|C62E-LinearRe
  sponseLimit|C62F-CameraSerialNumber|C630-DNGLensInfo|C631-ChromaBlurRadius|C632-AntiAlia
  sStrength|C633-ShadowScale|C634-SR2Private|C635-MakerNoteSafety|C640-RawImageSegmentatio
  n|C65A-CalibrationIlluminant1|C65B-CalibrationIlluminant2|C65C-BestQualityScale|C65D-Raw
  DataUniqueID|C660-AliasLayerMetadata|C68B-OriginalRawFileName|C68C-OriginalRawFileData|C
  68D-ActiveArea|C68E-MaskedAreas|C68F-AsShotICCProfile|C690-AsShotPreProfileMatrix|C691-C
  urrentICCProfile|C692-CurrentPreProfileMatrix|EA1C-Padding|EA1D-OffsetSchema|FDE8-OwnerN
  ame|FDE9-SerialNumber|FDEA-Lens|FE4C-RawFile|FE4D-Converter|FE4E-WhiteBalance|FE51-Expos
  ure|FE52-Shadows|FE53-Brightness|FE54-Contrast|FE55-Saturation|FE56-Sharpness|FE57-Smoot
  hness|FE58-MoireFilter|00-GPSVersionID|01-GPSLatitudeRef|02-GPSLatitude|03-GPSLongitudeR
  ef|04-GPSLongitude|05-GPSAltitudeRef|06-GPSAltitude|07-GPSTimeStamp|08-GPSSatellites|09-
  GPSStatus|0A-GPSMeasureMode|0B-GPSDOP|0C-GPSSpeedRef|0D-GPSSpeed|0E-GPSTrackRef|0F-GPSTr
  ack|10-GPSImgDirectionRef|11-GPSImgDirection|12-GPSMapDatum|13-GPSDestLatitudeRef|14-GPS
  DestLatitude|15-GPSDestLongitudeRef|16-GPSDestLongitude|17-GPSDestBearingRef|18-GPSDestB
  earing|19-GPSDestDistanceRef|1A-GPSDestDistance|1B-GPSProcessingMethod|1C-GPSAreaInforma
  tion|1D-GPSDateStamp|1E-GPSDifferential|GP00-GPSVersionID|GP01-GPSLatitudeRef|GP02-GPSLa
  titude|GP03-GPSLongitudeRef|GP04-GPSLongitude|GP05-GPSAltitudeRef|GP06-GPSAltitude|GP07-
  GPSTimeStamp|GP08-GPSSatellites|GP09-GPSStatus|GP0A-GPSMeasureMode|GP0B-GPSDOP|GP0C-GPSS
  peedRef|GP0D-GPSSpeed|GP0E-GPSTrackRef|GP0F-GPSTrack|GP10-GPSImgDirectionRef|GP11-GPSImg
  Direction|GP12-GPSMapDatum|GP13-GPSDestLatitudeRef|GP14-GPSDestLatitude|GP15-GPSDestLong
  itudeRef|GP16-GPSDestLongitude|GP17-GPSDestBearingRef|GP18-GPSDestBearing|GP19-GPSDestDi
  stanceRef|GP1A-GPSDestDistance|GP1B-GPSProcessingMethod|GP1C-GPSAreaInformation|GP1D-GPS
  DateStamp|GP1E-GPSDifferential
 )
 }

 if ( hfil := dllcall("_lopen", str,file, int,0 ) ) <= 0                      ; open error
    return ( DllCall( "SetLastError", uint,1 )<<64 )

 if ! dllcall( "_lread", uint,hfil, uint,&var, int,4096 )                     ; read error
   return ( dllcall( "_lclose", uint,hfil )<<64)+( dllcall( "SetLastError", uint,2 )<<64 )

 loop 4096 ; search hdr for FFE1 marker to ensure the file has exif metadata
     if ( exif := ( numget( var,a_index-1,"ushort" ) = 0xE1FF ) ? a_index-1 : false )
         break

 if ( !exif or numget( var,exif+4 ) != 0x66697845 )          ; 0x66697845 is string "Exif"
   return ( dllcall( "_lclose", uint,hfil )<<64)+( dllcall( "SetLastError", uint,3 )<<64 )

 /*

 bytes 0-1:
 The byte order used within the file. legal values are: “II” (0x4949) and “MM” (0x4D4D)
 In the “II” format, byte order is always from the least significant byte to the most
 significant byte, for both 16-bit and 32-bit integers.  This is called little-endian byte
 order ( aka "Intel byte align").  In the “MM” format,byte order is always from most
 significant to least significant, for both 16-bit and 32-bit integers. This is called
 big-endian byte order ( aka "Motorola byte align" ).

 AHK's NumGet() presumes the "little-endian byte order". To swap these values to
 "big-endian byte order", this function calls byte swapper machine code provided by Laszlo

 */

 ; ascertain whether byte reversing is required
 ben := ( numget( var, tiff := exif+10, "ushort" ) <> 0x4949 )  ; 'MM' Motorola/Big-Endian
 
 ifd0 := dllcall( ben ? bswp32:noswp, uint,numget( var,tiff+4 ), "cdecl" ) + tiff
 ifd0p := dllcall( "_llseek", uint,hfil, uint,ifd0, int,0 )
 dllcall( "_lread", uint,hfil, uint,&tem, uint,2 )

; retrieve the count of directory entries in IFD0 ( Image File Directory Zero )
 ifd0c := dllcall( ben ? bswp16:noswp, ushort,numget( tem,0,"ushort" ), "cdecl ushort" )
 count := ifd0c, varsetcapacity( outp, 10240,0 )

/*
  we have IFDE ( the count ) and file pointer is located exactly at the IFD data area.
  Each directory entry will be 12 bytes and has to be loop throughed one at a time
  the structure of a 12 byte directory entry is as follows :

  bytes 0-1  :   the tag id ( the marker )
  bytes 2-3  :   the field type ( the format )
  bytes 4-7  :   the number of values ( the format )
  bytes 8-12 :   the file offset to the value 'or' the value itself ( tricky! )
                 file offset would always be an even number and may point anywhere,
                 even after the image data.
                 if the value could be fit in 4 bytes or less then the value will be
                 available directly in this field.
*/

Exif_MultiLoop:
 loop %count% { ; all entries in IFD0

   dllcall( "_lread", uint,hfil, uint,&var, uint,12 )
   cpos := dllcall( "_llseek", uint,hfil, uint,0, uint,1 ), foff := cpos - 16

   tag := dllcall( ben ? bswp16:noswp, ushort,numget( var,0,"ushort" ), "cdecl ushort" )

   typ := dllcall( ben ? bswp16:noswp, ushort,numget( var,2,"ushort" ), "cdecl ushort" )
   cnt := dllcall( ben ? bswp32:noswp, uint,numget( var,4 ), "cdecl" )
   off := dllcall( ben ? bswp32:noswp, uint, val := numget( var,8 ), "cdecl" )

   if ( tag=0x8769 || tag=0x8825 )
     t%tag% := tiff+off

   if ( tag=0x201 || tag=0x202 )
     t%tag% := off
     

   dllcall( "msvcrt.dll\sprintf", str,htag, str, gpstag ? "GP%02X" : "%04X", uint,tag )

   dsz := ( bc%typ% * cnt ), VarSetCapacity( data,0 )
   sz := varsetcapacity( data, dsz>4 ? dsz : 4, 32 )
   
   if ( dsz > 4 )
      dllcall( "_llseek", uint,hfil, uint,tiff+off, uint,0 )
    , dllcall( "_lread", uint,hfil, uint,&data, uint,dsz )
   else
      numput(  val, data ), off := cpos-16

   tagn := substr( tags, sp := ( f := instr( tags, "|" htag "-" ) ) ? f+6 : 0,  sp
         ? instr( tags, "|",0,sp ) - sp : 0 )
   outp .=  "`n" htag de substr( tagn s32,1,28) de substr( s32 foff+4,-6)
        . de substr( s32 (tiff+off),-6) de substr( s32 dsz,-5) de substr( s32 typ,-4) de
   dllcall( "_llseek", uint,hfil, uint,cpos, uint,0 )
   
  ; = = = = = = = = = =    D A T A   F O R M A T   T A B L E   = = = = = = = = = = = = = =
  /*

      1) unsigned byte  = 1        5) unsig.rational = 8         9) signed long     = 4
      2) ascii string   = 1        6) signed byte    = 1        10) signed rational = 8
      3) unsigned short = 2        7) undefined      = 1        11) single float    = 4
      4) unsigned long  = 4        8) signed short   = 2        12) double float    = 8

  */

 if ( typ = 1 or typ = 6 )                                 ; 8 bit unsigned/signed integer
    outp .= substr( S32 numget(data,0,typ=1 ? "uint" : "int" ), -15 ) substr( s32, -15 )

 if ( typ = 2  )                                           ; ascii string
    varsetcapacity( data,-1), outp .= subStr( data s32,1,32 )

 if ( typ = 7  )                                           ; ascii string
    if data is integer
      outp .= subStr( data s32,1,32 )
    else
      if dsz <= 4
      varsetcapacity( hval,17,32 )
      ,  dllcall( "msvcrt.dll\sprintf", str,hval, str,"0x%08X", uint,numget(data) )
      ,  outp .= substr( hval s32,1,32 )
    else outp .= s32

 if ( typ = 3 or typ = 8 )                                ; 16 bit unsigned/signed integer
   outp .= substr( s32 dllcall( ben ? bswp16:noswp, ushort,numget( data,0,typ=3 ? "ushort"
           : "short" ), "cdecl " ( typ=3 ? "ushort" : "short" ) ),-15 ) substr( s32,17 )

 if ( typ = 4 or typ = 9 )                                ; 32 bit unsigned/signed integer
   v := dllcall( ben ? bswp32:noswp, uint,numget( data,0,typ=4 ? "uint" : "int" )
               ,"cdecl " (typ=4 ? "uint" : "int" ) )
   , outp .= substr( s32 v,-15 ) . substr( s32, -15 )

 if ( ( typ = 5 or typ = 10 ) && sz=8 ) {        ; pair of 32 bit unsigned/signed rational
    n := dllcall( ben ? bswp32:noswp, uint,numget( data,0,typ=5 ? "uint" : "int" )
                                              ,"cdecl " ( typ=5 ? "uint" : "int" ) )
    d := dllcall( ben ? bswp32:noswp, uint,numget( data,4,typ=5 ? "uint" : "int" )
                                              ,"cdecl " ( typ=5 ? "uint" : "int" ) )
    outp .= substr( s32 n, -15) substr( s32 d, -15)
    }

 if ( ( typ = 5 or typ = 10 ) && sz>8 ) { ; multi.pairs of 32 bit unsigned/signed rational
   Loop % ( sz/8 )
     n := dllcall( ben ? bswp32:noswp, uint,numget( data, _ := 8*(a_index-1), typ=5
                            ? "uint" : "int" ),"cdecl " ( typ=5 ? "uint" : "int" ) )
   , d := dllcall( ben ? bswp32:noswp, uint,numget( data, _ + 4, typ=5 ? "uint" : "int" )
                            ,"cdecl " ( typ=5 ? "uint" : "int" ) )
   , series .= "," round( n/d,6 )
  outp .= substr( series s32, 2,32 ), series := ""
    }
 }

 if ( t34665 ) {
  dllcall( "_llseek", uint,hfil, uint,t34665, uint,0 ), t34665 := 0
  dllcall( "_lread", uint,hfil, uint,&tem, uint,2 )
  count := dllcall( ben ? bswp16:noswp, ushort,numget( tem,0,"ushort" ), "cdecl ushort" )
  goto Exif_MultiLoop
 }

 if ( t34853 ) {
  dllcall( "_llseek", uint,hfil, uint,t34853, uint,0 ), t34853 := 0, gpstag := 1
  dllcall( "_lread", uint,hfil, uint,&tem, uint,2 )
  count := dllcall( ben ? bswp16:noswp, ushort,numget( tem,0,"ushort" ), "cdecl ushort" )
  goto Exif_MultiLoop
 }

 gpstag := False

 if ! ( ifd1p ) {             ;  attempting to read IFD1 which will contain thumbnail data
  dllcall( "_llseek", uint,hfil, uint,ifd0p+(ifd0c*12 )+2, int,0 )
  dllcall( "_lread", uint,hfil, uint,&tem, uint,4 )
  if ( ifd1p := dllcall( ben ? bswp32:noswp, uint,numget(tem), "cdecl" ) ) {
    dllcall( "_llseek", uint,hfil, uint,ifd1p+tiff, int,0 )
    dllcall( "_lread", uint,hfil, uint,&tem, uint,2 )
    count := dllcall( ben ? bswp16:noswp, ushort,numget( tem,0,"ushort" ),"cdecl ushort" )
    goto Exif_MultiLoop
 }}

                                                           ; thumbnail procedure
 if ( thm ) {                                              ; thumbnail has been requested
    varsetcapacity( thm,64,0 ), varsetcapacity( thm,0 )    ; reset the variable

 if t514                                                   ; thumbnail is available
    dllcall( "_llseek", uint,hfil, uint,tiff+t513, int,0 ) ; seek thumbnail
  , varsetcapacity( thm,t514 )                             ; set the capacity
  , dllcall( "_lread", uint,hfil, uint,&thm, uint,t514 )   ; read thumbnail into var

 }

 dllcall( "_lclose", uint,hfil )                           ; close the file

return "hTag" de "Tagname                     " de " FrameO" de "  DataO" de " Bytes" de
     . " Type" de "Value        BigE="  ben " / TiffO=" substr( "000" tiff,-3) outp
}


EXIF_Get( ByRef ExifTable, hTag, Field=6 ) {
 Static F0=1,L0=4, F1=6,L1=28, F2=35,L2=7, F3=43,L3=7, F4=51,L4=6, F5=58,L5=5, F6=64,L6=32
 Return (( Row:=SubStr( ExifTable, (F:=InStr( ExifTable, "`n" hTag) ) ? F+1 : 0, F ? 95
        : 0 )) && ( Field<0 || Field>6 ) ) ? Row : SubStr( Row, F%Field%, L%Field% )
}