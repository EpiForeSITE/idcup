

# Scaling analysis of measles outbreak simulations

While we can simulate outbreaks at the full population size, reducing
the scale to something that is computationally more manageable without
losing the key dynamics is plaussible. In our models, we are fixing the
population size to be approximately 1,000,000 agents. Things to consider
of the model implemented here are:

1.  **Contact rates**: The population size has no effect on the contact
    rates in our model. Instead of using mixing matrices, we use contact
    matrices, so the average number of contacts per person is the same
    regardless of the population size.

2.  **Depletion of susceptibles**: While in network models changes in
    network topology may lead to things like local depletion of
    susceptibles, in our model agents are not constrained by a network
    structure. Instead, agents in our model behave more as if they were
    in a well-mixed population.

The only potential risk of reducing the population size lies in groups
that may shrink too fast. The following table shows the adjusted
population size ranges per group for each city included in the project:

| city          | Population | Adjustment Scale | Min (true) | Min Adjusted |
|:--------------|:-----------|-----------------:|-----------:|-------------:|
| New York City | 8,478,072  |             0.12 |      12370 |         1459 |
| Los Angeles   | 3,878,704  |             0.26 |      24480 |         6311 |
| Houston       | 2,390,125  |             0.42 |       4431 |         1854 |
| Philadelphia  | 1,573,916  |             0.64 |       1422 |          903 |
| Dallas        | 1,326,087  |             0.75 |       1367 |         1031 |
| Atlanta       | 520,070    |             1.00 |        260 |          260 |
| Boston        | 673,458    |             1.00 |        299 |          299 |
| Kansas City   | 516,032    |             1.00 |        223 |          223 |
| Miami         | 487,014    |             1.00 |       1046 |         1046 |
| San Francisco | 827,526    |             1.00 |        508 |          508 |
| Seattle       | 780,995    |             1.00 |       1002 |         1002 |

Adjusted smallest population sizes per group for each city included in
the project when scaling down to 1,000,000 agents.

Of the cities included in the project, the one that is most affected by
the scaling is New York. The smallest group goes from 12,370 to 730; a
downscaling of about 16 times. Nonetheless, as we present below, in a
downscaling of 20 times, with a group that moved from 10,000 to 500, we
did not see any significant changes in the outbreak dynamics. This gives
us confidence that the scaling down to 1,000,000 agents is not likely to
affect the results of our simulations.

## Some results from scaling analyses

To validate the performance of the model when changing the scale, we
conducted a simulation study in which we only changed the population
size. Each one of the 2,000 simulations used the same parameters:

- Five different groups of different sizes.
- The population was distributed according to the following vector
  `[0.05, 0.09, 0.16, 0.28, 0.42]` (from a very small to a very large
  group).
- Each simulation featured a single importation of Measles.
- We ran the simulations for 90 days.
- The simulations were calibrated to an R0 of 8. Higher R0s usually
  result in more stochasticity.
- The vaccination rate was 90%

The following table shows some key statistics from the 2,000 x 4 runs:

| Population Size | Mean Index Case Rt | Mean Outbreak Size (SD) | P(\>5) | P(\>10) | P(\>20) | P(\>50) | P(\>100) |
|----|----|----|----|----|----|----|----|
| 10,000 | 1.078 | 3.88 (6.30) | 0.172 | 0.086 | 0.031 | 0.003 | 0.000 |
| 50,000 | 1.050 | 4.02 (7.43) | 0.170 | 0.085 | 0.030 | 0.006 | 0.000 |
| 100,000 | 1.132 | 4.38 (8.16) | 0.186 | 0.091 | 0.039 | 0.005 | 0.001 |
| 200,000 | 1.072 | 4.01 (7.02) | 0.171 | 0.085 | 0.034 | 0.004 | 0.001 |

The Mean Outbreak Size stays within 3.88 and 4.01. Mean Index Case Rt
has an even narrower range between 1.05 and 1.13. And finally, looking
at the outbreaj size probabilities, we can see hat the ranges are mostly
consistent across population sizes. None of the measured statistics seem
to be associated with population size.
