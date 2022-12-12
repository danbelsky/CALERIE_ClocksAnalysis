//ANALYSIS DATASET FOR CLOCKS PAPER - Mergedd DNAm and Pheno Data
global db3275 "danielbelsky"
//global db3275 "db3275"
global box "Library/CloudStorage/Box-Box"
cd "/Users/$db3275/Downloads"


use "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIENatAgingPhenoData.dta", clear

merge 1:1 deidnum fu using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIENatAgingDNAmData.dta", 
// 1 obs with missing randomization data in pheno file
list if _merge == 2 
drop if CR==.

tabmiss methpc1 methpc2 methpc3 methpc4 methpc5 methpc6 methpc7 methpc8 methpc9 methpc10 methpc11 methpc12 methpc13 methpc14 methpc15 methpc16 methpc17 methpc18 methpc19 methpc20 methpc21 methpc22 methpc23 methpc24 methpcs cd8t cd4t nk bcell mono neu dnamage dnamagehannum dnamphenoage dnamageskinblood dnamgrimage pchorvath1 pcskinblood pchannum pcphenoage pcgrimage pcclocks cells pace

unique deidnum 
count


capture drop X1
egen X1 = count(dnamage), by(deidnum)
capture drop X2 
gen X2 = 1 if dnamage!=. & fu==0 & (X1==2 | X1==3) 
capture drop asample 
egen asample = max(X2), by(deidnum) 
unique deidnum if asample ==1 
tab CR if dnamage!=. & asample == 1 & fu == 0
tab CR if dnamage!=. & asample == 1 & fu == 1 
tab CR if dnamage!=. & asample == 1 & fu == 2


//********************************************************************************//
//List of DNAm Measures 
//********************************************************************************//
global dnammeasures "cd8t cd4t nk bcell mono neu dnamage dnamagehannum dnamphenoage dnamageskinblood dnamgrimage pace pchorvath1 pcskinblood pchannum pcphenoage pcgrimage"
//********************************************************************************//
tabmiss $dnammeasures 

//********************************************************************************//
//Batch Correction - Residualize DNAm measures for batch effects based on technical PCs
//********************************************************************************// 
capture drop yhat*
foreach y in $dnammeasures { 
	xtreg `y' methpc*, re i(deidnum)
	predict `y'_br, ue
	replace `y'_br = `y'_br + _b[_cons]
	}
//********************************************************************************//	
//Calculate Baseline and Change Score values	
//********************************************************************************//
foreach y in $dnammeasures { 
	capture drop X 
	capture drop b_`y' 
	capture drop d_`y' 
	gen X = `y'_br if fu==0
	egen b_`y'_br = min(X), by(deidnum)
	gen d_`y'_br =`y'_br - b_`y'_br
	drop X	
	}

foreach y in mclinwt mbmi { 
	capture drop X 
	capture drop b_`y' 
	capture drop d_`y' 
	gen X = `y' if fu==0
	egen b_`y' = min(X), by(deidnum)
	gen d_`y' =`y' - b_`y'
	drop X	
	}	
//********************************************************************************//
//Age residuals & Age differences for DNAm clocks
//********************************************************************************// 
foreach x in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pchorvath1 pchannum pcskinblood  pcphenoage pcgrimage {
	//Raw Age Differences
	gen ad_`x'_br = `x'_br - agedwb 
	//Age-acceleration residual
	quietly reg `x'_br agedwb 
	predict aar_`x'_br,r
	}	
//********************************************************************************//
//Re-scale measures by baseline SD (use age-difference values for clocks)
//*********************************************************************************//
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	if inlist(`"`y'"', "pace") { 
		quietly sum `y'_br if fu==0 & asample==1
		gen bad_`y'_br = (b_`y'_br-r(mean))/r(sd) 
		gen dad_`y'_br = d_`y'_br/r(sd) 
		} 
	else { 
		//Generate variable for baseline value of the Age-Differenced values 
		capture drop X 
		gen X = ad_`y'_br if fu==0
		egen bad_`y'_br = max(X), by(deidnum)
		drop X 
		//Generate difference scores comparing the age-difference at 12mo and 24mo w/ baseline
		gen dad_`y'_br = ad_`y'_br - bad_`y'_br
		//Rescale difference scores using SD of the baseline age-differenced value
		quietly sum ad_`y'_br if fu==0 & asample==1
		replace bad_`y'_br = (bad_`y'_br-r(mean)) /r(sd)
		replace dad_`y'_br = dad_`y'_br/r(sd)
		}
	}
