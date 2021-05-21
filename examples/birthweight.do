*This example studies the relationship between birth weight and test scores
use nlsy_deming.dta,clear

*Decribe the data
d
sum

*Let's look at the structure of the panel data for a few key variables
sort mom_id /*sort so that siblings are next to each other in the dataset*/
browse mom_id hispanic black momed male firstborn lnbw comp_score_11to14

*OLS with robust standard errors
reg comp_score_11to14 lnbw,robust

*OLS with clustered standard errors
reg comp_score_11to14 lnbw,cluster(mom_id)

*Random effects
*The estimated coefficient changes a lot,
*which suggest that the between-family variation
*and the within-family variation lead to different
*coefficients. Many researchers would conclude 
*that we should rely on fixed effects.
xtreg comp_score_11to14 lnbw,i(mom_id) re

*Random effects with robust standard errors
*Note that in the xt commands, Stata automatically 
*clusters at the group level.
xtreg comp_score_11to14 lnbw,i(mom_id) re robust

*Fixed effects
*Here, the estimated coefficient shrinks even
*more, consistent with upward bias from between-family
*variation.
xtreg comp_score_11to14 lnbw,i(mom_id) fe
areg comp_score_11to14 lnbw,a(mom_id)

*Fixed effects with robust standard errors
*xtreg automatically clusters at the group level.
*areg does not unless you specify clustered standard errors.
xtreg comp_score_11to14 lnbw,i(mom_id) fe robust
areg comp_score_11to14 lnbw,a(mom_id) robust
areg comp_score_11to14 lnbw,a(mom_id) cluster(mom_id)
*Note that the coefficient estimates are all the same.
*But the SEs are all different! The xtreg,robust result 
*should in theory be the same as the areg,cluster result.
*Stata is using a different degrees of freedom adjustment
*in the xtreg command. Both standard errors are 
*theoretically justified, but statisticians would prefer
*the xtreg one.

*Let's try adding some control variables. We will add black,
*hispanic, and momed as examples of control variables that 
*DO NOT vary within family. We will add male and first born
*as examples of covariates that DO vary within family. Since
*adding control variables changes the sample size, we will 
*rerun the models without control variables in the smaller
*sample.

*OLS with and without control variables. The "if e(sample)"
*in lines 2-3 restricts the sample to the one used in the
*previous regression. Consistent with the comparison of FE and OLS,
*adding the family-level control variables reduces the estimates a lot.
*Adding just the individual-level control variables doesn't do much.
reg comp_score_11to14 lnbw hispanic black momed male firstborn,cluster(mom_id)
reg comp_score_11to14 lnbw male firstborn if e(sample),cluster(mom_id)
reg comp_score_11to14 lnbw if e(sample),cluster(mom_id)

*FE with and without control variables. The family-level control
*variables are dropped because they are collinear with the mother
*fixed effects. Again, the individual-level control variables
*don't much change the estimates on lnbw.
xtreg comp_score_11to14 lnbw hispanic black momed male firstborn,fe i(mom_id) robust
xtreg comp_score_11to14 lnbw male firstborn if e(sample),fe i(mom_id) robust
xtreg comp_score_11to14 lnbw if e(sample),fe i(mom_id) robust

