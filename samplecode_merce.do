********************************************************************************
*              Sample Code Mercè Capell - Big Five Questionnaire			   *
********************************************************************************
/*
* Creator: Mercè Capell
* Creation date: 25/03/2025
* Purpose: Import, Cleaning and Analysis of a students survey on Big Five Skills at Baseline and Endline.
  > Inputs:
	* Baseline: "$raw/baseline.xlsx"
	* Endline: "$raw/endline.xlsx"
	* Assignment: "$raw/assignment.xlsx"
			
  > Output: 
	* Dataset"$output/bfi_measure_cleandataset"
	* Tables/Graphs:
		- "$output/bfi_domain_distributions.png" //Distributions
		- "$output/bfi_domain_balance.tex" //Balance table at Baseline, controlling for endline.
		- "$output/bfi_dom_olsregression.tex" //OLS regression, controlling for baseline.
  
  /!\ This sign indicate codelines where additional attention is needed, as drop/keep decicions have been taken.
  
*/
********************************************************************************
********************************************************************************
*				0 Globals: Directory, Paths and Ado.
********************************************************************************
//Directory
global mydirectory " " // Please change your DIRECTORY here to ensure replication. (i.e. C:/Users/mcapell/Desktop/CodeTest_MerceMCapell)

//Activate Paths
global raw "${mydirectory}/raw"
global ado "${mydirectory}/ado"
global output "${mydirectory}/output"

//Activate Ado Files
cap prog drop bfi_measure dupvar
run "$ado/bfi_measure.ado"
run "$ado/dupvar.ado"

********************************************************************************
*				1 Data Import and Merging
********************************************************************************
*1.1) Import Baseline and Endline Data
import excel "$raw/baseline.xlsx", allstring firstrow clear
gen survey="Baseline" //indicator of baseline data

preserve
	import excel "$raw/endline.xlsx", allstring firstrow clear
	rename school idschl // cleaning to ensure correct append with endline data
	rename student idstudent  // cleaning to ensure correct append with endline data
	gen survey="Endline" //indicator of endline data
	tempfile endlinedata
	save `endlinedata'
restore

*1.2) Append Endline Data
sort idschl group idstudent
append using `endlinedata'

encode survey, gen(sround) //numeric transf. survey round variable
drop survey
rename sround survey

*1.3) Merge Assignment Data
preserve
	import excel "$raw/assignment.xlsx", allstring firstrow clear
	rename id idstudent //cleaning to ensure merge with assignment data.
	rename school idschl
	rename group group_f // this is the group variable used as reference.
	
	label define treat 0 "Control" 1 "Treatment"
	encode treatassign, gen(treat_assignment) label(treat)
	label var treat_assignment "Treatment Assignment"
	
	duplicates drop	//!\ 126 observations dropped 25/03/2024.
	drop if group=="" //!\ drop 2 testing observations 25/03/2024.
	isid idschl idstudent group //check distinct stud obs.
	
	gen grade=substr(group, -2,1) if strlen(group)==2
	replace grade="4" if group_f=="4optativa" //corrections of other types of groups
	replace grade="3" if group_f=="3AB"
	replace grade="A" if group_f=="A30"
	lab var grade "Grade Level"
	
	drop treatassign
		
	tempfile assignment
	save `assignment'
restore

sort idschl idstudent 
merge m:1 idschl idstudent using `assignment', gen(m_assignment)

drop if m_assignment==2 //!\ students not part of the study. 2361 observations dropped by 25/03/2024.
drop if m_assignment==1 //!\ testing observations. 2 observations dropped by 25/03/2024.

********************************************************************************
*      			2 Variables Cleaning
********************************************************************************
*2.1) Cleaning of NonNumeric Characaters
forval v=1/30 {
    tab bfi_q`v' if missing(real(bfi_q`v')) // check, spot nonummeric characters.
}
replace bfi_q13="-99" if bfi_q13=="/./" //decision, -99 stands for non-valid values.

