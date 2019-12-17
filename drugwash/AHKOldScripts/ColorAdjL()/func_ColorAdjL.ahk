ColorAdjL( Lum=235, RGB="" ) {
 IfEqual,RGB,, Random,RGB,1,16777215
 DllCall( "shlwapi\ColorRGBToHLS", UInt,RGB, UIntP,H, UIntP,L, UIntP,S )
 CC := DllCall( "shlwapi\ColorHLSToRGB", UInt,H, UInt,Lum, UInt,S )
 VarSetCapacity(RGB,6,0), DllCall( "msvcrt.dll\sprintf", Str,RGB, Str,"%06X", UInt,CC )
Return RGB
}

Gui +ToolWindow +AlwaysOnTop
Dark  := ColorAdjL(  70, 0xFF0000 )
Light := ColorAdjL( 235, 0xFF0000 )
Gui, Color, %Light%
Gui, Font, s50
Gui, Add, Text, x5 y5 w200 h75 c%Dark% Center vText, Hello
Gui, Font
Gui, Add, Edit, x36 y100 w30 h20 Limit3 Center vLum, 230
Gui, Add, Button, x+5 h20 w100 gChangeGuiColor, Random Color
Gui, Show, w210 h130, % " GuiColor : " Light
Return

ChangeGuiColor:
 GuiControlGet, Lum
 Light := ColorAdjL( Lum )
 Gui, Color, %Light%
 Gui, Show,, % " GuiColor : " Light
Return

GuiClose:
 ExitApp
