library(dplyr)
library(ggplot2)
library(ggthemes)
library(googleVis)
library(scales)
library(RColorBrewer)
library(plotly)
library(shiny)
library(shinydashboard)
library(htmlwidgets)
library(devtools)
library(DT)
library(tidyr)
library(car)

setwd("/Users/heloisadutcosky/Documents/NYC Data Science Academy/Projetos/Projeto 2 - Web Scraping/Project2/data_processing/2. Cleaning/data")
all_values = read.csv("dj_crypto.csv", stringsAsFactors = F)
all_values = select(all_values, -1)
data_ct = read.csv("data_ct.csv", stringsAsFactors = F)
data_ct = select(data_ct, -1)
data_rc = read.csv("data_rc.csv", stringsAsFactors = F)
data_rc = select(data_rc, -1)

data_rc = drop_na(data_rc)

all_values$date = as.Date(all_values$date, '%Y-%m-%d')
data_ct$news_date = as.Date(data_ct$news_date, '%Y-%m-%d')
data_rc$news_date = as.Date(data_rc$news_date, '%Y-%m-%d')

index_list = unique(all_values$index)
coins_list = sort(c(unique(all_values$name), ""))
min_date = min(all_values$date)
max_date = max(all_values$date)

columns_list = c("Day movement (Open x close values)", 
                 "Day volatility (High x low values)")

index_list_ct = unique(data_ct$index)
content_list_ct = unique(data_ct$content)
column_list_ct = colnames(data_ct)

column_list_rc = colnames(data_rc)

is.coin = function(x){
  ifelse(x == "", return(coins_list), return(x))
}