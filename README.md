# 2022-ISBA-BNPCI
Github repo for the BNP Causal Inference short course.

- `BART-Illustration.R` illustrates the BART methodology in a non-causal setting, using the `dbarts` package.

- `BCF-Meps.R` implements the Bayesian Causal Forest of [Hahn et al.](https://projecteuclid.org/journals/bayesian-analysis/volume-15/issue-3/Bayesian-Regression-Tree-Models-for-Causal-Inference--Regularization-Confounding/10.1214/19-BA1195.pdf), illustrating on the Medical Expenditure Panel Survey (MEPS) to approximate the average causal effect of smoking on total medical expenditures.

- `BCMF-Meps.R` implements a Bayesian Causal Mediation Forest, illustrating on the MEPS to approximate the direct/indirect effect of smoking on total medical expenditures, as mediated by the overall health status of an individual.

- The repository https://github.com/YanxunXu/BaySemiCompeting contains code for implementing the semi-competing risks model described in the course.

- `meps2011.csv` is a subset of the MEPS dataset.

- `ISBA_2022_slides.pdf` contain the slides.

- This code requires the `dbarts`, `bcf`, `SoftBart`, and `BartMediate` packages to run. The packages `dbarts` and `bcf` are available on CRAN, while `SoftBart` and `BartMediate` are on GitHub at www.github.com/theodds/SoftBart and www.github.com/theodds/BartMediate respectively.

# Bibliography

## Forthcoming Book

- Daniels, M.J., Linero, A.R., and Roy, J.A. (2022+) Bayesian Nonparametrics for Causal Inference and Missing Data, CRC Press/Chapman & Hall

## BART

- Chipman, H.A., George, E.I., and McCulloch, R.E. (2010) BART: Bayesian
  Additive Regression Trees. _Annals of Applied Statistics_, 4(1) 266-298. [Link](https://projecteuclid.org/journals/annals-of-applied-statistics/volume-4/issue-1/BART-Bayesian-additive-regression-trees/10.1214/09-AOAS285.full).

- Hahn, P.R., Murray, J.S., and Carvalho, C.M. (2020). Bayesian regression tree models for causal inference: Regularization, confounding, and heterogeneous effects (with discussion). _Bayesian Analysis_ 15(3), 965-1056.

- Linero, A.R. and Yang, Y. (2018) Bayesian regression tree ensembles that adapt
  to smoothness and sparsity, _Journal of the Royal Statistical Society,
  Series B_, 80, 1087-1110.

- Linero, A.R. and Zhang, Q. (2022+) Mediation Analysis Using Bayesian Tree Ensembles. To appear in _Psychological Methods_.

## Misc

- Antonelli, J., Daniels, M.J. (2019). Discussion of 'PENCOMP'.  _Journal of the American Statistical Association_, 40, 24-27.

- Linero, A. (2022) Simulation‐based estimators of analytically intractable
  causal effects. To appear in _Biometrics_.

## Papers Using Dirichlet Processes

- Kim, C., Daniels, M.J., Marcus, B.H., and Roy, J.A. (2017). A
  framework for Bayesian nonparametric inference for causal effects of
  mediation. _Biometrics_, 73, 401-409.

- Roy, J.A., Lum, K., and Daniels, M.J. (2017). A Bayesian
  nonparametric approach to marginal structural models for point treatments and
  a continuous or survival outcome. _Biostatistics_, 18, 32-47.

- Xu, Y., Scharfstein, D., Mueller, P., and Daniels, M.J. (2022) A Bayesian
  Nonparametric Approach for Evaluating the Causal Effect of Treatment in
  Randomized Trials with Semi-Competing Risks. _Biostatistics_, 23, 34--49.

- Roy, J.A., Lum, K., Daniels, M.~J., Zeldow*, B.~Z., Dworkin, J., and Lo Re
  III, V. (2018). Bayesian nonparametric generative models for causal
  inference with missing at random covariates. _Biometrics_, 74,
  1193--1202.

- Josefsson, M, Daniels, M.J. (2021). A Bayesian semi-parametric G-computation
  for causal inference in a cohort study with non-ignorable dropout and death.
  _Journal of the Royal Statistical Society, Series C_, 70, 398-414.

- Xu, D., Daniels, M.J., and Winterstein, A.~G. (2018). A Bayesian nonparametric approach to causal inference on quantiles, _Biometrics_, 74, 986-996.

## Missing Data

- Linero, A. and Daniels, M.J. (2015) A flexible Bayesian approach to monotone
  missing data in longitudinal studies with informative missingness with
  application to an acute schizophrenia clinical trial. _Journal of the
  American Statistical Association_, 110, 45-55.

- Linero, A. and Daniels, M.J. (2018) A Bayesian approach for missing not at
  random outcome data: The role of identifying restrictions. _Statistical
  Science_, 33, 198-213.

- Linero, A. (2017) Bayesian nonparametric analysis of longitudinal studies in
  the presence of informative missingness, _Biometrika_, 104, 327-341.





