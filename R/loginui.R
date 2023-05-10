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
#' @export
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
loginUI <- function(id) {
  ns <- NS(id)
  cookies::add_cookie_handlers(tagList(
    shinyjs::useShinyjs(),
    div(
      id = "login-panel",
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
        checkboxInput(ns("remember"), "Remember Me", TRUE)
      )
    )
  ))
}

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

  values <- reactiveValues()

  # on load get cookie sodium
  observeEvent(cookies::get_cookie("sodium"),
    {
      if (is.null(cookies::get_cookie("sodium"))) {
        return(NULL)
      }

      values$password_verified <- sodium::password_verify(readLines("hash.txt"), cookies::get_cookie("sodium"))
    },
    once = TRUE,
    ignoreInit = FALSE,
    ignoreNULL = FALSE
  )


  observeEvent(input$login, {
    values$password_verified <- sodium::password_verify(readLines("hash.txt"), input$password)

    if (values$password_verified) {
      if (input$remember) {
        cookies::set_cookie(
          cookie_name = "sodium",
          cookie_value = sodium::password_store(input$password)
        )
      }
    }
  })

  observeEvent(values$password_verified, {
    if (values$password_verified) {
      shinyjs::hide(id = "login-panel")
    } else {
      shinyjs::show(id = "login-panel")
    }
  })

  output$content <- renderUI({
    if (req(values$password_verified)) {
      actionButton("logout", "Logout")
    }
  })

  observeEvent(input$logout,
    {
      cookies::remove_cookie("sodium")
      values$password_verified <- FALSE
    },
    ignoreNULL = TRUE,
    ignoreInit = TRUE
  )

  observe(message(values$password_verified))
}
