**************************************************************************************************
**  Project:        PLATIPUS Ordinal Outcome Validation
**
**  Do-file:        cr03_derive_strider.do
**  Author:         Melissa Middleton
**  Date Created:   29/04/2025 
**  Version:        v1
**	Date updated:	
**
**  Purpose:        loads the STRIDER source data and derives the PLATIPUS ordinal
**					outcome per the mapping definition outlined in 
**					06_documentation/03_outcome_mapping/ValidationMapping_STRIDER.docx
**					and stores the ordinal outcome and relevant analysis variables in the derived dataset 
**					02_derived_data/derived_strider.dta
**	
**	Notes:			
**
********************************************************************************
**Start a script-specific log
	log using "04_logs/cr03_derive_strider.txt", text replace name(cr03_strider)

	pwd
	
********************************************************************************
**	STEP 0: LOAD SOURCE DATA

**Load CSV source data 
import delimited "01_source_data\STRIDERConsortiumLM-PLATIPUSdatarequest_DATA_2025-04-28_2308.csv", clear

********************************************************************************
**	STEP 1: General Data Cleaning
********************************************************************************
**Look at variables required for the ordinal outcome

foreach var of varlist neonatal_postnatalward_days neonatal_specialcare_days neonatal_nicu_days ///
	neonatal_non_et_support neonatal_non_et_support_days neonatal_oxygen_support ///
	neonatal_tube_support neonatal_tube_support_days neonatal_dysplasia neonatal_ne ///
	neonatal_infection neonatal_early_onset neonatal_late_onset neonatal_uss_periventricular ///
	neonatal_uss_ivh neonatal_death neonatal_death_age {
	replace `var' = "0" if `var' == "NA" // NA indicates for stillborn, does not have as 0 days alive; 
}


foreach var of varlist neonatal_postnatalward_days neonatal_specialcare_days neonatal_nicu_days ///
	neonatal_non_et_support neonatal_non_et_support_days neonatal_oxygen_support /// 
	neonatal_tube_support neonatal_tube_support_days neonatal_dysplasia neonatal_early_onset ///
	neonatal_late_onset neonatal_uss_ivh delivery_onset neonatal_death neonatal_death_age {
	replace `var' = "" if `var' == "NI" //NI - no information - to query, potentially missing?
}

foreach var of varlist neonatal_postnatalward_days neonatal_specialcare_days neonatal_nicu_days ///
	neonatal_non_et_support neonatal_non_et_support_days neonatal_oxygen_support ///
	neonatal_tube_support neonatal_tube_support_days neonatal_dysplasia neonatal_ne ///
	neonatal_infection neonatal_early_onset neonatal_late_onset neonatal_uss_periventricular ///
	neonatal_uss_ivh delivery_onset neonatal_death neonatal_death_age {
	destring `var', replace
}

replace neonatal_dysplasia = 0 if neonatal_dysplasia == 2 //2 is No due to infant death (Dutch trial)

lab define yesno 0 "No" 1 "Yes"

foreach var of varlist neonatal_non_et_support neonatal_oxygen_support neonatal_tube_support ///
	neonatal_dysplasia neonatal_infection neonatal_early_onset neonatal_late_onset ///
	neonatal_uss_periventricular neonatal_uss_ivh neonatal_death {
	lab val `var' yesno
}

lab define nec 0 "No" 1 "Yes - suspected" 2 "Yes - confirmed surgically"
lab val neonatal_ne nec

lab define birth 1 "Livebirth" 2 "Stillbirth"
lab val neonatal_birth_combined birth

lab define deliver 1 "Termination" 2 "Spontaneous" 3 "Induction" 4 "Pre-labour c-section"
lab val delivery_onset deliver

/*No cleaning required
delivery_ga_w					
delivery_ga_d
*/

********************************************************************************
** STEP 2: DERIVE ORDINAL OUTCOME
********************************************************************************Death
**calculate days until 42 weeks PMA
gen days_til_42 = (7*42)-(delivery_ga_w*7+delivery_ga_d)

gen plat_death = 	neonatal_birth_combined == 2 | /// stillbirth
					delivery_onset == 1 | /// termination
					neonatal_death_age < days_til_42 // died prior to 42+0
	replace plat_death = . if neonatal_birth_combined == . | neonatal_death == .
					
**Brain injury
gen plat_bi = 		neonatal_uss_periventricular == 1 | /// PVL >+ grade 2
					neonatal_uss_ivh == 1 // IVH grade 3 or 4
	replace plat_bi = . if neonatal_uss_ivh == . | neonatal_uss_periventricular == .
					
