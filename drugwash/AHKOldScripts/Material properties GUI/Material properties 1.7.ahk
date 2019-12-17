
; v1.7 (7-6-09) - Added edit and delete material functionality to the Add Material tab.  Added mouseover capability to the merit figure titles to explain why the user should care about the different merit figures/ratios.  Removed the unit converter and calculator functionality to simplify the main goal of the script (this already exists in the Unit Converter script anyways).;                 
;
;=======================================================================================
;     Conversion from Metric to English (to be used in figures routine)
;=======================================================================================
;METRIC emod=GPa smod=GPa density=kg/m^3 yield=MPa CTE=µm/m-C Conduct=W/m-K Specific=J/kg-C
;ENGLISH emod=ksi*10^3 smod=ksi*10^3 density=lb/in^3 yield=ksi CTE=µin/in-F Conduct=BTU/hr-in-F Specific=BTU/lb-F
;CONVERSION Metric==>English
emod_convert:=.145037,smod_convert:=.145037,density_convert:=0.00003612700,yield_convert:=.145037,CTE_convert:=0.555556,Conduct_convert:=0.04818133759,Specific_convert:=.0002388459


;=========================================================================================
;     INI File Check or Creation
;     - In .ini file material properties should be in metric units listed above
;     - Five common metals are used to make a default .ini file if Material-Properties.ini
;       doesn't exist
;=========================================================================================
;

IfNotExist,Mat-Props-v1.7.ini
     {ini=
     (
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

Elastic2=68.9
Shear2=26.
Poisson2=0.33
Density2=2700.
Yield2=276.
CTE2=23.6
Conductivity2=167.0
Specific2=900.

Elastic3=113.8
Shear3=44.
Poisson3=0.342
Density3=4430.
Yield3=880.
CTE3=8.6
Conductivity3=6.7
Specific3=530.

Elastic4=303.
Shear4=135.
Poisson4=0.13
Density4=1844.
Yield4=345.
CTE4=11.5
Conductivity4=216.
Specific4=1930.

Elastic5=148.
Shear5=56.
Poisson5=0.29
Density5=8137.89
Yield5=241.3
CTE5=1.3
Conductivity5=10.15
Specific5=520.

Elastic6=110.
Shear6=46.
Poisson6=.343
Density6=8960.
Yield6=33.3
CTE6=16.4
Conductivity6=385.
Specific6=385.

Elastic7=77.2
Shear7=27.2
Poisson7=0.42
Density7=19320.
Yield7=100.
CTE7=14.4
Conductivity7=301.
Specific7=132.3

Elastic8=76.
Shear8=27.8
Poisson8=0.38
Density8=10491.
Yield8=117.
CTE8=19.6
Conductivity8=419.
Specific8=234.

Elastic9=200.
Shear9=77.5
Poisson9=0.291
Density9=7870.
Yield9=50.
CTE9=12.2
Conductivity9=76.2
Specific9=440.

Elastic10=68.
Shear10=28.
Poisson10=0.19
Density10=2180.
Yield10=34.
CTE10=0.75
Conductivity10=1.38
Specific10=750.

Elastic11=4.099
Shear11=0.166
Poisson11=0.33
Density11=155.
Yield11=20.
CTE11=5.
Conductivity11=0.064
Specific11=2900.
     )
     FileAppend,%ini%,Mat-Props-v1.7.ini
     }

;=======================================================================================
;     Drop Down List created from .ini file for Material Properties and Figures of Merit tabs
;=======================================================================================
droplist2=|
droplist=|
Loop,1000
     {
     Iniread,name%A_Index%,Mat-Props-v1.7.ini,Names,Name%A_Index%,0
     currentname:=name%A_Index%
     If currentname>0
          {
          matnum+=1
          }
     Else
          continue
     droplist=%droplist%%currentname%|
     droplist2=%droplist2%%currentname%|
     If A_Index=1
          droplist=%droplist%|
     }

;=======================================================================================
;     START GUI SECTION !!!!!
;=======================================================================================
Gui,Font,s10
Gui, Add, Tab2,x-4 y0 w490 h325 ggetter vgetter,Material Properties|Add/Edit Material|Compare Merit Figures
Gui,Font

;=======================================================================================
;     Material Properties GUI tab
;=======================================================================================
Gui, Tab, 1

;Number formatting, decimals, and groupbox dividers
Gui, Margin, -4, -4
Gui, Add, GroupBox, x-5 y239 w490 h85 cblack,
Gui, Add, GroupBox, x-5 y240 w490 h85 cblack,
Gui, Add, Radio, x165 y260 h20 greg1 vreg1 checked, Regular
Gui, Add, Radio, x165 y280 h20 gsci1 vsci1, Scientific
Gui, Add, Edit, x245 y270 w40 h20 gRpre1 vRP1,
Gui, Add, UpDown, Range0-5 0x80, 2
Gui, Add, Text, x290 y272, decimals
 
