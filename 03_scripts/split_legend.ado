program define split_legend, rclass
	version 18.0

    frame create legend
    frame change legend

    colorpalette HCL reds, n(15) nograph reverse

    forvalues i = 2/15 {
        local col`i' "`r(p`i')'"
    }

    **Set up dummy values for legend
    set obs 1
    
    twoway ///
        (scatteri 10.5 12, text(10.5 13 "{bf:OR and 95% confidence interval for outcome}" "{bf:dichotomoised as 'at category or higher'}", place(e)) msymbol(none) mlabcolor(black)) ///
        ///
        (scatteri 9.25 12.5, msymbol(circle) msize(medium) mcolor("`col15'")) ///
        (scatteri 9.25 12 9.25 13 (3) "Death", msy(pipe) connect(line) mcolor("`col15'") lcolor("`col15'") mlabcolor(black) mlabsize(vsmall)) ///
            (scatteri 9.25 19.5, msymbol(circle) msize(medium) mcolor("`col8'")) ///
            (scatteri 9.25 19 9.25 20 (3) "Moderate respiratory morbidity", msy(pipe) connect(line) mcolor("`col8'") lcolor("`col8'") mlabcolor(black) mlabsize(vsmall)) ///
        (scatteri 8.5 12.5, msymbol(circle) msize(medium) mcolor("`col14'")) ///
        (scatteri 8.5 12 8.5 13 , text(8.5 13.15 "Severe respiratory morbidity AND" "major surgery AND brain injury", place(e) size(vsmall) j(left)) msy(pipe) connect(line) mcolor("`col14'") lcolor("`col14'")) ///
            (scatteri 8.5 19.5, msymbol(circle) msize(medium) mcolor("`col7'")) ///
            (scatteri 8.5 19 8.5 20 (3) "MV via ETT >=7 days", msy(pipe) connect(line) mcolor("`col7'") lcolor("`col7'") mlabcolor(black) mlabsize(vsmall)) ///
        (scatteri 7.75 12.5, msymbol(circle) msize(medium) mcolor("`col13'")) ///
        (scatteri 7.75 12 7.75 13, text(7.75 13.15 "Two of: severe respiratory morbidity," "major surgery, or brain injury", place(e) size(vsmall) j(left)) msy(pipe) connect(line) mcolor("`col13'") lcolor("`col13'")) ///
            (scatteri 7.75 19.5, msymbol(circle) msize(medium) mcolor("`col6'")) ///
            (scatteri 7.75 19 7.75 20 (3) "MV via ETT >=1 and <7 days", msy(pipe) connect(line) mcolor("`col6'") lcolor("`col6'") mlabcolor(black) mlabsize(vsmall)) ///
        (scatteri 7 12.5, msymbol(circle) msize(medium) mcolor("`col12'")) ///
        (scatteri 7 12 7 13 (3) "Brain injury", msy(pipe) connect(line) mcolor("`col12'") lcolor("`col12'") mlabcolor(black) mlabsize(vsmall)) ///
            (scatteri 7 19.5, msymbol(circle) msize(medium) mcolor("`col5'")) ///
            (scatteri 7 19 7 20, text(7 20.15 "Non-invasive respiratory support" ">=5 days", place(e) size(vsmall) j(left)) msy(pipe) connect(line) mcolor("`col5'") lcolor("`col5'") mlabcolor(black) mlabsize(vsmall)) ///
        (scatteri 6.25 12.5, msymbol(circle) msize(medium) mcolor("`col11'")) ///
        (scatteri 6.25 12 6.25 13 (3) "Major surgery", msy(pipe) connect(line) mcolor("`col11'") lcolor("`col11'") mlabcolor(black) mlabsize(vsmall)) ///
            (scatteri 6.25 19.5, msymbol(circle) msize(medium) mcolor("`col4'")) ///
            (scatteri 6.25 19 6.25 20, text(6.25 20.15 "Non-invasive respiratory support" ">=1 and <5 days", place(e) size(vsmall) j(left)) msy(pipe) connect(line) mcolor("`col4'") lcolor("`col4'") mlabcolor(black) mlabsize(vsmall)) ///
        (scatteri 5.5 12.5,  msymbol(circle) msize(medium) mcolor("`col10'")) ///
        (scatteri 5.5 12 5.5 13 (3) "Severe respiratory morbidity", msy(pipe) connect(line) mcolor("`col10'") lcolor("`col10'") mlabcolor(black) mlabsize(vsmall)) ///
            (scatteri 5.5 19.5, msymbol(circle) msize(medium) mcolor("`col3'")) ///
            (scatteri 5.5 19 5.5 20 (3) "Admitted neonatal unit >=48hrs", msy(pipe) connect(line) mcolor("`col3'") lcolor("`col3'") mlabcolor(black) mlabsize(vsmall)) ///
        (scatteri 4.75 12.5, msymbol(circle) msize(medium) mcolor("`col9'")) ///
        (scatteri 4.75 12 4.75 13 (3) "NEC/Sepsis", msy(pipe) connect(line) mcolor("`col9'") lcolor("`col9'") mlabcolor(black) mlabsize(vsmall)) ///
            (scatteri 4.75 19.5, msymbol(circle) msize(medium) mcolor("`col2'")) ///
            (scatteri 4.75 19 4.75 20 (3) "Admitted neonatal unit <48hrs", msy(pipe) connect(line) mcolor("`col2'") lcolor("`col2'") mlabcolor(black) mlabsize(vsmall)) ///
        ///
        (scatteri 3.75 13 3.75 14 (3) "Proportional Odds Ratio", connect(line) lpattern(dash) lcolor(gs8) msymbol(i) mlabcolor(black) mlabsize(vsmall)) ///
        (scatteri 3.75 18 3.75 19 (3) "95% Confidence Interval", connect(line) lcolor(gs10%20) lwidth(vvthick) msymbol(i) mlabcolor(black) mlabsize(vsmall)), ///
        legend(off) ytitle("") ylabel(none) xtitle("") xlabel(none) xscale(off noline range(11 26)) yscale(off range(3 11)) ///
        note("{it:resp.: respiratory, MV: mechanical ventilation, ETT: endotracheal tube, NEC: Necrotizing enterocolitis}", size(vsmall))
        
    frame change default
	frame drop legend

end	

*xlabel(11(1)26)`: display "Severe respiratory morbidity AND" _n "major surgery AND brain injury"'