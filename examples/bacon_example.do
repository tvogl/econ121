clear all
pause on
cap log close
log using bacon_example.log,replace

*analysis of bacon consumption in the national health interview survey.
*open nhis dta, describe and summarize.
use nhis2000

d
sum
pause

*generate a variable that equals one if any bacon consumption, zero otherwise.
*stata counts missing values as very high values, so we must be careful to instruct
*stata to ignore missing values.
tab bacon,miss
gen anybacon = (bacon>0) if bacon<.
keep if anybacon<.
pause

*generate some covariates.
*gender.
tab sex
tab sex,nol
gen male = 2-sex

*marital status: first a dummy for marriage, then a categorical variable.
tab marstat
tab marstat,nol
gen married = (marstat<20) if marstat<.

******************************
****BINARY OUTCOME************
******************************

**COMPARING OLS, LOGIT, AND PROBIT

*estimate a linear probability model, a logit, and a probit.
*then generate predicted probabilities for each of these approaches.
*then compare the predicted probabilities
reg anybacon edyrs age male black hisp other married,robust
predict p_ols

probit anybacon edyrs age male black hisp other married,robust
predict p_probit

logit anybacon edyrs age male black hisp other married,robust
predict p_logit

sum p_*
corr p_*
pause

**WEIGHTED LEAST SQUARES

*note that an alternative to using the "robust" option in the
*linear probability model above is to use weighted least squares.
*recall that this only works if the predicted probabilities p_ols 
*lie between zero and one, as they do here. following the lecture 
*note, we generate the weight:
gen weight = 1/(p_ols*(1-p_ols))
*and then run the regression
reg anybacon edyrs age male black hisp other married [aw=weight]
pause

**PREDICTED PROBABILITIES

*now let's make the logit and probit coefficients more interpretable.
*start by generating predicted probabilities. suppose we want to 
*isolate the "effect" of education, controlling for the other covariates.
*first we save our data:
save temp,replace
*then we can run:
probit anybacon edyrs age male black hisp other married,robust
*and before generating the predictions, we set all the other covariates
*equal to their means:
foreach var of varlist age male black hisp other married {
  sum `var'
  replace `var' = r(mean)
  }
predict p_hat
*now let's plot the adjusted predictions against education
twoway scatter p_hat edyrs
pause

*reopen the original dataset
use temp,clear

**MARGINAL EFFECTS

*now let's compute marginal effects at the means of the independent
*variables. one way to do this is to run a logit or a probit and
*to then use the mfx compute command:
logit anybacon edyrs age male black hisp other married,robust
mfx compute

probit anybacon edyrs age male black hisp other married,robust
mfx compute
pause

*alternatively, we can use margins to compute avergae 
*marginal effects. here we do it for the probit above:
margins,dydx(*)
pause

*we can also calculate marginal effects in the probit model
*using the dprobit command:
dprobit anybacon edyrs age male black hisp other married,robust
pause
*note that the marginal effects are the same as those computed
*by mfx compute. but they are NOT the same as those computed
*by margins. that's because mfx and dprobit evaluate marginal
*effects at the means of the independent variables, while
*margins evaluates the average marginal effect.

*stata does not provide a similar command for logits,
*but you can download one from the internet if you so
*desire. type "net search dlogit2" in stata; follow the 
*instructions.

**ODDS RATIOS

*finally, we can also estimate odds ratios in the logit setting:
logit anybacon edyrs age male black hisp other married,robust or
logistic anybacon edyrs age male black hisp other married,robust
pause
*these are especially convenient for binary independent variables.
*for instance, men have 48% higher odds of eating bacon than women.

log close
