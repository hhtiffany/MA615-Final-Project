
#######################################################################################
############################# Setup Twitter Oauth
library(twitteR)

api_key <- 	"Wn8T24lYzEAqYPZctbAYYcSB5"
api_secret <- "zkxCDTViuqDVeFAvrYmWdetMcd20NLemFoXgSUNcuteipDF7NX"
access_token <- "793887904984629248-Fe7cs8CAF33gWUyt8yRT5qCICQGcbR6"
access_token_secret <- "FkTOObT7Qmzxdrqiuf3TejN3GGYbd9DlDGlydA5uVGfwr"

setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)



#######################################################################################
############################# Save my_oauth
library(ROAuth)

requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "Wn8T24lYzEAqYPZctbAYYcSB5"
consumerSecret <- "zkxCDTViuqDVeFAvrYmWdetMcd20NLemFoXgSUNcuteipDF7NX"
my_oauth <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
                             requestURL = requestURL, accessURL = accessURL, authURL = authURL)

my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

save(my_oauth, file = "my_oauth.Rdata")



#######################################################################################
############################# Getting Data
library(streamR)
load("my_oauth.Rdata")

filterStream(file.name = "tweets.t", 
             track = c("Trump"),
             language = "en",
             locations=c(-125,25,-66,50),
             timeout = 600, 
             oauth = my_oauth) 

Trump<- parseTweets("tweets.t", simplify = FALSE)



#######################################################################################
############################# Simple Data Clean
library(dplyr)
load("Trump.RData")
Trump$created <-  as.POSIXct(strptime(Trump$user_created_at, "%a %b %d %H:%M:%S %z %Y"))
Trump <- Trump[, c(1,2,3,18,20,21,22,23,30,38,39,44)] %>% arrange(created)
Trump$text <- gsub("[^[:alnum:]///' ]", "", Trump$text)



#######################################################################################
############################# Data subset for Map
library(data.table)
points <- data.frame(x=as.numeric(Trump$place_lon),
                     y=as.numeric(Trump$place_lat))
year <- year(strptime(Trump$created, format="%Y"))
points$year <- year

points <- points[points$y<50,] 
points <- points[points$y>20,] 
points <- points[points$x< -60,] 
points <- points[points$x>-125,] 

map <- na.omit(points)



#######################################################################################
############################# Data subset for Word Cloud 
########### Create corpus
library(tm)
# build a corpus, and specify the source to be character vectors
corpus <- Corpus(VectorSource(Trump$text))

# convert to lower case
corpus <- tm_map(corpus, content_transformer(tolower))

# remove URLs and anything other than English letters or space
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeURL))
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
corpus <- tm_map(corpus, content_transformer(removeNumPunct))

# remove stopwords
myStopwords <- c(setdiff(stopwords('english'), c("Trump")), 
                 "just", "will", "im", "like", "dont", "one", "can", "get", "now")
corpus <- tm_map(corpus, removeWords, myStopwords)

# remove extra whitespace
corpus <- tm_map(corpus, stripWhitespace)

# convert corpus to a Plain Text Document
corpus <- tm_map(corpus,PlainTextDocument)

# replace oldword with newword
replaceWord <- function(corpus, oldword, newword) {
  tm_map(corpus, content_transformer(gsub),
         pattern=oldword, replacement=newword)}

corpus <- replaceWord(corpus, "trumps", "trump")
corpus <- replaceWord(corpus, "donald", "trump")
corpus <- replaceWord(corpus, "russian", "russia")
corpus <- replaceWord(corpus, "american", "america")
corpus <- replaceWord(corpus, "jobs", "job")

########### Build Term Doc Matrix
tdm <- TermDocumentMatrix(corpus, control = list(wordLengths = c(1, Inf)))
# count word frequence
term.freq <-sort(rowSums(as.matrix(tdm)), decreasing=TRUE) 
term.freq <- subset(term.freq, term.freq >= 200)
wordcloud <- data.frame(term = names(term.freq), freq = term.freq)



#######################################################################################
############################# Data subset for Sentiment Analysis
library(sentiment)
sentiments <- sentiment(Trump$text)

## sentiment table
sentiments$score <- 0
sentiments$score[sentiments$polarity == "positive"] <- 1
sentiments$score[sentiments$polarity == "negative"] <- -1
sentiments$date <- Trump$created
senti <- aggregate(score ~ date, data = sentiments, sum)



#######################################################################################
############################# Data subset for Top Retweeted Tweetsop and Times Series
rets <- Trump[, c(2,3,12)]



#######################################################################################
############################# Save Data
save(Trump, file = "Trump.RData")
save(map, file = "map.RData")
save(tdm, file = "tdm.RData")
save(wordcloud, file = "wordcloud.RData")
save(lda, file = "lda.RData")
save(topics, file = "topics.RData")
save(senti, file = "senti.RData")
save(rets, file = "rets.RData")