Gui, Add, Dropdownlist, x80 y32 w210 h20 r1000 gfigures vmat altsubmit, %droplist%
Gui, Add, DropDownList, x298 y32 w65 h20 gsystemshow vsystem_mat r2, English||Metric

Gui, Add, Text, x80 y62 h20, Elastic Modulus (E)
Gui, Add, Text, x80 y83 h20, Shear Modulus (G)
Gui, Add, Text, x80 y104 h20, Poisson's Ratio (v)
Gui, Add, Text, x80 y125 h20, Density (p)
Gui, Add, Text, x80 y146 h20, Yield Strength (Yield)
Gui, Add, Text, x80 y167 h20, CTE (CTE)
Gui, Add, Text, x80 y188 h20, Thermal Conductivity (K)
Gui, Add, Text, x80 y209 h20, Specific Heat (Cp)

Gui, Add, Edit, x200 y60 h20 w90 vemod,
Gui, Add, Edit, x200 y81 h20 w90 vsmod,
Gui, Add, Edit, x200 y102 h20 w90 vpoisson,
Gui, Add, Edit, x200 y123  h20 w90 vdensity,
Gui, Add, Edit, x200 y144  h20 w90 vyield,
Gui, Add, Edit, x200 y165  h20 w90 vcte,
Gui, Add, Edit, x200 y186  h20 w90 vconduct,
Gui, Add, Edit, x200 y207  h20 w90 vspecific,

Gui, Add, Text, x300 y62 h20 hidden vmet1, GPa
Gui, Add, Text, x300 y83 h20 hidden vmet2, GPa
Gui, Add, Text, x300 y125 h20 hidden vmet3, kg/m3
Gui, Add, Text, x300 y146 h20 hidden vmet4, MPa
Gui, Add, Text, x300 y167 h20 hidden vmet5, µm/m-C
Gui, Add, Text, x300 y188 h20 hidden vmet6, W/m-K
Gui, Add, Text, x300 y209 h20 hidden vmet7, J/kg-C

Gui, Add, Text, x300 y62 h20 veng1, ksi*103
Gui, Add, Text, x300 y83 h20 veng2, ksi*103
Gui, Add, Text, x300 y125 h20 veng3, lb/in3
Gui, Add, Text, x300 y146 h20 veng4, ksi
Gui, Add, Text, x300 y167 h20 veng5, µin/in-F
Gui, Add, Text, x300 y188 h20 veng6, BTU/hr-in-F
Gui, Add, Text, x300 y209 h20 veng7, BTU/lb-F


;=======================================================================================
;     Add Material tab
;=======================================================================================
Gui, Tab, 2

;Number formatting, decimals, and groupbox dividers
Gui, Margin, -4, -4

Gui, Add, Radio,x80 y30 vadd checked gmatadd,Add
Gui, Add, Radio,x130 y30 vedit gmatedit,Edit
Gui, Add, Radio,x175 y30 vdel gmatdel,Delete Material

Gui, Add, Text, x80 y55 h17,Specify the Unit System for Material:
Gui, Add, DropDownList, x255 y52 w65 h20 gsystemshow vsystem_mat2 r2, English||Metric

Gui, Add, Text, x80 y82 h20, Elastic Modulus (E)
Gui, Add, Text, x80 y103 h20, Shear Modulus (G)
Gui, Add, Text, x80 y124 h20, Poisson's Ratio (v)
Gui, Add, Text, x80 y145 h20, Density (p)
Gui, Add, Text, x80 y166 h20, Yield Strength (Yield)
Gui, Add, Text, x80 y187 h20, CTE (CTE)
Gui, Add, Text, x80 y208 h20, Thermal Conductivity (K)
Gui, Add, Text, x80 y229 h20, Specific Heat (Cp)

Gui, Add, Edit, x200 y80 h20 w90 vemodnew gemodnew,
Gui, Add, Edit, x200 y101 h20 w90 vsmodnew gsmodnew,
Gui, Add, Edit, x200 y122 h20 w90 vpoissonnew gpoissonnew,
Gui, Add, Edit, x200 y143  h20 w90 vdensitynew gdensitynew,
Gui, Add, Edit, x200 y164  h20 w90 vyieldnew gyieldnew,
Gui, Add, Edit, x200 y185  h20 w90 vctenew gctenew,
Gui, Add, Edit, x200 y206  h20 w90 vconductnew gconductnew,
Gui, Add, Edit, x200 y227  h20 w90 vspecificnew gspecificnew,

