library(dplyr)
library(ggplot2)
library(tidyr)

setwd("/Users/heloisadutcosky/Documents/NYC Data Science Academy/Projetos/Projeto 2 - Web Scraping/Project2/data_processing/2. Cleaning/data")
crypto = read.csv("crypto_date.csv", stringsAsFactors = F)
dj = read.csv("dow_jones.csv", stringsAsFactors = F)
ct = read.csv("cointelegraph_nlp.csv", stringsAsFactors = F)
rc = read.csv("reddit_nlp.csv", stringsAsFactors = F)

crypto = select(crypto, -1)
rc = select(rc, -1)
ct = select(ct, -1)

##################################################################################################################################
### Crypto #######################################################################################################################

# 1 - Bitcoin and other cryptocurrencies are not correlated with the stock market (Used Dow Jones to prove it) -------------------


# 2 - Smaller coins follow Bitcoins movements ------------------------------------------------------------------------------------


# 3 - Bitcoin movements are determined by posts or news on it --------------------------------------------------------------------


# 4 - Other cryptocurrencies movements are a function of Bitcoin's movements and their own news ----------------------------------