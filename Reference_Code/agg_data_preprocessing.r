library(data.table)
library(ggplot2)
library(ggthemes)
library(gridExtra)
library(zoo)
################ 
#### AFFECT DATA 

dt_affect <- data.table(read.csv("~/Documents/C/Research/data/all_keywords_0301_0709_agg_complete.csv"))
dt_affect$X = NULL

## 2020 data 
dt_affect[, date:= as.character(date)]
dt_affect <- dt_affect[grepl('2020', date)]

dt_affect[, date:= as.Date(date, format = "%b-%d-%Y")]

dt_affect[state=='California'][order(date)]
dt_affect[state=='New York'][order(date)]
dt_affect[state=='Alabama'][order(date)]
dt_affect[state=='Texas'][order(date)]


dt_affect[, list(total_cnt = sum(count)), by = state][order(-total_cnt)]


################ 
#### COVID DATA 

dt_covid = data.table(read.csv(file = '~/Documents/C/Research/data/covid_state_by_date.csv'))
dt_covid$X = NULL

dt_affect[, state:= as.character(state)]
dt_covid[, date:= as.Date(date)]
states_affect = dt_affect[, unique(state)]
states_covid = dt_covid[, unique(state)]
length(states_affect)
length(states_covid)
setdiff(states_affect, states_covid)
intersect(states_affect, states_covid)

dt_affect[state == 'Washington, D.C.', state:= 'District of Columbia']
intersect(dt_affect[, unique(state)], dt_covid[, unique(state)])
length(intersect(dt_affect[, unique(date)], dt_covid[, unique(date)]))


dt_covid[order(state, date), new_cases := total_confirmed - shift(total_confirmed), by = list(state)]
dt_covid[order(state, date), new_deaths := total_deaths - shift(total_deaths), by = list(state)]
dt_covid[order(state, date), last_day_new_cases := shift(new_cases), by = list(state)]
dt_covid[order(state, date), last_day_new_death := shift(new_deaths), by = list(state)]
dt_covid[order(state, date), rolling_avg_new_cases_3day := frollmean(new_cases, 3), by = list(state)]
dt_covid[order(state, date), rolling_avg_new_cases_5day := frollmean(new_cases, 5), by = list(state)]
dt_covid[order(state, date), rolling_avg_new_cases_7day := frollmean(new_cases, 7), by = list(state)]

################ 
#### combine data with all date-state pairs 
all_dates = dt_affect[, unique(date)]
all_states = dt_affect[, unique(state)]

dt = data.table( date = rep(all_dates, each = length(all_states))
                 , state = rep(all_states, length(all_dates))
                 )

dt = base::merge(dt, dt_affect, by = c('date', 'state'), all.x = T)
dt = base::merge(dt, dt_covid, by = c('date', 'state'), all.x = T)

dt[is.na(dt)] <- 0
#dt[order(state, date), new_cases := total_confirmed - shift(total_confirmed), by = list(state)]
#dt[order(state, date), new_deaths := total_deaths - shift(total_deaths), by = list(state)]

################ 
#### country level agg

names(dt)

dt_country = dt[, list(state = 'US total'
                       , count = sum(count)
                       , pred_anger = sum(count*pred_anger)/sum(count)
                       , pred_sadness = sum(count*pred_sadness)/sum(count)
                       , pred_joy = sum(count*pred_joy)/sum(count)
                       , pred_disgust = sum(count*pred_disgust)/sum(count)
                       , pred_fear = sum(count*pred_fear)/sum(count)
                       , pred_surprise = sum(count*pred_surprise)/sum(count)
                       , total_confirmed = sum(total_confirmed)
                       , total_deaths = sum(total_deaths)
                       , new_cases = sum(new_cases)
                       , new_deaths = sum(new_deaths)
                       , last_day_new_cases = sum(last_day_new_cases)
                       , last_day_new_death = sum(last_day_new_death)
                       , rolling_avg_new_cases_3day = sum(rolling_avg_new_cases_3day)
                       , rolling_avg_new_cases_5day = sum(rolling_avg_new_cases_5day)
                       , rolling_avg_new_cases_7day = sum(rolling_avg_new_cases_7day)
                       )
                , by = list(date)]

setcolorder(dt_country, names(dt))
dt = rbind(dt, dt_country)

dt = dt[date>=as.Date('2020-03-01') & date<=as.Date('2020-07-01') ]

write.csv(dt, '~/Documents/C/Research/data/state_date_level_twitter_affect_covid_agg_0301_0701_complete.csv')