*2.2) Recodify Big Five Values
//Note: Big Five measure has been programmed to record values from 1 to 5, allowing to skip questions. However, some questions were not programmed correctly and rather allowed entry of 0 values.
label define bfi_labels 1 "Strongly disagree" ///
                            2 "Disagree" ///
                            3 "Neutral" ///
                            4 "Agree" ///
                            5 "Strongly agree" ///
							.d "Non Valid" ///
                            .m "Missing" ///
				   
forval v=1/30 { //apply labels
	rename bfi_q`v' qst_bfi_q`v'
    destring qst_bfi_q`v', replace
	pause
	recode  qst_bfi_q`v' (1=1) (2=2) (3=3) (4=4) (5=5) (missing = .m) (nonmissing= .d)
    label values qst_bfi_q`v' bfi_labels
}

*2.3) Big Five Variable Names
lab var qst_bfi_q1 "BFI 30, Q1: Is outgoing, sociable"
lab var qst_bfi_q2 "BFI 30, Q2: Is compassionate, has a soft heart"
lab var qst_bfi_q3 "BFI 30, Q3: Tends to be disorganized"
lab var qst_bfi_q4 "BFI 30, Q4: Is relaxed, handles stress well"
lab var qst_bfi_q5 "BFI 30, Q5: Has few artistic interests"
lab var qst_bfi_q6 "BFI 30, Q6: Is respectful, treats others with respect"
lab var qst_bfi_q7 "BFI 30, Q7: Tends to find fault with others"
lab var qst_bfi_q8 "BFI 30, Q8: Is fascinated by art, music or literature"
lab var qst_bfi_q9 "BFI 30, Q9: Is dominant, acts like a leader"
lab var qst_bfi_q10 "BFI 30, Q10: Has difficulty getting started on tasks"
lab var qst_bfi_q11 "BFI 30, Q11: Feels secure, comfortable with self"
lab var qst_bfi_q12 "BFI 30, Q12: Is less active than other people"
lab var qst_bfi_q13 "BFI 30, Q13: Can be somewhat careless"
lab var qst_bfi_q14 "BFI 30, Q14: Is emotionally stable, not easily upset"
lab var qst_bfi_q15 "BFI 30, Q15: Has little creativity"
lab var qst_bfi_q16 "BFI 30, Q16: Tends to be quiet"
lab var qst_bfi_q17 "BFI 30, Q17: Kees things neat and tidy"
lab var qst_bfi_q18 "BFI 30, Q18: Worries a lot"
lab var qst_bfi_q19 "BFI 30, Q19: Is sometimes rude to others"
lab var qst_bfi_q20 "BFI 30, Q20: Is reliable can always be counted on"
lab var qst_bfi_q21 "BFI 30, Q21: Is complex, a deep thinker"
lab var qst_bfi_q22 "BFI 30, Q22: Is full of energy"
lab var qst_bfi_q23 "BFI 30, Q23: Can be cold and uncaring"
lab var qst_bfi_q24 "BFI 30, Q24: Prefers to have others take charge"
lab var qst_bfi_q25 "BFI 30, Q25: Is persistent, works until the task is finished"
lab var qst_bfi_q26 "BFI 30, Q26: Tends to feel depressed, blue"
lab var qst_bfi_q27 "BFI 30, Q27: Has little interest in abstract ideas"
lab var qst_bfi_q28 "BFI 30, Q28: Assumes the best out of people"
lab var qst_bfi_q29 "BFI 30, Q29: Is temperamental, gets emotional easily"
lab var qst_bfi_q30 "BFI 30, Q30: Is original, comes up with new ideas"

*2.3) Cleaning of date variable
foreach var in  qst_startdate qst_enddate  { //cleaning dates
    split `var', parse(" ")
	rename `var' `var'time
	rename `var'1 `var'
	drop `var'2
	gen `var'_c= date(`var', "MDY")
	rename `var' `var'_str
	rename `var'_c `var'
	format %td `var'
	}

label var qst_startdate "Start Date"
label var qst_enddate "End Date"

*2.4) Cleaning of missing string variables
ds, has(type string)
global varlist_string `r(varlist)'
display "$varlist_string"
foreach v in $varlist_string{
    replace `v'= ".m" if `v'=="." //codify as "missings"
	replace `v'= ".n" if `v'=="" //codify as "does not apply"
}

