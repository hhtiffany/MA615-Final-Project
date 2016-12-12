library(shiny)
library(shinythemes)


shinyUI(fluidPage(
  theme="bootstrap.min.css",
  titlePanel(title=h3(img(src="logo.png",height=80,width=180),"MA615 Project: Trump via Twitter Data")),
  navbarPage(title="",
          ## Home Page
             tabPanel(title = "Home",img(src="trump-twitter.jpg",width="100%", height="100%")),
           
          ## Introduction Page  
             tabPanel("Introduction",
                      p("Author: Tianwen Huan"),
                      
                      hr(),
                      p("This project first used 'filterStream' code to track data including
                        'Trump' from Twitter. The original dataset include 28147 observations. 
                        Based on this dataset, I first did some simple data clean to make it
                        suitable for later analysis. The code has been uploaded to github, 
                        check the following link："),
                      a(href="https://github.com/hhtiffany/MA615-Final-Project/blob/master/Geting%20data.R","Getting Data"),
                      
                      hr(),
                      p("Based on this original data, I divided the further analysis into four parts:"),
                      p("1. Map"), 
                      p("2. 'words' Analysis: Cluster Dendrogram, Word Cloud and Word Association Analysis"), 
                      p("3. Sentiment Analysis"), 
                      p("4. Top Frequency Analysis: Topic Modeling, Top Retweeted Tweetsop and Barplot"),
                      
                      hr(),
                      p("Finally, I also created the pdf anf html document for my final project. 
                        All the materials including the ui.R and server.R can be found from the follwing link page."),
                      a(href="https://github.com/hhtiffany/MA615-Final-Projectv", "MA615 Final Project - Tianwen Huan")
                      ), 
             
          ## 1. Map  
             tabPanel("1. Map",
                      sidebarPanel(selectInput(inputId = "y", label = "Year",
                                               c("2006-2010" = "p1",
                                                 "2011-2016" = "p2",
                                                 "2006-2016" = "points"),
                                    hr())),
                      mainPanel(p("This map plotted all the available 'place_lat' and 'place_lon' points created from the
                                  original dataset. From the map below we can tell that Trump own more attention in Twitter
                                  in recent years than before.") ,
                                imageOutput("map"))
                      ),
          
          ## 2. 'words' Analysis
             tabPanel("2. 'words' Analysis",
                      tabsetPanel(tabPanel(strong("Cluster Dendrogram"),
                                           sidebarPanel(radioButtons(inputId = "fit",
                                                                     label = "Sparse",
                                                                     choices=c("0.96"="fit96", "0.97"="fit97", 
                                                                     "0.98"="fit98"),
                                                                     selected="0.96"),
                                                        hr(),
                                                        p("Code:"),
                                                        code("# remove sparse terms and cluster terms"), br(),
                                                        code("# tdm2 <- removeSparseTerms(tdm, sparse = 0.96/0.97/0.98)"),br(),
                                                        code("# distMatrix <- dist(scale(as.matrix(tdm2)))"),  br(),
                                                        code("# fit <- hclust(distMatrix, method = 'ward.D2')"),  br(),
                                                        code("# plot(fit)"),br(),
                                                        code("# rect.hclust(fit, k=6)")),
                                           mainPanel( h4("Cluster Dendrogram with Different Sparse"),
                                                      p("The results showed that when people talk about Trump on Twitter, 
                                                        they mainly considered about 'Job', 'Russia' and 'Sate Security'."),
                                                      imageOutput("cd"))),
                                  tabPanel(strong("Word Cloud"),
                                           sidebarPanel(sliderInput("mf","Min Frequency:",60,600,60,
                                                                    format="####",
                                                                    animate=TRUE), hr(),
                                                        sliderInput("mw","Max Words:",200,800,400,
                                                                    format="####",
                                                                   animate=TRUE),hr()),
                                           mainPanel( h4("Word Cloud"),
                                                      p("People really interested in 'Job', 'Russia' and 'Sate Security' when they
                                                         talk about Trump on Twitter."),
                                                      plotOutput("wc"))),
                                          
                                  tabPanel(strong("Word Association Analysis"),
                                           tabsetPanel(tabPanel(strong("Find Word Association"),
                                                                sidebarPanel(selectInput(inputId = "word", label = "Top Frequency Term",
                                                                                         c("trump","rt","russia","state","secretary","tillerson", 
                                                                                           "putin", "cia","amp","job","election")),
                                                                             hr(),
                                                                             sliderInput("cl","Corlimit:",0.1,0.5,0.3,
                                                                                              format="####",
                                                                                              animate=TRUE), 
                                                                             hr()),
                                                                mainPanel( h4("Find Word Association"),
                                                                           verbatimTextOutput("fwa"),
                                                                           p("For example, the words associated with 'Russia' when 
                                                                             corlimit equals to 0.3 are 'cia'(0.34) and 'election'(0.32)."))),
                                                       tabPanel(strong("Word Association Graph"),
                                                                sidebarPanel(sliderInput("lf","Lower Frequency:",700,3000,700,
                                                                                         format="####",
                                                                                         animate=TRUE), hr(),
                                                                             sliderInput("ct","corThreshold:",0.1,0.4,0.2,
                                                                                         format="####",
                                                                                         animate=TRUE),hr()),
                                                                mainPanel( h4("Word Association Graph"),
                                                                           plotOutput("wag"))))
                                           )
                                  )
                      ),
          
          ## 3. Sentiment Analysis
             tabPanel("3. Sentiment Analysis",
                      sidebarPanel(p("Code:"),
                                   code("# install package sentiment140"),br(),
                                   code("require(devtools)"),br(),
                                   code("install_github('sentiment140', 'okugami79')"), br(),
                                   hr(),
                                   code("# sentiment analysis"), br(),
                                   code("library(sentiment)"), br(),
                                   code("sentiments <- sentiment(Trump$text)"), br(),
                                   hr(),
                                   code("# sentiment table"),br(),
                                   code("sentiments$score <- 0"), br(),
                                   code("sentiments$score[sentiments$polarity == 'positive'] <- 1"), br(),
                                   code("sentiments$score[sentiments$polarity == 'negative] <- -1"), br(),
                                   code("sentiments$date <- as.IDate(Trump$created)"), br(),
                                   code("result <- aggregate(score ~ date, data = sentiments, sum)"), br(),
                                   hr(),
                                   code("# sentiment plot"),br(),
                                   code("plot(result, type = 'l')"),br(),
                                   code("qplot(polarity, data=sentiments)"),br(),
                                   hr()),
                      mainPanel( h4("Sentiment Plot"),
                                 p("The positive score stands for 'positive' sentiment. 
                                    The negative score stands for 'negetive' sentiment.
                                    The higher the score, the more positive. 
                                    The lower the score, the more negative.
                                    The result showed a liitle bit more negative than positive."),
                                 plotOutput("plot"),
                                 hr(),
                                 h4("Polarity Table"),
                                 plotOutput("qplot"))
                      ),
          
          ## 4. Top Frequency Analysis
             tabPanel("4. Top Frequency Analysis",
                      tabsetPanel(tabPanel(strong("Topic Modeling"),
                                           sidebarPanel(sliderInput("nt","No. of Topics:",6,12,8,
                                                                    format="####",
                                                                    animate=TRUE), 
                                                        hr(),
                                                        sliderInput("ft","First n Terms of each Topict:",6,12,7,
                                                                    format="####",
                                                                    animate=TRUE), 
                                                        hr()),
                                           mainPanel( h4("Topic Modeling"),
                                                      p("The results showed the most popular topics about Trump in Twitter.
                                                        It's clear from the picture that people starts to pay more attention on
                                                        politic topics with Trump since 2009."),
                                                      plotOutput("tm"))),
                                  tabPanel(strong("Barplot of Top 20 Popular Words"),
                                           sidebarPanel(sliderInput("mtf","More than Frequency:",700,5000,700,
                                                                    format="####",
                                                                    animate=TRUE), hr()),
                                           mainPanel( h4("Barplot of Top 20 Popular Words"),
                                                      p("This plot shows the most popular words people mentioned when they 
                                                        talk about Trump by using Twitter."),
                                                      plotOutput("bp"))),
                                  tabPanel(strong("Top Retweeted Tweetsop"),
                                           sidebarPanel(sliderInput("trt","Min Retweet Counts:",20000,80000,25000,
                                                                    format="####",
                                                                    animate=TRUE), hr()),
                                           mainPanel( h4("Top Retweeted Tweetsop"),
                                                      p("This plot shows the top retweeted twitters related to Trump."),
                                                      plotOutput("trt"))
                                  )
                                  )) 
             )))