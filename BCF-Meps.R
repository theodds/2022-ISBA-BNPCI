## Load packages ----

library(bcf)
library(dbarts)
library(tidyverse)

## Load data ----

meps <- read_csv("meps2011.csv") %>% filter(totexp > 0)

meps %>% View()

## Fitting a BCF: Estimating the Propensity Score ----

smoke_design <- meps %>%
  select(age, bmi, edu, income, povlev, region, sex, race, seatbelt, smoke) %>%
  mutate(smoke = factor(smoke))

set.seed(111911)
smoke_bart <- bart2(smoke %>% as.numeric - 1 ~ ., data = smoke_design,
                    useQuantiles = TRUE)
smoke_hat  <- apply(smoke_bart$yhat.train, 3, function(x) mean(pnorm(x)))

ggplot(data.frame(e = smoke_hat), aes(e)) +
  geom_histogram(bins = 100, alpha = 0.4, color = 'black') + 
  xlab("Estimated Propensity Scores") + theme_bw()

## Fitting the BCF ----

x_control <- smoke_design %>% select(-smoke)
x_control <- model.matrix(~ . - 1, data = x_control)
smoke_bcf <- bcf(y = log(meps$totexp),
                 z = smoke_design$smoke %>% as.numeric - 1,
                 x_control = x_control, pihat = smoke_hat,
                 nburn = 2000, nsim = 2000)

smoke_bcf$tau[1:10,1:5] 

## Getting the ATE with the Bayesian Bootstrap ----

bb_weights <- MCMCpack::rdirichlet(n = 2000, alpha = rep(1, nrow(meps)))
ATE        <- rowSums(bb_weights * smoke_bcf$tau)

ggplot(data.frame(ATE = ATE), aes(ATE)) +
  geom_histogram(bins = 50, alpha = 0.4, color = 'black') +
  xlab("Average Causal Effect") + theme_bw()

## Making a waterfall plot ----

num_subject <- ncol(smoke_bcf$tau)
num_iter    <- nrow(smoke_bcf$tau)
o           <- order(colMeans(smoke_bcf$tau))
cate_df     <- tibble(tau = as.numeric(smoke_bcf$tau),
                      iteration = rep(1:num_iter, num_subject),
                      subject = rep(1:num_subject, each = num_iter))

q_10 <- function(x) quantile(x, 0.1)
q_90 <- function(x) quantile(x, 0.9)
cate_summary <- cate_df %>% group_by(subject) %>%
summarise(tau_hat = mean(tau), lcl = q_10(tau), ucl = q_90(tau)) %>%
arrange(tau_hat) %>%
mutate(subject = rank(tau_hat))
ggplot(cate_summary, aes(x = subject, y = tau_hat)) + geom_point() +
geom_ribbon(aes(ymin = lcl, ymax = ucl), alpha = 0.3) +
xlab("Subject (Ordered)") + ylab("CATE")

## Interpretation through Posterior Projection ----

library(rpart)
library(rpart.plot)
rpart(colMeans(smoke_bcf$tau) ~ ., data = as.data.frame(x_control)) %>%
rpart.plot()
