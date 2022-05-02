library(RCurl)
library(tidyverse)
library(mosaic)
library(LICORS)  # for kmeans++
library(ggplot2)
library(ggpubr)
library(reshape2) # stack data by PC

# Read data #
wine_original = read.csv("https://raw.githubusercontent.com/Cheng-Jipeng/ECO395M/master/data/wine.csv")
wine = wine_original %>% 
  select(-quality,-color) %>% 
  scale(center=TRUE, scale=TRUE) # standardize data


# Clustering #
## Kmean++
wine_clust_color = kmeanspp(wine, k=2, nstart=25)
#unique(wine_original$quality)
wine_clust_quality = kmeanspp(wine, k=7, nstart=25)
wine_results = data.frame(wine, color = wine_original$color, 
                          quality = wine_original$quality,
                          clust_color = wine_clust_color$cluster,
                          clust_quality = wine_clust_quality$cluster)


# Clustering Assessment #
## Color ##
### Data visualization
wine_plot_data_clust = cbind(wine_results[12:15], stack(wine_results[1:11]))
ggplot(wine_plot_data_clust) +
  geom_boxplot(aes(x=color, y=values)) +
  facet_wrap(~ind, ncol=3) +
  labs(y = "Value of Chemicals",
       x="Actual Color")# mostly differed by va and tsd
### Labels emerge naturally from clustering
# refernce: 【7.1】cars.R
ggplot(wine_results) + 
  geom_point(aes(x=volatile.acidity, y=total.sulfur.dioxide,
                 col=factor(clust_color))) +
  labs(color='Generated\nCluster') 
ggplot(wine_results) + 
  geom_point(aes(x=volatile.acidity, y=total.sulfur.dioxide,
                 col=factor(color))) +
  labs(color='Actual\nColor')
### Compare cluster and labels
confusion_color = table(y=wine_results$color, yhat=wine_results$clust_color)
confusion_color[2:1,]


## Quality ##
### Data visualization
ggplot(wine_plot_data_clust) +
  geom_boxplot(aes(x=factor(quality), y=values)) +
  facet_wrap(~ind, ncol=3) +
  labs(y = "Value of Chemicals", x="Actual Quality")

wine_plot_data_clust %>%
  group_by(quality, ind) %>%
  summarise(median_feature = median(values)) %>%
  ggplot() +
  geom_point(aes(x=factor(quality), y=median_feature)) +
  facet_wrap(~ind, ncol=3) +
  labs(y = "Median Value of Chemicals",
       x="Actual Quality")# mostly differed by chlo and dens, ca and fsd
### Labels emerge naturally from clustering
#### clustering labels 
clust_1 = ggplot(wine_results) + 
  geom_point(aes(x=density, y=alcohol,
                 col=factor(clust_quality))) +
  labs(color="Generated\nCluster")
clust_2 = ggplot(wine_results) + 
  geom_point(aes(x=volatile.acidity, y=free.sulfur.dioxide,
                 col=factor(clust_quality))) +
  labs(color="Generated\nCluster")
clust_3 = ggplot(wine_results) + 
  geom_point(aes(x=density, y=free.sulfur.dioxide,
                 col=factor(clust_quality))) +
  labs(color="Generated\nCluster")
clust_4 = ggplot(wine_results) + 
  geom_point(aes(x=alcohol, y=free.sulfur.dioxide,
                 col=factor(clust_quality))) +
  labs(color="Generated\nCluster")
ggarrange(clust_1, clust_2, clust_3, clust_4, 
          ncol = 2, nrow=2, common.legend = TRUE,
          legend = "right") 
############################################################
# However, if we care about the precision of the clustering, 
# the true differences among wines are not accurately captured.
# Especially, we cannot match the generated clustered with
# the true groups as we did for color clustering. This suggests
# that the actual quality clusters of points are not convex.
############################################################
#### orginal label
clust_11 = ggplot(wine_results) + 
  geom_point(aes(x=density, y=alcohol,
                 col=factor(quality))) +
  labs(color="Actual\nQuality")
clust_22 = ggplot(wine_results) + 
  geom_point(aes(x=volatile.acidity, y=free.sulfur.dioxide,
                 col=factor(quality)))  +
  labs(color="Actual\nQuality")
clust_33 = ggplot(wine_results) + 
  geom_point(aes(x=density, y=free.sulfur.dioxide,
                 col=factor(quality)))  +
  labs(color="Actual\nQuality")
clust_44 = ggplot(wine_results) + 
  geom_point(aes(x=alcohol, y=free.sulfur.dioxide,
                 col=factor(quality))) +
  labs(color="Actual\nQuality")
