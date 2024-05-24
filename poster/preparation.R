## -----------------------------------------------------------------------------
#| label: library
#| message: false

library(tidyverse)
library(knitr)
library(readxl)
library(zoo)


## -----------------------------------------------------------------------------
bdd <- read_csv("time-series-US-cost-1980-2024.csv", skip = 2)
summary(bdd)

