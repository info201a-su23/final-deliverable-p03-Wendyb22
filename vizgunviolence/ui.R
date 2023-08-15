# Front end
# Load required libraries
library(shiny)

gunshot <- read.csv("https://raw.githubusercontent.com/info201a-su23/exploratory-analysis-p02-sc100922/main/all_incidents.csv")

# UI component.
ui <- fluidPage(
  # Application title
  titlePanel("Gun Violence Incidents Analysis"),
  
  # Tabs
  tabsetPanel(
    # Introduction
    tabPanel("Introduction",
             h1("Introduction"),
             p("Welcome to our in-depth analysis project on gun violence in the 
               United States. Gun violence has always been an urgent issue for 
               the U.S. As incidents of gun misuse and gun violence continue to 
               rise, the entire nation is seeking answers. We are no exception. 
               Our study revolves around the changes and differences in gun 
               violence incidents over different periods and regions, as well as
               the broad implications for public safety. Central to our 
               exploration are three key questions:"),
             p("1. How has the number of gun violence incidents changed over 
               time in different states and cities?"),
             p("2. Does gun violence differ by state?"),
             p("3. Does gun violence data analysis for each US state indicate a 
               significant public safety threat?"),
             p("To address these questions, we utilize a detailed dataset from 
               Kaggle (\"https://www.kaggle.com/datasets/emmanuelfwerr/gun-violence-incidents-in-the-usa\")
               to track gun violence incidents from 2013 to 2022, including 
               details such as the date, location, and number of casualties. 
               By revealing the geographic and temporal dynamics of gun violence
               , we aim to understand potential factors to build safer 
               communities."),
             p("However, navigating and analyzing this dataset poses significant
               challenges. Given that we're dealing with real tragedies, 
               we have a responsibility to protect the privacy of victims 
               and involved parties. Moreover, our investigation needs to 
               respect the facts and be mindful of potential biases that might 
               arise during the data collection process, as well as ethical 
               considerations."),
             img(src = "image.jpg",
                 height = "400px", width = "700px",
                 style = "position:absolute; left:100px; margin-top:50px"),
    ),
    
    
    # Chart 1
    tabPanel("Gunshoot Trending Analysis",
             p("Gunshoot is a big deal because it affects everyone, everywhere. 
    Its far-reaching consequences impact not only individual well-being, but also 
    economies and societies. Here we create a interactive graph which can show you the gun
    shoot cases in different period of your interests."),
             
             p("We created the table below to see the shooting case in different states. Knowing more about
   our community and the place we living is important for our safety. Users can select
    a specific city that they are interested in, and the page will return the number of gunshot cases
    in that given location at throughout different time period as the output"),
             
             sidebarLayout(
               sidebarPanel(
                 selectInput("cityInput", 
                             label = "Select city that you are interested in:", 
                             choices = unique(gunshot$city)),
               ),
               mainPanel(
                 plotOutput("gunshotPlot"),
                 #dataTableOutput("filteredData2")
               )
             )
    ),
    
    # Map Chart
    tabPanel("Geographical Distribution",
             titlePanel("Gun Violence Incidents by State"),
             sliderInput("yearSelector", "Select Year:", min = 2013, max = 2022, 
                         value = 2022),
             plotOutput("mapPlot"),
             fluidRow(column(12, 
                             align = "center",
                             tags$p("This map displays the total gun violence 
                             incident cases by state from 2013 to End of May 
                             2022. The 
                             color intensity of each state corresponds to the 
                             total number of incidents, with darker red shades 
                             indicating higher incident counts. Use the slider 
                             to select a specific year and observe the variation
                             in gun violence incidents across different 
                             states.",
                                    style = 
                                      "font-size: 16px; color: #666; margin-top: 20px;"
                             )
             )
             )
    ),
    
    # Chart 3
    tabPanel("Victims of States Statistics", 
             titlePanel("Victims in Gun Violence of 51 States of the U.S."),
             sidebarLayout(
               sidebarPanel(
                 h4("Overview or Compare:"),
                 selectInput('state1', 'State 1', c(Choose='', state.name), 
                             selectize=FALSE),
                 selectInput('state2', 'State 2', c(Choose='', state.name), 
                             selectize=FALSE),
                 actionButton("update", "Overview"),
                 actionButton("compare", "Compare")
               ),
               mainPanel(
                 plotOutput('plot1')
               )
             ),
             fluidRow(column(12, 
                             align = "center",
                             tags$p("This chart has two functions: firstly 
                             displays the overview gun violence incident cases 
                             of 51 states of the U.S in lollipop chart from 2013
                             to 2022. Secondly, it offer two selective widgets 
                             of 51 states and a confirm button to compare the 
                             number of victims of two different states to learn
                             about the data in a different aspect which is more 
                             detailed.",
                                    style = "font-size: 16px; color: #666; margin-top: 
                                      20px;"
                             )
             )
             )
    )
  )
)




