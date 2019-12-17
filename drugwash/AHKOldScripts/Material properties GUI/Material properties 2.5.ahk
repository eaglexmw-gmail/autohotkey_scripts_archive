
; v2.4 (11-20-09)
;     Direct questions/requests to Jake at fuzz54@yahoo.com
;
;     This new release of the Material Property Database script is a major
;     overhaul of the previous script.  Changes before this version are ommitted.
;     There's several new features like an alphabetical material list, real time
;     updating of the drop down lists as materials are added or deleted,
;     a MAT1 material card export option for NASTRAN users, and indexing of the
;     number formats and unit system preferences upon script close.         
;
; v2.5 (11-25-09)
;     Fixed an error with the Material Edit and Delete functions when ten or more
;     materials are databased.


;=======================================================================================
;     Conversion Constants from Metric to English  (values in .ini are always in metric)
;=======================================================================================
Setformat,Float,0.16E
;METRIC emod=GPa smod=GPa density=kg/m^3 yield=MPa CTE=µm/m-C Conduct=W/m-K Specific=J/kg-C
;ENGLISH emod=ksi*10^3 smod=ksi*10^3 density=lb/in^3 yield=ksi CTE=µin/in-F Conduct=BTU/hr-in-F Specific=BTU/lb-F
;CONVERSION Metric==>English
emod_convert:=.145037,smod_convert:=.145037,density_convert:=0.00003612700,yield_convert:=.145037,CTE_convert:=0.555556,Conduct_convert:=0.04818133759,Specific_convert:=.0002388459


;=========================================================================================
;     INI File Check or Creation
;     - In the .ini file material properties should be in metric units listed above
;       although the user should never have to edit the .ini file manually
;     - If Material-Properties.ini doesn't exist then one is generated with a few materials
;       to get the user started
;=========================================================================================
;

IfNotExist,Mat-Props-v2.5.ini
     {ini=
     (
[Initialize_States]
SortState=0
system_mat=English
system_mat_two=English
RP=2
Scientific=0
[Names]
name1=Steel (304 SS)
name2=Aluminum (6061-T6)
name3=Titanium (6Al-4V)
name4=Beryllium (I220)
name5=Invar
name6=Copper
name7=Gold
name8=Silver
name9=Iron
name10=Glass
name11=Balsa Wood
[Properties]
Elastic1=195.
Shear1=86.
Poisson1=0.29
Density1=8000.
Yield1=215.
CTE1=17.3
Conductivity1=16.2
Specific1=500.
Source1=Matweb.com
Elastic2=68.9
Shear2=26.
Poisson2=0.33
Density2=2700.
Yield2=276.
CTE2=23.6
Conductivity2=167.0
Specific2=900.
Source2=Matweb.com
Elastic3=113.8
Shear3=44.
Poisson3=0.342
Density3=4430.
Yield3=880.
CTE3=8.6
Conductivity3=6.7
Specific3=530.
Source3=Matweb.com
Elastic4=303.
Shear4=135.
Poisson4=0.13
Density4=1844.
Yield4=345.
CTE4=11.5
Conductivity4=216.
Specific4=1930.
Source4=Matweb.com
Elastic5=148.
Shear5=56.
Poisson5=0.29
Density5=8137.89
Yield5=241.3
CTE5=1.3
Conductivity5=10.15
Specific5=520.
Source5=Matweb.com
Elastic6=110.
Shear6=46.
Poisson6=.343
Density6=8960.
Yield6=33.3
CTE6=16.4
Conductivity6=385.
Specific6=385.
Source6=Matweb.com
Elastic7=77.2
Shear7=27.2
Poisson7=0.42
Density7=19320.
Yield7=100.
CTE7=14.4
Conductivity7=301.
Specific7=132.3
Source7=Matweb.com
Elastic8=76.
Shear8=27.8
Poisson8=0.38
Density8=10491.
Yield8=117.
CTE8=19.6
Conductivity8=419.
Specific8=234.
Source8=Matweb.com
Elastic9=200.
Shear9=77.5
Poisson9=0.291
Density9=7870.
Yield9=50.
CTE9=12.2
Conductivity9=76.2
Specific9=440.
Source9=Matweb.com
Elastic10=68.
Shear10=28.
Poisson10=0.19
Density10=2180.
Yield10=34.
CTE10=0.75
Conductivity10=1.38
Specific10=750.
Source10=Matweb.com
Elastic11=4.099
Shear11=0.166
Poisson11=0.33
Density11=155.
Yield11=20.
CTE11=5.
Conductivity11=0.064
Specific11=2900.
Source11=Internet - Various
     )
     FileAppend,%ini%,Mat-Props-v2.5.ini
     }

;=======================================================================================
;     Drop Down List created from .ini file.  This DDL is used on first 3 tabs.
;=======================================================================================
droplist=
Loop,1000
     {
     Iniread,name%A_Index%,Mat-Props-v2.5.ini,Names,Name%A_Index%,0
     currentname:=name%A_Index%
     If currentname>0
          {
          matnum+=1
          }
     Else
          continue
     droplist=%droplist%%currentname%|
     }
holding=%droplist%
droplist2=|%droplist%
;=======================================================================================
;     START GUI CONTROLS DEFINITION
;=======================================================================================
Gui,Font,s10
Gui, Add, Tab2,x-4 y0 w510 h350 gTab_Updater vTab_Updater,Material Properties|Add/Edit Material|Compare Merit Figures|Write MAT1 Card
Gui,Font

;=======================================================================================
;     Material Properties GUI tab
;=======================================================================================
Gui, Tab, 1
Gui, margin, -4, -4

;Number formatting, decimals, and groupbox dividers
Gui, Add, GroupBox, x-5 y260 w512 h90 cblack,
Gui, Add, GroupBox, x-5 y261 w512 h90 cblack,
Gui, Add, Radio, x105 y280 h20 gRegular vRegular checked, Regular
Gui, Add, Radio, x105 y300 h20 gScientific vScientific, Scientific
Gui, Add, Edit, x185 y290 w40 h20 gPrecision_Update vRP,
Gui, Add, UpDown, Range0-5 vdec 0x80, 2
Gui, Add, Text, x230 y292, decimals

Gui, Add, checkbox, x300 y292 gsorter vsorted, alphabetic sorting
 
Gui, Add, Dropdownlist, x110 y32 w210 h20 r1000 gDisplay_Update vmat choose1, %droplist%
Gui, Add, DropDownList, x328 y32 w65 h20 gsystemshow vsystem_mat r2, English||Metric

Gui, Add, Text, x110 y62 h20, Elastic Modulus (E)
Gui, Add, Text, x110 y83 h20, Shear Modulus (G)
Gui, Add, Text, x110 y104 h20, Poisson's Ratio (v)
Gui, Add, Text, x110 y125 h20, Density (p)
Gui, Add, Text, x110 y146 h20, Yield Strength (Yield)
Gui, Add, Text, x110 y167 h20, CTE (CTE)
Gui, Add, Text, x110 y188 h20, Thermal Conductivity (K)
Gui, Add, Text, x110 y209 h20, Specific Heat (Cp)
Gui, Add, Text, x110 y236 h20, Source of Information

Gui, Add, Edit, x230 y60 h20 w90 vemod,
Gui, Add, Edit, x230 y81 h20 w90 vsmod,
Gui, Add, Edit, x230 y102 h20 w90 vpoisson,
Gui, Add, Edit, x230 y123  h20 w90 vdensity,
Gui, Add, Edit, x230 y144  h20 w90 vyield,
Gui, Add, Edit, x230 y165  h20 w90 vcte,
Gui, Add, Edit, x230 y186  h20 w90 vconduct,
Gui, Add, Edit, x230 y207  h20 w90 vspecific,
Gui, Add, Edit, x230 y233 h20 w90 vsource,

