//ANALYSIS DATASET FOR CLOCKS PAPER - PhenoData Component 
//global db3275 "danielbelsky"
global db3275 "db3275"
global box "Library/CloudStorage/Box-Box"
cd "/Users/$db3275/Downloads"

//BACKBONE DATA FILE
//********************************************************************************//
// Subject Demographics
//********************************************************************************//
use "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/subject1.dta", clear 
keep deidnum deidsite bmistrat agebl female ethnic race race3 txcomp
recode female (1=0) (0=1), gen(sex)
capture label drop sex 
label define sex 0 "Men" 1 "Women" 
label values sex sex 
//********************************************************************************//
// Treatment Group 
//********************************************************************************//
merge 1:1 deidnum using "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/ivrsrand.dta", keepus(strata tx) nogen
drop if tx==""
gen CR = 1 if tx == "A"
replace CR = 0 if tx == "B"
drop tx 
capture label drop CR
label define CR 0 "AL" 1 "CR"
label values CR CR
order deidnum CR deidsite strata agebl female ethnic race race3 bmistrat
drop if CR==.

save randomized, replace 
//********************************************************************************//
// Follow-up 
//********************************************************************************//
merge 1:m deidnum using "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/visits.dta",  keepus(visit daysrnd daysint) 
keep if _merge ==3 
drop _merge 
keep if inlist(visit,1,11,13)
unique deidnum
recode visit (1=0) (11=1) (13=2), gen(fu)

 gen agecalc = agebl+daysrnd/365
replace agecalc=agebl if fu==0
 label var agecalc "Calc Age at Visit (agebl + daysrnd/365)"
 gen fut = daysint/365
 label var fut "Intervention Time"

//********************************************************************************//
// Age at Follow-up & Caloric Intake
//********************************************************************************//
preserve  
	use "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/teerq.dta", clear 
	recode visit (0=1) 
	egen akcal = rowtotal(acarb aprot aalc)
	sum kcal akcal if visit==0
	save teerq, replace
restore
merge 1:1 deidnum visit using teerq,  keepus(kcal akcal agevis)
drop if inlist(visit,4,5,9,12)
drop _merge 
replace agevis=agebl if fu==0
keep if CR!=.
//********************************************************************************//
//Anthropometry
//********************************************************************************//
merge 1:1 deidnum visit using "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/clwtvis.dta",  
tab _merge
drop if _merge ==2
drop _merge
//******************************************************************************//
//Percent CR 
//********************************************************************************//
preserve 
	use "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/pctcr.dta",  clear 
	gen fu = 1 if interval == 2
	replace fu = 2 if interval == 4
	keep if fu!=. 
	keep deidnum fu pctcr 
	save pctcr, replace 
restore
merge 1:1 deidnum fu using pctcr 
tab _merge
drop if _merge ==2
drop _merge
//******************************************************************************//


	
//******************************************************************************//
//Issue with AgeVis data 
//******************************************************************************//
/*
I calculated follow-up ages by hand using the days-since-randomization variable contained within the Visit file ('agecalc') and compared with the CALERIE provided computed age data contained in the TEERQ file ('agevis'). What we see is that in cases where there are substantive discrepancies, the 'agecalc' values are consistent with the intervention timeline, where as the 'agevis' variables are not. Unclear where the discrepancy comes from. But the way we chose to handle it was to correct the 'agvis' values of the discrepant case to be equal to the 'agecalc' values.

There are 4 discrepant cases and one case for which an 'agevis' value is present but there are no other data from that follow-up for that person:

| deidnum     fu   CR     agebl        agevis    agecalc   daysrnd   daysint   mclinwt   pctcr |
|----------------------------------------------------------------------------------------------|
|   53970   12mo   AL   43.8934    43.9726776          .         .         .         .       . |
|   77810   24mo   AL   35.9344    36.0136612   38.31251       868       867      73.3       . |
|   51191   24mo   AL   31.5164   31.59289617   33.88352       864       863     71.95       . |
|   84146   12mo   AL   43.3517   43.43093046     44.538       433       432      65.3       . |
|   99093   12mo   CR   26.1397   26.30410959   26.97808       306       274      56.5       . |
*/	
scatter agevis agecalc if fu>0

list deidnum fu CR agebl agevis agecalc days* mclinwt kcal akcal pctcr if agebl!=. & ((agevis==. & agecalc!=.) | abs(agevis-agecalc)>=0.5 | agevis-agebl<.5 & fu==1 | agevis-agebl<1.5 & fu==2)

//Compute Corrected Age Value 
capture drop agedwb 
gen agedwb = agevis
replace agedwb = agecalc if abs(agevis-agecalc)>=0.5 | agevis-agebl<.5 & fu==1 | agevis-agebl<1.5 & fu==2
scatter agedwb agecalc if fu>0
label var agedwb "Revised Time-Varying Age Value (combines agebl, agevis, & follow-up time vars)"
//******************************************************************************//

//********************************************************************************//
save "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIENatAgingPhenoData.dta", replace
//********************************************************************************//

