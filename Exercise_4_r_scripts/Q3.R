library(tidyverse)
library(arules) # has a big ecosystem of packages built around it.
library(arulesViz)
library(igraph)

groceries = read.csv("https://raw.githubusercontent.com/Cheng-Jipeng/ECO395M/master/data/groceries.txt",header = FALSE)

groceries$buyer = seq.int(nrow(groceries))
groceries = cbind(groceries[,5], stack(lapply(groceries[,1:4], as.character)))[1:2]
colnames(groceries) = c("Customer","Goods")
groceries = groceries[order(groceries$Customer),]
groceries = groceries[!(groceries$Goods==""),]
row.names(groceries) = 1:nrow(groceries)
groceries$Customer = factor(groceries$Customer)

groceries_list = split(x=groceries$Goods, f=groceries$Customer)
groceries_list = lapply(groceries_list, unique)
groceries_trans = as(groceries_list, "transactions")

# Run the 'apriori' algorithm.
gt = apriori(groceries_trans, 
                parameter=list(support=.01, confidence=.1, maxlen=2))
inspect(gt)
inspect(subset(gt, lift > 10 & confidence > 0.05))
plot(gt, measure = c("support", "lift"), shading = "confidence")
subs = subset(gt, subset=confidence > 0.01 & support > 0.005)
plot(head(subs, 45, by='lift'), method='graph')



