library(shiny)
library(rjson)
library(RCurl)


shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    
    
    ## USE NCAA LIST OF TEAMS FOR CONSISTENCY
    ## The names in the first column (save for the 'field' teams) comes
    ## from http://www.ncaa.org/championships/statistics/football-schedules
    
    Teams <- matrix(c("Air Force", NA,
                      "Akron", NA,
                      "Alabama", NA,
                      "Arizona", NA,
                      "Arizona St", "Arizona State",
                      "Arkansas", NA,
                      "Arkansas St", "Arkansas State",
                      "Army", NA,
                      "Auburn", NA,
                      "BYU", "Bringham Young",
                      "Ball St", "Ball State",
                      "Baylor", NA,
                      "Boise St", "Boise State",
                      "Boston College", "BC",
                      "Bowling Green", NA,
                      "Buffalo", NA,
                      "California", "UC Berkeley",
                      "Central Mich", "Central Michigan",
                      "Cincinnati", NA,
                      "Clemson", NA,
                      "Colorado", NA,
                      "Colorado St", "Colorado State",
                      "Connecticut", NA,
                      "Duke", NA,
                      "East Carolina", "ECU",
                      "Eastern Mich", "Eastern Michigan",
                      "FIU", "Florida International",
                      "Fla Atlantic", "Florida Atlantic",
                      "Florida", NA,
                      "Florida St", "Florida State",
                      "Florida St", "Florida state",
                      "Fresno St", "Fresno State",
                      "Georgia", NA,
                      "Georgia Tech", NA,
                      "Hawaii", NA,
                      "Houston", NA,
                      "Idaho", NA,
                      "Illinois", NA,
                      "Indiana", NA,
                      "Iowa", NA,
                      "Iowa St", "Iowa State",
                      "Kansas", NA,
                      "Kansas St", "Kansas State",
                      "Kansas St", "Kansas state",
                      "Kent St", "Kent State",
                      "Kentucky", NA,
                      "LSU", "Louisiana State",
                      "La-Lafayette", "Lafayette",
                      "La-Monroe", "Monroe",
                      "Louisiana Tech", "LA Tech",
                      "Louisville", NA,
                      "Marshall", NA,
                      "Maryland", NA,
                      "Massachusetts", NA,
                      "Memphis", NA,
                      "Miami (FL)", "Miami FL",
                      "Miami (FL)", "Miami",
                      "Miami (OH)", "Miami OH",
                      "Michigan", NA,
                      "Michigan St", "Michigan State",
                      "Middle Tenn", "Middle Tennessee",
                      "Minnesota", NA,
                      "Mississippi St", "Mississippi State",
                      "Missouri", NA,
                      "Navy", NA,
                      "Nebraska", NA,
                      "Nevada", NA,
                      "New Mexico", NA,
                      "New Mexico St", "New Mexico State",
                      "North Carolina", NA,
                      "North Carolina St", "North Carolina State",
                      "North Texas", NA,
                      "Northern Ill", "Northern Illinois",
                      "Northwestern", NA,
                      "Notre Dame", "Notre dame",
                      "Ohio", NA,
                      "Ohio St", "Ohio State",
                      "Oklahoma", NA,
                      "Oklahoma St", "Oklahoma State",
                      "Oklahoma St", "Oklahoma state",
                      "Ole Miss", "Mississippi",
                      "Oregon", NA,
                      "Oregon St", "Oregon State",
                      "Oregon St", "Oregon state",
                      "Penn St", "Penn State",
                      "Pittsburgh", NA,
                      "Purdue", NA,
                      "Rice", NA,
                      "Rutgers", NA,
                      "SMU", "Southern Methodist",
                      "San Diego St", "San Diego State",
                      "San Jose St", "San Jose State",
                      "South Ala", NA,
                      "South Carolina", NA,
                      "South Fla", "South Florida",
                      "Southern California", "USC",
                      "Southern California", "Southern Cal",
                      "Southern Miss", "Southern Mississippi",
                      "Stanford", NA,
                      "Syracuse", NA,
                      "TCU", "Texas Christian",
                      "Temple", NA,
                      "Tennessee", NA,
                      "Texas", NA,
                      "Texas A&M", "Texas AM",
                      "Texas St", NA,
                      "Texas Tech", "Texas tech",
                      "Toledo", NA,
                      "Troy", NA,
                      "Tulane", NA,
                      "Tulsa", NA,
                      "UAB", NA,
                      "UCF", "Central Florida",
                      "UCLA", NA,
                      "UNLV", NA,
                      "UTEP", NA,
                      "UTSA", NA,
                      "Utah", NA,
                      "Utah St", "Utah State",
                      "Vanderbilt", NA,
                      "Virginia", NA,
                      "Virginia Tech", NA,
                      "Wake Forest", NA,
                      "Washington", NA,
                      "Washington St", "Washington State",
                      "West Virginia", NA,
                      "Western Ky", "Western Kentucky",
                      "Western Mich", "Western Michigan",
                      "Wisconsin", NA,
                      "Wyoming", NA,
                      "Field (Any Other Team)", "xz Field (Any Other Team)",
                      "Field (Any Other Team)", "Field (Any other team)"),
                    ncol = 2,
                    byrow = TRUE)
    
    
    
    ## SPORTSBOOK AG
    
    # I scraped the numbers from www.sportsbook.ag using KimonoLabs.
    # Here I fetch the data from the Kimono CSV API that I created.
    url <- getURL("https://www.kimonolabs.com/api/csv/dsyjvzgy?apikey=13ff6ad50d64d091e0a23328afd5c04e")
    
    # Load the data
    sportsbook <- read.csv(text=url, skip=1, header=TRUE)
    
    
    # Modify team names for consistency.
    # Use the NCAA's list
    sportsbook$Team <- factor( unlist( apply( X = cbind(Teams[ match(x = sportsbook$Team, table = Teams[,1]), 1],
                                                        Teams[ match(x = sportsbook$Team, table = Teams[,2]), 1]),
                                              MARGIN = 1,
                                              FUN = function(x) x[ !is.na(x) ])) )
    
    # Last Sportsbook update
    last.sportsbook.update.time <- fromJSON(json_str=getURL('https://www.kimonolabs.com/api/dsyjvzgy?apikey=13ff6ad50d64d091e0a23328afd5c04e'))$lastsuccess
    output$sportsbook.update <- renderText(expr=paste("Updated", last.sportsbook.update.time))
    
    # Convert moneyline to probability
    sportsbook$naive.probability[ sportsbook$Moneyline.text > 0 ] <- 100 / (100 + sportsbook$Moneyline.text[ sportsbook$Moneyline.text > 0 ])
    sportsbook$naive.probability[ sportsbook$Moneyline.text < 0 ] <- abs(sportsbook$Moneyline.text[ sportsbook$Moneyline.text < 0 ]) / (100 + abs(sportsbook$Moneyline.text[ sportsbook$Moneyline.text < 0 ]))
    
    # The naive probabilities sum to more than 1.  Remove the vig.
    sportsbook$sportsbook.probability <- sportsbook$naive.probability / sum( sportsbook$naive.probability )
    
    # Keep only important variables
    sportsbook <- subset(x=sportsbook, select=c("Team", "sportsbook.probability"))
    
    
    
    
    ## BOVADA
    # I scraped the numbers from www.oddsshark.com/ncaaf/odds/futures using KimonoLabs
    url <- getURL(url = 'https://www.kimonolabs.com/api/csv/6dddbpb8?apikey=13ff6ad50d64d091e0a23328afd5c04e')
    
    # Load the data
    bovada <- read.csv(text = url, skip=1, header=TRUE)
    
    # Modify team names for consistency
    bovada$Team <- factor( unlist( apply( X = cbind(Teams[ match(x = bovada$Team, table = Teams[,1]), 1],
                                                    Teams[ match(x = bovada$Team, table = Teams[,2]), 1]),
                                          MARGIN = 1,
                                          FUN = function(x) x[ !is.na(x) ])) )
    
    # Convert odds to naive probabilities
    bovada$naive.probability <- NA
    for(i in 1:nrow(bovada)){
      temp <- as.numeric( strsplit(x=as.character(bovada$odds[i]), split="/")[[1]] )
      bovada$naive.probability[i] <- temp[2] / (temp[1] + temp[2])
    }
    
    # The naive probabilities sum to more than 1.  Remove the vig.
    bovada$bovada.probability <- bovada$naive.probability / sum( bovada$naive.probability )
    
    # Keep only important variables
    bovada <- subset(x=bovada, select=c("Team", "bovada.probability"))
    
    
    
    
    
    
    ## GT Bets
    # I scraped the numbers
    url <- getURL(url = 'https://www.kimonolabs.com/api/csv/a6397kqo?apikey=13ff6ad50d64d091e0a23328afd5c04e')
    
    # Load the data
    GTbets <- read.csv(text = url, skip=1, header=TRUE)
    
    # Split the data column
    GTbets <- data.frame(do.call(what = rbind, 
                                 args = strsplit(x = as.character(GTbets$Data), split = "\\(")) )
    
    # Extract team names
    names(GTbets) <- c("Team", "odds")
    GTbets$Team <- gsub("^\\s+|\\s+$", "", GTbets$Team)
    
    # Modify team names for consistency
    GTbets$Team <- factor( unlist( apply( X = cbind(Teams[ match(x = GTbets$Team, table = Teams[,1]), 1],
                                                    Teams[ match(x = GTbets$Team, table = Teams[,2]), 1]),
                                          MARGIN = 1,
                                          FUN = function(x) x[ !is.na(x) ])) )
    
    # Extract the numbers needed to calculate the probabilities
    GTbets$odds <- as.character(GTbets$odds)
    GTbets$odds1 <- do.call(what = rbind,
                            args = strsplit(x = GTbets$odds, split = " to "))[,1]
    GTbets$odds2 <- do.call(what = rbind,
                            args = strsplit(x = GTbets$odds, split = " to "))[,2]
    GTbets$odds2 <- gsub(pattern = "\\)", replacement = "", x= GTbets$odds2)
    
    # Calculate naive probability (includes the vig)
    GTbets$naive.probability <- as.numeric(GTbets$odds2) / (as.numeric(GTbets$odds1) + as.numeric(GTbets$odds2))
    
    # Remove the vig
    GTbets$GTbets.probability <- GTbets$naive.probability / sum(GTbets$naive.probability)
    
    # Keep only useful variables
    GTbets <- subset(x = GTbets, select = c("Team", "GTbets.probability"))
    
    
    
    
    
    
    ## Odds Shark
    # I scraped the numbers
    url <- getURL(url = 'https://www.kimonolabs.com/api/csv/efkrwgr4?apikey=13ff6ad50d64d091e0a23328afd5c04e')
    
    # Load the data
    odds.shark <- read.csv(text = url, skip=1, header=TRUE)
    
    # Modify team names for consistency
    odds.shark$Team <- factor( apply(X = cbind(as.character( Teams[ match(x = odds.shark$Team, table = Teams[,1]), 1]),
                                               as.character( Teams[ match(x = odds.shark$Team, table = Teams[,2]), 1]) ),
                                     MARGIN = 1,
                                     FUN = function(x) x[ !is.na(x) ]))
    
    # Because Odds Shark lists odds from several sites, some sites have teams that other sites
    # do not.  Calculating the naive probabilities gets a little ugly if I write code to 
    # ignore NAs, so it's easier to set those values to zero and calculate naive probabilities
    # for values above or below zero only.
    odds.shark[ is.na(odds.shark) ] <- 0
    
    # Calculate naive probabilities (includes the vig)
    odds.shark$naive.FiveDimes[odds.shark$FiveDimes > 0] <- 100 / (100 + odds.shark$FiveDimes[odds.shark$FiveDimes > 0])
    odds.shark$naive.FiveDimes[odds.shark$FiveDimes < 0] <- abs(odds.shark$FiveDimes[odds.shark$FiveDimes < 0]) / (100 + abs(odds.shark$FiveDimes[odds.shark$FiveDimes > 0]))
    odds.shark$naive.topbet[odds.shark$TopBet > 0] <- 100 / (100 + odds.shark$TopBet[odds.shark$TopBet > 0])
    odds.shark$naive.topbet[odds.shark$TopBet < 0] <- abs(odds.shark$TopBet[odds.shark$TopBet < 0]) / (100 + (odds.shark$TopBet[odds.shark$TopBet > 0]))
    
    # Remove the vig
    odds.shark$FiveDimes.probability <- odds.shark$naive.FiveDimes / sum(odds.shark$naive.FiveDimes, na.rm=TRUE)
    odds.shark$TopBet.probability <- odds.shark$naive.topbet / sum(odds.shark$naive.topbet, na.rm=TRUE)
    
    # Keep useful variables
    odds.shark <- subset(x = odds.shark, select = c("Team", "FiveDimes.probability", "TopBet.probability"))
    
    
    
    
    
    ## COMBINE PROBABILITIES INTO SINGLE OBJECT
    Teams <- data.frame(Team = unique(Teams[,1]))
    
    data <- merge(x = Teams, y = sportsbook, by = "Team", all.x = TRUE)
    data <- merge(x = data, y = bovada, by = "Team", all.x = TRUE)
    data <- merge(x = data, y = GTbets, by = "Team", all.x = TRUE)
    data <- merge(x = data, y = odds.shark, by = "Team", all.x = TRUE)
    
    
    # Drop 'field' observation.  Although the probability from that
    # observation should be distributed to all the teams that have
    # zero probability in the dataset, the 'field' probability is
    # so small that it effectively makes no difference
    data <- subset(x = data, 
                   subset = (Team != 'Field (Any Other Team)'))
    
    
    # Replace missing values with zeroes
    data[ is.na(data) ] <- 0
    
    
    # Ensemble
    data$ensemble.probability <- rowMeans(x = data[,-1])
    
    
    # Remove duplicates
    data <- data[ !duplicated(data), ]
    
    
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
  
  
  output$last_Betfair_update <- renderText({
    
    # Last Betfair update
    last.betfair.update.time <- fromJSON(json_str=getURL('https://www.kimonolabs.com/api/4pc95v1s?apikey=13ff6ad50d64d091e0a23328afd5c04e'))$lastsuccess
    output$betfair.update <- renderText(expr=paste("Updated", last.betfair.update.time))
    
  })
  
  
  
  output$last_Sportsbook_update <- renderText({
    
    # Last Sportsbook update
    last.sportsbook.update.time <- fromJSON(json_str=getURL('https://www.kimonolabs.com/api/dsyjvzgy?apikey=13ff6ad50d64d091e0a23328afd5c04e'))$lastsuccess
    output$sportsbook.update <- renderText(expr=paste("Updated", last.sportsbook.update.time))
    
  })
  
  
  
  
})
