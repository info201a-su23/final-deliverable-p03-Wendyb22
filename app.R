# Main
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
library(shiny)

source("ui.R")
source("server.R")

# Run the application
shinyApp(ui, server)