library(tidyverse)
library(ggplot2)
library(modelr)
library(rsample)
library(mosaic)
library(caret)
library(parallel)
library(foreach)
library(ggpubr)
library(kknn)
data(SaratogaHouses)

# Split into training and testing sets with K folds
K_folds = 5
sh_folds = crossv_kfold(SaratogaHouses, k = K_folds)
# Question 1
lm1 = map(sh_folds$train, ~ lm(price ~ lotSize + bedrooms + bathrooms, data=. ))
lm2 = map(sh_folds$train, ~ lm(price ~ . - pctCollege - sewer - waterfront - landValue - newConstruction,
                               data=. ))
lm3 = map(sh_folds$train, ~ lm(price ~ (. - pctCollege - sewer - waterfront - landValue - newConstruction)^2,
                               data=. ))
lm4 = map(sh_folds$train, ~ lm(price ~ livingArea + centralAir + bathrooms + fuel + 
                                 lotSize + bedrooms + rooms + livingArea:centralAir + livingArea:bathrooms + 
                                 livingArea:fuel + livingArea:rooms + bathrooms:bedrooms + centralAir:fuel + 
                                 bathrooms:fuel + fuel:lotSize + centralAir:bathrooms +  bedrooms:rooms, data=. ))

errs_lm1 = map2_dbl(lm1, sh_folds$test, modelr::rmse)
errs_lm2 = map2_dbl(lm2, sh_folds$test, modelr::rmse)
errs_lm3 = map2_dbl(lm3, sh_folds$test, modelr::rmse)
errs_lm4 = map2_dbl(lm4, sh_folds$test, modelr::rmse)
# Predictions out of sample
# Root Mean squared error
c(errs_lm1 = mean(errs_lm1), errs_lm2= mean(errs_lm2), errs_lm3 = mean(errs_lm3), errs_lm4 =  mean(errs_lm4))
#// The result suggests that lm4 is the best

#Question 2 - KNN
#// idea: We will find optimal k and features simultaneously
## Features from lm1
k_grid = rep(1:125)
cv_sh_knn1 = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sh_folds$train, ~ knnreg(price ~ lotSize + bedrooms + bathrooms,
                                        data = ., k=k, use.all=FALSE))
  errs = map2_dbl(models, sh_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

k_min_rmse_sh1 = cv_sh_knn1 %>%
  slice_min(err) %>%
  pull(k)
cv_sh_knn1_err = cv_sh_knn1 %>% filter(k==k_min_rmse_sh1)
## Features from lm2 & lm3
cv_sh_knn2 = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sh_folds$train, ~ knnreg(price ~ (. - pctCollege - sewer - waterfront - landValue - newConstruction)
                                        , data = ., k=k, use.all=FALSE))
  errs = map2_dbl(models, sh_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

k_min_rmse_sh2 = cv_sh_knn2 %>%
  slice_min(err) %>%
  pull(k)
cv_sh_knn2_err = cv_sh_knn2 %>% filter(k==k_min_rmse_sh2)
## Features from lm4
cv_sh_knn3 = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sh_folds$train, ~ knnreg(price ~ livingArea + centralAir + bathrooms + bedrooms + 
                                          lotSize + fuel + rooms
                                        , data = ., k=k, use.all=FALSE))
  errs = map2_dbl(models, sh_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

k_min_rmse_sh3= cv_sh_knn3 %>%
  slice_min(err) %>%
  pull(k)
cv_sh_knn3_err = cv_sh_knn3 %>% filter(k==k_min_rmse_sh3)
## Cross-validation OOS Performance Errors for KNN
rbind(knn1 = cv_sh_knn1_err,knn2 = cv_sh_knn2_err, knn3 = cv_sh_knn3_err)
## To .Rmd writer: You may write some codes to incorporate these 2 results since we are required to compared KNN results
## with linear regression results.

# XDD
