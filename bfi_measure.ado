prog def bfi_measure
	
	syntax , type(integer) survey(string)
	
	local nquestions=`type'
	gen survey1="`survey'"

if `nquestions'==30 {
	
	*Reverse negatively keyed BFI-2S
	   //ssc install vreverse // install command 
	   foreach var in 16 24 12 19 23 7 3 10 13 14 4 11 5 27 15 {
			vreverse `survey'_bfi_q`var', gen(`survey'_bfi_q`var'r)
			
			replace `survey'_bfi_q`var'r=.m if `survey'_bfi_q`var'==.m
			replace `survey'_bfi_q`var'r=.n if `survey'_bfi_q`var'==.n

			drop `survey'_bfi_q`var'
			rename `survey'_bfi_q`var'r `survey'_bfi_q`var'
		}

	* Score BFI-2-S domain scales.
	  egen dom_bfi2s_1= rowmean(`survey'_bfi_q16 `survey'_bfi_q9 `survey'_bfi_q22 `survey'_bfi_q1 `survey'_bfi_q24 `survey'_bfi_q12)   // Extraversion
	  egen dom_bfi2s_2 = rowmean(`survey'_bfi_q2 `survey'_bfi_q19 `survey'_bfi_q28 `survey'_bfi_q23 `survey'_bfi_q6 `survey'_bfi_q7)   // Agreeableness
	  egen dom_bfi2s_3 = rowmean(`survey'_bfi_q3 `survey'_bfi_q10 `survey'_bfi_q20 `survey'_bfi_q17 `survey'_bfi_q25 `survey'_bfi_q13) // Conscientiouness
	  egen dom_bfi2s_4 = rowmean(`survey'_bfi_q18 `survey'_bfi_q26 `survey'_bfi_q14 `survey'_bfi_q4 `survey'_bfi_q11 `survey'_bfi_q29) // Negative Emotionality
	  egen dom_bfi2s_5 = rowmean(`survey'_bfi_q5 `survey'_bfi_q8 `survey'_bfi_q27 `survey'_bfi_q30 `survey'_bfi_q21 `survey'_bfi_q15)  // Open Mindness

	* Variable labels
	  label var dom_bfi2s_1 "BFI-2-S Extraversion"
	  label var dom_bfi2s_2 "BFI-2-S Agreeableness"
	  label var dom_bfi2s_3 "BFI-2-S Conscientiousness"
	  label var dom_bfi2s_4 "BFI-2-S Negative Emotionality"
	  label var dom_bfi2s_5 "BFI-2-S Open-Mindedness"
  
	* Codify missing values
  
  forv c=1/5{
	replace dom_bfi2s_`c'=.m if dom_bfi2s_`c'==. & `survey'_bfi_q3!=.n
	replace dom_bfi2s_`c'=.n if dom_bfi2s_`c'==. & `survey'_bfi_q3==.n

	replace dom_bfi2s_`c'=.n if survey==3 & survey1=="qst" //it does not apply to endline

}
}

  

if `nquestions'==15 {
/*	
	 *Reverse negatively keyed BFI-2XS
	  ssc install vreverse // install command 
	   foreach var in 16 19 3 10 14 27 {
			vreverse `survey'_bfi_q`var', gen(`survey'_bfi_q`var'r)
			drop `survey'_bfi_q`var'
			rename `survey'_bfi_q`var'r `survey'_bfi_q`var'
		}
*/
	* Score BFI-2-XS domain scales.
	  egen dom_bfi2xs_1 = rowmean(`survey'_bfi_q16 `survey'_bfi_q9 `survey'_bfi_q22) // Extraversion
	  egen dom_bfi2xs_2 = rowmean(`survey'_bfi_q2 `survey'_bfi_q19 `survey'_bfi_q28) // Agreeableness
	  egen dom_bfi2xs_3 = rowmean(`survey'_bfi_q3 `survey'_bfi_q10 `survey'_bfi_q20) // Conscientiouness
	  egen dom_bfi2xs_4 = rowmean(`survey'_bfi_q18 `survey'_bfi_q26 `survey'_bfi_q14) // Negative Emotionality
	  egen dom_bfi2xs_5 = rowmean(`survey'_bfi_q8 `survey'_bfi_q30 `survey'_bfi_q27)  // Open Mindness
 
	* Variable labels
	  label var dom_bfi2xs_1 "BFI-2-XS Extraversion"
	  label var dom_bfi2xs_2 "BFI-2-XS Agreeableness"
	  label var dom_bfi2xs_3 "BFI-2-XS Conscientiousness"
	  label var dom_bfi2xs_4 "BFI-2-XS Negative Emotionality"
	  label var dom_bfi2xs_5 "BFI-2-XS Open-Mindedness"
  
  
	* Code missings
  
	  forv c=1/5{
	replace dom_bfi2xs_`c'=.m if dom_bfi2xs_`c'==. & `survey'_bfi_q3!=.n
	replace dom_bfi2xs_`c'=.n if dom_bfi2xs_`c'==. & `survey'_bfi_q3==.n
}

  //Note: there is an error in bfi_8; it was not included in endline; instead, we included bfi_6
	}

	drop survey1
end

//Sources:
* BFI Short and Extra Short Versions
*https://www.colby.edu/academics/departments-and-programs/psychology/research-opportunities/personality-lab/the-bfi-2/