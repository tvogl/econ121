//This do file presents solutions to ECON 121 Problem Set 4.

/////////////
//Problem 1//
/////////////

//Summary statistics appear below. The average conscription rate is 50
//percent, and the average crime rate is 7 percent.
use "https://github.com/tvogl/econ121/raw/main/data/crime_ps4.dta",clear
d
sum

//There are large variations in conscription rates by birth year, and
//somewhat smaller variations in crime rates by birth year.
tab birthyr,sum(conscripted)
tab birthyr,sum(crimerate)

//To shed light on whether these birth year differences are statistically
//significant (this was not necessary for full credit), we can run 
//regressions as follows:
reg conscripted i.birthyr,robust
reg crimerate i.birthyr,robust
//The "Prob > F" output tells us the p-value from the joint F test on all
//estimated coefficients. For both regressions, this p-value is less than 
//0.05, indicating that the birth year variations in both variables are
//statistically significant.


/////////////
//Problem 2//
/////////////

//OLS regressions of various crime rates on conscription rates.  
//Crime rates are higher in cells with higher conscription rates.
reg crimerate conscripted i.birthyr indigenous naturalized,robust

//This association would reflect a causal effect only if the lottery
//completely determined conscription -- i.e., there was perfect compliance.
//But we know from the description that some individuals were exempted from
//military service, even if the lottery made them eligible. If people
//exempted from military service have different crime propensities than
//non-exempt people, then the OLS estimate is biased. For instance,
//clerics and individuals with dependents may be less prone to crime than
//non-exempt individuals, which would bias us toward finding a larger 
//(more positive) association between conscription and crime.

//Alternatively, it may be that patriotic individuals are more likely to
//sign up even if they are not eligible for the lottery, and are less likely
//to find ways to become exempt. In this case, conscription would be
//positively correlated with patriotism. If patriotic individuals are 
//also less likely to commit crimes, then these patterns would bias us 
//toward finding a smaller (more negative) association betetween conscription
//and crime.

/////////////
//Problem 3//
/////////////

gen eligible = (draftnumber>=175) if birthyr==1958
replace eligible = (draftnumber>=320) if birthyr==1959
replace eligible = (draftnumber>=341) if birthyr==1960
replace eligible = (draftnumber>=350) if birthyr==1961
replace eligible = (draftnumber>=320) if birthyr==1962

/////////////
//Problem 4//
/////////////

//To estimate the first-stage effect of eligibility on conscription, we
//regress conscription rates on eligibility, controlling for birth year 
//dummies. The birth year dummies are required because the eligibility
//rule depended on birth year -- elibility is randomly assigned within
//each birth year, but it varies systematically across birth years.
//Ethnic composition covariates are not necessary because the assignment
//of eligibility is unrelated to ethnicity.
reg conscripted eligible i.birthyr,robust

//The results indicate that eligibility has a large, positive, and 
//significant effect on conscription. Eligibility raises conscription 
//rates by 66 percentage points, with a t-statistic of 572!

/////////////
//Problem 5//
/////////////

//Like the first stage, the reduced form regression must control for
//birth year dummies. This result reflects a causal effect, since 
//eligibility is randomly assigned conditional on year of birth. However,
//it reflects the average effect of *eligibility*, not *conscription*.
reg crimerate eligible i.birthyr,robust

//We find that eligibility raises overall crime rates (by 0.2 %-points).

/////////////
//Problem 6//
/////////////

//We can compute the instrumental variables estimator by dividing the
//reduced form coefficient by the first stage coefficient.
reg crimerate eligible i.birthyr,robust
di .0017595/0.6587458
  
/////////////
//Problem 7//
/////////////

//We get exactly the same point estimates by running 2SLS.
ivregress 2sls crimerate (conscripted = eligible) i.birthyr,robust
  
//We find that conscription raises the overall crime rate by .27 percentage points,
//This magnitude is remarkably similar to the OLS result in Question 2. This 
//similarity suggests that perhaps after all, the OLS results were not biased.

/////////////
//Problem 8//
/////////////

//(1) The instrument is clearly relevant, with a first-stage t-statistic of over 500.

//(2) It also likely satisfies the independence assumption, since the lottery effectively
//    randomizes eligibility.

//(3) Whether it satisfies the exclusion restriction is a little less clear. 
//    It seems likely that eligibility only affects crime through its effect
//    on conscription, but alternative pathways are possible. For instance, 
//    suppose eligible people who were opposed to military service evaded 
//    conscription by hiding from the authorities, which exposed them to more crime. 

