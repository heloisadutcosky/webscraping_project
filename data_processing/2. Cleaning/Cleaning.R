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
##################################################################################################################################
##################################################################################################################################
### Crypto #######################################################################################################################

# Data gathering -----------------------------------------------------------------------------------------------------------------

  ## New columns (day movement and volatility)
crypto$day_movement = (crypto$open_value - crypto$close_value)/crypto$open_value
crypto$volatility = (crypto$high_value - crypto$low_value)/crypto$high_value

  ## Change XRP per Ripple
crypto$name[crypto$name == "XRP"] = "Ripple"

  ## Make sure the date is read as date
crypto$date = as.Date(crypto$date, '%Y-%m-%d')

  ## Find proportion of market caps per coin
total_mc = group_by(crypto, date) %>%
  summarise(total_market_cap = sum(market_cap))

crypto = left_join(crypto, total_mc, by = "date")

crypto = mutate(crypto, prop_market_cap = market_cap / total_market_cap)

index_10 = filter(crypto, date == max(crypto$date)) %>%
  top_n(., n = 10, wt = prop_market_cap) %>%
  filter(name!= "Bitcoin")

  ## Creating an index on the type of coin (Bitcoin, Top 10, Small coins)

crypto$index[crypto$name %in% index_10$name] = "Top 10"
crypto$index[crypto$name == "Bitcoin"] = "Bitcoin"
crypto$index[is.na(crypto$index)] = "Small coins"

# --------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------
  ### Provar que moedas pequenas estão relacionadas com Bitcoin ------------------------------------------------------------------

small_bit = group_by(crypto, date, index) %>%
  summarise(day_mov = sum(day_movement*prop_market_cap) / sum(prop_market_cap),
            volatility = sum(volatility*prop_market_cap) / sum(prop_market_cap))

  ggplot(small_bit, aes(x = date, y = day_mov)) + geom_line(aes(color = index)) + ylim(-0.25,0.25) +
  facet_grid(index ~ .) + xlab("Date") + ylab("Day movements [%]") +
  scale_x_date(date_breaks = "1 year", limits = c(as.Date('2017-1-1'), as.Date('2017-2-1')))
  
  ggplot(small_bit, aes(x = date, y = volatility)) + geom_line(aes(color = index)) + ylim(-0.25,0.25) +
    facet_grid(index ~ .) + xlab("Date") + ylab("Volatility [%]") +
    scale_x_date(date_breaks = "1 year", limits = c(as.Date('2017-1-1'), as.Date('2017-2-1')))

plot(model_top10)

summary(lm(small_bit$day_mov[small_bit$index == "Top 10"] ~ small_bit$day_mov[small_bit$index == "Bitcoin"]))
summary(lm(small_bit$day_mov[small_bit$index == "Small coins"] ~ small_bit$day_mov[small_bit$index == "Bitcoin"]))

summary(lm(small_bit$volatility[small_bit$index == "Top 10"] ~ small_bit$volatility[small_bit$index == "Bitcoin"]))
summary(lm(small_bit$volatility[small_bit$index == "Small coins"] ~ small_bit$volatility[small_bit$index == "Bitcoin"]))

# --------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------

##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
### Cointelegraph ################################################################################################################

# Data gathering -----------------------------------------------------------------------------------------------------------------

  # Splitting the coins list that show up on that news

library(splitstackshape)

ct = cSplit_e(ct, 'coins_list', sep = " ", mode= 'binary', type='character', fill=0, drop=T) %>%
  gather(., key = "coins_list", value = "value", coins_list_ardor:coins_list_zcash, na.rm = T)

ct = filter(ct, value == 1) %>%
  select(-value, - coin)

ct$coins_list = gsub("coins_list_", "", ct$coins_list)


  ## Arranging the data and joining it with crypto's movements data

crypto$name = tolower(crypto$name)

ct$news_date = as.Date(ct$news_date, '%Y-%m-%d')

ct_crypto = left_join(ct, crypto, by = c("coins_list" = "name", "news_date" = "date"))


  ## Dropping missing data (I dont have information in one of the parameters - don't want it)

ct_crypto = drop_na(ct_crypto)


  ## Classifying news into positive or negative

ct_crypto$content = ifelse(ct_crypto$polarity > 0, "Positive", ifelse(ct_crypto$polarity < 0, "Negative", "Neutro"))


  ## Grouping the data per day

