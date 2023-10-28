###  Luka Vähäsarja 29.6.2023  ###
###  HHS, KTTL, LTDK, HY       ###

## Conducted power analyses to estimate the utility of the confirmatory factor
## analyses given the most complicated model provided by theory.

library(WebPower)

# df = observed - estimated

p    <- 21                # Observed variables.
vars <- (p * (p + 1)) / 2 # Variances and covariances.
ests <- 6                 # cfa() model parameters for the 3+1 bifactor solution.
df   <- vars - ests    

Ns   <- c(4700, 1050, 2550, 650) # Estimates of subgroup size rounded to the nearest 50.

model <- "
  D =~ Q3 + Q5 + Q10 + Q13 + Q16 + Q17 + Q21
  A =~ Q2 + Q4 + Q7 + Q9 + Q15 + Q19 + Q20
  S =~ Q1 + Q6 + Q8 + Q11 + Q12 + Q14 + Q18
  
  GD =~ Q3 + Q5 + Q10 + Q13 + Q16 + Q17 + Q21 +
  Q2 + Q4 + Q7 + Q9 + Q15 + Q19 + Q20 +
  Q1 + Q6 + Q8 + Q11 + Q12 + Q14 + Q18
"
for (i in 1:4) {
  WebPower::wp.sem.chisq(n = Ns[i], df = df, 
                         effect = 0.1, alpha = 0.05) %>%
  print()
}
