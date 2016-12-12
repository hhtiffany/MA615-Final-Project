
############################# Setup Twitter Oauth
library(twitteR)

api_key <- 	"Wn8T24lYzEAqYPZctbAYYcSB5"
api_secret <- "zkxCDTViuqDVeFAvrYmWdetMcd20NLemFoXgSUNcuteipDF7NX"
access_token <- "793887904984629248-Fe7cs8CAF33gWUyt8yRT5qCICQGcbR6"
access_token_secret <- "FkTOObT7Qmzxdrqiuf3TejN3GGYbd9DlDGlydA5uVGfwr"

setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)



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


############################# Save Data
#save(Trump, file = "Trump.RData")


