#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Load required libraries
library(dplyr)
library(ggplot2)
library(stringr)
library(maps)
library(scales)
library(slider)

# Load data
gunshot <- read.csv("/Users/wendybu/Desktop/info201/groupproject/exploratory-analysis-p02-sc100922/all_incidents.csv")

# Add a 'year' column based on the date variable in your dataset
gunshot$year <- lubridate::year(as.Date(gunshot$date))

# Get the state borders data for the US
us_states <- map_data("state")

# Get the total number of incidents per state and year
total_per_state_year <- gunshot %>% 
  group_by(state, year) %>%
  summarise(total_incidents = n())

# Changes the abbreviations to state names
state_mapping <- setNames(state.name, state.abb)

# Adds the full state name from abbreviation
total_per_state_year$full_state_name <- state_mapping[total_per_state_year$state]
state_shape <- map_data("state")

# Capitalize the first letter of each word in the region column
state_shape$region <- str_to_title(state_shape$region)
state_shape <- state_shape %>%
  select(-subregion)

# Combines the two data sets
total_per_state_year <- total_per_state_year %>% 
  mutate(full_state_name = tolower(full_state_name))
total_incidents_shape <- left_join(total_per_state_year, state_shape, by = c("state" = "region"))

# UI for year selection
ui_map <- fluidPage(
  titlePanel("Gun Violence Incidents by State"),
  sliderInput("yearSelector", "Select Year:", min = 2013, max = 2022, value = 2022),
  plotOutput("mapPlot"),
  
  fluidRow(
    column(12, align = "center", 
           tags$p("This map displays the total gun violence incident cases by state from 2013 to End of May 2022. The color intensity of each state corresponds to the total number of incidents, with darker red shades indicating higher incident counts. Use the slider to select a specific year and observe the variation in gun violence incidents across different states.", 
                  style = "font-size: 16px; color: #666; margin-top: 20px;"))
  )
)


# Server for rendering the map
server_map <- function(input, output) {
  filtered_data <- reactive({
    total_incidents_shape %>%
      filter(year == input$yearSelector)
  })
  
  output$mapPlot <- renderPlot({
    total_incidents_map <- ggplot(data = filtered_data()) +
      geom_polygon(mapping = aes(x = long,
                                 y = lat,
                                 group = group,
                                 fill = total_incidents)) +
      geom_polygon(data = us_states, mapping = aes(x = long, y = lat, group = group), color = "black", fill = NA) +
      scale_fill_continuous(
        trans = "sqrt", # Apply square root transformation for better color distribution
        low = "green",
        high = "red",
        limits = c(0, 6000),  # Adjust the limits to better fit your data range
        breaks = seq(0, 6000, by = 1000),  # Specify breaks for color scale
        labels = scales::comma_format(scale = 1e-3, accuracy = 0.1, suffix = "k")
      ) +
      labs(title = paste("Total Gun Violence Incident Cases by State", input$yearSelector),
           fill = "Total Per State") +
      coord_fixed(1.3)
    
    print(total_incidents_map)
  })
}

# Run the application 
shinyApp(ui_map, server_map)

