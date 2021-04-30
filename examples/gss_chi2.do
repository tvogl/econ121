clear all
pause on
cap log close
*log using gss_chi2.log,replace

*chi2 example using the US General Social Survey
use "https://github.com/tvogl/econ121/raw/main/data/gss_2004_2016.dta",clear

d
sum
pause

*first we look at the relationship between parents' education
*and their children's education. we consider the highest degree
*obtained, which has multiple categories.

*cross-tab of parents' highest degree and respondent's highest degree
tab pardeg deg
*are these variables independent of each other? add the chi2 test.
tab pardeg deg,chi
*p-value is < 0.001, so we reject independence! parents' and children's
*highest degree are related. we can make the cross-tab more interpretable
*by changing the "cell sizes" to "row frequencies" as follows:
tab pardeg deg,chi row nofreq
*now we can see that among respondents whose parents have less than 
*high school, 32% drop out of high school, and 5% percent obtain
*graduate degrees. in contrast, among repondents with parents who
*have graduate degrees, 2% drop out of high school, and 30% obtain
*graduate degrees.

*now let's do a two-by-two example. to make matters interesting, 
*let's look at the relationship between political party and 
*unwillingness to vote for a Black president. (the Black  
*president question was asked in 2008 and 2010.)
tab republican racpres,row nofreq chi
*republicans are more likely than non-republicans to be unwilling
*to vote for a Black president. the difference is statistically 
*significant, with a p-value of 0.003.
*now let's confirm that we get the same answer from prtest:
prtest racpres,by(republican)
*and ttest:
ttest racpres,by(republican)
*and regression:
reg racpres republican


cap erase temp.dta
cap log close
