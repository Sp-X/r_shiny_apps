#Data Import
dataset <- read.csv('global_product_sales.csv')

df <- ts(matrix(dataset$quantity, nrow = 60, ncol = nrow(dataset)),
         start = c(2014, 1), frequency = 12)


#Creating bottom level names for matrix column names
library(dplyr)

ids <- strsplit(dataset$id, split = "-")

for (i in 1:nrow(dataset)) {
    dataset$uid[i] <- paste(ids[[i]][1],
                            ids[[i]][2],
                            formatC(as.integer(ids[[i]][3]),flag=0,width=2),
                            sep = "")
}

colnames(df) <- dataset$uid


#Remove unused dataset from memory
remove(list = c("dataset", "ids", "i"))

###############################################################################
#Model Development
library(hts)
df_hts <- hts(df, characters = c(2, 1, 2))

###############################################################################
#Forecast Reconciliation using middle-out approach
df_fc <- forecast(df_hts, method="mo", level = 2,fmethod="arima", h= 12)

#End of Modelling


#Start of WebApp development

library(shiny)
library(ggplot2)

ui <- fluidPage(
    plotOutput("plot", 
               click = "click",
               dblclick = "dblclick",
               hover = "hover",
               brush = "brush"),
    selectInput("xVar", "Select Hierarchy Level", 
                choices = c(0, 1, 2), selected = 1),
    fluidRow(
        column(3, 
               h4("Click"),
               verbatimTextOutput("clickVals")
        ),
        column(3, 
               h4("Double Click"),
               verbatimTextOutput("dblclickVals")
        ),
        column(3, 
               h4("Hover"),
               verbatimTextOutput("hoverVals")
        ),
        column(3, 
               h4("Brush"),
               verbatimTextOutput("brushVals")
        )
    )
)

server <- function(input, output) {
    output$plot <- renderPlot({
        #Forecasts for each level of aggregation
        fcsts <- aggts(df_fc, levels=0:input$xVar)
        #Forecast Plots
        groups <- aggts(df_hts, levels=0:input$xVar)
        autoplot(fcsts, main= "Middle-Out approach and ARIMA", xlab= "Year", ylab= "Units Sold") + autolayer(groups)
    })
    
    output$clickVals <- renderText({
        paste0("x=", input$click$x, "\ny=", input$click$y)
    })
    
    output$dblclickVals <- renderText({
        paste0("x=", input$dblclick$x, "\ny=", input$dblclick$y)
    })
    
    output$hoverVals <- renderText({
        paste0("x=", input$hover$x, "\ny=", input$hover$y)
    })
    
    output$brushVals <- renderText({
        paste0("xmin=", input$brush$xmin, "\nymin=", input$brush$ymin, "\nxmax=", input$brush$xmax,"\nymax=", input$brush$ymax)
    })
    
}

shinyApp(ui, server)

