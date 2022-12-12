global db3275 "danielbelsky"
//global db3275 "db3275"

use "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIEClockData.dta", clear 

gen cbage = (agebl-38)/ 10

global dcells "d_cd8t_br  d_cd4t_br d_nk_br  d_bcell_br  d_mono_br  d_neu_br"
global C "i.deidsite i.R bmistrat sex cbage"


//Clock baseline age-difference SDs for figure captions
matrix Fx = J(1,3,999)
foreach x in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage{ 
	quietly sum ad_`x'_br if fu==0 & asample ==1 
	matrix A = r(mean), r(sd), r(N)
	matrix rownames A = `x'
	matrix Fx = Fx \ A 	
	}
quietly sum pace_br if asample==1 & fu==0 
matrix A = r(mean), r(sd), r(N)
matrix rownames A = pace 
matrix Fx = Fx \ A 
matrix Fx = Fx[2...,1...]
matrix colnames Fx = M SD N 
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(BaselineAgeDiffSDs) modify	
putexcel B2 = "Means and SDs of age difference values"
putexcel B3 = matrix(Fx) ,names 

//Clock data for graphing Figure 2 of paper showing all participant data on all clocks at all timepoints
preserve 
	keep if asample==1 
	sort deidnum fu 
	//with ID - for graphing 
	export delimited deidnum CR fu dnamage_br dnamagehannum_br dnamphenoage_br dnamageskinblood_br dnamgrimage_br pace_br pchorvath1_br pcskinblood_br pchannum_br pcphenoage_br pcgrimage_br using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/Figure2ClockValues_withID.csv", delim(,) replace
	//No ID - for posting to journal
	export delimited CR fu dnamage_br dnamagehannum_br dnamphenoage_br dnamageskinblood_br dnamgrimage_br pace_br pchorvath1_br pcskinblood_br pchannum_br pcphenoage_br pcgrimage_br using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/Figure2ClockValues.csv", delim(,) replace	
restore 

//*********************************************************************************//
//Descriptives at Baseline
//*********************************************************************************//
//Data
matrix X =J(1,4,0) 
forvalues v= 0(1)2 {
	//Full CALERIE 
	count if fu == `v' & dnamage!=. & CR==0
	matrix A = r(N)
	count if fu == `v' & dnamage!=. & CR==1
	matrix A = A, r(N)
	//Analysis Sample
	count if fu == `v' & dnamage!=. & CR==0 & asample==1 
	matrix A = A, r(N)	
	count if fu == `v' & dnamage!=. & CR==1 & asample==1 
	matrix A = A, r(N)		
	matrix X = X \ A 
	}
matrix N = X[2...,1...]
matrix rownames N = Bl 12mo 24mo
matrix colnames N = AL CR ALasmple CRasample	
matrix list N
//Sex
matrix X =J(1,4,0) 
forvalues v= 0(1)1 {
	//Full CALERIE 
	count if fu == 0 & sex == `v' & CR==0
	matrix A = r(N)
	count if fu == 0 & sex == `v' & CR==1
	matrix A = A ,r(N)
	//Analysis Sample
	count if fu == 0 & sex == `v' & CR==0 & asample==1 
	matrix A = A, r(N)	
	count if fu == 0 & sex == `v' & CR==1 & asample==1 
	matrix A = A, r(N)		
	matrix X = X \ A 
	}
matrix S = X[2...,1...]
matrix rownames S = Women Men
matrix colnames S = AL CR ALasmple CRasample	
matrix list S 
//Race
matrix X =J(1,4,0) 
forvalues v= 0(1)2 {
	//Full CALERIE 
	count if fu == 0 & R == `v' & CR==0
	matrix A = r(N)
	count if fu == 0 & R == `v' & CR==1
	matrix A = A, r(N)	
	//Analysis Sample
	count if fu == 0 & R == `v' & CR==0 & asample==1 
	matrix A = A, r(N)	
	count if fu == 0 & R == `v' & CR==1 & asample==1 
	matrix A = A, r(N)		
	matrix X = X \ A 
	}
matrix R = X[2...,1...]
matrix rownames R = White Black Other 
matrix colnames R = AL CR ALasmple CRasample	
matrix list R 

//Study Site 
matrix X =J(1,4,0) 
foreach v in 858 933 1008 {
	//Full CALERIE 
	count if fu == 0 & deidsite == `v' & CR==0
	matrix A = r(N)
	count if fu == 0 & deidsite == `v' & CR==1
	matrix A = A, r(N)	
	//Analysis Sample
	count if fu == 0 & deidsite == `v' & CR==0 & asample==1 
	matrix A = A, r(N)	
	count if fu == 0 & deidsite == `v' & CR==1 & asample==1 
	matrix A = A, r(N)		
	matrix X = X \ A 
	}
matrix Site = X[2...,1...]
matrix rownames Site = A B C 
matrix colnames Site = AL CR ALasmple CRasample	
matrix list Site 

