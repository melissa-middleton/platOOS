**************************************************************************************************
**  Project:        PLATIPUS Ordinal Outcome Validation
**
**  Do-file:        cr04_derive_VICS.do
**  Author:         Melissa Middleton
**  Date Created:   14/05/2025 
**  Version:        v1
**	Date updated:	
**
**  Purpose:        loads the vics source data and derives the PLATIPUS ordinal
**					outcome per the mapping definition outlined in 
**					06_documentation/03_outcome_mapping/ValidationMapping_VICS.docx
**					and stores the ordinal outcome and relevant analysis variables in the derived dataset 
**					02_derived_data/derived_vics.dta
**	
**	Notes:			
**
********************************************************************************
**Start a script-specific log
	log using "04_logs/cr02_derive_vics.txt", text replace name(cr04_vics)

	pwd

********************************************************************************
**	STEP 0: LOAD SOURCE DATA
	use "01_source_data\VICS data for Platipus_11.10.23.dta", clear
	
********************************************************************************
** STEP 1: DATA CLEANING
********************************************************************************
**Drop infants who were not offered care
keep if icu == 1

**Check missing data for variables to be included in outcome derivation

misstable summarize dayshosp days_noninvasive hfovday ippvday etcpapday ///
					o236week datesbest nec av_36w surgneo bowel necsurgery ///
					cvh3or4 sevpvl alive36w dieddis 
/**High levels of missing in 
dayshosp 
hfovday
ippvday
o236week
nec
av_36w
bowel
alive36w
*/

**1 infant is missing all observations
	drop if missing(dayshosp) & missing(days_noninvasive) & missing(hfovday) & missing(ippvday) & missing(etcpapday) ///
					& missing(o236week) & missing(nec) & missing(av_36w) & missing(surgneo) & missing(bowel) & missing(necsurgery) ///
					& missing(cvh3or4) & missing(sevpvl) & missing(alive36w)   

**HFOV
	**check if missing hfov days is because no av given
	tab anyav if hfovday == . , m //no av given
		replace hfovday = 0 if hfovday == . & anyav == 0
	
**IPPV
	**check if missing IPPV days is because no av given
	tab anyav if ippvday == . , m //no av given
		replace ippvday = 0 if ippvday == . & anyav == 0
		
**O2 36 week
	**check if alive at 36 week
	tab o236week alive36w, m //31 missing were not alive at 36wls
		replace o236week = 0 if o236week == . & alive36w == 0
	**check if born at 36 week
	count if datesbest > 36 & o236week == . //130 were born after 36 weeks
		replace o236week = 0 if datesbest > 36 & o236week == .
	//still 6 missing that are unaccounted for
	
**NEC 
	**check if died
	tab nec dieddis, m //412 were alive at 36 weeks
	**check gestation age
	sum datesbest if nec == . //mostly term babies (370/413)
	**Check if necsurgery required
	tab nec necsurgery, m // all missing nec have indicated no nec surgery
	
	*************************
	**Set term with NEC missing as not having NEC - need to check with Jeanie
	replace nec = 0 if datesbest >= 37 & nec == .
	
	
**Bowel
	**check if surgneo covers both necsurgery and bowel
	tab surgneo necsurgery, m // all those with necsurgery are also indicated for neonatal surgery
	tab surgneo bowel, m // all those with bowel surgery are also indicated for neonatal surgery, neonatal surgery is non missing
		// just use surgneo for derivation
 
**How many are missing any variables required for derivation
	egen anymiss = rowmiss(dayshosp days_noninvasive hfovday ippvday etcpapday o236week datesbest nec av_36w surgneo cvh3or4 sevpvl dieddis alive36w)
	
	**Check gestational ages for those with missing data
	gen ga_cat = .
		replace ga_cat = 1 if datesbest < 28
		replace ga_cat = 2 if datesbest >= 28 & datesbest < 32
		replace ga_cat = 3 if datesbest >= 32 & datesbest < 37
		replace ga_cat = 4 if datesbest > 37 & datesbest != .
	lab def ga 1 "EP" 2 "VP" 3 "MLP" 4 "Term"
	lab val ga_cat ga
	
	tab ga_cat anymiss //most missing is for Term babies who we expect to be generally well off and this mostly comes from incomplete NEC
	
********************************************************************************
**	STEP 1: DERIVE ORDINAL OUTCOME
********************************************************************************

**NICU < 48
	*not derivable
**NICU >= 48 
	*not derivable
**Non-invasive resp support < 5 days
	gen nirs1 = days_noninvasive > 0 & days_noninvasive < 5
		replace nirs1 = . if days_noninvasive == .
		lab var nirs1  "PLATIPUS Outcome 4 - Non-invasive respiratory support < 5 days"
		
