library(shiny)



shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    
    
    # Load data
    data <- read.csv("/home/ubuntu/NCAAF_market_data.csv", header = TRUE)
    
    
    
    # Identify maximum probability (so switching between estimates keeps same x axis)
    max.x <- max(data[,-1])
    
    
    
    # Data to use
    data$y <- data$ensemble
    if(input$select_box == 1)  data$y <- data$bovada.probability
    if(input$select_box == 2)  data$y <- data$FiveDimes.probability
    if(input$select_box == 3)  data$y <- data$GTbets.probability
    if(input$select_box == 4)  data$y <- data$sportsbook.probability
    if(input$select_box == 5)  data$y <- data$TopBet.probability
    
    
    # Order data
    data <- data[ order(data$y, decreasing=TRUE), ]
    
    # Rank
    data$rank <- 1:length(data$y)
    
    
    # Generate the graphic
    par(cex.axis=.9, cex.lab=.9, mar=c(4,4,2,0))
    plot(x = c(0.005, max.x+.02), 
         y = c(5, nrow(data)-2), 
         type='n', 
         axes=FALSE,
         xlab="probability of winning the 2015 NCAA football championship", 
         ylab="rank")
    box()
    axis(1)
    axis(3)
    axis(2, at=24:0*5+5, labels=0:24*5+1)
    
    points(x=data$y, y=25*5+1-data$rank, pch=20)
    text(x=data$y, y=25*5+1-data$rank, labels=data$Team, pos=4, cex=.8)
    
  })
  
  
  
  # Return the time that each market was updated
  output$urlText <- renderText({
    
    update <- read.csv("/home/ubuntu/NCAAF_update_times.csv", header = TRUE)
    
    HTML(paste('<ul>',
               
               '<li> <a href="http://sports.bovada.lv/sports-betting/football-futures.jsp">Bovada (',
               as.character(update$last.bovada.update.time),
               ' ET)</a> </li>',
               
               '<li> <a href="http://www.oddsshark.com/ncaaf/odds/futures">5Dimes (',
               as.character(update$last.FiveDimes.update.time),
               ' ET)</a> </li> ',
               
               '<li> <a href="http://www.gtbets.eu/betting1.asp?league=CF&specialeventname=2015+BCS+Championship&wagertype=FUTURE&eventtime=">GT Bets (',
               as.character(update$last.GTbets.update.time),
               ' ET)</a> </li> ',
               
               '<li> <a href="https://www.sportsbook.ag/sbk/sportsbook4/www.sportsbook.ag/getodds5.xgi?categoryId=592">Sportsbook (',
               as.character(update$last.sportsbook.update.time),
               ' ET)</a> </li> ',

               '<li> <a href="http://www.oddsshark.com/ncaaf/odds/futures">TopBet (',
               as.character(update$last.FiveDimes.update.time),
               ' ET)</a> </li> ',
               
               '<li> <a href="http://www.scholarpedia.org/article/Ensemble_learning">Ensemble is the average of these sources</a> </li> ',
               '</ul>',
               sep = ''))
  })
  
  
  
  
  
  
})
