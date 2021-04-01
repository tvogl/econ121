cap log close
log using nlsy_diffs.log,replace
pause on

*******************************************
*ESTIMATING RACIAL DIFFERENCES IN EARNINGS*
*IN THE NAT'L LONGITUDINAL SURVEY OF YOUTH*
*******************************************

use "https://github.com/tvogl/econ121/raw/main/data/nlsy79.dta",clear

*list variables
describe
pause

*show mean and sd of labor earnings
sum laborinc07
pause

*more detailed summary with percentiles
*note that there are many zeros, which implies
*that we cannot take logarithms without first
*thinking about sample selection.
sum laborinc07,d
pause

*we can also see this by plotting histograms by race
hist laborinc07,by(black) percent
pause

*we will be interested in estimating differences
*between blacks and non-blacks.

*means by race. two methods:
bysort black: sum laborinc07
tab black,sum(laborinc07)
pause

*these results give us all the information we need 
*to test for differences by race. we use the "display"
*command, "di" for short, to perform calculations.
*difference:
di 47939.387-28484.452
*t-statistic:
di (47939.387-28484.452)/sqrt(57507.716^2/3643 + 34586.784^2/562)
*well above 1.96, so statistically significant by the usual standards.
pause

*alternative ways to run this test are...
*t-test with unequal variances:
ttest laborinc07,by(black) unequal
*regression with heteroskedasticity-robust standard errors:
reg laborinc07 black,r
*the slight differences across the commands are due to
*differences in how they adjust for "degrees of freedom," 
*and possibly also to rounding errors in the computation. 
*note also that the standard devitations are VERY
*different. hence it is very important to allow for
*unequal variances (or equivalently, heteroskedasticity).
pause

*it is actually uncommon to test for average differences
*in the level (rather than log) of earnings, including
*zeros from the non-employed. it would be much more
*typical to restrict to employed individuals. so let's
*restrict to people who worked at least 1000 hours in 2007:
*equivalent to a part-time job of 20 hours per week for
*50 weeks.
sum hours07,d
keep if hours07>=1000
*means of by race
tab black,sum(laborinc07)
*still an $18k difference, which amounts to a black/non-black
*ratio of:
di 58142/40512
pause
*now let's look at log earnings.
gen loginc07 = ln(laborinc07)
tab black,sum(loginc07)
*difference:
di 10.681949-10.332826
pause
*this difference in logs can by roughly interpreted as 
*a 35% difference in earnings, although this interpretation
*relies on calculus [dln(y)/dx], so it is really for
*continuous X variables rather than binary ones. if we 
*were being really careful, we would exponentiate the 
*difference of logs:
di exp(10.681949-10.332826)
*which implies a 42% difference in geometric means. this
*proportional difference is very close to the 44% difference
*in arithmetic means that we saw above.
pause
*the t-statistic:
di (10.681949-10.332826)/sqrt(.84377072^2/2792 + .9771058^2/364)
*well above 1.96, so statistically significant by the usual standards.
pause
*alternative ways to run this test are...
*t-test with unequal variances:
ttest loginc07,by(black) unequal
*regression with heteroskedasticity-robust standard errors:
reg loginc07 black,r
*same results. that is to say, a regression on a "dummy variable"
*for black leads to the same results as a difference of means


log close

