## Load Packages ----

options(java.parameters = "-Xmx8g")
library(BartMediate)
library(tidyverse)

## Preprocess Data ----

meps_logy <- read.csv("meps2011.csv") %>% 
  filter(totexp > 0) %>% 
  mutate(logY = log(totexp)) %>% 
  mutate(smoke = ifelse(smoke == "No", 0, 1)) %>% 
  select(-totexp) %>% select(logY, everything())

phealth <- meps_logy$phealth
phealth <- case_when(phealth == "Poor" ~ 1, phealth == "Fair" ~ 2, 
                     phealth == "Good" ~ 3, phealth == "Very Good" ~ 4, 
                     phealth == "Excellent" ~ 5)
meps_logy$phealth <- phealth
rm(phealth)

View(meps_logy)

## Estimating the propensity score ----

fitted_smoking <- bartMachine(
  X = meps_logy %>% select(-logY, -smoke, -phealth) %>% as.data.frame(),
  y = factor(meps_logy$smoke),
  num_burn_in = 4000,
  num_iterations_after_burn_in = 4000,
  mem_cache_for_speed = TRUE,
  seed = 1
)

# First Clever Covariate
propensity_scores <- fitted_smoking$p_hat_train

## Fitting model to the mediator and get second CC ----

fitted_mediator <- bartMachine(
  X = meps_logy %>% select(-logY, -phealth) %>%
  mutate(propensity = propensity_scores) %>% as.data.frame(),
  y = meps_logy$phealth,
  num_burn_in = 4000,
  num_iterations_after_burn_in = 4000,
  seed = 2
)

# Second Clever Covariate
health_hat_0 <- predict(
  fitted_mediator, 
  meps_logy %>% select(-logY, -phealth) %>%
  mutate(propensity = propensity_scores, smoke = 0) %>% as.data.frame()
)

# Third Clever Covariate
health_hat_1 <- predict(
  fitted_mediator, 
  meps_logy %>% select(-logY, -phealth) %>%
  mutate(propensity = propensity_scores, smoke = 1) %>% as.data.frame()
)

## Make outcome df ----

meps_outcome <- meps_logy %>% 
  select(-logY) %>%
  mutate(propensity = propensity_scores, health_hat_0 = health_hat_0,
         health_hat_1 = health_hat_1)

## Fit model to the outcome ----

fitted_outcome <- bartMachine(
  X = meps_outcome %>% as.data.frame(), y = meps_logy$logY,
  num_burn_in = 4000, num_iterations_after_burn_in = 4000,
  seed = 3
)


## Lastly, fit the outcome model ----

set.seed(4)
mediated_bart <- mediate_bart(
  fit_y = fitted_outcome, 
  fit_m = fitted_mediator, 
  design_y = meps_outcome %>% as.data.frame(), 
  design_m = meps_logy %>% 
  select(-logY, -phealth) %>%
  mutate(propensity = propensity_scores) %>% as.data.frame(), 
  trt_name = "smoke", med_name = "phealth", 
  iters = seq(from = 1, to = 4000, by = 4), 
  num_copy = 2
)

## Doing Sensitivity ----

set.seed(6)
mediated_bart <- mediate_bart_sensitivity(
  fit_y = fitted_outcome,
  fit_m = fitted_mediator,
  design_y = meps_outcome %>% as.data.frame(),
  design_m = meps_logy %>%
    select(-logY, -phealth) %>%
    mutate(propensity = propensity_scores) %>% as.data.frame(),
  trt_name = "smoke", med_name = "phealth",
  iters = seq(from = 1, to = 4000, by = 4),
  num_copy = 2
)

summary(lm(logY ~ . , data = meps_logy))

mediated_bart_agg <- mediated_bart %>% group_by(Iteration, ParamName) %>%
  summarise(Param = mean(Param)) %>% 
  pivot_wider(names_from = ParamName, values_from = Param)

shift_lambda <- function(lambda) {
  out <- mediated_bart_agg %>%
    mutate(delta_0 = delta_0 - lambda * theta_a,
           delta_1 = delta_1 - lambda * theta_a,
           zeta_0 = zeta_0 + lambda * theta_a,
           zeta_1 = zeta_1 + lambda * theta_a,
           lambda = lambda)
  return(out)
}

lambda_grid <- seq(from = -.3, to = .3, length = 21)

mediated_sa <- do.call(rbind, lapply(lambda_grid, shift_lambda))
mediated_summary <- mediated_sa %>%
  group_by(lambda) %>%
  summarise_all(list(mean, function(x) quantile(x, 0.025), 
                     function(x) quantile(x, 0.975))) %>%
  select(-Iteration_fn1) %>%
  rename(delta_0 = "delta_0_fn1", ymin = "delta_0_fn2", ymax = "delta_0_fn3") %>%
  select(lambda, delta_0, ymin, ymax)

mediated_summary_zeta <- mediated_sa %>%
  group_by(lambda) %>%
  summarise_all(list(mean, function(x) quantile(x, 0.025), 
                     function(x) quantile(x, 0.975))) %>%
  select(-Iteration_fn1) %>%
  rename(zeta_1 = "zeta_1_fn1", ymin = "zeta_1_fn2", ymax = "zeta_1_fn3") %>%
  select(lambda, zeta_1, ymin, ymax)

pp <- ggplot(mediated_summary, aes(x = lambda / 0.34, y = delta_0)) +
  geom_ribbon(aes(ymin = ymin, ymax = ymax), alpha = 0.3) +
  theme_bw() + xlab("Scaled $\\lambda$") + ylab("$NIE_0$") +
  geom_point() + geom_line() + geom_hline(yintercept = 0)

pp2 <- ggplot(mediated_summary_zeta, aes(x = lambda / 0.34, y = zeta_1)) +
  geom_ribbon(aes(ymin = ymin, ymax = ymax), alpha = 0.3) +
  theme_bw() + xlab("Scaled $\\lambda$") + ylab("$NDE_1$") +
  geom_point() + geom_line() + geom_hline(yintercept = 0)

## Visualize ----

gridExtra::grid.arrange(pp, pp2, nrow = 2)
