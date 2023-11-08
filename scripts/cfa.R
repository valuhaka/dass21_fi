###  Luka Vähäsarja 28.6.2023  ###
###  HHS, KTTL, LTDK, HY       ###

# This is a long script that contains most of the analyses investigating the 
# structure of the DASS-21. It has been split in parts. To run parts of it,
# just change the booleans under the "Choices" heading.

#------------------------------------------------------------------------------#

library(foreign)
library(lavaan)
library(lavaanPlot)
library(semTools)
library(tidyverse)
library(psych)
library(corrplot)
library(rempsyc)

#------------------------------------------------------------------------------#

# Choices.
# Note: running multiple subsections may cause bugs.

finnishOnly        <- TRUE     # Should only Finnish answers be included?

covariances        <- FALSE    # Should the covariances be calculated?

nFactors           <- FALSE    # Should the amount of factors be analysed?
figures1           <- FALSE    # Should the structure be plotted?
fitsTable          <- FALSE    # Should model fit indice be tabled?

loadings           <- FALSE    # Should loadings be tabled?
figures2           <- FALSE    # Should the solutions be plotted?
residuals          <- FALSE    # Should the residual matrix of the bifactor  
                               # solution be plotted?

#------------------------------------------------------------------------------#

## Fetch the data and other necessary material.   ##

backupOptions <- options()

dataFolder <- "L:/ltdk_hhs45/data"    #  CHANGE

setwd(dataFolder)

load("dass.Rdata")           # Load the data.
load("cfaModels.Rdata")      # Load the models.
load("scaleLocs.Rdata")      # Load the scale locations among the questions.

qNames              <- paste0("Q", scaleLocs %>% unlist())

nModels             <- length(models)    # Number of models used 


## If chosen, remove those that didn't answer in Finnish. ##

if (finnishOnly) for (k in 1:2) dass[[k]] <- dass[[k]][suomi[[k]], ]


#------------------------------------------------------------------------------#

## Covariance matrices.

if (covariances == 1){
  covarianceMats <- list()

  for (k in 1:2) {
    
    # Calculate the covariances.
    covarianceMats[[k]]                 <- cov(dass[[k]])
    
    # Format.
    covarianceMats[[k]][upper.tri(covarianceMats[[k]], diag = FALSE)] <- NA
    Qs                                                    <- paste0("Q", 1:21)
    covarianceMats[[k]]                                   <- data.frame(Qs, covarianceMats[[k]])
    
    # Into nice_table format.
    covarianceMats[[k]]                 <- nice_table(covarianceMats[[k]], title = c("Table.",
            "The covariance matrix between the DASS-21 items in the ______ cohort of the Helsinki Health study."),
            note = "Variances on the diagonal")
  }
  # flextable::save_as_docx(covarianceMats[[1]], path = paste0(dataFolder, "/covMatYoung.docx"))
  # flextable::save_as_docx(covarianceMats[[2]], path = paste0(dataFolder, "/covMatOld.docx"))
}

#------------------------------------------------------------------------------#

## Number of Factors ##

if (nFactors == 1) {
  
  nf <- list()
  
  for (k in 1:2) {
    a <- psych::scree(dass[[k]], pc = FALSE)
    readline("[Enter]")
    
    nf[[k]] <- psych::nfactors(dass[[k]])
    nf[[k]]
    nf[[k]] <- nf[[k]]$vss.stats            %>% 
                dplyr::select(RMSEA, SRMR, eBIC) %>%
                round(digits = 2)
    nf[[k]] <- nf[[k]][1:6, ]
  }
  
  # Add cut-off info.
  
  nf           <- cbind(nf[[1]], nf[[2]])
  nf           <- rbind(nf, c(0.06, 0.08, NA, 0.06, 0.08, NA))
  
  nimet        <- data.frame(c(paste("factor", 1:6), "cutoff"))
  nf           <- cbind(nimet, nf)
  colnames(nf) <- c("f", "working-aged.RMSEA", "working-aged.SRMR", "working-aged.EBIC",
                         "older.RMSEA", "older.SRMR", "older.EBIC")
  
  # Format.
  
  nftable      <- nice_table(nf, separate.header = TRUE,
                             title = c("Table X", "Number of factors in the DASS-21."))
  }

