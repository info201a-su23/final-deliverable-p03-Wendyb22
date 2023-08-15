# Back end
# Load required libraries
library(dplyr)
library(ggplot2)
library(stringr)
library(maps)
library(scales)
library(slider)
library(lubridate)
library(shiny)

# Load data for map
gunshot <- read.csv("https://raw.githubusercontent.com/info201a-su23/exploratory-analysis-p02-sc100922/main/all_incidents.csv")

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

# Load data for chart 3.
gun_violence_us <- read.csv("https://raw.githubusercontent.com/info201a-su23/exploratory-analysis-p02-sc100922/main/all_incidents.csv")
gun_violence_states <- gun_violence_us %>% 
  mutate(n_injured_killed = n_injured + n_killed) %>%
  group_by(., state) %>%
  summarize(n_injured_killed = sum(n_injured_killed))

# Server component
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
  
  # Set the server to present chart 3
  observeEvent(input$compare, {
    output$plot1 <- renderPlot({
      df1 <- gun_violence_states %>% filter(state == input$state1)
      df2 <- gun_violence_states %>% filter(state == input$state2)
      combine_df <- rbind(df1, df2)
      ggplot(combine_df, aes(x = state, y = n_injured_killed)) +
        geom_segment(aes(x = state, xend = state, y = 0,
                         yend = n_injured_killed), color = "black") +
        geom_point(color = "red", size = 1, alpha = 0.6) +
        theme_light() + coord_flip() +
        labs(title =
               "The Number of Injured / Killed in Gun Violence of 51 States of the U.S.
         Dec 31, 2012 - May 27, 2022", y = "Number of Injured / Killed",
             x = "States") +
        theme(plot.title = element_text(hjust = 0.4),
              panel.border = element_blank(),
              axis.ticks.y = element_blank())
    })
  })
  
  observeEvent(input$update, {
    # Code to update the plot when the button is clicked
    output$plot1 <- renderPlot({
      ggplot(gun_violence_states, aes(x = state, y = n_injured_killed)) +
        geom_segment(aes(x = state, xend = state, y = 0,
                         yend = n_injured_killed), color = "black") +
        geom_point(color = "red", size = 1, alpha = 0.6) +
        theme_light() + coord_flip() +
        labs(title =
               "The Number of Injured / Killed in Gun Violence of 51 States of the U.S.
       Dec 31, 2012 - May 27, 2022", y = "Number of Injured / Killed",
             x = "States") +
        theme(plot.title = element_text(hjust = 0.4),
              panel.border = element_blank(),
              axis.ticks.y = element_blank()
        )
    })
  })
  
  # Chart 1
  filtered_data2 <- reactive({
    subset(gunshot, city == input$cityInput)
  })
  
  output$filteredData <- renderDataTable({
    filtered_data2()
  })
  
  #xy graph
  output$gunshotPlot <- renderPlot({
    ggplot(yearly_counts(), aes(x = year, y = count)) +
      geom_point() +
      geom_line() +
      labs(title = paste("Gunshot Incidents in", input$cityInput, "(city)"),
           x = "Year",
           y = "Number of Gunshot Cases")
  })
  
  yearly_counts <- reactive({
    data <- filtered_data2()
    data$year <- year(data$date)
    aggregate(cbind(count = n_killed + n_injured) ~ year, data = data, sum)
  })
}
