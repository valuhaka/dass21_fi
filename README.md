<h1 align="center"> Depression Anxiety Stress Scales (DASS-21) for Finnish-speaking adults: validation and normative data </h1> <br>
<p align="center">
  <a href="https://helsinki.fi/hhs/">
    <img alt="The DASS-21 Finnish Validation" title="The DASS-21 Finnish Validation" src="https://www.helsinki.fi/assets/drupal/styles/hero_image/s3/media-image/HHS_metro.jpg.webp?itok=wOMorWTB" width="600">
  </a>
</p>
  
## Project description

This folder will contain the code used to analyse the DASS-21 questionnaire for an upcoming article by Vähäsarja et al. The data were collected as a part of the [Helsinki Health Study](helsinki.fi/hhs), an epidemiological study started in 2000.

## Table of Contents

- [What is DASS?](#what-is-dass)
- [Scripts](#scripts)
  - [1. Preprocessing](#1-preprocessing)
  - [2. Exploration](#1-preprocessing)
  - [3. Analyses and visualisation](#1-preprocessing)
  - [4. Producing normative data](#1-preprocessing)
  - [5. Subscripts](#1-preprocessing)
- [Data](#data)


## What is DASS?

The Depression, Anxiety and Stress Scales (DASS-42) is a public domain questionnaire intended to measure and differentiate affective symptoms. The shortened DASS-21 has later become popular, particularly for research. It has appeared in thousands of original research articles and been translated to more than forty languages.

Questionnaire data is tricky. We investigated whether or not the new Finnish translation works among Finns as it is expected to. If the factor structure or reported symptoms significantly deviated from English-speaking populations, the DASS-21 could not have been employed.

# Scripts

<div style="text-align: left;">

## 1. Preprocessing

### < preprocessData.R >

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

### < createDASS21Data.R >

- This script further trims the chosen data down, as certain script (e.g. cfa.R) require no demographic variables.
- Input:
  -  < chosenData.Rdata >    - chosen data for both cohorts
- Output:
  1. < dass >   [list of 2 DFs]     DASS-21 data for each cohort.
  2. < scales > [list of 2 DFs]     DASS-21 sum scores (subscales) for each cohort.
  3. < suomi >  [list of 2 vectors] TRUE = answered in Finnish, FALSE = not.

### < defineModels.R >

- output: < models.Rdata >
  - necessary for < cfa.R >

## 2. Exploration

### < table1.R > 

- Input: 1 R.data file with the chosen data for each cohort.
- Output: Table 1 with the demographic information of the study population.

### < psychometrics.R > 

- Input: < dass.Rdata >, < scaleLocs.Rdata >.
- Calls on < psychometricsSubs.R >
- Outputs:
  1. A formatted table of the psychometric properties and distribution of the DASS-21 data in the two cohorts.
  2. A formatted table of the differnece in properties between Finnish and non-Finnish answers in the two cohorts.

### < sampleFormation.R >

- Input: 1 R.data file with the full data for each cohort.
- Output: A visR diagram showing the sample formation in each cohort.
 
## 3. Analyses and visualisation

### < powerAnalyses.R >

- Estimates the power necessary to carry out the analyses.

### < cfa.R >

- Investigates the structural validity of the data.
- Produces:
  - confirmatory factor analyses (CFA)
  - tables and figures from the CFA
  - estimation of the number of factors
  - residual matrices after the 3+1 bifactor solution
  - other visualisations
 
### < criterionValidity.R >

- Takes < chosenData.Rdata > and < dass.Rdata >.
- Correlates each DASS-21 subscale (D, A, S, GD) with each of the RAND-36 scales.
- Outputs the correlation table in nice_table format.

### < measurementInvariance.R >

- Takes < chosenData.Rdata >, < dass.Rdata >, < cfaModels.Rdata >, and < scaleLocs.Rdata >.
- Compares men and women's DASS-21 factor structure following [Schoot et al.'s (2012)](https://doi.org/10.1080/17405629.2012.686740) checklist.
- - Outputs the invariance analysis table in nice_table format.

### < prevalence.R >

- Takes < chosenData.Rdata > and < dass.Rdata >.
- Creates a table of mean values in each subscale (D, A, S, GD) among men and women in both cohorts with a t-test comparison.
- Outputs the table in nice_table format.
 
### < attritionAnalyses.R >

- Takes < fullData.Rdata >.
- Defines attrition as missing the 2022 questionnaire.
- Transforms the education, marital status and SES variables.
- Produces attrition tables using < attritionSub.R > from subscripts.
- Outputs it in nice_table format.

## 4. Producing normative data

### < makeNorms.R >

- Takes < dass.Rdata >.
- Defines the function "generatePRs".
- Uses it to generate two dataframes, which compare DASS-21 scores with their respective percentile ranks in the two cohorts.
- Outputs them in nice_table format.

## 5. Subscripts

### < attritionSub.R >

- Contains two functions.
  1. addRelativePortion(x)
    - Writes the relative portion of cases after a value.
    - Required by the function below.
  3. makeAttrTable(data, contBool, attrition)
    - Takes a data frame and two index vectors.
      - "data" contains demographic variables of the subjects.
      - "contBool" defines which columns in the data are continuous.
      - "attrition" defines which subjects fell to attrition between 2017 and 2022.
    - Outputs an attrition table in data.frame format.

### < psychometricsSubs.R >

- Contains one function.
  - psychometricsTable(dass, scaleLocs, finnish)
    - Required by < psychometrics.R >.
    - Takes DASS data, scale locations and a boolean to determine the sample (Finnish or not).
    - Outputs a list of three objects: a raw data.frame, a formatted data.frame, and a list of Ns.

<div style="text-align: center;">

# Data

<div style="text-align: left;">

### < cfaModels.Rdata > (1 list of 5 objects)

- contains the 5 models tested by the CFA
- used with lavaan

### < scaleLocs.Rdata > (a 3x7 data frame)

- contains the locations of the DASS items that measure each of the subscales: depression, anxiety and stress

----
#### _Note: the following data is not available due to EU privacy laws. The functions that handle the data are provided._

### < fullData.Rdata > (2 lists of 2)

- "data": a list of two data.frames containing DASS-21, RAND-36 and demographic variables in both cohorts.
- "fulfillsAllConditions": a list of two boolean vectors denoting which subjects fulfill all inclusion criteria in each cohort.

### < chosenData.Rdata > (2 lists of 2)

- "data": a list of two data.frames containing DASS-21, RAND-36 and demographic variables in both cohorts, excluding those that do not fulfill the inclusion criteria.

### < dass.Rdata > (4 lists of 2)

- "dass": a list of DASS-21 data in the two cohorts.
- "id": a list of the IDs for the subjects in the two cohorts.
- "scales": a list of the DASS-21 subscale sumscores in the two cohorts.
- "suomi": a list of two boolean vectors denoting which subjects answered in Finnish in each cohort.

