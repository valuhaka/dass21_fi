###  Luka Vähäsarja 8.8.2023  ###
###  HHS, KTTL, LTDK, HY       ###

library(foreign)
library(lavaan)
library(lavaanPlot)
library(semTools)
library(tidyverse)
library(psych)
library(corrplot)
library(rempsyc)

## This script is used to investigate measurement invariance in the DASS-21 between 
## the subpopulations of the two cohorts of the Helsinki Health Study.

backupOptions <- options()

#------------------------------------------------------------------------------#

## Get the DASS data, models and indices. ##

setwd(".../data")            # YOUR DIRECTORY HERE

load("dass.Rdata")           # Load the DASS-21 data.
load("cfaModels.Rdata")      # Load the factor analytic models.
load("scaleLocs.Rdata")      # Load the scale indices for the DASS-21 questions.

# Get gendered data.

load("chosenData.Rdata")

dass[[1]]$gender     <- data[[1]]$sukupuoli
dass[[2]]$gender     <- data[[2]]$i1

rm(data)


#------------------------------------------------------------------------------#

fits              <- list(matrix(nrow = 4, 
                                 ncol = 4) %>% 
                            data.frame()   %>% 
                            rbind("cut-offs" = 
                                    c(">0.95", ">0.95", 
                                      "<0.06", "<0.08")))
fits[[2]]         <- fits[[1]]

for (k in 1:2) colnames(fits[[k]]) <- c("CFI", "TLI", "RMSEA", "SRMR")

configRes         <- list()
metricRes         <- list()
scalarRes         <- list()
strictRes         <- list()

configSummary     <- list()
metricSummary     <- list()
comparisons       <- list()

#------------------------------------------------------------------------------#

## 1. Configural invariance ##

# Just a multigroup CFA.

for (k in 1:2) {
  
  configRes[[k]]   <- lavaan::cfa(model = models[[3]],
                                data = dass[[k]],
                                estimator = "WLSMV",
                                group = "gender",
                                orthogonal = TRUE)
  
  configSummary[[k]] <- summary(configRes[[k]],
                                fit.measures = TRUE,
                                standardized = TRUE)
  
  fits[[k]][1, ]    <-  configSummary[[k]]$fit              %>% 
                        rbind(names(configSummary$fit), .)  %>%
                        data.frame()                        %>%
                        dplyr::select("cfi.robust", 
                               "tli.robust",
                               "rmsea.robust",
                               "srmr")
  
}


#------------------------------------------------------------------------------#


## 2. Metric invariance ##

# Factor loadings fixed, intercepts free.

for (k in 1:2) {
  
  metricRes[[k]]   <- lavaan::cfa(model = models[[3]],
                                  data = dass[[k]],
                                  estimator = "WLSMV",
                                  group = "gender", 
                                  group.equal = "loadings",
                                  orthogonal = TRUE)
}


#------------------------------------------------------------------------------#


## 3. Scalar invariance ##

# Factor loadings and intercepts fixed.

for (k in 1:2) {
  scalarRes[[k]] <- lavaan::cfa(model = models[[3]],
                                  data = dass[[k]],
                                  estimator = "WLSMV",
                                  group = "gender", 
                                  group.equal = c("loadings", "intercepts"),
                                  orthogonal = TRUE)
}


#------------------------------------------------------------------------------#

## 4. Strict invariance  ##

# Factor loadings, intercepts and residual variances fixed.


for (k in 1:2) {
  strictRes[[k]] <- lavaan::cfa(model = models[[3]],
                                data = dass[[k]],
                                estimator = "WLSMV",
                                group = "gender", 
                                group.equal = c("loadings", 
                                                "intercepts",
                                                "residuals"),
                                orthogonal = TRUE)
}



for (k in 1:2) {
  comparisons[[k]]     <- compareFit(configRes[[k]],
                                     metricRes[[k]],
                                     scalarRes[[k]],
                                     strictRes[[k]])
  
  fits[[k]][2:4, ] <- comparisons[[k]]@fit.diff %>%
    dplyr::select("cfi.robust", 
                  "tli.robust",
                  "rmsea.robust",
                  "srmr")
  
  fits[[k]][2, ]   <- (fits[[k]][1, ] %>% as.numeric) + (fits[[k]][2, ] %>% as.numeric)
  fits[[k]][3, ]   <- (fits[[k]][2, ] %>% as.numeric) + (fits[[k]][3, ] %>% as.numeric)
  fits[[k]][4, ]   <- (fits[[k]][3, ] %>% as.numeric) + (fits[[k]][4, ] %>% as.numeric)
}


## Round all numbers. ##

for (k in 1:2) for (i in 1:4) for (j in 1:4) fits[[k]][i,j] <- fits[[k]][i,j] %>% 
  as.numeric %>%
  round(digits = 4)

## Format ##

fits           <- data.frame(c("configural", "metric",
                               "scalar", "strict",
                               "cut-offs"),
                              fits[[1]], fits[[2]])
colnames(fits) <- c("model",
                     "working-aged.cfi", "working-aged.tli",
                     "working-aged.rmsea", "working-aged.srmr",
                     "older.cfi", "older.tli",
                     "older.rmsea", "older.srmr")


#------------------------------------------------------------------------------#

##  Format nicely.  ##

niceInvarianceTable <- nice_table(fits, 
                           title = c("Table 1", 
                           "Invariance analyses in the two Helsinki Health Study cohorts. All values for variables measured in 2022."),
                           separate.header = TRUE)



## Display ##

print(niceInvarianceTable)


##  Save.  ##

# flextable::save_as_docx(niceInvarianceTable, path = paste0(getwd(), "/invarianceTable.docx"))


#------------------------------------------------------------------------------#

options(backupOptions)
