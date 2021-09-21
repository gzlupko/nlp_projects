# twitter sample 

library(ROAuth)
library(twitteR)


# create Twitter connection 

api_key <- "jcf0K4bRqDrTVLD1sSZmsdWLI"
api_secret <- "ZTU2urYwNj8RMXqSYZJXi5Gveb8GbSP0zITT9vqLJ2mOUgh7po"
access_token <- "AAAAAAAAAAAAAAAAAAAAAFedTwEAAAAAeiHNm98VAp1WXC6H1l3kt093Jkw%3DRFFhFgrUm24KpY04BYK6xHUoazVq0uYuPIOEzvPUA9a2RHpYJB"
access_token_secret <- "38jeqJKRAFCwUY8BdJTMGe2OHWEldJ7q55la7hINoNePA"
bearer_token <- "AAAAAAAAAAAAAAAAAAAAAFedTwEAAAAAeiHNm98VAp1WXC6H1l3kt093Jkw%3DRFFhFgrUm24KpY04BYK6xHUoazVq0uYuPIOEzvPUA9a2RHpYJB"
setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)



### Download sample tweets
```{r}

TL <- searchTwitter("work from home", n=2, since='2021-07-01', until='2021-08-01')
TL <- do.call("rbind", lapply(TL, as.data.frame))
