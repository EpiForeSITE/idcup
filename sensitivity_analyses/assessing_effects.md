

# What are the relevant effects of the World Cup?

The 2026 World Cup will result in a large number of both international
and local visitors to the host cities. Current estimates place the
number of international visitors at around 742,000 additional visitors
(Society 2026).

On average, a single international visitor to the World Cup is expected
to attend 2 matches and stay for about 14 days (Airbnb 2026). Assuming a
uniform distribution of the matches across the matches, we should expect
to see an influx like the following

| city          | N matches | Delta (thousands) |
|:--------------|----------:|------------------:|
| Kansas City   |         6 |            114.15 |
| Dallas        |         9 |            171.23 |
| Boston        |         7 |            133.18 |
| Miami         |         7 |            133.18 |
| San Francisco |         6 |            114.15 |
| Philadelphia  |         6 |            114.15 |
| Seattle       |         6 |            114.15 |
| Atlanta       |         8 |            152.21 |
| New York City |         8 |            152.21 |
| Houston       |         7 |            133.18 |
| Los Angeles   |         8 |            152.21 |
| Total         |        78 |           1484.00 |

Estimated number of international visitors in each host city. The
‘Delta’ column assumes individuals will not visit the same city for
multiple matches, and that each visitor will attend 2 matches on
average.

According to AirBnB (Airbnb 2026), the two-night stay is the most common
booking, suggesting that many fans will attend a single match within a
single city. However, the average stay of 14 days suggests that many
fans will attend multiple matches across multiple cities. The actual
distribution of match attendance and city visits is likely to be complex
and may vary widely among different groups of fans.

If we take the previous table and combine it with the population sizes,
we can get a rough estimate of the percentage increase in population for
each city during the World Cup:

| city | Population | N matches | Population increase (%) | Population increase (%) per match |
|:---|---:|---:|---:|---:|
| Atlanta | 520070 | 8 | 29.27 | 3.66 |
| Boston | 673458 | 7 | 19.78 | 2.83 |
| Dallas | 1326087 | 9 | 12.91 | 1.43 |
| Houston | 2390125 | 7 | 5.57 | 0.80 |
| Kansas City | 516032 | 6 | 22.12 | 3.69 |
| Los Angeles | 3878704 | 8 | 3.92 | 0.49 |
| Miami | 487014 | 7 | 27.35 | 3.91 |
| New York City | 8478072 | 8 | 1.80 | 0.22 |
| Philadelphia | 1573916 | 6 | 7.25 | 1.21 |
| San Francisco | 827526 | 6 | 13.79 | 2.30 |
| Seattle | 780995 | 6 | 14.62 | 2.44 |

Estimated percentage increase in population for each host city during
the World Cup. This is calculated by dividing the estimated number of
international visitors (Delta) by the city’s population.

While the overall influx can be substantial, if we consider the increase
on a per-match basis, the percentage increase in population for each
city is much smaller. From the epidemiological perspective, the
per-match increase is more relevant for understanding the potential
impact on disease transmission.

Within our model, since we are not changing the mixing matrix (people
will still mix with the same age groups), the main effect may be
reflected in the variance of the contact rates. For example, in the case
of Miami, which expects a 3.91% increase in population per match, given
an average contact rate of 11.6869384, the variance would increase from
11.68666 to 11.68667, which is an increase close to zero. This is also
consistent with the fact that for small probabilities, the Binomial
distribution can be approximated by a Poisson distribution, where the
variance is equal to the mean.

Therefore, from the perspective of disease transmission, the biggest
risk may not be the increase in population size itself, but rather the
introduction of infectious individuals from other regions or cities
within the US. Using this as a starting point, we will focus our
sensitivity analyses on the potential effects of increased importation
of cases, rather than the increase in population size.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-airbnbFIFAWorldCup2026" class="csl-entry">

Airbnb. 2026. “FIFA World Cup 2026™ Travel Trends, Revealed.” In *Airbnb
Newsroom*.
<https://news.airbnb.com/fifa-world-cup-2026-travel-trends-revealed/>.

</div>

<div id="ref-societyLargestWorldCup2026" class="csl-entry">

Society, Funds. 2026. “The Largest World Cup in History and Its Economic
Impacts in the U.S.” In *Funds Society*.
<https://www.fundssociety.com/en/style/the-largest-world-cup-in-history-and-its-economic-impacts-in-the-u-s/>.

</div>

</div>