Gui, Add, Text, x300 y82 h20 hidden vmet1new, GPa
Gui, Add, Text, x300 y103 h20 hidden vmet2new, GPa
Gui, Add, Text, x300 y145 h20 hidden vmet3new, kg/m3
Gui, Add, Text, x300 y166 h20 hidden vmet4new, MPa
Gui, Add, Text, x300 y187 h20 hidden vmet5new, µm/m-C
Gui, Add, Text, x300 y208 h20 hidden vmet6new, W/m-K
Gui, Add, Text, x300 y229 h20 hidden vmet7new, J/kg-C

Gui, Add, Text, x300 y82 h20 veng1new, ksi*103
Gui, Add, Text, x300 y103 h20 veng2new, ksi*103
Gui, Add, Text, x300 y145 h20 veng3new, lb/in3
Gui, Add, Text, x300 y166 h20 veng4new, ksi
Gui, Add, Text, x300 y187 h20 veng5new, µin/in-F
Gui, Add, Text, x300 y208 h20 veng6new, BTU/hr-in-F
Gui, Add, Text, x300 y229 h20 veng7new, BTU/lb-F

Gui, Add, Text, x80 y260 h17,Specify Material Name:
Gui, Add, Dropdownlist, x200 y258 w210 h20 r1000 hidden vmatedit gmateditupdate altsubmit, %droplist%
Gui, Add, Edit, x200 y258 h20 vnamenew,
Gui, Add, Button, x135 y290 h20,Add/Edit/Delete Material

;=======================================================================================
;     Figures of Merit Comparison tab
;=======================================================================================
Gui, Tab, 3

Gui, Add, Text, x104 y35 h20 w65,Material 1
Gui, Add, Text, x104 y60 h20 w65,Material 2
Gui, Add, Text, x104 y83 h20 w65,Material 3

Gui, Font, cblue s10, Tahoma
Gui, Add, Text, x77 y105 h20 w95,Normalize to:
Gui, Font

Gui, Add, DropDownList, x372 y104 w65 h20 gcompare vsystem_mer r2, English||Metric

Gui, Add, Dropdownlist, x160 y32 w205 h20 r1000 gcompare vcompare1, %droplist2%
Gui, Add, Dropdownlist, x160 y56 w205 h20 r1000 gcompare vcompare2, %droplist2%
Gui, Add, Dropdownlist, x160 y80 w205 h20 r1000 gcompare vcompare3, %droplist2%

Gui, Add, Dropdownlist, x160 y104 w205 h20 r1000 gcompare vnormalize, %droplist2%

Gui, Add, Text, x170 y133 h20 w65,Material 1
Gui, Add, Text, x240 y133 h20 w65,Material 2
Gui, Add, Text, x310 y133 h20 w65,Material 3

Gui, Add, Edit, x160 y150 h20 w65 vmeritc1,
Gui, Add, Edit, x160 y171 h20 w65 vmeritc2,
Gui, Add, Edit, x160 y192 h20 w65 vmeritc3,
Gui, Add, Edit, x160 y213 h20 w65 vmeritc4,
Gui, Add, Edit, x160 y234 h20 w65 vmeritc5,
Gui, Add, Edit, x160 y255 h20 w65 vmeritc6,
Gui, Add, Edit, x160 y276 h20 w65 vmeritc7,

Gui, Add, Edit, x230 y150 h20 w65 vmeritc11,
Gui, Add, Edit, x230 y171 h20 w65 vmeritc12,
Gui, Add, Edit, x230 y192 h20 w65 vmeritc13,
Gui, Add, Edit, x230 y213 h20 w65 vmeritc14,
Gui, Add, Edit, x230 y234 h20 w65 vmeritc15,
Gui, Add, Edit, x230 y255 h20 w65 vmeritc16,
Gui, Add, Edit, x230 y276 h20 w65 vmeritc17,

Gui, Add, Edit, x300 y150 h20 w65 vmeritc21,
Gui, Add, Edit, x300 y171 h20 w65 vmeritc22,
Gui, Add, Edit, x300 y192 h20 w65 vmeritc23,
Gui, Add, Edit, x300 y213 h20 w65 vmeritc24,
Gui, Add, Edit, x300 y234 h20 w65 vmeritc25,
Gui, Add, Edit, x300 y255 h20 w65 vmeritc26,
Gui, Add, Edit, x300 y276 h20 w65 vmeritc27,


Gui, Add, Text, x374 y153 h20 w65,E/p
Gui, Add, Text, x374 y174 h20 w65,E/p*Yield
Gui, Add, Text, x374 y195 h20 w65,E/p*(K/CTE)
Gui, Add, Text, x374 y216 h20 w65,K/CTE
Gui, Add, Text, x374 y237 h20 w65,K/(CTE*p*Cp)
Gui, Add, Text, x374 y258 h20 w65,K/(p*Cp)
Gui, Add, Text, x374 y279 h20 w65,K/p

