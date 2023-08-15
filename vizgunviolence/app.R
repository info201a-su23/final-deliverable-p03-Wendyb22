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
library(lubridate)
library(shiny)

# Load data
gunshot <- read.csv("/Users/wendybu/Desktop/info201/groupproject/final-deliverable-p03-Wendyb22/vizgunviolence/all_incidents.csv")

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

# UI for the application
ui <- fluidPage(
  # Application title
  titlePanel("Gun Violence Incidents Analysis"),
  
  # Tabs
  tabsetPanel(
    # Introduction tab
    tabPanel("Introduction",
             h1("Introduction"),
             p("Welcome to our in-depth analysis project on gun violence in the United States. Gun violence has always been an urgent issue for the U.S. As incidents of gun misuse and gun violence continue to rise, the entire nation is seeking answers. We are no exception. Our study revolves around the changes and differences in gun violence incidents over different periods and regions, as well as the broad implications for public safety. Central to our exploration are three key questions:"),
             p("1. How has the number of gun violence incidents changed over time in different states and cities?"),
             p("2. Does gun violence differ by state?"),
             p("3. Does gun violence data analysis for each US state indicate a significant public safety threat?"),
             p("To address these questions, we utilize a detailed dataset from Kaggle (\"https://www.kaggle.com/datasets/emmanuelfwerr/gun-violence-incidents-in-the-usa\") to track gun violence incidents from 2013 to 2022, including details such as the date, location, and number of casualties. By revealing the geographic and temporal dynamics of gun violence, we aim to understand potential factors to build safer communities."),
             p("However, navigating and analyzing this dataset poses significant challenges. Given that we're dealing with real tragedies, we have a responsibility to protect the privacy of victims and involved parties. Moreover, our investigation needs to respect the facts and be mindful of potential biases that might arise during the data collection process, as well as ethical considerations."),
             img(src = "/Users/wendybu/Desktop/info201/groupproject/final-deliverable-p03-Wendyb22/vizgunviolence/image.png",
                 height = "350px", width = "600px",
                 style = "position:absolute;left:100px;margin-top:50px"),
    ),
    
    # Map tab
    tabPanel("Geographical Distribution",
             titlePanel("Gun Violence Incidents by State"),
             sliderInput("yearSelector", "Select Year:", min = 2013, max = 2022, value = 2022),
             plotOutput("mapPlot"),
             
             fluidRow(
               column(12, align = "center",
                      tags$p("This map displays the total gun violence incident cases by state from 2013 to End of May 2022. The color intensity of each state corresponds to the total number of incidents, with darker red shades indicating higher incident counts. Use the slider to select a specific year and observe the variation in gun violence incidents across different states.",
                             style = "font-size: 16px; color: #666; margin-top: 20px;"))
             )
    )
  )
)

# Server for the application
server <- function(input, output) {
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
shinyApp(ui, server)