Gui, Add, Text, x330 y62 h20 hidden vmet1, GPa
Gui, Add, Text, x330 y83 h20 hidden vmet2, GPa
Gui, Add, Text, x330 y125 h20 hidden vmet3, kg/m3
Gui, Add, Text, x330 y146 h20 hidden vmet4, MPa
Gui, Add, Text, x330 y167 h20 hidden vmet5, µm/m-C
Gui, Add, Text, x330 y188 h20 hidden vmet6, W/m-K
Gui, Add, Text, x330 y209 h20 hidden vmet7, J/kg-C

Gui, Add, Text, x330 y62 h20 veng1, ksi*103
Gui, Add, Text, x330 y83 h20 veng2, ksi*103
Gui, Add, Text, x330 y125 h20 veng3, lb/in3
Gui, Add, Text, x330 y146 h20 veng4, ksi
Gui, Add, Text, x330 y167 h20 veng5, µin/in-F
Gui, Add, Text, x330 y188 h20 veng6, BTU/hr-in-F
Gui, Add, Text, x330 y209 h20 veng7, BTU/lb-F


;=======================================================================================
;     Add/Edit/Delete Material tab
;=======================================================================================
Gui, Tab, 2

;Number formatting, decimals, and groupbox dividers

Gui, Add, Radio,x110 y30 vadd checked gmatadd,Add
Gui, Add, Radio,x160 y30 vedit gmatedit,Edit
Gui, Add, Radio,x205 y30 vdel gmatdel,Delete Material

Gui, Add, Text, x110 y55 h17,Specify the Unit System for Material:
Gui, Add, DropDownList, x285 y52 w65 h20 gsystemshow vsystem_mat_two r2, English||Metric

Gui, Add, Text, x110 y82 h20, Elastic Modulus (E)
Gui, Add, Text, x110 y103 h20, Shear Modulus (G)
Gui, Add, Text, x110 y124 h20, Poisson's Ratio (v)
Gui, Add, Text, x110 y145 h20, Density (p)
Gui, Add, Text, x110 y166 h20, Yield Strength (Yield)
Gui, Add, Text, x110 y187 h20, CTE (CTE)
Gui, Add, Text, x110 y208 h20, Thermal Conductivity (K)
Gui, Add, Text, x110 y229 h20, Specific Heat (Cp)
Gui, Add, Text, x110 y253 h20, Source of Information

Gui, Add, Edit, x230 y80 h20 w90 vemodnew gemodnew,
Gui, Add, Edit, x230 y101 h20 w90 vsmodnew gsmodnew,
Gui, Add, Edit, x230 y122 h20 w90 vpoissonnew gpoissonnew,
Gui, Add, Edit, x230 y143  h20 w90 vdensitynew gdensitynew,
Gui, Add, Edit, x230 y164  h20 w90 vyieldnew gyieldnew,
Gui, Add, Edit, x230 y185  h20 w90 vctenew gctenew,
Gui, Add, Edit, x230 y206  h20 w90 vconductnew gconductnew,
Gui, Add, Edit, x230 y227  h20 w90 vspecificnew gspecificnew,
Gui, Add, Edit, x230 y251 h20 w90 vsourcenew gsourcenew,

Gui, Add, Text, x330 y82 h20 hidden vmet1new, GPa
Gui, Add, Text, x330 y103 h20 hidden vmet2new, GPa
Gui, Add, Text, x330 y145 h20 hidden vmet3new, kg/m3
Gui, Add, Text, x330 y166 h20 hidden vmet4new, MPa
Gui, Add, Text, x330 y187 h20 hidden vmet5new, µm/m-C
Gui, Add, Text, x330 y208 h20 hidden vmet6new, W/m-K
Gui, Add, Text, x330 y229 h20 hidden vmet7new, J/kg-C
                 
Gui, Add, Text, x330 y82 h20 veng1new, ksi*103
Gui, Add, Text, x330 y103 h20 veng2new, ksi*103
Gui, Add, Text, x330 y145 h20 veng3new, lb/in3
Gui, Add, Text, x330 y166 h20 veng4new, ksi
Gui, Add, Text, x330 y187 h20 veng5new, µin/in-F
Gui, Add, Text, x330 y208 h20 veng6new, BTU/hr-in-F
Gui, Add, Text, x330 y229 h20 veng7new, BTU/lb-F

Gui, Add, Text, x110 y278 h17,Specify Material Name
Gui, Add, Dropdownlist, x230 y275 w210 h20 r1000 hidden vmatedit gDisplay_Update choose1, %droplist%
Gui, Add, Edit, x230 y275 h20 vnamenew,
Gui, Add, Button, x165 y315 h20,Add/Edit/Delete Material

;=======================================================================================
;     Figures of Merit Comparison tab
;=======================================================================================
Gui, Tab, 3

Gui, Add, Text, x134 y35 h20 w65,Material 1
Gui, Add, Text, x134 y60 h20 w65,Material 2
Gui, Add, Text, x134 y83 h20 w65,Material 3

Gui, Font, cblue s10, Tahoma
Gui, Add, Text, x107 y105 h20 w95,Normalize to:
Gui, Font

Gui, Add, DropDownList, x402 y104 w65 h20 gcompare vsystem_mer r2, English||Metric

Gui, Add, Dropdownlist, x190 y32 w205 h20 r1000 gcompare vcompare1, %droplist2%
Gui, Add, Dropdownlist, x190 y56 w205 h20 r1000 gcompare vcompare2, %droplist2%
Gui, Add, Dropdownlist, x190 y80 w205 h20 r1000 gcompare vcompare3, %droplist2%

Gui, Add, Dropdownlist, x190 y104 w205 h20 r1000 gcompare vnormalize, %droplist2%

Gui, Add, Text, x200 y133 h20 w65,Material 1
Gui, Add, Text, x270 y133 h20 w65,Material 2
Gui, Add, Text, x340 y133 h20 w65,Material 3

Gui, Add, Edit, x190 y150 h20 w65 vmeritc1,
Gui, Add, Edit, x190 y171 h20 w65 vmeritc2,
Gui, Add, Edit, x190 y192 h20 w65 vmeritc3,
Gui, Add, Edit, x190 y213 h20 w65 vmeritc4,
Gui, Add, Edit, x190 y234 h20 w65 vmeritc5,
Gui, Add, Edit, x190 y255 h20 w65 vmeritc6,
Gui, Add, Edit, x190 y276 h20 w65 vmeritc7,

Gui, Add, Edit, x260 y150 h20 w65 vmeritc11,
Gui, Add, Edit, x260 y171 h20 w65 vmeritc12,
Gui, Add, Edit, x260 y192 h20 w65 vmeritc13,
Gui, Add, Edit, x260 y213 h20 w65 vmeritc14,
Gui, Add, Edit, x260 y234 h20 w65 vmeritc15,
Gui, Add, Edit, x260 y255 h20 w65 vmeritc16,
Gui, Add, Edit, x260 y276 h20 w65 vmeritc17,

