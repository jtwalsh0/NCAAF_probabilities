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
      h6("Sources:"),
      HTML("<ul>
           <li> <a href='http://sports.bovada.lv/sports-betting/football-futures.jsp'>Bovada</a> </li>
           <li> <a href='http://www.gtbets.eu/betting1.asp?league=CF&specialeventname=2015+BCS+Championship&wagertype=FUTURE&eventtime='>GT Bets</a> </li>
           <li> <a href='http://www.oddsshark.com/ncaaf/odds/futures'>5Dimes and TopBet</a> </li>
           <li> <a href='https://www.sportsbook.ag/sbk/sportsbook4/www.sportsbook.ag/getodds5.xgi?categoryId=592'>Sportsbook</a> </li>
           <li> <a href='http://www.scholarpedia.org/article/Ensemble_learning'>Ensemble</a> is the average of these sources </li>
           </ul>")
      ),
    
    mainPanel( 
      plotOutput("distPlot", height=1250) 
    )
  )
)

)
