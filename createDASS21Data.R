###  Luka Vähäsarja 14.7.2023  ###
###  HHS, KTTL, LTDK, HY       ###

## This script takes as its input two sets of chosen data: one among the younger
## cohort, the other among the older one. The input data have been sorted. This
## script simply further condenses them down, as certain script (e.g. cfa.R)
## require no demographic variables. The output includes three objects:
## 1. < dass >   [list of 2 DFs]     DASS-21 data for each cohort.
## 2. < scales > [list of 2 DFs]     DASS-21 sum scores (subscales) for each cohort.
## 3. < suomi >  [list of 2 vectors] TRUE = answered in Finnish, FALSE = not.

library(tidyverse)

backupOptions <- options()
setwd("L:/ltdk_hhs45/data")

#------------------------------------------------------------------------------#

dass   <- list()
scales <- list()
suomi  <- list()
id     <- list()

load("chosenData.Rdata")    

# Younger cohort

dass[[1]]           <- data[[1]][, 151:171]
colnames(dass[[1]]) <- paste(rep("Q", 21), 
                             1:21, sep = "")
suomi[[1]]          <- data$suomi
id[[1]]             <- data$ID

# Older cohort

dass[[2]]           <- data[[2]][, 36:56]
colnames(dass[[2]]) <- paste(rep("Q", 21), 
                             1:21, sep = "")
suomi[[2]]          <- data$suomi
id[[2]]             <- data$tunnus1

# Remove NAs.

suomi[[2]] <- replace_na(suomi[[2]], 1)


#------------------------------------------------------------------------------#

load("scaleLocs.Rdata")

for (k in 1:2) { # 2 cohorts
  
  ## Table the sum variables. ##
  
  dass[[k]] <- dass[[k]] - 1
  dass[[k]][is.na(dass[[k]])] <- 1.5
  
  scales[[k]]        <- data.frame(
    dass[[k]] %>% dplyr::select(scaleLocs$d) %>% rowSums(),
    dass[[k]] %>% dplyr::select(scaleLocs$a) %>% rowSums(),
    dass[[k]] %>% dplyr::select(scaleLocs$s) %>% rowSums(),
    dass[[k]]                         %>% rowSums())
  
  names(scales[[k]]) <- c("D", "A", "S", "GD")
}

save(dass, scales, suomi, id, file = "dass.Rdata")