Gui, Add, Text, x5 y153 h20 vmeritwin1,Stiffness to Weight Ratio         
Gui, Add, Text, x5 y174 h20 vmeritwin2,Stiff. to Wt. Ratio w Yield
Gui, Add, Text, x5 y195 h20 vmeritwin3,Stiff. to Wt. w Thermal Bending
Gui, Add, Text, x5 y216 h20 vmeritwin4,Bending Parameter             
Gui, Add, Text, x5 y237 h20 vmeritwin5,Thermal Diffusiv. w Expansion
Gui, Add, Text, x5 y258 h20 vmeritwin6,Thermal Diffusivity           
Gui, Add, Text, x5 y279 h20 vmeritwin7,Conduction to Density Ratio 


gosub Initializer
gosub english_metric
gosub getter
gosub figures



Gui, Show, AutoSize, Material Property Database
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
     Iniread,Elastic_met%A_Index%,Mat-Props-v1.7.ini,Properties,Elastic%A_Index%,0
     Iniread,Shear_met%A_Index%,Mat-Props-v1.7.ini,Properties,Shear%A_Index%,0
     Iniread,Poisson_met%A_Index%,Mat-Props-v1.7.ini,Properties,Poisson%A_Index%,0
     Iniread,Density_met%A_Index%,Mat-Props-v1.7.ini,Properties,Density%A_Index%,0
     Iniread,Yield_met%A_Index%,Mat-Props-v1.7.ini,Properties,Yield%A_Index%,0
     Iniread,CTE_met%A_Index%,Mat-Props-v1.7.ini,Properties,CTE%A_Index%,0
     Iniread,Conductivity_met%A_Index%,Mat-Props-v1.7.ini,Properties,Conductivity%A_Index%,0
     Iniread,Specific_met%A_Index%,Mat-Props-v1.7.ini,Properties,Specific%A_Index%,0
     Iniread,name%A_Index%,Mat-Props-v1.7.ini,Names,Name%A_Index%,0
     
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
message1 = Stiffness to Weight Ratio:  E/p `nThis is an important parameter for comparing the relative dynamic response of materials.  `nHowever, stiffness should be evaluated with the moment of inertia `nand/or light-weight reduction factors common with telescope structures and mirrors.
message2 = Stiffness to Weight Ratio with Yield: E/p*Yield `nIn this case an allowable working stress (fracture or microyield) is given equal weighting. `nMicroyield or fracture may significantly influence a systems capability `nif not properly included in the design process.
message3 = Stiffness to Weight Ratio with Thermal Bending:  E/p*(K/CTE) `nThis combined figure of merit gives equal weight to the structural dynamics `nand the thermal distortion parameters.
message4 = Bending Parameter:  K/CTE `nFor a given flux load or heat sink temperature, the larger this value,`nthe smaller the resulting misalignments and reflective optic wavefront errors.  `nIt applies to near steady state thermal conditions, and applies to many transient `noptical system situations because the slowly varying temperature is attenuated with `nrespect to the external environment with the use of MLI, low emittance surfaces, `nor conductive isolation techniques.
message5 = Thermal Diffusivity with Expansion:  K/(CTE*p*Cp) `nThis parameter is important for changing environmental conditions, such `nas times of directly focused solar energy or response to cyclic electronics `nwaste heat. It is a fair indication of the effect of transient conditions, but should `nnot be used in a general sense to scale temperature gradients.  For example, in a `ncyclic environment (such as solar load moving across the aperture), the diffusivity `nwill appear in the temperature response equation in 2 places, `none relating to stabilization time and the other to the gradient magnitude.
message6 = Thermal Diffusivity:  K/(p*Cp) `nSubstances with high thermal diffusivity rapidly change in temperature `nto adjust to their surroundings.  This is because they conduct heat quickly `nin comparison to their volumetric capacity or 'thermal bulk'.
message7 = Conduction to Density Ratio:  K/p `nAlso known as the Radiator Parameter.  This figure of merit is most `napplicable to the design of thermal radiators or to evaluate the general `nheat spreading ability of structures.
 
RP1=2
 
Return


;=====================================================================================
;     English_Metric routine is run when determining whether to use English or Metric
;     units for Material Properties or Figures of Merit tabs
;=====================================================================================
English_Metric:
Gui, submit, nohide

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

If system_mat=Metric
     {
     If getter=material properties
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
     }
If system_mer=Metric
     {
     If getter=merit figures
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
     SetTimer, mouseOver, Off
     If pre1
          SetFormat,Float,0.%RP1%E
    Else
         SetFormat,Float,0.%RP1%
     }
     
If getter=Add/Edit Material
     {
     SetTimer, mouseOver, Off
     If edit=1
          {
          gosub mateditupdate         
          }
     }
     
If getter=Compare Merit Figures
     {
     ControlGetPos,x1,y1,w1,h1,Stiffness to Weight Ratio,Material Property Database
     xw1 := x1+w1
     yh1 := y1+h1-5
     ControlGetPos,x2,y2,w2,h2,Stiff. to Wt. Ratio w Yield,Material Property Database
     xw2 := x2+w2
     yh2 := y2+h2-5
     ControlGetPos,x3,y3,w3,h3,Stiff. to Wt. w Thermal Bending,Material Property Database
     xw3 := x3+w3
     yh3 := y3+h3-5
     ControlGetPos,x4,y4,w4,h4,Bending Parameter,Material Property Database
     xw4 := x4+w4
     yh4 := y4+h4-5
     ControlGetPos,x5,y5,w5,h5,Thermal Diffusiv. w Expansion,Material Property Database
     xw5 := x5+w5
     yh5 := y5+h5-5
     ControlGetPos,x6,y6,w6,h6,Thermal Diffusivity,Material Property Database
     xw6 := x6+w6
     yh6 := y6+h6-5
     ControlGetPos,x7,y7,w7,h7,Conduction to Density Ratio,Material Property Database
     xw7 := x7+w7
     yh7 := y7+h7-5
     SetTimer, mouseOver, 150
     If system_mer=English
          SetFormat, Float,0.2
     If system_mer=Metric
          SetFormat, Float,0.7
     
     }
     
Return


matadd:
Gui, submit, nohide
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
Guicontrol, enable, system_mat2
Guicontrol,,emodnew,
Guicontrol,,smodnew,
Guicontrol,,poissonnew,
Guicontrol,,densitynew,
Guicontrol,,yieldnew,
Guicontrol,,CTEnew,
Guicontrol,,Conductnew,
Guicontrol,,Specificnew,

return


matedit:
Gui, submit, nohide
Gui,font,cgray
Guicontrol, font, emodnew
Guicontrol, font, smodnew
Guicontrol, font, poissonnew
Guicontrol, font, densitynew
Guicontrol, font, yieldnew
Guicontrol, font, ctenew
Guicontrol, font, conductnew
Guicontrol, font, specificnew

gosub systemshow 

If pre1
     SetFormat,Float,0.%RP1%E
Else
     SetFormat,Float,0.%RP1%   
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
Guicontrol, enable, system_mat2

return               
   
                     
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
Guicontrol,disable,system_mat2
Guicontrol,disable,namenew
return

mateditupdate:
Gui, submit, nohide

Gui,font,cgray
Guicontrol, font, emodnew
Guicontrol, font, smodnew
Guicontrol, font, poissonnew
Guicontrol, font, densitynew
Guicontrol, font, yieldnew
Guicontrol, font, ctenew
Guicontrol, font, conductnew
Guicontrol, font, specificnew

If pre1
     SetFormat,Float,0.%RP1%E
Else
     SetFormat,Float,0.%RP1%
matminus:=matedit-1
If system_mat2=English
     {
     
     Elastic_eng:=Elastic_eng%matminus%+0
     Shear_eng:=Shear_eng%matminus%+0
     Poisson_eng:=Poisson_eng%matminus%+0
     Density_eng:=Density_eng%matminus%+0
     Yield_eng:=Yield_eng%matminus%+0
     CTE_eng:=CTE_eng%matminus%+0
     Conductivity_eng:=Conductivity_eng%matminus%+0
     Specific_eng:=Specific_eng%matminus%+0
     
     guicontrol,,emodnew, %Elastic_eng%   
     guicontrol,,smodnew, %Shear_eng%     
     guicontrol,,poissonnew, %Poisson_eng%     
     guicontrol,,densitynew, %Density_eng%     
     guicontrol,,yieldnew, %Yield_eng%
     guicontrol,,CTEnew, %CTE_eng%
     guicontrol,,Conductnew, %Conductivity_eng%
     guicontrol,,Specificnew, %Specific_eng%
     }
Else
     {     
     Elastic_met:=Elastic_met%matminus%+0
     Shear_met:=Shear_met%matminus%+0
     Poisson_met:=Poisson_met%matminus%+0
     Density_met:=Density_met%matminus%+0
     Yield_met:=Yield_met%matminus%+0
     CTE_met:=CTE_met%matminus%+0
     Conductivity_met:=Conductivity_met%matminus%+0
     Specific_met:=Specific_met%matminus%+0
     
     guicontrol,,emodnew, %Elastic_met%     
     guicontrol,,smodnew, %Shear_met%     
     guicontrol,,poissonnew, %Poisson_met%   
     guicontrol,,densitynew, %Density_met%   
     guicontrol,,yieldnew, %Yield_met%     
     guicontrol,,CTEnew, %CTE_met%   
     guicontrol,,Conductnew, %Conductivity_met%   
     guicontrol,,Specificnew, %Specific_met%
     }

Guicontrolget,smodold,,smodnew
Guicontrolget,emodold,,emodnew
Guicontrolget,poissonold,,poissonnew
Guicontrolget,densityold,,densitynew
Guicontrolget,yieldold,,yieldnew
Guicontrolget,CTEold,,CTEnew
Guicontrolget,Conductold,,Conductnew
Guicontrolget,Specificold,,Specificnew

return


emodnew:
Gui, submit, nohide
If edit=1
     {
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, emodnew
          }     
     If (emodnew<emodold)
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
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, smodnew
          }     
     If (smodnew<smodold)
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
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, poissonnew
          }     
     If (poissonnew<poissonold)
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
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, densitynew
          }     
     If (densitynew<densityold)
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
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, yieldnew
          }     
     If (yieldnew<yieldold)
          {
          Gui, font, cblack
          Guicontrol, font, yieldnew
          }
     }
return

CTEnew:
Gui, submit, nohide
     {
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, CTEnew
          }     
     If (CTEnew<CTEold)
          {
          Gui, font, cblack
          Guicontrol, font, CTEnew
          }
     }
return

conductnew:
Gui, submit, nohide
     {
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, conductnew
          }     
     If (conductnew<conductold)
          {
          Gui, font, cblack
          Guicontrol, font, conductnew
          }
     }
return

specificnew:
Gui, submit, nohide
     {
     GetKeyState,state,Backspace
     If state=D
          {
          Gui, font, cblack
          Guicontrol, font, specificnew
          }     
     If (specificnew<specificold)
          {
          Gui, font, cblack
          Guicontrol, font, specificnew
          }
     }
return

ButtonAdd/Edit/DeleteMaterial:
Gui, submit, nohide

If add=1
     {
     If system_mat2=English
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
     Fileappend,`n`n,Mat-Props-v1.7.ini
     Iniwrite,%Namenew%,Mat-Props-v1.7.ini,Names,Name%matnum%
     Iniwrite,%Emod%,Mat-Props-v1.7.ini,Properties,Elastic%matnum%
     Iniwrite,%Smod%,Mat-Props-v1.7.ini,Properties,Shear%matnum%
     Iniwrite,%Poisson%,Mat-Props-v1.7.ini,Properties,Poisson%matnum%
     Iniwrite,%Density%,Mat-Props-v1.7.ini,Properties,Density%matnum%
     Iniwrite,%Yield%,Mat-Props-v1.7.ini,Properties,Yield%matnum%
     Iniwrite,%CTE%,Mat-Props-v1.7.ini,Properties,CTE%matnum%
     Iniwrite,%Conductivity%,Mat-Props-v1.7.ini,Properties,Conductivity%matnum%
     Iniwrite,%Specific%,Mat-Props-v1.7.ini,Properties,Specific%matnum%
     
     matnum+=1
     
     msgbox, Material has been added to database.  It will show up the next time you run the script.
     }

If edit=1
     {
     matedit-=1
     name_edit:=name%matedit%
     namedit:=name_edit

     If system_mat2=English                         
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

     inidelete,Mat-Props-v1.7.ini,names,name%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Elastic%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Shear%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Poisson%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Density%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Yield%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,CTE%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Conductivity%matedit%     
     inidelete,Mat-Props-v1.7.ini,properties,Specific%matedit%

     Fileappend,`n`n,Mat-Props-v1.7.ini
     iniwrite,%namedit%,Mat-Props-v1.7.ini,names,name%matedit%
     iniwrite,%Emod%,Mat-Props-v1.7.ini,properties,Elastic%matedit%
     iniwrite,%Smod%,Mat-Props-v1.7.ini,properties,Shear%matedit%
     iniwrite,%Poisson%,Mat-Props-v1.7.ini,properties,Poisson%matedit%
     iniwrite,%Density%,Mat-Props-v1.7.ini,properties,Density%matedit%
     iniwrite,%Yield%,Mat-Props-v1.7.ini,properties,Yield%matedit%
     iniwrite,%CTE%,Mat-Props-v1.7.ini,properties,CTE%matedit%
     iniwrite,%Conductivity%,Mat-Props-v1.7.ini,properties,Conductivity%matedit%     
     iniwrite,%Specific%,Mat-Props-v1.7.ini,properties,Specific%matedit%     

     msgbox, Material has been modified.  The new properties will show up the next time you run the script.     
     }
     
If del=1
     {
     matedit-=1
       
     inidelete,Mat-Props-v1.7.ini,names,name%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Elastic%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Shear%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Poisson%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Density%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Yield%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,CTE%matedit%
     inidelete,Mat-Props-v1.7.ini,properties,Conductivity%matedit%     
     inidelete,Mat-Props-v1.7.ini,properties,Specific%matedit%     

     msgbox, Material has been deleted.  It will be gone the next time you run the script.

     matnum-=1
     }
Return


ButtonImportMat1Card:
Gui,submit,nohide
SetFormat,Float,0.16e

Loop,%matnum%
     {
     If Name%A_Index%=%Importname%
          {
          Msgbox, Material name already exists in database!
          return
          }
     }

Fileread, ImportMATarray, %Importlocation%
Stringsplit,ImportArrayMAT,ImportMATarray,`n`

blank=0

Loop
     {
     If ImportArrayMAT%A_Index%=
          {
          blank+=1
          If blank>100
               {
               Msgbox, MAT1 card was not found in specified file!
               break
               }
          }
     Stringleft,ImpA,ImportArrayMAT%A_Index%,4
     If ImpA=MAT1
          {
          Stringleft,ImpFF,ImportArrayMAT%A_Index%,16
          Stringright,ImpF,ImpFF,8
          If ImpF=%Importnumber%
               {
               matnum+=1
               NameImp=%ImportName%
               Line:=ImportArrayMAT%A_Index%
               fieldnum=16
               Loop,7
                    {
                    back:=%A_Index%-1
                    fieldnum+=8
                    Stringleft,MAT1hold,Line,%fieldnum%
                    Stringright,MAT1%A_Index%,MAT1hold,8
                    StringReplace,MAT1%A_Index%,MAT1%A_Index%,-,e-
                    StringReplace,MAT1%A_Index%,MAT1%A_Index%,+,e+
;                    If MAT1%A_Index%=MAT1%back%
;                         MAT1%A_Index%=
                    }
               Elastic:=MAT11
               Shear:=MAT12
               Poisson:=MAT13
               Density:=MAT14
               CTE:=MAT15
               TREF:=MAT16
               SDamp:=MAT17
               
               If ImportSystem=English (lbf-in)
                    {
                    Elastic := Elastic/1000000.*1/emod_convert
                    Shear := Shear/1000000.*1/smod_convert
                    Density := Density*1/density_convert
                    CTE := CTE*1/CTE_convert
                    }
               If ImportSystem=English (slug-ft)
                    {
                    Elastic := Elastic/(1000000.*144.)*1/emod_convert
                    Shear := Shear/(1000000.*144.)*1/smod_convert
                    Density := Density*32.17*1/density_convert
                    CTE := CTE*1/CTE_convert
                    }
               If ImportSystem=Metric (m-kg)
                    {
                    Elastic := Elastic/1.E+9
                    Shear := Shear/1.E+9
                    }
               If ImportSystem=Metric (mm-g)
                    {
                    Elastic := Elastic/1000.
                    Shear := Shear/1000.
                    Density := Density*1.E+6
                    }
               SetFormat,Float,0.2                   
               Fileappend,`n`n,Mat-Props-v1.7.ini
               Iniwrite,%NameImp%,Mat-Props-v1.7.ini,Names,Name%matnum%
               Iniwrite,%Elastic%,Mat-Props-v1.7.ini,Properties,Elastic%matnum%
               Iniwrite,%Shear%,Mat-Props-v1.7.ini,Properties,Shear%matnum%
               Iniwrite,%Poisson%,Mat-Props-v1.7.ini,Properties,Poisson%matnum%
               Iniwrite,%Density%,Mat-Props-v1.7.ini,Properties,Density%matnum%
               Iniwrite,No Data,Mat-Props-v1.7.ini,Properties,Yield%matnum%
               Iniwrite,%CTE%,Mat-Props-v1.7.ini,Properties,CTE%matnum%
               Iniwrite,No Data,Mat-Props-v1.7.ini,Properties,Conductivity%matnum%
               Iniwrite,No Data,Mat-Props-v1.7.ini,Properties,Specific%matnum%
               Iniwrite,%TREF%,Mat-Props-v1.7.ini,Properties,TREF%matnum%
               Iniwrite,%SDamp%,Mat-Props-v1.7.ini,Properties,SDamp%matnum%

               Msgbox, MAT1 card has been imported.  It will show up the next time this script is run.  `n`nAll fields were imported, although not all show up in the property display.  `nSee bottom of Mat-Props-v1.7.ini file to verify.
               break             
               }
          Else
               Continue
          }
     Else
          Continue
     }
               
