## -----------------------------------------------------------------------------
#| label: library
#| message: false

library(tidyverse)
library(knitr)
library(readxl)
library(zoo)


## -----------------------------------------------------------------------------
#| label: fig-bb
#| echo: false
#| fig-cap: "Frequency and Estimated Costs of Billion-Dollar Disasters in the USA from 1980 to 2024, by @dottle_climate_2023."

include_graphics("images/bb_bdd_cropped.png")


## -----------------------------------------------------------------------------
#| label: input-data
#| message: false

bdd <- read_csv("time-series-US-cost-1980-2024.csv", skip = 2)
bdd