ggarrange(clust_11, clust_22, clust_33, clust_44, 
          ncol = 2, nrow=2, common.legend = TRUE,
          legend = "right") 
############################################################
# The failure of quality clustering can be confirmed again by 
# comparing the actual number of each group and the number of wines  
# in each predicted clusters. If the clusters are capable of 
# classifying the seven levels quality, then the distribution 
# of wine numbers among clusters should look similar to the 
# one among true quality groups. Fig. shows the distribution 
# are different and thus clustering algorithms cannot 
# distinguish higher from the lower quality wines.
############################################################
### distribution 
clust_5 = wine_results %>%
  group_by(quality) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = reorder(factor(quality),(-count)), y = count)) + 
  geom_bar(stat = 'identity') +
  xlab("Actual Quality") +
  ylab("Count")+
  ylim(0,3000)
clust_6 = wine_results %>%
  group_by(clust_quality) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = reorder(factor(clust_quality),(-count)), y = count)) + 
  geom_bar(stat = 'identity') +
  xlab("Predicted Clusters") +
  ylim(0,3000) 
ggarrange(clust_5, clust_6+rremove("ylab"), ncol = 2, nrow=1) 

# Principal Component Analysis #
############################################################
# Next, we consider PCA to see if there are some principal components
# that can distinguish the reds from the whites, or distinguish wines
# of different quality. Before that, we would like to take a look at
# the heatmap Fig. , which shows that there exist some correlated features
# that might be able to summarized by some principal components, 
# like `residual.sugar`, `total.sulfur.dioxide`, and `free.sulfur.dioxide`.
############################################################
ggcorrplot::ggcorrplot(cor(wine), hc.order = TRUE)
############################################################
# The results of PCA show that the first two components can account for
# about half of the variations. 
############################################################
wine_PCA = prcomp(wine, rank=11)
summary(wine_PCA)
wine_loadings = wine_PCA$rotation %>%
  as.data.frame %>%
  rownames_to_column('features')
wine_scores = wine_PCA$x %>%
  as.data.frame() %>%
  rownames_to_column('wine_code')
wine_results = wine_results %>% rownames_to_column('wine_code')
## color ##
wine_results = merge(wine_results, wine_scores, by = 'wine_code') 
wine_plot_data_pca = melt(wine_results, id.var = colnames(wine_results)[1:16],
                          variable.name = 'PC')
############################################################
# The preliminary visualization has indicated the significant
# differences in principal component 1 between red wines and 
# white wines. 
############################################################
ggplot(wine_plot_data_pca) +
  geom_boxplot(aes(x=color, y=value)) +
  facet_wrap(~PC) +
  labs(y = "Value of Principal Components",
       x="Actual Color")
### Groups emerge naturally from PCA
############################################################
# Fig. further confirmed that we can distinguish the reds from
# the whites using principal component 1: `PC1`'s scores tend to 
# higher on the whites than on the reds.
############################################################
ggplot(wine_results) +
  geom_point(aes(x=PC1, y=PC2, color=factor(color))) +
  labs(y = "Principal Component 2", x="Principal Component 1",
       color='Acutal Color') 
## quality ##
### Distributions of scores over quality
# Should look at the scores, i.e. go wine by wine or quality by quality
# what the first summary of these scores over quality?
# reference: 【8.4】ercot_PCA.R
############################################################
# Fig. shows that there is no principal components that can significantly
# differ wines of different quality.
############################################################
ggplot(wine_plot_data_pca) +
  geom_boxplot(aes(x=factor(quality), y=value)) +
  facet_wrap(~PC) +
  labs(y = "Value of Principal Components",
       x="Actual Quality")
############################################################
# However, Fig. shows that principal component 2 and 
# principal component 3 would decrease with quality on average.
############################################################
wine_plot_data_pca %>%
  group_by(quality, PC) %>%
  summarise(median_feature = median(value)) %>%
  ggplot() +
  geom_point(aes(x=factor(quality), y=median_feature)) +
  facet_wrap(~PC, ncol=3)+
  labs(y = "Median Value of Principal Components",
       x="Actual Quality") # most differed by PC2 and PC3
############################################################
# Fig. shows that wines of high quality tend to have less
# principal component 2 and vice versa. But the pattern
# is not very clear and may not able to classify quality
# very well.
############################################################
ggplot(wine_results) +
  geom_point(aes(x=PC2, y=PC3, color=factor(quality))) +
  labs(y = "Principal Component 3", x="Principal Component 2",
       color='Acutal Quality') 