//BMI Stratum
matrix X =J(1,4,0) 
forvalues v= 1(1)2 {
	//Full CALERIE 
	count if fu == 0 & bmistrat == `v' & CR==0
	matrix A = r(N)
	count if fu == 0 & bmistrat == `v' & CR==1
	matrix A = A ,r(N)
	//Analysis Sample
	count if fu == 0 & bmistrat == `v' & CR==0 & asample==1 
	matrix A = A, r(N)	
	count if fu == 0 & bmistrat == `v' & CR==1 & asample==1 
	matrix A = A, r(N)		
	matrix X = X \ A 
	}
matrix Strat = X[2...,1...]
matrix rownames Strat = Lean Overweight
matrix colnames Strat = AL CR ALasmple CRasample	
matrix list Strat 

matrix T1A = N \ S \ R \ Site \ Strat
matrix list T1A 

preserve 
	//create variables with harmonized naming to clocks for ease of looping
	gen ad_agedwb_br=agedwb
	gen ad_kcal_br = kcal
	gen ad_pace_br = pace_br
	matrix X = J(1,8,0)
	foreach y in agedwb kcal dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage { 
		//Full CALERIE 
		sum ad_`y'_br if fu==0 & CR==0 
		matrix A = r(mean) , r(sd)
		sum ad_`y'_br if fu==0 & CR==1 
		matrix A = A , r(mean) , r(sd)
		//Analysis Sample
		sum ad_`y'_br if fu==0 & CR==0 & asample==1
		matrix A = A, r(mean) , r(sd)
		sum ad_`y'_br if fu==0 & CR==1 & asample==1
		matrix A = A , r(mean) , r(sd)
		matrix rownames A = `y'
		matrix X = X \ A 
		}
	matrix T1B = X[2...,1...]
	matrix rownames T1B = age akcal Horvath Hannum SkinBlood PhenoAge GrimAge PACE pcHorvath pcHannum pcSkinBlood pcPhenoAge pcGrimAge
	matrix colnames T1B = AL SD CR SD ALasample SD CRasample SD 
	matrix list T1B 
restore 

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(T1) modify	
putexcel B3 = matrix(T1A) ,names 
putexcel B20 = matrix(T1B) ,names 


//Correlations with Chronological Age (text)
preserve 
	matrix X = (0,0)
	foreach x in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage {
		corr `x'_br agedwb if fu==0 & asample==1
		matrix A = r(rho), r(N)
		matrix rownames A = `x'
		matrix X = X \A 
		}
	matrix X = X[2...,1...]
	matrix colnames X = r N 
	matrix list X 
restore 

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(T1) modify	
putexcel B40 ="Correlation with Chronological Age at Baseline (analysis sample)"
putexcel B41 = matrix(X) ,names 

//Comparisons of Clock values between groups (text)
preserve 
	foreach x in pace {
		gen ad_`x'_br = `x'_br
		}
	matrix X = J(1,8,999)
	foreach x in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage{
		//raw values (age diffs for clocks)
		quietly reg ad_`x'_br CR if fu==0 & asample==1
		matrix A = _b[CR], _se[CR], 2*ttail(e(df_r),abs(_b[CR]/ _se[CR])), e(N)
		matrix rownames A = `x'
		//standardized values 
		quietly reg bad_`x'_br CR if fu==0 & asample==1
		matrix A = A, _b[CR], _se[CR], 2*ttail(e(df_r),abs(_b[CR]/ _se[CR])), e(N)
		matrix rownames A = `x'
		
		matrix X = X \ A 
		}
	matrix X = X[2...,1...]
	matrix colnames X = b SE p N CohensD SE p N  
	matrix list X 
restore

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(T1) modify	
putexcel B60 ="Test of Differences at Baseline (analysis sample)"
putexcel B61 = matrix(X) ,names 

//*********************************************************************************//
//*********************************************************************************//
//MEANS 
//*********************************************************************************//
//*********************************************************************************//
//Descriptive Means
preserve 
	foreach x in pace {
		gen ad_`x'_br = `x'_br
		}
	foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage{
		if inlist(`"`y'"', "pace") {
			mean `y'_br if asample==1, over(CR fu)
			}
		else {
			mean ad_`y'_br if asample==1, over(CR fu)
			}
	matrix A = r(table)
	matrix B = A[1,1...]
	matrix C = A[5..6,1...]
	matrix D = (B',C')
	matrix `y' = D[1..3,1...], D[4..6,1...]
	matrix rownames `y' = `y' 12 24 
	matrix colnames `y' = AL ll ul CR ll ul
	} 
	matrix Fx = dnamage \ dnamagehannum \ dnamageskinblood \ dnamphenoage \ dnamgrimage \ pace \ pchorvath1 \ pchannum \ pcskinblood \ pcphenoage \ pcgrimage
	matrix list Fx
restore
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(Means) modify	
putexcel B3 = matrix(Fx) ,names 


//*********************************************************************************//
//Descriptive Means by Sex
preserve 
foreach x in pace {
	gen ad_`x'_br = `x'_br
	}
