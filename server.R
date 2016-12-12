################ library packages
library(shiny)
library(ggplot2)
library(grid)
library(tm)
library(dplyr)
library(graph)
library(Rgraphviz)
library(topicmodels)
library(data.table)
library(leaflet)
library(sentiment)
if (!require('pacman')) install.packages('pacman')
pacman::p_load(twitteR, sentiment, plyr, ggplot2, wordcloud, RColorBrewer, httpuv, RCurl, base64enc)


################ Install of several packages
##### sentiment
# require(devtools)
# install_github("sentiment140", "okugami79")
##### graph & Rgraphviz
# source("https://bioconductor.org/biocLite.R")
# biocLite("BiocInstaller")
# biocLite("graph")
# biocLite("Rgraphviz")


################ Loading Data
load("Trump.RData")
load("Tr.RData")
load("wordcloud.RData")
load("tdm.RData")
load("result.RData")
load("sentiments.RData")
load("dtm.new.RData")



################ Sever
shinyServer(function(input, output) {
  ## Panel of Map
  output$map <- renderImage({filename <- normalizePath(file.path('./www',
                                        paste(input$y, '.png', sep='')))
                            list(src = filename, width = 800,height = 600)},
                            deleteFile = FALSE)
  
  ## Panel of 'words' Analysis
   # Cluster Dendrogram
   output$cd <- renderImage({filename <- normalizePath(file.path('./www',
                                         paste(input$fit, '.png', sep='')))
                             list(src = filename, width = 800,height = 600)},
                             deleteFile = FALSE)
   # Word Cloud
   output$wc <- renderPlot({set.seed(1)
     wordcloud(words = df$term, freq = df$freq, min.freq = input$mf, 
               random.color = TRUE, max.words=input$mw, rot.per=0.35, 
               colors=brewer.pal(8, "Dark2"))})
   # Find Word Association
   output$fwa <- renderPrint({findAssocs(tdm, input$word, input$cl)})
   # Word Association Graph
   output$wag <- renderPlot({plot(tdm, terms=findFreqTerms(tdm, lowfreq=input$lf), 
                                  corThreshold = input$ct,
                                  attrs=list(node=list(width=20, fontsize=14, 
                                                       fontcolor="blue", color="navy")))})
 
  ## Panel of Sentiment Analysis
   output$plot <- renderPlot({plot(result, type = "l")})
   output$qplot <- renderPlot({qplot(polarity, data=sentiments)})
  
  ## Panel of Top Frequency Analysis
   # Topic Modeling
   output$tm <- renderPlot({lda <- LDA(dtm.new, k = input$nt) # find 8 topics
                            term <- terms(lda, input$ft) # first 7 terms of every topic
                            topics <- topics(lda) # 1st topic identified for every document (tweet)
                            topics <- data.frame(date=as.IDate(Tr$created), topic=topics)
                            ggplot(topics, aes(date, fill = term[topic])) +
                              geom_density(position = "stack")})
   # Barplot of Top 20 Popular Words
   output$bp <- renderPlot({dfsub <- df %>% filter(freq>input$mtf)
                            ggplot(dfsub, aes(x=term, y=freq)) + 
                              geom_bar(stat="identity", width=0.5, fill="lightblue") +
                              xlab("Terms") + ylab("Count") + coord_flip() +
                              theme(axis.text=element_text(size=10)) +
                              geom_text(aes(label=freq), vjust=0.3, hjust=1.1, color="white", size=3.5)})
   # Top Retweeted Tweetsop
   output$trt <- renderPlot({selected <- which(Trump$retweet_count >= input$trt)
                            dates <- strptime(Trump$created, format="%Y-%m-%d")
                            plot(x=dates, y=Trump$retweet_count, type="l", col="grey",
                                 xlab="Date", ylab="Times retweeted")
                            colors <- rainbow(length(selected))[1:length(selected)]
                            points(dates[selected], Trump$retweet_count[selected], pch=19, col=colors)
                            text(dates[selected], Trump$retweet_count[selected],
                                 Trump$text[selected], col=colors, cex=.9)})
  
   })

