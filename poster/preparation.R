## -----------------------------------------------------------------------------
#| label: required-packages
#| message: false

library(tidyverse)
library(knitr)
source("utils.R") # Custom utility functions and variables


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
bdd_time_series <- select(bdd_time_series, matches("^[^0-9]*$"), -`State`)
bdd_time_series


## -----------------------------------------------------------------------------
#| label: process-time-series-data-cost

# Get cost of BDD events by year
bdd_cost <- bdd_time_series |>
  select(contains("Cost"), -matches("All"), Year) |>
  rename_with(~ gsub(" Cost$", "", .x), contains("Cost")) |>
  pivot_longer(cols = -Year, names_to = "Disaster", values_to = "Cost")

# Add disaster subcategory, arrange and sort the dataset
bdd_cost <-
  add_disaster_category(bdd_cost) |>
  select(Year, Disaster, Category, Cost) |>
  arrange(Year, Category, Disaster)
bdd_cost

# Ensure that there are no missing values or categories
verify_data(bdd_cost)


## -----------------------------------------------------------------------------
#| label: process-time-series-data-cost-interval

# Add 5-year intervals
bdd_cost_summary <- bdd_cost |>
  mutate(Interval = cut(Year, breaks = seq(1980, max(Year) + 5, by = 5),
                        right = FALSE, include.lowest = TRUE))

# Create new labels
new_labels <- gsub("\\[|\\)|\\]", "", levels(bdd_cost_summary$Interval))
new_labels <- gsub(",", "-", new_labels)
new_labels <- gsub("2025", "2024", new_labels)
new_labels <- factor(
  bdd_cost_summary$Interval,
  levels = levels(bdd_cost_summary$Interval),
  ordered = TRUE,
  labels = new_labels
)

# Get cost of disaster categories for every 5-year interval
bdd_cost_summary <- bdd_cost_summary |>
  mutate(Interval = new_labels) |>
  group_by(Interval, Category) |>
  summarize(Cost = sum(Cost, na.rm = TRUE), .groups = "drop")

# Set order of categories
custom_levels <- c("Storm Events", "Dry Weather Events", "Wet Weather Events")
bdd_cost_summary$Category <- factor(bdd_cost_summary$Category,
                                    levels = custom_levels)
bdd_cost_summary

# Ensure that there are no missing values or categories
verify_data(bdd_cost_summary)

# Get aggregated cost of disaster categories for every 5-year interval
bdd_cost_summary_aggregated <- bdd_cost_summary |>
  group_by(Interval) |>
  summarize(Cost = sum(Cost, na.rm = TRUE), .groups = "drop") |>
  mutate(Category = "All Events") |>
  select(Interval, Category, Cost)
bdd_cost_summary_aggregated

# Ensure that there are no missing values or categories
verify_data(bdd_cost_summary_aggregated)

# Combine the aggregated cost with the summary dataset
bdd_cost_combined <- bdd_cost_summary_aggregated |>
  bind_rows(bdd_cost_summary) |>
  arrange(Interval, Category)

# Set order of categories
custom_levels <- c("All Events",
                   "Storm Events",
                   "Dry Weather Events",
                   "Wet Weather Events")
bdd_cost_combined$Category <- factor(bdd_cost_combined$Category,
                                     levels = custom_levels)
bdd_cost_combined

# Ensure that there are no missing values or categories
verify_data(bdd_cost_combined)


## -----------------------------------------------------------------------------
#| label: process-time-series-data-freq

# Get frequency of BDD events by year, and add disaster subcategory
bdd_frequency <- bdd_time_series |>
  select(contains("Count"), -matches("All"), Year) |>
  rename_with(~ gsub(" Count$", "", .x), contains("Count")) |>
  pivot_longer(cols = -Year, names_to = "Disaster", values_to = "Count")

# Add disaster subcategory, arrange and sort the dataset
bdd_frequency <-
  add_disaster_category(bdd_frequency) |>
  select(Year, Disaster, Category, Count) |>
  arrange(Year, Category, Disaster)
bdd_frequency

# Ensure that there are no missing values or categories
verify_data(bdd_frequency)


## -----------------------------------------------------------------------------
#| label: process-time-series-data-frequency-interval

# Add 5-year intervals
bdd_frequency_summary <- bdd_frequency |>
  mutate(Interval = cut(Year, breaks = seq(1980, max(Year) + 5, by = 5),
                        right = FALSE, include.lowest = TRUE))

