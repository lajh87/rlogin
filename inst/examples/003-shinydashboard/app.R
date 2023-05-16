library(shiny)
library(shinydashboard)
library(rlogin)

pool <- connect_mysql()
onStop(function(){pool::poolClose(pool)})

ui <- dashboardPage(
  header = dashboardHeader(
    title = "Dashboard",
    disable = TRUE,
    dropdownMenuOutput("logout")
  ),
  dashboardSidebar(
    disable = TRUE,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )
  ),
  dashboardBody(
    shinyjs::useShinyjs(),
    uiOutput("content")
  )
)

server <- function(input, output, session) {

  # Login ----
  login <- callModule(
    module = loginServer,
    id = "login",
    db = pool
  )

  output$content <- renderUI({
    if(!login$password_verified){
      loginUI("login")
    } else{

      tabItems(
        tabItem(tabName = "dashboard",

                fluidRow(
                  box(plotOutput("plot1", height = 250)),

                  box(
                    title = "Controls",
                    sliderInput("slider", "Number of observations:", 1, 100, 50)
                  )
                )
        ),

        # Second tab content
        tabItem(tabName = "widgets",
                h2("Widgets tab content")
        )
      )
    }

  })

  # When password is verified make the header and sidebar visible.
  observeEvent(login$password_verified,{
    if(login$password_verified){
      shinyjs::runjs(
        paste('document.querySelector("body > div > header").setAttribute("style", "display: block");',
              'document.querySelector("body > div > header > nav > a"). setAttribute("style", "display: block");')
      )
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else{
      shinyjs::runjs(
        paste('document.querySelector("body > div > header").setAttribute("style", "display: none");',
              'document.querySelector("body > div > header > nav > a"). setAttribute("style", "display: none");')
      )
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  },ignoreInit = FALSE, ignoreNULL = FALSE)

  # Display a logout message
  output$logout <- renderMenu({
    dropdownMenu(type = "notifications",
                 badgeStatus = NULL,
                 icon = icon("user-circle"),
                 headerText = "You are logged in.",
                 logoutUI("login"))
  })

  # Example Server Code ----
  set.seed(122)
  histdata <- rnorm(500)

  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)
