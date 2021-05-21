*This do file uses data from the National Logitudinal Study
*of Young Men to study the returns to schooling. The key
*idea, following Card (1993), is to instrument for years of
*schooling using the distance to the nearest college as the
*instrument. We now understand that this instrument is 
*probably not valid -- distance to college is correlated 
*with many determinants of earnings, violating the exogeneity
*assumption. Nonetheless, it is a useful example to understand
*the mechanics of instrumental variables.

pause on

use "https://github.com/tvogl/econ121/raw/main/data/card_college.dta",clear
gen age2 = age^2
keep if lwage<.

sum
d
pause

*OLS estimates of the return to schooling
reg lwage edyrs age age2 black smsa,robust
pause

*OLS with some background characteristics
reg lwage edyrs age age2 black smsa daded momed sinmom14 south,robust
pause

*From now on, leave out current SMSA residence, which is endogenous to education
*and therefore a "bad control."

*First stage
reg edyrs nearc2 nearc4 age age2 black daded momed sinmom14 south,robust
reg edyrs nearc2 nearc4a nearc4b age age2 black daded momed sinmom14 south,robust
reg edyrs nearc4 age age2 black daded momed sinmom14 south,robust
pause

*Reduced form
reg lwage nearc4 age age2 black,robust
reg lwage nearc4 age age2 black daded momed sinmom14 south,robust
pause

*Compute IV coefficient as ratio of reduced form to first stage
**no background covariates
reg edyrs nearc4 age age2 black,robust
reg lwage nearc4 age age2 black,robust
di 0.1262711/0.7304538
pause

**background covariates
reg edyrs nearc4 age age2 black daded momed sinmom14 south,robust
reg lwage nearc4 age age2 black daded momed sinmom14 south,robust
di 0.0891009/0.4456637
pause

*2SLS estimates of the return to schooling
**no background covariates
ivregress 2sls lwage (edyrs=nearc4) age age2 black,robust first
pause

**background covariates
ivregress 2sls lwage (edyrs=nearc4) age age2 black daded momed sinmom14 south,robust first
pause

*Is the instrument valid?
*Ideally, would not be correlated with background characteristics.
*It is, which should make us doubt its validity.
reg nearc4 age age2 black daded momed sinmom14 south,robust
dprobit nearc4 age age2 black daded momed sinmom14 south,robust


