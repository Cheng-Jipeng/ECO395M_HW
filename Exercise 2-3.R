setwd("~/OneDrive - The University of Texas at Austin/學習小札/2020 UTAustin/2022 Sp_Data Mining & Stat Learning/Homework2")
getwd()

g_c = read.csv('~/OneDrive - The University of Texas at Austin/學習小札/2020 UTAustin/2022 Sp_Data Mining & Stat Learning/Homework2/german_credit.csv')

library(tidyverse)
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