return


ButtonWriteMat1Card:
Gui, submit, nohide
Temp=293.
Setformat,float,0.16E

matw:=matwrite-1

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

Setformat,float,0.3E
Emod := Emod+0.
Smod := Smod+0.
CTE := CTE+0.

Setformat,float,0.2
Density := Density+0.
Conductivity := Conductivity + 0.
Specific := Specific + 0.

Setformat,float,0.2
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


clipboard = MAT1, %matid%, %Emod%, %Smod%, %Poisson%, %Density%, %CTE%, %Temp%
;stringreplace,clipboard,clipboard,E+00,+,all
;stringreplace,clipboard,clipboard,E+0,+,all
;stringreplace,clipboard,clipboard,E-00,-,all
;stringreplace,clipboard,clipboard,E-0,-,all
If nas_sys=English (lbf-in)
     {
     msg1= MAT1 has been copied to the clipboard (csv format).  `n`nUse Param,Wtmass to scale as needed
     msgbox % msg1
     }
If nas_sys=English (slug-ft)
     {
     msg2= MAT1 has been copied to the clipboard (csv format). `n`nUse Param,Wtmass to scale as needed
     msgbox % msg2
     }
If nas_sys=Metric (m-kg)
     {
     msg3=MAT1 has been copied to the clipboard (csv format).  n`nUse Param,Wtmass to scale as needed.
     msgbox % msg3
     }
If nas_sys=Metric (mm-g)
     {
     msg5=MAT1 has been copied to the clipboard (csv format).  n`nUse Param,Wtmass to scale as needed.
     msgbox % msg5
     }

