
# rlogin

<!-- badges: start -->
[![Codecov test coverage](https://codecov.io/gh/lajh87/rlogin/branch/master/graph/badge.svg)](https://app.codecov.io/gh/lajh87/rlogin?branch=master)
<!-- badges: end -->

The goal of rlogin is to create authentication process for users to shiny applications.

## Installation

You can install the development version of rlogin like so:

``` r
devtools::install_github("lajh87/rlogin")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
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

```

