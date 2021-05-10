//This do file presents solutions to ECON 121 Problem Set 2.

//Note: You may have noticed that the dataset includes a
//      primary sampling unit identifier and a sampling 
//      weight. It would be reasonable to cluster standard
//      errors at the PSU level and weight using sampling
//      weights, but these details were not the focus of the
//      problem set and are therefore not required. You may
//      have also noticed slight overlap in the white, black,
//      and hisp variables, which were supposed to be mutually
//      exclusive. This nuance was also not the point of the
//      problem set, so you were not required to correct it.  
//      My code ignores both these issues.

/////////////
//Problem 1//
/////////////

//Summary statistics appear below. 14 percent of the sample 
//reports being in fair or poor health, and 8 percent died 
//died within 5 years of the survey. The sample includes
//adults 25 and up, with a median age of 46. (The mean age
//is less meaningful because age was top-coded at 85. You
//did not need to notice this.) 57 percent of the sample
//is female, perhaps surprisingly. This gender imbalance
//has two sources. First, men and women responded to the 
//survey at different rates, so the gender imbalance shrinks
//when we use the sampling weights. Second, men die at 
//higher rates than women, so the gender imbalance grows
//with age.

use "https://github.com/tvogl/econ121/raw/main/data/nhis2000.dta",clear
d

tab health
gen fpoor = (health>3) if health<.
tab fpoor

tab mort5

tab age
sum age,d

tab sex
tab sex [aw=sampweight]
tab age sex [aw=sampweight],row nofreq

sum

/////////////
//Problem 2//
/////////////

//I draw local linear regressions with bandwidths of 1 year.
//5-year mortality is higher for people with fair/poor health
//than for people with good/very good/excellent health. In
//both groups, 5-year mortality rises non-linearly with age.
//Since local linear regression fits a linear regression within
//the bandwidth around each grid point, this method is the non-
//parametric version of the linear probability model.

twoway (lpoly mort5 age if fpoor==0,degree(1) bw(1) lcolor(black) lpattern(solid)) ///
       (lpoly mort5 age if fpoor==1,degree(1) bw(1) lcolor(red) lpattern(dash)) ///
	   ,legend(order(1 "Good/Very Good/Excellent" 2 "Fair/Poor")) ///
	    ytitle("Predicted probability of death within 5 years") ///
		xtitle("Age")

/////////////
//Problem 3//
/////////////

//Rates of mortality and fair/poor health decline with
//family income. This pattern holds for the full sample
//as well as by gender. The same general pattern holds
//for education as well, although individuals with 
//post-graduate education do not appear to be in worse 
//health than college graduates.

//Generate family income category variable
gen faminc = 1 if faminc_gt75==0&faminc_20t75==0
replace faminc = 2 if faminc_gt75==0&faminc_20t75==1
replace faminc = 3 if faminc_gt75==1&faminc_20t75==0
label define faminc_lbl 1 "<20k" 2 "20k-75k" 3 ">75k"
label values faminc faminc_lbl
//Graphs
graph bar mort5 fpoor,over(faminc)
graph bar mort5 fpoor,over(faminc) by(sex)

//Generate education category variable
recode edyrs (1/11=1) (12=2) (13/15=3) (16=4) (17/19=5),gen(edlev)
label define edlev_lbl 1 "<12 yrs" 2 "12 yrs" 3 "13-15 yrs" 4 "16 yrs" 5 ">16 yrs"
label values edlev edlev_lbl
//Graphs
graph bar mort5 fpoor,over(edlev)
graph bar mort5 fpoor,over(edlev) by(sex)

/////////////
//Problem 5//
/////////////

//Because age and education have non-linear relation-
//ships with health, I include a series of dummy 
//variables for categories. I use the education cate-
//gories from above, and 10-year age intervals.

//For both outcomes and for all three models, the
//results show that mortality and fair/poor health 
//decline with income, decline with education, and 
//rise with age. One surprising result is that 
//conditional on the socioeconomic variables, racial
//gaps in mortality are small and insignificant.
//There are larger racial gaps in fair/poor health.
//Another surprising result is that Hispanics have
//low mortality risk (conditional on the other
//covariates).

//The linear probability results are similar to the
//probit and logit average marginal effects, although 
//the similarity is much stronger for fair/poor health
//than for mortality. You did not need to comment
//on the reason in your response, but the larger 
//difference in the case of mortality is probably
//due to the fact that mortality risk is exceptionally
//low across much of the age distribution, so that
//the marginal effect is calculated in the flatter part 
//of the CDF.