# Create new labels
new_labels <- gsub("\\[|\\)|\\]", "", levels(bdd_frequency_summary$Interval))
new_labels <- gsub(",", "-", new_labels)
new_labels <- gsub("2025", "2024", new_labels)
new_labels <- factor(
  bdd_frequency_summary$Interval,
  levels = levels(bdd_frequency_summary$Interval),
  ordered = TRUE,
  labels = new_labels
)

# Get cost of disaster categories for every 5-year interval
bdd_frequency_summary <- bdd_frequency_summary |>
  mutate(Interval = new_labels) |>
  group_by(Interval, Category) |>
  summarize(Count = sum(Count, na.rm = TRUE), .groups = "drop")
bdd_frequency_summary

# Ensure that there are no missing values or categories
verify_data(bdd_frequency_summary)

bdd_frequency_total <- bdd_frequency_summary |>
  group_by(Interval) |>
  summarise(TotalCount = sum(Count))
bdd_frequency_total

category_totals <- bdd_frequency_summary |>
  group_by(Category) |>
  summarise(Total = sum(Count)) |>
  arrange(Total)

ordered_categories <- category_totals$Category

bdd_frequency_summary$Category <- factor(
  bdd_frequency_summary$Category,
  levels = ordered_categories
)


## -----------------------------------------------------------------------------
#| label: process-base-events-data

# Convert datatype of Begin Date and End Date to dates
bdd_base_events <- bdd_base_events |>
  mutate(
    `Begin Date` = ymd(`Begin Date`),
    `End Date` = ymd(`End Date`),
    `Begin Date` = format(`Begin Date`, "%d/%m/%Y"),
    `End Date` = format(`End Date`, "%d/%m/%Y"),
    `Begin Date` = dmy(`Begin Date`),
    `End Date` = dmy(`End Date`)
  )

# Add disaster subcategory to the base events
bdd_base_events <- add_disaster_category(bdd_base_events)
bdd_base_events


## -----------------------------------------------------------------------------
#| label: process-additional-events-data

# Convert datatype of Begin Date and End Date to dates
bdd_additional_events <- bdd_additional_events |>
  mutate(
    `Begin Date` = dmy(`Begin Date`),
    `End Date` = dmy(`End Date`),
    `Begin Date` = as.Date(`Begin Date`, format = "%d/%m/%Y"),
    `End Date` = as.Date(`End Date`, format = "%d/%m/%Y")
  )

# Add disaster subcategory to the additional events, and select relevant columns
bdd_additional_events <-
  add_disaster_category(bdd_additional_events) |>
  select(Name, `Begin Date`, `End Date`, Category, Summary)
bdd_additional_events


## -----------------------------------------------------------------------------
#| label: process-events-data

# Combine both events and additional events datasets
bdd_events <- bdd_base_events |>
  left_join(
    bdd_additional_events,
    by = c("Name", "Begin Date", "End Date", "Category")
  ) |>
  mutate(Year = year(`Begin Date`)) |>
  select(
    `Name`, `Disaster`, `Category`, `Deaths`,
    `Year`, `Begin Date`, `End Date`, `CPI-Adjusted Cost`,
    `Unadjusted Cost`, `Summary`
  ) |>
  arrange(`Year`, `Begin Date`, `End Date`)
bdd_events

# Ensure that there are no missing values or categories
verify_data(bdd_events)

# Export combined dataset into CSV
write_csv(bdd_events, "data/combined-events.csv")


## -----------------------------------------------------------------------------
#| label: process-combined-events-data

# Get frequency and costs of BDD events by year
bdd_events_frequency_cost <- bdd_events |>
  group_by(Year, Disaster) |>
  summarise(
    Count = n(),
    `CPI-Adjusted Cost` = sum(`CPI-Adjusted Cost`, na.rm = TRUE),
    `Unadjusted Cost` = sum(`Unadjusted Cost`, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(Category = case_when(
    Disaster %in% names(disaster_mapping) ~ disaster_mapping[Disaster],
    TRUE ~ "Other"
  )) |>
  select(
    `Year`, `Disaster`, `Category`, `Count`,
    `CPI-Adjusted Cost`, `Unadjusted Cost`
  )
bdd_events_frequency_cost

# Ensure that there are no missing values or categories
verify_data(bdd_events_frequency_cost)

