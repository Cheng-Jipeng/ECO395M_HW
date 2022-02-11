library(tidyverse)
library(ggplot2)
library(rsample)  
library(caret)
library(modelr)
library(parallel)
library(foreach)
library(ggpubr)

setwd("/Users/jipengcheng/Library/Mobile Documents/com~apple~CloudDocs/【MA】Course/Sp_Data Mining/ECO395M/data")
sclass = read.csv("sclass.csv")
K_folds = 5
k_grid = rep(1:125)
# For trim = 350
sclass_350 = sclass %>% filter(trim == "350")
sclass_350_folds = crossv_kfold(sclass_350, k=K_folds)
cv_grid_350 = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sclass_350_folds$train, ~ knnreg(price ~ mileage, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, sclass_350_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

k_min_rmse_350 = cv_grid_350 %>%
  slice_min(err) %>%
  pull(k)
  
k_plot_350 = ggplot(cv_grid_350) +
  geom_point(aes(x = k, y = err)) +
  geom_errorbar(aes(x = k, ymin = err-std_err, ymax = err+std_err)) + 
  geom_vline(aes(xintercept = k_min_rmse_350))
## predictions vs. x
sclass_350_split = initial_split(sclass_350, prop = 0.8)
sclass_350_train = training(sclass_350_split)
sclass_350_test = testing(sclass_350_split)
knn_optimal_350 = knnreg(price ~ mileage, data = sclass_350_train, k = k_min_rmse_350)
pred_vs_x_350= sclass_350_test %>%
  mutate(price_predict = predict(knn_optimal_350, sclass_350_test)) %>%
  ggplot()+
  geom_point(aes(x=mileage, y=price))+
  geom_line(aes(x=mileage, y=price_predict))


# For trim = 65
sclass_65= sclass %>% filter(trim == "65 AMG")
sclass_65_folds = crossv_kfold(sclass_65, k=K_folds)
cv_grid_65 = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sclass_65_folds$train, ~ knnreg(price ~ mileage, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, sclass_65_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

k_min_rmse_65 = cv_grid_65 %>%
  slice_min(err) %>%
  pull(k)

k_plot_65 = ggplot(cv_grid_65) +
  geom_point(aes(x = k, y = err)) +
  geom_errorbar(aes(x = k, ymin = err-std_err, ymax = err+std_err))
## predictions vs. x
sclass_65_split = initial_split(sclass_65, prop = 0.8)
sclass_65_train = training(sclass_65_split)
sclass_65_test = testing(sclass_65_split)
knn_optimal_65 = knnreg(price ~ mileage, data = sclass_65_train, k = k_min_rmse_65)
pred_vs_x_65 = sclass_65_test %>%
  mutate(price_predict = predict(knn_optimal_65, sclass_65_test)) %>%
  ggplot()+
  geom_point(aes(x=mileage, y=price))+
  geom_line(aes(x=mileage, y=price_predict))

# Combine multiple plots
ggarrange(k_plot_350, k_plot_65, 
          ncol = 1, nrow = 2)

ggarrange(pred_vs_x_350, pred_vs_x_65, 
          ncol = 1, nrow = 2)



############################### Supplemental Codes ###############################
sclass_350 %>%
  ggplot() +
  geom_point(aes(mileage, price))

sclass_65 %>%
  ggplot() +
  geom_point(aes(mileage, price))



