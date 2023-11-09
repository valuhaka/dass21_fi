###  Luka Vähäsarja 26.6.2023  ###
###  HHS, KTTL, LTDK, HY       ###

## This script investigates the criterion validity for the DASS-21 in two Finnish
## cohorts. For this, the measurement is simply correlated with measurements using 
## the RAND-36 questionnaire.

library(tidyverse)
library(rempsyc)
library(ltm)


#------------------------------------------------------------------------------#

## Data ##

setwd(".../data")                # CHANGE
load("dass.Rdata")
load("chosenData.Rdata")

RANDs <- list()

RANDs[[1]]       <- data[[1]][,192:199]    # The locations of the RAND subscale columns.
RANDs[[2]]       <- data[[2]][,70:77]      # The locations of the RAND subscale columns.

RANDVarNames     <- c("PF", "RP", "RE", "E/F", "EW", "SoF", "BP", "GH")

#------------------------------------------------------------------------------#

## Create tables. ##

correlationTables <- list()

for (k in 1:2) correlationTables[[k]] <- cor(RANDs[[k]], scales[[k]], 
                                             use = "complete.obs") %>% 
                                  data.frame(row.names = NULL)

# Format.

correlationTables    <- cbind(correlationTables[[1]], correlationTables[[2]])

# Column names by cohort.

colnames(correlationTables) <- colnames(correlationTables) %>%
                            paste(c(rep("young", 4),
                                    rep("old", 4)), .,
                                    sep = ".")

# Add variable names.

correlationTables    <- cbind(RANDVarNames, 
                              correlationTables)

# Into nice_table format.

niceCorrelationTable <- nice_table(correlationTables, 
                                   separate.header = TRUE,
                                   title = c("Table 1", 
 "Correlation coefficients between the the DASS-21 subscales and the RAND-36 emotional wellbeing (EW) scale in the two Helsinki Health Study cohorts."))

#------------------------------------------------------------------------------#


## Display and save. ##

print(niceCorrelationTable)

flextable::save_as_docx(niceCorrelationTable, path = paste0(getwd(), 
                                                      "/criterionValidityTable.docx"))
