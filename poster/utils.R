# Utility functions and variables to support data processing for visualising Billion-Dollar Disasters

# Define custom mapping of disaster types into their respective subcategories
disaster_mapping <- c(
  "Severe Storm" = "Storms Events",
  "Tropical Cyclone" = "Storm Events",
  "Drought" = "Dry Weather Events",
  "Wildfire" = "Dry Weather Events",
  "Winter Storm" = "Wet Weather Events",
  "Flooding" = "Wet Weather Events",
  "Freeze" = "Wet Weather Events"
)

# Function to add disaster subcategory
add_disaster_category <- function(df) {
  df <- df |> 
    mutate(Category = case_when(
      Disaster %in% names(disaster_mapping) ~ disaster_mapping[Disaster],
      TRUE ~ "Other"
    ))
  return(df)
}

# Function to ensure dataframe provided is error free
verify_data <- function(df) {
  if(nrow(filter(df, Category == "Other")) == 0 && nrow(df[rowSums(is.na(df)) > 0, ]) == 0) {
    message("Dataframe is error free")
  } 
  # Check if there are any rows with Category == "Other"
  else if (!nrow(filter(df, Category == "Other")) == 0) {
    message("Dataframe has missing disaster subcategories")
  } 
  # Check if there are any rows with NA values
  else if (!nrow(df[rowSums(is.na(df)) > 0, ]) == 0) {
    message("Dataframe has missing values")
  } else {
    message("Dataframe has missing values and disaster subcategories")
  }
}