********************************************************************************
*      			4 Observations Cleaning
********************************************************************************
*3.1) Duplicates, repeated observations at the survey round.
dupvar idstudent idschl group survey qst_startdate qst_enddate
drop if dup>1 // 9 obs, by 25/03/2024. Exact duplicates, generated fue to problems with the IT platform.
drop dupvar

dupvar idstudent idschl group survey //1 observations by 25/03/2024, duplicates of surveys done in two different dates.
drop if qst_startdate_str=="3/1/2023" & idschl=="A10188" & dupvar!=0 //!\ all observations in that group done 17-23 March.
drop dupvar

isid idstudent group_f survey // check, distinct observations at the student level, each survey round.

*3.4) Share of missings in Big Five Questionnaire
foreach var of varlist qst_bfi* {
	gen m_`var'= 1 if `var' ==.m
	gen n_`var'=1 
	}

egen total_m=rowtotal(m_*)
egen total_n=rowtotal(n_*)
gen total_share= total_m/total_n
drop if total_share>0.7 //!\ 1 dropped obs., clearly observations that are all (or almost) missing. By 25/03/2024.

order idschl group_f idstudent survey treat_assignment
drop m_assignment group survey_r total_m* m_* n_* total_n total_share //drop variables not used in the analysis

********************************************************************************
*    			 5 Measures Creation and Clustering Variable
********************************************************************************
*4.1) Creation of Big Five Measures.
//Note: Ado File is run to create the 5 Big5 Domains. Measure could be created with the 15-item questionnaire. For the purposes of this analysis is not included.
bfi_measure, type(30) survey(qst)

*4.2) Save Value Labels and keep them after Reshape
foreach var in dom_bfi2s_1 dom_bfi2s_3 dom_bfi2s_2 dom_bfi2s_4 dom_bfi2s_5 {
local varlabel_`var': variable label `var'
di "`varlabel_`var''"
}

*4.2) Cluster Variable at the school and grade level
gen schgr=idschl+grade // cluster 
lab var schgr "Clustering Variable, at the School and Grade Level"

//globals
global qbfi30 dom_bfi2s_1 dom_bfi2s_2 dom_bfi2s_3 dom_bfi2s_4 dom_bfi2s_5
global cluster_var schgr

*4.3) Save Clean Dataset
save "$output/bfi_measure_cleandataset", replace

********************************************************************************
*	  			6 Analysis Dataset Preparation
*******************************************************************************
*5.1) Cleaning necessary for analysis
destring grade, replace
drop qst_bfi* qst_startdatetime qst_startdate_str qst_enddate_str qst_enddatetime qst_startdate qst_enddate gender spain
reshape wide $qbfi30 , i(idschl group_f idstudent treat_assignment schgr) j(survey)