foreach S in 0 1 { 
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage{
	if inlist(`"`y'"', "pace") {
		mean `y'_br if asample==1, over(CR fu)
		}
	else {
		mean ad_`y'_br if sex == `S' & asample==1, over(CR fu)
		}
matrix A = r(table)
matrix B = A[1,1...]
matrix C = A[5..6,1...]
matrix D = (B',C')
matrix `y' = D[1..3,1...], D[4..6,1...]
matrix rownames `y' = `y' 12 24 
matrix colnames `y' = AL ll ul CR ll ul
} 
matrix Fx`S' = dnamage \ dnamagehannum \ dnamageskinblood \ dnamphenoage \ dnamgrimage \ pace \ pchorvath1 \ pchannum \ pcskinblood \ pcphenoage \ pcgrimage
matrix list Fx`S'
}
restore 
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(MeansbySex) modify	

putexcel B2 = "Women"
putexcel B3 = matrix(Fx0) ,names 
putexcel B45 = "Men"
putexcel B46 = matrix(Fx1) ,names 
//*********************************************************************************//
//*********************************************************************************//


//*********************************************************************************//
// WITHIN PERSON STABILITY ICCs 
//*********************************************************************************//
foreach T in 0 1 {	
	matrix ICC = J(1,3,999)
preserve 
	foreach x in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage{
		capture drop ad_`x'_br
		gen ad_`x'_br = `x'_br - agevis
		}
	capture drop ad_pace_br 
	gen ad_pace_br = pace_br 
	foreach x in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage pace {
		icc ad_`x'_br deidnum if CR==`T' & fu<2
		matrix A = r(icc_i),  r(icc_i_lb),  r(icc_i_ub)
		icc ad_`x'_br deidnum if CR==`T' & fu!=1
		matrix A = A \ (r(icc_i),  r(icc_i_lb),  r(icc_i_ub))
		matrix rownames A = `x'_bl12, `x'_bl24
		matrix ICC = ICC \ A
		} 
	matrix ICC_`T' = ICC[2...,1...]
	matrix colnames ICC_`T' = ICC`T' lb`T' ub`T' 
	matrix list ICC_`T' 
restore
	}
matrix ICC = ICC_0, ICC_1 
matrix list ICC , format(%9.2f)

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(ICC) modify

putexcel B2 = "Within-individual stability of DNAm measures of aging in AL (0) and CR (1)"
putexcel B3 = matrix(ICC), names

//*********************************************************************************//
// Correlations of Follow-up with Baseline
//*********************************************************************************//
	//Correlations of baseline level with level at 12mo and 24mo
foreach x in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage      { 
		capture drop ad_`x'_br
		gen ad_`x'_br = `x'_br - agevis
		}
capture drop ad_pace_br 
gen ad_pace_br = pace_br 
matrix Fx = (0,0,0,0)
foreach x in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage  pace    { 
preserve 
keep if fu!=.
keep deidnum fu CR ad_`x'_br 
	reshape wide ad_`x'_br, i(deidnum) j(fu)
	matrix A = (0)
	foreach y in 0 1 {
		corr ad_`x'_br0 ad_`x'_br1 if CR==`y'
		matrix A = A, r(rho)
		corr ad_`x'_br0 ad_`x'_br2 if CR==`y'
		matrix A = A, r(rho)
		matrix rownames A = `x'
		}
		matrix A = A[1...,2....]
		matrix Fx=Fx \ A 
restore
	}
matrix Fx = Fx[2...,1...]
matrix colnames Fx = rbl_12AL rbl_24AL rbl_12CR rbl_24CR
matrix list Fx 
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(Correlations) modify
putexcel B2 = "Correlations between Baseline Level & Follow-up Level"
putexcel B3 = matrix(Fx), names

	//Correlations of baseline level with Delta at 12mo and 24mo
matrix Fx = (0,0,0,0)
foreach x in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage  pace    { 
preserve 
keep if fu!=.
keep deidnum fu CR d_`x'_br b_`x'_br
	reshape wide d_`x'_br, i(deidnum) j(fu)
	matrix A = (0)
	foreach y in 0 1 {
		corr b_`x'_br d_`x'_br1 if CR==`y'
		matrix A = A, r(rho)
		corr b_`x'_br d_`x'_br2 if CR==`y'
		matrix A = A, r(rho)
		matrix rownames A = `x'
		}
		matrix A = A[1...,2....]
		matrix Fx=Fx \ A 
restore
	}
matrix Fx = Fx[2...,1...]
matrix colnames Fx = rbl_12AL rbl_24AL rbl_12CR rbl_24CR
matrix list Fx 
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(Correlations) modify
putexcel B45 = "Correlations between Baseline Level & Follow-up Delta"
putexcel B46 = matrix(Fx), names
//*********************************************************************************//

