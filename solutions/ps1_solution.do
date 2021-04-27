//This do file presents solutions to ECON 121 Problem Set 1

/////////////
//Problem 1//
/////////////

//If education and experience are exogenous, then beta1 represents
//the causal effect of education on log wages. The quantitative
//interpretation is that each additional year of education raises
//wages by 100*beta1 percent.

//The squared term in experience allows for wages to vary non-
//linearly with experience. For instance, we might expect wages
//to rise with experience at a decreasing rate. In this case, 
//beta3 would be positive and beta4 would be negative.

/////////////
//Problem 2//
/////////////

//We open the CPS dataset, then describe and summarize the data
use "https://github.com/tvogl/econ121/raw/main/data/cps_18.dta",clear
d
sum

//Drop observations with <50 weeks or <35 hours or missing hours
drop if uhrsworkt<35|wkswork1<50|uhrsworkt>900

//Generate new variables
gen lnw = ln(incwage/(wkswork1*uhrsworkt))

gen black = (race==200)
gen other = (race>200)

recode educ (2=0) (10=2.5) (20=5.5) (30=7.5) (40=9) (50=10) (60=11) (71/73=12) (81/92=14) (111=16) (123=18) (124=18.5) (125=20),gen(edyrs)

gen exper = age - edyrs - 5
gen exper2 = exper^2

gen female = (sex==2)

//Summarize the new variables. The mean log wage is 3.13, or 
//approximately $23/hour. Education averages 14 years, with a 
//standard deviation of 2.7. Experience averages 24 years, with
//a standard deviation of 11. 12 percent of the sample is black.
sum lnw edyrs exper black other female

//Note: I like to focus on the estimation sample, with non-missing
//wage data. But this is not essential for your problem set.
sum lnw edyrs exper black other female if lnw<.

/////////////
//Problem 3//
/////////////

//Estimate the Mincerian regression. The estimated return is
//0.113, or an 11 percent wage increase per year of education.
reg lnw edyrs exper exper2,r

/////////////
//Problem 4//
/////////////

//The extended Mincerian regression yields an estimated 
//return of 0.117, which is similar but slightly larger
//than the original estimate.
reg lnw edyrs exper exper2 female black other,r

/////////////
//Problem 5//
/////////////

//The female-male wage gap is 0.272 log points, while the
//black white gap is -0.167 log points, leading to a 
//difference of 0.106, which is significant at the 0.1% level.
lincom black-female

/////////////
//Problem 6//
/////////////

//If we run separate regressions for men and women, we
//find a return of 0.111 for men and 0.126 for women, 
//implying a difference in returns of 0.0145 log points
//or 1.45 percent.
bysort female: reg lnw edyrs exper exper2 black other,r

//To assess whether the difference is significant, we
//can compute the t-statistic using the coefficients and
//standard errors. That's because the male and female samples
//are independent, so the coefficients have no covariance.
//The t-statistic is 5.84, so the difference in coefficients
//is significant at the 5% level.
di (.1256933-.1111288)/sqrt(.0019217^2+.0015884^2)

/////////////
//Problem 7//
/////////////

//To match the approach in Problem 6, we need to allow
//ALL of the coefficients to vary by gender, so we need
//many interaction terms. The coefficient on the interaction
//term between education and female is 0.0145, with a 
//t-statistic of 5.84, just as in Problem 6!
gen edyrs_f = edyrs*female
gen exper_f = exper*female
gen exper2_f = exper2*female
gen black_f = black*female
gen other_f = other*female
reg lnw edyrs edyrs_f exper exper_f exper2 exper2_f black black_f other other_f female,r

//Using the delta method to estimate the ratio of returns, we
//find a female/male ratio of 1.13. The 95% confidence interval
//starts at 1.085, so we can reject the null hypothesis that 
//the ratio is 1 at the 5% level.
nlcom (_b[edyrs]+_b[edyrs_f])/_b[edyrs]

//Alternatively, we could have used the bootstrap, which
//leads to the same answer.
bootstrap ratio=((_b[edyrs]+_b[edyrs_f])/_b[edyrs]),reps(99): reg lnw edyrs edyrs_f exper exper_f exper2 exper2_f black black_f other other_f female

/////////////
//Problem 8//
/////////////

//Open the NLSY dataset
use nlsy79,clear

//The sample is 25% black and 16% Hispanic, but when we use 
//sampling weights, those shares fall to 14% black and 6% 
//Hispanic. Because the sampling weights undo the NLSY's over-
//sampling, the latter estimates are representatives of US
//adults who were teenagers residing in the United States
//in 1979. The weighted statistics provide unbiased estimates
//of the population racial composition, since they restore
//representativeness in the sample.
sum black hisp
sum black hisp [aw=perweight]

/////////////
//Problem 9//
/////////////

//Keep full time workers only
drop if hours07<35*50

//Generate new variables
gen lnw = ln(laborinc07/hours07)

gen exper = age79 + (2007-1979) - educ - 5
gen exper2 = exper^2

//Estimates of the Mincerian return to education are quite 
//similar using OLS (0.122) and WLS (0.123). Since the 
//unweighted OLS estimates are more precise (consistent 
//with the Guass Markov theorem), I will continue the 
//analysis with unweighted regressions. (I could have
//also said that I prefer to have results that are 
//representative of the coefficient I would obtain in
//the full population, which would have led me to run
//weighted regressions for the rest of the analysis.)
reg lnw educ exper exper2 black hisp male,r
reg lnw educ exper exper2 black hisp male [aw=perweight],r

//////////////
//Problem 10//
//////////////

//The extended Mincerian regression yields an estimated 
//return to education of 12 percent, similar to the CPS.
//However, while the CPS had a significant positive coef-
//ficient on exper and a significant negative coefficient
//on exper2, these coefficients are insignificantly 
//different from zero in the NLSY. This difference is 
//likely due to the fact that all NLSY respondents are 
//middle-aged in 2007, with substantial potential experience.
//The CPS indicated that wages rise with experience at labor
//market entry but then flatten out (due to the negative 
//squared term). Since the NLSY in 2007 only had mature 
//workers, the dataset is not well-suited for estimating
//the returns to experience.

//////////////
//Problem 11//
//////////////

//It seems unlikely that the coefficient on education 
//represents the causal effect of education. Education
//and wages are likely to be correlated with a number of
//omitted variables, such as innate ability and parental
//socioeconomic status.

//////////////
//Problem 12//
//////////////

//To address the concerns above, we can control for 
//childhood background characteristics and cognitive
//test scores. Doing so reduces the estimated return to 
//education substantially, to 7 percent.
reg lnw educ exper exper2 black hisp male ///
    foreign urban14 mag14 news14 lib14 ///
	educ_mom educ_dad numsibs afqt81,r

//However, note that the sample size changed because
//we do not have all control variables for all 
//observations. We should reestimate the "short" model
//to make sure that the change in coefficients is not
//due to sample composition. (This was not essential
//for full credit, but it is good practice.)
reg lnw educ exper exper2 black hisp male if e(sample),r

//Why did the return fall when we included additional
//covariates? It appears that urban residence, paternal
//education and AFQT scores (a measure of innate ability)
//are all positively related with wages, and it is likely
//that they also predict higher education. (You can check this.)

