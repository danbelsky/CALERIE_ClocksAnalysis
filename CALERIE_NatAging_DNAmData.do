//ANALYSIS DATASET FOR CLOCKS PAPER - DNAm component
//global db3275 "danielbelsky"
global db3275 "db3275"
global box "Library/CloudStorage/Box-Box"
cd "/Users/$db3275/Downloads"

//******************************************************************************//
//EPIC ARRAY Batch PCs - From David Corcoran May 19, 2020
//******************************************************************************//
import delimited using "/Users/$db3275/$box/CALERIE Molecular Data Folder/DNAm_3TimePoints/AnalysisReady/CALERIE_Control_PCs.txt", delim(tab) varn(1) clear 
	forvalues v=1(1)24{
		rename pc`v' methpc`v'
		}
	keep barcode methpc* 
	save methpcs, replace


//******************************************************************************//
//DunedinPACE - from David Corcoran August 11, 2020
//******************************************************************************// 
import delimited using "/Users/$db3275/$box/CALERIE Molecular Data Folder/DNAm_3TimePoints/Results/20200811_PoAm45/CALERIE_PoAm45.txt", clear delim(tab) varn(1) 
rename id sample_name
	rename poam45 pace
	save pace, replace 
	
//********************************************************************************//
//********************************************************************************//
//Clock Data - from CPR
//********************************************************************************//
//Revised Horvath Website Clock data using corrected age values
import delimited using "/Users/$db3275/OneDrive - cumc.columbia.edu/CALERIE Molecular Data Folder/KoborLab/DNAm_3TimePoints/CPR_clocks_agedwb/CPR_agedwb_Horvath_Clocks/CALERIE_agedwb_horvath_datout.output.csv", clear 
	keep barcode sample_name dnamage dnamagehannum dnamphenoage dnamageskinbloodclock dnamgrimage
	split sample_name, parse(_) gen(X)
	gen deidnum = X1
	destring deidnum, replace force
	gen fu = 0 if X2=="base" | X3 == "base"
	replace fu = 1 if X2=="12" | X3 == "12"
	replace fu = 2 if X2=="24" | X3 == "24"
	gen REP = X2 
	replace REP= "" if inlist(X2,"base" , "12" , "24") 
//	drop if REP !="" & REP !="REP1"
	drop X1 X2 X3
	unique deidnum fu 
keep barcode sample_name deidnum fu dnamage dnamagehannum dnamphenoage dnamageskinbloodclock dnamgrimage
foreach x in deidnum fu dnamage dnamagehannum dnamphenoage dnamageskinbloodclock dnamgrimage{ 
	destring `x' , replace force 
	}
rename dnamageskinbloodclock dnamageskinblood	
keep if deidnum !=. 
save clocks, replace 
//********************************************************************************//


//******************************************************************************//
//EPIC-based Cell Counts - From CPR 
//******************************************************************************//
import delimited using "/Users/$db3275/OneDrive - cumc.columbia.edu/CALERIE Molecular Data Folder/KoborLab/DNAm_3TimePoints/Results/CALERIE_CPR_EPIC_cell_counts.csv", clear 
save cells, replace 
//*********************************************************************************//


//*********************************************************************************//
//PC Clocks - From CPR
//*********************************************************************************//
import delimited using "/Users/$db3275/OneDrive - cumc.columbia.edu/CALERIE Molecular Data Folder/KoborLab/DNAm_3TimePoints/CPR_clocks_agedwb/CPR_agedwb_PC_clocks/CALERIE_PC-clocks_agedwb_CPR_fixed.csv", clear 	
keep barcode pchorvath1 pchorvath2 pchannum pcphenoage pcgrimage
rename pchorvath2 pcskinblood 
save pcclocks, replace 


//*********************************************************************************//
//Assemble DNAm Variables
//*********************************************************************************//
use clocks, clear 
merge 1:1 barcode using pcclocks, gen(pcclocks) 
merge 1:1 barcode using cells, gen(cells)
merg 1:1 barcode using methpcs, gen(methpcs) 
count 
drop if sample_name==""
merge 1:1 sample_name using pace, nogen  
count 
order barcode sample_name deidnum fu methpc* cd8t cd4t nk bcell mono neu

//2 replicates in data 
tabmiss sample_name deidnum fu dnamage dnamagehannum dnamphenoage dnamageskinblood dnamgrimage pchorvath1 pcskinblood pchannum pcphenoage pcgrimage pcclocks cells pace if inlist(sample_name, "21216_REP1_base", "21216_REP2_base", "24064_REP1_base", "24064_REP2_base")

list sample_name deidnum fu dnamage dnamagehannum dnamphenoage dnamageskinblood dnamgrimage pchorvath1 pcskinblood pchannum pcphenoage pcgrimage pcclocks cells pace if inlist(sample_name, "21216_REP1_base", "21216_REP2_base", "24064_REP1_base", "24064_REP2_base")



drop if inlist(sample_name,"21216_REP2_base", "24064_REP2_base")
count
//*********************************************************************************//
//*********************************************************************************//
save "/Users/$db3275/OneDrive - cumc.columbia.edu/Projects/mPoA/CALERIE/MS/NatAging/Documentation/CALERIENatAgingDNAmData.dta", replace
//*********************************************************************************//
//*********************************************************************************//


tabmiss 