//*********************************************************************************//
//*********************************************************************************//
//MEANS OF CHANGE
//*********************************************************************************//
//*********************************************************************************//
//Descriptive Means
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage{
	if inlist(`"`y'"', "pace") {
		mean dad_`y'_br if asample==1, over(CR fu)
		}
	else {
		mean dad_`y'_br if asample==1, over(CR fu)
		}
matrix A = r(table)
matrix B = A[1,1...]
matrix C = A[5..6,1...]
matrix D = (B',C')
matrix `y' = D[1..3,1...], D[4..6,1...]
matrix rownames `y' = `y' 12 24 
matrix colnames `y' = AL ll ul CR ll ul
} 
matrix Fx = dnamage \ dnamagehannum \ dnamageskinblood \ dnamphenoage \ dnamgrimage \ pace \ pchorvath1 \ pchannum \ pcskinblood \ pcphenoage \ pcgrimage
matrix list Fx

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(MeansofChange) modify	

putexcel B3 = matrix(Fx) ,names 


//UN-SCALED Descriptive Means
foreach y in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage pace {
mean d_`y'_br if asample==1, over(CR fu)
matrix A = r(table)
matrix B = A[1,1...]
matrix C = A[5..6,1...]
matrix D = (B',C')
matrix `y' = D[1..3,1...], D[4..6,1...]
matrix rownames `y' = `y' 12 24 
matrix colnames `y' = AL ll ul CR ll ul
} 
matrix Fx = dnamage \ pchorvath1 \ dnamagehannum \ pchannum  \ dnamageskinblood \ pcskinblood  \ dnamphenoage \ pcphenoage \ dnamgrimage \ pcgrimage \ pace
matrix list Fx

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(UnscaledMeansofChange) modify	
putexcel B3 = matrix(Fx) ,names 

matrix Fx = J(1,8,999)
foreach y in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage dnamgrimage pcgrimage pace {
quietly mixed d_`y'_br fu##CR $C b_`y'_br if fu>0 || deidnum: fu , robust cov(unstr)
		quietly margins, over(fu CR)
		matrix A = r(table)'
		matrix A = A[1...,1],A[1...,5..6], A[1...,4]
		matrix A = (A[1,1...] \ A[3,1...]) , (A[2,1...] \ A[4,1...])
		matrix rownames A = `y' 24 
		matrix Fx  = Fx \ A 
	}
matrix FxITTunsc = Fx[2...,1...]
matrix list FxITTunsc 
matrix colnames FxITTunsc= B_AL ll ul pval B_CR ll ul pval 
matrix list FxITTunsc  

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(UnscaledMeansofChange) modify
putexcel B40 = matrix(FxITTunsc) ,names 


//*********************************************************************************//
//*********************************************************************************//
//MEANS OF CHANGE BY SEX 
//*********************************************************************************//
//*********************************************************************************//
//Descriptive Means
foreach s in 0 1 {
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage{
	if inlist(`"`y'"', "pace") {
		mean dad_`y'_br if asample==1 & sex==`s', over(CR fu)
		}
	else {
		mean dad_`y'_br if asample==1 & sex==`s', over(CR fu)
		}
matrix A = r(table)
matrix B = A[1,1...]
matrix C = A[5..6,1...]
matrix D = (B',C')
matrix `y' = D[1..3,1...], D[4..6,1...]
matrix rownames `y' = `y' 12 24 
matrix colnames `y' = AL ll ul CR ll ul
} 
matrix Fx`s' = dnamage \ dnamagehannum \ dnamageskinblood \ dnamphenoage \ dnamgrimage \ pace \ pchorvath1 \ pchannum \ pcskinblood \ pcphenoage \ pcgrimage
matrix list Fx`s'
}

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(MeansofChangebySex) modify	

putexcel B2 = "Women"
putexcel B3 = matrix(Fx0) ,names 
putexcel B45 = "Men"
putexcel B46 = matrix(Fx1) ,names 

//*********************************************************************************//
//*********************************************************************************//
// ITT Effect Sizes 
//*********************************************************************************//
//*********************************************************************************//
matrix Fx = J(1,4,999)
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage{
quietly mixed dad_`y'_br fu##CR $C bad_`y'_br if fu>0 || deidnum: fu , robust cov(unstr)
		quietly margins, dydx(CR) over(fu)
		matrix A = r(table)
		matrix A = A[1...,3..4]
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1]) \ (A[1,2],A[5,2],A[6,2],A[4,2] )
	}
matrix FxITT = Fx[2...,1...]
matrix colnames FxITT= D_ITT ll ul pval 
matrix rownames FxITT = dnamage 24 dnamagehannum 24 dnamageskinblood 24 dnamphenoage 24 dnamgrimage 24 pace 24 pchorvath 24 pchannum 24 pcskinblood 24 pcphenoage 24 pcgrimage 24
matrix list FxITT 

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(ITTtable) modify	
putexcel B3 = matrix(FxITT) ,names 
//*********************************************************************************//
//Cell count adjustments 
matrix Fx = J(1,4,999)
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage { 
quietly mixed dad_`y'_br fu##CR $C bad_`y'_br $dcells if fu>0 || deidnum: fu , robust cov(unstr)
		quietly margins, dydx(CR) over(fu)
		matrix A = r(table)
		matrix A = A[1...,3..4]
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1]) \ (A[1,2],A[5,2],A[6,2],A[4,2] )
	}
