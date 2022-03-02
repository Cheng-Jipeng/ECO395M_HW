setwd("~/OneDrive - The University of Texas at Austin/學習小札/2020 UTAustin/2022 Sp_Data Mining & Stat Learning/Homework2")
getwd()

capmetro_UT = read.csv('~/OneDrive - The University of Texas at Austin/學習小札/2020 UTAustin/2022 Sp_Data Mining & Stat Learning/Homework2/capmetro_UT.csv')
head(capmetro_UT)

capmetro_UT = mutate(capmetro_UT,
                     day_of_week = factor(day_of_week,
                     levels=c("Mon", "Tue", "Wed","Thu", "Fri", "Sat", "Sun")),
                     month = factor(month, levels=c("Sep", "Oct","Nov")))

avg_boarding = capmetro_UT %>%
  group_by(hour_of_day, day_of_week, month) %>%
  summarize(meanboarding = mean(boarding)) 
avg_boarding

week = mutute(capmetro_UT, weekdays = day_of_week == "Mon", "Tue", "Wed","Thu", "Fri", weekend = day_of_week == "Sat", "Sun")

ggplot(avg_boarding) +
  geom_line(aes(x = hour_of_day, y=meanboarding, color=month)) +
  facet_wrap(~day_of_week) +
  labs(title="Average boardings grouped by hour of the day, day of week, and month", y="mean boarding", x="hour of day")

head(capmetro_UT)

# graph2
avg_boarding_tem = capmetro_UT %>%
  group_by(temperature, hour_of_day,  weekend) %>%
  summarize(meanboarding = mean(boarding)) 
avg_boarding

ggplot(avg_boarding_tem) +
  geom_point(aes(x = temperature, y=meanboarding, color=weekend)) +
  facet_wrap(~hour_of_day) +
  labs(title="Average boardings grouped by temperature and week", y="mean boarding", x="temperature")
