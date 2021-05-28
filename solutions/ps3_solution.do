//This do file presents solutions to ECON 121 Problem Set 3.

//Note: I chose to estimate "robust" standard errors throughout the 
//      analysis, but you could have chosen to use classical standard 
//      errors. I also did not include additional covariates unless
//      the problem set specifically asked for them, but you could have
//      included them.

/////////////
//Problem 1//
/////////////

//Summary statistics appear below. 21 percent of the sample participated
//in HS. 32 percent of the sample is black, and 20 percent is Hispanic.
//Average mother's education is 12 years. 3 in 10 repeat a grade, another
//3 in 10 go to college, and 7 in 10 graduate high school.
use "https://github.com/tvogl/econ121/raw/main/data/nlsy_deming.dta",clear
d
sum

//The question asks about the backgounds of kids who participated in HS.
//HS participants are more likely to be black, have lower family income,
//and have less educated mothers, on average. They are also more likely 
//to repeat a grade and less likely to go to college. However, these 
//differences in long-term outcomes may reflect selection bias rather
//than the effects of HS.
bysort head_start: sum

/////////////
//Problem 2//
/////////////

//We run an OLS regression of the age 5-6 test score on the HS indicator,
//clustering standard errors by mom_id. The results indicate that average
//test scores are 5.8 points lower for participants than for non-participants.
//The association is highly statistically significant and represents roughly
//one-quarter of a standard deviation in test scores. If we assumed participation
//is exogenous, then we would conclude that HS reduces test scores by one-
//quarter of a standard deviation on average. However, we already know that
//participation is associated with several background characteristics that
//are likely to have independent effects on test scores, which implies that
//the residual is correlated with HS participation. As a result, participation
//is not exogenous, and we should not interpret the association as a causal 
//effect.
reg comp_score_5to6 head_start,cluster(mom_id)

/////////////
//Problem 3//
/////////////

//We now run a random effects model. The estimated association between HS and
//the test score more than halves, from -5.8 to -2.5! This very large change 
//suggests that both OLS and RE deliver biased estimates of the causal effect 
//of HS. Specifically, OLS and RE use both between- and within-family variation,
//with each model putting different weights on the two sources of variation.
//The very large difference between OLS and RE suggests that the between and
//within regressions give very different answers. Given that we know of many
//potential biases in the between-family variation, we can conclude that we
//should rely exclusively on the within-family variation: fixed effects.

//I ran xtreg with robust (and therefore also cluster-robust) SEs. This is
//standard practice, but for the problem set, you could have also used
//"classical" SEs, which assume independence and homoskedasticity.
xtreg comp_score_5to6 head_start,i(mom_id) re robust

/////////////
//Problem 4//
/////////////

//Now we run fixed effects model with and without background controls. I first
//run the model without controls for the largest possible sample. I then run
//the model with controls for the subsample that has non-missing data on all
//covariates. Finally, I re-run the model without controls on the subsample.
//The final regression allows me to check whether any differences between the 
//first and second regressions are due to adding covariates or changing the 
//sample. You did not need to run the third regression to get full credit.

//For choosing control variables: we can only use variables that vary within
//family. Ethnicity, race, and mother's education do not vary in the family.
//Gender, first-born status, early-life family income, early-life father 
//exposure, and birth weight do vary in the family, so I include them. Note
//that PPVT scores also vary in the family, but they are available for a very
//small subset of observations, so I do not use them. This choice is subjective,
//but as researchers we often face tradeoffs between having more information
//(by including PPVT scores) and maintaining the composition of the sample
//(by excluding PPVT scores).

//The FE model suggests that HS participation raises test scores, in contrast to
//the negative effects suggested by OLS and RE. The likely reason is that between-
//family variation in HS participation is correlated with family disadvantage,
//which biases us toward finding a negative association in the OLS and RE models.
//The full-sample fixed effect model without controls indicates that HS
//raises test scores by 7.6 points, or one-third of a SD, on average. Adding 
//covariates shrinks the estimated effect to 5.6 points. This reduction might
//raise concerns about omitted variables within the family, but the final 
//regression suggests that it is due primarily to the change in sample composition.
//Specifically, if we estimate the model without controls in the sample that has
//data on the controls, the estimated effect is 6.0, very close to 5.6.
xtreg comp_score_5to6 head_start,i(mom_id) fe robust
xtreg comp_score_5to6 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw,i(mom_id) fe robust
xtreg comp_score_5to6 head_start if e(sample),i(mom_id) fe robust

/////////////
//Problem 5//
/////////////