Return


;==================================================================================
;     System and System_mer are run when switching between Metric and English
;==================================================================================
systemshow:
Gui, submit, nohide
If pre1
     SetFormat,Float,0.%RP1%E
Else
     SetFormat,Float,0.%RP1%
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
     gosub figures
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
     gosub figures
     }

If system_mat2=Metric
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
If system_mat2=English
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
If add=1
     return

matminus:=matedit-1
If system_mat2=English
     {
     
     Elastic_eng:=Elastic_eng%matminus%+0
     Shear_eng:=Shear_eng%matminus%+0
     Poisson_eng:=Poisson_eng%matminus%+0
     Density_eng:=Density_eng%matminus%+0
     Yield_eng:=Yield_eng%matminus%+0
     CTE_eng:=CTE_eng%matminus%+0
     Conductivity_eng:=Conductivity_eng%matminus%+0
     Specific_eng:=Specific_eng%matminus%+0
     guicontrol,,emodnew, %Elastic_eng%   
     guicontrol,,smodnew, %Shear_eng%
     guicontrol,,poissonnew, %Poisson_eng%
     guicontrol,,densitynew, %Density_eng%
     guicontrol,,yieldnew, %Yield_eng%
     guicontrol,,CTEnew, %CTE_eng%
     guicontrol,,Conductnew, %Conductivity_eng%
     guicontrol,,Specificnew, %Specific_eng%
     }
