********************************************************************************
** Stata program to generate Grotta bar graphs for the PLATIPUS outcome validation 
** project.
**
**	Author: 	Melissa Middleton
**	Date:		18/06/2025
** 	Version: 	v1.0
**	Updates:
**
**
**	Args:
********************************************************************************
program define grotta_platipus, rclass
	version 18.0
	
	syntax [anything] using/  ///
		[,	exp(string) ///
			graphname(string) ///
			titleby(string)] ///
			connected(string)

	cap frame drop grotta
	frame create grotta
	frame change grotta
	
	cap use `using', clear
		if _rc != 0 {
			frame change default
			frame drop grotta
			exit 601
		}
			
	**Check variables exist in dataset
	cap desc `anything' 
		if _rc != 0 {
			di as error "Outcome variable not found"
			frame change default
			frame drop grotta
			exit
		}
		
	
	
	if "`exp'" != "" {
		**Check coding of exposure variable
		cap desc `exp'
			if _rc != 0 {
				di as error "Exposure not found"
				frame change default
				frame drop grotta
				exit
			}
		**Get level values for exposure
		qui levelsof `exp'
		local lvl1 = "`: word 1 of `r(levels)''"
		local lvl2 = "`: word 2 of `r(levels)''"
		**Obtain totals for treatment and control groups
		qui count if `exp' == `lvl1'
			local t`lvl1' = r(N)
		qui count if `exp' == `lvl2'
			local t`lvl2' = r(N)
		**Obtain cumulative proportions for each level of ordinal outcome
		forval i = 1/15 {
			qui count if `anything' <= `i' & `exp' == `lvl1'
				gen c`i'_`lvl1' = r(N)/`t`lvl1''*100
			qui count if `anything' <= `i' & `exp' == `lvl2'
				gen c`i'_`lvl2' = r(N)/`t`lvl2''*100
		}
		**Set starting point
		gen c0 = 0
		**Generate y-axis thresholds for the thickness of bars
		egen x`lvl1' = seq(), from(1) to(3)  
		egen x`lvl2' = seq(), from(4) to(6) 

		**set graphical parameters
		gen lab_bot = "`: label `: value label `exp'' `lvl1'', n = `t`lvl1''"
		gen lab_top = "`: label `: value label `exp'' `lvl2'', n = `t`lvl2''"

		keep in 1/6

		if "`connected'" == "n" {
			**Set graphical parameters
			gen mid = 50
			gen bot = 3.25
			gen top = 6.25

			** Set colourpalette
			colorpalette HCL reds, n(15) nograph reverse

			**Graph Grotta Plot
				twoway 	(rarea c0 c1_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p1)'")) ///
						(rarea c1_`lvl1' c2_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p2)'")) ///
						(rarea c2_`lvl1' c3_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p3)'")) ///
						(rarea c3_`lvl1' c4_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p4)'")) ///
						(rarea c4_`lvl1' c5_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p5)'")) ///
						(rarea c5_`lvl1' c6_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p6)'")) ///
						(rarea c6_`lvl1' c7_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p7)'")) ///
						(rarea c7_`lvl1' c8_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p8)'")) ///
						(rarea c8_`lvl1' c9_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p9)'")) ///
						(rarea c9_`lvl1' c10_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p10)'")) ///
						(rarea c10_`lvl1' c11_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p11)'")) ///
						(rarea c11_`lvl1' c12_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p12)'")) ///
						(rarea c12_`lvl1' c13_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p13)'")) ///
						(rarea c13_`lvl1' c14_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p14)'")) ///
						(rarea c14_`lvl1' c15_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p15)'")) ///
						(rarea c0 c1_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p1)'")) ///
						(rarea c1_`lvl2' c2_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p2)'")) ///
						(rarea c2_`lvl2' c3_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p3)'")) ///
						(rarea c3_`lvl2' c4_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p4)'")) ///
						(rarea c4_`lvl2' c5_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p5)'")) ///
						(rarea c5_`lvl2' c6_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p6)'")) ///
						(rarea c6_`lvl2' c7_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p7)'")) ///
						(rarea c7_`lvl2' c8_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p8)'")) ///
						(rarea c8_`lvl2' c9_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p9)'")) ///
						(rarea c9_`lvl2' c10_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p10)'")) ///
						(rarea c10_`lvl2' c11_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p11)'")) ///
						(rarea c11_`lvl2' c12_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p12)'")) ///
						(rarea c12_`lvl2' c13_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p13)'")) ///
						(rarea c13_`lvl2' c14_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p14)'")) ///
						(rarea c14_`lvl2' c15_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p15)'")) ///
						(scatter top mid, mlab(lab_top) mlabposition(0) msymbol(i) mlabcol(black)) ///
						(scatter bot mid, mlab(lab_bot) mlabposition(0) msymbol(i) mlabcol(black)), ///
					yscale(off) xtitle("Percentage") xlab(0(10)100,nogrid) ylab(, nogrid) ysize(5) ///
					legend(order(- " " - " " - " " 1 "None of the below" 2 "Admitted to neonatal unit <48hrs" ///
									3 "Admitted neonatal unit >=48hrs" 4 "Non-invasive respiratory support" ">=1 and < 5 days"  5 "Non-invasive respiratory support" ">= 5 days" ///
									6 "MV via ETT for >= 1 and < 7 days" 7 "MV via ETT for >= 7 days" 8 "Moderate respiratory morbidity" ///
									9 "NEC/Sepsis" 10 "Severe respiratory morbidity" 11 "Major surgery" ///
									12 "Brain injury" 13 "Two of: sev. respiratory morbidity," "major surgery, or brain injury" ///
									14 "Severe respiratory morbidity AND" "major surgery AND brain injury"  ///
									15 "Death" - " " - " " - " ") size(vsmall) position(3) bmargin(zero)) ///
					title("", justification(left)) note("{it:resp.: respiratory, MV: mechanical ventilation, ETT: endotracheal tube, NEC: Necrotizing enterocolitis}")
		}
		else {
			forval i = 1/15 {
				qui sum c`i'_`lvl1'
				local `lvl1'`i' = r(mean)
				qui sum c`i'_`lvl2'
				local `lvl2'`i' = r(mean)
			}

			**Set graphical parameters
			gen mid = 50
			gen bot = 0.8
			gen top = 6.25

			** Set colourpalette
			colorpalette HCL reds, n(15) nograph reverse

			**Graph Grotta Plot
				twoway 	(rarea c0 c1_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p1)'")) ///
						(rarea c1_`lvl1' c2_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p2)'")) ///
						(rarea c2_`lvl1' c3_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p3)'")) ///
						(rarea c3_`lvl1' c4_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p4)'")) ///
						(rarea c4_`lvl1' c5_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p5)'")) ///
						(rarea c5_`lvl1' c6_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p6)'")) ///
						(rarea c6_`lvl1' c7_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p7)'")) ///
						(rarea c7_`lvl1' c8_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p8)'")) ///
						(rarea c8_`lvl1' c9_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p9)'")) ///
						(rarea c9_`lvl1' c10_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p10)'")) ///
						(rarea c10_`lvl1' c11_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p11)'")) ///
						(rarea c11_`lvl1' c12_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p12)'")) ///
						(rarea c12_`lvl1' c13_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p13)'")) ///
						(rarea c13_`lvl1' c14_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p14)'")) ///
						(rarea c14_`lvl1' c15_`lvl1' x`lvl1', lwidth(none) horizontal col("`r(p15)'")) ///
						(rarea c0 c1_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p1)'")) ///
						(rarea c1_`lvl2' c2_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p2)'")) ///
						(rarea c2_`lvl2' c3_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p3)'")) ///
						(rarea c3_`lvl2' c4_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p4)'")) ///
						(rarea c4_`lvl2' c5_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p5)'")) ///
						(rarea c5_`lvl2' c6_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p6)'")) ///
						(rarea c6_`lvl2' c7_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p7)'")) ///
						(rarea c7_`lvl2' c8_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p8)'")) ///
						(rarea c8_`lvl2' c9_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p9)'")) ///
						(rarea c9_`lvl2' c10_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p10)'")) ///
						(rarea c10_`lvl2' c11_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p11)'")) ///
						(rarea c11_`lvl2' c12_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p12)'")) ///
						(rarea c12_`lvl2' c13_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p13)'")) ///
						(rarea c13_`lvl2' c14_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p14)'")) ///
						(rarea c14_`lvl2' c15_`lvl2' x`lvl2', lwidth(none) horizontal col("`r(p15)'")) ///
						(scatteri  4 ``lvl2'1' 3 ``lvl1'1', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'2' 3 ``lvl1'2', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'3' 3 ``lvl1'3', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'4' 3 ``lvl1'4', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'5' 3 ``lvl1'5', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'6' 3 ``lvl1'6', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'7' 3 ``lvl1'7', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'8' 3 ``lvl1'8', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'9' 3 ``lvl1'9', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'10' 3 ``lvl1'10', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'11' 3 ``lvl1'11', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'12' 3 ``lvl1'12', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'13' 3 ``lvl1'13', connect(l) msym(i) lcol(black%50)) ///
						(scatteri  4 ``lvl2'14' 3 ``lvl1'14', connect(l) msym(i) lcol(black%50)) ///
						(scatter top mid, mlab(lab_top) mlabposition(0) msymbol(i) mlabcol(black)) ///
						(scatter bot mid, mlab(lab_bot) mlabposition(0) msymbol(i) mlabcol(black)), ///
					yscale(off) xtitle("Percentage") xlab(0(10)100,nogrid) ylab(, nogrid) ysize(5) ///
					legend(order(- " " - " " - " " 1 "None of the below" 2 "Admitted to neonatal unit <48hrs" ///
									3 "Admitted neonatal unit >=48hrs" 4 "Non-invasive resp. support >=1 and < 5 days"  5 "Non-invasive resp. support >= 5 days" ///
									6 "MV via ETT for >= 1 and < 7 days" 7 "MV via ETT for >= 7 days" 8 "Moderate resp. morbidity" ///
									9 "NEC/Sepsis" 10 "Severe resp. morbidity" 11 "Major surgery" ///
									12 "Brain injury" 13 "Two of: severe resp. morbidity, major surgery, or" "brain injury" ///
									14 "Severe resp. morbidity AND major surgery"  "AND brain injury"  ///
									15 "Death" - " " - " " - " ") size(vsmall) position(3) bmargin(zero)) ///
					title(" ", justification(left)) note("{it:resp.: respiratory, MV: mechanical ventilation, ETT: endotracheal tube, NEC: Necrotizing enterocolitis}")
		}
	}
	else {
		**Obtain total N
		qui count if `anything' != .
		local tn = r(N)
		
	**Obtain cumulative proportions for each level of ordinal outcome
		forval i = 1/15 {
			qui count if `anything' <= `i' 
			gen c`i' = r(N)/`tn'*100
		}
	
		**Set starting point
		gen c0 = 0

		**Generate y-axis thresholds for the thickness of bars
		egen x = seq(), from(1) to(3)  

		**Set graphical parameters
		gen mid = 50

		keep in 1/3
		** Set colourpalette
		colorpalette HCL reds, n(15) nograph reverse
	
		**Graph Grotta Plot
		twoway 	(rarea c0 c1 x, lwidth(none) horizontal col("`r(p1)'")) ///
				(rarea c1 c2 x, lwidth(none) horizontal col("`r(p2)'")) ///
				(rarea c2 c3 x, lwidth(none) horizontal col("`r(p3)'")) ///
				(rarea c3 c4 x, lwidth(none) horizontal col("`r(p4)'")) ///
				(rarea c4 c5 x, lwidth(none) horizontal col("`r(p5)'")) ///
				(rarea c5 c6 x, lwidth(none) horizontal col("`r(p6)'")) ///
				(rarea c6 c7 x, lwidth(none) horizontal col("`r(p7)'")) ///
				(rarea c7 c8 x, lwidth(none) horizontal col("`r(p8)'")) ///
				(rarea c8 c9 x, lwidth(none) horizontal col("`r(p9)'")) ///
				(rarea c9 c10 x, lwidth(none) horizontal col("`r(p10)'")) ///
				(rarea c10 c11 x, lwidth(none) horizontal col("`r(p11)'")) ///
				(rarea c11 c12 x, lwidth(none) horizontal col("`r(p12)'")) ///
				(rarea c12 c13 x, lwidth(none) horizontal col("`r(p13)'")) ///
				(rarea c13 c14 x, lwidth(none) horizontal col("`r(p14)'")) ///
				(rarea c14 c15 x, lwidth(none) horizontal col("`r(p15)'")) ///
				, ///
			yscale(off) xtitle("Percentage") xlab(0(10)100,nogrid) ylab(, nogrid) ysize(5) ///
			legend(order(- " " - " " - " " 1 "None of the below" 2 "Admitted to neonatal unit <48hrs" ///
							3 "Admitted neonatal unit >=48hrs" 4 "Non-invasive resp. support >=1 and < 5 days"  5 "Non-invasive resp. support >= 5 days" ///
							6 "MV via ETT for >= 1 and < 7 days" 7 "MV via ETT for >= 7 days" 8 "Moderate resp. morbidity" ///
							9 "NEC/Sepsis" 10 "Severe resp. morbidity" 11 "Major surgery" ///
							12 "Brain injury" 13 "Two of: severe resp. morbidity, major surgery, or" "brain injury" ///
							14 "Severe resp. morbidity AND major surgery"  "AND brain injury"  ///
							15 "Death" - " " - " " - " ") size(vsmall) position(3) bmargin(zero)) ///
			title(" ", justification(left)) note("{it:resp.: respiratory, MV: mechanical ventilation, ETT: endotracheal tube, NEC: Necrotizing enterocolitis}")
	}
	
	graph export "`graphname'.png", replace

	frame change default
	frame drop grotta
	
end	