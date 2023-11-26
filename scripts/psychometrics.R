###  Luka Vähäsarja 1.8.2023  ###
###  HHS, KTTL, LTDK, HY       ###

# Creates a table of statistics on the DASS questions and subscales (D, A, S, GD),
# including range, n, mean, median, SD, skew, kurtosis, alpha, omegas and SEm.

require(tidyverse)
require(rempsyc)

# Use only Finnish answers?

finnishOnly <- 1

## Load the data. ##

setwd(".../data")          # YOUR DIRECTORY HERE

load("scaleLocs.Rdata")    # Load the locations of the scales among the questions.
load("dass.Rdata")         # Load the data.


# If chosen, remove non-Finnish answers.

if (finnishOnly == 1) { 
  for (k in 1:2) dass[[k]]   <- dass[[k]][suomi[[k]], ]
  for (k in 1:2) scales[[k]] <- scales[[k]][suomi[[k]], ]
}

# Calculate the Ns.

N      <- lapply(dass, FUN = dim)
N[[1]] <- N[[1]][1]
N[[2]] <- N[[2]][1]


## Calculate the reliabilities. ##

rels <- list(data.frame(rep(NA, 25),
                        rep(NA, 25),
                        rep(NA, 25)),
             data.frame(rep(NA, 25),
                        rep(NA, 25),
                        rep(NA, 25)))

for (k in 1:2) {
  for (i in 1:3) {
    rel            <- dass[[k]]            %>% 
                  select(scaleLocs[, i])   %>% 
                  psych::reliability()
    
    rels[[k]][i, ] <- rel$result.df[1:3]  %>% 
                  round(digits = 2)
  }
  rel            <- dass[[k]]             %>% 
                  psych::reliability()
  
  rels[[k]][4, ] <- rel$result.df[1:3]    %>% 
    round(digits = 2)
  
  colnames(rels[[k]]) <- c("omegah", "alpha", "omegatot")
  
  rels[[k]]      <- rels[[k]] %>% relocate("alpha", 1)
  
  rm(rel)
}

## SEm = std(sum(X)) * sqrt(1 - R)

SEm <- data.frame(rep(NA, 25), rep(NA, 25))

for (k in 1:2) {
  for (i in 1:3) {
    SEm[i, k] <- dass[[k]]            %>% 
      select(scaleLocs[, i])          %>%
      rowSums()                       %>%
      sd(., na.rm = TRUE) * sqrt(1 - rels[[k]][i, 3]) # omega_tot
  }
  SEm[4, k] <- dass[[k]]              %>%
    rowSums()                         %>%
    sd(., na.rm = TRUE) * sqrt(1 - rels[[k]][4, 2])   # omega_h
}

## Into a data frame ##

df            <- list()
  
for (k in 1:2) {
  df[[k]]     <- dass[[k]]            %>% 
    cbind(scales[[k]], .)                             %>%
    psych::describe(type = 2)                         %>% 
    data.frame()                                      %>% 
    select(n, mean, median, sd, skew, kurtosis)       %>% 
    round(digits = 3)                                 %>% 
    add_column(rels[[k]], SEm[, k], .after = "kurtosis")
  df[[k]]$median <- df[[k]]$median %>%
                                    round(digits = 0)
}

## Format ##

ranges                        <- c(rep("0—21", 3), "0—63", rep("0—7", 21))

df            <- data.frame(rownames(df[[1]]),
                                            ranges,
                                            df[[1]], 
                                            df[[2]])    %>%
                                 mutate(n.1 = n.1 %>% round(digits = 0))

names(df)     <- c("Qs", "range", 
                                   
                                   "working-aged.n", "working-aged.m",
                                   "working-aged.md", "working-aged.SD",
                                   "working-aged.skew (G_1)", "working-aged.kurt (G_2)", 
                                   "working-aged.α", "working-aged.ω_h",
                                   "working-aged.ω_tot", "working-aged.SEm", 
                                   
                                   "older.n", "older.m", 
                                   "older.md", "older.SD", 
                                   "older.skew (G_1)", "older.kurt (G_2)", 
                                   "older.α", "older.ω_h", 
                                   "older.ω_tot", "older.SEm")

note                          <- paste0("N_working-aged=", N[[1]], ", N_older=", N[[2]], ".
SEm = SD × √(1 - α). 
For a comparison of measures of skew and kurtosis, see Joanes and Jill (1998).")


niceDf        <- nice_table(df, title = c("Table 1.", 
                               "Sample distribution and reliability statistics in the two Helsinki Health Study cohorts."),
                               separate.header = TRUE,
                               note = note,
                               width = 1)

print(niceDf)