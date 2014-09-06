library(shiny)

# Define UI for application 
shinyUI(fluidPage(
  
  # Application title
  h1("NCAA Football Championship Probabilities", align="center"),
  
  # Let user choose the plot
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId="select_box", 
                  label = h3("Estimates to Display"), 
                  choices = list("Bovada" = 1, 
                                 "5Dimes" = 2, 
                                 "GT Bets" = 3, 
                                 "Sportsbook" = 4,
                                 "TopBet" = 5,
                                 "Ensemble" = 6), 
                  selected = 6),
      h6("Sources (time last updated):"),
      htmlOutput("urlText")
      ),
    
    mainPanel( 
      plotOutput("distPlot", height=1250) 
    )
  )
)

)
