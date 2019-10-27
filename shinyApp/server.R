library(shiny)

#Read ROC data
load("perf.RData")
thresholds <- data.frame(threshold=perf@alpha.values[[1]], fpr=perf@x.values[[1]], 
                      tpr=perf@y.values[[1]])

# function to find best threshold, tpr and fpr based a specific criteria
get_point <- function(variable, rate) {
  if (variable=="fpr") {
    thresholds2 <- thresholds[order(thresholds$tpr, decreasing=TRUE),]
    thresholds_filter <- thresholds2[thresholds2$fpr <= rate,]
    rownames(thresholds_filter) <- 1:nrow(thresholds_filter)
    best_threshold <- thresholds_filter[1,1]
    if (is.infinite(best_threshold)) {best_threshold <- 1}
    best_tpr <- thresholds_filter[1,3]
    best_fpr <- thresholds_filter[1,2]
    return(c(best_threshold, best_tpr, best_fpr))
  }
  else {
    thresholds2 <- thresholds[order(thresholds$fpr, decreasing=FALSE),]
    thresholds_filter <- thresholds2[thresholds2$tpr >= rate,]
    rownames(thresholds_filter) <- 1:nrow(thresholds_filter)
    best_threshold <- thresholds_filter[1,1]
    if (is.infinite(best_threshold)) {best_threshold <- 1}
    best_tpr <- thresholds_filter[1,3]
    best_fpr <- thresholds_filter[1,2]
    return(c(best_threshold, best_tpr, best_fpr))
  }
}

# Define server logic required to plot
shinyServer(function(input, output) {
  # get best threshold, tpr and fpr
  currentFib <- reactive({ get_point(input$variable, input$rate/100) })

  # Compute the forumla text in a reactive expression
  formulaText <- reactive({
    text_threshold <- paste("Threshold: ", round(currentFib()[1], 4))
    text_tpr <- paste("True Positive Rate: ", round(currentFib()[2]*100,2), "%")
    text_fpr <- paste("False Positive Rate: ", round(currentFib()[3]*100,2), "%")
    return(paste(text_tpr, text_fpr, text_threshold, sep=" | "))
  })
  
  # Return the formula text for printing as a caption
  output$caption <- renderText({
    formulaText()
  })
  
  # Generate a plot
  output$mpgPlot <- renderPlot({
    plot(perf)
    abline(a=0, b= 1)
    points(x=currentFib()[3], y=currentFib()[2], type="p", pch=1, col="red", cex=1)
    title(paste("ROC Curve:"))
  })
})