matrix FxITTcells = Fx[2...,1...]
matrix colnames FxITTcells= D_ITT ll ul pval 
matrix rownames FxITTcells = dnamage 24 dnamagehannum 24 dnamageskinblood 24 dnamphenoage 24 dnamgrimage 24 pace 24 pchorvath 24 pchannum 24 pcskinblood 24 pcphenoage 24 pcgrimage 24
matrix list FxITTcells 

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(ITTcells) modify	
putexcel B3 = matrix(FxITTcells) ,names 
//*********************************************************************************//
//Sex Differences 
matrix Fx = J(1,9,999)
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage { 
	quietly mixed dad_`y'_br fu##CR##sex $C bad_`y'_br if fu>0 || deidnum: fu , robust cov(unstr)
	quietly margins, dydx(CR) over(sex fu)
		matrix A = r(table)
		matrix A = A[1...,5..8]
	quietly margins CR##fu##sex, contrast
		matrix B = r(table)
		matrix list B 
 		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1] , A[1,2],A[5,2],A[6,2],A[4,2] , B[4,5]) \ (A[1,3],A[5,3],A[6,3],A[4,3] , A[1,4],A[5,4],A[6,4],A[4,4] , B[4,7] )
	} 
matrix FxITTbySex = Fx[2...,1...]
matrix colnames FxITTbySex= D_ITTF ll ul pval D_ITTM ll ul pval sexDpval
matrix rownames FxITTbySex = dnamage 24 dnamagehannum 24 dnamageskinblood 24 dnamphenoage 24 dnamgrimage 24 pace 24 pchorvath 24 pchannum 24 pcskinblood 24 pcphenoage 24 pcgrimage 24
matrix list FxITTbySex

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(ITTbySex) modify	

putexcel B3 = matrix(FxITTbySex) ,names 

//*********************************************************************************//
//Complier ITT 
preserve 
gen CR2 = CR 
replace CR2 = 2 if pctcr>10 & pctcr<. & CR==1
tab CR2 fu if CR==1 & asample==1 & dnamage!=.
matrix Fx = J(1,4,999)
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage { 
quietly mixed dad_`y'_br fu##CR2 $C bad_`y'_br if fu>0 || deidnum: fu , robust cov(unstr)
		quietly margins, dydx(CR2) over(fu)
		matrix A = r(table)
		matrix A = A[1...,3..6]
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1]) \ (A[1,2],A[5,2],A[6,2],A[4,2]) \ ///
						  (A[1,3],A[5,3],A[6,3],A[4,3]) \ (A[1,4],A[5,4],A[6,4],A[4,4])
		}
matrix FxITThcr = Fx[2...,1...]
matrix colnames FxITThcr= D_ITT ll ul pval 
matrix rownames FxITThcr = dnamage 24 HCR 24 dnamagehannum 24 HCR 24 dnamageskinblood 24 HCR 24 dnamphenoage 24 HCR 24 dnamgrimage 24 HCR 24 pace 24 HCR 24 pchorvath 24 HCR 24 pchannum 24 HCR 24 pcskinblood 24 HCR 24 pcphenoage 24 HCR 24 pcgrimage 24 HCR 24
matrix list FxITThcr 
restore
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(ITThcr) modify	
putexcel B3 = matrix(FxITThcr) ,names 
//*********************************************************************************//

//*********************************************************************************//
//*********************************************************************************//



//*********************************************************************************//
//*********************************************************************************//
//TOT EFFECT SIZES 
//*********************************************************************************//
//*********************************************************************************//

//*********************************************************************************//
//Test associations of baseline values of BMI and aging measures with %CR in the treatment group 
capture drop bad_mbmi 
quietly sum mbmi if fu==0
gen bad_mbmi = (b_mbmi-r(mean))/r(sd)

//Association of pre-treatment covariates & %CR 
foreach x in mbmi dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage { 
	if `"`x'"'=="mbmi" {
		mixed pctcr c.bad_`x'##fu sex c.cbage i.deidsite i.R if fu>0 & CR==1 || deidnum: fu , cov(unstr)
		margins, dydx(bad_`x') over(fu)		
		}
	else {	
		mixed pctcr c.bad_`x'_br##fu c.b_mbmi##fu c.b_mbmi##sex c.cbage i.deidsite i.R if fu>0 & CR==1 || deidnum: fu , cov(unstr)
		margins, dydx(bad_`x'_br) over(fu)
		}
	matrix A = r(table)
	matrix `x' = A[1,1...]',A[5..6,1...]', A[4,1...]'
	matrix rownames `x' = `x' 24
	}
matrix Fx = mbmi \ dnamage \ dnamagehannum \ dnamageskinblood \ dnamphenoage \ dnamgrimage \ pace \ pchorvath1 \ pchannum \ pcskinblood \ pcphenoage \ pcgrimage 
matrix list Fx 
//*********************************************************************************//
	//By Sex
