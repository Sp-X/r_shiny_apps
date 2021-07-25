# ui.R
library(shiny)

ui <- fluidPage(
    sliderInput('num', "Please Enter an Integer:", 1, 1000, 50),
    plotOutput('hist')
)
