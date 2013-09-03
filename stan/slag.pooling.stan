data {
  int<lower=0> N;
  int<lower=0> K;
  vector[N] y;
  real X[N,K];
}
parameters {
  real a;
  real b[K];                           
  real<lower=0> sigma_y;
}
model {
  for (n in 1:N)
    for (k in 1:K)
      y[n] ~ normal(a + b[k] * X[n,k], sigma_y);
}