foreach S in 0 1 {
foreach x in mbmi dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage { 
	if `"`x'"'=="mbmi" {
		mixed pctcr c.bad_`x'##fu c.cbage i.deidsite i.R if fu>0 & CR==1 & sex==`S' || deidnum: fu , cov(unstr)
		margins, dydx(bad_`x') over(fu)		
		}
	else {	
		mixed pctcr c.bad_`x'_br##fu c.b_mbmi##fu c.cbage i.deidsite i.R if fu>0 & CR==1 & sex==`S' || deidnum: fu , cov(unstr)
		margins, dydx(bad_`x'_br) over(fu)
		}
	matrix A = r(table)
	matrix `x' = A[1,1...]',A[5..6,1...]', A[4,1...]'
	matrix rownames `x' = `x' 24
	}
matrix Fx`S' = mbmi \ dnamage \ dnamagehannum \ dnamageskinblood \ dnamphenoage \ dnamgrimage \ pace \ pchorvath1 \ pchannum \ pcskinblood \ pcphenoage \ pcgrimage 
matrix list Fx`S'	
}
//*********************************************************************************//	
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(AssocPctCR) modify	
putexcel A3 = matrix(Fx) ,names 
putexcel A35 = "Women"
putexcel A36 = matrix(Fx0) ,names 
putexcel A70= "Men"
putexcel A71 = matrix(Fx1) ,names 	
//*********************************************************************************//
	
//*********************************************************************************//	
//Model to develop 1st stage of IV regression 
/*
Consider pre-treatment covariates: age sex site BMI 
Retain sex*bmi interaction 
*/
	//Kitchen sink saturated model (only sex, bmi, and interaction are statistically significant at alpha=0.05)
xtreg pctcr c.cbage##sex##c.b_mbmi##deidsite##fu i.R if CR==1, re i(deidnum) 
	//Refined model retaining only sex*BMI interaction 
xtreg pctcr sex##c.b_mbmi##fu cbage i.deidsite i.R if CR==1, re i(deidnum) 

//*********************************************************************************//
capture drop yhat* 
foreach t in 1 2 {
	if `t'==1 {
		local T "12 months"
		}
	else{
		local T "24 months"
		}
reg pctcr CR##sex##c.b_mbmi $C if fu==`t'
predict yhat`t'
#delimit ;
scatter pctcr yhat`t' if CR==0 & fu==`t', mcolor(navy%50) mlcolor(navy%1) msymbol(O) 
	|| scatter pctcr yhat`t' if CR==1& fu==`t', mcolor(red%70) mlcolor(red%1)  msymbol(O) 
	|| lfit pctcr yhat`t' if CR==0 & fu ==`t', lcolor(navy%75) lpattern(dash) lwidth(medthick) 
	|| lfit pctcr yhat`t' if CR==1 & fu ==`t', lcolor(red%90) lpattern(dash) lwidth(medthick) 
	scheme(s1mono) ylabel(,nogrid angle(horiz)) 
	ytitle(%CR vs Baseline, margin(small) size(medlarge)) 
	xtitle(Model Predicted %CR vs Baseline, size(medlarge))
	legend(ring(0) pos(5) cols(1) region(lcolor(white)) order(1 2) lab(1 "AL participants") lab(2 "CR participants")) 
	title(`T')
	yline(25, lcolor(gs10) lpattern(dash))
	name(FU`t', replace) nodraw
; #delimit cr 
}
graph combine FU1 FU2 ,cols(2) xsize(8) ysize(4) scheme(s1mono) ycommon xcommon
graph export "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/PredictedCR.pdf", replace	
export delimited CR fu yhat1 yhat2 pctcr using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/PredictedCR.csv", delim(,) replace	


//*********************************************************************************//
//IV REGRESSIONS 

//Rescale CR pct to a 20pct increment  
capture drop pctcr20 
gen pctcr20 = pctcr/20
	
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage { 
	matrix Fx = J(1,4,999)
	//Cross-sectional models
		//12mo
	#delimit ;
	quietly ivregress 2sls dad_`y'_br $C bad_`y'_br 
		(pctcr20=CR##sex##c.b_mbmi CR#c.bad_`y'_br) 
		if fu==1,  vce(robust); #delimit cr 
	quietly margins, dydx(pctcr20)
		matrix A = r(table)
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1])
		//24mo
	#delimit ;
	quietly ivregress 2sls dad_`y'_br $C bad_`y'_br 
		(pctcr20=CR##sex##c.b_mbmi CR#c.bad_`y'_br) 
		if fu==2, vce(robust); #delimit cr 
		quietly margins, dydx(pctcr20)
		matrix A = r(table)
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1])
	matrix `y' = Fx[2...,1...]
	matrix colnames `y'= b_`y' ll ul pval 
	matrix rownames `y'= `y'_12 `y'_24 	
	} 
matrix Fx = J(1,4,999)
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	matrix Fx = Fx \ `y' \ J(1,4,999)
	}
matrix FxTOT = Fx[2...,1...]
matrix colnames FxTOT= D_TOT ll ul pval 
matrix list FxTOT
	
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(TOTtable) modify	

putexcel B3 = matrix(FxTOT) ,names 
//*********************************************************************************//
	//CELL COUNT ADJUSTMENT 

//Rescale CR pct to a 20pct increment  
capture drop pctcr20 
gen pctcr20 = pctcr/20
	
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	matrix Fx = J(1,4,999)
	//Cross-sectional models
		//12mo
	#delimit ;
	quietly ivregress 2sls dad_`y'_br $C $dcells bad_`y'_br 
		(pctcr20=CR##sex##c.b_mbmi CR#c.bad_`y'_br) 
		if fu==1,  vce(robust); #delimit cr 
	quietly margins, dydx(pctcr20)
		matrix A = r(table)
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1])
		//24mo
	#delimit ;
	quietly ivregress 2sls dad_`y'_br $C $dcells bad_`y'_br 
		(pctcr20=CR##sex##c.b_mbmi CR#c.bad_`y'_br) 
		if fu==2, vce(robust); #delimit cr 
		quietly margins, dydx(pctcr20)
		matrix A = r(table)
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1])
	matrix `y' = Fx[2...,1...]
	matrix colnames `y'= b_`y' ll ul pval 
	matrix rownames `y'= `y'_12 `y'_24 	
	} 