#------------------------------------------------------------------------------#

## Structural images of the models. ##

if (figures1 == 1) {
  
  par(mfrow = c(3,2))
  
  for (i in 1:nModels) {
  models[i] %>%
    lavaanify() %>%
    semPlot::semPaths(residuals = TRUE, bifactor = c("D", "A", "S"), 
                      layout = "tree3", label.cex = 2)
    title(main = i, adj = 0)
  }
}

#------------------------------------------------------------------------------#

##  CFA  ##
  
# The parts below run the main confirmatory factor analyses.
  
#------------------------------------------------------------------------------#
  
# Create necessary variables.

quantities       <- c("chisq", "df", "cfi",   # What to measure?
                   "tli", "rmsea", "srmr") 
result      <- list(list(), list())
modelFits <- list(list(), list())

#------------------------------------------------------------------------------#

for (k in 1:2) {
  for (i in 1:nModels ) {
    if (i == 2) {                          # Which models are orthogonal?
      orth = FALSE
    } else {
      orth = TRUE
    }
    
    # Fit models and solve.
    
    result[[k]][[i]]        <- models[i] %>% paste() %>%
              lavaan::cfa(data = dass[[k]],
                    estimator = "WLSMV", # ML
                    std.lv = TRUE,
                    orthogonal = orth)
    
    # Get fit indices.
    
    modelFits[[k]][[i]]   <- fitMeasures(result[[k]][[i]], quantities)
  }


  # Format the fit table.
  
  modelFits[[k]]           <- modelFits[[k]] %>% list2DF() %>% t()
  colnames(modelFits[[k]]) <- quantities
  rownames(modelFits[[k]]) <- c(names(models))
  
  
  # Also format chisquare and chisquare/df.
  
  chisq <- modelFits[[k]][, 1] %>%           # Save for later.
        unlist() %>% as.vector()
  
  df    <- modelFits[[k]][, 2] %>%
        unlist() %>% as.vector()
  
  modelFits[[k]] <- round(modelFits[[k]], digits = 2)
  
  for (i in 1:nModels) {
  modelFits[[k]][i, 1]        <- paste0(
                                round(modelFits[[k]][i, 1] %>% as.numeric, digits = 0), " (",
                                modelFits[[k]][i, 2], ")")
  }
  
  colnames(modelFits[[k]])[2] <- "chisq/df"
  modelFits[[k]][, 2]         <- chisq / df 
  modelFits[[k]][i, 2]        <- modelFits[[k]][i, 2] %>% unlist() %>% 
                                  as.numeric() %>% round(digits = 2)

}

#------------------------------------------------------------------------------#

## Tables.


if (fitsTable == 1) {
  
  modelFitsTable        <- data.frame(modelFits[[1]], modelFits[[2]])
  
  modelFitsTable[, 2]   <- modelFitsTable[, 2] %>% as.numeric() %>% round(digits = 2)
  modelFitsTable[, 8]   <- modelFitsTable[, 8] %>% as.numeric() %>% round(digits = 2)
  
  quantities            <- c("χ²(df)", "χ²/df", "CFI", "TLI", "RMSEA", "SRMR")
                              
  modelFitsTable        <- 1:nModels %>% 
                              add_column(.data = modelFitsTable, .before = 1)
  
  colnames(modelFitsTable) <- c("model", "working-aged.χ²(df)",  "working-aged.χ²/df", 
                               "working-aged.CF I", "working-aged.TL I", 
                               "working-aged.RMSE A", "working-aged.SRM R", 
                               "older.χ²(df)", "older.χ²/df", "older.CF I", 
                               "older.TL I", "older.RMSE A", "older.SRM R")   
  
  cutOffs               <- rep(c(NA, "< 2", "≥ 0.95", "≥ 0.95", 
                                         "≤ 0.06", "≤ 0.08"), 2)
  modelFitsTable        <- rbind(modelFitsTable, c("cutoffs", cutOffs))
  
  niceModelFits         <- nice_table(modelFitsTable,
                             separate.header = TRUE,
                             title = c("Table 2.", 
        "Model fit indices from a confirmatory factor analysis (CFA) on the DASS-21 data from the working-aged and older cohorts of the Helsinki Health Study - nuoret ensin, sitten vanhat"),
                             note  = "Fits esimated using the robust WLSMV method. ")
  
  print(niceModelFits)
  
  # flextable::save_as_docx(niceModelFits, path = paste0(dataFolder, "/cfaTable.docx"))
}