//Generate age categories variable (in decades)
gen agecat = floor(age/10)*10

//Mortality analyses
reg mort5 faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp,r
probit mort5 faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp,r
margins,dydx(*)
logit mort5 faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp,r
margins,dydx(*)

//Fair/poor health analyses
reg fpoor faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp,r
probit fpoor faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp,r
margins,dydx(*)
logit fpoor faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp,r
margins,dydx(*)

/////////////
//Problem 5//
/////////////

//I used the logit model above for this test. In
//that model, the difference between high income 
//African Americans and low income whites is the
//black coefficient plus the high income coefficient
//minus the white coefficient. The results suggest
//that high income blacks have significantly lower
//mortality rates than low income whites. You
//did not need to comment on the size of the gap,
//but the exponentiated difference (in the log odds) 
//is 0.59755, suggesting that high income blacks
//have 40 percent lower odds of 5-year mortality 
//than low income whites.

//It's likely that this model is not the best for 
//testing differences between these groups. It would
//be better to include interactions of race and income.

logit mort5 faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp,r
lincom black + faminc_gt75 - white
di exp(-.5149155)

/////////////
//Problem 6//
/////////////

//We probably should not interpret these results as causal.
//One problem is that there are many confounding variables
//that we do not observe but may jointly determine health
//and income, for instance place of birth. Another problem
//is that there may be reverse causality, i.e. health may
//affect income.

/////////////
//Problem 7//
/////////////

//I used the logit model again, and I exponentiated the 
//coefficients for interpretability. I control for
//insurance status, smoking status, exercise, bacon
//consumption, and obesity. To keep the samples the same
//in the regressions with and without the additional
//control variables, I run the "long" regression first
//and then run the "short" regression with "if e(sample)"
//to use the same sample as the previous regression. This
//detail was not required.

//Mortality results:
//Insurance status, bacon consumption, and obesity were
//not significantly associated with 5-year mortality risk.
//Smoking and exercise were highly associated with mortality
//risk: ever smoking raised the odds of death twofold, and
//weekly exercise halved the odds. These patterns explain part
//of the socioeconomic gradient in health. Upon controlling for
//these variables, the odds ratio on the high income dummy rose
//from 0.52 to 0.57 and the odds ratio on the >16 years of 
//education dummy rose from 0.46 to 0.58. Thus, health behavior
//explains a larger share of the education-mortality relationship
//than the income-mortality relationship.

//Fair/poor health results:
//Smoking, exercise, and obesity were positively associated
//with being in fair/poor health. Being uninsured and eating
//bacon were (surprisingly) negatively associated with
//being in fair/poor health -- likely because of reverse 
//causality. These patterns again explain part of the 
//socioeconomic gradient in health. The odds ratio on high
//income rises from 0.23 to 0.26, while that on >16 years
//rises from 0.21 to 0.29.

//Recode behavior variables as 0/1 dummies
sum uninsured smokev vig10fwk bacon bmi
tab uninsured
replace uninsured = 2-uninsured
tab smokev
replace smokev = 0.1*(smokev-1)
tab vig10fwk
replace vig10fwk = (vig10fwk>0) if vig10fwk<. //any exercise
tab bacon
replace bacon = (bacon>0) if bacon<. //any bacon/sausage
gen obese = (bmi>=30) if bmi<.

//Mortality analyses
logit mort5 faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp ///
      uninsured smokev vig10fwk bacon obese,r or
logit mort5 faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp if e(sample),r or

//Fair/poor health analyses
logit fpoor faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp ///
      uninsured smokev vig10fwk bacon obese,r or
logit fpoor faminc_20t75 faminc_gt75 i.edlev i.agecat white black hisp if e(sample),r or

/////////////
//Problem 8//
/////////////

//I tabulate the multicategoried health variable with the
//mort5 variable. To improve interpretability, I report 
//row fractions instead of cell frequencies. I assess
//statistical significance with a chi-squared test.

//The chi-squared test has a p-value of 0.000, so the
//two variables are significantly related to each other.
//Additionally, we can see that the share dying rises
//with each incremental change in reported health status,
//from 2% to 5% to 10% to 20% to 32%. We are indeed throwing
//out information by converting self-reported health status
//to a binary variable.

tab health mort5,row nofreq chi

//Note that we could have also drawn a bar graph, although
//it would not have told us about statistical significance.

graph bar mort5,over(health)
