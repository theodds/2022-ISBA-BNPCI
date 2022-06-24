# 2022-ISBA-BNPCI
Github repo for the BNP Causal Inference short course.

- `BART-Illustration.R` illustrates the BART methodology in a non-causal setting, using the `dbarts` package.

- `BCF-Meps.R` implements the Bayesian Causal Forest of [Hahn et al.](https://projecteuclid.org/journals/bayesian-analysis/volume-15/issue-3/Bayesian-Regression-Tree-Models-for-Causal-Inference--Regularization-Confounding/10.1214/19-BA1195.pdf), illustrating on the Medical Expenditure Panel Survey (MEPS) to approximate the average causal effect of smoking on total medical expenditures.

- `BCMF-Meps.R` implements a Bayesian Causal Mediation Forest, illustrating on the MEPS to approximate the direct/indirect effect of smoking on total medical expenditures, as mediated by the overall health status of an individual.

- The repository https://github.com/YanxunXu/BaySemiCompeting contains code for implementing the semi-competing risks model described in the course.

- `meps2011.csv` is a subset of the MEPS dataset.

- `ISBA_2022_slides.pdf` contain the slides.

- This code requires the `dbarts`, `bcf`, `SoftBart`, and `BartMediate` packages to run. The packages `dbarts` and `bcf` are available on CRAN, while `SoftBart` and `BartMediate` are on GitHub at www.github.com/theodds/SoftBart and www.github.com/theodds/BartMediate respectively.
