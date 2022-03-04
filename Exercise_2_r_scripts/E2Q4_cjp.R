library(RCurl)
library(tidyverse)
library(mosaic)
library(ggplot2)
library(gamlr)
library(rsample)
library(modelr)
library(parallel)
library(foreach)

# Read in data
hotel_dev = read.csv("https://raw.githubusercontent.com/Cheng-Jipeng/ECO395M/master/data/hotels_dev.csv")
hotel_val = read.csv("https://raw.githubusercontent.com/Cheng-Jipeng/ECO395M/master/data/hotels_val.csv")
hotel_dev = hotel_dev %>% filter(reserved_room_type != "L") 
#// Because of no corresponding data points in hotel_val.csv, see DEBUG at the end for more details.
# Data browsing
ggplot(data = hotel_dev) +
  geom_histogram(aes(x=children), binwidth=0.5)

#####
# 1. Model building
#####
hotel_dev_split = initial_split(hotel_dev, prop = 0.8)
hotel_dev_train = training(hotel_dev_split)
hotel_dev_test = testing(hotel_dev_split)
## (1) Build baseline models
baseline1 = glm(children ~ market_segment + adults + customer_type + is_repeated_guest,
                data = hotel_dev_train, family = "binomial")
baseline2 = glm(children ~ . - arrival_date , data = hotel_dev_train, family = "binomial")
## (2) Build best model - Feature engineering with LASSO 
#//idea: use LASSO to find main effects + interaction by eyeballing
hotel_lasso_x_main = model.matrix(children ~  (.-1-arrival_date), data=hotel_dev_train)
hotel_lasso_x_itac = model.matrix(children ~  (.-1-arrival_date)^2, data=hotel_dev_train)
hotel_lasso_y = hotel_dev_train$children
#//see https://cran.r-project.org/web/packages/gamlr/gamlr.pdf to see more
hotel_lasso_main = cv.gamlr(hotel_lasso_x_main, hotel_lasso_y, nfold=10, verb=TRUE, family="binomial")
hotel_lasso_itac = cv.gamlr(hotel_lasso_x_itac, hotel_lasso_y, nfold=10, verb=TRUE, family="binomial")
#### extract strong single covariates
coef(hotel_lasso_main, select='min') #// rule out 'deposit_type' by eyeballing
#### extract strong interactions
strong_interaction_name = coef(hotel_lasso_itac, select = 'min')@Dimnames[1] %>% as.data.frame() 
strong_interaction_name = strong_interaction_name[coef(hotel_lasso_itac, select = 'min')@i,] 
strong_interaction_beta = coef(hotel_lasso_itac, select = 'min')@x[-1]
coef_lasso = cbind(strong_interaction_name, strong_interaction_beta) %>% # transform matrix to dataframe
  as.data.frame() %>%
  mutate(abs_beta = abs(as.numeric(strong_interaction_beta))) 
coef_lasso %>% # filter in strong interaction
  filter(!(strong_interaction_name %in% colnames(hotel_dev))) %>%
  arrange(desc(abs_beta)) %>%
  head(30) 
#// pick (meal:reserved_room_type, reserved_room_type:assigned_room_type, hotel:reserved_room_type, market_segment:reserved_room_type,
#// meal:is_repeated_guest, adults:previous_bookings_not_canceled, meal:previous_bookings_not_canceled, market_segment:customer_type,
#// is_repeated_guest:assigned_room_type, assigned_room_type:required_car_parking_spaces) by eyeballing
lasso_selected_try = glm(children ~ (.-arrival_date-deposit_type) + meal:reserved_room_type+ reserved_room_type:assigned_room_type+
                           hotel:reserved_room_type+ market_segment:reserved_room_type+meal:is_repeated_guest+ 
                           adults:previous_bookings_not_canceled+ meal:previous_bookings_not_canceled+ market_segment:customer_type+
                           is_repeated_guest:assigned_room_type+ assigned_room_type:required_car_parking_spaces, 
                         data = hotel_dev_train, family = "binomial")
coef(lasso_selected_try) # rule out non-converged covariates & interactions
lasso_selected = glm(children ~ (.-arrival_date-deposit_type) + hotel:reserved_room_type+ meal:is_repeated_guest+ 
                           adults:previous_bookings_not_canceled+ meal:previous_bookings_not_canceled+ market_segment:customer_type+
                           is_repeated_guest:assigned_room_type+ assigned_room_type:required_car_parking_spaces, 
                         data = hotel_dev_train, family = "binomial")
