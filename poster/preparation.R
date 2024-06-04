## -----------------------------------------------------------------------------
#| label: required-packages
#| message: false

library(tidyverse)
library(knitr)


## -----------------------------------------------------------------------------
#| label: fig-bb
#| echo: false
#| fig-cap: "Frequency and Estimated Costs of Billion-Dollar Disasters in the
#| USA from 1980 to 2024, by @dottle_climate_2023."

include_graphics("images/bb_bdd_cropped.png")


## -----------------------------------------------------------------------------
#| label: data-loading
#| message: false

# Load time-series dataset
bdd_time_series <- read_csv("data/time-series-US-cost-1980-2024.csv", skip = 2)
bdd_time_series

# Load events dataset
bdd_base_events <- read_csv("data/events-US-1980-2024.csv", skip = 2)
bdd_base_events

# Load additional events dataset
bdd_additional_events <- read_csv("data/additional-events-US-1980-2024.csv")
bdd_additional_events


## -----------------------------------------------------------------------------
#| label: process-time-series-data

# Remove unwanted columns from the time-series dataset
bdd_time_series_cleaned <- bdd_time_series |>
  select(matches("^[^0-9]*$"), -`State`)
bdd_time_series_cleaned

# Get cost of BDD events by year
bdd_cost <- bdd_time_series_cleaned |>
  select(contains("Cost"), -matches("All"), Year) |>
  rename_with(~ gsub(" Cost$", "", .x), contains("Cost")) |>
  pivot_longer(cols = -Year, names_to = "Disaster", values_to = "Cost")
bdd_cost

# Get cost of BDD events by year, with sum of costs for all disasters
bdd_cost_total <- bdd_time_series_cleaned |>
  select(contains("Cost"), Year) |>
  rename_with(~ gsub(" Cost$", "", .x), contains("Cost")) |>
  pivot_longer(cols = -Year, names_to = "Disaster", values_to = "Cost")
bdd_cost_total

# Get frequency of BDD events by year
bdd_frequency <- bdd_time_series_cleaned |>
  select(contains("Count"), -matches("All"), Year) |>
  rename_with(~ gsub(" Count$", "", .x), contains("Count")) |>
  pivot_longer(cols = -Year, names_to = "Disaster", values_to = "Count")
bdd_frequency

# Get frequency of BDD events by year, with sum of frequencies for all disasters
bdd_frequency_total <- bdd_time_series_cleaned |>
  select(contains("Count"), -matches("All"), Year) |>
  rename_with(~ gsub(" Count$", "", .x), contains("Count")) |>
  pivot_longer(cols = -Year, names_to = "Disaster", values_to = "Count")
bdd_frequency_total


## -----------------------------------------------------------------------------
#| label: process-events-data

# Convert datatype of Begin Date and End Date to dates
bdd_base_events <- bdd_base_events |>
  mutate(`Begin Date` = ymd(`Begin Date`),
    `End Date` = ymd(`End Date`),
    `Begin Date` = format(`Begin Date`, "%d/%m/%Y"),
    `End Date` = format(`End Date`, "%d/%m/%Y"),
    `Begin Date` = dmy(`Begin Date`),
    `End Date` = dmy(`End Date`)
  )

# Convert datatype of Begin Date and End Date to dates
bdd_additional_events <- bdd_additional_events |>
  mutate(`Begin Date` = dmy(`Begin Date`),
    `End Date` = dmy(`End Date`),
    `Begin Date` = as.Date(`Begin Date`, format = "%d/%m/%Y"),
    `End Date` = as.Date(`End Date`, format = "%d/%m/%Y")
  )

# Get subset of additional information to be added to the base events tibble
subset_bdd_additional_events <- bdd_additional_events |>
  select(Name, `Begin Date`, `End Date`, Summary)
subset_bdd_additional_events

# Combine events dataset with additional events dataset
bdd_events <- bdd_base_events |>
  left_join(subset_bdd_additional_events,
    by = c("Name", "Begin Date", "End Date")
  ) |>
  mutate(Year = year(`Begin Date`))

# Export combined dataset into CSV
write_csv(bdd_events, "data/combined_events.csv")

bdd_events

# Get frequency and costs of BDD events by year (same as bdd_events and
# bdd_frequency, but does not include categories with values = 0)
bdd_events_frequency_cost <- bdd_events |>
  group_by(Year, Disaster) |>
  summarise(
    Frequency = n(),
    `CPI-Adjusted Cost` = sum(`CPI-Adjusted Cost`, na.rm = TRUE),
    `Unadjusted Cost` = sum(`Unadjusted Cost`, na.rm = TRUE),
    .groups = "drop"
  )
bdd_events_frequency_cost

