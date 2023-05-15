library(shiny)

pool <- connect_sqlite()
onStop(function(){pool::poolClose(pool)})
setup_db_schema(pool, interactive = FALSE)
create_dummy_user(pool)

ui <- fluidPage(
  loginUI("login"),
  logoutUI("login")
)

server <- function(input, output, session) {

  login <- callModule(
    module = loginServer,
    id = "login",
    db = pool
  )
}

shinyApp(ui, server)
