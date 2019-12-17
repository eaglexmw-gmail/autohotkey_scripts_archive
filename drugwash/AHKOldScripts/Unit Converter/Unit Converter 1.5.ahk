; by fuzz54 http://www.autohotkey.com/forum/viewtopic.php?t=42809
; v1.3 (4-7-09) modded by Drugwash
; v1.4 (4-9-09) - changed format/precision menu from Drugwash mod to radios and moved to bottom
;               - changed to allow different decimals for scientific format
;               - added units Angstrom, lightyear, parsec, and AU to distance and cm of water to pressure
;
; v1.5 (4-12-09) - added section to list common physical constants.  made GUI wider as a result.
;                - added an Easter egg coded by HugoV.  when To: is clicked the
;                  from and to units swap.  doesn't work with physical constants section. 
;                  Most of the constants are very small and show up the best in scientific format.
;


Gui, Margin, -2, 3
Gui, Add, GroupBox, x-5 y-8 w298 h91 cblack,
Gui, Add, GroupBox, x-5 y-7 w298 h91 cblack,
Gui, Add, Radio, x10 y87 h20 checked greg, Regular
Gui, Add, Radio, x90 y87 h20 gsci, Scientific
Gui, Add, Edit, x180 y87 w35 h18 gRpre vRP Hidden,
Gui, Add, UpDown, Range1-9 0x80, 2
Gui, Add, Text, x+3 yp+3 Hide, decimals

Gui, Add, DropDownList, x75 y4 w144 h20 r22 gunits vunits, Acceleration||Angle|Area|Density|Distance|Electric Current|Energy|Force|Heat Capacity|Heat Transfer Coefficient|Mass|Power|Pressure|Specific Heat|Speed|Temperature|Thermal Conductivity|Time|Volume|======================|Physical Constants

Gui, Add, DropDownList, x6 y28 w125 h20 r30 vfrom gcalc,
Gui, Add, Text, x138 y28 w17 h20 gswap +Center, To:
Gui, Add, DropDownList, x161 y28 w125 h20 r30 vto gcalc,

Gui, Add, Edit, x6 y48 w125 h20 gcalc vtot,
Gui, add, updown,range1-1000 +wrap 0x80,1
Gui, Add, Text, x131 y48 w30 h20 +Center, =
Gui, Add, Edit, x161 y48 w125 h20 vres +readonly,

gosub, units
gosub reg
Gui, Show, , Converter
Return

swap:
Gui, submit, nohide
GuiControlGet, From, , Combobox2
GuiControlGet, To, , Combobox3
ControlGet, List ,List, List, Combobox2
StringReplace, List, List, `n, |, all
List .= "|"
StringReplace, FromList, List, %From%|, %From%||
StringReplace, ToList, List, %To%|, %To%||
GuiControl, , Combobox2, |
GuiControl, , Combobox2, %ToList%
GuiControl, , Combobox3, |
GuiControl, , Combobox3, %FromList%
gosub calc
Return

reg:
GuiControl, Show, RP
GuiControl, Show, msctls_updown321
GuiControl, Show, Static1
pre = 0
gosub calc
return

sci:
GuiControl, Show, RP
GuiControl, Show, msctls_updown321
GuiControl, Show, Static1
pre = 1
gosub calc
return

Rpre:
Gui, submit, nohide
SetFormat, Float, 0.1
RegP := RP/10
SetFormat, Float, %RegP%
gosub calc
return

units:
Gui, submit, nohide
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
Guicontrol,, from, lb/cubic inch||lb/cubic foot|kg/cubic meter|slugs/cubic foot
Guicontrol,, to, |
Guicontrol,, to, lb/cubic inch||lb/cubic foot|kg/cubic meter|slugs/cubic foot
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
Guicontrol,, from, Watt/m-K||kiloWatt/m-K|BTU/hr-ft-F|BTU-in/hr-ft2-F|cal/s-cm-C
Guicontrol,, to, |
Guicontrol,, to, Watt/m-K||kiloWatt/m-K|BTU/hr-ft-F|BTU-in/hr-ft2-F|cal/s-cm-C
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
Guicontrol,, from, m2||cm2|mm2|micron2|in2|ft2|yd2|mil2
Guicontrol,, to, |
Guicontrol,, to, m2||cm2|mm2|micron2|in2|ft2|yd2|mil2
}

if units=Volume
{
Guicontrol,, from, |
Guicontrol,, from, cubic meters||cubic centimeters|cubic millimeters|cubic inches|cubic feet|cubic yards|ounce|pint|quart|tsp|tbsp|liter
Guicontrol,, to, |
Guicontrol,, to, cubic meters||cubic centimeters|cubic millimeters|cubic inches|cubic feet|cubic yards|ounce|pint|quart|tsp|tbsp|liter
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

if units=Physical Constants
{
Guicontrol,, from, |
Guicontrol,, from, Speed of Light (m/s)||Gravitation (m^3/kg-s2)|Planck's Constant (J-s)|magnetic constant (N/A2)|electric constant (F/m)|Coulomb cons. (N-m2/C2)|elementary charge (C)|Electron Mass (kg)|Proton Mass (kg)|fine structure constant|Rydberg constant (1/m)|atomic mass unit (kg)|Avogadro's # (1/mol)|Boltzmann constant (J/K)|Faraday constant (C/mol)|gas constant (J/K-mol)|Stefan-Boltz. (W/m2-K^4)
Guicontrol,, to, |
Guicontrol,, to, Value||
}

gosub, calc
return

calc:
gui, submit, nohide

if pre
   SetFormat, float, %RegP%E
else
   SetFormat, float, %RegP%

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

;Volume from
If From=cubic meters
From=1.0
If From=cubic centimeters
From=0.000001
If From=cubic millimeters
From=1.0E-9
If From=cubic inches
From=0.000016387064
If From=cubic feet
From=0.028316846592
If From=cubic yards
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
If To=cubic meters
To=1.0
If To=cubic centimeters
To=0.000001
If To=cubic millimeters
To=1.0E-9
If To=cubic inches
To=0.000016387064
If To=cubic feet
To=0.028316846592
If To=cubic yards
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
If From=Ton (Uk)
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
If To=Ton (Uk)
To=2240
If To=slugs
To=14.593903

;density from
If From=lb/cubic inch
From=1
If From=lb/cubic foot
From=0.000578703
If From=Kg/cubic meter
From=3.6127E-5
If From=slugs/cubic foot
From=515.31788206
;density to
If To=lb/cubic inch
To=1
If To=lb/cubic foot
To=0.000578703
If To=Kg/cubic meter
To=3.6127E-5
If To=slugs/cubic foot
To=515.31788206

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
     If From=Gravitation (m^3/kg-s2)
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
       
if pre
   SetFormat, float, %RegP%E
else
   SetFormat, float, %RegP%

val := val + 0
guicontrol,, res, %val%
return

GuiClose:
ExitApp
