library(shiny)
library(DT)
setwd("F:/Repo/GitHub/r_shiny_apps/interactive_tables")

shinyApp(
    ui = fluidPage(
        selectInput("table", "Table:",
                    c("Filling Line" = "df1",
                      "Table 2" = "df2",
                      "Table 3" = "df3",
                      "Table 4" = "df4",
                      "Table 5" = "df5")),
        dataTableOutput("data")
    ),
    server = function(input, output) {
        output$data <- DT::renderDataTable({
            read.csv(paste("../", input$table, ".csv", sep = ""))
        })
    }
)