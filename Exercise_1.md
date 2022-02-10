# Data visualization: flights at ABIA

What are the bad airports to fly to if you want to depart from Austin?
We measure how “bad” these airports are with the proportion of delayed
or cancelled flights. Four levels of flights’ states are defined as:

-   On time: no delays
-   Minor delay: arrival delay \< 30 mins
-   Major delay: arrival delay > 30 min
-   Cancelled: flights being cancelled

Personally, we focus on flights being cancelled or with arrival delays
larger than 30 minutes, which are extremely annoying to travelers. The
“Bad Index” with which we rate destination airports are formally given
by
$$
\\text{Bad Index}\_{\\text{Destination}} = \\frac{\\text{# of major delay + # of cancelled}}{\\text{# from AUS to Destination}},
$$
where \# refers to the number of flights.

The *yearly top 10 worst destination airports* of 2008 together with
their “Bad Index” are shown in Figure @ref(fig:fig1). **Newark airport**
is the worst airport given our rating system: the flights from Austin to
Newark are most likely to be delayed by over 30 minutes or cancelled.
The second follows **JFK airport** in New York. Considering that EWR
also serves The NYC Metropolitan Area, it seems that choosing **New
York** as destination is the real cause. Busy city and busy airports!

``` r
# Remember to reset working directory
library(tidyverse)
library(mosaic)
library(dplyr)
library(stringr)
library(data.table)
library(lubridate)
library(ggplot2)
abia = read.csv("/Users/jipengcheng/Library/Mobile Documents/com~apple~CloudDocs/【MA】Course/Sp_Data Mining/ECO395M/data/ABIA.csv")

# Plot column graph of Bad Index vs. Top 10 worst destination
bad_airports_top10 = abia %>%
  filter(Origin == "AUS") %>%
  group_by(Dest) %>%
  summarize(cancelled = sum(Cancelled, na.rm=TRUE),
            major_delay = sum(ArrDelay > 30, na.rm=TRUE),
            cancel_ratio = sum(Cancelled, na.rm=TRUE)/n(),
            major_delay_ratio = sum(ArrDelay > 30, na.rm=TRUE)/n(),
            entry_count = n()) %>%
  mutate(bad_count = cancelled + major_delay,
         bad_ratio = cancel_ratio + major_delay_ratio) %>%
  filter(bad_count > 1) %>%
  arrange(desc(bad_ratio)) %>%
  head(10)

bad_airports_top10 %>%
  ggplot(aes(fct_reorder(Dest, -bad_ratio),
             bad_ratio))+
  geom_col() +
  labs(y = "Bad Index", x= "Destination Airports")
```

<div class="figure" style="text-align: center">

<img src="Exercise_1_files/figure-markdown_github/fig1-1.png" alt="Top 10 Worst Destination of 2008"  />
<p class="caption">
Top 10 Worst Destination of 2008
</p>

</div>
