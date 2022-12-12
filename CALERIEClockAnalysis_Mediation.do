global db3275 "danielbelsky"
//global db3275 "db3275"

use "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIEClockData.dta", clear 

gen cbage = (agebl-38)/ 10

global dcells "d_cd8t_br  d_cd4t_br d_nk_br  d_bcell_br  d_mono_br  d_neu_br"
global C "i.deidsite i.R bmistrat sex cbage"


//Treatment Completion for Sample Tracking 
capture drop _merge 
merge m:1 deidnum using  "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/subject1.dta", keepus(txcomp)
drop if _merge ==2 
drop _merge

//BA vars from Kwon paper
preserve 
import delimited using "/Users/$db3275/Dropbox (Personal)/KownBioAgePackage/Geroscience/Data/CALERIE_Geroscience.csv", clear delim(comma) varn(1)
drop if deidnum ==. | fu==.
duplicates report deidnum fu 
save temp, replace 
restore 
merge m:1 deidnum fu using temp, keepus(kdm* phenoage* hd_log*)
destring kdm* phenoage* hd_log*, replace force 

tab deidsite, gen(Site)
tab R, gen(Race)
global C "Site* Race* bmistrat sex cbage"

	
//*****************************************************************************//
// MEDIATION ANALYSIS
//*****************************************************************************//

capture drop _merge 
replace visit =0 if visit == 1 

//RMR Residual 
merge 1:1 deidnum visit using "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/rmrresid.dta", nogen keepus(rmrresid) 
drop if fu==. | sex==.
//Systolic BP 
merge 1:1 deidnum visit using "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/vitalsa.dta", nogen keepus(meansbp meandbp meanbp meanwst)
drop if fu==. | sex==.
//BLOOD BIOMARKERS 
#delimit ;
merge 1:1 deidnum visit using "/Users/$db3275/OneDrive - cumc.columbia.edu/CalerieRCT/STATA_Database/analysis_datasets/oclabflt.dta", nogen keepus( 
	crp
	hdl ldl chol trig
	ins0 homair aucins insresp inssens  
	sgl0 /*aucgluc odindex*/ 
	homabeta
	/*tnfa il6 il8*/)
; #delimit cr 

drop if fu==. | sex==.

//*********************************************//
//Metabolic Syndrome Coded per Kraus 2019 Paper 
//*********************************************//
gen MAP = (2*meandbp / meansbp )/3 
//WOMEN
foreach x in hdl trig chol sgl0 meanwst MAP {
	quietly sum `x' if fu==0 & sex ==0 
	gen z`x'=(`x'-r(mean))/r(sd) if sex==0
	}
//MEN
foreach x in hdl trig chol sgl0 meanwst MAP {
	quietly sum `x' if fu==0 & sex ==1
	replace z`x'=(`x'-r(mean))/r(sd) if sex==1
	}
egen metsyn = rowmean(zhdl ztrig zchol zsgl0 zmeanwst zMAP)
replace metsyn = metsyn*6 
//*********************************************//

	//transformations
foreach x in trig /*tnfa il6 il8*/ {
	capture drop ln`x'
	gen ln`x'=ln(`x'+1)
	}
capture drop lncrp
gen lncrp = ln(crp)

//Change in PACE by 12mo 
capture drop X 
gen X = d_pace_br if fu==1 
egen d12pace = max(X), by(deidnum)
drop X 

//Change in BMI by 12mo as % of baseline 
capture drop X 
gen X = (mbmi-b_mbmi)/b_mbmi if fu==1 
egen d12bmip = max(X), by(deidnum)
drop X 

//PCT CR by 12mo 
capture drop X 
gen X = pctcr if fu==1
egen d12pctcr = max(X), by(deidnum)
drop X 


//Blood Chem Bio Age Vars
gen KDM=kdm_advance_v2 
gen PhenoAge = phenoage_advance_v2
gen HD = hd_log_v2 

