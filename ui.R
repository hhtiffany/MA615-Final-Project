library(shiny)
library(shinythemes)
require(leaflet)
library(dygraphs)


shinyUI(fluidPage(
  theme="bootstrap.min.css",
  titlePanel(fluidRow(
             column(3, img(src="logo.png",height=80,width=180)), 
             column(8, h3("MA615 Project: Trump via Twitter Data")))),
  navbarPage(title="",
          ## Home Page
             tabPanel(title = strong("Home"),img(src="trump-twitter.jpg",width="100%", height="100%")),
           
          ## Introduction Page  
             tabPanel(strong("Introduction"),
                      strong(p("Author: Tianwen Huan")),
                      
                      hr(),
                      p("This project first used",code("filterStream") ,"code to track data including
                        'Trump' located in United States from Twitter. The original dataset 
                        include 28147 observations. 
                        Based on this dataset, I first did some simple data clean to make it
                        suitable for later analysis." ),
                      
                      hr(),
                      p("Based on this original data, I divided the further analysis into five parts:"),
                      p("1. Map"), 
                      p("2. Word Cloud"), 
                      p("3. Top Retweeted Analysis"),
                      p("4. Sentiment Analysis"), 
                      p("5. Time Series"),
                      
                      hr(),
                      p("Finally, I also created the pdf and html document for my final project. 
                        All the materials including the ui.R and server.R can be found from the link below:"),
                      a(href="https://github.com/hhtiffany/MA615-Final-Project", "MA615 Final Project - Tianwen Huan")
                      ), 
             
          ## 1. Map  
             tabPanel(strong("Map"),
                      h4(strong(p("Spatial Mapping"))),
                      p("This map plotted all the available 'place_lat' and 'place_lon' points created from the
                         original dataset. From the map below we can tell that Trump own more attention in Twitter
                        in recent years than before. The very few points of the first year 2006 may due to the data
                        searching limitation. From all these years' data, we can found that people near the seaside
                        and east pay more attention on Trump in Twitter than people live in the inland."),
                      hr(),
                      sidebarPanel(sliderInput(inputId = 'year1', label=strong("Year"), 
                                               min=2006, max=2016, value=2016, step=1)),
                      mainPanel(leafletOutput("map"))
                      ),
          
          ## 2. Word Cloud
             tabPanel(strong("Top Words"),
                      h4(strong(p("Word Cloud"))),
                      p("From the picture below we can find that people really interested in 'Job', 
                         'Russia' and 'Sate Security' when they talk about Trump on Twitter."),
                      hr(),
                      sidebarPanel(sliderInput("mf",strong("Min Frequency:"),200,600,260,10), hr(),
                                   sliderInput("mw",strong("Max Words:"),60,166,80,10),hr()),
                      mainPanel(plotOutput("wc")),
                      br(),
                      h4(strong("Barplot of Top Popular Words")),
                      p("This barplot has shown the most popular words people used when they mentioned 
                        Trump on Twitter, which has revealed the area people most considerded about,
                        such as 'Job', 'Russia', 'Sate Security' and so on. Use the sidebar below to
                        check the words in different mention frequency. "),
                      hr(),
                      sidebarPanel(sliderInput("mtf",strong("More than Frequency:"),700,5000,1500,100), hr()),
                      mainPanel( plotOutput("bp"))),
                    
          ## 3. Top Retweeted Analysis
          tabPanel(strong("Top Retweeted Text"),
                   h4(strong("Top Retweeted Tweetsop")),
                   p("This plot shows the top retweeted twitters related to Trump in different year. The
                     most retweeted twitters are created in recent years. This is normal because the time
                     passing made old twitter hard to be found again by people."),
                   hr(),
                   sliderInput("trt",strong("Min Retweet Counts:"),10000,80000,25000,500),
                   br(),
                   plotOutput("trt")),
          
          ## 4. Sentiment Analysis
             tabPanel(strong("Sentiment Analysis"),
                      h4(strong("Sentiment Analysisp")),
                      p("The positive score stands for 'positive' sentiment. The negative score stands 
                         for 'negetive' sentiment. The higher the score, the more positive. The lower    
                         the score, the more negative. The result showed a liitle bit more negative than 
                        positive. Please use the select bar below to choose the time period you interested
                        in."),
                      hr(),
                      dygraphOutput("senti")
                      ),
          
          ## 5. Time Series
          tabPanel(strong("Time Series"),
                   h4(strong("Time Series")),
                   p("This plot shows the weekly tweets number according to the time. Please use the select bar 
                      below to choose the time period you interested in."),
                   hr(),
                   dygraphOutput("ts"),
                   br(),br(),br(), 
                   h4(strong("Check the Autocorrelation")),
                   p("The ACF plot for most years(except 2009) suggested that there is no significant correlation to 
                     be captured by a model. The autocorrelations are within the 5% significance bands. However, 
                     correlation seems exit during year 2009, because a number of autocorrelations are outside the 
                     5% significance bands. Please use the select bar below to check the ACF plots for different years."),
                   hr(),
                   sidebarPanel(sliderInput(inputId = 'year2', label=strong("Year"), 
                                            min=2006, max=2016, value=2016, step=1)),
                   mainPanel(plotOutput("acf"))
                   )
          
           
             )))