//(4) The monotonicity condition is likely to be satisfied. It is very difficult
//    to fathom why a person who would volunteer for the military without being
//    drafted would refuse to serve if drafted.

//Note: Instead of 2-4, you could have also discussed the instrument exogeneity
//      assumption from the constant treatment effects setup.

/////////////
//Problem 9//
/////////////

//As noted above, the 2SLS result for crimerate suggests that conscription
//raises the probability of having a criminal record by 0.27 percentage points.
//Viewed through the lens of heterogeneous treatment effects, this estimate
//reflects the average treatment effect among people who were induced
//to serve by the draft lottery. It does not reflect the effects of
//conscription among people who would have volunteered anyway (always takers),
//nor the effects of conscription among exempted people (never takers).

//If always takers exist in this context, then we should call the estimand
//a LATE, not a TOT. Recall the first stage regression:
reg conscripted eligible i.birthyr,robust

//Because the constant term is positive, we can conclude that some non-eligible
//people did sign up for the military. So there are always takers, and we
//should call it a LATE.

//////////////
//Problem 10//
//////////////

//Part A
//The scatterplot represents the effect of crossing the cutoff on conscription.
//It shows an opportunity to use the cutoff rule in a fuzzy RD design. It is
//"fuzzy" because conscription rates are positive below the cutoff and less than
//1 above the cutoff, so the change in treatment probability is smaller than 1.
scatter conscripted draftnumber,by(birthyr)

//SOME ADDITIONAL COMMENTS
//If we are concerned that draft numbers are generally correlated with 
//other characteristics, we may be able to use the discontinuous treatment
//rule to improve our strategy to estimate the causal effect of conscription.
//Specifically, if we can assume that crime rates would not change 
//discontinuously at the cutoff in the absence of conscription, then we
//can interpret a discontinuity in crime rates as being the consequence of
//conscription. The same holds if we can assume that for individuals close
//to the cutoff, the side of the cutoff random.

//In that case, we can define a new variable that measures distance to 
//the cutoff, and then estimate a two-stage least squares regression in which
//the outcome is crime, the endogenous covariate is the conscription rate,
//the instrument is eligibility (i.e., being to the right of the cutoff),
//and the control variables are a flexible function (polynomial or local
//linear) of the draft number. If we can additionally assume that:
//   (1) crossing the cutoff only affects crime through its effect on conscription
//   (2) crossing the cutoff does not REDUCE conscription for anyone
//then we can interpret the 2SLS estimate as the average effect of conscription
//among individuals at/near the cutoff whose conscription status depends on 
//eligibility. That is to say, the LATE at the cutoff.

//PART B
//generate distance to cutoff
gen distance = draftnumber-175 if birthyr==1958
replace distance = draftnumber-320 if birthyr==1959
replace distance = draftnumber-341 if birthyr==1960
replace distance = draftnumber-350 if birthyr==1961
replace distance = draftnumber-320 if birthyr==1962
//just focus on the window from -100 to +100
keep if distance<=100 & distance>=-100

//PART C
//draw the first-stage scatterplot pooling all birth years
scatter conscripted distance
//the discontinuity is clear. crossing the threshold has an effect on conscription.

//PART D
//draw the reduced-form scatterplot pooling all birth years
scatter crimerate distance
//here, any discontinuity is very hard to see here. crossing the threshold does not seem to have an effect on conscription.

//PART E
//but let's try estimating the 2sls regression anyway.
//we will use local linear regression with a bandwidth of 100.
//we need one additional covariate, the interaction of distance and eligible.
gen distanceXelig = distance*eligible
//now estimate the regression, and show the first-stage estimates. first without birth year dummies.
ivregress 2sls crimerate (conscripted=eligible) distance distanceXelig,r first 
//we can see from the first stage that crossing the cutoff raises conscription by almost 60 percentage points. but there is no significant discontinuity in crime rates. these findings confirm the patterns in the scatter plots.

//PART F
//why this disappointing result? a big problem is that by focusing right around the cutoff,
//we have increased the variance (std. errors) of our estimator a lot. the 2sls result
//in problem 7 had an SE of .0008. here we have a standard error of .008, 10 times larger!
//so even though our point estimate is larger now (.047 versus .026), it is not significant.


