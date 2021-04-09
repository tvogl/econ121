*this do-file estimates the relationship between age 
*and asset ownership in India, using the National
*Family Health Survey.
pause on

use "https://github.com/tvogl/econ121/raw/main/data/nfhs4.dta" if age>=20&age<=80,clear

*first let's aggregate the data to age bins and plot average assets by age.
*note that we estimating weighted averages using the survey weights.
collapse (mean) mean_assets=assets (sd) sd_assets=assets (count) n=assets [aw=weight],by(age)
scatter mean_assets age [aw=n],msymbol(oh) nodraw name(mean,replace)
scatter sd_assets age [aw=n],msymbol(oh) nodraw name(sd,replace)
graph combine mean sd,cols(1)
pause

*now we are going to run a series of OLS regressions on the grouped data.
*since we have unequal group sizes, this may be a good scenario to weight
*by the number of observations in each group. however, that method works
*when the same model holds for everyone (i.e., beta is not heterogeneous)
*and the individual-level model is homoskedastic. we already know that
*the individual-level model is heteroskedastic, so we may not end up
*improving the precision of the estimator (i.e., shrinking the SEs).

*before we run the unweighted and weighted regressions, let's have a look
*at the group sizes by age:
scatter n age
pause

*linear regression using grouped data, with and without weighting by N.
*get different coefficients because of linearity. not clear that the 
*weighted regression is preferred.
reg mean_assets age,r
reg mean_assets age [aw=n],r 
pause

*quadratic regression using grouped data, with and without weighting by N.
*get very similar coefficients now, but smaller SEs in unweighted model,
*not as predicted under correct functional form, homoskedasticity, and  ==
*constant coefficients.
gen age2 = age^2
reg mean_assets age age2,r
reg mean_assets age age2 [aw=n],r
pause

*back to the micro data
use "https://github.com/tvogl/econ121/raw/main/data/nfhs4.dta" if age>=20&age<=80,clear

*estimate quadratic functional form, with and without weighting by 
*sampling weight. get slightly diffent coefficients, larger SEs.
*so the weighted estimate is NOT more efficient. it is also not
*necessarily the average coefficient in the population. it IS
*an estimate of the answer we would get from a census of the population.
gen age2 = age^2
reg assets age age2,r
reg assets age age2 [aw=weight],r
pause

*should actually estimate this taking the clustered sampling into
*account. villages were sampled, and then individuals within them.
*need cluster-robust SEs. the SEs become larger, consistent with
*positive intra-cluster correlations.
reg assets age age2 [aw=weight],cluster(clustnum)
pause

*even though the relationship is non-linear, it may still be
*useful to use a single slope as a summary of a population pattern.
*here it probably makes sense to weight.
reg assets age [aw=weight],cluster(clustnum)



