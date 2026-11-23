**************************************************************************************************
**  Project:        PLATIPUS Ordinal Outcome Validation
**
**  Do-file:        00_MASTER_platipus_validation.do
**  Author:         Melissa Middleton
**  Date Created:   20/03/2025 
**  Version:        v1
**	Date updated:	
**
**  Purpose:        This master do-file is designed to perform the analyses and produces the
**					the figures and tables as presented in the PLATIPUS ordinal outcome validation paper.
**	
**	Notes:			
**
********************************************************************************
**  CONTENTS
********************************************************************************
/*
    Section 0 - Housekeeping
    Section 1 - Data Management
        1.1 - PLUSS Scale derivation
		1.2	- HIPSTER Scale derivation
		1.4 - STRIDER Scale derivation
		1.5 - VICS Scale derivation
		1.6 - VIBeS and La Prem Scale derivation
    Section 2 - Study Aim 1: Distribution of outcome
    Section 3 - Study Aim 2: Proportional Odds     
    Section 4 - Study Aim 3: Reanalysis

*/

********************************************************************************
**  SECTION 0 - HOUSEKEEPING
********************************************************************************
**Preamble
    version 18.0

    clear all
	capture log close
	set more off
	capture postfile close
	scalar drop _all
	global date: di %td_YYNNDD date(c(current_date), "DMY")
	global user `c(username)'

	pwd
	**Create new ado pathway for stored functions	
	adopath + "`c(pwd)'/03_scripts"
	
	**Create a master log
	log using "04_logs/00_master_platipus_validation_${date}.txt", text replace name(master)
	
********************************************************************************
**	SECTION 1 - DATA MANAGEMENT
********************************************************************************
	**1.1 PLUSS Scale derivation
	/*Derivation of PLUSS scale has been completed by Kate Francis per mapping defintion
	outlined in 06_documentation/03_outcome_mapping/ValidationMapping_PLUSS.docx
	This do-file will load the source data and extract the variables relevant for 
	analysis in the derived dataset 02_derived_data/derived_pluss.dta */
	
	*do 03_scripts/cr01_derive_pluss.do
	**clean PLUSS labels
	use 01_source_data/PLUSS_for_PLATIPUS_july2025.dta, clear
		label define pluss_trt 0 "Sufactant alone" 1 "Surfactant & Budesonide"
		lab val trt01 pluss_trt
	save 02_derived_data/derived_pluss.dta
	
	**1.2 HIPSTER Scale derivation
	/*The following do-file loads the HIPSTER source data and derives the PLATIPUS ordinal
	outcome per the mapping definition outlined in 06_documentation/03_outcome_mapping/ValidationMapping_HIPSTER.docx
	and stores the ordinal outcome and relevant analysis variables in the derived dataset 
	02_derived_data/derived_hipster.dta*/
	
	do 03_scripts/cr02_derive_hipster.do
	
	**1.3 STRIDER Scale derivation
	/*The following do-file loads the STRIDER source data and derives the PLATIPUS ordinal
	outcome per the mapping definition outlined in 06_documentation/03_outcome_mapping/ValidationMapping_STRIDER.docx
	and stores the ordinal outcome and relevant analysis variables in the derived dataset 
	02_derived_data/derived_strider.dta*/
	
	do 03_scripts/cr03_derive_strider.do		
	
	**1.4 VICS scale derivation
	/*The following do-file loads the VICS source data and derives the PLATIPUS ordinal
	outcome per the mapping definition outlined in 06_documentation/03_outcome_mapping/ValidationMapping_VICS.docx
	and stores the ordinal outcome and relevant analysis variables in the derived dataset 
	02_derived_data/derived_VICS.dta*/
	
	do 03_scripts/cr04_derive_vics.do				
	
	**1.5 VIBeS and La Prem scale derivation
	/*The following do-file loads the VIBeS and La Prem source data and derives the PLATIPUS ordinal
	outcome per the mapping definition outlined in 06_documentation/03_outcome_mapping/ValidationMapping_VIBeS.docx
	and 06_documentation/03_outcome_mapping/ValidationMapping_LaPrem.docx
	and stores the ordinal outcome and relevant analysis variables in the derived dataset 
	02_derived_data/derived_VIBeS.dta and 02_derived_data/derived_LaPrem.dta */
	
	do 03_scripts/cr05_derive_vibeslaprem.do		
		//Lots of missing data. Suspect the different cohorts collected different items
		// so even though we have sufficient data across both cohorts, the outcome
		// is not able to be derived within the individual cohorts

