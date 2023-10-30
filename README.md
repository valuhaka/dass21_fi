<div style="text-align: center;">
  
# Project description

This folder will contain the code used to analyse the DASS-21 questionnaire for the upcoming article *The Depression, Anxiety and Stress Scales (DASS-21) among two Finnish occupational cohorts: Validation, Normative Data, and Pschometric Properties* (Vähäsarja et al., 2024?). The data were collected as a part of the Helsinki Health Study (helsinki.fi/hhs), an epidemiological study started in 2000.

# What is DASS?

The Depression, Anxiety and Stress Scales (DASS-42) is a public domain questionnaire intended to measure and differentiate affective symptoms. The shortened DASS-21 has later become popular, particularly for research. It has appeared in thousands of original research articles and been translated to more than forty languages.

Questionnaire data is tricky. We investigated whether or not the new Finnish translation works among Finns as it is expected to. If the factor structure or reported symptoms significantly deviated from English-speaking populations, the DASS-21 could not have been employed.

# **SCRIPTS**

<div style="text-align: left;">

# 1. Preprocessing

## < preprocessData.R >

- This script preprocesses the data. It compares the full data to a set of conditions:
  1. The person had to participate in 2022.
  2. The person may be missing at most one item in each DASS-21 subscale: depression, anxiety and stress.
  3. The person may not miss any items for the RAND-36.  
- Input:
  - 2 SAS files: contain the DASS-21, the RAND-36 and demographic variables for each cohort.
- Output:
  1. < chosenData.Rdata >  - contains the chosen data (dataframe)
  2. < fullData.Rdata >    - contains the full data set (dataframe) alongside a boolean vector for inclusion
      - needed to assess nonparticipation

## < createDASS21Data.R >

- This script further trims the chosen data down, as certain script (e.g. cfa.R) require no demographic variables.
- Input:
  -  < chosenData.Rdata >    - chosen data for both cohorts
- Output:
  1. < dass >   [list of 2 DFs]     DASS-21 data for each cohort.
  2. < scales > [list of 2 DFs]     DASS-21 sum scores (subscales) for each cohort.
  3. < suomi >  [list of 2 vectors] TRUE = answered in Finnish, FALSE = not.

## < defineModels.R >

- output: < models.Rdata >
  - necessary for < cfa.R >

# 2. Exploration

## < table1.R > 

- Input: 1 R.data file with the chosen data for each cohort.
- Output: Table 1 with the demographic information of the study population.

## < sampleFormation.R >

- Input: 1 R.data file with the full data for each cohort.
- Output: A visR diagram showing the sample formation in each cohort.
 
# 3. Analyses and visualisation

## < powerAnalyses.R >

- Estimates the power necessary to carry out the analyses.

## < cfa.Rdata >

- Investigates the structural validity of the data.
- Produces:
  - confirmatory factor analyses (CFA)
  - tables and figures from the CFA
  - estimation of the number of factors
  - residual matrices after the 3+1 bifactor solution
  - other visualisations

# 4. Producing normative data

# 5. Subscripts

<div style="text-align: center;">

# **DATA**

_Note: the raw data is not available due EU privacy laws. The functions that handle the data are provided.
_

<div style="text-align: left;">

## < models.Rdata > (list of 5 objects)

- contains the 5 models tested by the CFA
- used with lavaan

## < scaleLocs.Rdata > (3x7 data frame)

- contains the locations of the DASS items that measure each of the subscales: depression, anxiety and stress

