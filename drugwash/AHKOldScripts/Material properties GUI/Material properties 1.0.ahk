
; v1.0 (4-29-09) ;                 
;
;=======================================================================================
;     Conversion from Metric to English (to be used in figures routine)
;=======================================================================================
;METRIC emod=GPa smod=GPa density=kg/m^3 yield=MPa CTE=µm/m-C Conduct=W/m-K Specific=J/kg-C
;ENGLISH emod=ksi*10^3 smod=ksi*10^3 density=lb/in^3 yield=ksi CTE=µin/in-F Conduct=BTU/hr-in-F Specific=BTU/lb-F
;CONVERSION Metric==>English
emod_convert:=.145037,smod_convert:=.145037,density_convert:=0.00003612700,yield_convert:=.145037,CTE_convert:=0.555556,Conduct_convert:=0.04818133759,Specific_convert:=238.8459


;=========================================================================================
;     INI File Check or Creation
;     - In .ini file material properties should be in metric units listed above
;     - Five common metals are used to make a default .ini file if Material-Properties.ini
;       doesn't exist
;=========================================================================================
;

IfNotExist,Material-Properties.ini
     {ini=
     (
[Names]
name1=Steel (304 SS)
name2=Aluminum (6061-T6)
name3=Titanium (6Al-4V)
name4=Beryllium (I220)
name5=Invar


[Properties]
Elastic1=195.
Shear1=86.
Poisson1=0.29
Density1=8000.
Yield1=215.
CTE1=17.3
Conductivity1=16.2
Specific1=0.0005

Elastic2=68.9
Shear2=26.
Poisson2=0.33
Density2=2700.
Yield2=276.
CTE2=23.6
Conductivity2=167.0
Specific2=0.0009

Elastic3=113.8
Shear3=44.
Poisson3=0.342
Density3=4430.
Yield3=880.
CTE3=8.6
Conductivity3=6.7
Specific3=0.00053

Elastic4=303.
Shear4=135.
Poisson4=0.13
Density4=1844.
Yield4=345.
CTE4=11.5
Conductivity4=216.
Specific4=0.00193

Elastic5=148.
Shear5=56.
Poisson5=0.29
Density5=8137.89
Yield5=241.3
CTE5=1.3
Conductivity5=10.15
Specific5=0.00052
     )
     FileAppend,%ini%,Material-Properties.ini
     }

;=======================================================================================
;     Drop Down List created from .ini file for Material Properties and Figures of Merit tabs
;=======================================================================================
Loop,1000
     {
     Iniread,name%A_Index%,Material-Properties.ini,Names,Name%A_Index%,0
     currentname:=name%A_Index%
     If currentname=0
          {
          matnum=%A_Index%
          break
          }
     droplist=%droplist%%currentname%|
     If A_Index=1
          droplist=%droplist%|
     }

;=======================================================================================
;     START GUI SECTION !!!!!
;=======================================================================================

Gui, Add, Tab2,x-4 y0 w300 h280 ggetter vgetter,Material Properties|Merit Figures|Converter|Calc


;=======================================================================================
;     Material Properties GUI tab
;=======================================================================================
Gui, Tab, 1

;Number formatting, decimals, and groupbox dividers
Gui, Margin, -2, -2
Gui, Add, GroupBox, x-5 y226 w300 h53 cblack,
Gui, Add, GroupBox, x-5 y227 w300 h53 cblack,
Gui, Add, Radio, x10 y235 h20 greg1 vreg1, Regular
Gui, Add, Radio, x10 y255 h20 gsci1 vsci1 checked, Scientific
Gui, Add, Edit, x95 y245 w40 h20 gRpre1 vRP1,
Gui, Add, UpDown, Range0-5 0x80, 2
Gui, Add, Text, x138 y247, decimals

;IniRead, namesread, Material-Properties.ini, names, name, 0
Gui, Add, Dropdownlist, x5 y32 w210 h20 r22 gfigures vmat, %droplist%
Gui, Add, DropDownList, x223 y32 w65 h20 gsystem vsystem r2, English||Metric

Gui, Add, Text, x5 y62 h20, Elastic Modulus (E)
Gui, Add, Text, x5 y83 h20, Shear Modulus (G)
Gui, Add, Text, x5 y104 h20, Poisson's Ratio (v)
Gui, Add, Text, x5 y125 h20, Density (p)
Gui, Add, Text, x5 y146 h20, Yield Strength (Yield)
Gui, Add, Text, x5 y167 h20, CTE (CTE)
Gui, Add, Text, x5 y188 h20, Thermal Conductivity (K)
Gui, Add, Text, x5 y209 h20, Specific Heat (Cp)

Gui, Add, Edit, x125 y60 h20 w90 vemod,
Gui, Add, Edit, x125 y81 h20 w90 vsmod,
Gui, Add, Edit, x125 y102 h20 w90 vpoisson,
Gui, Add, Edit, x125 y123  h20 w90 vdensity,
Gui, Add, Edit, x125 y144  h20 w90 vyield,
Gui, Add, Edit, x125 y165  h20 w90 vcte,
Gui, Add, Edit, x125 y186  h20 w90 vconduct,
Gui, Add, Edit, x125 y207  h20 w90 vspecific,

Gui, Add, Text, x225 y62 h20 vmet1, GPa
Gui, Add, Text, x225 y83 h20 vmet2, GPa
Gui, Add, Text, x225 y125 h20 vmet3, kg/m3
Gui, Add, Text, x225 y146 h20 vmet4, MPa
Gui, Add, Text, x225 y167 h20 vmet5, µm/m-C
Gui, Add, Text, x225 y188 h20 vmet6, W/m-K
Gui, Add, Text, x225 y209 h20 vmet7, J/kg-C

Gui, Add, Text, x225 y62 h20  hidden veng1, ksi*103
Gui, Add, Text, x225 y83 h20  hidden veng2, ksi*103
Gui, Add, Text, x225 y125 h20  hidden veng3, lb/in3
Gui, Add, Text, x225 y146 h20  hidden veng4, ksi
Gui, Add, Text, x225 y167 h20  hidden veng5, µin/in-F
Gui, Add, Text, x225 y188 h20  hidden veng6, BTU/hr-in-F
Gui, Add, Text, x225 y209 h20  hidden veng7, BTU/lb-F


;=======================================================================================
;     Figures of Merit GUI tab
;=======================================================================================
Gui, Tab, 2

Gui, Add, Dropdownlist, x5 y32 w210 h20 r22 gfigures vfigmat, %droplist%
Gui, Add, DropDownList, x223 y32 w65 h20 gsystem_mer vsystem_mer r2, English||Metric

Gui, Add, Text, x5 y62 h20  vmer1, Stiff. to Weight Ratio
Gui, Add, Text, x5 y83 h20  vmer2, Stiff. to Weight Ratio w/ yield
Gui, Add, Text, x5 y104 h20  vmer3, Stiff. to Wt. w Thermal Bending
Gui, Add, Text, x5 y125 h20  vmer4, Bending Parameter
Gui, Add, Text, x5 y146 h20  vmer5, Thermal Diffusivity w Expansion
Gui, Add, Text, x5 y167 h20  vmer6, Thermal Diffusivity
Gui, Add, Text, x5 y188 h20  vmer7, Conduction to Density Ratio
                   
Gui, Add, Edit, x160 y62 h20 w55  vmert1,
Gui, Add, Edit, x160 y83 h20 w55  vmert2,
Gui, Add, Edit, x160 y104 h20 w55  vmert3,
Gui, Add, Edit, x160 y125 h20 w55  vmert4,
Gui, Add, Edit, x160 y146 h20 w55  vmert5,
Gui, Add, Edit, x160 y167 h20 w55  vmert6,
Gui, Add, Edit, x160 y188 h20 w55  vmert7,