Gui, Add, Edit, x330 y150 h20 w65 vmeritc21,
Gui, Add, Edit, x330 y171 h20 w65 vmeritc22,
Gui, Add, Edit, x330 y192 h20 w65 vmeritc23,
Gui, Add, Edit, x330 y213 h20 w65 vmeritc24,
Gui, Add, Edit, x330 y234 h20 w65 vmeritc25,
Gui, Add, Edit, x330 y255 h20 w65 vmeritc26,
Gui, Add, Edit, x330 y276 h20 w65 vmeritc27,


Gui, Add, Text, x404 y153 h20 w65,E/p
Gui, Add, Text, x404 y174 h20 w65,E/p*Yield
Gui, Add, Text, x404 y195 h20 w65,E/p*(K/CTE)
Gui, Add, Text, x404 y216 h20 w65,K/CTE
Gui, Add, Text, x404 y237 h20 w65,K/(CTE*p*Cp)
Gui, Add, Text, x404 y258 h20 w65,K/(p*Cp)
Gui, Add, Text, x404 y279 h20 w65,K/p

Gui, Add, Text, x20 y153 h20 vmeritwin1,Stiffness to Weight Ratio         
Gui, Add, Text, x20 y174 h20 vmeritwin2,Stiff. to Wt. Ratio with Yield
Gui, Add, Text, x20 y195 h20 vmeritwin3,Stiff. to Wt. with Thermal Bending
Gui, Add, Text, x20 y216 h20 vmeritwin4,Bending Parameter             
Gui, Add, Text, x20 y237 h20 vmeritwin5,Thermal Diffusiv. with Expansion
Gui, Add, Text, x20 y258 h20 vmeritwin6,Thermal Diffusivity           
Gui, Add, Text, x20 y279 h20 vmeritwin7,Conduction to Density Ratio 


;=======================================================================================
;     Write MAT1 Card tab
;=======================================================================================
Gui, Tab, 4

Gui, Add, Text, x57 y50,Pick Material for MAT1 Card:
Gui, Add, Dropdownlist, x210 y47 w210 h20 r1000 vmatwrite, %droplist%
 
Gui, Add, Text, x69 y78 h17, Specify Material Property ID:
Gui, Add, Edit, x210 y75 h20 vmatid w90,
Gui, Add, Text, x88 y103, Specify MAT Card Units:
Gui, Add, DropDownList, x210 y100 w105 h20 vnas_sys r1000, English (lbf-in)||English (slug-ft)|Metric (m-kg)|Metric (mm-g)

Gui, Add, Checkbox, x150 y127 h20 vsourceadd, Add source information to comments
Gui, Add, Checkbox, x150 y150 h20 vdateadd, Add date and time to comments
Gui, Add, Checkbox, x150 y171 h20 vversionadd, Add script version to comments

Gui, Add, Button, x180 y210 w100 h25, Write MAT1 Card

gosub Initializer
gosub Number_Formatter
RP=2
version=2.5
Gosub State_Initializer

Gui, Show, AutoSize, Material Property Database
Return

GuiClose:
Iniwrite,%sorted%,Mat-Props-v2.5.ini,Initialize_States,SortState
Iniwrite,%system_mat%,Mat-Props-v2.5.ini,Initialize_States,system_mat
Iniwrite,%system_mat_two%,Mat-Props-v2.5.ini,Initialize_States,system_mat_two
Iniwrite,%RP%,Mat-Props-v2.5.ini,Initialize_States,RP
Iniwrite,%Scientific%,Mat-Props-v2.5.ini,Initialize_States,Scientific
ExitApp

State_Initializer:
Gui, Submit, Nohide
Iniread,RP,Mat-Props-v2.5.ini,Initialize_States,RP
Guicontrol,,dec,%RP%
Iniread,sorted,Mat-Props-v2.5.ini,Initialize_States,SortState
Guicontrol,,sorted,%sorted%
Gosub Sorter
Iniread,system_mat,Mat-Props-v2.5.ini,Initialize_States,system_mat
Guicontrol,Choose,system_mat,%system_mat%
Iniread,system_mat_two,Mat-Props-v2.5.ini,Initialize_States,system_mat_two
Guicontrol,Choose,system_mat_two,%system_mat_two%
Iniread,Scientific,Mat-Props-v2.5.ini,Initialize_States,Scientific
Guicontrol,,Scientific,%Scientific%
Gosub systemshow
Gosub Display_Update


;Tool Tips for the Merit Figure Comparison tab

message1 = Stiffness to Weight Ratio:  E/p `nThis is an important parameter for comparing the relative dynamic response of materials. `n(higher ratio = higher natural frequencies)  `nHowever, stiffness should be evaluated with the moment of inertia `nand/or light-weight reduction factors common with telescope structures and mirrors.
message2 = Stiffness to Weight Ratio with Yield: E/p*Yield `nIn this case an allowable working stress (fracture or microyield) is given equal weighting. `nMicroyield or fracture may significantly influence a systems capability `nif not properly included in the design process.
message3 = Stiffness to Weight Ratio with Thermal Bending:  E/p*(K/CTE) `nThis combined figure of merit gives equal weight to the structural dynamics `nand the thermal distortion parameters.
message4 = Bending Parameter:  K/CTE `nFor a given flux load or heat sink temperature, the larger this value,`nthe smaller the resulting misalignments and reflective optic wavefront errors.  `nIt applies to near steady state thermal conditions, and applies to many transient `noptical system situations because the slowly varying temperature is attenuated with `nrespect to the external environment with the use of MLI, low emittance surfaces, `nor conductive isolation techniques.
message5 = Thermal Diffusivity with Expansion:  K/(CTE*p*Cp) `nThis parameter is important for changing environmental conditions, such `nas times of directly focused solar energy or response to cyclic electronics `nwaste heat. It is a fair indication of the effect of transient conditions, but should `nnot be used in a general sense to scale temperature gradients.  For example, in a `ncyclic environment (such as solar load moving across the aperture), the diffusivity `nwill appear in the temperature response equation in 2 places, `none relating to stabilization time and the other to the gradient magnitude.
message6 = Thermal Diffusivity:  K/(p*Cp) `nSubstances with high thermal diffusivity rapidly change in temperature `nto adjust to their surroundings.  This is because they conduct heat quickly `nin comparison to their volumetric capacity or 'thermal bulk'.
message7 = Conduction to Density Ratio:  K/p `nAlso known as the Radiator Parameter.  This figure of merit is most `napplicable to the design of thermal radiators or to evaluate the general `nheat spreading ability of structures.

 
Return

;==================================================================================
;==================================================================================
;     END GUI CONTROLS DEFINITION
;==================================================================================
;==================================================================================

 
;==================================================================================
;     Properties are populated from .ini file in Initializer routine
;     - Initializer is called at end of GUI section and whenever the database is
;       changed
;==================================================================================
Initializer:
Gui, submit, nohide

Setformat,Float,0.16E