#------------------------------------------------------------------------------#
  
## Create and table the residuals.

if (residuals == 1) {
  
  residualTable <- list(list(), list())
  
  for (i in 1:5) { 
    for (k in 1:2) {
    
      # Create the residual matrix.
    
      residual                    <- resid(result[[k]][[i]]) %>%
        data.frame()
      
      # Format.
      
      residual[upper.tri(residual)] <- NA
      colnames(residual)          <- c("Qs", qNames)
      residual$Qs                 <- qNames
      
      # Save.
      
      residualTable[[k]][[i]]         <- residual
      rm(residual)
    } 
  } 
  
  # Format the tables for the residuals after fitting the bifactor solution.
  
  niceResidualTableYoung <- nice_table(residualTable[[1]][[3]], title = c("Table 1",
          "The residual covariance matrix of DASS-21 items after fitting the bifactor solution."))
  # flextable::save_as_docx(niceResidualTableYoung, paste0(dataFolder, "/residYoung.docx"))
  niceResidualTableOld <- nice_table(residualTable[[2]][[3]], title = c("Table 2",
          "The residual covariance matrix of DASS-21 items after fitting the bifactor solution."))
  # flextable::save_as_docx(niceResidualTableOld, paste0(dataFolder, "/residOld.docx"))
}


#------------------------------------------------------------------------------#

## Table the solutions.

if (loadings == 1) {
  
  summaries <- list()
  estimates <- list(matrix(NA, nrow=21, ncol=8) %>% data.frame(), # Create empty
                    matrix(NA, nrow=21, ncol=8) %>% data.frame()) # data frames.
  
  
  
  # Now inspect the 3+1 factor solution.
  
  for (k in 1:2) {
    
    summaries[[k]]             <- lavaan::summary(result[[k]][[3]])
    
    estimates[[k]][, 1:2]      <- summaries[[k]]$pe[22:42, 5:6]
    estimates[[k]][1:7, 3:4]   <- summaries[[k]]$pe[1:7, 5:6]
    estimates[[k]][8:14, 5:6]  <- summaries[[k]]$pe[8:14, 5:6]
    estimates[[k]][15:21, 7:8] <- summaries[[k]]$pe[15:21, 5:6]
    
    estimates[[k]]             <- estimates[[k]] %>% round(digits = 2)
    colnames(estimates[[k]])   <- c("GD.slope", "GD.SE",
                                     "D.slope", "D.SE",
                                     "A.slope", "A.SE",
                                     "S.slope", "S.SE")
    
    estimates[[k]]             <- data.frame(qNames, estimates[[k]]) %>%
                                   nice_table(estimates[[k]], separate.header = TRUE)
    
    
  }
  
  # save_as_docx(estimates[[1]], paste0(dataFolder, "/estYoung.docx"))
  # save_as_docx(estimates[[2]], paste0(dataFolder, "/estOld.docx"))
}


#------------------------------------------------------------------------------#
  
## Plot the solutions.

if (figures2 == 1) {
  par(mfrow = c(1,1))
  semPlot::semPaths(result[[1]][[3]], "std", bifactor = c("D", "A", "S"), layout = "tree2", 
                    sizeLat = 5, edge.label.cex = .6, sizeMan = 6, residuals = 0, esize = 1)
  
  semPlot::semPaths(result[[2]][[3]], "std", bifactor = c("D", "A", "S"), layout = "tree2", 
                    sizeLat = 5, edge.label.cex = .6, sizeMan = 6, residuals = 0, esize = 1)
}

#------------------------------------------------------------------------------#

# Reload options.
  
options(backupOptions)