**************************************************************************************************
**  Project:        PLATIPUS Ordinal Outcome Validation
**
**  Do-file:        cr02_derive_hipster.do
**  Author:         Melissa Middleton
**  Date Created:   20/03/2025 
**  Version:        v1
**	Date updated:	
**
**  Purpose:        loads the HIPSTER source data and derives the PLATIPUS ordinal
**					outcome per the mapping definition outlined in 
**					06_documentation/03_outcome_mapping/ValidationMapping_HIPSTER.docx
**					and stores the ordinal outcome and relevant analysis variables in the derived dataset 
**					02_derived_data/derived_hipster.dta
**	
**	Notes:			
**
********************************************************************************
**Start a script-specific log
	log using "04_logs/cr02_derive_hipster.txt", text replace name(cr01_hipster)

	pwd

********************************************************************************
**	STEP 0: LOAD SOURCE DATA
**There is an issue where three infants have been included in the stata dataset "hipsterrawold.dta"
** that should be removed form the analysis. Will need to load the csv file (which has misaligned variables and data)
** and match the participant ids to those in the stata data file to identify which infants to include.

**Load CSV source data 
	import delimited "01_source_data/hipsterclean-platipus.csv", clear
	
	keep studynum
	
	merge 1:1 studynum using "01_source_data/hipsterrawold.dta"
	
	keep if _merge == 3
	drop _merge
		
********************************************************************************
**	STEP 1: DERIVE ORDINAL OUTCOME
********************************************************************************
**general cleaning

**non-invasive resp support >= 1 and < 5 days
egen total_nirs = rowtotal(cpap_days nippv_days hfnc_days)
	replace total_nirs = . if missing(cpap_days,nippv_days, hfnc_days)

gen nirs_1_4 = total_nirs >= 1 & total_nirs < 5

**non-invasive resp support >=5 days

gen nirs_5 = total_nirs >= 5 & total_nirs != .

**MV via ETT >= 1 and < 5 days
gen mv_1_4 = ett_days >= 1 & ett_days < 5

** MV via ETT >= 5 days
gen mv_5 = ett_days >= 5 & ett_days != .

**moderate respiratory support
gen mod_resp = oxy_36wks == 1 | respsupp_36wks == 1
	replace mod_resp = . if oxy_36wks == . | respsupp_36wks == .
	
**nec/sepsis
gen nec_sepsis = nec == 1 | (septic > 0 & septic != .)

**severe resp morbidity
gen sev_resp = (homeo2 == 1 & disch_age_weeks < 40) | inlist(respsupp_36wks,2,3,4)

** major surgery
	**excluded

**brain injury
gen bi = ivh == 1 | pvl == 1 | vent_dil == 1 | vent_drain == 1

**two of sev resp morbidity, major surgery or brain injury
gen two_bi_sevresp = sev_resp == 1 & bi == 1

**three of... 
	**excluded
	
**Death ** only 2 deaths in cohort, manual checks put both at < 42 weeks PMA
tab death

********************************************************************************
**Derive outcome
gen platipus_out = 1			//alive, well
	replace platipus_out = 2 	//NICU < 48hours 	- all should have this level
	replace platipus_out = 3	//NICU >= 48hours	- all should have this level
	replace platipus_out = 4 if nirs_1_4 == 1
	replace platipus_out = 5 if nirs_5 == 1
	replace platipus_out = 6 if mv_1_4 == 1
	replace platipus_out = 7 if mv_5 == 1
	replace platipus_out = 8 if mod_resp == 1
	replace platipus_out = 9 if nec_sepsis	== 1
	replace platipus_out = 10 if sev_resp == 1
	//platipus_out == 11 if major surgery
	replace platipus_out = 12 if bi == 1
	replace platipus_out = 13 if two_bi_sevresp == 1
	//platipus_out == 14 if three of
	replace platipus_out = 15 if death == 1
	
lab define plat_out 1 "Alive and well" 2 "NICU <48 hrs" 3 "NICU >= 48hrs" 4 "Non-invasive resp. <5 days" ///
	5 "Non-invasive resp >= 5 days" 6 "MV via ETT < 5 days" 7 "MV via ETT >= 5 days" ///
	8 "Mod. resp. morbidity" 9 "NEC/Sepsis" 10 "Sev. resp. morbidity" 11 "major surgery" ///
	12 "brain injury" 13 "two of: sev. resp, surgery OR brain injury" ///
	14 "Sev. resp AND surgery AND brain injury" 15 "death"
	
lab val platipus_out plat_out

**Create stratification variables
gen stratgest = gestage_weeks < 32
********************************************************************************
** keep only variables relevant for analysis
keep 	platipus_out	/// outcome
		treat_fail		/// trial-specific binary outcome
		treatment		/// treatment status 
		centre stratgest  gestage_weeks

**Save the derived dataset
save 02_derived_data/derived_hipster.dta, replace

**Close the log
log close cr01_hipster

**Exit the do-file
exit