data_ct = group_by(ct_crypto, coins_list, index, news_date, content) %>%
  summarise(news_n = n(), views = sum(views), comments = sum(comments), polarity = mean(abs(polarity)), subjectivity = mean(subjectivity),
            day_movement = mean(day_movement), volatility = mean(volatility))

write.csv(data_ct, "data_ct.csv")

# --------------------------------------------------------------------------------------------------------------------------------

# Graphs for Shiny App ------------------------------------------------------------------------------------------------------------

data_ct = read.csv("data_ct.csv", stringsAsFactors = F)
data_ct = select(data_ct, -1)

index_name = c("Top 10")
coin_name = data_ct$coins_list
content_ = c("Negative", "Positive")
coluna_ = "polarity"

data_ct_graph = filter(data_ct, content %in% content_, coins_list %in% coin_name, index %in% index_name)
data_ct_graph = as.data.frame(data_ct_graph)

ggplot(data_ct_graph, aes(y = data_ct_graph[,"volatility"], x = data_ct_graph[,coluna_])) + 
  geom_point(aes(color = content)) + geom_smooth(method = "lm") +
  xlab(coluna_) + ylab("Volatility") + ggtitle(paste0("Volatility as a function of ", coluna_))

model = lm(data_ct_graph[data_ct_graph$content %in% content_,"volatility"] ~ data_ct_graph[data_ct_graph$content %in% content_,coluna_])

summary(model)

# --------------------------------------------------------------------------------------------------------------------------------

# Multilinear regression ---------------------------------------------------------------------------------------------------------


cor(data_ct[data_ct$content == "Positive",4:10], use = "na.or.complete")
cor(data_ct[data_ct$content == "Negative",4:10], use = "na.or.complete")
cor(data_ct[data_ct$content == "Neutro",4:10], use = "na.or.complete")

data_ct_content = mutate(data_ct, views_weighted = views*polarity*(1-subjectivity), 
                         comments_weighted = comments*polarity*(1-subjectivity)) %>%
  group_by(coins_list, news_date) %>%
  summarise(views = sum(views), comments = sum(comments), polarity = mean(polarity), subjectivity = mean(subjectivity),
            views_weighted = sum(views_weighted), comments_weighted = sum(comments_weighted),
            day_movement = sum(day_movement), volatility = sum(volatility))

cor(data_ct_content[,3:10], use = "na.or.complete")

plot(data_ct_content[,3:10])

summary(lm(data_ct_content$day_movement ~ data_ct_content$views_weighted))
summary(lm(data_ct_content$day_movement ~ data_ct_content$comments_weighted))
summary(lm(data_ct_content$volatility ~ data_ct_content$views_weighted))
summary(lm(data_ct_content$volatility ~ data_ct_content$comments_weighted))

summary(glm(data_ct_content$day_movement ~ data_ct_content$views_weighted + data_ct_content$comments_weighted))
summary(glm(data_ct_content$volatility ~ data_ct_content$views_weighted + data_ct_content$comments_weighted))

# --------------------------------------------------------------------------------------------------------------------------------


##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
### Reddit #######################################################################################################################

# Data gathering -----------------------------------------------------------------------------------------------------------------

  ## Arranging reddit's data and joining it with crypto's movements data
rc$news_date = as.Date(rc$news_date, '%Y-%m-%d')

rc_crypto = left_join(rc, crypto, by = c("coin" = "name", "news_date" = "date"))


  ## Dropping missing data (I dont have information in one of the parameters - don't want it)

rc_crypto = drop_na(rc_crypto)


  ## Classifying news into positive or negative

rc_crypto$content = ifelse(rc_crypto$polarity > 0, "Positive", ifelse(rc_crypto$polarity < 0, "Negative", "Neutro"))

rc_crypto$moderator = ifelse(rc_crypto$moderator == "True", 1, 0)


  ## Grouping the data per day

data_rc = group_by(rc_crypto, coin, index, news_date, content) %>%
  summarise(news_n = n(), subscribers = mean(subscribers), normal_users = sum(post_karma*(1-moderator)), 
            moderators = sum(post_karma*moderator), score = sum(score), comments = sum(comments),
            polarity = mean(abs(polarity)), subjectivity = mean(subjectivity), 
            volatility = mean(volatility), day_movement = mean(day_movement))

write.csv(data_rc, "data_rc.csv")