matrix Fx = J(1,4,999)
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	matrix Fx = Fx \ `y' \ J(1,4,999)
	}
matrix FxTOTcells = Fx[2...,1...]
matrix colnames FxTOTcells= D_TOT ll ul pval 
matrix list FxTOTcells
	
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(TOTcells) modify	

putexcel B3 = matrix(FxTOTcells) ,names 
//*********************************************************************************//
	//SEX DIFFERENCES
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	foreach s in 0 1{ 
		matrix Fx = J(1,4,999)
		//Cross-sectional models
			//12mo
		#delimit ;
		quietly ivregress 2sls dad_`y'_br $C bad_`y'_br 
			(pctcr20=CR##c.b_mbmi CR#c.bad_`y'_br) 
			if fu==1 & sex==`s',  vce(robust) ; #delimit cr 
		quietly margins, dydx(pctcr20)
			matrix A = r(table)
			matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1])
			//24mo
		#delimit ;
		quietly ivregress 2sls dad_`y'_br $C bad_`y'_br 
			(pctcr20=CR##c.b_mbmi CR#c.bad_`y'_br) 
			if fu==2 & sex==`s',  vce(robust) ; #delimit cr 
		quietly margins, dydx(pctcr20)
			matrix A = r(table)
			matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1])
		matrix `y'`s' = Fx[2...,1...]
		matrix colnames `y'`s'= b_`y' ll ul pval 
		matrix rownames `y'`s'= `y'_12 `y'_24 	
		} 
	matrix `y' = `y'0, `y'1
	}
matrix Fx = J(1,8,999)
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	matrix Fx = Fx \ `y' 
	}
matrix FxTOTbySex = Fx[2...,1...]
matrix colnames FxTOTbySex= D_TOTF ll ul pval D_TOTM ll ul pval 
matrix list FxTOTbySex
	
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(TOTbySex) modify	

putexcel B3 = matrix(FxTOTbySex) ,names 
//*********************************************************************************//
//*********************************************************************************//

//ITT for age accel resids
matrix Fx = J(1,4,999)
foreach y in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage  dnamgrimage pcgrimage {
preserve 
	sum aar_`y'_br if fu==0
	replace d_aar_`y'_br = d_aar_`y'_br/r(sd)
quietly mixed d_aar_`y'_br fu##CR $C b_aar_`y'_br if fu>0 || deidnum: fu , robust cov(unstr)
		quietly margins, dydx(CR) over(fu)
		matrix A = r(table)
		matrix A = A[1...,3..4]
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1]) \ (A[1,2],A[5,2],A[6,2],A[4,2] )
restore
	}
matrix FxITTaa = Fx[2...,1...]
matrix colnames FxITTaa= D_ITT ll ul pval 
matrix rownames FxITTaa = Horvath 24 PCHorvath 24 Hannum 24 PCHannum 24 SkinBlood 24 PCSkinBlood 24 PhenoAge 24 PCPhenoAge 24 Grimage 24 PCGrimAge 24
matrix list FxITTaa 

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(ITTtable_aar) modify	
putexcel B3 = matrix(FxITTaa) ,names 


// ITT for diff in raw clock age 
matrix Fx = J(1,4,999)
foreach y in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage  dnamgrimage pcgrimage  pace{
quietly mixed d_`y'_br fu##CR $C b_`y'_br if fu>0 || deidnum: fu , robust cov(unstr)
		quietly margins, dydx(CR) over(fu)
		matrix A = r(table)
		matrix A = A[1...,3..4]
		matrix Fx  = Fx \ (A[1,1],A[5,1],A[6,1],A[4,1]) \ (A[1,2],A[5,2],A[6,2],A[4,2] )
	}
matrix FxITTrd = Fx[2...,1...]
matrix colnames FxITTrd= D_ITT ll ul pval 
matrix rownames FxITTrd = Horvath 24 PCHorvath 24 Hannum 24 PCHannum 24 SkinBlood 24 PCSkinBlood 24 PhenoAge 24 PCPhenoAge 24 Grimage 24 PCGrimAge 24 Pace 24
matrix list FxITTrd 

putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(ITTtable_rawdiff) modify	
putexcel B3 = matrix(FxITTrd) ,names 

