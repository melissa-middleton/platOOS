********************************************************************************
** Stata program to generate split odds ratio forest plots for the PLATIPUS outcome validation 
** project.
**
**	Author: 	Melissa Middleton
**	Date:		02/07/2025
** 	Version: 	v1.0
**	Updates:
**
**
**	Args:
********************************************************************************
program define split_odds, rclass
	version 18.0
	
	syntax [anything] using/  ///
		[,	exp(string) ///
			graphname(string) ///
			strat(string)]

	cap frame drop splitodds
	frame create splitodds
	frame change splitodds
	
	cap use `using', clear
		if _rc != 0 {
			frame change default
			frame drop splitodds
			di as error "Data file not found"
			exit 601
		}
			
	**Check variables exist in dataset
	cap desc `anything' 
		if _rc != 0 {
			di as error "Outcome variable not found"
			frame change default
			frame drop splitodds
			exit
		}
		
	
	
	if "`exp'" != "" {
	
		**Check coding of exposure variable
		cap desc `exp'
			if _rc != 0 {
				di as error "Exposure not found"
				frame change default
				frame drop splitodds
				exit
			}
		
		**Create the splits and analyse
		forval i = 2/15 {
		local j = `i' - 1
		tempvar bin`j'v`i'
	
		gen `bin`j'v`i'' = `anything' >= `i' & `anything' != .
	
		**Piecewise odds models
		cap noi logit `bin`j'v`i'' `exp' `strat' 
			if _rc == 0 { 
				local b`j'v`i' 	= _b[`exp']
				local se`j'v`i' 	= _se[`exp'] 
			}
		}
			
		** Proportional odds model
		ologit `anything' `exp' `strat' , or 
				local por = round(exp(_b[`exp']), 0.01)
				local por_lci = round(exp(_b[`exp'] - 2* _se[`exp']), 0.01)
				local por_uci = round(exp(_b[`exp'] + 2* _se[`exp']), 0.01)
			
	
		********************************************************************************
		** 03 CREATE PLOT OF BINARY SPLIT LOGISTIC REGRESSION ESTIMATES
		********************************************************************************
		frame create bin_split
		frame bin_split {
	
			**Set obs size
			insobs 14

			**Gen variable identifier for cut point
			egen cut = seq(), from(2) to(15)

			label define cuts 	2 "1 v 2-15" ///
								3 "1-2 v 3-15" ///
								4 "1-3 v 4-15" ///
								5 "1-4 v 5-15" ///
								6 "1-5 v 6-15" ///
								7 "1-6 v 7-15" ///
								8 "1-7 v 8-15" ///
								9 "1-8 v 9-15" ///
								10 "1-9 v 10-15" ///
								11 "1-10 v 11-15" ///
								12 "1-11 v 12-15" ///
								13 "1-12 v 13-15" ///
								14 "1-13 v 14-15" ///
								15 "1-14 v 15"
						
			lab val cut cuts
	
			**Store estimates for beta coeff and se 
			gen beta = .
			gen se = .

			forval i = 2/15 {
				local j = `i' - 1
				cap replace beta = `b`j'v`i'' if cut == `i' 
				cap replace se = `se`j'v`i'' if cut == `i' 
			}

			**generate conifdence interval limits
			gen cil = beta - 2*se
			gen ciu = beta + 2*se

			**Exponentiate results to display on odds scale
			gen or = exp(beta)
			gen or_cil = exp(cil)
			gen or_ciu = exp(ciu)

			gen por_lci = `por_lci'
			gen por_uci = `por_uci'
			gen por = `por'

			** Generate graphic 
			twoway (scatter cut or, mcol(navy)) (rcap or_ciu or_cil cut, horizontal lcol(navy)) (scatteri . ., connect(l) lpattern(dash) lcolor(gray) msymbol(i)) (rarea por_lci por_uci cut, lwidth(none) fcolor(gray%20) horizontal) /// 
				, ///
				title("Estimated odds ratio for the intervention" "at each binary split of the ordinal outcome") legend(subtitle("Proportional" "Odds Ratio", ) order(3 "Estimate" 4 "95% Confidence" "Interval") position(3) cols(1) size(small)) ///
				xline(`por', lcolor(gray)) xline(1, lcol(black) lstyle(solid)) ///
				xtitle("Estimated Odds Ratio") ytitle("Binary Split") ylab(2(1)15,val angle(0)) xscale(log)
	
			**Export graphic
			graph export "`graphname'.png", replace
		} //end frame
		
		frame change default
		frame drop splitodds
		frame drop bin_split

	}

end