# --------------------------------------------------------------------------------------------------------------------------------

# Graphs for Shiny App ------------------------------------------------------------------------------------------------------------

data_rc = read.csv("data_rc.csv", stringsAsFactors = F)
data_rc = select(data_rc, -1)

index_name = c("Top 10")
coin_name = data_rc$coin
content_ = c("Negative", "Positive")
coluna_ = "polarity"
moderator_ = 1

data_rc_graph = filter(data_rc, content %in% content_, coin %in% coin_name, index %in% index_name,
                       moderator %in% moderator_)
data_rc_graph = as.data.frame(data_rc_graph)

ggplot(data_rc_graph, aes(y = data_rc_graph[,"volatility"], x = data_rc_graph[,coluna_])) + 
  geom_point(aes(color = content)) + geom_smooth(method = "lm") +
  xlab(coluna_) + ylab("Volatility") + ggtitle(paste0("Volatility as a function of ", coluna_))


moderator_list_rc = c("Normal user", "Subreddit moderator")

is.moderator = function(x){
  return(ifelse(x == "Normal user", 0, 1))
}

model = lm(data_rc_graph[data_rc_graph$content %in% content_,"volatility"] ~ data_rc_graph[data_rc_graph$content %in% content_,coluna_])

summary(model)



# For small coins ----------------------------------------------------------------------------------------------------------------

# Comparing to bitcoin index
bitcoin = filter(crypto, index == "Bitcoin") %>%
  select(date, mov_bitcoin = day_movement, volatility_bitcoin = volatility)

rc_crypto = left_join(rc_crypto, bitcoin, by = c("news_date" = "date"))

# Weighting values in order to group by day
rc_crypto_content = rc_crypto %>%
  select(., -comment_karma, -fonte, - head, -rank,-user, -head_nlp, -close_value, -open_value) %>%
  mutate(., normal_user = ifelse(moderator == 0, content*post_karma, 0)) %>%
  mutate(., moderator = ifelse(moderator == 1, content*post_karma, 0)) %>%
  mutate(., content_score = score*content) %>%
  mutate(., comments = comments * (1-subjectivity))

data_rc = group_by(rc_crypto_content, coin, news_date) %>%
  summarise(volatility_bitcoin = sum(volatility_bitcoin), movement_bitcoin = sum(mov_bitcoin),
            subscribers = mean(subscribers), normal_users = sum(normal_user), moderators = sum(moderator),
            score = sum(score), comments = sum(comments), day_movement = sum(day_movement), 
            volatility = sum(volatility))


plot(rc_crypto_content)

model = glm(day_movement ~ movement_bitcoin + subscribers + normal_users + moderators + score + comments, data = rc_crypto_content)

summary(model)

cor(rc_crypto_content[,3:11])

# --------------------------------------------------------------------------------------------------------------------------------



##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
### Dow Jones ####################################################################################################################

# --------------------------------------------------------------------------------------------------------------------------------

# Gather ----------------------------------------------------------------------------------------------------------------------

  # Open and clean crypto data

crypto = read.csv("crypto_date.csv", stringsAsFactors = F)
crypto = select(crypto, -1)

crypto$name[crypto$name == "XRP"] = "Ripple"

## Find proportion of market caps per coin
total_mc = group_by(crypto, date) %>%
  summarise(total_market_cap = sum(market_cap))

crypto = left_join(crypto, total_mc, by = "date")

crypto = mutate(crypto, prop_market_cap = market_cap / total_market_cap)

index_10 = filter(crypto, date == max(crypto$date)) %>%
  top_n(., n = 10, wt = prop_market_cap) %>%
  filter(name!= "Bitcoin")

## Creating an index on the type of coin (Bitcoin, Top 10, Small coins)

crypto$index[crypto$name %in% index_10$name] = "Top 10"
crypto$index[crypto$name == "Bitcoin"] = "Bitcoin"
crypto$index[is.na(crypto$index)] = "Small coins"

crypto = select(crypto, -prop_market_cap, -total_market_cap)


  # Open and clean dow jones data and joins it with crypto

dj = read.csv("dow_jones.csv", stringsAsFactors = F)

dj$symbol = "DJ"
dj = select(dj, -close_value) %>%
  rename(close_value = adj_close)
dj$market_cap = ""
dj$index = "Dow Jones"

