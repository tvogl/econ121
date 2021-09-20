# uncomment if these packages are not installed
# install.packages(c('tidyverse','estimatr'))

###########################################
#ESTIMATING RACIAL DIFFERENCES IN EARNINGS#
#IN THE NAT'L LONGITUDINAL SURVEY OF YOUTH#
###########################################

# input Stata file (need haven library for importing Stata file)
library(haven)
nlsy79 <- read_dta("https://github.com/tvogl/econ121/raw/main/data/nlsy79.dta")

# data structure
library(tidyverse)
glimpse(nlsy79)

# mean and sd of labor earnings (na.rm=TRUE removes missing values from the calculation)
mean(nlsy79$laborinc07,na.rm=TRUE)
sd(nlsy79$laborinc07,na.rm=TRUE)

# more detailed summary with percentiles
# note that there are many zeros, which implies
# that we cannot take logarithms without first
# thinking about sample selection.
summary(nlsy79$laborinc07)

# we can see this better when we plot histograms by race (need ggplot2 library for graphing)
library(ggplot2)
ggplot(nlsy79, aes(x = laborinc07)) +
  geom_histogram(fill = "white", colour = "black") +
  facet_grid(black ~ .)

#we will estimate differences between blacks and non-blacks.

# means by race: this uses the dplyr library and the pipe operator %>%
nlsy79 %>% group_by(black) %>% summarize(mean=mean(laborinc07, na.rm = TRUE),
                                         sd=sd(laborinc07, na.rm = TRUE),
                                         n=sum(!is.na(laborinc07)))

# these results give us all the information we need to test for differences by race.
# difference
44577-30214
# t-statistic
(44577-30214)/sqrt(53998^2/5150 + 34920^2/2278)
# well above 1.96, so statistically significant by the usual standards.

# alternative ways to run this test are...
# t-test with unequal variances:
t.test(laborinc07 ~ black, data = nlsy79)
# regression with robust SEs (need to load estimatr library for lm_robust function)
library(estimatr)
lm_robust(laborinc07 ~ black,data = nlsy79)

# it is actually uncommon to test for average differences in the level 
# (rather than log) of earnings, including zeros from the non-employed. 
# it would be much more typical to restrict to employed individuals. so 
# let's restrict to people who worked at least 1000 hours in 2007:
# equivalent to a part-time job of 20 hours per week for 50 weeks.
summary(nlsy79$hours07)
nlsy79_workers <- subset(nlsy79, hours07>=1000)
summary(nlsy79_workers$hours07)
# means by race
nlsy79_workers %>% group_by(black) %>% summarize(mean=mean(laborinc07, na.rm = TRUE),
                                                 sd=sd(laborinc07, na.rm = TRUE),
                                                 n=sum(!is.na(laborinc07)))
# still an $15k difference, which amounts to a black/non-black ratio of:
55119/40731

# now let's look at log earnings. first remove zeros, then take logs.
nlsy79_workers <- subset(nlsy79_workers, laborinc07>0)
nlsy79_workers$loginc07 <- log(nlsy79_workers$laborinc07)
nlsy79_workers %>% group_by(black) %>% summarize(mean=sprintf("%0.3f",mean(loginc07, na.rm = TRUE)),
                                                 sd=sd(loginc07, na.rm = TRUE),
                                                 n=sum(!is.na(loginc07)))
# difference:
10.639-10.344

# this difference in logs can by roughly interpreted as a 30% difference 
# in earnings, although this interpretation relies on calculus [dln(y)/dx],
# so it is really for continuous X variables rather than binary ones. if we 
# were being really careful, we would exponentiate the difference of logs:
exp(10.639-10.344)
# which implies a 34% difference in geometric means. this proportional 
# difference is very close to the 36% difference in arithmetic means 
# that we saw above.

# the t-statistic:
(10.639-10.344)/sqrt(.823^2/3829 + .925^2/1566)
# well above 1.96, so statistically significant by the usual standards.

# alternative ways to run this test are...
# t-test with unequal variances:
t.test(loginc07 ~ black, data = nlsy79_workers)
# regression with heteroskedasticity-robust standard errors:
lm_robust(loginc07 ~ black,data = nlsy79_workers)
# same results. that is to say, a regression on a "dummy variable"
# for black leads to the same results as a difference of means
# note that the t-statistic is very slightly different from what
# we computed "by hand." that's likely due to rounding errors.