**Non-invasive resp support >= 5
	gen nirs2 = days_noninvasive >= 5 & days_noninvasive < .
		replace nirs2 = . if days_noninvasive == .
		lab var nirs2 "PLATIPUS Outcome 5 - Non-invasive respiratory support >= 5 days"
	
**MV via ETT < 7
	gen ett_day = hfovday + ippvday + etcpapday
	gen mv1 = ett_day > 0 & ett_day < 7
		replace mv1 = . if ett_day == .
		lab var mv1  "PLATIPUS Outcome 6 - MV via ETT < 7 days"
	
**MV via ETT >= 7
	gen mv2 = ett_day >= 7 & ett_day < .
		replace mv2 = . if ett_day == .
		lab var mv2  "PLATIPUS Outcome 7 - MV via ETT >= 7 days"
	
**Moderate resp morbidity
	gen mod_resp = o236week == 1 & datesbest < 37
		replace mod_resp = . if o236week == . & datesbest < 37
		lab var mod_resp  "PLATIPUS Outcome 8 - Moderate respiratory morbidity"
	
**Nec and/or Sepsis
	gen necsep = nec == 1
		replace necsep = . if nec == .
		lab var necsep  "PLATIPUS Outcome 9 - NEC and/or Sepsis"

**Severe resp morbidity
	gen sev_resp = av_36w == 1
		replace sev_resp = . if av_36w == .
		lab var sev_resp  "PLATIPUS Outcome 10 - Severe Respiratory morbidity"
	
**Major surgery
	gen surg = surgneo == 1 
		replace surg = . if surgneo == . 
		lab var surg  "PLATIPUS Outcome 11 - Major surgery"
		
**Brain injury
	gen bi = cvh3or4 == 1 | sevpvl == 1
		replace bi = . if cvh3or4 == . & sevpvl == .
		lab var bi  "PLATIPUS Outcome 12 - Brain Injury"
		
**Death
	gen death = alive36w == 0 & dieddis == 1
		replace death = . if alive36w == .
		lab var death  "PLATIPUS Outcome 15 - death"
	
****************************************************************************
**Derive outcome scale

gen platipus_out = .
	replace platipus_out = 1 	if (nirs1 + nirs2 + mv1 + mv2 + mod_resp + necsep + sev_resp + surg + bi + death) == 0
	replace platipus_out = 2   	if datesbest < 37 //assume premmie babies always admitted to NICU
	replace platipus_out = 4	if nirs1 == 1
	replace platipus_out = 5	if nirs2 == 1
	replace platipus_out = 6	if mv1 == 1
	replace platipus_out = 7	if mv2 == 1
	replace platipus_out = 8	if mod_resp == 1
	replace platipus_out = 9 	if necsep == 1
	replace platipus_out = 10	if sev_resp == 1
	replace platipus_out = 11	if surg == 1
	replace platipus_out = 12	if bi == 1
	replace platipus_out = 13	if (sev_resp + surg + bi) == 2
	replace platipus_out = 14	if (sev_resp + surg + bi) == 3
	replace platipus_out = 15	if death == 1

lab define plat_out 1 "Alive and well" 2 "NICU <48 hrs" 3 "NICU >= 48hrs" 4 "Non-invasive resp. <5 days" ///
	5 "Non-invasive resp >= 5 days" 6 "MV via ETT < 5 days" 7 "MV via ETT >= 5 days" ///
	8 "Mod. resp. morbidity" 9 "NEC/Sepsis" 10 "Sev. resp. morbidity" 11 "major surgery" ///
	12 "brain injury" 13 "two of: sev. resp, surgery OR brain injury" ///
	14 "Sev. resp AND surgery AND brain injury" 15 "death"
	
lab val platipus_out plat_out
lab var platipus_out "PLATIPUS 15-point ordinal outcome"

**Replace outcome to be missing if any variables for derivation are missing
replace platipus_out = . if anymiss != 0

********************************************************************************
** keep only variables relevant for analysis
keep 	platipus_out	/// outcome
		datesbest		/// gestational age
		anster male bweight
		
gen grp = datesbest < 37
	lab def grp 0 "VICS Term" 1 "VICS Preterm"
	lab val grp grp
	
	lab def anster 0 "No antenatal corticosteroids" 1 "Antenatal corticosteroids", replace
	lab val anster anster
**Save the derived dataset
save 02_derived_data/derived_vics.dta, replace

**Close the log
log close cr04_vics

**Exit the do-file
exit

