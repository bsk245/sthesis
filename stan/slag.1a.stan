data {
  int<lower=0> N;
  int<lower=0> J;
  int<lower=0> K;
  vector[N] y;
  real X[N,K];
  int province[N];
  real m[K];
  real<lower=0> sigma_b[K];
}
parameters {
  real a[J];
  real b[K];                           
  real mu_a;
  real<lower=0> sigmasq_y;
  real<lower=0> sigmasq_a;
  real<lower=0> inv_nu;
}
transformed parameters {
  real<lower=0> sigma_y;       
  real<lower=0> sigma_a;
  real<lower=0> nu; 
  sigma_y <- sqrt(sigmasq_y);
  sigma_a <- sqrt(sigmasq_a);
  nu <- 1/inv_nu;
}
model {
  mu_a ~ normal(300,100);
  sigmasq_y ~ inv_gamma(108,77182.75);
  sigmasq_a ~ inv_gamma(2,200);
  inv_nu ~ uniform(0,0.5);
  a ~ normal(mu_a, sigma_a);
  b ~ normal(m,sigma_b);
  for (n in 1:N)
      y[n] ~ student_t(nu,a[province[n]] + b[1]*X[n,1] + b[2]*X[n,2] + b[3]*X[n,3] 
                       + b[4]*X[n,4] + b[5]*X[n,5], sigma_y);
}