## (3) Out-of-sample performance evaluation: likelihood/deviance/TPR/FPR/FDR
### baseline evaluation
#### calculate deviance
test_child_index = which(hotel_dev_test$children == 1) # find true book with children
phat_baseline1 = predict(baseline1, hotel_dev_test, type = "response") # baseline1
baseline1_predict_deviance = -2 * sum(log(phat_baseline1[test_child_index]))
phat_baseline2 = predict(baseline2, hotel_dev_test, type = "response") # baseline2
baseline2_predict_deviance = -2 * sum(log(phat_baseline2[test_child_index]))
phat_lasso_selected = predict(lasso_selected, hotel_dev_test, type = "response") # lasso_selected
lasso_selected_predict_deviance = -2 * sum(log(phat_lasso_selected[test_child_index]))
#### confusion matrix + relevant evaluation
yhat_baseline1 = ifelse(phat_baseline1>0.5, 1, 0)
yhat_baseline2 = ifelse(phat_baseline2>0.5, 1, 0)
yhat_lasso_selected = ifelse(phat_lasso_selected>0.5, 1, 0)
confusion_baseline1 = table(y=hotel_dev_test$children, yhat=yhat_baseline1)
confusion_baseline1 = cbind(confusion_baseline1, c(0,0))
confusion_baseline2 = table(y=hotel_dev_test$children, yhat=yhat_baseline2)
confusion_lasso_selected = table(y=hotel_dev_test$children, yhat=yhat_lasso_selected)

## (4) Output: a table of measuring out-of-sample performance
measurement = c("Deviance", "TPR", "FPR", "FDR")
eval_baseline1 = c(baseline1_predict_deviance,
      confusion_baseline1[2,2]/(confusion_baseline1[2,2]+confusion_baseline1[2,1]),
      confusion_baseline1[1,2]/(confusion_baseline1[1,1]+confusion_baseline1[1,2]),
      confusion_baseline1[1,2]/(confusion_baseline1[1,2]+confusion_baseline1[2,2])) %>% round(3)
eval_baseline2 = c(baseline2_predict_deviance,
      confusion_baseline2[2,2]/(confusion_baseline2[2,2]+confusion_baseline2[2,1]),
      confusion_baseline2[1,2]/(confusion_baseline2[1,1]+confusion_baseline2[1,2]),
      confusion_baseline2[1,2]/(confusion_baseline2[1,2]+confusion_baseline2[2,2])) %>% round(3)
eval_lasso_selected = c(lasso_selected_predict_deviance,
                        confusion_lasso_selected[2,2]/(confusion_lasso_selected[2,2]+confusion_lasso_selected[2,1]),
                        confusion_lasso_selected[1,2]/(confusion_lasso_selected[1,1]+confusion_lasso_selected[1,2]),
                        confusion_lasso_selected[1,2]/(confusion_lasso_selected[1,2]+confusion_lasso_selected[2,2])) %>% round(3)
rbind(measurement, eval_baseline1, eval_baseline2, eval_lasso_selected)

#####
# 2. Model Validation: Step 1
#####
## (1) Preidcition with validation set
phat_lasso_predict_best = predict(lasso_selected, hotel_val, type = "response")
## (2) Calculate TPR & FPR vs. t
t_grid = rep(1:49)/50
ROC_df = foreach(t = t_grid, .combine='rbind') %dopar% {
  yhat_best = ifelse(phat_lasso_predict_best > t, 1, 0)
  confusion_best = table(y=hotel_val$children, yhat=yhat_best)
  TPR_best = confusion_best[2,2]/(confusion_best[2,2]+confusion_best[2,1]) %>% round(3)
  FPR_best = confusion_best[1,2]/(confusion_best[1,1]+confusion_best[1,2]) %>% round(3)
  c(t=t, TPR = TPR_best, FPR = FPR_best)
} %>% as.data.frame()
## (3) Plot the graph
ggplot(ROC_df) +
  geom_line(aes(x=t, y=TPR, color = "TPR"), size=1) +
  geom_line(aes(x=t, y=FPR, color = "FPR"), size=1) +
  labs(y="TPR/FPR", x = "t", color=" ")
#####
# 3. Model Validation: Step 2
#####
K_folds = 20

hotel_val = hotel_val %>%
  mutate(fold_id = rep(1:K_folds, length=nrow(hotel_val)) %>% sample)

hotel_val_cv = foreach(fold = 1:K_folds, .combine='rbind') %dopar% {
  hotel_val_folds_train = filter(hotel_val, fold_id == fold)
  hotel_val_folds_phat = predict(lasso_selected, hotel_val_folds_train, type = "response")
  c(y=sum(hotel_val_folds_train$children), E_y=sum(hotel_val_folds_phat)%>%round(0))
} %>% as.data.frame()

hotel_val_cv = hotel_val_cv %>%
  arrange(y) %>%
  mutate(fold_id = rep(1:K_folds))

ggplot(data = hotel_val_cv) +
  geom_line(aes(x=fold_id, y=y, color = "Actual # of children"),  size=1) +
  geom_line(aes(x=fold_id, y=E_y, color = "Predicted # of children"), size=1) +
  labs(y="Predicted / Actual Children for Each Fold", x = "t", color=" ")+
  geom_point(aes(x=fold_id, y=y)) +
  geom_point(aes(x=fold_id, y=E_y))
