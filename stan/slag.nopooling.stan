data {
  int<lower=0> N;
  int<lower=0> J;
  int<lower=0> K;
  vector[N] y;
  real X[N,K];
  int province[N];
}
parameters {
  real a[J];
  real b[K];              
  real<lower=0> sigma_y;
}
model {
  for (i in 1:N)
    for (k in 1:K)
      y[i] ~ normal(a[province[i]] + b[k] * X[i,k], sigma_y);
}