Else
     {
     
     Elastic_met:=Elastic_met%matminus%+0
     Shear_met:=Shear_met%matminus%+0
     Poisson_met:=Poisson_met%matminus%+0
     Density_met:=Density_met%matminus%+0
     Yield_met:=Yield_met%matminus%+0
     CTE_met:=CTE_met%matminus%+0
     Conductivity_met:=Conductivity_met%matminus%+0
     Specific_met:=Specific_met%matminus%+0
     guicontrol,,emodnew, %Elastic_met%   
     guicontrol,,smodnew, %Shear_met%     
     guicontrol,,poissonnew, %Poisson_met%   
     guicontrol,,densitynew, %Density_met%
     guicontrol,,yieldnew, %Yield_met%
     guicontrol,,CTEnew, %CTE_met%     
     guicontrol,,Conductnew, %Conductivity_met%     
     guicontrol,,Specificnew, %Specific_met%
     }
     
Guicontrolget,smodold,,smodnew
Guicontrolget,emodold,,emodnew
Guicontrolget,poissonold,,poissonnew
Guicontrolget,densityold,,densitynew
Guicontrolget,yieldold,,yieldnew
Guicontrolget,CTEold,,CTEnew
Guicontrolget,Conductold,,Conductnew
Guicontrolget,Specificold,,Specificnew

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

Rpre1:
Gui, submit, nohide
gosub figures
If System=English
     gosub systemshow
return


;=================================================================================
;     Figures routine does all the calculation and display requests for
;     Material Properties tab
;=================================================================================
figures:
Gui, submit, nohide

;Setformat, float, 0.16E

gosub english_metric

matmin:=mat-1

emod_mat := Elastic%matmin%
smod_mat := Shear%matmin%
poisson_mat := Poisson%matmin%
density_mat := Density%matmin%
yield_mat := Yield%matmin%
cte_mat := CTE%matmin%
conduct_mat := Conductivity%matmin%
specific_mat := Specific%matmin%

gosub getter

emod_mat := emod_mat+0
smod_mat := smod_mat+0
poisson_mat := poisson_mat+0
density_mat := density_mat+0
yield_mat := yield_mat+0
cte_mat := cte_mat+0
conduct_mat := conduct_mat+0
specific_mat := specific_mat+0

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
     If compare1=%namecomp%
          {
          gosub getter
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
          gosub getter
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
          gosub getter
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
