## Load packages ----

library(dbarts)
library(SoftBart)
library(tidyverse)

## Simulation Experiment ----

sim_data <- tibble(x = seq(from = 0, to = 1, length = 300)) %>%
  mutate(y = sin(2 * pi * x) + 0.1 * rnorm(length(x)))

sim_bart <- bart(sin_data$x, sin_data$y, verbose = FALSE)

## Get posterior mean and confidence band ----

mu_hat       <- sin_bart$yhat.train.mean
lcl          <- apply(sin_bart$yhat.train, 2, function(x) quantile(x, 0.025))
ucl          <- apply(sin_bart$yhat.train, 2, function(x) quantile(x, 0.975))
sin_fit_data <- sin_data %>% mutate(mu_hat = mu_hat, lcl = lcl, ucl = ucl)

ggplot(sin_fit_data, aes(x = x)) + geom_point(aes(y = y)) +
  geom_line(aes(y = mu_hat), color = 'green', size = 2) +
  geom_ribbon(aes(ymin = lcl, ymax = ucl), alpha = 0.4) +
  stat_function(fun = function(x) sin(2 * pi * x), color = 'blue', size = 2,
                alpha = 0.3)

## Assess mixing ----

mixing_data <- tibble(sigma = sin_bart$sigma)

qplot(1:length(sigma), sigma, data = mixing_data, geom = "line")

## More complicated example ----

set.seed(1234)

f_fried <- function(x) 10 * sin(pi * x[,1] * x[,2]) + 20 * (x[,3] - 0.5)^2 + 
                       10 * x[,4] + 5 * x[,5]

gen_data <- function(n_train, n_test, P, sigma) {
  X <- matrix(runif(n_train * P), nrow = n_train)
  mu <- f_fried(X)
  X_test <- matrix(runif(n_test * P), nrow = n_test)
  mu_test <- f_fried(X_test)
  Y <- mu + sigma * rnorm(n_train)
  Y_test <- mu_test + sigma * rnorm(n_test)
  return(list(X = X, Y = Y, mu = mu, X_test = X_test,
              Y_test = Y_test, mu_test = mu_test))
}

sim_data <- gen_data(250, 100, 1000, 1)

## Fit SBART ----

hypers <- Hypers(sim_data$X, sim_data$Y, num_tree = 50)
opts   <- Opts(num_burn = 5000, num_save = 5000)

fit <- softbart(X = sim_data$X, 
                Y = sim_data$Y, 
                X_test = sim_data$X_test, 
                hypers = hypers,
                opts = opts)

## Automatic relevance determination ----

posterior_inclusion_probs <- colMeans(fit$var_counts > 0)
plot(posterior_inclusion_probs, 
     col = ifelse(posterior_inclusion_probs > 0.5, 
                  muted("blue"), 
                  muted("green")), 
     pch = 20)