Loop,%matnum%
     {
     Iniread,Elastic_met%A_Index%,Mat-Props-v2.5.ini,Properties,Elastic%A_Index%,0
     Iniread,Shear_met%A_Index%,Mat-Props-v2.5.ini,Properties,Shear%A_Index%,0
     Iniread,Poisson_met%A_Index%,Mat-Props-v2.5.ini,Properties,Poisson%A_Index%,0
     Iniread,Density_met%A_Index%,Mat-Props-v2.5.ini,Properties,Density%A_Index%,0
     Iniread,Yield_met%A_Index%,Mat-Props-v2.5.ini,Properties,Yield%A_Index%,0
     Iniread,CTE_met%A_Index%,Mat-Props-v2.5.ini,Properties,CTE%A_Index%,0
     Iniread,Conductivity_met%A_Index%,Mat-Props-v2.5.ini,Properties,Conductivity%A_Index%,0
     Iniread,Specific_met%A_Index%,Mat-Props-v2.5.ini,Properties,Specific%A_Index%,0
     Iniread,name%A_Index%,Mat-Props-v2.5.ini,Names,Name%A_Index%,0
     Iniread,Source%A_Index%,Mat-Props-v2.5.ini,Properties,Source%A_Index%,0
     
     Elastic_eng%A_Index% := Elastic_met%A_Index%*emod_convert
     Shear_eng%A_Index% := Shear_met%A_Index%*smod_convert
     Poisson_eng%A_Index% := Poisson_met%A_Index%
     Density_eng%A_Index% := Density_met%A_Index%*density_convert
     Yield_eng%A_Index% := Yield_met%A_Index%*yield_convert
     CTE_eng%A_Index% := CTE_met%A_Index%*cte_convert
     Conductivity_eng%A_Index% := Conductivity_met%A_Index%*conduct_convert
     Specific_eng%A_Index% := Specific_met%A_Index%*specific_convert
     
     If Elastic_met%A_Index%=no data
          Elastic_eng%A_Index%:=Elastic_met%A_Index%
     If Shear_met%A_Index%=no data
          Shear_eng%A_Index%:=Shear_met%A_Index%
     If Poisson_met%A_Index%=no data
          Poisson_eng%A_Index%:=Poisson_met%A_Index%
     If Density_met%A_Index%=no data
          Density_eng%A_Index%:=Density_met%A_Index%
     If Yield_met%A_Index%=no data
          Yield_eng%A_Index%:=Yield_met%A_Index%
     If CTE_met%A_Index%=no data
          CTE_eng%A_Index%:=CTE_met%A_Index%
     If Conductivity_met%A_Index%=no data
          Conductivity_eng%A_Index%:=Conductivity_met%A_Index%
     If Specific_met%A_Index%=no data
          Specific_eng%A_Index%:=Specific_met%A_Index%
     }
     
Return


;=====================================================================
;     Sorter function sorts the drop down list alphabetically if
;     the user checks the appropriate box on the first GUI tab.  The
;     sorting state gets saved when the script is closed and is
;     restored when the script is started again.
;=====================================================================
Sorter:
Gui, submit, nohide
If sorted=0
     {
     droplist=%holding%
     Guicontrol,,mat,|%droplist%
     Guicontrol,Choose,mat,1
     gosub Display_Update
     Guicontrol,,matedit,|%droplist%
     Guicontrol,Choose,matedit,1
     Guicontrol,,matwrite,|%droplist%
     Guicontrol,Choose,matwrite,1
     Guicontrol,,sorted,0
     }
If sorted=1
     {
     sort,droplist,droplist,D|
     Guicontrol,,mat,|%droplist%
     Guicontrol,Choose,mat,1
     gosub Display_Update
     Guicontrol,,matedit,|%droplist%
     Guicontrol,Choose,matedit,1
     Guicontrol,,matwrite,|%droplist%
     Guicontrol,Choose,matwrite,1
     Guicontrol,,sorted,1
     }
Return


;=====================================================================================
;     English_Metric routine is run when determining whether to use English or Metric
;     units for Material Properties or Figures of Merit tabs
;=====================================================================================
English_Metric:
Gui, submit, nohide

Setformat,Float,0.16E

Loop,%matnum%
     {
     Elastic%A_Index% := Elastic_eng%A_Index%
     Shear%A_Index% := Shear_eng%A_Index%
     Poisson%A_Index% := Poisson_eng%A_Index%
     Density%A_Index% := Density_eng%A_Index%
     Yield%A_Index% := Yield_eng%A_Index%
     CTE%A_Index% := CTE_eng%A_Index%
     Conductivity%A_Index% := Conductivity_eng%A_Index%
     Specific%A_Index% := Specific_eng%A_Index%
     }     

If (system_mat="Metric" && Tab_Updater="material properties")
     {
     Loop,%matnum%
          {
          Elastic%A_Index% := Elastic_met%A_Index%
          Shear%A_Index% := Shear_met%A_Index%
          Poisson%A_Index% := Poisson_met%A_Index%
          Density%A_Index% := Density_met%A_Index%
          Yield%A_Index% := Yield_met%A_Index%
          CTE%A_Index% := CTE_met%A_Index%
          Conductivity%A_Index% := Conductivity_met%A_Index%
          Specific%A_Index% := Specific_met%A_Index%
          }
     }

If (system_mat_two="Metric" && Tab_Updater="Add/Edit Material")
     {
     Loop,%matnum%
          {
          Elastic%A_Index% := Elastic_met%A_Index%
          Shear%A_Index% := Shear_met%A_Index%
          Poisson%A_Index% := Poisson_met%A_Index%
          Density%A_Index% := Density_met%A_Index%
          Yield%A_Index% := Yield_met%A_Index%
          CTE%A_Index% := CTE_met%A_Index%
          Conductivity%A_Index% := Conductivity_met%A_Index%
          Specific%A_Index% := Specific_met%A_Index%
          }
     }

If (system_mer="Metric" && Tab_Updater="Compare Merit Figures")
     {
     Loop,%matnum%
          {
          Elastic%A_Index% := Elastic_met%A_Index%
          Shear%A_Index% := Shear_met%A_Index%
          Poisson%A_Index% := Poisson_met%A_Index%
          Density%A_Index% := Density_met%A_Index%
          Yield%A_Index% := Yield_met%A_Index%
          CTE%A_Index% := CTE_met%A_Index%
          Conductivity%A_Index% := Conductivity_met%A_Index%
          Specific%A_Index% := Specific_met%A_Index%
          }
     }
Return

;=====================================================================================
;     Tab_Updater udates the displayed data fields every time the user changes tabs
;=====================================================================================
Tab_Updater:
Gui, submit, nohide

SetTimer, mouseOver, Off

If Tab_Updater=Compare Merit Figures
     {
     ControlGetPos,x1,y1,w1,h1,Stiffness to Weight Ratio,Material Property Database
     xw1 := x1+w1
     yh1 := y1+h1-5
     ControlGetPos,x2,y2,w2,h2,Stiff. to Wt. Ratio with Yield,Material Property Database
     xw2 := x2+w2
     yh2 := y2+h2-5
     ControlGetPos,x3,y3,w3,h3,Stiff. to Wt. with Thermal Bending,Material Property Database
     xw3 := x3+w3
     yh3 := y3+h3-5
     ControlGetPos,x4,y4,w4,h4,Bending Parameter,Material Property Database
     xw4 := x4+w4
     yh4 := y4+h4-5
     ControlGetPos,x5,y5,w5,h5,Thermal Diffusiv. with Expansion,Material Property Database
     xw5 := x5+w5
     yh5 := y5+h5-5
     ControlGetPos,x6,y6,w6,h6,Thermal Diffusivity,Material Property Database
     xw6 := x6+w6
     yh6 := y6+h6-5
     ControlGetPos,x7,y7,w7,h7,Conduction to Density Ratio,Material Property Database
     xw7 := x7+w7
     yh7 := y7+h7-5
     SetTimer, mouseOver, 200
     If system_mer=English
          SetFormat, Float,0.2
     If system_mer=Metric
          SetFormat, Float,0.7
     droplist2=|%droplist%
     }

Gosub Display_Update

Return


;=====================================================================================
;     Number_Formatter routine is run at start of each tab and during drop down list selections
;      -This routine could be simpler and is a brute force approach to getting things
;       working and displaying right
;=====================================================================================   
Number_Formatter:
Gui, submit, nohide