//Create change scores and baseline scores for outcome vars 
capture program drop blch
program define blch 
args X 
tempvar v1
gen `v1' = `X' if fu==0
	capture drop b_`X'
	egen b_`X' = max(`v1'), by(deidnum) 
capture drop d_`X'
	gen d_`X' = `X'-b_`X'
end 

#delimit ;
foreach x of varlist 
	crp lncrp 
	hdl ldl chol trig lntrig
	ins0 homair aucins insresp inssens  
	sgl0 
	homabeta
	meansbp meandbp meanbp meanwst
	metsyn 
	KDM PhenoAge HD { ; #delimit cr
	blch `x'
	}
	
//Change in Blood Chem BioAge by 12mo
foreach x of varlist KDM PhenoAge HD {
	gen X = d_`x' if fu==1
	egen d12`x'= max(X) , by(deidnum) 	
	drop X 
	}	

save temp, replace 

global C "Site1 Site3 Race2 Race3 b_mbmi sex cbage"


//Sample for mediation analysis -- defined as anyone contributing any data
capture drop X   
  #delimit ; 
egen X = rownonmiss(crp lncrp 
	hdl ldl chol trig lntrig
	ins0 homair aucins insresp inssens 
	homabeta
	meansbp meandbp meanbp meanwst
	metsyn 
	KDM PhenoAge) ; #delimit cr 
tab X 
unique deidnum if X !=0 & asample==1
	
	
//Screen for association with PACE 
preserve 
use temp, clear 
matrix Fx = J(1,5,999) 
capture drop zpace 
quietly sum pace_br if fu==0
gen zpace = (pace_br-r(mean)) / r(sd)
#delimit ; 
foreach Y in crp lncrp 
	hdl ldl chol trig lntrig
	ins0 homair aucins insresp inssens 
	homabeta
	meansbp meandbp meanbp meanwst
	metsyn 
	KDM PhenoAge  { ; #delimit cr 
capture drop z`Y' 
quietly sum `Y' if fu==0
gen z`Y' = (`Y'-r(mean)) / r(sd)
reg z`Y' zpace i.deidsite i.bmistrat sex i.R cbage if fu==0, robust
matrix A = _b[zpace], _b[zpace]- invttail(e(df_r),0.025)*_se[zpace], _b[zpace]+ invttail(e(df_r),0.025)*_se[zpace], 2*ttail(e(df_r), abs(_b[zpace]/_se[zpace])), e(N)
matrix rownames A = `Y'
matrix Fx = Fx \ A 
	}
matrix Fx = Fx[2...,1...]
matrix colnames Fx = b lb ub p N 
matrix list Fx

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(PACE_BiomarkerAssoc) modify
putexcel B1 = "Baseline_PACEAssoc"
putexcel B2 = matrix(Fx), names
restore

preserve 
clear 
svmat2 Fx , names(col) rnames(X) 
gen Z = _n
capture label drop Z 
#delimit ; 
label define Z 
1 "CRP"
2 "lnCRP"
3 "HDL"
4 "LDL"
5 "TotChol"
6 "Triglycerides"
7 "lnTriglycerides"
8 "Fasting Insulin"
9 "HOMA-IR"
10 "AUC Insulin"
11 "Insulin Response"
12 "Insulin Sensitivity"
13 "HOMA Beta"
14 "SBP"
15 "DBP"
16 "MAP"
17 "Waist Circumference"
18 "Metabolic Syndrome Score"
19 "KDM BA Advance"
20 "PhenoAge Advance" ; #delimit cr 
label values Z Z