//*********************************************************************************//
//*********************************************************************************//
//SCATTERPLOTS OF AGE CORRELATIONS 
//*********************************************************************************//
label var pchorvath1 "PC Horvath Clock"
label var pchannum "PC Hannum Clock"
label var pcskinblood "PC Skin & Blood Clock"
label var pcphenoage "PC PhenoAge Clock"
label var pcgrimage "PC GrimAge Clock"
label var dnamageskinblood "Skin & Blood Clock"
label var pace "DunedinPACE"
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pchorvath1 pchannum pcskinblood pcphenoage pcgrimage pace{ 
	local T: variable label `y'
	#delimit ;
	twoway scatter `y'_br agebl if sex ==0 & fu==0, mcolor(pink%75) msymbol(Oh) msize(medlarge)
		|| scatter `y'_br agebl if sex ==1 & fu==0, mcolor(blue%75) msymbol(+) msize(medlarge)
		|| lfit `y'_br agebl if sex ==0 & fu==0, lcolor(pink) lpattern(solid) lwidth(medthick)
		|| lfit `y'_br agebl if sex ==1 & fu==0, lcolor(blue)  lpattern(solid) lwidth(medthick)
		ytitle(`T', size(medlarge) margin(small))
		xtitle(Chronological Age, size(medlarge))
		ylabel(,labsize(medlarge) format(%9.0f))
		xlabel(,labsize(medlarge))
		legend(ring(0) pos(11) cols(1) order(1 2) lab(1 "Women" ) lab(2 "Men"))
		scheme(plotplain)
		name(`y', replace) nodraw
		; #delimit cr
	}
	
graph combine dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage  dnamgrimage pcgrimage pace, scheme(s1mono) cols(2) xsize(8) ysize(14) name(agecorr, replace)
graph export "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/AgeCorrelations.pdf", replace
export delimited dnamage_br dnamagehannum_br dnamageskinblood_br dnamphenoage_br dnamgrimage_br pchorvath1_br pchannum_br pcskinblood_br pcphenoage_br pcgrimage_br pace_br agebl sex using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/AgeCorrelations.csv", delim(,) replace


matrix X = (0,0,0)
foreach x in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	corr `x'_br agebl if fu==0
	matrix A = r(rho)
	corr `x'_br agebl if fu==0 & sex==0
	matrix A = A, r(rho)
	corr `x'_br agebl if fu==0 & sex==1
	matrix A = A, r(rho)	
	matrix rownames A = `x'
	matrix X = X \ A 
	}
matrix X = X[2...,1...]
matrix colnames X = rho	W M 
matrix list X , format(%9.2f)
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(BaselineAgeCorr) modify	
putexcel B3 = matrix(X) ,names 


//*********************************************************************************//
//*********************************************************************************//
//SCATTERPLOTS OF CORRELATIONS w/ BMI @ Baseline
//*********************************************************************************//
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pchorvath1 pchannum pcskinblood pcphenoage pcgrimage pace{ 
	local T: variable label `y'
	#delimit ;
	twoway scatter bad_`y'_br mbmi if sex ==0 & fu==0, mcolor(pink%75) msymbol(Oh) msize(medlarge)
		|| scatter bad_`y'_br mbmi if sex ==1 & fu==0, mcolor(blue%75) msymbol(+) msize(medlarge)
		|| lfit bad_`y'_br mbmi if sex ==0 & fu==0, lcolor(pink) lpattern(solid) lwidth(medthick)
		|| lfit bad_`y'_br mbmi if sex ==1 & fu==0, lcolor(blue)  lpattern(solid) lwidth(medthick)
		ytitle(`T', size(medlarge) margin(small))
		xtitle(BMI at Baseline, size(medlarge))
		ylabel(,labsize(medlarge) format(%9.0f))
		xlabel(,labsize(medlarge))
		legend(off)
		scheme(plotplain)
		name(`y', replace) nodraw
		; #delimit cr
	}
restore 
graph combine dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage  dnamgrimage pcgrimage pace, scheme(s1mono) cols(2) xsize(8) ysize(14) name(bmicorr, replace)
graph export "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/BMICorrelations.pdf", replace
export delimited bad_dnamage_br bad_dnamagehannum_br bad_dnamageskinblood_br bad_dnamphenoage_br bad_dnamgrimage_br bad_pchorvath1_br bad_pchannum_br bad_pcskinblood_br bad_pcphenoage_br bad_pcgrimage_br bad_pace_br mbmi using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/BMICorrelations.csv", delim(,) replace

preserve 
foreach x in pace { 
reg `x'_br cbage if fu==0
predict aar_`x'_br, r  
}
matrix X = (0,0,0)
foreach x in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	corr aar_`x'_br agebl if fu==0
	matrix A = r(rho)
	corr aar_`x'_br agebl if fu==0 & sex==0
	matrix A = A, r(rho)
	corr aar_`x'_br agebl if fu==0 & sex==1
	matrix A = A, r(rho)	
	matrix rownames A = `x'
	matrix X = X \ A 
	}
matrix X = X[2...,1...]
matrix colnames X = rho	W M 
matrix list X , format(%9.2f)
restore 
putexcel set "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIETables.xlsx", sheet(BaselineBMICorr) modify	
putexcel B3 = matrix(X) ,names 



	
	
	
	
