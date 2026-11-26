program define grotta_legend, rclass
	version 18.0

    colorpalette HCL reds, n(15) nograph reverse

    forvalues i = 1/15 {
        local col`i' "`r(p`i')'"
    }

    frame create legend
    frame change legend

    twoway ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col1'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col2'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col3'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col4'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col5'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col6'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col7'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col8'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col9'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col10'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col11'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col12'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col13'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col14'")) ///
        (scatteri 0 0, msymbol(square) msize(medium) mcolor("`col15'")), ///
        legend(cols(3) position(6) size(vsmall) region(lstyle(none)) span ///
            order( ///
            1 "None of the below" ///
            2 "Admitted to neonatal unit <48hrs" ///
            3 "Admitted neonatal unit >=48hrs" ///
            4 "Non-invasive respiratory support >=1 and <5 days" ///
            5 "Non-invasive respiratory support >=5 days" ///
            6 "MV via ETT >=1 and <7 days" ///
            7 "MV via ETT >=7 days" ///
            8 "Moderate respiratory morbidity" ///
            9 "NEC/Sepsis" ///
            10 "Severe respiratory morbidity" ///
            11 "Major surgery" ///
            12 "Brain injury" ///
            13 "Two of: severe respiratory morbidity, major surgery, or brain injury" ///
            14 "Severe respiratory morbidity AND major surgery AND brain injury" ///
            15 "Death") ) ///
        xlabel(none) ylabel(none) xscale(off) yscale(off) ///
        xtitle("") ytitle("") ysize(1) xsize(2) aspectratio(2, placement(left)) ///
        plotregion(lstyle(none) fcolor(none) margin(zero)) ///
        graphregion(color(white) margin(zero)) /// 
        note("{it:resp.: respiratory, MV: mechanical ventilation, ETT: endotracheal tube, NEC: Necrotizing enterocolitis}", size(vsmall))
        
    frame change default
	frame drop legend

end	