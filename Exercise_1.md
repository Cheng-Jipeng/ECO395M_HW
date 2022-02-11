# Data visualization: flights at ABIA

## Worst Destination Airports

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

the sum of **# of major delayed flights** and **# of cancelled flights**
divided by the **# from AUS to Destination**,

where # refers to the number of flights.

The *yearly top 10 worst destination airports* of 2008 together with
their “Bad Index” are shown in Figure 1. **Newark airport** is the worst
airport given our rating system: the flights from Austin to Newark are
most likely to be delayed by over 30 minutes or cancelled. The second
follows **JFK airport** in New York. Considering that EWR also serves
The NYC Metropolitan Area, it seems that choosing **New York** as
destination is the real cause. Busy city and busy airports!
<img src="Exercise_1_files/figure-gfm/fig1-1.png" title="Figure 1: Top 10 Worst Destination of 2008" alt="Figure 1: Top 10 Worst Destination of 2008" style="display: block; margin: auto;" />

We can also visualize the top 10 airports on a U.S. map in Figure 2 with
blue bar refering to the values of their “Bad Index”.

<img src="Exercise_1_files/figure-gfm/fig2-1.png" title="Figure 2: Top 10 Worst Destination of 2008 on Map" alt="Figure 2: Top 10 Worst Destination of 2008 on Map" style="display: block; margin: auto;" />
If you are also interested in if there are many minor delays in these
bad flights, Figure 3 shows the proportions of all kinds of flights’
states. If *minor delays can annoy you very much too*, then you must
avoid choosing **Atlanta airport** as your destination among the top 10
worst airports.

<img src="Exercise_1_files/figure-gfm/fig3-1.png" title="Figure 3: Distribution of Delays in Top 10 Worst Destination of 2008" alt="Figure 3: Distribution of Delays in Top 10 Worst Destination of 2008" style="display: block; margin: auto;" />

Does the top list change over the months in 2008? Table 1 answers the
question in details by focusing on the top 5 worst airports in each
month. Definitely there are new blood across different months like
Boston airport in February, Ontario airport in April.

| Month | First | Second | Third | Fourth | Fifth |
|------:|:------|:-------|:------|:-------|:------|
|     1 | ORD   | CLE    | SFO   | EWR    | JAX   |
|     2 | BOS   | ORD    | JAX   | EWR    | STL   |
|     3 | EWR   | STL    | JFK   | ATL    | CLE   |
|     4 | ONT   | SEA    | EWR   | DFW    | JFK   |
|     5 | EWR   | MCI    | SJC   | OAK    | DFW   |
|     6 | EWR   | JFK    | OAK   | IAD    | ORD   |
|     7 | JFK   | OAK    | EWR   | ATL    | IAD   |
|     8 | JAX   | JFK    | EWR   | LGB    | OAK   |
|     9 | HOU   | JFK    | ORD   | EWR    | LGB   |
|    10 | TPA   | EWR    | HRL   | IAD    | ATL   |
|    11 | CVG   | TPA    | EWR   | MAF    | ATL   |
|    12 | LGB   | EWR    | MAF   | ATL    | IND   |

Table 1: Top 5 Worst Destinations across Months

A more sketchy way to capture the variability is counting how many time
airports occur in the monthly lists of top 5 worst. This is given by
Figure 4. There are 23 airports in all of the monthly lists, and this
also support our conclusion from yearly list: all 12 lists contains EWR
and 6 lists contains JFK.

<img src="Exercise_1_files/figure-gfm/fig4-1.png" title="Figure 4: Frequency of Appearances in Top 5 Worst Destinations across Months" alt="Figure 4: Frequency of Appearances in Top 5 Worst Destinations across Months" style="display: block; margin: auto;" />

## Best Month to Depart from AUS

According to the following graph, it shows that September has the lowest
delay rate in 2008.
<img src="Exercise_1_files/figure-gfm/fig5-1.png" title="Figure 5: Delay Rate by Month in 2008" alt="Figure 5: Delay Rate by Month in 2008" style="display: block; margin: auto;" />

# Wrangling the Billboard Top 100

## Part A

| Performer                                 | Song                                | Count |
|:------------------------------------------|:------------------------------------|------:|
| Imagine Dragons                           | Radioactive                         |    87 |
| AWOLNATION                                | Sail                                |    79 |
| Jason Mraz                                | I’m Yours                           |    76 |
| The Weeknd                                | Blinding Lights                     |    76 |
| LeAnn Rimes                               | How Do I Live                       |    69 |
| LMFAO Featuring Lauren Bennett & GoonRock | Party Rock Anthem                   |    68 |
| OneRepublic                               | Counting Stars                      |    68 |
| Adele                                     | Rolling In The Deep                 |    65 |
| Jewel                                     | Foolish Games/You Were Meant For Me |    65 |
| Carrie Underwood                          | Before He Cheats                    |    64 |

Table 2: Top 10 Most Popular Songs Since 1958

## Part B

<img src="Exercise_1_files/figure-gfm/fig6-1.png" title="Figure 6: Musical Diversity Over Time" alt="Figure 6: Musical Diversity Over Time" style="display: block; margin: auto;" />
## Part C
<img src="Exercise_1_files/figure-gfm/fig7-1.png" title="Figure 7: Artists Having over 30 Ten-Week-Hits Songs" alt="Figure 7: Artists Having over 30 Ten-Week-Hits Songs" style="display: block; margin: auto;" />

# Wrangling the Olympics

## Part A

    ##   q95_height
    ## 1        183

The 95th percentile of heights for female competitors across all
Athletics events is **183cm**.

## Part B

| Event                      | Height Variability |
|:---------------------------|-------------------:|
| Rowing Women’s Coxed Fours |           10.86549 |

It is shown that women’s coxed four rowing had the greatest variability
in competitor’s heights across the entire history of the Olympics.

## Part C

<img src="Exercise_1_files/figure-gfm/fig8-1.png" title="Figure 8: Increasing Trend of Age Similar Across Female and Male Swimmers' Age After Female Participation in Olympics" alt="Figure 8: Increasing Trend of Age Similar Across Female and Male Swimmers' Age After Female Participation in Olympics" style="display: block; margin: auto;" />

# K-nearest neighbors

<img src="Exercise_1_files/figure-gfm/fig9-1.png" title="Figure 9: RMSE vs. K" alt="Figure 9: RMSE vs. K" style="display: block; margin: auto;" />
Thus, the graphs show that the optimal K for predicting 350’s prices
with KNN method should be

    ## [1] 12

and the optimal K for predicting 65 AMG’s price with KNN method should
be

    ## [1] 10

given they yield the smallest RMSEs respectively.
<img src="Exercise_1_files/figure-gfm/fig10-1.png" title="Figure 10: Prediction vs. Testing Set" alt="Figure 10: Prediction vs. Testing Set" style="display: block; margin: auto;" />
The trim of 350 tends to yield a larger optimal value of K. This might
be because the sample size of 350’s is larger and allows a bigger K to
capture more information, reduce estimation bias, and avoid being
heavily affected by noises.
