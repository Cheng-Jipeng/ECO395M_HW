library(RCurl)
library(tidyverse)
capmetro_UT = read.csv('https://raw.githubusercontent.com/Cheng-Jipeng/ECO395M/master/data/capmetro_UT.csv')
head(capmetro_UT)

capmetro_UT = mutate(capmetro_UT,
                     day_of_week = factor(day_of_week,
                     levels=c("Mon", "Tue", "Wed","Thu", "Fri", "Sat", "Sun")),
                     month = factor(month, levels=c("Sep", "Oct","Nov")))

avg_boarding = capmetro_UT %>%
  group_by(hour_of_day, day_of_week, month) %>%
  summarize(meanboarding = mean(boarding)) 
avg_boarding

ggplot(avg_boarding) +
  geom_line(aes(x = hour_of_day, y=meanboarding, color=month)) +
  facet_wrap(~day_of_week) +
  labs(title="Average boardings grouped by hour of the day, day of week, and month", y="mean boarding", x="hour of day")

# Comments
# Does the hour of peak boardings change from day to day, or is it broadly similar across days? 
# According to the graph, it shows that the hour of peak boardings do not change from day to day, and it broadly similar showing the peak hour at 15-17.

# Why do you think average boardings on Mondays in September look lower, compared to other days and months? 
# We can guess that there are less average boardings on September because the beginning of Fall semester. On the other hand, students may not prefer choosing the courses on Monday due to "Monday Blue".

# Similarly, why do you think average boardings on Weds/Thurs/Fri in November look lower?
# Average boardings on Weds/Thurs/Fri in November look lower because students may have to prepare for the midterm exam, they would like to stay home rather than go outside.


# graph2
avg_boarding_tem = capmetro_UT %>%
  group_by(temperature, hour_of_day,  weekend) %>%
  summarize(meanboarding = mean(boarding)) 
avg_boarding

ggplot(avg_boarding_tem) +
  geom_point(aes(x = temperature, y=meanboarding, color=weekend)) +
  facet_wrap(~hour_of_day) +
  labs(title="Average boardings grouped by temperature and week", y="mean boarding", x="temperature")

# When we hold hour of day and weekend status constant, does temperature seem to have a noticeable effect on the number of UT students riding the bus?
# According to above graph, temperature seem to have no noticeable effect on the number of UT students riding the bus.