#delimit ; 
twoway rcap lb ub Z, lpattern(solid) lcolor(navy%70) horiz
	|| scatter Z b , msymbol(O) msize(large) mcolor(dknavy) 
	ylabel(
1 "CRP"
2 "lnCRP"
3 "HDL"
4 "LDL"
5 "TotChol"
6 "Triglycerides"
7 "lnTriglycerides"
8 "Fasting Insulin"
9 "HOMA-IR"
10 "AUC Insulin"
11 "Insulin Response"
12 "Insulin Sensitivity"
13 "HOMA Beta"
14 "SBP"
15 "DBP"
16 "MAP"
17 "Waist Circumference"
18 "Metabolic Syndrome Score"
19 "KDM BA Advance"
20 "PhenoAge Advance"
, angle(horiz))
xlabel(,labsize(medlarge)) 
xtitle("Effect-size (Z-score units)", margin(small))
yscale(rev)
ytitle("")
legend(off)
scheme(plotplain)
	xline(0, lcolor(gs10)) 
	xline(-.1, lcolor(red)) 
	xline(.1, lcolor(red)) 
title(Associations of DunedinPACE with Clinical Measures at Baseline)
name(PACEFx, replace)
; #delimit cr 
restore 
graph export "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/PACEFxClinicalVarsBaseline.pdf", replace
export delimited using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/PACEFxClinicalVarsBaseline.csv", delim(,) replace

//MEDIATION ANALYSIS 
//CR-->DeltaPACE at 24mo--DeltaBloodChem at 24mo
use temp, clear 
preserve 
matrix Fx = J(1,9,999)
#delimit ; 
foreach x in crp lncrp 
	hdl ldl chol trig lntrig
	ins0 homair aucins insresp inssens 
	homabeta
	meansbp meandbp meanbp meanwst
	metsyn 
	KDM PhenoAge   { ; 
	quietly sum `x' if fu==0 ;
	replace b_`x' = (`x'-r(mean))/r(sd) ;
	replace d_`x' = d_`x'/r(sd) ;
	medeff (regress d_pace_br CR $C b_`x') (regress d_`x' d_pace_br CR $C  b_`x') if fu==2, 
			mediate(d_pace_br) treat(CR) seed(1) ;
	matrix A = r(tau), r(taulo) , r(tauhi), 
				r(navg), r(navglo), r(navghi), 
				r(delta1), r(delta1lo), r(delta1hi) ; #delimit cr
	matrix rownames A = `x'
	matrix Fx = Fx \ A 
	} 
restore
matrix FxConc = Fx[2...,1...]
matrix colnames FxConc = TotEff lb ub PctMed lb ub ACME lb ub 
matrix list FxConc, format(%9.2f)

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(MEDIATION) modify
putexcel B1 = "CR->24moPACE-->24moBloodChem"
putexcel B2 = matrix(FxConc), names


preserve 
matrix X = FxConc
matrix colnames X = TE telb teub PctMed lb ub ACME acmelb acmeub
matrix list X 
clear 
svmat2 X , names(col) 
drop if _n==12
gen Z= _n
#delimit ; 
twoway bar TE Z , color(navy)  horiz 
	|| bar ACME Z, color(cranberry) horiz
ytitle("")
yscale(rev)
ylabel(,labsize(medlarge)) 
	ylabel(
1 "CRP"
2 "lnCRP"
3 "HDL"
4 "LDL"
5 "TotChol"
6 "Triglycerides"
7 "lnTriglycerides"
8 "Fasting Insulin"
9 "HOMA-IR"
10 "AUC Insulin"
11 "Insulin Response"
12 "HOMA Beta"
13 "SBP"
14 "DBP"
15 "MAP"
16 "Waist Circumference"
17 "Metabolic Syndrome Score"
18 "KDM BA Advance"
19 "PhenoAge Advance"
, angle(horiz)) 
legend(pos(3) cols(1) 
	lab(1 "Total Effect") lab(2 "Mediated Effect") 
	region(lcolor(white)) symxsize(5) 
	)
xtitle("Treatment Effect (Cohen's d)", margin(small))
xscale(rev)
xlabel(,angle(horiz) labsize(medlarge) format(%9.1f))
scheme(plotplain)
title(DunedinPACE Mediation of CR Treatment Effects at 24mo)
name(PACE_MedPct24mo, replace)	
; #delimit cr 
graph export "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/R1/Figures/MediationFx.pdf", replace 

graph export "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/MediationFx.pdf", replace
export delimited using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/MediationFx.csv", delim(,) replace





