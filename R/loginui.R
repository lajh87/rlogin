#' Shiny Login Module
#'
#' Verify user credentials against authentication database.
#'
#' @param id Namespace id
#'
#' @return A reactive values data frame with the following fields: \itemize{
#'   \item{verified}{ Boolean, whether or not the user is verified.}
#'   \item{message}{ A character string with any message from server to user.}
#' }
#'
#' @examples
#' \dontrun{
#' library(shiny)
#' library(rlogin)
#'
#' ui <- fluidPage(
#'   loginUI("login")
#' )
#'
#' server <- function(input, output, session) {
#'
#'   callModule(
#'     module = loginServer,
#'     id = "login"
#'   )
#' }
#'
#' shinyApp(ui, server)
#' }
#' @name rlogin
NULL

#'@describeIn rlogin loginUI
#'@export
loginUI <- function(id) {
  ns <- NS(id)
  cookies::add_cookie_handlers(tagList(
    shinyjs::useShinyjs(),
    div(
      id = ns("login-panel"),
      style = "width: 500px; max-width: 100%; margin: 0 auto;",
      div(
        class = "well",
        h4(class = "text-center", "Please login"),
        p(
          class = "text-center",
          tags$small("")
        ),
        textInput(
          inputId = ns("username"),
          label = tagList(icon("user"), "User"),
          placeholder = "Enter Username"
        ),
        passwordInput(
          inputId = ns("password"),
          label = tagList(
            icon("unlock-alt"),
            "Password"
          ),
          placeholder = "Enter password"
        ),
        div(
          class = "text-center",
          actionButton(
            inputId = ns("login"),
            label = "Log in",
            class = "btn-primary"
          )
        ),
        div(
          style = "color: red;",
          uiOutput(ns("error"))
        )
      )
    )
  ))
}

#'@describeIn rlogin logoutUI
#'@export
logoutUI <- function(id){
  ns <- NS(id)
  actionButton(ns("logout"), "Logout")
}

#'@describeIn rlogin loginServer
#'@export
loginServer <- function(
    input, output, session,
    dbname = Sys.getenv("MYSQL_ADDON_DB"),
    host = Sys.getenv("MYSQL_ADDON_HOST"),
    port = Sys.getenv("MYSQL_ADDON_PORT"),
    user = Sys.getenv("MYSQL_ADDON_USER"),
    password = Sys.getenv("MYSQL_ADDON_PASSWORD"),
    token_auth_tbl = "token_auth",
    user_auth_tbl = "user_auth"
    ) {

  ns <- session$ns
  values <- reactiveValues()

  observeEvent(input$login, {

    values$password_verified <- verify_password(
      input_username = input$username,
      input_password = input$password,
      dbname = Sys.getenv("MYSQL_ADDON_DB"),
      host = Sys.getenv("MYSQL_ADDON_HOST"),
      port = Sys.getenv("MYSQL_ADDON_PORT"),
      user = Sys.getenv("MYSQL_ADDON_USER"),
      password = Sys.getenv("MYSQL_ADDON_PASSWORD")
    )

    if(!values$password_verified)
      values$error <- "Invalid Username or Password"
  })

  observeEvent(values$password_verified, {
    if (values$password_verified) {
      shinyjs::hide(id = "login-panel")
    } else {
      shinyjs::show(id = "login-panel")
    }
  })

  output$error <- renderUI({
    values$error
  })

  observeEvent(input$logout,
    {
     values$password_verified <- FALSE
    },
    ignoreNULL = TRUE,
    ignoreInit = TRUE
  )

  return(values)
}
