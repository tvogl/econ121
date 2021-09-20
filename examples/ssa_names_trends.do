//analyzes naming trends in the social security names database (national).
//takes special interest in frequency of muslim names before and after 9/11/2001.

//save output in a log file
log using ssa_names_trends_log,replace

//open dataset
use "https://github.com/tvogl/econ121/raw/main/data/ssa_names.dta",clear

//summarize
sum

//structure of data - look at first 10 observations
list if _n<=10

//keep post 1990, since we are interested in 9/11
tab year
keep if year>=1990

//keep boy names only, since we are especially interested in Osama
tab sex
keep if sex=="M"

//note the difference in syntax: year is numeric, sex is string

//graph counts of three male muslim names, with a vertical line at 2001
twoway (line freq year if name=="Osama",lcolor(black) lwidth(thick)) ///
       (line freq year if name=="Mohammed",lcolor(orange)) ///
       (line freq year if name=="Ahmed",lcolor(blue)) ///
       ,xline(2001) ///
	    legend(label(1 "Osama") label(2 "Mohammed") ///
		       label(3 "Ahmed") rows(1))

//large levels differences --> counts awkward to compare
//let's take logs, so we can study proportional changes	   
gen lnfreq = ln(freq)		
twoway (line lnfreq year if name=="Osama",lcolor(black) lwidth(thick)) ///
       (line lnfreq year if name=="Mohammed",lcolor(orange)) ///
       (line lnfreq year if name=="Ahmed",lcolor(blue)) ///
       ,xline(2001) ///
	    legend(label(1 "Osama") label(2 "Mohammed") ///
		       label(3 "Ahmed") rows(1))
			   
//close log file and convert to PDF
log close
translate ssa_names_trends.smcl ssa_names_trends.pdf			   
