load("map.RData")
load("wordcloud.RData")
load("topics.RData")
load("senti.RData")
load("rets.RData")



library(data.table)
year <- year(strptime(rets$created, format="%Y"))
dates <- strptime(rets$created, format="%Y-%m-%d")

# creat xts doc
library(xts)
sentid <- xts(senti$score, senti$date)
ts <- xts(rep(1,times=nrow(rets)),rets$created)
ts.sum <- apply.weekly(ts,sum)

year2 <- year(strptime(index(ts.sum), format="%Y"))