Gui, Add, Text, x225 y62 h20 w65,E/p
Gui, Add, Text, x225 y83 h20 w65,E/p*Yield
Gui, Add, Text, x225 y104 h20 w65,E/p*(K/CTE)
Gui, Add, Text, x225 y125 h20 w65,K/CTE
Gui, Add, Text, x225 y146 h20 w65,K/(CTE*p*Cp)
Gui, Add, Text, x225 y167 h20 w65,K/(p*Cp)
Gui, Add, Text, x225 y188 h20 w65,K/p


Gui, Add, GroupBox, x-5 y226 w300 h53 cblack,
Gui, Add, GroupBox, x-5 y227 w300 h53 cblack,


;=======================================================================================
;     Unit Converter GUI tab
;=======================================================================================
Gui, Tab, 3

Gui, Font, s14
Gui, Add, Text, x85 y30, Unit Converter
Gui, Font

Gui, Add, DropDownList, x75 y61 w145 h20 r26 gunits vunits, Acceleration||Angle|Area|Coeff. of Thermal Expansion|Density|Distance|Electric Current|Energy|Force|Heat Capacity|Heat Transfer Coefficient|Mass|Power|Pressure|Specific Heat|Speed|Temperature|Thermal Conductivity|Time|Volume| |--------------------------------------------------|Physical Constants|Mathematical Constants

;Middle GUI controls, from and to units
Gui, Add, DropDownList, x6 y88 w125 h20 r30  vfrom gcalculate,
Gui, Add, Text, x138 y88 w17 h20  gswap vswap +Center, To:
Gui, Add, DropDownList, x161 y88 w125 h20 r30  vto gcalculate,

;Bottom GUI controls, input and result
Gui, Add, Edit, x6 y108 w125 h20 gcalculate vtot,
Gui, add, updown,range1-1000 +wrap 0x80  vgoaway,1
Gui, Add, Text, x131 y108 w30 h20 +Center  vequal, =
Gui, Add, Edit, x161 y108 w125 h20 vrez  +readonly,

Gui, Add, GroupBox, x-5 y135 w300 h60 cblack,
Gui, Add, GroupBox, x-5 y136 w300 h60 cblack,

Gui, Add, Radio, x10 y145 h20 greg3 vreg3, Regular
Gui, Add, Radio, x10 y165 h20 gsci3 vsci3 checked, Scientific
Gui, Add, Edit, x85 y155 w40 h20 gRpre3 vRP3,
Gui, Add, UpDown, Range0-16 0x80, 2
Gui, Add, Text, x128 y157, decimals

;Memory variable controls
Gui, Add, Text, x185 y147 vgobyebye , save result to:
Gui, Add, DropDownList, x185 y162 w75 h17 r5  gmem vmem, Memory1|Memory2|Memory3|Memory4|Memory5

;=======================================================================================
;     Calc (Expression Evaluator) GUI tab
;=======================================================================================
Gui, Tab, 4

Gui, Font, s14
Gui, Add, Text, x55 y30, Expression Evaluator
Gui, Font

Gui Add, Edit, x4 y62 w165 h20 vcode ,
Gui Add, Edit, x187 y62 w100 h20 vres  Readonly ; no scroll bar for results
Gui Add, Button, x47 y88 w55 h20 Default  vevaluate, &Evaluate
Gui Add, Button, x4 y88 w40 h20  vclear, &Clear
Gui Add, Button, x105 y88 w30 h20  vhelp, &Help
Gui Add, Text, x175 y65 w5 h20  +Center vequals, =
Gui Add, Button, x160 y88 w16 h20  vlparen, (
Gui Add, Button, x177 y88 w16 h20  vrparen, )
Gui Add, Button, x194 y88 w16 h20  vmultiply, x
Gui Add, Button, x211 y88 w16 h20  vdivide, /
Gui Add, Button, x228 y88 w16 h20  vadd, +
Gui Add, Button, x245 y88 w16 h20  vsubtract, -
Gui Add, Button, x262 y88 w24 h20  vexponent,exp

Gui, Add, GroupBox, x-5 y135 w300 h60 cblack,
Gui, Add, GroupBox, x-5 y136 w300 h60 cblack,

Gui, Add, Radio, x10 y145 h20 greg4 vreg4, Regular
Gui, Add, Radio, x10 y165 h20 gsci4 vsci4 checked, Scientific
Gui, Add, Edit, x85 y155 w40 h20 gRpre4 vRP4,
Gui, Add, UpDown, Range0-16 0x80, 3
Gui, Add, Text, x128 y157, decimals

Gui, Add, Text, x185 y147 vgone , paste memory:
Gui, Add, DropDownList, x185 y162 w75 h17 r5  gmemrec vmemrec, Memory1|Memory2|Memory3|Memory4|Memory5


gosub Initializer
gosub getter
gosub figures
gosub units

Gui, Show, AutoSize, Engineer's Friend
Return

GuiClose:
ExitApp

;==================================================================================
;     END GUI SECTION
;==================================================================================



;==================================================================================
;     Properties are populated from .ini file in Initializer routine
;     - Initializer is called at end of GUI section
;==================================================================================
Initializer:
Gui, submit, nohide
Loop,%matnum%
     {
     Iniread,emod%A_Index%,Material-Properties.ini,Properties,Elastic%A_Index%,0
     Iniread,smod%A_Index%,Material-Properties.ini,Properties,Shear%A_Index%,0
     Iniread,poisson%A_Index%,Material-Properties.ini,Properties,Poisson%A_Index%,0
     Iniread,density%A_Index%,Material-Properties.ini,Properties,Density%A_Index%,0
     Iniread,yield%A_Index%,Material-Properties.ini,Properties,Yield%A_Index%,0
     Iniread,cte%A_Index%,Material-Properties.ini,Properties,CTE%A_Index%,0
     Iniread,conduct%A_Index%,Material-Properties.ini,Properties,Conductivity%A_Index%,0
     Iniread,specific%A_Index%,Material-Properties.ini,Properties,Specific%A_Index%,0
     Iniread,name%A_Index%,Material-Properties.ini,Names,Name%A_Index%,0
     }     
Return
 
 
;=====================================================================================
;     Getter routine is run at start of each tab and during drop down list selections
;      -This routine could be simpler and is a brute force approach to getting things
;       working and displaying right
;=====================================================================================   
getter:
Gui, submit, nohide

If getter=material properties
     {
     If pre1
          {
          SetFormat,Float,0.%RP1%E
          GuiControl,,sci1,1
          GuiControl,,reg1,0
          }
     Else
          {
          SetFormat,Float,0.%RP1%
          GuiControl,,reg1,1
          GuiControl,,sci1,0
          }
     }

If getter=merit figures
     {
     If system_mer=English
          SetFormat, Float,0.2
     If system_mer=Metric
          SetFormat, Float,0.4
     merit1 := merit1 + 0
     merit2 := merit2 + 0
     merit3 := merit3 + 0
     merit4 := merit4 + 0
     merit5 := merit5 + 0
     merit6 := merit6 + 0
     merit7 := merit7 + 0
     If merit1>-1
          guicontrol,,mert1, %merit1%
     else
          guicontrol,,mert1, No Data
     
     If merit2>-1
          guicontrol,,mert2, %merit2%
     else
          guicontrol,,mert2, No Data
     
     If merit3>-1
          guicontrol,,mert3, %merit3%
     else
          guicontrol,,mert3, No Data
     
     If merit4>-1
          guicontrol,,mert4, %merit4%
     else
          guicontrol,,mert4, No Data
     
     If merit5>-1
          guicontrol,,mert5, %merit5%
     else
          guicontrol,,mert5, No Data
     
     If merit6>-1
          guicontrol,,mert6, %merit6%
     else
          guicontrol,,mert6, No Data
     
     If merit7>-1
          guicontrol,,mert7, %merit7%
     else
          guicontrol,,mert7, No Data     
     }
     
If getter=converter
     {                           
     If pre3                       
          {
          SetFormat,Float,0.%RP3%E
          GuiControl,,sci3,1
          GuiControl,,reg3,0
          }
     Else
          {                         
          SetFormat,Float,0.%RP3%
          GuiControl,,sci3,0
          GuiControl,,reg3,1
          }
     val:=val+0
     }                             