all_values = rbind(crypto, dj)
all_values$day_movement = (all_values$open_value - all_values$close_value)/all_values$open_value
all_values$volatility = (all_values$high_value - all_values$low_value)/all_values$high_value

  ## Make sure the date is read as date
all_values$date = as.Date(all_values$date, '%Y-%m-%d')

all_values = drop_na(all_values)

write.csv(all_values, "dj_crypto.csv")

# --------------------------------------------------------------------------------------------------------------------------------

### First Graph: Dow Jones x Crypto movements ------------------------------------------------------------------------------------

coin_name1 = "Bitcoin"
coin_name2 = "XRP"
coluna = "day_movement"

coin_df = filter(all_values, name == coin_name2) %>%
  select(date)
min = min(coin_df$date)
max = max(coin_df$date)

data = filter(all_values, name == coin_name1 | name == coin_name2) %>%
  select(date, name, coluna)

ggplot(data, aes(x = data[,"date"], y = data[,coluna])) + geom_line(aes(color = data[,"name"])) + 
  scale_x_date(date_breaks = "1 year", limits = c(min, max))
  
# --------------------------------------------------------------------------------------------------------------------------------

### Second Graph: Dow Jones x Crypto movements -----------------------------------------------------------------------------------

coin_name1 = "Bitcoin"
coin_name2 = "XRP"
coluna = "day_movement"

data_coins = filter(all_values, name == coin_name1 | name == coin_name2)%>%
  select("date", "name", coluna) %>%
  spread(., key = "name", value = coluna) %>%
  select(., -date) 

ggplot(data_coins, aes(x = data_coins[,coin_name1], y = data_coins[,coin_name2])) + geom_point() + geom_smooth() +
  xlab(coin_name1) + ylab(coin_name2) + ggtitle(paste("Correlation between", coin_name1, "and", coin_name2, coluna))

# --------------------------------------------------------------------------------------------------------------------------------

##################################################################################################################################
# t-test - Null hypothesis : beta1 = 0 -> no correlation between x and y

### First Infobox: P-value -------------------------------------------------------------------------------------------------------

coin_name1 = "Bitcoin"
coin_name2 = "XRP"
coluna = "day_movement"

model = lm(data_coins[,coin_name2] ~ data_coins[,coin_name1])
sm_model = summary(model)

p_value = sm_model$coefficients[2,4]

# --------------------------------------------------------------------------------------------------------------------------------

### Second Infobox: Correlation equation -----------------------------------------------------------------------------------------

coin_name1 = "Bitcoin"
coin_name2 = "XRP"
coluna = "day_movement"

model = lm(data_coins[,coin_name2] ~ data_coins[,coin_name1])
sm_model = summary(model)

p_value = sm_model$coefficients[2,4]

if(p_value>0.05){
  "No correlation"
} else{
  beta0 = model[1]$coefficients[[1]]
  beta1 = model[1]$coefficients[[2]]
}

# --------------------------------------------------------------------------------------------------------------------------------

### Third Infobox: R^2 -----------------------------------------------------------------------------------------------------------
# (Coefficient of Determination)

coin_name1 = "Bitcoin"
coin_name2 = "XRP"
coluna = "day_movement"

model = lm(data_coins[,coin_name2] ~ data_coins[,coin_name1])
sm_model = summary(model)

p_value = sm_model$coefficients[2,4]

if(p_value>0.05){
  "No correlation"
} else{
  R_2 = sm_model$adj.r.squared
}
  
## Obs.: low R^2 = dependent variable variability is little explained by the regression model

# --------------------------------------------------------------------------------------------------------------------------------

### Third Graph: Residual  x Fitted values ---------------------------------------------------------------------------------------

coin_name1 = "Bitcoin"
coin_name2 = "XRP"
coluna = "day_movement"

model = lm(data_coins[,coin_name2] ~ data_coins[,coin_name1])

plot(model$fitted, model$residuals, xlab = "Fitted values", ylab = "Residuals", main = "Residuals")

# --------------------------------------------------------------------------------------------------------------------------------

### Fourth Graph: QQ Plot residuals ----------------------------------------------------------------------------------------------

coin_name1 = "Bitcoin"
coin_name2 = "XRP"
coluna = "day_movement"

model = lm(data_coins[,coin_name2] ~ data_coins[,coin_name1])

qqnorm(model$residuals)
qqline(model$residuals)

# --------------------------------------------------------------------------------------------------------------------------------