//We run FE regressions of the three test scores on HS, finding that the estimated
//effects on test scores shrink as children get older. HS participation raises test
//scores by 7.6 points on average at ages 5-6, by 3.8 points at ages 7-10, and by
//3.8 points at ages 11 to 14. Because the test scores may be scaled differently
//at different ages, it may be useful to compare the effects to the standard 
//deviation of test scores at each age. The effects amount to one-third of a standard 
//deviation at ages 5-6 and roughly one-sixth of a standard deviation at later ages.
sum comp_score*
xtreg comp_score_5to6 head_start,i(mom_id) fe robust
xtreg comp_score_7to10 head_start,i(mom_id) fe robust
xtreg comp_score_11to14 head_start,i(mom_id) fe robust

//An alternative approach to standardizing the effects across ages would be
//to redefine the dependent variables to be measured in standard deviation 
//units. We can simply generate new standardized test scores in which we
//subtract the mean and divide by the standard deviation. We find the same
//results as above. In your problem set, you could have taken either approach
//for full credit.
sum comp_score*
gen std_score_5to6 = (comp_score_5to6-45.42266)/22.37593
gen std_score_7to10 = (comp_score_7to10-45.19414)/24.12119
gen std_score_11to14 = (comp_score_11to14-43.77577)/24.80608
xtreg std_score_5to6 head_start,i(mom_id) fe robust
xtreg std_score_7to10 head_start,i(mom_id) fe robust
xtreg std_score_11to14 head_start,i(mom_id) fe robust

//The regressions above use different samples for the different test scores.
//We might also want to check the results in a constant sample. We do so below
//and find a similar pattern: the test score effects are smaller at older ages.
//However, the smallest effects are at the intermediate ages.
gen all_test_scores = (comp_score_5to6<.&comp_score_7to10<.&comp_score_11to14<.)
tab all_test_scores
sum comp_score* if all_test_scores==1
xtreg comp_score_5to6 head_start if all_test_scores==1,i(mom_id) fe robust
xtreg comp_score_7to10 head_start if all_test_scores==1,i(mom_id) fe robust
xtreg comp_score_11to14 head_start if all_test_scores==1,i(mom_id) fe robust
//And now using standardized scores:
xtreg std_score_5to6 head_start if all_test_scores==1,i(mom_id) fe robust
xtreg std_score_7to10 head_start if all_test_scores==1,i(mom_id) fe robust
xtreg std_score_11to14 head_start if all_test_scores==1,i(mom_id) fe robust

/////////////
//Problem 6//
/////////////

//We run FE regressions for longer-term outcomes. We find that HS participation
//reduces grade repetition by 5 percentage points, reduces learning disability 
//diagnosis by 4 percentage points, raises high school graduation by 13 percentage
//points, raises college attendance by 7 percentage points, reduces idleness 
//(not working or studying) by 7 percentage points, and reduces fair/poor health
//by 7 percentage points. All of these results but one (for grade repetition)
//are significant at the 5 percent level. The grade repetition result is significant 
//at the 9 percent level.
xtreg repeat head_start,i(mom_id) fe robust
xtreg learndis head_start,i(mom_id) fe robust
xtreg hsgrad head_start,i(mom_id) fe robust
xtreg somecoll head_start,i(mom_id) fe robust
xtreg idle head_start,i(mom_id) fe robust
xtreg fphealth head_start,i(mom_id) fe robust

/////////////
//Problem 7//
/////////////

//The easiest way to test for heterogeneous effects by race, ethnicity, and sex
//is include interactions of the HS dummy with race, ethnicity, and sex dummies.
//We also need to control for the main effect of sex, but not for the main effects
//or race and ethnicity because they are collinear with the mother fixed effects.
//The results do not show much evidence of heterogeneity in effects by race, 
//ethnicity, and sex. None of the interaction terms are significant at the 5% level.

//You could have also run separate regressions for different groups.

gen hispXhs = hispanic*head_start
gen blackXhs = black*head_start
gen maleXhs = male*head_start
xtreg repeat head_start hispXhs blackXhs maleXhs male,i(mom_id) fe robust
xtreg learndis head_start hispXhs blackXhs maleXhs male,i(mom_id) fe robust
xtreg hsgrad head_start hispXhs blackXhs maleXhs male,i(mom_id) fe robust
xtreg somecoll head_start hispXhs blackXhs maleXhs male,i(mom_id) fe robust
xtreg idle head_start hispXhs blackXhs maleXhs male,i(mom_id) fe robust
xtreg fphealth head_start hispXhs blackXhs maleXhs male,i(mom_id) fe robust

/////////////
//Problem 8//
/////////////

//The evidence suggests that HS participation has lasting effects on children's
//outcomes, which provides some justification for the program's existence. Whether
//the government chould expand or cut funding for this and similar programs depends
//on its cost-effectiveness compared with other potential use of funds. In general,
//it is difficult to extrapolate the effects of program expansion from our estimated 
//average effects of treatment on the treated because the effects may be different
//in the new subpopulations that would gain access if the program expanded. At the
//same time, the lack of treatment effect heterogeneity in Problem 7 suggests that 
//perhaps we can extrapolate. Many answers could receive full credit for this
//question.


