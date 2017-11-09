library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Find best threshold"),
  
  sidebarPanel(
    selectInput("variable", "Select Criteria:",
                list("True Positive Rate" = "tpr", 
                     "False Positive Rate" = "fpr")),
    numericInput("rate", "Value (%)", 100, min = 0, max = 100, step = NA, width = NULL)
  ),
  
  mainPanel(
    h3(textOutput("caption")),
    plotOutput("mpgPlot")    
  )
))