If Scientific
     SetFormat,Float,0.%RP%E
Else
     SetFormat,Float,0.%RP%

Return


matadd:
Gui, submit, nohide
Gui,font,cblack
Guicontrol, font, emodnew
Guicontrol, font, smodnew
Guicontrol, font, poissonnew
Guicontrol, font, densitynew
Guicontrol, font, yieldnew
Guicontrol, font, ctenew
Guicontrol, font, conductnew
Guicontrol, font, specificnew
Guicontrol, font, sourcenew

Guicontrol, Hide, matedit
Guicontrol, Show, namenew
Guicontrol, enable, namenew   
Guicontrol, enable, emodnew   
Guicontrol, enable, smodnew   
Guicontrol, enable, poissonnew
Guicontrol, enable, densitynew
Guicontrol, enable, yieldnew   
Guicontrol, enable, ctenew     
Guicontrol, enable, conductnew
Guicontrol, enable, specificnew
Guicontrol, enable, system_mat_two
Guicontrol, enable, sourcenew
Guicontrol,,emodnew,
Guicontrol,,smodnew,
Guicontrol,,poissonnew,
Guicontrol,,densitynew,
Guicontrol,,yieldnew,
Guicontrol,,CTEnew,
Guicontrol,,Conductnew,
Guicontrol,,Specificnew,
Guicontrol,,sourcenew,

return


Mate_Choose:
Gui, submit, nohide

If Tab_Updater=Material Properties
     material=%mat%

If Tab_Updater=Add/Edit Material
     material=%matedit%

If Tab_Updater=Write MAT1 Card
     material=%matwrite%

Loop,%matnum%
     {
     If Name%A_Index%=%material%
          {
          mate=%A_Index%
          }
     }

Return



matedit:
Gui, submit, nohide

gosub systemshow 

Guicontrol, Show, matedit
Guicontrol, Hide, namenew
Guicontrol, enable, emodnew
Guicontrol, enable, smodnew
Guicontrol, enable, poissonnew
Guicontrol, enable, densitynew
Guicontrol, enable, yieldnew
Guicontrol, enable, ctenew
Guicontrol, enable, conductnew
Guicontrol, enable, specificnew
Guicontrol, enable, system_mat_two
Guicontrol, enable, sourcenew

Gui,font,cgray
Guicontrol, font, emodnew
Guicontrol, font, smodnew
Guicontrol, font, poissonnew
Guicontrol, font, densitynew
Guicontrol, font, yieldnew
Guicontrol, font, ctenew
Guicontrol, font, conductnew
Guicontrol, font, specificnew
Guicontrol, font, sourcenew

Return               
   
                     
matdel:
Gui, submit, nohide
Guicontrol, Show, matedit
Guicontrol, Hide, namenew
Guicontrol,disable,emodnew
Guicontrol,disable,smodnew
Guicontrol,disable,poissonnew
Guicontrol,disable,densitynew
Guicontrol,disable,yieldnew
Guicontrol,disable,ctenew
Guicontrol,disable,conductnew
Guicontrol,disable,specificnew
Guicontrol,disable,system_mat_two
Guicontrol,disable,namenew
Guicontrol,disable,sourcenew
Return




emodnew:
Gui, submit, nohide
If edit=1
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, emodnew
          }     
     }
return

smodnew:
Gui, submit, nohide
If edit=1
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, smodnew
          }     
     }
return

poissonnew:
Gui, submit, nohide
If edit=1
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, poissonnew
          }     
     }
return

densitynew:
Gui, submit, nohide
If edit=1
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, densitynew
          }     
     }
return

yieldnew:
Gui, submit, nohide
If edit=1
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, yieldnew
          }     
     }
return

CTEnew:
Gui, submit, nohide
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, CTEnew
          }     
     }
return

conductnew:
Gui, submit, nohide
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, conductnew
          }     
     }
return

specificnew:
Gui, submit, nohide
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, specificnew
          }     
     }
return

sourcenew:
Gui, submit, nohide
     {
     GetKeyState,bstate,Backspace
     GetKeyState,dstate,Delete
     If (bstate="D" or dstate="D")
          {
          Gui, font, cblack
          Guicontrol, font, sourcenew
          }
     }
return   


;====================================================================================
;    This button function updates the ini file in slightly different ways depending
;    on whether the user is adding, editing, or deleting.  For editing and deleting
;    the ini file is passed to a variable. The ini file is then deleted and rewritten
;    after some data manipulation to the variable.
;====================================================================================

ButtonAdd/Edit/DeleteMaterial:
Gui, submit, nohide

Setformat,Float,0.16E

Loop,%matnum%
     {
     If Name%A_Index%=%matedit%
          {
          mate=%A_Index%
          }
     }

If add=1
     {
     Loop,%matnum%
          {
          If Name%A_Index%=%Namenew%
               {
               Msgbox, Material name already exists in database!  Try a different name.
               return
               }
          }
     matnum+=1
     If system_mat_two=English
          {
          Emod := Emodnew/Emod_convert
          Smod := Smodnew/Smod_convert
          Poisson := Poissonnew
          Density := Densitynew/Density_convert
          Yield := Yieldnew/Yield_convert
          CTE := CTEnew/CTE_convert
          Conductivity := Conductnew/conduct_convert
          Specific := Specificnew/specific_convert       
          }
     Else
          {
          Emod := Emodnew
          Smod := Smodnew
          Poisson := Poissonnew
          Density := Densitynew
          Yield := Yieldnew
          CTE := CTEnew
          Conductivity := Conductnew
          Specific := Specificnew                   
          }

     Source%matnum% := Sourcenew

     Iniwrite,%Namenew%,Mat-Props-v2.5.ini,Names,Name%matnum%
     Iniwrite,%Emod%,Mat-Props-v2.5.ini,Properties,Elastic%matnum%
     Iniwrite,%Smod%,Mat-Props-v2.5.ini,Properties,Shear%matnum%
     Iniwrite,%Poisson%,Mat-Props-v2.5.ini,Properties,Poisson%matnum%
     Iniwrite,%Density%,Mat-Props-v2.5.ini,Properties,Density%matnum%
     Iniwrite,%Yield%,Mat-Props-v2.5.ini,Properties,Yield%matnum%
     Iniwrite,%CTE%,Mat-Props-v2.5.ini,Properties,CTE%matnum%
     Iniwrite,%Conductivity%,Mat-Props-v2.5.ini,Properties,Conductivity%matnum%
     Iniwrite,%Specific%,Mat-Props-v2.5.ini,Properties,Specific%matnum%
     Iniwrite,%Sourcenew%,Mat-Props-v2.5.ini,Properties,Source%matnum%

     droplist=%droplist%%Namenew%|     
     holding=%holding%%Namenew%|
         
     Guicontrol,,mat,|%droplist%
     Guicontrol,,matedit,|%droplist%
     Guicontrol,,matwrite,|%droplist%
     
     msgbox, Material has been added to the database and material list.
     }