********************************************************************************
**	SECTION 2 - AIM 1 DISTRIBUTION OF OUTCOME
********************************************************************************
** Generate Grotta Plots showing the distribution of the outcome for STIRDER, HIPSTER, and PLUSS

	use 02_derived_data/derived_strider.dta, clear
	lab define trt 1 "Control" 2 "Sildenafil", modify

	grotta_platipus platipus_out using 02_derived_data\derived_hipster.dta, exp(treatment) connected("n")
		graph rename hipster
	grotta_platipus plat_out using 02_derived_data\derived_strider.dta, exp(treatment) connected("n")
		graph rename strider
	grotta_platipus platipus_out using 02_derived_data/derived_pluss.dta, exp(trt01) connected("n")
		graph rename pluss, replace 
	grotta_platipus platipus_out using 02_derived_data\derived_vics.dta, exp(grp) graphname(05_output\03_figures\aim1_VICS) titleby("by prematurity") connected("n")	
		graph rename vics, replace
		graph save vics 05_output/03_figures/fig2_aim1VICS.grp, replace
		graph export  05_output/03_figures/fig2_aim1VICS.png, as(png) replace
		graph export  05_output/03_figures/fig2_aim1VICS.pdf, as(pdf) replace
		
	**Manually edit graphs to remove legend and notes from trials
	**Manually edit vics graph to remove all elements other than legend
		**offest legend to -50
	graph combine pluss strider hipster vics, rows(2) imargin(vsmall) note("{it:MV: Mechanical ventilation; ETT: Endotracheal tube; NEC: Necrotising enterocolitis}")
	**Manually add panel labelling
	graph save 		05_output/03_figures/fig3_aim1Trials.grp
	graph export 	05_output/03_figures/fig3_aim1Trials.png, as(png)
	graph export	05_output/03_figures/fig3_aim1Trials.pdf, as(pdf)
		
********************************************************************************
** SECTION 3 - AIM 2 PROPORTIONAL ODDS
********************************************************************************

	split_odds platipus_out using 01_source_data\PLUSS_for_PLATIPUS_oct23.dta, exp(trt01) graphname(05_output\03_figures\aim2_PLUSS) strat("i.pistratsurf i.pistratres i.pistratgest")
		graph rename pluss, replace 
	split_odds plat_out using 02_derived_data\derived_strider.dta, exp(treatment) graphname(05_output\03_figures\aim2_STRIDER) strat("i.secondary_identifier_site i.stratgest")
		graph rename strider, replace
	split_odds platipus_out using 02_derived_data\derived_hipster.dta, exp(treatment) graphname(05_output\03_figures\aim2_HIPSTER) strat("i.centre i.stratgest")
		graph rename hipster, replace
	split_odds platipus_out using 02_derived_data\derived_vics.dta, exp(anster) graphname(05_output\03_figures\aim2_VICS) strat("i.male datesbest bweight")
		graph rename vics, replace
	
	**Manually edit graphs to remove title and legend from trial graphs and keep legend from VICS
		**Manually update ticks
	
	graph combine pluss strider hipster vics, rows(2) imargin(vsmall)
	
	graph save 		05_output/03_figures/fig5_aim3.grp
	graph export 	05_output/03_figures/fig5_aim3.png, as(png)
	graph export	05_output/03_figures/fig5_aim3.pdf, as(pdf)
		
	
	
