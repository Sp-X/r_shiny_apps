library(shiny)

ui <- fluidPage(
    sliderInput('num', "Please Enter an Integer:", 1, 1000, 500),
    plotOutput('hist'),
    verbatimTextOutput('summ')
)

server <- function(input, output){
    data <- reactive({ rnorm(input$num) })
    output$hist = renderPlot({
      hist(data())
      })
    output$summ = renderPrint({
      isolate(summary(data()))
        })
}

shinyApp(ui, server)