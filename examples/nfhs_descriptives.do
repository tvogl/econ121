*this do-file plots the relationship between age and asset 
*ownership in India, using the National Family Health Survey.
pause on

use "https://github.com/tvogl/econ121/raw/main/data/nfhs4.dta",clear

d
sum age,d
keep if age>=20&age<=80 //drop households with very old or very young heads
sum assets //asset ownership measure was scaled to have mean zero and SD 1, so makes sense
pause

*note that the survey has sampling weights. these are to
*adjust for the fact that the sample was not a simple
*random sample. subpopulations that were undersampled receive
*larger sampling weights, so that weighted statistics provide
*unbiased estimates of population parameters. if p is the
*probability that a households was included in the sample,
*then that household's weight is proportional to 1/p.
sum weight,d
hist weight,percent
pause

*let's aggregate the data to age bins and plot average assets by age.
*for unbiased estimates of means, we should weight.
collapse (mean) mean_assets=assets (sd) sd_assets=assets [aw=weight],by(age)
pause
*relationship of mean assets and age: non-linear!
scatter mean_assets age ///
        ,msymbol(Oh) xlabel(20(10)80,grid) ylabel(,grid)
pause
*relationship of sd assets and age: heteroskedastic!
scatter sd_assets age  ///
        ,msymbol(Oh) xlabel(20(10)80,grid) ylabel(,grid)
pause

*we will talk more about sampling weights in the next couple weeks.



