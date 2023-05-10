library(shiny)
library(rlogin)

ui <- fluidPage(
  loginUI("login")
)

server <- function(input, output, session) {

  callModule(
    module = loginServer,
    id = "login"
    )
}

shinyApp(ui, server)
