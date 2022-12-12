//global db3275 "danielbelsky"
global db3275 "db3275"

use "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIEClockData.dta", clear 

gen cbage = (agebl-38)/ 10

global dcells "d_cd8t_br  d_cd4t_br d_nk_br  d_bcell_br  d_mono_br  d_neu_br"
global C "i.deidsite i.R bmistrat sex cbage"


matrix Fx = J(1,5,999)
foreach y in dnamage pchorvath1 dnamagehannum pchannum dnamageskinblood pcskinblood dnamphenoage pcphenoage  dnamgrimage pcgrimage  pace{
quietly mixed d_`y'_br fu##CR $C b_`y'_br if fu>0 || deidnum: fu , robust cov(unstr)
		quietly margins, over(CR fu)
		matrix A = r(table)
		matrix A = A[1,1...] \ A[5..6,1...]
		matrix A = A'
		matrix A = (0,0,0,0,0) \ (0,1,0,0,0) \ (1,0,A[1,1...]) \ (1,1,A[3,1...]) \ (2,0,A[2,1...]) \ (2,1,A[4,1...])
		matrix Fx  = Fx \ A
	}
matrix Fx = Fx[2...,1...]
matrix colnames Fx= fu CR b lb ub 
forvalues x = 1(1)11{
	matrix clock`x'=J(6,1,`x')
	}
matrix X = clock1 
forvalues x=2(1)11{
	matrix X = X \ clock`x'
	}
matrix colnames X = clock 
matrix Fx = X, Fx 
preserve 
clear 
svmat2 Fx, names(col) 
capture label drop clock 
label define clock 1 dnamage 2 pchorvath1 3 dnamagehannum 4 pchannum 5 dnamageskinblood 6 pcskinblood 7 dnamphenoage 8 pcphenoage 9 dnamgrimage 10 pcgrimage  11 pace
label values clock clock 
export delimited using "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/Figures/ITTFx.csv", delim(,) replace








/*



matrix rownames FxITTrd = Horvath 24 PCHorvath 24 Hannum 24 PCHannum 24 SkinBlood 24 PCSkinBlood 24 PhenoAge 24 PCPhenoAge 24 Grimage 24 PCGrimAge 24 Pace 24
matrix list FxITTrd 




//Means predicted in mixed effects models
foreach y in dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pace pchorvath1 pchannum pcskinblood pcphenoage pcgrimage  { 
	local T: variable label `y'
	quietly mixed d_`y'_br fu##CR $C b_`y'_br  || deidnum: fu , robust 
	margins, over(fu CR)
	#delimit ; 
	marginsplot ,
	plot1opts(lwidth(medthick) msize(vlarge) msymbol(O) mcolor(dknavy) lcolor(dknavy))
	plot2opts(lwidth(medthick) msize(vlarge) msymbol(T) mcolor(red) lcolor(red))
	ci1opts(lwidth(medthick) lcolor(dknavy))
	ci2opts(lwidth(medthick) lcolor(red))
	legend(ring(0) pos(11) cols(1) symxsize(5) size(large))
	yline(0,lcolor(gs10))
	xscale(range(-.25 2.25))
	/*yscale(range(-.25 2.75))*/
	xlabel(,labsize(medlarge))
	ylabel(, format(%9.2f) labsize(medlarge))
	ytitle(Change from Baseline, margin(small) size(medlarge))
	xtitle("") 
	title(`T', size(large))
	scheme(plotplain)
	name(`y',replace) nodraw
	; #delimit cr 
}
graph combine dnamage dnamagehannum dnamageskinblood dnamphenoage dnamgrimage pchorvath1 pchannum pcskinblood pcphenoage pcgrimage pace, scheme(s1mono) cols(2) xsize(8) ysize(14) name(txfx, replace)



	
	
	
	
	
	
	

