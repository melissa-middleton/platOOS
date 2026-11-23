********************************************************************************
** Stata program to generate reanalysis estimates for the PLATIPUS outcome validation 
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
program define reanalysis, rclass
	version 18.0
	
	syntax [anything] using/  ///
		[,	exp(string) ///
			strat(string) ///
			bin_out(string)]
			
			
	cap frame drop reanalysis
	frame create reanalysis
	frame change reanalysis
	
	cap use `using', clear
		if _rc != 0 {
			frame change default
			frame drop reanalysis
			di as error "Data file not found"
			exit 601
		}
			
	**Check variables exist in dataset
	cap desc `anything' 
		if _rc != 0 {
			di as error "Outcome variable not found"
			frame change default
			frame drop reanalysis
			exit
		}
		
	
	
	if "`exp'" != "" {
	
		**Check coding of exposure variable
		cap desc `exp'
			if _rc != 0 {
				di as error "Exposure not found"
				frame change default
				frame drop reanalysis
				exit
			}
			
		** Proportional odds model
		ologit `anything' `exp' `strat' , or 
			local por = round(exp(_b[`exp']), 0.01)
			local por_lci = round(exp(_b[`exp'] - 2* _se[`exp']), 0.01)
			local por_uci = round(exp(_b[`exp'] + 2* _se[`exp']), 0.01)
	
	if "`bin_out'" != "" {
		**Binary outcome
		logit `bin_out' `exp' `strat' , or 
			local or = round(exp(_b[`exp']), 0.01)
			local or_lci = round(exp(_b[`exp'] - 2* _se[`exp']), 0.01)
			local or_uci = round(exp(_b[`exp'] + 2* _se[`exp']), 0.01)
			
		matrix define results = (`por', `por_lci', `por_uci', `or', `or_lci', `or_uci')
			
	}
	else {
		matrix define results = (`por', `por_lci', `por_uci')
	}
	
	
	return matrix results = results
	
	}
	
	frame change default
	frame drop reanalysis
	
end