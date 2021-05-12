*This do file analyzes a panel of states over time
*to measure the effect of seat belt laws on motor vehicle
*fatality rates and seat belt usage

pause on

use "https://github.com/tvogl/econ121/raw/main/data/SeatBelts.dta",clear

label var vmt "Vehicle miles traveled (in millions)"
label var fatalityrate 
label var sb_usage "Seat belt usage rate"   
label var speed65 "=1 if 65 mile per hour speed limit"   
label var speed70 "=1 if 70 mile per hour speed limit"
label var drinkage21 "Binary variable for age 21 drinking age"  
label var ba08 "Binary variable for blood alcohol limit = .08%"        
label var income "Per capita income"     
label var age "Average age"         
label var primary "=1 if primary enforcement of seat belt laws"    
label var secondary "=1 if secondary enforcement of seat belt laws"   

gen lnincome = ln(income)

d
sum

*set panel dimensions
xtset fips year
pause


****************************
**VISUALIZE POLICY VARIATION
****************************
encode state,gen(statenum)
twoway (line primary year,lcolor(black)) ///
       (line secondary year,lcolor(red) lpattern(dash)) ///
	   ,by(statenum) ytitle("") xtitle("") legend(order(1 "Primary" 2 "Secondary"))
pause

***********************************
**BASELINE MODEL WITH NO COVARIATES
***********************************
*two-way fixed effects model
reg fatalityrate primary secondary i.fips i.year,robust
reg sb_usage primary secondary i.fips i.year,robust
pause

*same, now with clustering to allow for within state serial correlation
reg fatalityrate primary secondary i.fips i.year,cluster(fips)
reg sb_usage primary secondary i.fips i.year,cluster(fips)
pause

*first difference model
reg D.fatalityrate D.primary D.secondary i.year,robust
reg D.sb_usage D.primary D.secondary i.year,robust
pause

*first difference model with clustering
reg D.fatalityrate D.primary D.secondary i.year,cluster(fips)
reg D.sb_usage D.primary D.secondary i.year,cluster(fips)
pause

**********************************************
**INCLUDE TIME-VARYING, STATE-LEVEL COVARIATES
**********************************************
*fixed effects model with clustering
reg fatalityrate primary secondary speed65 speed70 drinkage21 ba08 lnincome age i.fips i.year,cluster(fips)
reg sb_usage primary secondary speed65 speed70 drinkage21 ba08 lnincome age i.fips i.year,cluster(fips)

*first difference model with clustering
reg D.fatalityrate D.primary D.secondary D.speed65 D.speed70 D.drinkage21 D.ba08 D.lnincome D.age i.year,cluster(fips)
reg D.sb_usage D.primary D.secondary D.speed65 D.speed70 D.drinkage21 D.ba08 D.lnincome D.age i.year,cluster(fips)
pause

*************************************
**ONLY INCLUDE "CLEAN" CONTROL STATES
*************************************

*first difference of primary law, conditional on no law last year
reg D.fatalityrate D.primary i.year if L.primary==0,cluster(fips)
reg D.sb_usage D.primary i.year if L.primary==0,cluster(fips)

*first difference of primary & secondary laws, conditional on no laws last year
reg D.fatalityrate D.primary D.secondary i.year if L.primary==0&L.secondary==0,cluster(fips)
reg D.sb_usage D.primary D.secondary i.year if L.primary==0&L.secondary==0,cluster(fips)
