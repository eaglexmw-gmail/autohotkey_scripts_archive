himl := IL_Create( 10, 0, 1 )
Loop 40
 IL_Add( himl, "shell32.dll", A_Index )
IML_Save( "test.iml", himl )
IL_Destroy( himl )

himl2 := IML_Load( "test.iml" )
Gui, Add, ListView, w480 h510 Icon, Icon
LV_SetImageList( himl2, 0 )
Loop 40
 LV_Add("Icon" . A_Index )
Gui, Show

#include IML.ahk