If edit=1
     {
     If system_mat_two=English                         
          {                                         
          Emod := Emodnew/Emod_convert               
          Smod := Smodnew/Smod_convert               
          Poisson := Poissonnew                     
          Density := Densitynew/Density_convert     
          Yield := Yieldnew/Yield_convert           
          CTE := CTEnew/CTE_convert                 
          Conductivity := Conductnew/conduct_convert
          Specific := Specificnew/specific_convert
   
          }                                         
     Else                                           
          {                                         
          Emod := Emodnew                           
          Smod := Smodnew                           
          Poisson := Poissonnew                     
          Density := Densitynew                     
          Yield := Yieldnew                         
          CTE := CTEnew                             
          Conductivity := Conductnew                 
          Specific := Specificnew                   
          }                                         

     Source := Sourcenew
     namedit:=Name%mate%

     valuetrack=0
     values=%namedit%,%Emod%,%Smod%,%Poisson%,%Density%,%Yield%,%CTE%,%Conductivity%,%Specific%,%Source%
     stringsplit,valuable,values,`,
     fileread,ini,Mat-Props-v2.5.ini   
     Stringsplit,inis,ini,`n 
     Loop,%inis0%
          {
          info:=inis%A_Index%
          StringSplit,first,info,=
          StringRight,last,first1,3
          If last is not number
               {
               StringRight,last,first1,2
               If last is not number
                    {
                    StringRight,last,first1,1
                    If last is not number
                         Continue
                    }
               }
          If last=%mate%
               {
               valuetrack+=1
               valued:=valuable%valuetrack%
               inis%A_Index%=%first1%=%valued%
               }
          }

     Filedelete,Mat-Props-v2.5.ini
     Loop,%inis0%
          {
          info:=inis%A_Index%
          Fileappend,%info%`n,Mat-Props-v2.5.ini
          }                         
     
     msgbox, Material has been modified.     
     }
     
If del=1
     {   
     namedit:=name%mate%       
     inidelete,Mat-Props-v2.5.ini,names,name%mate%
     inidelete,Mat-Props-v2.5.ini,properties,Elastic%mate%
     inidelete,Mat-Props-v2.5.ini,properties,Shear%mate%
     inidelete,Mat-Props-v2.5.ini,properties,Poisson%mate%
     inidelete,Mat-Props-v2.5.ini,properties,Density%mate%
     inidelete,Mat-Props-v2.5.ini,properties,Yield%mate%
     inidelete,Mat-Props-v2.5.ini,properties,CTE%mate%
     inidelete,Mat-Props-v2.5.ini,properties,Conductivity%mate%     
     inidelete,Mat-Props-v2.5.ini,properties,Specific%mate%
     inidelete,Mat-Props-v2.5.ini,properties,Source%mate%     
     
     matnum-=1     

     fileread,ini,Mat-Props-v2.5.ini
     
     Stringsplit,inis,ini,`n
     Loop,%inis0%
          {
          info:=inis%A_Index%
          Ifnotinstring,info,=
               {
               continue
               }
          Ifinstring,info,=
               {
               Stringsplit,first,info,=
               StringRight,last,first1,3
               If last is not number
                    {
                    trimmer=2
                    StringRight,last,first1,2
                    If last is not number
                         {
                         trimmer=1
                         StringRight,last,first1,1
                         If last is not number
                              Continue
                         }
                    }
               StringTrimRight,first1,first1,%trimmer%
               lastmin:=last-1
               If last>%mate%
                    {
                    inis%A_Index%=%first1%%lastmin%=%first2%
                    }
               }
          }
     Filedelete,Mat-Props-v2.5.ini
     Setformat,Float,0.6     
     Loop,%inis0%
          {
          info:=inis%A_Index%
          Fileappend,%info%`n,Mat-Props-v2.5.ini
          }
         
     Stringreplace,droplist,droplist,%namedit%|,
     Stringreplace,holding,holding,%namedit%|,     

     Guicontrol,,mat,|%droplist%
     Guicontrol,,matedit,|%droplist%
     Guicontrol,,matwrite,|%droplist%
     
     msgbox, Material has been deleted.

     }

Guicontrol,Choose,mat,1
Guicontrol,Choose,matedit,1
Guicontrol,Choose,matwrite,1
Gosub Initializer     
Gosub Display_Update

If sorted=1
     gosub sorter

Return


Mouseover:
SetTitleMatchMode, 3
MouseGetPos,currentx,currenty

If (currentx >= x1 && currentx <= xw1 && currenty <= yh1 && currenty >= y1)
     Tooltip, %message1%, x1+5, y1+5
If (currentx >= x2 && currentx <= xw2 && currenty <= yh2 && currenty >= y2)
     Tooltip, %message2%, x2+5, y2+5
If (currentx >= x3 && currentx <= xw3 && currenty <= yh3 && currenty >= y3)
     Tooltip, %message3%, x3+5, y3+5
If (currentx >= x4 && currentx <= xw4 && currenty <= yh4 && currenty >= y4)
     Tooltip, %message4%, x4+5, y4+5
If (currentx >= x5 && currentx <= xw5 && currenty <= yh5 && currenty >= y5)
     Tooltip, %message5%, x5+5, y5+5
If (currentx >= x6 && currentx <= xw6 && currenty <= yh6 && currenty >= y6)
     Tooltip, %message6%, x6+5, y6+5
If (currentx >= x7 && currentx <= xw7 && currenty <= yh7 && currenty >= y7)
     Tooltip, %message7%, x7+5, y7+5

If (currentx < x1)
     Tooltip,
If (currentx > xw1)
     Tooltip,
If (currenty < y1)
     Tooltip,
If (currenty > yh7)
     Tooltip,

Return


Compare:
Gui,submit,nohide

gosub english_metric

meritn1 := 1.0
meritn2 := 1.0
meritn3 := 1.0
meritn4 := 1.0
meritn5 := 1.0
meritn6 := 1.0
meritn7 := 1.0
Loop,7
     {
     merit0%A_Index%:=
     merit1%A_Index%:=
     merit2%A_Index%:=
     guicontrol,,meritc%A_Index%,
     guicontrol,,meritc1%A_Index%,
     guicontrol,,meritc2%A_Index%,
     }

Loop,%matnum%
     {
     namenorm:=name%A_Index%
     If normalize=%namenorm%
          {
          Setformat,float,0.16E
          meritn1 := Elastic%A_Index%/Density%A_Index%
          meritn2 := Elastic%A_Index%/Density%A_Index%*Yield%A_Index%                     
          meritn3 := Elastic%A_Index%/Density%A_Index%*Conductivity%A_Index%/CTE%A_Index% 
          meritn4 := Conductivity%A_Index%/CTE%A_Index%                                   
          meritn5 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%*CTE%A_Index%)
          meritn6 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%)           
          meritn7 := Conductivity%A_Index%/Density%A_Index%
          break
          }
     }       
Loop,%matnum%       
     {               
     namecomp:=name%A_Index%
     gosub Tab_Updater
     If compare1=%namecomp%
          {
          merit01 := Elastic%A_Index%/Density%A_Index%/meritn1
          merit02 := Elastic%A_Index%/Density%A_Index%*Yield%A_Index%/meritn2
          merit03 := Elastic%A_Index%/Density%A_Index%*Conductivity%A_Index%/CTE%A_Index%/meritn3
          merit04 := Conductivity%A_Index%/CTE%A_Index%/meritn4
          merit05 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%*CTE%A_Index%)/meritn5
          merit06 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%)/meritn6
          merit07 := Conductivity%A_Index%/Density%A_Index%/meritn7
          guicontrol,,meritc1, %merit01%
          guicontrol,,meritc2, %merit02%
          guicontrol,,meritc3, %merit03%
          guicontrol,,meritc4, %merit04%
          guicontrol,,meritc5, %merit05%
          guicontrol,,meritc6, %merit06%
          guicontrol,,meritc7, %merit07%
          }
     If compare2=%namecomp%
          {
          merit11 := Elastic%A_Index%/Density%A_Index%/meritn1                                                 
          merit12 := Elastic%A_Index%/Density%A_Index%*Yield%A_Index%/meritn2                                 
          merit13 := Elastic%A_Index%/Density%A_Index%*Conductivity%A_Index%/CTE%A_Index%/meritn3             
          merit14 := Conductivity%A_Index%/CTE%A_Index%/meritn4                                               
          merit15 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%*CTE%A_Index%)/meritn5           
          merit16 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%)/meritn6                       
          merit17 := Conductivity%A_Index%/Density%A_Index%/meritn7                                           
          guicontrol,,meritc11, %merit11%
          guicontrol,,meritc12, %merit12%
          guicontrol,,meritc13, %merit13%
          guicontrol,,meritc14, %merit14%
          guicontrol,,meritc15, %merit15%
          guicontrol,,meritc16, %merit16%
          guicontrol,,meritc17, %merit17%
          }
     If compare3=%namecomp%
          {
          merit21 := Elastic%A_Index%/Density%A_Index%/meritn1                                                 
          merit22 := Elastic%A_Index%/Density%A_Index%*Yield%A_Index%/meritn2                                 
          merit23 := Elastic%A_Index%/Density%A_Index%*Conductivity%A_Index%/CTE%A_Index%/meritn3             
          merit24 := Conductivity%A_Index%/CTE%A_Index%/meritn4                                               
          merit25 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%*CTE%A_Index%)/meritn5           
          merit26 := Conductivity%A_Index%/(Density%A_Index%*Specific%A_Index%)/meritn6                       
          merit27 := Conductivity%A_Index%/Density%A_Index%/meritn7                                           
          guicontrol,,meritc21, %merit21%
          guicontrol,,meritc22, %merit22%
          guicontrol,,meritc23, %merit23%
          guicontrol,,meritc24, %merit24%
          guicontrol,,meritc25, %merit25%
          guicontrol,,meritc26, %merit26%
          guicontrol,,meritc27, %merit27%
          }         
     }
Return


;========================================================================
;     This button function writes a NASTRAN MAT1 data card for the user
;     selected material.  There are options to add time, date, and
;     script version to the MAT1 card comments.  Some formatting of the
;     data output is done depending on how big or small the data fields
;     are so that as many significant figures are put into the card as
;     possible.
;========================================================================
ButtonWriteMat1Card:
Gui, submit, nohide
Temp=293.
Setformat,float,0.16E

If matid=
     {
     msgbox,Material number is blank!  Material card was not written.
     return
     }

Loop,%matnum%
     {
     If Name%A_Index%=%matwrite%
          {
          matw=%A_Index%
          }
     }   

Gosub Initializer

If nas_sys=English (lbf-in)
     {
     Emod := Elastic_eng%matw%*1000000.
     Smod := Shear_eng%matw%*1000000.
     Poisson := Poisson_eng%matw%
     Density := Density_eng%matw%
     Yield := Yield_eng%matw%*1000.
     CTE := CTE_eng%matw%*1.E-6
     Conductivity := Conductivity_eng%matw%*3600.
     Specific := Specific_eng%matw%
     PMwtmass := 0.0025907
     Force := lbf
     Stress := psi
     }
If nas_sys=English (slug-ft)
     {
     Emod := Elastic_eng%matw%*1000000.*144.*0.031081
     Smod := Shear_eng%matw%*1000000.*144.*0.031081
     Poisson := Poisson_eng%matw%
     Density := Density_eng%matw%*1728.*0.031081
     Yield := Yield_eng%matw%*1000.*144.*0.031081
     CTE := CTE_eng%matw%*1.E-6
     Conductivity := Conductivity_eng%matw%*12.*3600.
     Specific := Specific_eng%matw%
     PMwtmass := 0.031085
     Force := lbf
     Stress := psf
     }
If nas_sys=Metric (m-kg)
     {
     Emod := Elastic_met%matw%*1.E+9
     Smod := Shear_met%matw%*1.E+9
     Poisson := Poisson_met%matw%
     Density := Density_met%matw%
     Yield := Yield_met%matw%*1.E+6
     CTE := CTE_met%matw%*1.E-6
     Conductivity := Conductivity_eng%matw%
     Specific := Specific_eng%matw%
     PMwtmass := 1.
     Force := N
     Stress := Pa 
     }
If nas_sys=Metric (mm-g)
     {
     Emod := Elastic_met%matw%*1.E+3
     Smod := Shear_met%matw%*1.E+3
     Poisson := Poisson_met%matw%
     Density := Density_met%matw%/1.E+6
     Yield := Yield_met%matw%
     CTE := CTE_met%matw%*1.E-6
     Conductivity := Conductivity_eng%matw%/1000.
     Specific := Specific_eng%matw%/1000.
     PMwtmass := 0.000001
     Force := micro Newtons
     Stress := Pa
     }
Source:=Source%matw%

If Emod<1.E+10
     Setformat,float,0.3E
Else
     Setformat,float,0.2E
Emod := Emod+0.
Smod := Smod+0.
Setformat,float,0.3E
CTE := CTE+0.

If Density>1000.
     Setformat,float,0.2
If Density<1000.
     Setformat,float,0.3
If Density<100.
     Setformat,float,0.4
Density := Density+0.

Setformat,float,0.2
Conductivity := Conductivity + 0.
Specific := Specific + 0.

Setformat,float,0.3
Poisson := Poisson+0.
Damping := 0.01

Stringreplace,Emod,Emod,E+,+
Stringreplace,Emod,Emod,E-,-
Stringreplace,Emod,Emod,+00,+
Stringreplace,Emod,Emod,-00,-
Stringreplace,Emod,Emod,+0,+
Stringreplace,Emod,Emod,-0,-

Stringreplace,Smod,Smod,E+,+
Stringreplace,Smod,Smod,E-,-
Stringreplace,Smod,Smod,+00,+
Stringreplace,Smod,Smod,-00,-
Stringreplace,Smod,Smod,+0,+
Stringreplace,Smod,Smod,-0,-

Stringreplace,CTE,CTE,E+,+
Stringreplace,CTE,CTE,E-,-
Stringreplace,CTE,CTE,+00,+
Stringreplace,CTE,CTE,-00,-
Stringreplace,CTE,CTE,+0,+
Stringreplace,CTE,CTE,-0,-

If sourceadd=1
     addsource=$  Properties for %matwrite% are referenced from %Source%`r`n
Else
     addsource=
If versionadd=1
     {
     If dateadd=1
          {
          addversiondate1=$  Material card written by Material Property Database`r`n
          addversiondate2=$  script version %version% on %A_MM%-%A_DD%-%A_YYYY% at %A_hour%:%A_min%:%A_sec%`r`n
          }
     Else
          {
          addversiondate1=$  Material card written by Material Property Database script version %version%`r`n
          addversiondate2=
          }
     }
Else
     {
     If dateadd=1
          addversiondate1=$  Material card created on %A_MM%-%A_DD%-%A_YYYY% at %A_hour%:%A_min%:%A_sec%`r`n
     Else
          addversiondate1=
          addversiondate2=
     }   

Loop,9
     {
     stringlen,matidlen,matid
     stringlen,emodlen,emod
     stringlen,smodlen,smod
     stringlen,poissonlen,poisson
     stringlen,densitylen,density
     stringlen,CTElen,CTE
     If (matidlen<8)
          {
          matid=%matid%f
          stringreplace,matid,matid,f,%A_Space%
          }
     If (emodlen<8)
          {
          emod=%emod%f
          stringreplace,emod,emod,f,%A_Space%
          }
     If (smodlen<8)
          {
          smod=%smod%f
          stringreplace,smod,smod,f,%A_Space%
          }
     If (poissonlen<8)
          {
          poisson=%poisson%f
          stringreplace,poisson,poisson,f,%A_Space%
          }
     If (densitylen<8)
          {
          density=%density%f
          stringreplace,density,density,f,%A_Space%
          }
     If (CTElen<8)
          {
          CTE=%CTE%f
          stringreplace,CTE,CTE,f,%A_Space%
          }
     }

clipboard = %addversiondate1%%addversiondate2%%addsource%MAT1    %matid%%Emod%%Smod%%Poisson%%Density%%CTE%%Temp%

If addversiondate2=
clipboard = %addversiondate1%%addsource%MAT1    %matid%%Emod%%Smod%%Poisson%%Density%%CTE%%Temp%       
     

If nas_sys=English (lbf-in)
     {
     msg1=MAT1 has been copied to the clipboard.  `n`r`n`rUse Param,Wtmass to scale as needed
     msgbox % msg1
     }
If nas_sys=English (slug-ft)
     {
     msg2=MAT1 has been copied to the clipboard. `n`r`n`rUse Param,Wtmass to scale as needed
     msgbox % msg2
     }
If nas_sys=Metric (m-kg)
     {
     msg3=MAT1 has been copied to the clipboard.  `n`r`n`rUse Param,Wtmass to scale as needed.
     msgbox % msg3
     }
If nas_sys=Metric (mm-g)
     {
     msg5=MAT1 has been copied to the clipboard.  `n`r`n`rUse Param,Wtmass to scale as needed.
     msgbox % msg5
     }

Return


;==================================================================================
;     Systemshow is run when switching between Metric and English to show the
;     correct data field unit system labels
;==================================================================================
systemshow:
Gui, submit, nohide
If Scientific
     SetFormat,Float,0.%RP%E
Else
     SetFormat,Float,0.%RP%
If system_mat=Metric
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
     }
If system_mat=English
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
     }

If system_mat_two=Metric
     {
     Guicontrol, Show, met1new
     Guicontrol, Show, met2new
     Guicontrol, Show, met3new
     Guicontrol, Show, met4new
     Guicontrol, Show, met5new
     Guicontrol, Show, met6new
     Guicontrol, Show, met7new
     Guicontrol, Hide, eng1new
     Guicontrol, Hide, eng2new
     Guicontrol, Hide, eng3new
     Guicontrol, Hide, eng4new
     Guicontrol, Hide, eng5new
     Guicontrol, Hide, eng6new
     Guicontrol, Hide, eng7new
     }
If system_mat_two=English
     {
     Guicontrol, Hide, met1new
     Guicontrol, Hide, met2new
     Guicontrol, Hide, met3new
     Guicontrol, Hide, met4new
     Guicontrol, Hide, met5new
     Guicontrol, Hide, met6new
     Guicontrol, Hide, met7new
     Guicontrol, Show, eng1new
     Guicontrol, Show, eng2new
     Guicontrol, Show, eng3new
     Guicontrol, Show, eng4new
     Guicontrol, Show, eng5new
     Guicontrol, Show, eng6new
     Guicontrol, Show, eng7new
     }

gosub Display_Update

Return

;=================================================================================
;     English, Scientific, and Precision are run when
;     changing precision or number format
;=================================================================================
Regular:
GuiControl,,Scientific,0
GuiControl,,Regular,1
gosub Display_Update
return

Scientific:
GuiControl,,Scientific,1
GuiControl,,Regular,0
gosub Display_Update
return

Precision_Update:
Gui, submit, nohide
gosub Display_Update
If System=English
     gosub systemshow
return


;=================================================================================
;     Display_Update routine does all the calculation and display updates every
;     time a data field needs to be changed
;=================================================================================
Display_Update:
Gui, submit, nohide

gosub English_Metric
gosub Mate_Choose

If (Tab_Updater="Add/Edit Material" && Edit=1)
     {
     Gui,font,cgray
     Guicontrol, font, emodnew
     Guicontrol, font, smodnew
     Guicontrol, font, poissonnew
     Guicontrol, font, densitynew
     Guicontrol, font, yieldnew
     Guicontrol, font, ctenew
     Guicontrol, font, conductnew
     Guicontrol, font, specificnew
     Guicontrol, font, sourcenew
     }

emod_mat := Elastic%mate%
smod_mat := Shear%mate%
poisson_mat := Poisson%mate%
density_mat := Density%mate%
yield_mat := Yield%mate%
cte_mat := CTE%mate%
conduct_mat := Conductivity%mate%
specific_mat := Specific%mate%
Sourcehold := Source%mate%

gosub Number_Formatter

emod_mat := emod_mat+0.
smod_mat := smod_mat+0.
poisson_mat := poisson_mat+0.
density_mat := density_mat+0.
yield_mat := yield_mat+0.
cte_mat := cte_mat+0.
conduct_mat := conduct_mat+0.
specific_mat := specific_mat+0.

If emod_mat>-1
     {
     guicontrol,,emod, %emod_mat%
     guicontrol,,emodnew, %emod_mat%
     }
else
     {
     guicontrol,,emod, No Data
     guicontrol,,emodnew, No Data
     }
     
If smod_mat>-1
     {
     guicontrol,,smod, %smod_mat%
     guicontrol,,smodnew, %smod_mat%
     }
else
     {
     guicontrol,,smod, No Data
     guicontrol,,smodnew, No Data
     }
     
If poisson_mat>-1
     {
     guicontrol,,poisson, %poisson_mat%
     guicontrol,,poissonnew, %poisson_mat%
     }
else
     {
     guicontrol,,poisson, No Data
     guicontrol,,poissonnew, No Data
     }
     
If density_mat>-1
     {
     guicontrol,,density, %density_mat%
     guicontrol,,densitynew, %density_mat%
     }
else
     {
     guicontrol,,density, No Data
     guicontrol,,densitynew, No Data
     }

If yield_mat>-1
     {
     guicontrol,,yield, %yield_mat%
     guicontrol,,yieldnew, %yield_mat%
     }
else
     {
     guicontrol,,yield, No Data
     guicontrol,,yieldnew, No Data
     }
     
If cte_mat>-1
     {
     guicontrol,,cte, %cte_mat%
     guicontrol,,ctenew, %cte_mat%
     }
else
     {
     guicontrol,,cte, No Data
     guicontrol,,ctenew, No Data
     }
     
If conduct_mat>-1
     {
     guicontrol,,conduct, %conduct_mat%
     guicontrol,,conductnew, %conduct_mat%
     }
else
    {
    guicontrol,,conduct, No Data
    guicontrol,,conductnew, No Data
    }

If specific_mat>-1
     {
     guicontrol,,specific, %specific_mat%
     guicontrol,,specificnew, %specific_mat%
     }
else
     {
     guicontrol,,specific, No Data
     guicontrol,,specificnew, No Data
     }
     
guicontrol,,source, %sourcehold%
guicontrol,,sourcenew, %sourcehold%

If Add=1
     {
     guicontrol,,emodnew,
     guicontrol,,smodnew,
     guicontrol,,poissonnew,
     guicontrol,,densitynew,
     guicontrol,,yieldnew,
     guicontrol,,ctenew,
     guicontrol,,conductnew,
     guicontrol,,specificnew,
     guicontrol,,sourcenew,
     }
Return
