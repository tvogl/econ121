*this do-file continues analyzing the relationship 
*between age and asset ownership in India, using 
*the National Family Health Survey.
pause on

use "https://github.com/tvogl/econ121/raw/main/data/nfhs4.dta" if age>=20&age<=80,clear

*we left off with estimates of a single slope,
*as a summary of a population pattern. recall 
*that we used sampling weights, to ensure that
*the estimates are representative of the 
*estimate we would obtain for the full population.
reg assets age [aw=weight],cluster(clustnum)
pause

*heterogeneity between urban and rural areas
bysort rural: reg assets age [aw=weight],cluster(clustnum)
pause

*the urban/rural subsamples are independent, so we can compute
*a t-statistic for the difference in slopes "by hand"
di (.006709-.0100517)/sqrt(.0001704^2+.000329^2)
pause

*alternatively, we can use an interaction term
gen ruralXage = rural*age
reg assets age rural ruralXage [aw=weight],cluster(clustnum)
*same t-statistic! assets rise less steeply with age in rural areas.
pause

*if we wanted to obtain the slope for rural areas from
*the interacted model, we would take a linear combination
*of the coefficient on age plus coefficient on the ruralXage 
*interaction term.
lincom age+ruralXage
*same as we got when we estimated a separate regression for 
*rural areas!
pause

*note: in this sample, we could not compute the t-statistic 
*ourselves if we were interested in male/female differences in
*slopes. the primary sampling units are clusters, so the male
*and female subsamples are not independent. our only option
*here is to use an interaction term:
gen maleXage = male*age
reg assets age male maleXage [aw=weight],cluster(clustnum)
*no significant difference in slopes between men and women!
pause

*now let's suppose we are interested in the ratio of the urban
*slope to the rural slope. we have two options.

*option 1: delta method.
*start by estimating the interacted model.
reg assets age rural ruralXage [aw=weight],cluster(clustnum)
pause
*then use the nlcom command.
nlcom _b[age]/(_b[age]+_b[ruralXage])
*this is nice for interpretation. it's hard to interpret the 
*difference of 0.003 between the urban and rural slopes. but
*now we can say that the slope in urban areas is 50% higher than
*the slope in rural areas, and that proportional difference is
*statistically significant (because the 95% CI for the ratio
*excludes 1).
pause

*option 2: bootstrap the interacted model.
*let's start by just bootstrapping the model without calculating
*the ratio, just to get used to the bootstrap command. we'll do
*99 bootstrap replications. the simplest case is:
bootstrap,reps(99): reg assets age rural ruralXage
pause
*this command produces stardard errors that are robust to 
*heteroskedasticity, but they do not account for the clustered
*sampling in this survey, which is important. we can use the
*"block bootstrap" procedure, which resamples clusters (villages)
*instead of individuals:
bootstrap,reps(99) cluster(clustnum): reg assets age rural ruralXage
pause
*compare these with the analytical standard errors:
reg assets age rural ruralXage,cluster(clustnum)
pause
*very similar! note that we have not used survey weights here.
*it is difficult to incorporate weights into a bootstrap procedure,
*since the procedure emulates simple random sampling. a weighted
*sample is not a simple random sample. so let's bootstrap the ratio
*of urban to rural slopes, using a block bootstrap with no weighting.
bootstrap ratio=(_b[age]/(_b[age]+_b[ruralXage])),reps(99) cluster(clustnum): reg assets age rural ruralXage
pause

*let's conclude with a preview of the non-parametric
*methods we'll discuss on Monday. one of these methods
*is for flexible density estimation, and one is for 
*flexible regression estimation. each involves "local"
*estimation, in the sense that we estimate the density
*function or the regression function within a small 
*window, or "bandwidth," on the x-axis, and then we 
*move the window and re-estimate. this approach
*allows the slope of the function to change as we
*move across the x-axis.

*first, kernel density estimation. we use this
*method for a flexible representation of the
*pdf of the asset ownership measure. think of
*it as a continuous histogram. the key choice
*for us is the bandwidth, which determines how
*smoothness (wide bandwidth) or flexibility 
*(small bandwidth) of the estimated density function.
kdensity assets [aw=weight],bw(.5) //0.5 is half a standard deviation, so quite smooth
pause
kdensity assets [aw=weight],bw(.01) //0.5 is 1/20 of a standard deviation, so more flexible
pause
*we can combine them using "twoway"
twoway (kdensity assets [aw=weight],bw(.5) lcolor(black) lpattern(dash_dot)) ///
       (kdensity assets [aw=weight],bw(.25) lcolor(gs10) lpattern(shortdash)) ///
       (kdensity assets [aw=weight],bw(.05) lcolor(blue) lpattern(longdash)) ///
       (kdensity assets [aw=weight],bw(.01) lcolor(red) lpattern(solid)) ///
	   ,legend(label(1 "0.5") label(2 "0.25") label(3 "0.05") label(4 "0.01") rows(1)) ///
	    xtitle("Assets") ytitle("Kernel density estimate")
pause
		
*second, local linear estimation. we use this
*method for a flexible representation of the
*relationship between age and asset ownership.
*here again, we need to choose a bandwidth.
*we also need to tell Stata the "degree" of 
*the local polynomial. we want local linear,
*so the order of the polynomial is 1.
lpoly assets age [aw=weight],degree(1) bw(2)
pause
*Stata automatically adds a scatterplot,
*which expands the scale of the y-axis
*and makes it hard to study the regression
*estimate. we can remove the scatter as follows:
lpoly assets age [aw=weight],degree(1) bw(2) noscatter
pause
*or we can use "twoway" which automatically
*leaves out the scatter:
twoway lpoly assets age [aw=weight],degree(1) bw(2)
pause
*as before, we can also use "twoway" to
*compare results for different bandwidths:
twoway (lpoly assets age [aw=weight],degree(1) bw(10) lcolor(black) lpattern(dash_dot)) ///
       (lpoly assets age [aw=weight],degree(1) bw(5) lcolor(gs10) lpattern(shortdash)) ///
	   (lpoly assets age [aw=weight],degree(1) bw(2) lcolor(blue) lpattern(longdash)) ///
	   (lpoly assets age [aw=weight],degree(1) bw(1) lcolor(red) lpattern(solid)) ///
	   ,legend(label(1 "10") label(2 "5") label(3 "2") label(4 "1") rows(1)) ///
	    xtitle("Age of household head") ytitle("Assets")






