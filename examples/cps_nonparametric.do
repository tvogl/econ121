cap log close
log using cps_nonparametric.log,replace
pause on

*this do-file studies the relationship or gender, race, and age 
*with income in the united states, using the current population 
*survey. it relies on nonparametric estimators.

*I will focus only on Black-white differences. If you are 
*in other racial/ethnic groups, I encourage you to modify 
*the do file in your spare time.

use "https://github.com/tvogl/econ121/raw/main/data/cps_18.dta",clear

d
sum

*race and sex labels
label list race_lbl
label list sex_lbl
pause

*generate white, black, male, female, log income (not hourly)
gen white = (race==100)
gen black = (race==200)
gen male = (sex==1)
gen female = (sex==2)
gen lninc = ln(incwage)
pause

*what is the sd of lninc?
sum lninc

*kernel density estimates of log income by race and sex
*let's use .25 as the bandwidth, about a quarter of the sd of lninc.
twoway (kdensity lninc if black==1&female==1,bw(.25) lcolor(orange_red)) ///
       (kdensity lninc if white==1&female==1,bw(.25) lcolor(dknavy)) ///
       (kdensity lninc if black==1&male==1,bw(.25) lcolor(orange_red) lpattern(dash)) ///
       (kdensity lninc if white==1&male==1,bw(.25) lcolor(dknavy) lpattern(dash)) ///
	   ,legend(label(1 "Black women") label(2 "White women") ///
	           label(3 "Black men") label(4 "White men"))
pause
			   
*now let's try a bandwidth of .1 -> higher variance, but more detail
twoway (kdensity lninc if black==1&female==1,bw(.1) lcolor(orange_red)) ///
       (kdensity lninc if white==1&female==1,bw(.1) lcolor(dknavy)) ///
       (kdensity lninc if black==1&male==1,bw(.1) lcolor(orange_red) lpattern(dash)) ///
       (kdensity lninc if white==1&male==1,bw(.1) lcolor(dknavy) lpattern(dash)) ///
	   ,legend(label(1 "Black women") label(2 "White women") ///
	           label(3 "Black men") label(4 "White men"))
pause
			   
*now let's track racial differences in log wages over the lifecycle
*using local linear regression. set the degree to 1 because we are
*estimating a local LINEAR regression (not quadratic, cubic, etc.).
*and start with a bandwidth of 1 year of age.
twoway (lpoly lninc age if black==1&female==1,degree(1) bw(1) lcolor(orange_red)) ///
       (lpoly lninc age if white==1&female==1,degree(1) bw(1) lcolor(dknavy)) ///
       (lpoly lninc age if black==1&male==1,degree(1) bw(1) lcolor(orange_red) lpattern(dash)) ///
       (lpoly lninc age if white==1&male==1,degree(1) bw(1) lcolor(dknavy) lpattern(dash)) ///
	   ,legend(label(1 "Black women") label(2 "White women") ///
	           label(3 "Black men") label(4 "White men"))   
pause
			   
*what happens if we expand the bandwidth to 2 years? smoother curves.
twoway (lpoly lninc age if black==1&female==1,degree(1) bw(2) lcolor(orange_red)) ///
       (lpoly lninc age if white==1&female==1,degree(1) bw(2) lcolor(dknavy)) ///
       (lpoly lninc age if black==1&male==1,degree(1) bw(2) lcolor(orange_red) lpattern(dash)) ///
       (lpoly lninc age if white==1&male==1,degree(1) bw(2) lcolor(dknavy) lpattern(dash)) ///
	   ,legend(label(1 "Black women") label(2 "White women") ///
	           label(3 "Black men") label(4 "White men"))   
			   
