library(RCurl)
library(tidyverse)

g_c = read.csv('https://raw.githubusercontent.com/Cheng-Jipeng/ECO395M/master/data/german_credit.csv')
summary(g_c)

count(g_c$Default==1)
g_c %>%
  group_by(history) %>%
  count(Default==1)

ggplot(aes(x=Default/300, y=history), data=g_c) +
  geom_col() +
  labs(title="default probability by credit history", y="history performance", x="Default probability")

g_c_glm = glm(formula = Default ~ duration + amount + installment + age + 
      history + purpose + foreign, family = "binomial", data = g_c)
summary(g_c_glm)

# What do you notice about the history variable vis-a-vis predicting defaults? What do you think is going on here? In light of what you see here, do you think this data set is appropriate for building a predictive model of defaults, if the purpose of the model is to screen prospective borrowers to classify them into "high" versus "low" probability of default? Why or why not---and if not, would you recommend any changes to the bank's sampling scheme?