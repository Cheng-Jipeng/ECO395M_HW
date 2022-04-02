library(RCurl)
library(tidyverse)

g_c = read.csv('https://raw.githubusercontent.com/Cheng-Jipeng/ECO395M/master/data/german_credit.csv')
summary(g_c)

g_c2 = g_c %>%
  group_by(history) %>%
  summarize(p_default = sum(Default==1)/n())
g_c2
ggplot(data=g_c2) +
  geom_col(aes(x=history, y=p_default)) +
  labs(x="History Performance", y="Default Probability")

g_c_glm = glm(formula = Default ~ duration + amount + installment + age + 
      history + purpose + foreign, family = "binomial", data = g_c)

coef(g_c_glm)[2:4] %>% round(2) %>% as.data.frame()
coef_g_c_glm[2:]
# What do you notice about the history variable vis-a-vis predicting defaults? 
# What do you think is going on here? In light of what you see here, do you think this data set is appropriate for building a predictive model of defaults, if the purpose of the model is to screen prospective borrowers to classify them into "high" versus "low" probability of default? Why or why not---and if not, would you recommend any changes to the bank's sampling scheme?
#模型不好，选三个相似的feature,有两个feature选入样本，有遗漏一个feature，导致错误的提高了另外两个feature的错误程度，类似于selection bias=overrepresented
#因为我是刻意对着这两个feature找的sample 