#delimit ;
pause on;
clear all;

use "https://github.com/tvogl/econ121/raw/main/data/elections_example.dta";

*the running variable in this RD analysis is the
*democratic vote margin of victory: the vote share
*of the democrat minus the vote share of the other
*top-two candidate. the democrat wins for all values
*greater than zero;

*the dependent variable is the democratic vote share
*in the next election;

*we also have two predetermined variables: the dem-
*ocratic vote share in the previous election and 
*the democrat's years of political experience;

d;
sum;
pause;

*histogram of the democratic vote margin of victory;
*we make sure that the bars don't overlap zero;
hist difdemshare,start(-1) w(0.025) xline(0);
pause;

*drop uncontested elections;
drop if abs(difdemshare)==1;
pause;

*now generate a binning variable for the figures;
*each bin will be 0.05 wide;
gen bin = floor(difdemshare*20)/20+0.025;
tab bin;
pause;

*now generate local means for each of the bins;
bysort bin: egen demsharenext_mean = mean(demsharenext);
label var demsharenext_mean "Local means";
bysort bin: egen demshareprev_mean = mean(demshareprev);
label var demshareprev_mean "Local means: Previous democratic vote share";
bysort bin: egen demofficeexp_mean = mean(demofficeexp);
label var demofficeexp_mean "Local means: Democrat yrs. political experience";
pause;

*now let's run our main RD, using a global 4th order polynomial
*to approximate the conditional expectation function. we allow
*the shape of the polynomial to be different above and below
*the victory threshold. following david lee, we will cluster
*by district-year;
reg demsharenext right difdemshare difdemshare2 difdemshare3 difdemshare4 
                       rdifdemshare rdifdemshare2 rdifdemshare3 rdifdemshare4,cluster(statedisdec);
*so a democratic victory now causes a 7 point increase in
*the next election's democratic vote share;
*let's generate a predicted value;
predict demsharenext_hat_poly;
label var demsharenext_hat_poly "Polynomial";
pause;

*let's check whether this result is robust to including the 
*predetermined variables as controls;
reg demsharenext right difdemshare difdemshare2 difdemshare3 difdemshare4 
                       rdifdemshare rdifdemshare2 rdifdemshare3 rdifdemshare4
                       demshareprev demofficeexp,cluster(statedisdec);
*doesn't seem to matter much, which is promising;
*let's generate a predicted value, holding
*demshareprev demofficeexp at their means;
sum demshareprev demofficeexp;
gen demshareprev_temp = demshareprev;
gen demofficeexp_temp = demofficeexp;
replace demshareprev = .5260978;
replace demofficeexp = 2.203032;
predict demsharenext_hat_poly_control;
replace demshareprev = demshareprev_temp;
replace demofficeexp = demofficeexp_temp;
label var demsharenext_hat_poly_control "Polynomial w/ controls";
pause;

*the above result suggests that demshareprev demofficeexp 
*don't change discontinuously at zero, but we can also check
*directly;
reg demshareprev right difdemshare difdemshare2 difdemshare3 difdemshare4 
                       rdifdemshare rdifdemshare2 rdifdemshare3 rdifdemshare4,cluster(statedisdec);
reg demofficeexp right difdemshare difdemshare2 difdemshare3 difdemshare4 
                       rdifdemshare rdifdemshare2 rdifdemshare3 rdifdemshare4,cluster(statedisdec);
pause;                       

*the global polynomial might be misleading, let's check for 
*local mean differences and also run a local linear regression;
*we use a bandwidth of 0.1;
reg demsharenext right if abs(difdemshare)<0.1,cluster(statedisdec);
reg demsharenext right difdemshare rdifdemshare if abs(difdemshare)<0.1,cluster(statedisdec);
*let's generate a predicted value;
predict demsharenext_hat_locallinear if abs(difdemshare)<0.1;
label var demsharenext_hat_locallinear "Local linear";
pause;

*let's plot the data and our various predictions;
*add a local linear regression over all the data;
sort difdemshare;
twoway (scatter demsharenext_mean bin,mcolor(black) msymbol(Oh))
       (line demsharenext_hat_poly difdemshare if difdemshare<0,lcolor(blue))
       (line demsharenext_hat_poly_control difdemshare if difdemshare<0,lcolor(red))
       (line demsharenext_hat_locallinear difdemshare if difdemshare<0,lcolor(lime))
       (line demsharenext_hat_poly difdemshare if difdemshare>0,lcolor(blue))
       (line demsharenext_hat_poly_control difdemshare if difdemshare>0,lcolor(red))
       (line demsharenext_hat_locallinear difdemshare if difdemshare>0,lcolor(lime))
       (lpoly demsharenext difdemshare if difdemshare<0,lcolor(purple) bw(.1) degree(1) kernel(tri))
       (lpoly demsharenext difdemshare if difdemshare>0,lcolor(purple) bw(.1) degree(1) kernel(tri)),
       xline(0) legend(order(2 3 4 "Local - OLS" 8 "Local - triangular"));
pause;

*let's also plot the local means for the predetermined variables;
scatter demshareprev_mean bin,mcolor(black) msymbol(Oh) xline(0) name(demshareprev_mean) nodraw;
scatter demofficeexp_mean bin,mcolor(black) msymbol(Oh) xline(0) name(demofficeexp_mean) nodraw;
graph combine demshareprev_mean demofficeexp_mean;
      
       
                
                    