If getter=calc
     {                             
     If pre4                       
          {
          SetFormat,Float,0.%RP4%E
          GuiControl,,sci4,1
          GuiControl,,reg4,0
          }
     Else                         
          {
          SetFormat,Float,0.%RP4%
          GuiControl,,sci4,0
          GuiControl,,reg4,1
          }
     }                             
Return


;==================================================================================
;     System and System_mer are run when switching between Metric and English
;==================================================================================
system:
Gui, submit, nohide
If system=Metric
     {
     Guicontrol, Show, met1
     Guicontrol, Show, met2
     Guicontrol, Show, met3
     Guicontrol, Show, met4
     Guicontrol, Show, met5
     Guicontrol, Show, met6
     Guicontrol, Show, met7
     Guicontrol, Hide, eng1
     Guicontrol, Hide, eng2
     Guicontrol, Hide, eng3
     Guicontrol, Hide, eng4
     Guicontrol, Hide, eng5
     Guicontrol, Hide, eng6
     Guicontrol, Hide, eng7
     gosub figures
     }
If system=English
     {
     Guicontrol, Hide, met1
     Guicontrol, Hide, met2
     Guicontrol, Hide, met3
     Guicontrol, Hide, met4
     Guicontrol, Hide, met5
     Guicontrol, Hide, met6
     Guicontrol, Hide, met7
     Guicontrol, Show, eng1
     Guicontrol, Show, eng2
     Guicontrol, Show, eng3
     Guicontrol, Show, eng4
     Guicontrol, Show, eng5
     Guicontrol, Show, eng6
     Guicontrol, Show, eng7
     gosub figures
     }
Return

system_mer:
Gui, submit, nohide
gosub figures
Return


;=================================================================================
;     REG, SCI, and RPRE are run when changing precision or number format
;     - There are 4 sets of functions, one for each tab
;=================================================================================
reg1:
pre1 = 0
GuiControl,,sci1,0
GuiControl,,reg1,1
gosub figures
return

sci1:
pre1 = 1
GuiControl,,sci1,1
GuiControl,,reg1,0
gosub figures
return

reg3:
pre3 = 0
GuiControl,,sci3,0
GuiControl,,reg3,1
gosub calculate
return

sci3:
pre3 = 1
GuiControl,,sci3,1
GuiControl,,reg3,0
gosub calculate
return

reg4:
pre4 = 0
GuiControl,,sci4,0
GuiControl,,reg4,1
gosub buttonevaluate
return

sci4:
pre4 = 1
GuiControl,,sci4,1
GuiControl,,reg4,0
gosub buttonevaluate
return

Rpre1:
Gui, submit, nohide
gosub figures
If System=English
     gosub system
return

Rpre3:
Gui, submit, nohide
gosub calculate
return

Rpre4:
Gui, submit, nohide
RegP = 0.%RP4%
gosub buttonevaluate
return


;=================================================================================
;     Figures routine does all the calculation and display requests for
;     Material Properties and Figures of Merit tabs
;=================================================================================
figures:
Gui, submit, nohide

Setformat, float, 0.16E

; Clear Property Variables
emod_mat:=
smod_mat:=
poisson_mat:=
density_mat:=
yield_mat:=
cte_mat:=
conduct_mat:=
specific_mat:=

emod_mer:=
smod_mer:=
poisson_mer:=
density_mer:=
yield_mer:=
cte_mer:=
conduct_mer:=
specific_mer:=

Loop,%matnum%
     {
     named:=name%A_Index%
     If mat=%named%
          appendmat=%A_Index%
     If figmat=%named%
          appendmer=%A_Index%
     }

If System=English
{
     emod_mat := emod%appendmat%*emod_convert
     smod_mat := smod%appendmat%*smod_convert
     poisson_mat := poisson%appendmat%
     density_mat := density%appendmat%*density_convert
     yield_mat := yield%appendmat%*yield_convert
     cte_mat := cte%appendmat%*cte_convert
     conduct_mat := conduct%appendmat%*conduct_convert
     specific_mat := specific%appendmat%*specific_convert
}
Else
{
     emod_mat := emod%appendmat%
     smod_mat := smod%appendmat%
     poisson_mat := poisson%appendmat%
     density_mat := density%appendmat%
     yield_mat := yield%appendmat%
     cte_mat := cte%appendmat%
     conduct_mat := conduct%appendmat%
     specific_mat := specific%appendmat%
}

If System_mer=English
{
     emod_mer := abs(emod%appendmer%*emod_convert)
     smod_mer := abs(smod%appendmer%*smod_convert)
     poisson_mer := abs(poisson%appendmer%)
     density_mer := abs(density%appendmer%*density_convert)
     yield_mer := abs(yield%appendmer%*yield_convert)
     cte_mer := abs(cte%appendmer%*cte_convert)
     conduct_mer := abs(conduct%appendmer%*conduct_convert)
     specific_mer := abs(specific%appendmer%*specific_convert)
}
Else
{
     emod_mer := abs(emod%appendmer%)
     smod_mer := abs(smod%appendmer%)
     poisson_mer := abs(poisson%appendmer%)
     density_mer := abs(density%appendmer%)
     yield_mer := abs(yield%appendmer%)
     cte_mer := abs(cte%appendmer%)
     conduct_mer := abs(conduct%appendmer%)
     specific_mer := abs(specific%appendmer%)
}


merit1 := emod_mer/density_mer
merit2 := emod_mer/density_mer*yield_mer
merit3 := emod_mer/density_mer*conduct_mer/cte_mer
merit4 := conduct_mer/cte_mer
merit5 := conduct_mer/(density_mer*specific_mer*cte_mer)
merit6 := conduct_mer/(density_mer*specific_mer)
merit7 := conduct_mer/density_mer

gosub getter

emod_mat := emod_mat + 0
smod_mat := smod_mat + 0
poisson_mat := poisson_mat + 0
density_mat := density_mat + 0
yield_mat := yield_mat + 0
cte_mat := cte_mat + 0
conduct_mat := conduct_mat + 0
specific_mat := specific_mat + 0

merit1 := merit1 + 0
merit2 := merit2 + 0
merit3 := merit3 + 0
merit4 := merit4 + 0
merit5 := merit5 + 0
merit6 := merit6 + 0
merit7 := merit7 + 0

If getter=material properties
     {

     If emod_mat>-1
          guicontrol,,emod, %emod_mat%
     else
          guicontrol,,emod, No Data
     
     If smod_mat>-1
          guicontrol,,smod, %smod_mat%
     else
          guicontrol,,smod, No Data
     
     If poisson_mat>-1
          guicontrol,,poisson, %poisson_mat%
     else
          guicontrol,,poisson, No Data
     
     If density_mat>-1
          guicontrol,,density, %density_mat%
     else
          guicontrol,,density, No Data
     
     If yield_mat>-1
          guicontrol,,yield, %yield_mat%
     else
          guicontrol,,yield, No Data
     
     If cte_mat>-1
          guicontrol,,cte, %cte_mat%
     else
          guicontrol,,cte, No Data
     
     If conduct_mat>-1
          guicontrol,,conduct, %conduct_mat%
     else
          guicontrol,,conduct, No Data
     
     If specific_mat>-1
          guicontrol,,specific, %specific_mat%
     else
          guicontrol,,specific, No Data
     }


Else
     {
     If merit1>-1
          guicontrol,,mert1, %merit1%
     else
          guicontrol,,mert1, No Data
     
     If merit2>-1
          guicontrol,,mert2, %merit2%
     else
          guicontrol,,mert2, No Data
     
     If merit3>-1
          guicontrol,,mert3, %merit3%
     else
          guicontrol,,mert3, No Data
     
     If merit4>-1
          guicontrol,,mert4, %merit4%
     else
          guicontrol,,mert4, No Data
     
     If merit5>-1
          guicontrol,,mert5, %merit5%
     else
          guicontrol,,mert5, No Data
     
     If merit6>-1
          guicontrol,,mert6, %merit6%
     else
          guicontrol,,mert6, No Data
     
     If merit7>-1
          guicontrol,,mert7, %merit7%
     else
          guicontrol,,mert7, No Data
     }
