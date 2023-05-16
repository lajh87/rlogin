library(shiny)
library(rlogin)

ui <- fluidPage(
  loginUI("login"),
  uiOutput("logout")
)

pool <- connect_db("SQLite", setup = TRUE, testuser = TRUE)
onStop(function(){pool::poolClose(pool)})

server <- function(input, output, session) {

  login <- callModule(
    module = loginServer,
    id = "login",
    db = pool
  )

  output$logout <- renderUI({
    if(login$password_verified){
      logoutUI("login")
    }
  })
}

shinyApp(ui, server)
