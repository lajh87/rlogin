#' Shiny Login Module
#'
#' Verify user credentials against authentication database.
#'
#' @import shiny
#' @importFrom rlang .data
#'
#' @param id Namespace id
#' @param db Database connection object
#' @param input Shiny input parameter
#' @param output Shiny output parameter
#' @param session Shiny session parameter
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
          checkboxInput(
            inputId = ns("remember"),
            label = "Remember Me",
            value = TRUE
          )
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
  uiOutput(ns("logout"))

}

#'@describeIn rlogin loginServer
#'@export
loginServer <- function(
    input, output, session, db
    ) {

  ns <- session$ns
  values <- reactiveValues()

  observeEvent(cookies::get_cookie("auth_token"), {
    values$userid <- get_auth_token(db, cookies::get_cookie("auth_token"))
    values$password_verified <- is.numeric(values$userid)
  }, ignoreInit = FALSE, ignoreNULL = FALSE, once = TRUE)

  ## login and verify password
  ## if password verified and remember me box check then set a cookie and
  ##  send to database
  observeEvent(input$login, {

    values$password_verified <- verify_password(
      db,
      input_username = input$username,
      input_password = input$password
    )

    if(values$password_verified){
      if(input$remember){
        username_var <- input$username
        userid <- db |> dplyr::tbl("auth_users") |>
          dplyr::filter(.data$username == username_var) |>
          dplyr::pull(.data$userid)

        set_auth_cookie(db, userid[1])
      }
    } else{
      values$error <- "Invalid Username or Password"
    }

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

  output$logout <- renderUI({
    if (req(values$password_verified)) {
      actionButton(ns("logout"), "Logout")
    }
  })

  observeEvent(input$logout,
    {
     values$password_verified <- FALSE
     values$error <- NULL
     token <- cookies::get_cookie("auth_token")
     if(!is.null(token)){
       remove_token(db,token)
       cookies::remove_cookie("auth_token")
     }
    },
    ignoreNULL = TRUE,
    ignoreInit = TRUE
  )

  return(values)
}
