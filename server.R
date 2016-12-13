################ library packages
library(shiny)
library(ggplot2)
library(plotly)
library(grid)
library(tm)
library(dplyr)
library(graph)
library(Rgraphviz)
library(data.table)
require(leaflet)
library(sentiment)
library(dygraphs)
if (!require('pacman')) install.packages('pacman')
pacman::p_load(twitteR, sentiment, plyr, ggplot2, wordcloud, RColorBrewer, httpuv, RCurl, base64enc)



################ Sever
shinyServer(function(input, output) {
  
  
     ### Panel of Map
     output$map <- renderLeaflet({leaflet(map[map$year==input$year1,]) %>% 
                                  addTiles() %>%
                                  setView( lng = -96, lat = 37.8,  zoom = 4 )  %>%
                                  addCircleMarkers(~x, ~y, radius=6)})
 
  
  
     ### Panel of Word Cloud
      output$wc <- renderPlot({wordcloud(words = wordcloud$term, freq = wordcloud$freq, 
                                         min.freq = input$mf, random.color = TRUE, 
                                         max.words=input$mw, rot.per=0.35, scale=c(5,0.5), 
                                         colors=brewer.pal(8, "Dark2"))})
      # Barplot of Top Popular Words
      output$bp <- renderPlot({dfsub <- wordcloud %>% filter(freq>input$mtf)
                               ggplot(dfsub, aes(x=term, y=freq)) + 
                                 geom_bar(stat="identity", width=0.5, fill="lightblue") +
                                 xlab("Terms") + ylab("Count") + coord_flip() +
                                 theme(axis.text=element_text(size=10)) +
                                 geom_text(aes(label=freq), vjust=0.3, hjust=1.1, color="white", size=3.5)})
  
   
   
     ### Top Retweeted Analysis
       output$trt <- renderPlot({selected <- which(rets$retweet_count >= input$trt)
                             plot(x=dates, y=rets$retweet_count, type="l", col="grey",
                                  xlab="Date", ylab="Times retweeted")
                             colors <- rainbow(length(selected))[1:length(selected)]
                             points(dates[selected], rets$retweet_count[selected], pch=19, col=colors)
                             text(dates[selected], rets$retweet_count[selected],
                                  rets$text[selected], col=colors, cex=.9)})
   
 
     ### Panel of Sentiment Analysis
      output$senti <- renderDygraph({dygraph(sentid, main = "Sentiment Score") %>% 
        dyRangeSelector(dateWindow = c("2006-07-12", "2016-12-10"))})
   
   
     ### Panel of Time Series
      output$ts <- renderDygraph({dygraph(ts.sum, main = "Weekly Tweets Number") %>% 
          dyRangeSelector(dateWindow = c("2006-07-12", "2016-12-10"))})
   
      output$acf <- renderPlot(acf(ts.sum[year2==input$year2]))
  
   })

