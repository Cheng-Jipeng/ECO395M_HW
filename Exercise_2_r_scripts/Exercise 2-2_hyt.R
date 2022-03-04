library(tidyverse)
library(ggplot2)
library(modelr)
library(rsample)
library(mosaic)
data(SaratogaHouses)

glimpse(SaratogaHouses)

# Split into training and testing sets
saratoga_split = initial_split(SaratogaHouses, prop = 0.8)
saratoga_train = training(saratoga_split)
saratoga_test = testing(saratoga_split)

# Question 1
lm1 = lm(price ~ lotSize + bedrooms + bathrooms, data=saratoga_train)
lm2 = lm(price ~ . - pctCollege - sewer - waterfront - landValue - newConstruction, data=saratoga_train)
lm3 = lm(price ~ (. - pctCollege - sewer - waterfront - landValue - newConstruction)^2, data=saratoga_train)
lm4 = lm(price ~  livingArea + centralAir + bathrooms + fuel + 
        lotSize + bedrooms + rooms + livingArea:centralAir + livingArea:bathrooms + 
        livingArea:fuel + livingArea:rooms + bathrooms:bedrooms + centralAir:fuel + 
        bathrooms:fuel + fuel:lotSize + centralAir:bathrooms +  bedrooms:rooms, data=saratoga_train)

coef(lm1) %>% round(0)
coef(lm2) %>% round(0)
coef(lm3) %>% round(0)
coef(lm4) %>% round(0)

# Predictions out of sample
# Root mean squared error
rmse(lm1, saratoga_test)
rmse(lm2, saratoga_test)
rmse(lm3, saratoga_test)
rmse(lm4, saratoga_test)

summary(lm4, data=SaratogaHouses)

#Question 2 - KNN
install.packages("kknn")
library(tidyverse)
library(ggplot2)
library(rsample)  
library(caret)
library(modelr)
library(parallel)
library(foreach)
library(ggpubr)
library(kknn)

lm_best = lm(formula = price ~ livingArea + centralAir + bathrooms + bedrooms + 
     lotSize + fuel + rooms, data = saratoga_train)
lm_best_knn = train.kknn(formula = as.formula(lm_best), data = SaratogaHouses, scale=TRUE)
lm_best_knn

K_folds = 5
k_grid = rep(1:125)
sh = SaratogaHouses 
sh_folds = crossv_kfold(sh, k = K_folds)
cv_sh = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sh_folds$train, ~ knnreg(price ~ livingArea + centralAir + bathrooms + bedrooms + 
                                          lotSize + fuel + rooms, data = saratoga_train, k=k, use.all=FALSE))
  errs = map2_dbl(models, sh_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

k_min_rmse_sh = cv_sh %>%
  slice_min(err) %>%
  pull(k)
k_min_rmse_sh