**Major surgery (nec confirmed surgically)
gen plat_surg =		neonatal_ne == 2 // Surgery for NEC
	replace plat_surg = . if neonatal_ne == .

**Severe respiratory morbidity 
gen plat_srm =		neonatal_dysplasia == 1 & /// BPD
					delivery_ga_w < 37 // Born < 37 weeks GA
					
**Sepsis or NEC
gen plat_sepnec =	neonatal_ne == 1 | /// Nec suspected, not including NEC confirmed surgically (included under major surgery)
					neonatal_infection == 1 | /// culture positive req >= 5 days antibio
					neonatal_early_onset == 1 | /// early onset sepsis
					neonatal_late_onset == 1 // late onset sepsis
					
**Moderate resp morbidity - Not considered

**Mech ventilation >= 7 days
gen plat_mv7 =		neonatal_tube_support == 1 & neonatal_tube_support_days >= 7 & neonatal_tube_support_days < .

**Mech ventilation <7 
gen plat_mv17 = 	neonatal_tube_support == 1 & neonatal_tube_support > 0 & neonatal_tube_support < 7

**Non-invasive resp support >= 5 days
gen plat_nirs5 = 	neonatal_non_et_support == 1 & neonatal_non_et_support_days >= 5 & neonatal_non_et_support_days < .

**Non-invasive resp supprot >4 hours & < 5 days
gen plat_nirs15 = 	neonatal_non_et_support == 1 & neonatal_non_et_support_days < 5 & neonatal_non_et_support_days > 0

**Admission to NICU OR Special Care Nursery >= 48 hours
gen plat_nicu2 =	(neonatal_specialcare_days >= 2 & neonatal_specialcare_days < .) | (neonatal_nicu_days >= 2 & neonatal_nicu_days < .)
**Admission to NICU or special care nursery < 48 hours
gen plat_nicu12 =	(neonatal_specialcare_days > 0 & neonatal_specialcare_days < 2) | (neonatal_nicu_days > 0 & neonatal_nicu_days < 2)

**Platipus well
gen plat_well = neonatal_specialcare_days == 0 & neonatal_nicu_days == 0 /// no days in nicu or special care
				& neonatal_non_et_support == 0 & neonatal_tube_support == 0 /// no ventilation required 
				& neonatal_ne == 0 & neonatal_infection == 0 & neonatal_early_onset == 0 & neonatal_late_onset == 0 /// no sepsis or nec
				& (neonatal_dysplasia == 0 | (neonatal_dysplasia == 1 & delivery_ga_w>37)) /// no BPD or BPD but not preterm
				& neonatal_uss_ivh == 0 & neonatal_uss_periventricular == 0 /// No IVH or PVL
				& neonatal_birth_combined == 1 & (neonatal_death == 0 | (neonatal_death == 1 & neonatal_death_age > days_til_42)) /// live birth, and no neonatal death or neonatal death after 42 weeks 
				& delivery_onset != 1 //delivery onset was not termination


********DERIVE OUTCOME
gen plat_out = . 
	replace plat_out = 1 if 	plat_well == 1
	replace plat_out = 2 if 	plat_nicu12 == 1
	replace plat_out = 3 if 	plat_nicu2 == 1
	replace plat_out = 4 if		plat_nirs15 == 1
	replace plat_out = 5 if 	plat_nirs5 == 1
	replace plat_out = 6 if 	plat_mv17 == 1
	replace plat_out = 7 if 	plat_mv7 == 1
	*replace plat_out = 8							//Moderate resp support
	replace plat_out = 9 if		plat_sepnec == 1
	replace plat_out = 10 if 	plat_srm == 1 
	replace plat_out = 11 if 	plat_surg == 1
	replace plat_out = 12 if 	plat_bi == 1
	replace plat_out = 13 if 	plat_srm+plat_surg+plat_bi > 1
	replace plat_out = 14 if 	plat_srm+plat_surg+plat_bi == 3
	replace plat_out = 15 if 	plat_death == 1

****Create stratification variables
gen stratgest = delivery_ga_w < 26

**Create treatment variable
encode maternal_intervention_allocation, gen(treatment) label(trt)

********************************************************************************
** STEP 3: CREATE ANALYSE DATASET
********************************************************************************

keep plat* country_code treatment delivery_ga_w delivery_ga_d neonatal_serious_adverse_outcome secondary_identifier_site stratgest

save "02_derived_data/derived_strider.dta", replace

log close cr03_strider