Return


;=================================================================================
;     Units and Calculate routines do all the calculations for the
;     Unit Converter tab.  About 900 lines long!
;=================================================================================
units:
Gui, submit, nohide
Setformat, float, 0.16E

if units=Mass
{
Guicontrol,, from, |
Guicontrol,, from, kilograms|grams|ounces||pounds|stone|ton|ton(uk)|slugs
Guicontrol,, to, |
Guicontrol,, to, kilograms|grams|ounces||pounds|stone|ton|ton(uk)|slugs
}

if units=Distance
{
Guicontrol,, from, |
Guicontrol,, from, feet|inches||mil|meters|centimeter|kilometer|millimeter|micron|mile|furlong|yard|Angstrom|light year|parsec|AU
Guicontrol,, to, |
Guicontrol,, to, feet|inches||mil|meters|centimeter|kilometer|millimeter|micron|mile|furlong|yard|Angstrom|light year|parsec|AU
}

if units=Density
{
Guicontrol,, from, |
Guicontrol,, from, lb/in3||lb/ft3|g/cm3|kg/m3|slugs/ft3
Guicontrol,, to, |
Guicontrol,, to, lb/in3||lb/ft3|g/cm3|kg/m3|slugs/ft3
}

if units=Acceleration
{
Guicontrol,, from, |
Guicontrol,, from, m/s2||in/s2|ft/s2|g's
Guicontrol,, to, |
Guicontrol,, to, m/s2||in/s2|ft/s2|g's
}

if units=Force
{
Guicontrol,, from, |
Guicontrol,, from, Newton||lbf|dyne
Guicontrol,, to, |
Guicontrol,, to, Newton||lbf|dyne
}

if units=Pressure
{
Guicontrol,, from, |
Guicontrol,, from, Pascal||psi|psf|torr|bar|atm|mm mercury|cm water
Guicontrol,, to, |
Guicontrol,, to, Pascal||psi|psf|torr|bar|atm|mm mercury|cm water
}

if units=Energy
{
Guicontrol,, from, |
Guicontrol,, from, Joule||BTU|in lbf|ft lbf|kcal|therm
Guicontrol,, to, |
Guicontrol,, to, Joule||BTU|in lbf|ft lbf|kcal|therm
}

if units=Power
{
Guicontrol,, from, |
Guicontrol,, from, Watt||BTU/sec|BTU/hour|hp|ft lbf/s
Guicontrol,, to, |
Guicontrol,, to, Watt||BTU/sec|BTU/hour|hp|ft lbf/s
}

if units=Time
{
Guicontrol,, from, |
Guicontrol,, from, seconds||minutes|hours|days|weeks|months(30d)|years
Guicontrol,, to, |
Guicontrol,, to, seconds||minutes|hours|days|weeks|months(30d)|years
}

if units=Thermal Conductivity
{
Guicontrol,, from, |
Guicontrol,, from, Watt/m-K||kiloWatt/m-K|BTU/hr-ft-F|BTU/hr-in-F|BTU-in/hr-ft2-F|cal/s-cm-C
Guicontrol,, to, |
Guicontrol,, to, Watt/m-K||kiloWatt/m-K|BTU/hr-ft-F|BTU/hr-in-F|BTU-in/hr-ft2-F|cal/s-cm-C
}

if units=Specific Heat
{
Guicontrol,, from, |
Guicontrol,, from, KiloJoule/kg-K||BTU/lb-F|cal/g-C
Guicontrol,, to, |
Guicontrol,, to, KiloJoule/kg-K||BTU/lb-F|cal/g-C
}

if units=Heat Capacity
{
Guicontrol,, from, |
Guicontrol,, from, J/kg-K||BTU/lb-C|BTU/lb-F|cal/g-C
Guicontrol,, to, |
Guicontrol,, to, J/kg-K||BTU/lb-C|BTU/lb-F|cal/g-C
}

if units=Heat Transfer Coefficient
{
Guicontrol,, from, |
Guicontrol,, from, Watt/m2-K||BTU/hr-ft2-F|cal/s-cm2-C|kcal/hr-ft2-C
Guicontrol,, to, |
Guicontrol,, to, Watt/m2-K||BTU/hr-ft2-F|cal/s-cm2-C|kcal/hr-ft2-C
}

if units=Area
{
Guicontrol,, from, |
Guicontrol,, from, m2||cm2|mm2|micron2|in2|ft2|yd2|mil2|acre
Guicontrol,, to, |
Guicontrol,, to, m2||cm2|mm2|micron2|in2|ft2|yd2|mil2|acre
}

if units=Volume
{
Guicontrol,, from, |
Guicontrol,, from, m3||cm3|mm3|in3|ft3|yd3|ounce|pint|quart|tsp|tbsp|liter
Guicontrol,, to, |
Guicontrol,, to, m3||cm3|mm3|in3|ft3|yd3|ounce|pint|quart|tsp|tbsp|liter
}

if units=Angle
{
Guicontrol,, from, |
Guicontrol,, from, radians||degrees|mils|minute|second|grad|cycle
Guicontrol,, to, |
Guicontrol,, to, radians||degrees|mils|minute|second|grad|cycle
}

if units=Temperature
{
Guicontrol,, from, |
Guicontrol,, from, Kelvin||Celsius|Fahrenheit|Rankine|Reaumur
Guicontrol,, to, |
Guicontrol,, to, Kelvin||Celsius|Fahrenheit|Rankine|Reaumur
}

if units=Speed
{
Guicontrol,, from, |
Guicontrol,, from, m/s||km/h|in/s|ft/s|yard/s|mph|Mach Number|speed of light
Guicontrol,, to, |
Guicontrol,, to, m/s||km/h|in/s|ft/s|yard/s|mph|Mach Number|speed of light
}

if units=Electric Current
{
Guicontrol,, from, |
Guicontrol,, from, ampere||coulomb/s|statampere
Guicontrol,, to, |
Guicontrol,, to, ampere||coulomb/s|statampere
}

Guicontrol, Show, to
Guicontrol, Show, swap

if units=Physical Constants
{
Guicontrol,, from, |
Guicontrol,, from, Speed of Light (m/s)||Gravitation (m3/kg-s2)|Planck's Constant (J-s)|magnetic constant (N/A2)|electric constant (F/m)|Coulomb cons. (N-m2/C2)|elementary charge (C)|Electron Mass (kg)|Proton Mass (kg)|fine structure constant|Rydberg constant (1/m)|atomic mass unit (kg)|Avogadro's # (1/mol)|Boltzmann constant (J/K)|Faraday constant (C/mol)|gas constant (J/K-mol)|Stefan-Boltz. (W/m2-K^4)
Guicontrol,, to, |
Guicontrol,, to, value
Guicontrol,Hide, to
Guicontrol,Hide, swap
}


if units=Coeff. of Thermal Expansion
{
Guicontrol,, from, |
Guicontrol,, from, 1/°K||1/°C|1/°F|1/°R
Guicontrol,, to, |
Guicontrol,, to, 1/°K||1/°C|1/°F|1/°R
}

if units=Mathematical Constants
{
Guicontrol,, from, |
Guicontrol,, from, Pi||e|Euler-Mascheroni|Golden Ratio|Silver Ratio|Feigenbaum 1|Feigenbaum 2|Twin Prime constant|Meissel-Mertens|Laplace limit|Apéry's constant|Lévy's constant|Omega constant|Plastic Constant|Parabolic Constant|Brun's Twin Prime|Brun's Quad Prime|Khinchin's constant|Fransén-Robinson|
Guicontrol,, to, |
Guicontrol,, to, value
Guicontrol,Hide, to
Guicontrol,Hide, swap
}

gosub, calculate
return


calculate:
gui, submit, nohide
SetFormat, Float, 0.16E

