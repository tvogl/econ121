# uncomment if these packages are not installed
# install.packages(c('tidyverse','haven'))

# save output
rmarkdown::render(
  input = "nlsy_diffs.R",
  output_format = "pdf_document",
  output_file = "ssa_names_trends_log"
)

# analyzes naming trends in the social security names database (national).
# takes special interest in frequency of muslim names before and after 9/11/2001.

# input Stata file (need haven library for importing Stata file)
library(haven)
ssa <- read_dta("https://github.com/tvogl/econ121/raw/main/data/ssa_names.dta")

# summarize
summary(ssa)

# data structure (need tidyverse library for the glimpse function)
library(tidyverse)
glimpse(ssa)

# create post 1990 data frame, since we are interested in 9/11
# also keep only boy names, and only Osama, Mohammed, and Ahmed
data <- ssa[which(ssa$year>=1990 & ssa$sex=="M" & ssa$name %in% c("Osama", "Mohammed", "Ahmed")), ]

# summarize and glimpse new data frame
summary(data)
glimpse(data)

# graph counts of the three names, with a vertical line at 2001
# we will use the ggplot2 library, which is already loaded in the tideverse
ggplot(data, aes(x=year, y=freq, group=name, color=name)) +
  geom_line() +
  geom_vline(xintercept=2001)

# large levels differences --> counts awkward to compare
# let's take logs, so we can study proportional changes	  
data$lnfreq = log(data$freq)
ggplot(data, aes(x=year, y=lnfreq, group=name, color=name)) +
  geom_line() +
  geom_vline(xintercept=2001)
  


