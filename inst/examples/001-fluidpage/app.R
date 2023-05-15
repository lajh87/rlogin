library(shiny)
library(rlogin)

ui <- bootstrapPage(
  loginUI("login"),
  uiOutput("content")
)

server <- function(input, output, session) {

  login <- callModule(
    module = loginServer,
    id = "login"
    )

  output$content <- renderUI({

    l <- reactiveValuesToList(login)
    if(length(l)==0) return(NULL)
    if(l$password_verified==FALSE) return(NULL)

    tagList(
      selectInput(inputId = "n_breaks",
                  label = "Number of bins in histogram (approximate):",
                  choices = c(10, 20, 35, 50),
                  selected = 20),

      checkboxInput(inputId = "individual_obs",
                    label = strong("Show individual observations"),
                    value = FALSE),

      checkboxInput(inputId = "density",
                    label = strong("Show density estimate"),
                    value = FALSE),

      plotOutput(outputId = "main_plot", height = "300px"),

      # Display this only if the density is shown
      conditionalPanel(condition = "input.density == true",
                       sliderInput(inputId = "bw_adjust",
                                   label = "Bandwidth adjustment:",
                                   min = 0.2, max = 2, value = 1, step = 0.2)
      )
    )
  })

  output$main_plot <- renderPlot({

    hist(faithful$eruptions,
         probability = TRUE,
         breaks = as.numeric(input$n_breaks),
         xlab = "Duration (minutes)",
         main = "Geyser eruption duration")

    if (input$individual_obs) {
      rug(faithful$eruptions)
    }

    if (input$density) {
      dens <- density(faithful$eruptions,
                      adjust = input$bw_adjust)
      lines(dens, col = "blue")
    }

  })


}

shinyApp(ui, server)
