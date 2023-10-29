###  Luka Vähäsarja 10.10.2023  ###
###  HHS, KTTL, LTDK, HY       ###

library(tidyverse)
library(rempsyc)
library(officer)
library(table1)


finnishOnly     <- 1  #  Only include Finnish respondents.


#------------------------------------------------------------------------------#

## Load the data ##

setwd("L:/ltdk_hhs45/data")
load("chosenData.Rdata")

# If chosen, include Finnish responses only.

if (finnishOnly) for (k in 1:2) data[[k]] <- data[[k]][data[[k]]$suomi, ]


#------------------------------------------------------------------------------#

## Working for the Helsinki municipality ##

helsinki                       <- data$tyonantaja[data$tyonantaja == 1] %>% 
                                                   sum(na.rm = TRUE)

## Choose variables ##

chosenVars      <- list()

chosenVars[[1]] <- data[[1]] %>% dplyr::select(
  sukupuoli,                                       # Gender.
  b_ika,                                           # Age.
  koulutus,                                        # Education.
  siviilisaaty,                                    # Marital status.
)
chosenVars[[2]] <- data[[2]] %>% dplyr::select(
  i1,                                              # Gender.
  kika,                                            # Age.
                                                   # Education.
  i3,                                              # Marital status.
)

for (i in 1:2) colnames(chosenVars[[i]]) <- c("gender", "age", "education", 
                                           "marital_status")


#------------------------------------------------------------------------------#

## Making tables. ##


# Means. Naming. Refactoring.

for (i in 1:2) {
  chosenVars[[k]]$gender <- factor(chosenVars[[k]]$gender)
  levels(chosenVars[[i]]$gender) <- c("Male", "Female")
  
  chosenVars[[i]]$education <- chosenVars[[i]]$education %>% 
    cut(c(0, 1.5, 3.5, 7),
        c("middle school or below", 
          "high school or vocational school", 
          "university or polytechnic degree"))
  
  chosenVars[[i]]$marital_status   <- chosenVars[[i]]$marital_status %>% 
    cut(c(0, 1.5, 3.5, 6),
        c("single", "married or cohabiting", "divorced or widowed"))
}

## Format the table. 

tableOne      <- list()

# k = cohort

for (k in 1:2) tableOne[[k]] <- table1::table1(~ age + education + marital_status 
                                  | gender, data = chosenVars[[k]]) 

# Format into one table.

niceTableOne  <- cbind(tableOne[[1]] %>% data.frame, 
                       tableOne[[2]] %>% data.frame)
niceTableOne  <- niceTableOne[,-5]        # Remove the duplicate column "X.1".

# Fix the column names.

cnames                 <- colnames(niceTableOne)[2:4]
cnames                 <- c(paste0("Younger.", cnames), 
                            paste0("Older.", cnames))
colnames(niceTableOne) <- c("X", cnames)



# Make the table

niceTableOne <- nice_table(niceTableOne, separate.header = TRUE,
              title = c("Table 1", 
              "Demographic variables in the two Helsinki Health Study cohorts."))

#------------------------------------------------------------------------------#

## Save. ##

# Note: the follwing puts the table in your data folder in a .docx file.

flextable::save_as_docx(niceTableOne, path = paste0(getwd(), '/table1.docx'))