;distance from
if from=feet
from=1.0
if from=inches
from:=.0833333
if from=mil
from:=.0000833333
if from=microns
from:=3.2808E-6
if from=meters
from=3.2808
if from=kilometer
from=3280.8399
if from=centimeter
from=0.032808399
if from=millimeter
from=0.0032808399
if from=mile
from=5280
if from=furlong
from=660
if from=yard
from=3
if from=Angstrom
from=3.280839895E-10
if from=light year
from=31017896836000000
if from=parsec
from=101236138050000000
if from=AU
from=490806662370
;distance to
if to=feet
to=1.0
if to=inches
to:=.0833333
if to=mil
to:=.0000833333
if to=micron
to:=3.2808E-6
if to=meters
to=3.2808
if to=kilometer
to=3280.8399
if to=centimeter
to=0.032808399
if to=millimeter
to=0.0032808399
if to=mile
to=5280
if to=furlong
to=660
if to=yard
to=3
if to=Angstrom
to=3.280839895E-10
if to=light year
to=31017896836000000
if to=parsec
to=101236138050000000
if to=AU
to=490806662370


;Area from
If From=m2
From=1.0
If From=cm2
From=.0001
If From=mm2
From=0.000001
If From=micron2
From=1.0E-12
If From=in2
From=0.00064516
If From=ft2
From=0.09290304
If From=yd2
From=0.83612736
If From=mil2
From=6.4516E-10
If From=acre
From=4046.8564224
;Area to
If To=m2
To=1.0
If To=cm2
To=.0001
If To=mm2
To=0.000001
If To=micron2
To=1.0E-12
If To=in2
To=0.00064516
If To=ft2
To=0.09290304
If To=yd2
To=0.83612736
If To=mil2
To=6.4516E-10
If To=acre
To=4046.8564224

;Volume from
If From=m3
From=1.0
If From=cm3
From=0.000001
If From=mm3
From=1.0E-9
If From=in3
From=0.000016387064
If From=ft3
From=0.028316846592
If From=yd3
From=0.76455485798
If From=cup
From=0.0002365882365
If From=ounce
From=0.000029573529563
If From=pint
From=0.000473176473
If From=quart
From=0.000946352946
If From=tsp
From=0.0000049289215938
If From=tbsp
From=0.000014786764781
If From=liter
From=0.001
;Volume to
If To=m3
To=1.0
If To=cm3
To=0.000001
If To=mm3
To=1.0E-9
If To=in3
To=0.000016387064
If To=ft3
To=0.028316846592
If To=yd3
To=0.76455485798
If To=cup
To=0.0002365882365
If To=ounce
To=0.000029573529563
If To=pint
To=0.000473176473
If To=quart
To=0.000946352946
If To=tsp
To=0.0000049289215938
If To=tbsp
To=0.000014786764781
If To=liter
To=0.001

;Angle from
If From=radians
From=1.0
If From=degrees
From=0.01745329252
If From=minute
From=0.00029088820867
If From=second
From=0.0000048481368111
If From=mils
From=0.00098174770425
If From=grad
From=0.015707963268
If From=cycle
From=6.2831853072
If From=circle
From=6.2831853072
;Angle to
If To=radians
To=1.0
If To=degrees
To=0.01745329252
If To=minute
To=0.00029088820867
If To=second
To=0.0000048481368111
If To=mils
To=0.00098174770425
If To=grad
To=0.015707963268
If To=cycle
To=6.2831853072
If To=circle
To=6.2831853072

;weight from
If From=Kilograms
From=2.2046226218
If From=Grams
From=0.0022046226218
If From=Ounces
From=0.0625
If From=Pounds
From=1
If From=Stone
From=14
If From=Ton
From=2000
If From=Ton(Uk)
From=2240
If From=slugs
From=14.593903
;weight to
If To=Kilograms
To=2.2046
If To=Grams
To=0.0022046226218
If To=Ounces
To=0.0625
If To=Pounds
To=1
If To=Stone
To=14
If To=Ton
To=2000
If To=Ton(Uk)
To=2240
If To=slugs
To=14.593903

;density from
If From=lb/in3
From=1
If From=lb/ft3
From=0.000578703
If From=Kg/m3
From=3.6127E-5
If From=slugs/ft3
From=515.31788206
If From=g/cm3
From=0.036127292927
;density to
If To=lb/in3
To=1
If To=lb/ft3
To=0.000578703
If To=Kg/m3
To=3.6127E-5
If To=slugs/ft3
To=515.31788206
If To=g/cm3
To=0.036127292927

;acceleration from
If From=m/s2
From=1
If From=in/s2
From=0.0254
If From=ft/s2
From=0.3048
If From=g's
From=9.80665
;acceleration to
If To=m/s2
To=1
If To=in/s2
To=0.0254
If To=ft/s2
To=0.3048
If To=g's
To=9.80665

;Force from
If From=Newton
From=1
If From=lbf
From=4.4482
If From=dyne
From=10.0E-6
;Force to
If To=Newton
To=1
If To=lbf
To=4.4482
If To=dyne
To=10.0E-6

;Pressure from
If From=Pascal
From=1
If From=psi
From=6894.757
If From=psf
From=47.88025
If From=torr
From=133.3224
If From=mm mercury
From=133.3224
If From=bar
From=1.0E5
If From=atm
From=101325
If From=cm water
From=98.0665
;Pressure to
If To=Pascal
To=1
If To=psi
To=6894.757
If To=psf
To=47.88025
If To=torr
To=133.3224
If To=mm mercury
To=133.3224
If To=bar
To=1.0E5
If To=atm
To=101325
If To=cm water
To=98.0665

;Energy from
If From=Joule
From=1
If From=BTU
From=1.055055E3
If From=in lbf
From=0.112984
If From=ft lbf
From=1.355817
If From=kcal
From=4186.8
If From=therm
From=105505585.257348
;Energy to
If To=Joule
To=1
If To=BTU
To=1.055055E3
If To=in lbf
To=0.112984
If To=ft lbf
To=1.355817
If To=kcal
To=4186.8
If To=therm
To=105505585.257348

;Power from
If From=Watt
From=1
If From=BTU/hour
From=0.293071
If From=BTU/sec
From=1055.055
If From=hp
From=735.49875
If From=ft lbf/s
From=1.355817
;Power to
If To=Watt
To=1
If To=BTU/hour
To=0.293071
If To=BTU/sec
To=1055.055
If To=hp
To=735.49875
If To=ft lbf/s
To=1.355817

;Time from
If From=seconds
From=1
If From=minutes
From=60
If From=hours
From=3600
If From=days
From=86400
If From=weeks
From=604800
If From=months(30d)
From=2592000
If From=years
From=31536000
;Time to
If To=seconds
To=1
If To=minutes
To=60
If To=hours
To=3600
If To=days
To=86400
If To=weeks
To=604800
If To=months(30d)
To=2592000
If To=years
To=31536000

;Thermal Conductivity from
If From=Watt/m-K
From=1
If From=kiloWatt/m-K
From=1000
If From=BTU/hr-ft-F
From=1.729577
If From=BTU/hr-in-F
From=20.754924
If From=BTU-in/hr-ft2-F
From=0.144131
If From=cal/s-cm-C
From=418.4
;Thermal Conductivity to
If To=Watt/m-K
To=1
If To=kiloWatt/m-K
To=1000
If To=BTU/hr-ft-F
To=1.729577
If To=BTU/hr-in-F
To=20.754924
If To=BTU-in/hr-ft2-F
To=0.144131
If To=cal/s-cm-C
To=418.4

;Specific Heat from
If From=KiloJoule/kg-K
From=1
If From=BTU/lb-F
From=4.1868
If From=cal/g-C
From=4.1868
;Specific Heat to
If To=KiloJoule/kg-K
To=1
If To=BTU/lb-F
To=4.1868
If To=cal/g-C
To=4.1868

;Heat Capacity from
If From=J/kg-K
From=1
If From=BTU/lb-C
From=2326
If From=BTU/lb-F
From=4186.8
If From=cal/g-C
From=4186.8
;Heat Capacity to
If To=J/kg-K
To=1
If To=BTU/lb-C
To=2326
If To=BTU/lb-F
To=4186.8
If To=cal/g-C
To=4186.8

