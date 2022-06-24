## Load Packages ----

options(java.parameters = "-Xmx8g")
library(BartMediate)

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

## Visualize ----
