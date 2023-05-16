library(shiny)
library(rlogin)

pool <- connect_mysql()
onStop(function(){pool::poolClose(pool)})

if(!all(c("auth_tokens", "auth_users") %in% DBI::dbListTables(pool))){
  setup_db_schema(pool, interactive = FALSE)
}

if(pool |> dplyr::tbl("auth_users") |> dplyr::collect() |> nrow() == 0){
  create_dummy_user(pool)
}

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