foreach b in "1" "2" { //renaming for analysis
    foreach var in $qbfi30 {
        if "`b'" == "1" {
            rename `var'`b' bs_`var'
			label var bs_`var' "`varlabel_`var''"
        }
        else if "`b'" == "2" {
            rename `var'`b' end_`var'
			label var end_`var' "`varlabel_`var''"
        }
    }
}

********************************************************************************
*	  							7 Analysis 
*******************************************************************************
set varabbrev on
eststo clear

*5.1) Distributions at endline, only for Big Five 30q.
local n = 0
foreach var in end_dom_bfi2s_1 end_dom_bfi2s_2 end_dom_bfi2s_3 end_dom_bfi2s_4 end_dom_bfi2s_5 {
    local n = `n'+ 1
    twoway (kdensity `var' if treat_assignment == 1, bw(0.4) color(blue%50)) ///
           (kdensity `var' if treat_assignment == 0, bw(0.4) color(red%50)), ///
        title("") graphregion(color(white)) subtitle("`: var label `var''", size(small)) name(t`n', replace) title("") ///
        legend(label(1 "T") label(2 "C")) ytitle("")  // Remove y-axis label
}
graph combine t1 t2 t3 t4 t5, graphregion(color(white)) title("Big Five (30 questions): Distribution of domains")
graph export  "$output/bfi_domain_distributions.png", replace

*5.2) Balance at baseline for key outcomes
set scheme cleanplots

cap file close fh
file open fh using "$output/bfi_domain_balance.tex", write replace
    file write fh _n  "\begin{tabular}{@{}lcccccc@{}}"
    file write fh _n "\toprule"     
	file write fh _n  "" " " " & " "\multicolumn{2}{c}{\textbf{Control}}" " & " "\multicolumn{2}{c}{\textbf{Treatment}}" " & "  "\multicolumn{2}{c}{\textbf{Total}}" "\\"
        file write fh _n  "" "  " " & " "\multicolumn{1}{c}{N}" " & " "\multicolumn{1}{c}{Mean}"  " & "  "\multicolumn{1}{c}{N}" " & " "\multicolumn{1}{c}{Mean}" " & " "\multicolumn{1}{c}{N}" " & " "\multicolumn{1}{c}{Means Diff.}" "\\"

	file write fh _n "\multicolumn{3}{l}{\textit{Big Five (30q) Domains}}" "\\"
			forvalues v=1/5 {
			reg bs_dom_bfi2s_`v' treat_assignment if end_dom_bfi2s_`v'!=., vce(cluster $cluster_var)
			local treat=_b[treat]
			local treat_mean=_b[treat]+_b[_cons]
			local cons=_b[_cons]
			local se=_se[treat]
			local NT=e(N)
			if inrange(2* ttail(e(df_r), abs(_b[treat]/_se[treat])),0.000000000,0.01) local star="***"
		else if inrange(2* ttail(e(df_r), abs(_b[treat]/_se[treat])),0.01000000001,0.05) local star= "**"
		else if inrange(2* ttail(e(df_r), abs(_b[treat]/_se[treat])),0.05000000001,0.10) local star= "*"
		else local star = " "
			su bs_dom_bfi2s_`v' if (!missing(treat_assignment) & end_dom_bfi2s_`v'!=.), det
			local m1 = r(mean)
			local s1 = r(sd)
			local N1 = r(N)
			su bs_dom_bfi2s_`v' if (treat_assignment==1 & end_dom_bfi2s_`v'!=.), det
			local m2 = r(mean)
			local s2 = r(sd)
			local N2 = r(N)
			su bs_dom_bfi2s_`v' if (treat_assignment==0 & end_dom_bfi2s_`v'!=.), det
			local m3 = r(mean)
			local s3 = r(sd)
			local N3 = r(N)
			local diff=`m2'-`m3'
			ttesti `N2' `m2' `s2' `N3' `m3' `s3'
			local pval = r(p)
			local normdiff=`treat'/`s3'
			file write fh _n `"`: var label bs_dom_bfi2s_`v''"'  " & " (`N3') " & " %9.2fc (`m3')  " & " (`N2') " & "  %9.2fc (`m2')  "  & " (`N1') " & " %9.3fc (`treat') "`star'" " \\"
				}			
		file write fh _n "\bottomrule" 
        file write fh _n "\end{tabular}"	
file close fh

*5.2) Simple Regression analysis
forval n=1/5 {
    reg end_dom_bfi2s_`n' treat_assignment if bs_dom_bfi2s_`n'!=. , vce(cluster schgr) //clustering at the school level
	estimates store cbfi`n', title(BFI `n')
		qui sum `e(depvar)'  if treat_assignment == 0 & e(sample)
	estadd scalar Mean= r(mean)
	estadd scalar SD= r(sd)
}

esttab cbfi1 cbfi2 cbfi3 cbfi4 cbfi5 using "$output/bfi_dom_olsregression.tex", keep(treat_assignment) cells(b(star fmt(3)) se(par fmt(2))) stats( Mean SD N r2_a, fmt(2 2 0 2) label(Mean SD N R-sqr-adj)) starlevels(* 0.10 ** 0.05 *** 0.01) label replace booktabs note("/textit{Note:}The standard errors are clustered at the school-grade level. * p<0.10, ** p<0.05, *** p<0.01.")

**EOF