//*********************************************************************************//
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	if inlist(`"`y'"', "pace") { 
		quietly sum `y'_br if fu==0 & asample==1
		gen b_aar_`y'_br = (b_`y'_br-r(mean))/r(sd) 
		gen d_aar_`y'_br = d_`y'_br/r(sd) 
		} 
	else { 
		//Generate variable for baseline value of the Age-Differenced values 
		capture drop X 
		gen X = aar_`y'_br if fu==0
		egen b_aar_`y'_br = max(X), by(deidnum)
		drop X 
		//Generate difference scores comparing the age-difference at 12mo and 24mo w/ baseline
		gen d_aar_`y'_br = aar_`y'_br - b_aar_`y'_br
		//Rescale difference scores using SD of the baseline age-differenced value
		quietly sum aar_`y'_br if fu==0 & asample==1
		replace b_aar_`y'_br = (b_aar_`y'_br-r(mean)) /r(sd)
		replace d_aar_`y'_br = d_aar_`y'_br/r(sd)
		}
	}
//*********************************************************************************//	
//*********************************************************************************//
	//Label variables
capture label drop CR
label define CR 0 "AL" 1 "CR"
label values CR CR

capture label drop fu
label define fu 0 "Baseline" 1 "12mo" 2 "24mo"
label values fu fu 

label var fu "Follow-up (0=Baseline, 1=12mo, 2=24mo)"
label var CR "Intervention Condition (1=CR, 0=AL)"
label define race 2 "Asian" 4 "Black" 5 "White" 8 "Other"
label values race race
recode race (5=0) (4=1) (8=2), gen(R)
capture label drop R 
label define R 0 "White" 1 "Black" 2 "Other"
label values R R

capture label drop bmistrat
label define bmistrat 1 "Lean" 2 "Overweight"
label values bmistrat bmistrat

label var pace "DunedinPACE"	

label var dnamage "Horvath Clock" 
label var dnamagehannum "Hannum Clock" 
label var dnamageskinblood "Skin & Blood Clock" 
label var dnamphenoage "PhenoAge Clock" 
label var dnamgrimage "GrimAge Clock" 

label var pchorvath1 "Horvath Clock" 
label var pchannum "Hannum Clock" 
label var pcskinblood "Skin & Blood Clock" 
label var pcphenoage "PhenoAge Clock" 
label var pcgrimage "GrimAge Clock" 

foreach x in $dnammeasures { 
	local L: variable label `x'
	label var `x'_br `"`L' (batch corrected)"'
	label var b_`x'_br `"Baseline `L' (batch corrected)"'
	label var d_`x'_br `"Change in `L' (batch corrected)"'
	}
foreach x in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pchorvath1 pchannum pcskinblood pcphenoage pcgrimage {
	local L: variable label `x'
	label var aar_`x'_br `"`L' (batch corrected) Age Accel Resid"'
	label var ad_`x'_br `"`L' (batch corrected) Age Difference"'
	}
foreach x in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pchorvath1 pchannum pcskinblood pcphenoage pcgrimage pace {
	local L: variable label `x'
	label var bad_`x'_br `"Scaled Baseline `L' (batch corrected)"'
	label var dad_`x'_br `"Scaled Change in `L' (batch corrected)"'
	}	

	

//********************************************************************************//
//Count numbers of individuals with data  
//********************************************************************************//
//n=220 unique individuals
	unique deidnum 
//n=217 with at least 1 DNAm observation 
	unique deidnum if dnamage!=.
//n=214 w/ baseline DNAm data
	unique deidnum if dnamage!=. & fu==0
//n=197 w/ baseline DNAm data & 1+ follow-up assessments
unique deidnum if asample==1 
//At Baseline, AL n=69 & CR n=128
tab CR asample if fu==0
//At 12mo, AL n=66 & CR n=125
count if d_dnamage_br !=. & fu==1 & CR==0
count if d_dnamage_br !=. & fu==1 & CR==1
//At 24mo, AL n=68 & CR n=117
count if d_dnamage_br !=. & fu==2 & CR==0
count if d_dnamage_br !=. & fu==2 & CR==1


//********************************************************************************//
save "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIEClockData.dta", replace
//********************************************************************************//



use "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIEClockData.dta", clear
keep if asample == 1 

count
unique deidnum

export delimited CR fu dnamage_br dnamagehannum_br dnamphenoage_br dnamageskinblood_br dnamgrimage_br pace_br pchorvath1_br pcskinblood_br pchannum_br pcphenoage_br pcgrimage_br using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/Fig2PanelAData.csv", replace 

