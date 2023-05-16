library(shiny)
library(shinydashboard)
library(rlogin)

pool <- connect_mysql()
onStop(function(){pool::poolClose(pool)})

ui <- dashboardPage(
  header = dashboardHeader(title = "Dashboard",
                           disable = TRUE),
  dashboardSidebar(
    disable = TRUE,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )
  ),
  dashboardBody(
    shinyjs::useShinyjs(),
    tabItems(
      tabItem(tabName = "dashboard",
              loginUI("login"),
              uiOutput("content")
      ),

      # Second tab content
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )
  )
)

server <- function(input, output, session) {

  # Login ----
  login <- callModule(
    module = loginServer,
    id = "login",
    db = pool
  )

  observeEvent(login$password_verified,{
    shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    if(login$password_verified){
      shinyjs::runjs(
        paste('document.querySelector("body > div > header").setAttribute("style", "display: true");',
              'document.querySelector("body > div > header > nav > a"). setAttribute("style", "display: true");')
      )
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    }
  },ignoreInit = FALSE, ignoreNULL = FALSE)

  output$content <- renderUI({

    fluidRow(
      box(plotOutput("plot1", height = 250)),

      box(
        title = "Controls",
        sliderInput("slider", "Number of observations:", 1, 100, 50)
      )
    )
  })


  set.seed(122)
  histdata <- rnorm(500)

  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)
