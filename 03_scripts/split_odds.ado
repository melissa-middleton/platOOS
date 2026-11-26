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
			titleby(string) ///
			strat(string) ///
			xtick(string asis)]

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

		colorpalette HCL reds, n(15) nograph reverse

		**obtain color palette for legend
		forvalues i = 2/15 {
    		local col`i' "`r(p`i')'"
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
				local por_lci = round(exp(_b[`exp'] - invnormal(0.975)* _se[`exp']), 0.01)
				local por_uci = round(exp(_b[`exp'] + invnormal(0.975)* _se[`exp']), 0.01)
			
	
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
			gen cil = beta - invnormal(0.975)*se
			gen ciu = beta + invnormal(0.975)*se

			**Exponentiate results to display on odds scale
			gen or = exp(beta)
			gen or_cil = exp(cil)
			gen or_ciu = exp(ciu)

			gen por_lci = `por_lci'
			gen por_uci = `por_uci'
			gen por = `por'

			** Generate graphic 
			twoway ///
    			(scatter cut or if cut == 2, mcolor("`col2'")  msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 2, horizontal lcolor("`col2'")) ///
    			(scatter cut or if cut == 3, mcolor("`col3'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 3, horizontal lcolor("`col3'")) ///
    			(scatter cut or if cut == 4, mcolor("`col4'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 4, horizontal lcolor("`col4'")) ///
    			(scatter cut or if cut == 5, mcolor("`col5'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 5, horizontal lcolor("`col5'")) ///
    			(scatter cut or if cut == 6, mcolor("`col6'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 6, horizontal lcolor("`col6'")) ///
    			(scatter cut or if cut == 7, mcolor("`col7'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 7, horizontal lcolor("`col7'")) ///
    			(scatter cut or if cut == 8, mcolor("`col8'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 8, horizontal lcolor("`col8'")) ///
    			(scatter cut or if cut == 9, mcolor("`col9'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 9, horizontal lcolor("`col9'")) ///
    			(scatter cut or if cut == 10, mcolor("`col10'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 10, horizontal lcolor("`col10'")) ///
    			(scatter cut or if cut == 11, mcolor("`col11'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 11, horizontal lcolor("`col11'")) ///
    			(scatter cut or if cut == 12, mcolor("`col12'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 12, horizontal lcolor("`col12'")) ///
    			(scatter cut or if cut == 13, mcolor("`col13'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 13, horizontal lcolor("`col13'")) ///
    			(scatter cut or if cut == 14, mcolor("`col14'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 14, horizontal lcolor("`col14'")) ///
    			(scatter cut or if cut == 15, mcolor("`col15'") msymbol(circle) msize(medium)) ///
    			(rcap or_ciu or_cil cut if cut == 15, horizontal lcolor("`col15'")) ///
    			(rarea por_lci por_uci cut, horizontal fcolor(gs10%20) lcolor(gs10%20) lwidth(none)) ///
    			(scatteri . ., connect(line) lpattern(dash) lcolor(gs8) msymbol(i)), ///
    			xline(`por', lcolor(gs8) lpattern(dash)) xline(1, lcolor(black) lpattern(solid)) ///
    			xscale(log) xtick(`xtick') xlabel(`xtick') xtitle("Estimated odds ratio") ///
				ylabel(none) ytitle("") ///
    			title("`titleby'") legend(off) 

			**Export graphic
			*graph export "`graphname'.png", replace
		} //end frame

		frame change default
		frame drop splitodds
		frame drop bin_split

	}

end