;Heat Transfer Coefficient from
If From=Watt/m2-K
From=1
If From=BTU/hr-ft2-F
From=5.678263
If From=cal/s-cm2-C
From=41868
If From=kcal/hr-ft2-C
From=12.518428
;Heat Transfer Coefficient to
If To=Watt/m2-K
To=1
If To=BTU/hr-ft2-F
To=5.678263
If To=cal/s-cm2-C
To=41868
If To=kcal/hr-ft2-C
To=12.518428

;Speed from
If From=m/s
From=1
If From=km/h
From=0.277777777778
If From=in/s
From=0.0254
If From=ft/s
From=0.3048
If From=yard/s
From=0.9144
If From=mph
From=0.44704
If From=Mach Number
From=340.2933
If From=speed of light
From=299790000
;Speed to
If To=m/s
To=1
If To=km/h
To=0.277777777778
If To=in/s
To=0.0254
If To=ft/s
To=0.3048
If To=yard/s
To=0.9144
If To=mph
To=0.44704
If To=Mach Number
To=340.2933
If To=speed of light
To=299790000

;Electric Current from
If From=ampere
From=1
If From=coulomb/s
From=1
If From=statampere
From=3.335641E-10
;Electric Current to
If To=ampere
To=1
If To=coulomb/s
To=1
If To=statampere
To=3.335641E-10

;Coefficient of Thermal Expansion from
If From=1/°K
From=1.0
If From=1/°C
From=1.0
If From=1/°F
From=1.8
If From=1/°R
From=1.8
;Coefficient of Thermal Expansion to
If to=1/°K
to=1.0
If to=1/°C
to=1.0
If to=1/°F
to=1.8
If to=1/°R
to=1.8

val:=(from/to)*tot


;Temperature Equation - SPECIAL CASE
If units=Temperature
   {
   If From=Kelvin
     {
     If To=Kelvin
        val:=tot
     If To=Fahrenheit
        val:=tot*9/5-459.67
     If To=Celsius
        val:=tot-273.15
     If To=Rankine
        val:=tot*9/5
     If To=Reaumur
        val:=(tot-273.15)*4/5
     }
   Else If From=Fahrenheit
     {
     If To=Kelvin
        val:=(tot+459.67)*5/9
     If To=Fahrenheit
        val:=tot
     If To=Celsius
        val:=(tot-32)*5/9
     If To=Rankine
        val:=tot+459.67
     If To=Reaumur
        val:=(tot-32)*4/9
     }
   Else If From=Celsius
     {
     If To=Kelvin
        val:=tot+273.15
     If To=Fahrenheit
        val:=tot*9/5+32
     If To=Celsius
        val:=tot
     If To=Rankine
        val:=(tot+273.15)*9/5
     If To=Reaumur
        val:=tot*4/5
     }
   Else If From=Rankine
     {
     If To=Kelvin
        val:=tot*5/9
     If To=Fahrenheit
        val:=tot-459.67
     If To=Celsius
        val:=(tot-491.67)*5/9
     If To=Rankine
        val:=tot
     If To=Reaumur
        val:=(tot-491.67)*4/9
     }
   Else If From=Reaumur
     {
     If To=Kelvin
        val:=tot*5/4+273.15
     If To=Fahrenheit
        val:=tot*9/4+32
     If To=Celsius
        val:=tot*5/4
     If To=Rankine
        val:=tot*9/4+491.67
     If To=Reaumur
        val:=tot
     }
   }

;Physical Constants - SPECIAL CASE
If Units=Physical Constants
     {
     If From=Speed of Light (m/s)
          val:=299792458.
     If From=Gravitation (m3/kg-s2)
          val:=6.67428E-11
     If From=Planck's constant (J-s)
          val:=6.62606896E-34
     If From=magnetic constant (N/A2)
          val:=1.256637061E-6
     If From=electric constant (F/m)
          val:=8.854187817E-12
     If From=Coulomb cons. (N-m2/C2)
          val:=8.9875517873681764E9
     If From=elementary charge (C)
          val:=1.602176487E-19
     If From=Electron Mass (kg)
          val:=9.10938215E-31
     If From=Proton Mass (kg)
          val:=1.672621637E-27
     If From=fine structure constant
          val:=7.2973525376E-3
     If From=Rydberg constant (1/m)
          val:=10973731.568525
     If From=atomic mass unit (kg)
          val:=1.66053886E-27
     If From=Avogadro's # (1/mol)
          val:=6.0221415E23
     If From=Boltzmann constant (J/K)
          val:=1.3806503882381375462532721956135E-23
     If From=Faraday constant (C/mol)
          val:=96485.3371638995
     If From=gas constant (J/K-mol)
          val:=8.314472
     If From=Stefan-Boltz. (W/m2-K^4)
          val:=5.670400E-8
     }

;Mathematical Constants - SPECIAL CASE
If Units=Mathematical Constants
     {
     If From=Pi
          val:=3.14159265358979323846264338327950288
     If From=e
          val:=2.71828182845904523536028747135266249
     If From=Euler-Mascheroni
          val:=0.57721566490153286060651209008240243
     If From=Golden Ratio
          val:=1.61803398874989484820458683436563811
     If From=Silver Ratio
          val:=2.4142135623730949
     If From=Feigenbaum 1
          val:=4.66920160910299067185320382046620161
     If From=Feigenbaum 2
          val:=4.66920160910299067185320382046620161
     If From=Twin Prime constant
          val:=0.66016181584686957392781211001455577
     If From=Meissel-Mertens
          val:=0.26149721284764278375542683860869585
     If From=Laplace limit
          val:=0.66274341934918158097474209710925290
     If From=Apéry's constant
          val:=1.20205690315959428539973816151144999
     If From=Lévy's constant
          val:=3.27582291872181115978768188245384386
     If From=Omega constant
          val:= 0.56714329040978387299996866221035555
     If From=Plastic Constant
          val:=1.32471795724474602596090885447809734
     If From=Brun's Twin Prime
          val:=1.9021605823
     If From=Brun's Quad Prime
          val:=0.8705883800
     If From=Khinchin's constant
          val:=2.68545200106530644530971483548179569
     If From=Fransén-Robinson
          val:=2.80777024202851936522150118655777293
     If From=Parabolic Constant
          val:=2.29558714939263807403429804918949039
               }

gosub getter

val := val + 0
guicontrol,, rez, %val%
return


;=================================================================================
;     Mem and Memrec routines hold 5 user selected variables for copying and
;     pasting between Unit Converter and Calc tabs
;=================================================================================
mem:
Gui, submit, nohide
If mem = Memory1
     Mem1=%rez%
If mem = Memory2
     Mem2=%rez%
If mem = Memory3
     Mem3=%rez%
If mem = Memory4
     Mem4=%rez%
If mem = Memory5
     Mem5=%rez%
return

memrec:
Gui, submit, nohide
If memrec = Memory1
     Pastemem=%Mem1%
If memrec = Memory2
     Pastemem=%Mem2%
If memrec = Memory3
     Pastemem=%Mem3%
If memrec = Memory4
     Pastemem=%Mem4%
If memrec = Memory5
     Pastemem=%Mem5%
coded=%code%%Pastemem%
Guicontrol,, code, %coded%
Guicontrol,focus,code
Send, {END}
gosub buttonevaluate
Return


;=================================================================================
;     Swap is a little easter egg that switches the from and to units in the
;     unit converter when "To:" is clicked. 
;     - Doesn't work with physical or mathematical constant sections.
;===================================================================================
swap: 
If units=Physical Constants
   return
If units=Mathematical Constants
   return
