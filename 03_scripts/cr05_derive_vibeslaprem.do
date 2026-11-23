**************************************************************************************************
**  Project:        PLATIPUS Ordinal Outcome Validation
**
**  Do-file:        cr04_derive_vibeslaprem.do
**  Author:         Melissa Middleton
**  Date Created:   14/05/2025 
**  Version:        v1
**	Date updated:	
**
**  Purpose:        loads the VIBeS/LaPrem source data and derives the PLATIPUS ordinal
**					outcome per the mapping definition outlined in 
**					06_documentation/03_outcome_mapping/ValidationMapping_vibeslaprem.docx
**					and stores the ordinal outcome and relevant analysis variables in the derived dataset 
**					02_derived_data/derived_vibeslaprem.dta
**	
**	Notes:			
**
********************************************************************************
**Start a script-specific log
	log using "04_logs/cr05_derive_vibeslaprem.txt", text replace name(cr05_vibeslaprem)

	pwd

********************************************************************************
**	STEP 0: LOAD SOURCE DATA
	use "01_source_data\LaPrem and VIBES 2 data for Platipus_9.8.23.dta", clear
	
********************************************************************************
**	STEP 1: DERIVE ORDINAL OUTCOME
********************************************************************************

***********
**Check missing data

misstable summarize hfov respcpaphr_birth respippvhr_birth nec_andor_sepsis_nn ///
					cld surgery abdosurg cardsurg ivh3or4 phvd pvlcystic deceased_nn
  
**High levels of missing data across the datasets

**NICU < 48
	//not derivable
**NICU >= 48 
	//not derivable
**Non-invasive resp support < 5 days
	gen nirs_tot = hfov + respcpaphr_birth
	gen nirs_days = nirs_tot/24
	gen nirs1 = nirs_tot > 4 & nirs_days < 5
		replace nirs1 = . if nirs_tot == .

**Non-invasive resp support >= 5
	gen nirs2 = nirs_tot >=5 & nirs_days < .
		replace nirs2 = . if nirs_tot == .
	
**MV via ETT < 7
	gen ippv_days = respippvhr_birth/24
	gen mv1 = respippvhr_birth > 4 & ippv_days < 7
		replace mv1 = . if respippvhr_birth == .
	
**MV via ETT >= 7
	gen mv2 = ippv_days >= 7 & ippv_days < .
		replace mv2 = . if respippvhr_birth == .
	
**Moderate resp morbidity
	//not derivable
	
**Nec and/or Sepsis
	gen necsep = nec_andor_sepsis_nn == 1
		replace necsep = . if nec_andor_sepsis_nn == .

**Severe resp morbidity
	gen sev_resp = cld == 1
		replace sev_resp = . if cld == .
	
**Major surgery
	gen surg = surgery == 1 | abdosurg == 1 |  == 1
		replace surg = . if surgery == . & abdosurg == . & cardsurg == .
		
**Brain injury
	gen bi = ivh3or4 == 1 | phvd == 1 | pvlcystic == 1
		replace bi = . if ivh3or4 == . & phvd == . & pvlcystic == .
		
**Death
	gen death = deceased_nn == 1 
		replace death = . if deceased_nn == .
	
****************************************************************************
**Derive outcome scale

gen platipus_out = .
	replace platipus_out = 1 	if (nirs1 + nirs2 + mv1 + mv2 + mod_resp + necsep + sev_resp + surg + bi + death) == 0
	replace platipus_out = 2   	if ga_completedwks < 37 //assume premmie babies always admitted to NICU
	replace platipus_out = 4	if nirs1 == 1
	replace platipus_out = 5	if nirs2 == 1
	replace platipus_out = 6	if mv1 == 1
	replace platipus_out = 7	if mv2 == 1
	replace platipus_out = 9 	if necsep == 1
	replace platipus_out = 10	if sev_resp == 1
	replace platipus_out = 11	if surg == 1
	replace platipus_out = 12	if bi == 1
	replace platipus_out = 13	if (sev_resp + surg + bi) == 2
	replace platipus_out = 14	if (sev_resp + surg + bi) == 3
	replace platipus_out = 15	if death == 1

lab define plat_out 1 "Alive and well" 2 "NICU <48 hrs" 3 "NICU >= 48hrs" 4 "Non-invasive resp. <5 days" ///
	5 "Non-invasive resp >= 5 days" 6 "MV via ETT < 7 days" 7 "MV via ETT >= 7 days" ///
	8 "Mod. resp. morbidity" 9 "NEC/Sepsis" 10 "Sev. resp. morbidity" 11 "major surgery" ///
	12 "brain injury" 13 "two of: sev. resp, surgery OR brain injury" ///
	14 "Sev. resp AND surgery AND brain injury" 15 "death"
	
lab val platipus_out plat_out

********************************************************************************
** keep only variables relevant for analysis
keep 	platipus_out	/// outcome
		ga_completedwks		// gestational age

gen grp = ga_completedwks < 37
	lab def grp 0 "VIBeS/LaPrem Term" 1 "VIBeS/LaPrem Preterm"
	lab val grp grp
		
**Save the derived dataset
save 02_derived_data/derived_vibeslaprem.dta, replace

**Close the log
log close cr05_vibeslaprem

**Exit the do-file
exit