********************************************************************************
** SECTION 4 - AIM 3 REANLAYSIS
********************************************************************************
putexcel set 05_output\04_tables\aim3_trialreanalysis.xlsx, replace
	putexcel B1:D1 	= "Platipus Ordinal Outcome", bold merge
	putexcel E1:G1 	= "Trial-Specific Binary Outcome", bold merge
	putexcel B2 	= "pOR", bold
	putexcel C2:D2	= "95% CI", bold merge
	putexcel E2		= "OR", bold
	putexcel F2:G2	= "95% CI", bold merge
	putexcel A3		= "PLUSS", bold
	putexcel A4		= "HIPSTER", bold
	putexcel A5		= "STRIDER", bold
	putexcel A6		= "VICS", bold
	
	
	reanalysis platipus_out using 01_source_data\PLUSS_for_PLATIPUS_july2025.dta, exp(trt01) strat("i.pistratsurf i.pistratres i.pistratgest") bin_out(fe_survivalnobpdfinal36pma)
		putexcel B3 = matrix(r(results))
	
	reanalysis plat_out using 02_derived_data\derived_strider.dta, exp(treatment) strat("i.secondary_identifier_site i.stratgest") bin_out(neonatal_serious_adverse_outcome)
		putexcel B5 = matrix(r(results)) 
		
	reanalysis platipus_out using 02_derived_data\derived_hipster.dta, exp(treatment) strat("i.centre i.stratgest") bin_out(treat_fail)
		putexcel B4 = matrix(r(results)) 
	
	reanalysis platipus_out using 02_derived_data\derived_vics.dta, exp(anster) strat("i.male datesbest bweight") 
		putexcel B6 = matrix(r(results)) 
		
		
**Calculate relative % increase in precision
		**PLUSS
		scalar ord_se = 0.1024667
		scalar bin_se = 0.1787517
		
		**% increase in precision
		di 100*((ord_se/bin_se)^2-1)
			//-67.14%

		**STRIDER
		scalar ord_se = 0.1894138
		scalar bin_se = 0.2443819
		
		**% increase in precision
		di 100*((ord_se/bin_se)^2-1)
			//-39.93%
			
		**hipster
		scalar ord_se = 0.2554307
		scalar bin_se = 0.528873
		
		**% increase in precision
		di 100*((ord_se/bin_se)^2-1)
			//-76.67%

**Create graph
twoway 	(scatteri 3.1 0.94 2.1 1.5 1.1 1.06 , mcol(lavender)) ///
		(scatteri 2.9 1.19 1.9 2.33 0.9 1.12, mcol(dkorange)) ///
		(pci 3.1 0.75 3.1 1.17 2.1 1.07 2.1 2.11 1.1 0.74 1.1 1.51 , recast(pccapsym) msymbol(pipe) lcol(lavender) mcol(lavender)) ///
		(pci 2.9 0.89 2.9 1.61 1.9 1.48 1.9 3.67 0.9 0.73 0.9 1.74 , recast(pccapsym) msymbol(pipe) lcol(dkorange) mcol(dkorange)) ///
		(scatteri 2.55 2.8 2.55 3.1 "pOR and 95% CI", msy(pipe) connect(line)  mc(lavender) lc(lavender) mlabsize(small) mlabcolor(black)) ///
		(scatteri 2.45 2.8 2.45 3.1 "OR and 95% CI", msy(pipe) connect(line)  mc(dkorange) lc(dkorange) mlabsize(small) mlabcolor(black)) ///
		(scatteri 2.55 2.95, msy(circle)  msize(vsmall) mc(lavender)) ///
        (scatteri 2.45 2.95, msy(circle)  msize(vsmall) mc(dkorange)) ///
		, ///
		legend(off) xscale(log) ///
		ylabel(1 "STRIDER" 2 "HIPSTER" 3 "PLUSS") ytitle("") xtitle("") ///
		xline(1) note("{it:Note: PLUSS binary outcome is positive coded while PLATIPUS ordinal outcome is negative coded}", size(small))
			
		graph save 		05_output/03_figures/fig4_aim2.grp, replace
		graph export 	05_output/03_figures/fig4_aim2.png, as(png) replace
		graph export	05_output/03_figures/fig4_aim2.pdf, as(pdf) replace

			
**Close the master log
log close master

**exit the do-file
exit
