Gui, submit, nohide
GuiControlGet, From, , Combobox6
GuiControlGet, To, , Combobox7
ControlGet, List ,List, List, Combobox6
StringReplace, List, List, `n, |, all
List .= "|"
StringReplace, FromList, List, %From%|, %From%||
StringReplace, ToList, List, %To%|, %To%||
GuiControl, , Combobox6, |
GuiControl, , Combobox6, %ToList%
GuiControl, , Combobox7, |
GuiControl, , Combobox7, %FromList%
gosub calculate
Return


;============================================================
;   CALCULATOR BUTTONS (calc tab)
;============================================================
ButtonClear:
   Gui Submit, Nohide
   Guicontrol,, code,
   Guicontrol,, res,
   Guicontrol,focus,code
Return

ButtonEvaluate:                                ; Alt-V or Enter: evaluate expression
   Gui Submit, NoHide
   if pre4
      SetFormat, float, %RegP%E
   else
      SetFormat, float, %RegP%
   coded:=code
   GuiControl,,Res,% Eval(coded)
   Guicontrol,focus,code
   Send, {END}
return

Button(:
   Gui Submit, Nohide
   codeadd=%code%(
   Guicontrol,, code, %codeadd%
   Guicontrol,focus,code
   Send, {END}   
Return   

Button):
   Gui Submit, Nohide
   codeadd=%code%)
   Guicontrol,, code, %codeadd%
   Guicontrol,focus,code
   Send, {END}   
Return

Buttonx:
   Gui Submit, Nohide
   codeadd=%code%*
   Guicontrol,, code, %codeadd%
   Guicontrol,focus,code
   Send, {END}   
Return   

Button/:
   Gui Submit, Nohide
   codeadd=%code%/
   Guicontrol,, code, %codeadd%
   Guicontrol,focus,code
   Send, {END}   
Return

Button+:
   Gui Submit, Nohide
   codeadd=%code%+
   Guicontrol,, code, %codeadd%
   Guicontrol,focus,code
   Send, {END}   
Return

Button-:
   Gui Submit, Nohide
   codeadd=%code%-
   Guicontrol,, code, %codeadd%
   Guicontrol,focus,code
   Send, {END}
Return

ButtonExp:
   Gui Submit, Nohide
   codeadd=%code%**
   Guicontrol,, code, %codeadd%
   Guicontrol,focus,code
   Send, {END}
Return
;============================================================
; END CALCULATOR BUTTONS                       
;============================================================



;=============================================================================================================
;=============================================================================================================
;=============================================================================================================
;     Expression Evaluation code by Laszlo at http://www.autohotkey.com/forum/viewtopic.php?t=17058
;
;     ALL THE CODE FROM HERE AND BELOW IS ONLY FOR CALCULATOR / EXPRESSION EVALUATOR!!
;     - No more commenting from here to bottom
;=============================================================================================================
xe := 2.718281828459045, xpi := 3.141592653589793

SetFormat Float, 0.16e                         ; max precise AHK internal format

ButtonHelp:                                    ; Alt-H

If units=CALCULATOR
{
   MsgBox,                                     ; list of shortcuts, functions
(
Shortcut commands:
   Alt-V, Enter: evaluate expression
   Alt-c, Clear: clear calculator

Functions (AHK's and the following):

   MONSTER Version 1.1 (needs AHK 1.0.46.12+)
   EVALUATE ARITHMETIC EXPRESSIONS containing HEX, Binary ('1001), scientific numbers (1.2e+5)
   (..); variables, constants: e, pi;
   (? :); logicals ||; &&; relationals =,<>; <,>,<=,>=; user operators GCD,MIN,MAX,Choose;
   |; ^; &; <<, >>; +, -; *, /, \ (or  = mod); ** (or @ = power); !,~;
   
   Functions AHK's and Abs|Ceil|Exp|Floor|Log|Ln|Round|Sqrt|Sin|Cos|Tan|ASin|ACos|ATan|SGN|Fib|fac;
   User defined functions: f(x) := expr;

Math Constants:
   pi  = pi       e   = e

)
}
Return

Eval(x) {                              ; non-recursive PRE/POST PROCESSING: I/O forms, numbers, ops, ";"
   Local FORM, FormF, FormI, i, W, y, y1, y2, y3, y4
   FormI := A_FormatInteger, FormF := A_FormatFloat

   SetFormat Integer, D                ; decimal intermediate results!
   RegExMatch(x, "\$(b|h|x|)(\d*[eEgG]?)", y)
   FORM := y1, W := y2                 ; HeX, Bin, .{digits} output format
   SetFormat FLOAT, 0.16e              ; Full intermediate float precision
   StringReplace x, x, %y%             ; remove $..
   Loop
      If RegExMatch(x, "i)(.*)(0x[a-f\d]*)(.*)", y)
         x := y1 . y2+0 . y3           ; convert hex numbers to decimal
      Else Break
   Loop
      If RegExMatch(x, "(.*)'([01]*)(.*)", y)
         x := y1 . FromBin(y2) . y3    ; convert binary numbers to decimal: sign = first bit
      Else Break
   x := RegExReplace(x,"(^|[^.\d])(\d+)(e|E)","$1$2.$3") ; add missing '.' before E (1e3 -> 1.e3)
                                       ; literal scientific numbers between ‘ and ’ chars
   x := RegExReplace(x,"(\d*\.\d*|\d)([eE][+-]?\d+)","‘$1$2’")

   StringReplace x, x,`%, \, All       ; %  -> \ (= MOD)
   StringReplace x, x, **,@, All       ; ** -> @ for easier process
   StringReplace x, x, +, ±, All       ; ± is addition
   x := RegExReplace(x,"(‘[^’]*)±","$1+") ; ...not inside literal numbers
   StringReplace x, x, -, ¬, All       ; ¬ is subtraction
   x := RegExReplace(x,"(‘[^’]*)¬","$1-") ; ...not inside literal numbers

   Loop Parse, x, `;
      y := Eval1(A_LoopField)          ; work on pre-processed sub expressions
                                       ; return result of last sub-expression (numeric)
   If FORM = b                         ; convert output to binary
      y := W ? ToBinW(Round(y),W) : ToBin(Round(y))
   Else If (FORM="h" or FORM="x") {
      if pre4
         SetFormat, float, %RegP%E
      else
         SetFormat, float, %RegP%
;      SetFormat Integer, Hex           ; convert output to hex
      y := Round(y) + 0
   }
   Else {
      W := W="" ? "0.6g" : "0." . W    ; Set output form, Default = 6 decimal places
      if pre4
         SetFormat, float, %RegP%E
      else
         SetFormat, float, %RegP%
;      SetFormat FLOAT, %W%
      y += 0.0
   }
   if pre4
      SetFormat, float, %RegP%E
   else
      SetFormat, float, %RegP%
;   SetFormat Integer, %FormI%          ; restore original formats
;   SetFormat FLOAT,   %FormF%
   Return y
}

Eval1(x) {                             ; recursive PREPROCESSING of :=, vars, (..) [decimal, no ";"]
   Local i, y, y1, y2, y3
                                       ; save function definition: f(x) := expr
   If RegExMatch(x, "(\S*?)\((.*?)\)\s*:=\s*(.*)", y) {
      f%y1%__X := y2, f%y1%__F := y3
      Return
   }
                                       ; execute leftmost ":=" operator of a := b := ...
   If RegExMatch(x, "(\S*?)\s*:=\s*(.*)", y) {
      y := "x" . y1                    ; user vars internally start with x to avoid name conflicts
      Return %y% := Eval1(y2)
   }
                                       ; here: no variable to the left of last ":="
   x := RegExReplace(x,"([\)’.\w]\s+|[\)’])([a-z_A-Z]+)","$1«$2»")  ; op -> «op»

   x := RegExReplace(x,"\s+")          ; remove spaces, tabs, newlines

   x := RegExReplace(x,"([a-z_A-Z]\w*)\(","'$1'(") ; func( -> 'func'( to avoid atan|tan conflicts

   x := RegExReplace(x,"([a-z_A-Z]\w*)([^\w'»’]|$)","%x$1%$2") ; VAR -> %xVAR%
   x := RegExReplace(x,"(‘[^’]*)%x[eE]%","$1e") ; in numbers %xe% -> e
   x := RegExReplace(x,"‘|’")          ; no more need for number markers
   Transform x, Deref, %x%             ; dereference all right-hand-side %var%-s

   Loop {                              ; find last innermost (..)
      If RegExMatch(x, "(.*)\(([^\(\)]*)\)(.*)", y)
         x := y1 . Eval@(y2) . y3      ; replace (x) with value of x
      Else Break
   }

   Return Eval@(x)
}

Eval@(x) {                             ; EVALUATE PRE-PROCESSED EXPRESSIONS [decimal, NO space, vars, (..), ";", ":="]
   Local i, y, y1, y2, y3, y4

   If x is number                      ; no more operators left
      Return x
                                       ; execute rightmost ?,: operator
   RegExMatch(x, "(.*)(\?|:)(.*)", y)
   IfEqual y2,?,  Return Eval@(y1) ? Eval@(y3) : ""
   IfEqual y2,:,  Return ((y := Eval@(y1)) = "" ? Eval@(y3) : y)

   StringGetPos i, x, ||, R            ; execute rightmost || operator
   IfGreaterOrEqual i,0, Return Eval@(SubStr(x,1,i)) || Eval@(SubStr(x,3+i))
   StringGetPos i, x, &&, R            ; execute rightmost && operator
   IfGreaterOrEqual i,0, Return Eval@(SubStr(x,1,i)) && Eval@(SubStr(x,3+i))
                                       ; execute rightmost =, <> operator
   RegExMatch(x, "(.*)(?<![\<\>])(\<\>|=)(.*)", y)
   IfEqual y2,=,  Return Eval@(y1) =  Eval@(y3)
   IfEqual y2,<>, Return Eval@(y1) <> Eval@(y3)
                                       ; execute rightmost <,>,<=,>= operator
   RegExMatch(x, "(.*)(?<![\<\>])(\<=?|\>=?)(?![\<\>])(.*)", y)
   IfEqual y2,<,  Return Eval@(y1) <  Eval@(y3)
   IfEqual y2,>,  Return Eval@(y1) >  Eval@(y3)
   IfEqual y2,<=, Return Eval@(y1) <= Eval@(y3)
   IfEqual y2,>=, Return Eval@(y1) >= Eval@(y3)
                                       ; execute rightmost user operator (low precedence)
   RegExMatch(x, "i)(.*)«(.*?)»(.*)", y)
   IfEqual y2,choose,Return Choose(Eval@(y1),Eval@(y3))
   IfEqual y2,Gcd,   Return GCD(   Eval@(y1),Eval@(y3))
   IfEqual y2,Min,   Return (y1:=Eval@(y1)) < (y3:=Eval@(y3)) ? y1 : y3
   IfEqual y2,Max,   Return (y1:=Eval@(y1)) > (y3:=Eval@(y3)) ? y1 : y3

   StringGetPos i, x, |, R             ; execute rightmost | operator
   IfGreaterOrEqual i,0, Return Eval@(SubStr(x,1,i)) | Eval@(SubStr(x,2+i))
   StringGetPos i, x, ^, R             ; execute rightmost ^ operator
   IfGreaterOrEqual i,0, Return Eval@(SubStr(x,1,i)) ^ Eval@(SubStr(x,2+i))
   StringGetPos i, x, &, R             ; execute rightmost & operator
   IfGreaterOrEqual i,0, Return Eval@(SubStr(x,1,i)) & Eval@(SubStr(x,2+i))
                                       ; execute rightmost <<, >> operator
   RegExMatch(x, "(.*)(\<\<|\>\>)(.*)", y)
   IfEqual y2,<<, Return Eval@(y1) << Eval@(y3)
   IfEqual y2,>>, Return Eval@(y1) >> Eval@(y3)
                                       ; execute rightmost +- (not unary) operator
   RegExMatch(x, "(.*[^!\~±¬\@\*/\\])(±|¬)(.*)", y) ; lower precedence ops already handled
   IfEqual y2,±,  Return Eval@(y1) + Eval@(y3)
   IfEqual y2,¬,  Return Eval@(y1) - Eval@(y3)
                                       ; execute rightmost */% operator
   RegExMatch(x, "(.*)(\*|/|\\)(.*)", y)
   IfEqual y2,*,  Return Eval@(y1) * Eval@(y3)
   IfEqual y2,/,  Return Eval@(y1) / Eval@(y3)
   IfEqual y2,\,  Return Mod(Eval@(y1),Eval@(y3))
                                       ; execute rightmost power
   StringGetPos i, x, @, R
   IfGreaterOrEqual i,0, Return Eval@(SubStr(x,1,i)) ** Eval@(SubStr(x,2+i))
                                       ; execute rightmost function, unary operator
   If !RegExMatch(x,"(.*)(!|±|¬|~|'(.*)')(.*)", y)
      Return x                         ; no more function (y1 <> "" only at multiple unaries: --+-)
   IfEqual y2,!,Return Eval@(y1 . !y4) ; unary !
   IfEqual y2,±,Return Eval@(y1 .  y4) ; unary +
   IfEqual y2,¬,Return Eval@(y1 . -y4) ; unary - (they behave like functions)
   IfEqual y2,~,Return Eval@(y1 . ~y4) ; unary ~
   If IsLabel(y3)
      GoTo %y3%                        ; built-in functions are executed last: y4 is number
   Return Eval@(y1 . Eval1(RegExReplace(f%y3%__F, f%y3%__X, y4))) ; user defined function
Abs:
   Return Eval@(y1 . Abs(y4))
Ceil:
   Return Eval@(y1 . Ceil(y4))
Exp:
   Return Eval@(y1 . Exp(y4))
Floor:
   Return Eval@(y1 . Floor(y4))
Log:
   Return Eval@(y1 . Log(y4))
Ln:
   Return Eval@(y1 . Ln(y4))
Round:
   Return Eval@(y1 . Round(y4))
Sqrt:
   Return Eval@(y1 . Sqrt(y4))
Sin:
   Return Eval@(y1 . Sin(y4))
Cos:
   Return Eval@(y1 . Cos(y4))
Tan:
   Return Eval@(y1 . Tan(y4))
ASin:
   Return Eval@(y1 . ASin(y4))
ACos:
   Return Eval@(y1 . ACos(y4))
ATan:
   Return Eval@(y1 . ATan(y4))
Sgn:
   Return Eval@(y1 . (y4>0)) ; Sign of x = (x>0)-(x<0)
Fib:
   Return Eval@(y1 . Fib(y4))
Fac:
   Return Eval@(y1 . Fac(y4))
}

ToBin(n) {      ; Binary representation of n. 1st bit is SIGN: -8 -> 1000, -1 -> 1, 0 -> 0, 8 -> 01000
   Return n=0||n=-1 ? -n : ToBin(n>>1) . n&1
}
ToBinW(n,W=8) { ; LS W-bits of Binary representation of n
   Loop %W%     ; Recursive (slower): Return W=1 ? n&1 : ToBinW(n>>1,W-1) . n&1
      b := n&1 . b, n >>= 1
   Return b
}
FromBin(bits) { ; Number converted from the binary "bits" string, 1st bit is SIGN
   n = 0
   Loop Parse, bits
      n += n + A_LoopField
   Return n - (SubStr(bits,1,1)<<StrLen(bits))
}

GCD(a,b) {      ; Euclidean GCD
   Return b=0 ? Abs(a) : GCD(b, mod(a,b))
}
Choose(n,k) {   ; Binomial coefficient
   p := 1, i := 0, k := k < n-k ? k : n-k
   Loop %k%                   ; Recursive (slower): Return k = 0 ? 1 : Choose(n-1,k-1)*n//k
      p *= (n-i)/(k-i), i+=1  ; FOR INTEGERS: p *= n-i, p //= ++i
   Return Round(p)
}

Fib(n) {        ; n-th Fibonacci number (n < 0 OK, iterative to avoid globals)
   a := 0, b := 1
   Loop % abs(n)-1
      c := b, b += a, a := c
   Return n=0 ? 0 : n>0 || n&1 ? b : -b
}
fac(n) {        ; n!
   Return n<2 ? 1 : n*fac(n-1)
}
