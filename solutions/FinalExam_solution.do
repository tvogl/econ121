/*

ECON 121: Applied Econometrics

Final Exam Solution

*/

clear all // this closes data currently open
use "https://github.com/tvogl/econ121/raw/main/data/nfhs5.dta" // this opens desired dataset 

*Part A
*A1 
reg child_u1death child_bord,cluster(psu_id)
bootstrap,reps(99) cluster(psu_id): reg child_u1death child_bord
*A linear probability model is estimated by OLS (the reg command).
*We cluster at the PSU level because of the clustered sampling design.

*A2
*An increase of birth order by 1 is associated with a .2 percentage point
*increase in the probability of dying before age 1. The p-value is 0.000, so
*the coefficient is significantly different from 0.

*A3  
*The odds ratio would be greater than 1 because the linear probability model
*indicates that higher birth orders are associated with higher mortality risk.
*That means the logit coefficient is likely to be positive. The odds ratio is the
*exponentiated logit coefficient, and the exponential of a positive number is
*greater than 1.

*A4  
xtreg child_u1death child_bord,fe i(mom_id) cluster(psu_id)
*You could have also used areg instead of xtreg. Most analyses would 
*continue to cluster at the PSU level, but you did not lose points
*if you did not throughout the problem set.

*A5  
*An increase of birth order by 1 is associated with a 1.8 percentage point
*decrease in the probability of dying before age 1. The coefficient from A4
*is negative, whereas the coefficient from A1 is positive. Since birth order 
*is positively associated with the number of children, the formulas for omitted
*variable bias imply that the number of children must be positively associated
*with mortality risk.

*A6  
xtreg child_u1death child_bord child_birthyr,fe i(mom_id) cluster(psu_id)
*You could have alternatively included birth year dummies (i.child_birthyr),
*which would have led to similar results.

*A7 
*Now the coefficient implies that an increase of birth order by 1 is 
*associated with a 2.9 percentage point deccrease in the probability 
*of dying before age 1. Now that we have purged the estimate of family
*size and birth year variation, it is reasonable to interpret it as a 
*causal effect of birth order. It captures how being later born in the
*family affects mortality risk, net of birth year. It is also possible
*to argue the opposite, so we graded based on the explanation only.
                                                   
*A8
gen maleXbord = child_male*child_bord //interaction between gender & birth order
gen maleXbirthyr = child_male*child_birthyr //interaction between gender & birth year
xtreg child_u1death child_bord maleXbord child_birthyr maleXbirthyr child_male,fe i(mom_id) cluster(psu_id)
*It was important to include the main effect of child_male as well as its
*interaction with child_bord. To be careful, we should also include the
*interaction with child_birthyr, so that we can distinguish between
*gender differences in birth order effects and birth year effects.

*A further possibility is to interact the mother fixed effects with the gender 
*of the child, so that we only compare siblings of the same gender. This goes
*beyond what we discussed in class, but I wanted to include if in case you
*are interested.
gen mom_gender_id = 2*mom_id+child_male //unique number for each mom-gender combination
xtreg child_u1death child_bord maleXbord child_birthyr maleXbirthyr,fe i(mom_gender_id) cluster(psu_id)
*Here we see that the benefits of being later born are much stronger for boys
*than for girls. The difference between this regression and the last comes from
*mortality risk being more associated with family size for boys than for girls.
*Note that we cannot include child_male in the regression because it is collinear
*with the fixed effects.

*A9
reg child_u1death mom_rural mom_edyrs mom_age,cluster(psu_id)
lincom (mom_rural+5*mom_edyrs+15*mom_age)-(12*mom_edyrs+40*mom_age)
nlcom (_b[_cons]+_b[mom_rural]+5*_b[mom_edyrs]+15*_b[mom_age]) / ///
      (_b[_cons]+12*_b[mom_edyrs]+40*_b[mom_age])
	  
*A10
*The answer in absolute terms comes from the lincom command, which
*indicates that infant mortality risk is 2.3 percentage points higher
*for the 15-year-old rural mom with 5 years than for the 40-year-old
*urban mom with 12 years. The 95% confidence interval excludes 0, so
*this difference is statistically significant at conventional levels.

*The answer in proportional terms comes from the nlcom command, which
*indicates that infant mortality risk for the 15-year-old rural mom 
*with 5 years is 1.93 times the infant mortality risk for the 40-year-old
*urban mom with 12 years. The 95% confidence interval excludes 1, so 
*this ratio is statistically significant at conventional levels.	  
                                              
*Part B
*B1
drop if child_bord>1
reg mom_working mom_kids,cluster(psu_id)

*B2
*Poor moms may need to work for survival, and they tend to have more children.

*B3
*This instrument is unlikely to satisfy the exclusion restriction. For instance,
*gender-biased mothers might be more likely to stay home to case for a boy than
*for a girl. You could have also argued against the independence assumption 
*because of sex-selective abortion.

*B4
reg mom_kids child_male,cluster(psu_id)
reg mom_working child_male,cluster(psu_id)

*B5
*The first regression is the first-stage regression. The second regression is
*the reduced-form regression.

*B6
*The instrumental variables estimator is equal to the reduced form coefficient
*divided by the first-stage coefficient. In this case, -.0039/-.2806 = .0139, 
*implying that each additional child raises the probability of maternal work by
*1.4 percentage points.

*B7
ivregress 2sls mom_working (mom_kids=child_male),cluster(psu_id) first

*B8
*If the IV assumptions were met, the result here captures the average effect
*of an additional child among women whose fertility depended on the gender of
*the first child.

*B9
probit child_male mom_rural mom_edyrs child_birthyr mom_age,cluster(psu_id)
margins,dydx(*)
*The commands dprobit or mfx compute would also be correct.

*B10
*An additional year of maternal education is associated with a .08 percentage
*point decline in the probability of having a first-born boy. The association
*is statistically significant at conventional levels, so it poses a concern for
*the independence assumption, which implies that the instrument should be 
*unrelated to the mother's pre-birth characteristics.

