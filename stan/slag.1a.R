##########################################################################
# slag.1a.R
# 8/30/13
##########################################################################
setwd("~/Desktop/new_data/STAN/Thesis/")

library(rstan)
library(ggplot2)

## Data

source("ch16_data.R", echo = TRUE)
setwd("~/Desktop/new_data/STAN/Thesis/")

## Call Stan from R
if (!exists("slag.1a.sm")) {
    if (file.exists("slag.1a.sm.RData")) {
        load("slag.1a.sm.RData", verbose = TRUE)
    } else {
        rt <- stanc("slag.1a.stan", model_name = "slag.1a")
        slag.1a.sm <- stan_model(stanc_ret = rt)
        save(slag.1a.sm, file = "slag.1a.sm.RData")
    }
}
slag.data <- c("N", "J", "K", "y", "X", "province","m","sigma_b")
slag.1a.sf <- sampling(slag.1a.sm, slag.data, iter = 100000, chains=4)
print(slag.1a.sf)

# Plot Figure 16.2
mu_a.sample <- extract(slag.1a.sf, pars = "mu_a",
                       permuted = FALSE, inc_warmup = TRUE)
n.chains <- dim(mu_a.sample)[2]
value <- matrix(mu_a.sample[1:1000,,1], ncol = 1)
trace.ggdf <- data.frame(chain = rep(1:n.chains, each = 200),
                         iteration = rep(1:1000, n.chains),
                         value)
p1a <- ggplot(trace.ggdf) +
    geom_path(aes(x = iteration, y = value, group = chain)) +
    ylab(expression(mu[alpha]))
print(p1a)

## Accessing the simulations
sims <- extract(slag.1a.sf)
a <- sims$a
b <- sims$b
sigma.y <- sims$sigma_y
sigma.a <- sims$sigma_a

# 90% CI for beta
quantile(b[,1], c(0.05, 0.95))             # financial autonomy
quantile(b[,2], c(0.05, 0.95))             # population (million)
quantile(b[,3], c(0.05, 0.95))             # population density
quantile(b[,4], c(0.05, 0.95))             # vote margin  
quantile(b[,5], c(0.05, 0.95))             # committee  

# Prob. avg allocation amounts are higher in Chungnam  than in county Jeonam
mean(a[,3] > a[,13])

## Fitted values, residuals and other calculations
a.multilevel <- rep(NA,J)
for (j in 1:J) {
    a.multilevel[j] <- median(a[,j])
}

b.multilevel <- rep(NA,K)
for (k in 1:K) {
  b.multilevel[k] <- median(b[,k])
}

y.hat <- a.multilevel[province] + as.matrix(X)%*%b.multilevel
y.resid <- y - y.hat

qplot(y.hat, y.resid)

# numeric calculations
n.sims <- 1000
chungnam.slag <- rep(NA, n.sims)
jeonam.slag <- rep(NA, n.sims)
for (s in 1:n.sims) {
  chungnam.slag[s] <- exp(rnorm(1, a[s,3] + as.matrix(X)%*%b[s,], sigma.y[s]))
  jeonam.slag[s] <- exp(rnorm(1, a[s,13] + as.matrix(X)%*%b[s,], sigma.y[s]))
}
slag.diff <- chungnam.slag - jeonam.slag
p2 <- ggplot(data.frame(slag.diff), aes(x = slag.diff)) +
    geom_histogram(color = "black", fill = "gray", binwidth = 0.75)
print(p2)
print(mean(slag.diff))
print(sd(slag.diff))
