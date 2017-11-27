########################################################################################################################
## IPRT Educational Attainment Analysis ################################################################################
########################################################################################################################

# Authors:
# Donal O'Donoghue - d.l.odonoghue@gmail.com
# Oisin Leonard - oisin.leonard@gmail.com

#####################
## Script Overview ##
#####################

# This script was developed for the 2017 Autumn DataKind DUB sprint in collaboration with the IPRT
# This script is dedicated to analyse the educational attainment of the prison survey data
# The output of this script is a variety of visualisations such as bar charts and line charts 
# and six data frames which store difference of proportion tests on education attainment

# It is highly recommended that any DataKind members using this script in the future reads 
# "DataKind Report on the Irish Penal Reform Trust Surveys of the Limerick, Midlands and Wheatfield prison" 
# As this is a very long script with many details and intricacies that are understood easier in the context of the final report

# There five broad sections to script

# (1) - "Processing CSO data"
#     - the 2016 CSO dataset is processed to have compatable scales and levels with the Survey data
#     - this includes:
#     - adding comparable age categories for each of the three prisons
#     - mapping the education complete attribute to ISCED standards

# (2) - "Processing Survey Data"
#     - the survey data is process to have compatable scales and levels with the CSO data
#     - this includes:
#     - defining new compatable age categories for the three prisons
#     - mapping the education attainment to the ISCED standards

# (3) - "Chapter 2: Comparing National and Combined Prison Populations"
#     - Compare the National and Prison Populations excluding Age
#     - Compare the National and Prison Populations by Age

# (4) - "Chapter 3: Comparing Each Individual Prison with each other"
#     - Compare the each Prison excluding Age
#     - Compare the each Prison by Age

# (5) - "Chapter 4: Comparing each individual with the general population"
#     - Compare the National and each Prison Population excluding Age
#     - Compare the National and each Prison Population by Age

#-- IMPORTANT NOTES --#

# NOTE I
# Some basic data cleaning was conducted on the survey data prior to this R analysis
# make sure the survey data is clean, consistent and compatable with this analysis
# In particular, the school experience attribute should only have the following levels
# (i) "I didn't go to secondary school."
# (ii) "I left school before the Junior/Inter Cert."
# (iii) "I left school after the Junior/Inter Cert."
# (iv) "I have gone to college/university."
# (v) "I have gone to college/university."
# If the data loaded in is correct, the whole analysis should run through without issues

# NOTE II
# As there were only 14 Women surveyed in the data
# This quantity is too small for us to derive any meaningful inferences from
# Thus there was no anaysis into the interaction effect of Educational Attainment and Gender

# NOTE III
# When taking into consideration the age of prisoners
# the approximation for the test staistic of the test 
# for some of the difference of proportions tests 
# may be inaccurate  due a lack of observations.

# NOTE IV
# Limerick prison incorporated different age levels when conducting the survey
# This will have an effect when comparing education attainment between the prisons by age
# To solve this, common age categories between the prisons will be created
# The data will then be summarise over these common age categories

# NOTE V 
# The plots are standardised to proportions based on the total prison population
# The proportion tests are standardised based on the specific age category
# Also the proportions tested correspond to the same proportions in the visulaisations

###################
## Preliminaries ##
###################

#-- Load in the relevant R libraries --#

# ggplot and dplyr will be utilised from the tidyverse package for all data manipulation and data visualisations
library(tidyverse)
# the datakindr package will be used specifically for the dk_theme in the visualisations
library(datakindr)
# the scales package will be used for scaling proportions to percentages in the visualisations
library(scales)

#-- Set the Working Directory --#

# The working directory will be set to facilitate easy loading and saving of data into R and out of R.
# Return the current working directory
getwd()
# set the working directory to where the survey and prison data are located 
setwd("C:/Users/Margaret/Documents/Oisin/DataKind/IPRT/Data")
# load in the raw CSO data and the raw Survey Data
raw_CSO_data <- read.csv(file = "raw_data.csv")
raw_prison_data <- read.csv(file = "MID_LIM_WHT_Data.csv")

######################################################################################################################
## Processing the CSO data ###########################################################################################
######################################################################################################################

#-- Notes on the CSO data --#

# Data on education attainment of the general population was downloaded from the CSO website
# the data was collect during the 2016 census
# The code of the database storing this data on the CSO website is "EZ055"

# As the CSO data stores age numerically
# Appropriate age levels with respect to the data collect from each prison will be first added into the dataset
# The data will be then aggragate up into four CSV dataset 
# that can be easily used in relation to each prison and the combined prison population

# There are nine steps to processing the CSO data:

# Step I
# First filter out the irrelevant data levels
levels(raw_CSO_data$Level.of.Ed.)
# The following levels are no relevant to this analysis
# (1) Economic status - other
# (2) Economic status - total at school, universoty, etc.
# (3) Totaleducation ceased and not ceased

# Step II
# Add in the age levels for Limerick Prison
summary(subset(x = raw_prison_data, subset = SITE == "LIM", select = Age))
# Need to add in the following levels
# (1) 18-25
# (2) 26-35
# (3) 36-50
# (4) 51+


# Step III
# Add in the age levels for the Midlands Prison
summary(subset(x = raw_prison_data, subset = SITE == "MID", select = Age))
# Need to add in the following levels
# (1) 18-21
# (2) 22-25
# (3) 26-35
# (4) 36-49
# (5) 50-64
# (6) 65+

# Step IV
# Add in  age levels for Wheatfield Prison
summary(subset(x = raw_prison_data, subset = SITE == "WHT", select = Age))
# Need to add in the following levels
# (1) 17-21
# (2) 22-25
# (3) 26-35
# (4) 36-49
# (5) 50-64

# Step V
# Add in age levels for the combined Prison population
# Needto add in levels that apply to all three prisons
# (1) <26
# (2) 26-35
# (3) 36-49
# (4) 50+

# Step VI & VII
# Add in ISCED levels and the corresponding Education Attainment Levels
# There are 6 grouped ISCED levels
# (1) 0-1       -> No Formal Education or Primary Education
# (2) 2         -> Lower Secondary Education
# (3) 3         -> Upper Secondary Education
# (4) 4-8       -> Third Level Education
# (5) 2-5       -> Technical / Vocational Education
# (6) Unknown   -> Unknown

# Step VIII
# Add in relevant age levels for comparing midlands and general population
# level the following levels are recategorised for this comparison
# (1) 17-21, 18-21, 22-25 -> <26
# (2) 50-64, 51+, 65+ -> "50+"

# Step IX
# Add in relevant age levels for comparing wheatfield and general population
# level the following levels are recategorised for this comparison
# (1) 17-21, 18-21, 22-25 -> <26
# (2) 50-64, 51+, 65+ -> "50+"

#-- Process the CSO Data --#

CSO_aggr_age_edu <- raw_CSO_data %>%
  # Step I
  # First filter out the irrelevant data levels
  # Note: the remove of "Technical/Vocational"
  filter(Level.of.Ed. != "Total education ceased and not ceased"  , 
         Level.of.Ed. != "Economic status - total at school, university, etc." , 
         Level.of.Ed. != "Economic status - other",
         Level.of.Ed. != "Technical/vocational") %>%
  # Step II
  # Add in the age levels for Limerick Prison
  mutate(Age_LIM = ordered(case_when(.$Age %in% c("18 years", "19 years", "20 years", "21 years", "22 years", 
                                                  "23 years", "24 years", "25 years") ~ "18-25",
                                     .$Age %in% c("26 years", "27 years", "28 years", "29 years", "30 years", "31 years",
                                                  "32 years", "33 years", "34 years", "35 years") ~ "26-35",
                                     .$Age %in% c("36 years", "37 years", "38 years", "39 years", "40 years", "41 years",
                                                  "42 years", "43 years", "44 years", "45 years", "46 years", "47 years",
                                                  "48 years", "49 years", "50 years") ~ "36-50",
                                     .$Age %in% c("50 years", "51 years", "52 years", "53 years", "54 years", "55 years",
                                                  "56 years", "57 years", "58 years", "59 years", "60 years", "61 years",
                                                  "62 years", "63 years", "64 years", "65 years", "66 years", "67 years",
                                                  "68 years", "69 years", "70 years", "71 years", "72 years", "73 years",
                                                  "68 years", "69 years", "70 years", "71 years", "72 years", "73 years",
                                                  "74 years", "75 years", "76 years", "77 years", "78 years", "79 years",
                                                  "80 years", "81 years", "82 years", "83 years", "84 years", "85 years and over") ~ "51+"))) %>%
  # Step III
  # Add in the age levels for the Midlands Prison
  mutate(Age_MID = ordered(case_when(.$Age %in% c("18 years", "19 years", "20 years", "21 years") ~ "18-21",
                                     .$Age %in% c("22 years", "23 years", "24 years", "25 years") ~ "22-25",
                                     .$Age %in% c("26 years", "27 years", "28 years", "29 years", "30 years", "31 years",
                                                  "32 years", "33 years", "34 years", "35 years") ~ "26-35",
                                     .$Age %in% c("36 years", "37 years", "38 years", "39 years", "40 years", "41 years",
                                                  "42 years", "43 years", "44 years", "45 years", "46 years", "47 years",
                                                  "48 years", "49 years") ~ "36-49",
                                     .$Age %in% c("50 years", "51 years", "52 years", "53 years", "54 years", "55 years",
                                                  "56 years", "57 years", "58 years", "59 years", "60 years", "61 years",
                                                  "62 years", "63 years", "64 years") ~ "50-64",
                                     .$Age %in% c("65 years", "66 years", "67 years", "68 years", "69 years", "70 years", 
                                                  "71 years", "72 years", "73 years", "68 years", "69 years", "70 years", 
                                                  "71 years", "72 years", "73 years", "74 years", "75 years", "76 years", 
                                                  "77 years", "78 years", "79 years", "80 years", "81 years", "82 years", 
                                                  "83 years", "84 years", "85 years and over") ~ "65+"))) %>% 
  # Step IV
  # Add in  age levels for Wheatfield Prison
  mutate(Age_WHT = ordered(case_when(.$Age %in% c("17 years", "18 years", "19 years", "20 years", "21 years") ~ "17-21",
                                     .$Age %in% c("22 years", "23 years", "24 years", "25 years") ~ "22-25",
                                     .$Age %in% c("26 years", "27 years", "28 years", "29 years", "30 years", "31 years",
                                                  "32 years", "33 years", "34 years", "35 years") ~ "26-35",
                                     .$Age %in% c("36 years", "37 years", "38 years", "39 years", "40 years", "41 years",
                                                  "42 years", "43 years", "44 years", "45 years", "46 years", "47 years",
                                                  "48 years", "49 years") ~ "36-49",
                                     .$Age %in% c("50 years", "51 years", "52 years", "53 years", "54 years", "55 years",
                                                  "56 years", "57 years", "58 years", "59 years", "60 years", "61 years",
                                                  "62 years", "63 years", "64 years") ~ "50-64"))) %>%
  # Step V
  # Add in age levels for the combined Prison population
  mutate(Age_COM = ordered(case_when(.$Age %in% c("17 years", "18 years", "19 years", "20 years", "21 years", "22 years",
                                                  "23 years", "24 years", "25 years", "26 years") ~ "<26",
                                     .$Age %in% c("26 years", "27 years", "28 years", "29 years", "30 years", "31 years",
                                                  "32 years", "33 years", "34 years", "35 years") ~ "26-35",
                                     .$Age %in% c("36 years", "37 years", "38 years", "39 years", "40 years", "41 years",
                                                  "42 years", "43 years", "44 years", "45 years", "46 years", "47 years",
                                                  "48 years", "49 years", "50 years") ~ "36-50",
                                     .$Age %in% c("50 years", "51 years", "52 years", "53 years", "54 years", "55 years",
                                                  "56 years", "57 years", "58 years", "59 years", "60 years", "61 years",
                                                  "62 years", "63 years", "64 years", "65 years", "66 years", "67 years",
                                                  "68 years", "69 years", "70 years", "71 years", "72 years", "73 years",
                                                  "68 years", "69 years", "70 years", "71 years", "72 years", "73 years",
                                                  "74 years", "75 years", "76 years", "77 years", "78 years", "79 years",
                                                  "80 years", "81 years", "82 years", "83 years", "84 years", "85 years and over") ~ "51+"))) %>%
  # Step VI
  # Add in ISCED levels
  mutate(ISCED_lvls = ordered(case_when(.$ISCED %in% c("0", "1") ~ "0-1",
                                        .$ISCED == "2" ~ "2",
                                        .$ISCED == "3" ~ "3",
                                        .$ISCED == "2-5" ~ "2-5",
                                        .$ISCED %in% c("4", "5", "6", "7", "8") ~ "4-8",
                                        .$ISCED == "Unknown" ~ "Unknown"))) %>% 
  # Step VII
  # Add in the corresponding Education Attainment Levels
  mutate(Edc.Att = ordered(case_when(.$ISCED_lvls == "0-1" ~ "Primary (inc. no formal education)",
                                     .$ISCED_lvls == "2" ~ "Lower secondary",
                                     .$ISCED_lvls == "3" ~ "Upper secondary",
                                     .$ISCED_lvls == "4-8" ~ "Third level non degree or more",
                                     .$ISCED_lvls == "2-5" ~ "Technical/vocational",
                                     .$ISCED_lvls == "Unknown" ~ "Unknown"))) %>%
  # Step VIII
  # Add in relevant age levels for comparing midlands and general population
  mutate(AGE_MIDGEN = ordered(case_when(.$Age_MID %in% c("18-21", "17-21", "18-25", "22-25") ~ "<26",
                                        .$Age_MID == "26-35" ~ "26-35",
                                        .$Age_MID %in% c("36-49", "36-50") ~ "36-49",
                                        .$Age_MID %in% c("50-64", "51+", "65+") ~ "50+"))) %>%
  # Step IX
  # Add in relevant age levels for comparing wheatfield and general population
  mutate(AGE_WHTGEN = ordered(case_when(.$Age_WHT %in% c("18-21", "17-21", "18-25", "22-25") ~ "<26",
                                        .$Age_WHT == "26-35" ~ "26-35",
                                        .$Age_WHT %in% c("36-49", "36-50") ~ "36-49",
                                        .$Age_WHT %in% c("50-64", "51+", "65+") ~ "50+")))

#-- Construct the Appropriate Education Datasets --#

# the following 7 CSO datasets are all used for specific cases
# where the prison population or some subset of the prison data 
# is compared with the general population (or CSO data)
# the various comparisons require specific age categories
# In other words, the following 7 CSO datasets are constructed 
# with different age categories and prison populations in mind

# (1) Limerick Prison 
# -> for comparing Limerick prison and the general population
CSO_LIM <- CSO_aggr_age_edu %>% 
  # filter out any missing values
  filter(!is.na(Age_LIM)) %>%
  # select the relevant attributes
  select(Edc.Att, ISCED_lvls, Age_LIM, Total, Male, Female) %>%
  # group by the appropriate attributes
  group_by(Edc.Att, ISCED_lvls, Age_LIM) %>%
  # aggregate the data up
  summarise(Total = sum(Total),
            Male = sum(Male),
            Female = sum(Female))
# check data has been aggregated up correctly
head(CSO_LIM)

# (2i) Midlands Prison
# -> for comparing Midlands prion and the general population
CSO_MID <- CSO_aggr_age_edu %>% 
  # filter out any missing values
  filter(!is.na(Age_MID)) %>%
  # select the relevant attributes
  select(Edc.Att, ISCED_lvls, Age_MID, Total, Male, Female) %>%
  # group by the appropriate attributes
  group_by(Edc.Att, ISCED_lvls, Age_MID) %>%
  # aggregate the data up
  summarise(Total = sum(Total),
            Male = sum(Male),
            Female = sum(Female))
# check data has been aggregated up correctly
head(CSO_MID)

# (2ii) Midlands Prison 
# -> for comparing Midlands prison and the general population with redefined age categories
CSO_MIDGEN <- CSO_aggr_age_edu %>% 
  # filter out any missing values
  filter(!is.na(AGE_MIDGEN)) %>%
  # select the relevant attributes
  select(Edc.Att, ISCED_lvls, AGE_MIDGEN, Total, Male, Female) %>%
  # group by the appropriate attributes
  group_by(Edc.Att, ISCED_lvls, AGE_MIDGEN) %>%
  # aggregate the data up
  summarise(Total = sum(Total),
            Male = sum(Male),
            Female = sum(Female))
# check data has been aggregated up correctly
head(CSO_MIDGEN)

# (3i) Wheatfield Prison 
# -> for comparing Wheatfield prison and the genral population
CSO_WHT <- CSO_aggr_age_edu %>% 
  # filter out any missing values
  filter(!is.na(Age_WHT)) %>%
  # select the relevant attributes
  select(Edc.Att, ISCED_lvls, Age_WHT, Total, Male, Female) %>%
  # group by the appropriate attributes
  group_by(Edc.Att, ISCED_lvls, Age_WHT) %>%
  # aggregate the data up
  summarise(Total = sum(Total),
            Male = sum(Male),
            Female = sum(Female))
# check data has been aggregated up correctly
head(CSO_WHT)

# (3ii) Wheatfield Prison 
# -> for comparing wheatfield prison and the general population with redefined age categoies
CSO_WHTGEN <- CSO_aggr_age_edu %>% 
  # filter out any missing values
  filter(!is.na(AGE_WHTGEN)) %>%
  # select the relevant attributes
  select(Edc.Att, ISCED_lvls, AGE_WHTGEN, Total, Male, Female) %>%
  # group by the appropriate attributes
  group_by(Edc.Att, ISCED_lvls, AGE_WHTGEN) %>%
  # aggregate the data up
  summarise(Total = sum(Total),
            Male = sum(Male),
            Female = sum(Female))
# check data has been aggregated up correctly
head(CSO_WHTGEN)

# (4i) Combined Prisons
# -> for comparing the combined prison population and the general population
CSO_COM <- CSO_aggr_age_edu %>% 
  # filter out any missing values
  filter(!is.na(Age_COM)) %>%
  # select the relevant attributes
  select(Edc.Att, ISCED_lvls, Age_COM, Total, Male, Female) %>%
  # group by the appropriate attributes
  group_by(Edc.Att, ISCED_lvls, Age_COM) %>%
  # aggregate the data up
  summarise(Total = sum(Total),
            Male = sum(Male),
            Female = sum(Female))
# check data has been aggregated up correctly
head(CSO_COM)

# (4ii) Combined Prisons for Chap 4 (Ex. "Unknown ISCED_lvl")
# -> for comparing each prison with the individual prison populations
CSO_IND <- CSO_aggr_age_edu %>% 
  # filter out any missing values
  filter(!is.na(Age_COM)) %>%
  filter(ISCED_lvls != "Unknown") %>%
  # select the relevant attributes
  select(Edc.Att, ISCED_lvls, Age_COM, Total, Male, Female) %>%
  # group by the appropriate attributes
  group_by(Edc.Att, ISCED_lvls, Age_COM) %>%
  # aggregate the data up
  summarise(Total = sum(Total),
            Male = sum(Male),
            Female = sum(Female))
# check data has been aggregated up correctly
head(CSO_IND)

########################################################################################################################
## Processing Survey Data ##############################################################################################
########################################################################################################################

# There are eight steps rquired to fully process the Survey Data:

# Step I
# Subset the relevant prison features from the Data
#  -  SITE, Gender, Age, school_expirence
str(raw_prison_data)

# Step II
# Add in the appropriate ISCED levels
# "0-1" = No Formal Education or Primary Education
# "2" = Lower Secondary Education
# "3" = Upper Secondary Education
# "4-8" = Third Level Education
# "2-5" = Technical / Vocation Education 
levels(raw_prison_data$ISCED_lvls)
levels(raw_prison_data$school_experience)

# Step III
# Add in the appropriate Age levels for the combined Prison Population
levels(raw_prison_data$Age)
levels(CSO_COM$Age_COM)
# Note the different Age levels

# Step IV
# Add in relevant age levels for comparing Limerick and wheafield prison
summary(subset(x = raw_prison_data, subset = SITE == "LIM", select = Age))
summary(subset(x = raw_prison_data, subset = SITE == "WHT", select = Age))
# Note the different Age levels

# Step V
# Add in relevant age levels for comparing Limerick and Midlands Prison
summary(subset(x = raw_prison_data, subset = SITE == "LIM", select = Age))
summary(subset(x = raw_prison_data, subset = SITE == "MID", select = Age))
# Note the different Age levels

# Step VI
# Add in relevant age levels for comparing Wheatfield and Midlands prison
summary(subset(x = raw_prison_data, subset = SITE == "WHT", select = Age))
summary(subset(x = raw_prison_data, subset = SITE == "MID", select = Age))
# Note the different Age levels

# Step VII
# Add in relevant age levels for comparing Midlands and general population
summary(subset(x = raw_prison_data, subset = SITE == "MID", select = Age))
levels(CSO_MIDGEN$AGE_MIDGEN)
# In this case Age categories 18-21 & 22-25 will be combined into a <26 category

# Step VIII
# Add in relevant age levels for comparing wheatfield and general population
summary(subset(x = raw_prison_data, subset = SITE == "WHT", select = Age))
levels(CSO_WHTGEN$AGE_WHTGEN)
# In this case Age categories 17-21 & 22-25 will be combined into a <26 category

#-- Process the Survey Data --#

PRIS_COM <-
  raw_prison_data %>%
  # Step I
  # Select the relevant Prison features 
  select(SITE, Age, school_experience) %>% 
  # Step II
  # add ISCED levels to prison data
  mutate(ISCED = ordered(case_when(.$school_experience %in%
                                     c("I didn't go to secondary school.",
                                       "I left school before the Junior/Inter Cert.") ~ "0-1",
                                   .$school_experience ==
                                     "I left school after the Junior/Inter Cert." ~ "2",
                                   .$school_experience == 
                                     "I left school after the Leaving Cert." ~ "3",
                                   .$school_experience %in%
                                     "I have gone to college/university." ~ "4-8",
                                   .$school_experience == "Unclear" ~ "Unknown"))) %>%
  # Step III
  # Add in relevant age levels for Combined Prison data
  mutate(Age_COM = ordered(case_when(.$Age %in% c("17-21", "18-21", "18-25", "22-25") ~ "<26",
                                     .$Age == "26-35" ~ "26-35",
                                     .$Age %in% c("36-49", "36-50") ~ "36-50",
                                     .$Age %in% c("51+", "50-64", "65+") ~ "51+"))) %>%
  # Step IV
  # Add in relevant age levels for comparing Limerick and wheafield prison
  mutate(Age_LIMWHT = ordered(case_when(.$Age %in% c("17-21", "18-21", "18-25", "22-25") ~ "<26",
                                        .$Age == "22-25" ~ "22-25",
                                        .$Age == "26-35" ~ "26-35",
                                        .$Age %in% c("36-49", "36-50") ~ "36-50",
                                        .$Age %in% c("50-64", "51+", "65+") ~ "51+"))) %>%
  # Step V
  # Add in relevant age levels for comparing Limerick and Midlands Prison
  mutate(Age_LIMMID = ordered(case_when(.$Age %in% c("17-21", "18-21", "18-25", "22-25") ~ "<26",
                                        .$Age == "26-35" ~ "26-35",
                                        .$Age %in% c("36-49", "36-50") ~ "36-50",
                                        .$Age %in% c("50-64", "51+", "65+") ~ "51+"))) %>%
  # Step VI
  # Add in relevant age levels for comparing Wheatfield and Midlands prison
  mutate(Age_WHTMID = ordered(case_when(.$Age %in% c("17-21", "18-21", "18-25", "22-25") ~ "<26",
                                        .$Age == "26-35" ~ "26-35",
                                        .$Age == "36-49" ~ "36-49",
                                        .$Age %in% c("50-64","51+", "65+") ~ "50+"))) %>%
  # Step VII
  # Add in relevant age levels for comparing midlands and general population
  mutate(AGE_MIDGEN = ordered(case_when(.$Age %in% c("18-21", "22-25") ~ "<26",
                                        .$Age == "26-35" ~ "26-35",
                                        .$Age == "36-49" ~ "36-49",
                                        .$Age %in% c("50-64", "65+") ~ "50+"))) %>%
  # Step VIII
  # Add in relevant age levels for comparing wheatfield and general population
  mutate(AGE_WHTGEN = ordered(case_when(.$Age %in% c("18-21", "17-21", "18-25", "22-25") ~ "<26",
                                        .$Age == "26-35" ~ "26-35",
                                        .$Age %in% c("36-49", "36-50") ~ "36-49",
                                        .$Age %in% c("50-64", "51+", "65+") ~ "50+")))

summary(PRIS_COM)

########################################################################################################################
## Chapter 2: Comparing National and Combined Prison Populations #######################################################
########################################################################################################################

# There are Two Sections to Chapter 2:
# - Compare National and Prison Populations excluding Age
# - Compare National and Prison Populations by Age

###########################################################
## Compare National and Prison Populations excluding Age ##
###########################################################

#-- Process the Data --#

# Prison Data
# Summarise over the total prisoner population by ISCED levels to get count totals
PRIS_COM_EDU <-
  PRIS_COM %>%
  # Group by ISCED Levels
  group_by(ISCED) %>%
  # Count up the number of observations in each group
  # Convert total into a proportion / percentage
  summarise(Total = n(),
            Prcnt = Total/dim(PRIS_COM)[1])
head(PRIS_COM_EDU)

# CSO data
# Summerise over CSO data by ISCED levels
CSO_COM_EDU <- 
  CSO_COM %>%
  # select the relevant features
  select(ISCED_lvls, Total) %>%
  # Group by ISCED Levels
  group_by(ISCED_lvls) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_COM$Total))
# Rename ISCED_lvls to assist in merging the two tables
colnames(CSO_COM_EDU)[1] <- "ISCED"
head(CSO_COM_EDU)

# Merge the CSO and Prison Datasets
# Add in prison and general label to distinuish between the two populations
PRIS_COM_EDU$Population <- "Prison"
CSO_COM_EDU$Population  <- "General"
COM_EDU <- rbind(PRIS_COM_EDU, CSO_COM_EDU)
head(COM_EDU)

#-- Visualisation --#

# Create a bar chart visualisation comparing the combined prison population with 
# the general population

ggplot(COM_EDU, aes(ISCED, Prcnt, fill = Population)) +
  geom_bar(stat = "identity", position = position_dodge())  +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -1, colour = "black", size = 2.5) +
  expand_limits(y = c(0.0, 1)) +
  # give the bar chart a title
  ggtitle("General Population vs Prison Population: Highest Level of Education Completed") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  # Incorporate the dk_theme from the datakindr package
  dk_theme +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))

# Save the Plot
ggsave("EduAtt_Ptison_vs_GenPop.pdf",
       width = 8, height = 6, units = c("in"))

#-- Difference of Proportions Test

# I shall now perform a difference of proportions test
# to test whether there is a differnce in the level of education achieved 
# between the general population and the total prison population
# First check that the general population and combined prison population are proportional
length(CSO_COM_EDU$Total)
length(PRIS_COM_EDU$Total)
# All prison datasets are proportional and have corresponding totals

# Test Hypotheses
# Ho: the proportions are equal
# Ha: the proportions are not equal

# Create Data Frame to hold the proportion tests
proptest1i <- as.data.frame(matrix(nrow = 5, ncol = 4))
# Set column names
colnames(proptest1i) <- c("Education Level", "Proportion 1: General",
                          "Proportion 2: Prison", "P-Value")
# run a for loop to fill in the data frame
for(i in 1:nrow(CSO_COM_EDU)) {
  # select the appropiate counts to be tested
  X <- c(CSO_COM_EDU$Total[i], PRIS_COM_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(CSO_COM_EDU$Total), sum(PRIS_COM_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in education level
  proptest1i$`Education Level`[i] <- levels(CSO_COM_EDU$ISCED)[i]
  # Fill in the first proportion
  proptest1i$`Proportion 1: General`[i] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest1i$`Proportion 2: Prison`[i] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest1i$`P-Value`[i] <- round(proptest[[3]], digits = 3)
}
# Write Prortion Test 1: General Population vs Combined Prison Population to a csv file
write.csv(x = as.matrix(proptest1i), file = "prop.test1i.csv", row.names = F, quote = F)

########################################################################################
# Educational progress National level Prison vs General Pop   --------------------- ####
########################################################################################

# create feature identifying different stages of education
combined_prison_edu_progress <-
  #raw_prison_data %>%
  #select(SITE, school_experience) %>%
  PRIS_COM %>%
  select(SITE, Age_COM, school_experience) %>%
  mutate(EduProgress =
           case_when(.$school_experience %in%
                       c("I didn't go to secondary school.") ~ "Attends Primary",
                     .$school_experience == 
                       "I left school before the Junior/Inter Cert." ~ "Starts Secondary",
                     .$school_experience ==
                       "I left school after the Junior/Inter Cert." ~ "Completes Junior Cert",
                     .$school_experience == 
                       "I left school after the Leaving Cert." ~ "Completes Leaving Cert",
                     .$school_experience %in%
                       c("I have gone to college/university.") ~ "Attends Third Level",
                     .$school_experience == "Unclear" ~ "Unknown"))


# create Education feature for CSO dataset
general_edu_progress <-
  CSO_COM_EDU %>%
  ungroup() %>%
  select(ISCED, Total) %>%
  mutate(EduProgress =
           case_when(.$ISCED == "0-1" ~ "Attends Primary",
                     .$ISCED == "2" ~ "Completes Junior Cert",
                     .$ISCED == "3" ~ "Completes Leaving Cert",
                     .$ISCED == "4-8" ~ "Attends Third Level",
                     .$ISCED == "Unknown" ~ "Unknown"))

# proportion of population in each group; primary or post primary
num_prisoners   <- dim(combined_prison_edu_progress)[1]
num_general_pop <- sum(general_edu_progress$Total)

all_prison_edu_progress  <-
  combined_prison_edu_progress  %>%
  group_by(EduProgress) %>%
  summarise(Total = n(),
            Prcnt = Total/num_prisoners)

general_edu_progress <-
  general_edu_progress %>%
  group_by(EduProgress) %>% 
  summarise(Total = sum(Total),
            Prcnt = Total / num_general_pop)

general_edu_progress$Population <- "General"
all_prison_edu_progress$Population  <- "Prison"

# merge general / prison stats and chart
all_edu_progress <- rbind(all_prison_edu_progress, general_edu_progress)

all_edu_progress$EduProgress <-
  factor(all_edu_progress$EduProgress,
         levels = c("Unknown", "Attends Primary", "Starts Secondary",
                    "Completes Junior Cert", "Completes Leaving Cert",
                    "Attends Third Level"))

# calc % remaining in EduProgress after each stage
all_edu_progress <-
  all_edu_progress %>%
  arrange(Population, EduProgress) %>%
  group_by(Population) %>%
  mutate(Remain = 1 - lag(cumsum(Prcnt), n = 1, default = 0))


#-- Educational progress Prison to Prison variation --#


all_prison_edu_progress <-
  combined_prison_edu_progress %>%
  group_by(SITE) %>%
  mutate(PrisonTotal = n())

diff_prison_edu <-
  all_prison_edu_progress %>%
  group_by(SITE, EduProgress) %>%
  summarise(Total = n(),
            Prcnt = Total/mean(PrisonTotal))

diff_prison_edu$EduProgress <-
  factor(diff_prison_edu$EduProgress,
         levels = c("Unknown", "Attends Primary", "Starts Secondary",
                    "Completes Junior Cert", "Completes Leaving Cert",
                    "Attends Third Level"))

# calc % remaining in education after each stage
diff_prison_edu <-
  diff_prison_edu %>%
  arrange(SITE, EduProgress) %>%
  group_by(SITE) %>%
  mutate(Remain = 1 - lag(cumsum(Prcnt), n = 1, default = 0))

all_age_group_edu_progress <-
  combined_prison_edu_progress %>%
  group_by(Age_COM) %>%
  mutate(AgeGroup_Total = n())

diff_age_group_edu <-
  all_age_group_edu_progress %>%
  group_by(Age_COM, EduProgress) %>%
  summarise(Total = n(),
            Prcnt = Total/mean(AgeGroup_Total))

diff_age_group_edu$EduProgress <-
  factor(diff_age_group_edu$EduProgress,
         levels = c("Unknown", "Attends Primary", "Starts Secondary",
                    "Completes Junior Cert", "Completes Leaving Cert",
                    "Attends Third Level"))

# calc % remaining in education after each stage
diff_age_group_edu <-
  diff_age_group_edu %>%
  arrange(Age_COM, EduProgress) %>%
  group_by(Age_COM) %>%
  mutate(Remain = 1 - lag(cumsum(Prcnt), n = 1, default = 0))

#-- Visualise General and Prison populations by Educational Progress --#

# line plot with text labels
ggplot(all_edu_progress %>% filter(EduProgress != "Unknown"),
       aes(EduProgress, Remain, group = Population)) +
  geom_line(aes(color=Population), size = 1.0, alpha = 0.8) +
  geom_point() +
  theme_minimal() + 
  geom_text(aes(label=percent(round(Remain,2))), position = position_dodge(0.5),
            vjust=-0.8, color="black", size=4) +
  expand_limits(y = c(0,1)) +
  scale_y_continuous(labels = percent) + 
  ggtitle("Stages of educational attainment") +
  xlab("Education level") +
  ylab("Portion of population") +
  dk_theme +
  theme(plot.title  = element_text(size = 14, hjust = 0.5),
        axis.text   = element_text(size = 10),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title  = element_text(size = 12),
        legend.text = element_text(size = 12)) 

ggsave("EduProgress_Prison_vs_GenPop.pdf",
       width = 8, height = 6, units = c("in"))

#-- Visualise Prison to Prison differences in Educational Progress --#

# line plot with text labels
ggplot(diff_prison_edu %>% filter(EduProgress != "Unknown"),
       aes(EduProgress, Remain, group = SITE)) +
  geom_point() +
  geom_line(aes(color=SITE), size = 1.0, alpha = 0.8) +
  geom_text(aes(label=percent(round(Remain,2))), position = position_dodge(0.5),
            vjust=-0.8, color="black", size=2.5) +
  theme_minimal() + 
  expand_limits(y = c(0,1)) +
  scale_y_continuous(labels = percent) + 
  ggtitle("Stages of educational attainment") +
  xlab("Education level") +
  ylab("Portion of population") +
  dk_theme +
  theme(plot.title  = element_text(size = 14, hjust = 0.5),
        axis.text   = element_text(size = 10),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title  = element_text(size = 12),
        legend.text = element_text(size = 12))

ggsave("EduProgress_PrisonDifferences.pdf",
       width = 8, height = 6, units = c("in"))

#-- Visualise Age group differences in Educational Progress --#

# line plot with text labels
ggplot(diff_age_group_edu %>% filter(EduProgress != "Unknown"),
       aes(EduProgress, Remain, group = Age_COM)) +
  geom_point() +
  geom_line(aes(color=Age_COM), size = 1.0, alpha = 0.8) +
  geom_text(aes(label=percent(round(Remain,2))), position = position_dodge(0.5),
            vjust=-0.8, color="black", size=2.5) +
  theme_minimal() + 
  expand_limits(y = c(0,1)) +
  scale_y_continuous(labels = percent) + 
  ggtitle("Stages of educational attainment") +
  xlab("Education level") +
  ylab("Portion of population") +
  dk_theme +
  theme(plot.title  = element_text(size = 14, hjust = 0.5),
        axis.text   = element_text(size = 10),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title  = element_text(size = 12),
        legend.text = element_text(size = 12))

ggsave("EduProgress_AgeGroup_Differences.pdf",
       width = 8, height = 6, units = c("in"))


####################################################
## Compare National and Prison Populations by Age ##
####################################################

#-- Process the Data --#

# Prison Data
# Summarise over the total prisoner population to count totals
PRIS_COM_EDU <-
  PRIS_COM %>%
  # Filter out the Unknown ISCED levels
  filter(ISCED != "Unknown") %>%
  # This time we are grouping by the ISCED and Age levels
  group_by(ISCED, Age_COM) %>%
  summarise(Total = n(),
            Prcnt = Total/dim(PRIS_COM)[1])
# rename the Age_COM column to facilitate the merge of the two tables
colnames(PRIS_COM_EDU)[2] <- "Age"
head(PRIS_COM_EDU)

# CSO data
CSO_COM_EDU <- 
  CSO_COM %>% 
  # Filter out the Unknown ISCED levels
  filter(ISCED_lvls != "Unknown") %>%
  group_by(ISCED_lvls, Age_COM) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_COM$Total))
# rename the ISCED_lvls column to facilitate the merge of the two tables
colnames(CSO_COM_EDU)[1] <- "ISCED"
# rename the Age_COM column to facilitate the merge of the two tables
colnames(CSO_COM_EDU)[2] <- "Age"
head(CSO_COM_EDU)

# Merge the CSO and PRIS datasets
# Add in prison and general label to distinuish between the two populations
PRIS_COM_EDU$Population <- "Prison"
CSO_COM_EDU$Population  <- "General"
COM_EDU <- rbind(PRIS_COM_EDU, CSO_COM_EDU)
head(COM_EDU)

#-- Visualisations

ggplot(COM_EDU, aes(ISCED, Prcnt, fill = Population)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.25)) +
  # divide the bar chart into seperate charts based on the variable age
  facet_wrap(~Age) + 
  # give the bar chart a title
  ggtitle("General Population vs Prison Population: Highest level of Education Completed by Age") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  # add in the dk_theme
  dk_theme +
  # format text
  theme(plot.title = element_text(size = 13, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))

# Save the plot
ggsave("EduAtt_Prison_vs_GenPop_by_Age.pdf",
       width = 8, height = 6, units = c("in"))

#-- Difference of Proportions Test

# I shall now perform a diffeence of proportions test
# to test whether there is a differnce in the level of education achieved 
# between the general population and the total prison population
# check that the CSO and PRIS data are proportional
length(CSO_COM_EDU$Total)
length(PRIS_COM_EDU$Total)
# All prison datasets are proportional and have corresponding totals

# Test Hypotheses
# Ho: the proportions are equal
# Ha: the proportions are not equal

# Create Data Frame to hold the proportion tests
proptest1ii <- as.data.frame(matrix(nrow = 16, ncol = 5))
# Set column names
colnames(proptest1ii) <- c("Age Level", "Education Level", "Proportion 1: General",
                           "Proportion 2: Prison", "P-Value")
# run a for loop to fill in the data frame
for(i in 1:nrow(CSO_COM_EDU)) {
  # select the appropiate counts to be tested
  X <- c(CSO_COM_EDU$Total[i], PRIS_COM_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(CSO_COM_EDU$Total), sum(PRIS_COM_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in the age level
  proptest1ii$`Age Level`[i] <- levels(PRIS_COM_EDU$Age)[PRIS_COM_EDU$Age[i]]
  # Fill in education level
  proptest1ii$`Education Level`[i] <- levels(PRIS_COM_EDU$ISCED)[PRIS_COM_EDU$ISCED[i]]
  # Fill in the first proportion
  proptest1ii$`Proportion 1: General`[i] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest1ii$`Proportion 2: Prison`[i] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest1ii$`P-Value`[i] <- round(proptest[[3]], digits = 3)
}
# Write Prortion Test 2: General Population vs Combined Prison Population by age to a csv file
write.csv(x = as.matrix(proptest1ii), file = "prop.test1ii.csv", row.names = F, quote = F)

# NOTE: we aregetting warnings for incorrect approximations
# due to a lack of observations in the data
# For example
head(PRIS_COM_EDU[PRIS_COM_EDU$Total < 20,])
# there are only 5 prisoners who are under 26 and have third level education
# this lack of data makes it differcult ti derive meangingful inferences

########################################################################################################################
## Chapter 3: Comparing Each Individual Prison with each other #########################################################
########################################################################################################################

# There are two sections to Chapter 3
# - Compare each Prison excluding Age
# - Compare each Prison by Age

#######################################
## Compare each Prison excluding Age ##
#######################################

#-- Process the Data --#

# Two-Step Process
# For each Prison
# (i) Extract the relevant data
levels(PRIS_COM$SITE)
# (ii) Summarise over the prisoner population to get count totals

# (1) Limerick Prison
PRIS_LIM_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED) %>%
  # filter out the unknown ISCED level and Limerick Prison
  filter(SITE == "LIM",ISCED != "Unknown") %>%
  # group by the ISCED education Levels
  group_by(SITE, ISCED) %>%
  # summarise over these ISCED levels
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "LIM",]))
# check the data
head(PRIS_LIM_EDU)
# check the proportions / perentages add up
sum(PRIS_LIM_EDU$Prcnt)

# (2) Midlands Prison
PRIS_MID_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED) %>%
  # filter out the unknown ISCED level and Midlands Prison
  filter(SITE == "MID", ISCED != "Unknown") %>%
  # group by the ISCED education Levels
  group_by(SITE, ISCED) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "MID",]))
# check the data
head(PRIS_MID_EDU)
# check the proportions / perentages add up
sum(PRIS_MID_EDU$Prcnt)

# (3) Wheatfield Prison

PRIS_WHT_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED) %>%
  # filter out the unknown ISCED level and Wheatfield Prison
  filter(SITE == "WHT", ISCED != "Unknown") %>%
  # group by the ISCED education Levels
  group_by(SITE, ISCED) %>%
  # summarise over these ISCED levels
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "WHT",]))
# check the data
head(PRIS_WHT_EDU)
# check the proportions / perentages add up
sum(PRIS_WHT_EDU$Prcnt)

# Merge the three prison datasets into 1
PRIS_EDU <- rbind(PRIS_LIM_EDU, PRIS_MID_EDU, PRIS_WHT_EDU)
# check the merge has been successful
head(PRIS_EDU)

#-- Visualisations --#

ggplot(PRIS_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -1, colour = "black", size = 3.5) +
  expand_limits(y = c(0,0.6)) +
  # give the bar chart a title
  ggtitle("Comparing Each Individual Prison: Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  # removing the default scale_fill_manual from thedk_theme
  dk_theme[-3] +
  # setting the scale_fill_manual palette to be just shades of orange
  scale_fill_manual(values = dk_palette[-1]) +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))

# Save the Plot
ggsave("EduAtt_PrisonDifferences.pdf",
       width = 8, height = 6, units = c("in"))

#-- Difference of Proportions Test

# I shall now perform a diffeence of proportions test
# to test whether there is a differnce in the level of education achieved 
# between the general population and the total prison population
# check that each PRIS data is proportional
length(PRIS_LIM_EDU$Total)
length(PRIS_MID_EDU$Total)
length(PRIS_WHT_EDU$Total)
# All prison datasets are proportional and have corresponding totals

# Test Hypotheses
# Ho: the proportions are equal
# Ha: the proportions are not equal

# Create Data Frame to hold the proportion tests
proptest2i <- as.data.frame(matrix(nrow = 12, ncol = 6))
# Set column names
colnames(proptest2i) <- c("Education Level", "Prison 1", "Prison 2", "Proportion 1: Prison 1", "Proportion 2: Prison 2", "P-Value")
# run a for loop to fill in the data frame
# (1) Limerick and Midlands
for(i in 1:nrow(PRIS_LIM_EDU)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_LIM_EDU$Total[i], PRIS_MID_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_LIM_EDU$Total), sum(PRIS_MID_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in education level
  proptest2i$`Education Level`[i] <- levels(PRIS_LIM_EDU$ISCED)[PRIS_LIM_EDU$ISCED[i]]
  # Fill in Prison 1
  proptest2i$`Prison 1`[i] <- "Midlands"
  # Fill in Prison 2
  proptest2i$`Prison 2`[i] <- "Limerick"
  # Fill in the first proportion
  proptest2i$`Proportion 1: Prison 1`[i] <- round(proptest[[4]][2], digits = 3)
  # Fill in the second proportion
  proptest2i$`Proportion 2: Prison 2`[i] <- round(proptest[[4]][1], digits = 3)
  # Fill in the P-Value
  proptest2i$`P-Value`[i] <- round(proptest[[3]], digits = 3)
}
# (2) Limerick and Wheatfield
for(i in 1:(nrow(PRIS_LIM_EDU))) {
  # select the appropiate counts to be tested
  X <- c(PRIS_LIM_EDU$Total[i], PRIS_WHT_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_LIM_EDU$Total), sum(PRIS_WHT_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in education level
  proptest2i$`Education Level`[i + 4] <- levels(PRIS_LIM_EDU$ISCED)[PRIS_LIM_EDU$ISCED[i]]
  # Fill in Prison 1
  proptest2i$`Prison 1`[i + 4] <- "Wheatfield"
  # Fill in Prison 2
  proptest2i$`Prison 2`[i + 4] <- "Limerick"
  # Fill in the first proportion
  proptest2i$`Proportion 1: Prison 1`[i + 4] <- round(proptest[[4]][2], digits = 3)
  # Fill in the second proportion
  proptest2i$`Proportion 2: Prison 2`[i + 4] <- round(proptest[[4]][1], digits = 3)
  # Fill in the P-Value
  proptest2i$`P-Value`[i + 4] <- round(proptest[[3]], digits = 3)
}
# (3) Midlands and Wheatfield
for(i in 1:nrow(PRIS_MID_EDU)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_MID_EDU$Total[i], PRIS_WHT_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_MID_EDU$Total), sum(PRIS_WHT_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in education level
  proptest2i$`Education Level`[i + 8] <- levels(PRIS_MID_EDU$ISCED)[PRIS_MID_EDU$ISCED[i]]
  # Fill in Prison 1
  proptest2i$`Prison 1`[i + 8] <- "Wheatfield"
  # Fill in Prison 2
  proptest2i$`Prison 2`[i + 8] <- "Midlands"
  # Fill in the first proportion
  proptest2i$`Proportion 1: Prison 1`[i + 8] <- round(proptest[[4]][2], digits = 3)
  # Fill in the second proportion
  proptest2i$`Proportion 2: Prison 2`[i + 8] <- round(proptest[[4]][1], digits = 3)
  # Fill in the P-Value
  proptest2i$`P-Value`[i + 8] <- round(proptest[[3]], digits = 3)
}
# Write Prortion Test 3: Each Individual Prison with one another to a csv file
write.csv(x = as.matrix(proptest2i), file = "prop.test2i.csv", row.names = F, quote = F)

# NOTE: the errors with the approxmation of the test statistic
# come from the lack of the data
head(PRIS_WHT_EDU[PRIS_WHT_EDU$Total < 10,])
# There are 9 observations in the ISCED 4-8 category
head(PRIS_LIM_EDU[PRIS_LIM_EDU$Total < 10,])
# There are 5 observations in the ISCED 3 category
# There are 8 observations in the ISCED 4-8 category
head(PRIS_MID_EDU[PRIS_MID_EDU$Total < 10,])

################################
## Compare each Prison by Age ##
################################

#-- Process the Data --#

# NOTE: The age levels recordedin the prison surveys are different across each prison
# As such, we need to relabel each combination of prison to have the same age levels

# Extract the relevant data for each individual Prison
levels(PRIS_COM$SITE)

# Summarise over the total prisoner population to count totals for each prison

# (1) Limerick and Wheatfield Prison
# (i) Limerick Prison
PRIS_LIM_EDU <-
  PRIS_COM %>%
  # select the appropriate features for Midlands
  select(SITE, ISCED, Age_LIMWHT) %>%
  # filter out the data only suitable for midlands 
  filter(SITE == "LIM", ISCED != "Unknown") %>%
  group_by(SITE, ISCED, Age_LIMWHT) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "LIM",]))
head(PRIS_LIM_EDU)
# (ii) Wheatfield Prison
PRIS_WHT_EDU <-
  PRIS_COM %>%
  # select the appropriate features for Midlands
  select(SITE, ISCED, Age_LIMWHT) %>%
  # filter out the data only suitable for midlands 
  filter(SITE == "WHT", ISCED != "Unknown") %>%
  group_by(SITE, ISCED, Age_LIMWHT) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "WHT",]))
head(PRIS_WHT_EDU)
PRIS_LIMWHT_EDU<- rbind(PRIS_LIM_EDU, PRIS_WHT_EDU)

# (2) Limerick and Midlands Prison
# (i) Limerick Prison
PRIS_LIM_EDU <-
  PRIS_COM %>%
  # select the appropriate features for Limerick or Midlands 
  select(SITE, ISCED, Age_LIMMID) %>%
  # filter out the data only suitable for midlands or midlands
  filter(SITE == "LIM", ISCED != "Unknown") %>%
  group_by(SITE, ISCED, Age_LIMMID) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "LIM",]))
head(PRIS_LIM_EDU)
# (ii) Wheatfield Prison
PRIS_MID_EDU <-
  PRIS_COM %>%
  # select the appropriate features for Limerick or Midlands 
  select(SITE, ISCED, Age_LIMMID) %>%
  # filter out the data only suitable for midlands or midlands
  filter(SITE == "MID", ISCED != "Unknown") %>%
  group_by(SITE, ISCED, Age_LIMMID) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "MID",]))
head(PRIS_MID_EDU)
PRIS_LIMMID_EDU<- rbind(PRIS_LIM_EDU, PRIS_MID_EDU)

# (3) Midlands and Wheatfield Prison
# (i) Midlands Prison
PRIS_MID_EDU <-
  PRIS_COM %>%
  # select the appropriate features for Midlands
  select(SITE, ISCED, Age_WHTMID) %>%
  # filter out the data only suitable for midlands 
  filter(SITE == "MID", ISCED != "Unknown") %>%
  group_by(SITE, ISCED, Age_WHTMID) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "MID",]))
head(PRIS_MID_EDU)
# (ii) Wheatfield Prison
PRIS_WHT_EDU <-
  PRIS_COM %>%
  # select the appropriate features for Midlands
  select(SITE, ISCED, Age_WHTMID) %>%
  # filter out the data only suitable for midlands 
  filter(SITE == "WHT", ISCED != "Unknown") %>%
  group_by(SITE, ISCED, Age_WHTMID) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "WHT",]))
head(PRIS_WHT_EDU)
PRIS_WHTMID_EDU<- rbind(PRIS_WHT_EDU, PRIS_MID_EDU)

#-- Visualisations --#

# (1) Limerick & Midlands
ggplot(PRIS_LIMMID_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.3)) +
  # divide the bar chart into seperate charts based on the variable age
  facet_wrap(~Age_LIMMID) + 
  # give the bar chart a title
  ggtitle("Limerick vs Midlands: Highest level of education completed") +
  # label the x axis of the plot
  xlab("Education Level") +
  # label the y axis of the plot
  ylab("Portion of Population") +
  # removing the default scale_fill_manual from thedk_theme
  dk_theme[-3] +
  # setting the scale_fill_manual palette to be just shades of orange
  scale_fill_manual(values = dk_palette[-1]) +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))

# Save the Plot
ggsave("EduAtt_LIMvMID.pdf",
       width = 8, height = 6, units = c("in"))

# (2) Limerick & Wheatfield
ggplot(PRIS_LIMWHT_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.3)) +
  # divide the bar chart into seperate charts based on the variable age
  facet_wrap(~Age_LIMWHT) + 
  ggtitle("Limerick vs Wheatfield: Highest level of education completed") +
  xlab("Education Level") +
  # label the y axis of the plot
  ylab("Portion of Population") +
  # removing the default scale_fill_manual from thedk_theme
  dk_theme[-3] +
  # setting the scale_fill_manual palette to be just shades of orange
  scale_fill_manual(values = dk_palette[-1]) +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))

# Save the Plot
ggsave("EduAtt_LIMvWHT.pdf",
       width = 8, height = 6, units = c("in"))

# (3) Wheatfields & Midlands
ggplot(PRIS_WHTMID_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.25)) +
  # divide the bar chart into seperate charts based on the variable age
  facet_wrap(~Age_WHTMID) + 
  ggtitle("Wheatfield vs Midlands: Highest level of education completed") +
  # label the x axis of the plot
  xlab("Education Level") +
  # label the y axis of the plot
  ylab("Portion of Population") +
  # removing the default scale_fill_manual from thedk_theme
  dk_theme[-3] +
  # setting the scale_fill_manual palette to be just shades of orange
  scale_fill_manual(values = dk_palette[-1]) +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))

# Save the Plot
ggsave("EduAtt_WHTvMID.pdf",
       width = 8, height = 6, units = c("in"))

#-- Difference of Proportions Test --#

# I shall now perform a diffeence of proportions test
# to test whether there is a differnce in the level of education achieved 
# between the general population and the total prison population
# check that each PRIS data is proportional
length(PRIS_LIMWHT_EDU$Total)
length(PRIS_WHTMID_EDU$Total)
length(PRIS_LIMMID_EDU$Total)
# The prison datasets are not proportional do not have corresponding totals
# (1) Limerick prison does not have anyone who is 51+ and has upper secondary education
# (2) Wheatfield prison does not have anyone who is less than 26 and has third level education
# To solve this issue I shall remove the corresponding proportion for each of the above issue
PRIS_LIMMID_EDUpt <- PRIS_LIMMID_EDU[-27,]
PRIS_LIMWHT_EDUpt <- PRIS_LIMWHT_EDU[-c(12,27),]
PRIS_WHTMID_EDUpt <- PRIS_WHTMID_EDU[-28,]

# Test Hypotheses
# Ho: the proportions are equal
# Ha: the proportions are not equal

# Create Data Frame to hold the proportion tests
proptest2ii <- as.data.frame(matrix(nrow = 44, ncol = 7))
# Set column names
colnames(proptest2ii) <- c("Age Level", "Education Level", "Prison 1", "Prison 2", 
                           "Proportion 1", "Proportion 2", "P-Value")
# run a for loop to fill in the data frame
# (1) Limerick and Midlands
for(i in 1:(nrow(PRIS_LIMMID_EDUpt)/2)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_LIMMID_EDUpt$Total[i], PRIS_LIMMID_EDUpt$Total[i + 15])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_LIMMID_EDUpt$Total[1:14]), sum(PRIS_LIMMID_EDUpt$Total[15:30]))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in age level
  proptest2ii$`Age Level`[i] <- levels(PRIS_LIMMID_EDUpt$Age_LIMMID)[PRIS_LIMMID_EDUpt$Age_LIMMID[i]]
  # Fill in education level
  proptest2ii$`Education Level`[i] <- levels(PRIS_LIMMID_EDUpt$ISCED)[PRIS_LIMMID_EDUpt$ISCED[i]]
  # Fill in Prison 1
  proptest2ii$`Prison 1`[i] <- "Limerick"
  # Fill in Prison 2
  proptest2ii$`Prison 2`[i] <- "Midlands"
  # Fill in the first proportion
  proptest2ii$`Proportion 1`[i] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest2ii$`Proportion 2`[i] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest2ii$`P-Value`[i] <- round(proptest[[3]], digits = 3)
}
# (2) Limerick and Wheatfield
for(i in 1:(nrow(PRIS_LIMWHT_EDUpt)/2)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_LIMWHT_EDUpt$Total[i], PRIS_LIMWHT_EDUpt$Total[i + 14])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_LIMWHT_EDUpt$Total[1:13]), sum(PRIS_LIMWHT_EDUpt$Total[14:28]))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in age level
  proptest2ii$`Age Level`[i + 15] <- levels(PRIS_LIMWHT_EDUpt$Age_LIMWHT)[PRIS_LIMWHT_EDUpt$Age_LIMWHT[i]]
  # Fill in education level
  proptest2ii$`Education Level`[i + 15] <- levels(PRIS_LIMWHT_EDUpt$ISCED)[PRIS_LIMWHT_EDUpt$ISCED[i]]
  # Fill in Prison 1
  proptest2ii$`Prison 1`[i + 15] <- "Limerick"
  # Fill in Prison 2
  proptest2ii$`Prison 2`[i + 15] <- "Wheatfield"
  # Fill in the first proportion
  proptest2ii$`Proportion 1`[i + 15] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest2ii$`Proportion 2`[i + 15] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest2ii$`P-Value`[i + 15] <- round(proptest[[3]], digits = 3)
}
# (3) Wheatfield and Midlands
for(i in 1:(nrow(PRIS_WHTMID_EDUpt)/2)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_WHTMID_EDUpt$Total[i], PRIS_WHTMID_EDUpt$Total[i + 15])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_WHTMID_EDUpt$Total[1:14]), sum(PRIS_WHTMID_EDUpt$Total[15:30]))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in age level
  proptest2ii$`Age Level`[i + 29] <- levels(PRIS_WHTMID_EDUpt$Age_WHTMID)[PRIS_WHTMID_EDUpt$Age_WHTMID[i + 15]]
  # Fill in education level
  proptest2ii$`Education Level`[i + 29] <- levels(PRIS_WHTMID_EDUpt$ISCED)[PRIS_WHTMID_EDUpt$ISCED[i + 15]]
  # Fill in Prison 1
  proptest2ii$`Prison 1`[i + 29] <- "Wheatfield"
  # Fill in Prison 2
  proptest2ii$`Prison 2`[i + 29] <- "Midlands"
  # Fill in the first proportion
  proptest2ii$`Proportion 1`[i + 29] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest2ii$`Proportion 2`[i + 29] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest2ii$`P-Value`[i + 29] <- round(proptest[[3]], digits = 3)
}
# Write Prortion Test 4: Each Individual Prison with one another by age to a csv file
write.csv(x = as.matrix(proptest2ii), file = "prop.test2ii.csv", row.names = F, quote = F)

# NOTE: the errors with the approxmation of the test statistic
# comes from the lack of the data
PRIS_WHTMID_EDUpt[PRIS_WHTMID_EDUpt$Total < 10,]
# There are 9 observations in the ISCED 2 category in the 50+ age bracket in MID
# There are 3 observations in the ISCED 0-1 category in the 50+ age bracket in WHT
# There are 2 observations in the ISCED 2 category in the 50+ age bracket in WHT
# There are 4 observations in the ISCED 3 category in the <26 age bracket in WHT
# There are 5 observations in the ISCED 3 category in the 26-35 age bracket in WHT
# There are 2 observations in the ISCED 3 category in the 50+ age bracket in WHT
PRIS_LIMWHT_EDUpt[PRIS_LIMWHT_EDUpt$Total < 10,]
# There are 6 observations in the ISCED 0-1 category in the 36-50 age bracket in LIM
# There are 1 observations in the ISCED 0-1 category in the 51+ age bracket in LIM
# There are 9 observations in the ISCED 2 category in the 36-50 age bracket in LIM
# There are 2 observations in the ISCED 2 category in the 51+ age bracket in LIM
# There are 2 observations in the ISCED 3 category in the <26 age bracket in LIM
# There are 1 observations in the ISCED 3 category in the 26-35 age bracket in LIM
PRIS_LIMMID_EDUpt[PRIS_LIMMID_EDUpt$Total < 10,]

########################################################################################################################
## Chapter 4: Comparing each individual with the general population ####################################################
########################################################################################################################

# There are two sections to Chapter 4
# - Compare National and each Prison Population excluding Age
# - Compare National and each Prison Population by Age

###############################################################
## Compare National and each Prison Population excluding Age ##
###############################################################

#-- Process the Data --#

# Two-Step Process
# For each Prison and the general population
# (i) Extract the relevant data
# (ii) Summarise over the population to get count totals

# (1) Limerick Prison
PRIS_LIM_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED) %>%
  # filter out the unknown ISCED level and Limerick Prison
  filter(SITE == "LIM",ISCED != "Unknown") %>%
  # group by the ISCED education Levels
  group_by(ISCED) %>%
  # summarise over these ISCED levels
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "LIM",]))
# check the data
head(PRIS_LIM_EDU)
# check the proportions / perentages add up
sum(PRIS_LIM_EDU$Prcnt)

# (2) Midlands Prison
PRIS_MID_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED) %>%
  # filter out the unknown ISCED level and Midlands Prison
  filter(SITE == "MID", ISCED != "Unknown") %>%
  # group by the ISCED education Levels
  group_by(ISCED) %>%
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "MID",]))
# check the data
head(PRIS_MID_EDU)
# check the proportions / perentages add up
sum(PRIS_MID_EDU$Prcnt)

# (3) Wheatfield Prison
PRIS_WHT_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED) %>%
  # filter out the unknown ISCED level and Wheatfield Prison
  filter(SITE == "WHT", ISCED != "Unknown") %>%
  # group by the ISCED education Levels
  group_by(ISCED) %>%
  # summarise over these ISCED levels
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "WHT",]))
# check the data
head(PRIS_WHT_EDU)
# check the proportions / perentages add up
sum(PRIS_WHT_EDU$Prcnt)

# (4) CSOdata related to Limerick
CSO_LIM_EDU <- 
  CSO_LIM %>% 
  # Filter outthe Unknown level
  filter(ISCED_lvls != "Unknown") %>%
  group_by(ISCED_lvls) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_LIM$Total))
colnames(CSO_LIM_EDU)[1] <- "ISCED"
head(CSO_LIM_EDU)

# (5) CSO data related to Midlands
CSO_MID_EDU <- 
  CSO_MID %>% 
  # Filter outthe Unknown level
  filter(ISCED_lvls != "Unknown") %>%
  group_by(ISCED_lvls) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_MID$Total))
colnames(CSO_MID_EDU)[1] <- "ISCED"
head(CSO_MID_EDU)

# (6) CSO data related to Wheatfield
CSO_WHT_EDU <- 
  CSO_WHT %>% 
  # Filter outthe Unknown level
  filter(ISCED_lvls != "Unknown") %>%
  group_by(ISCED_lvls) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_WHT$Total))
colnames(CSO_WHT_EDU)[1] <- "ISCED"
head(CSO_WHT_EDU)

# (7) CSO data for all three prisons
# Summerise over CSO data by ISCED levels
CSO_IND_EDU <- 
  CSO_IND %>%
  # select the relevant features
  select(ISCED_lvls, Total) %>%
  # Group by ISCED Levels
  group_by(ISCED_lvls) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_IND$Total))
# Rename ISCED_lvls to assist in merging the two tables
colnames(CSO_IND_EDU)[1] <- "ISCED"
head(CSO_IND_EDU)

# Merge the datasets together
# Create a site identifier for prison data
PRIS_LIM_EDU$SITE  <- "LIM"
PRIS_MID_EDU$SITE  <- "MID"
PRIS_WHT_EDU$SITE  <- "WHT"
# Create a general identifier for CSO data
CSO_LIM_EDU$SITE  <- "General"
CSO_MID_EDU$SITE  <- "General"
CSO_WHT_EDU$SITE  <- "General"
CSO_COM_EDU4$SITE <- "General"
# Merge the Datasets
COM_LIM_EDU <- rbind(PRIS_LIM_EDU, CSO_LIM_EDU)
COM_MID_EDU <- rbind(PRIS_MID_EDU, CSO_MID_EDU)
COM_WHT_EDU <- rbind(PRIS_WHT_EDU, CSO_WHT_EDU)
COM_LIMMIDWHT_EDU <- rbind(PRIS_LIM_EDU, PRIS_MID_EDU, PRIS_WHT_EDU, CSO_IND_EDU)

#-- Visualisations --#

# Limerick vs General Population
ggplot(COM_LIM_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.5)) +
  # give the bar chart a title
  ggtitle("Limerick Prison vs General Population: Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # lable the y axis
  ylab("Portion of Population") +
  # Incorporate the datakind theme
  dk_theme  +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))
# Save the Plot
ggsave("EduAtt_LIMVGenPop.pdf",
       width = 8, height = 6, units = c("in"))

# Midlands vs General Population
ggplot(COM_MID_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.5)) +
  # give the bar chart a title
  ggtitle("Midlands Prison vs General Population: Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  # incorporate the datakind theme
  dk_theme  +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))
# Save the Plot
ggsave("EduAtt_MIDVGenPop.pdf",
       width = 8, height = 6, units = c("in"))

# Wheatfield vs General Population
ggplot(COM_WHT_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.6)) +
  # Give the bar chart a title
  ggtitle("Wheatfield Prison vs General Population: Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  dk_theme  +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))
# Save the Plot
ggsave("EduAtt_WHTVGenPop.pdf",
       width = 8, height = 6, units = c("in"))

# Each individual Prison Population vs General Population
ggplot(COM_LIMMIDWHT_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.6)) +
  # give the bar chart a title
  ggtitle("Individual Prison Population vs General Population: Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # lable the y axis
  ylab("Portion of Population") +
  # Incorporate the datakind theme
  dk_theme  +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))
# Save the Plot
ggsave("EduAtt__LIMMIDWHTVGenPop.pdf",
       width = 8, height = 6, units = c("in"))

#-- Difference of Proportions Test

# I shall now perform a diffeence of proportions test
# to test whether there is a differnce in the level of education achieved 
# between the general population and the total prison population
# check that each PRIS data is proportional
length(COM_LIM_EDU$Total)
length(COM_MID_EDU$Total)
length(COM_WHT_EDU$Total)
# All datasets are proportional and have corresponding totals

# Test Hypotheses
# Ho: the proportions are equal
# Ha: the proportions are not equal

# Create Data Frame to hold the proportion tests
proptest3i <- as.data.frame(matrix(nrow = 12, ncol = 5))
# Set column names
colnames(proptest3i) <- c("Education Level", "Prison", "Proportion 1: Prison",
                          "Proportion 2: General", "P-Value")
# run a for loop to fill in the data frame
# (1) Limerick and General Population
for(i in 1:nrow(PRIS_LIM_EDU)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_LIM_EDU$Total[i], CSO_IND_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_LIM_EDU$Total), sum(CSO_IND_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in education level
  proptest3i$`Education Level`[i] <- levels(PRIS_LIM_EDU$ISCED)[i]
  # Fill in Prison
  proptest3i$Prison[i] <- "Limerick"
  # Fill in the first proportion
  proptest3i$`Proportion 1: Prison`[i] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest3i$`Proportion 2: General`[i] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest3i$`P-Value`[i] <- round(proptest[[3]], digits = 3)
}
# (2) Wheatfield and General Population
for(i in 1:nrow(PRIS_WHT_EDU)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_WHT_EDU$Total[i], CSO_IND_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_WHT_EDU$Total), sum(CSO_IND_EDU$Total))
  # print the two populations being tested to the R console
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in education level
  proptest3i$`Education Level`[i + 4] <- levels(PRIS_WHT_EDU$ISCED)[i]
  # Fill in Prison
  proptest3i$Prison[i + 4] <- "Wheatfield"
  # Fill in the first proportion
  proptest3i$`Proportion 1: Prison`[i + 4] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest3i$`Proportion 2: General`[i + 4] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest3i$`P-Value`[i + 4] <- round(proptest[[3]], digits = 3)
}
# (3) Midlands and General Population
for(i in 1:nrow(PRIS_MID_EDU)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_MID_EDU$Total[i], CSO_IND_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_MID_EDU$Total), sum(CSO_IND_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in education level
  proptest3i$`Education Level`[i + 8] <- levels(PRIS_MID_EDU$ISCED)[i]
  # Fill in Prison
  proptest3i$Prison[i + 8] <- "Midlands"
  # Fill in the first proportion
  proptest3i$`Proportion 1: Prison`[i + 8] <- round(proptest[[4]][1], digits = 3)
  # Fill in the second proportion
  proptest3i$`Proportion 2: General`[i + 8] <- round(proptest[[4]][2], digits = 3)
  # Fill in the P-Value
  proptest3i$`P-Value`[i + 8] <- round(proptest[[3]], digits = 3)
}
# Write Prortion Test 5: Each Prison vs General Population to a csv file
write.csv(x = as.matrix(proptest3i), file = "prop.test3i.csv", row.names = F, quote = F)

########################################################
## Compare National and each Prison Population by Age ##
########################################################

# (1) Limerick Prison
PRIS_LIM_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED, Age) %>%
  # filter out the unknown ISCED level and Limerick Prison
  filter(SITE == "LIM",ISCED != "Unknown") %>%
  # group by the ISCED education Levels and Age levels
  group_by(ISCED, Age) %>%
  # summarise over these ISCED levels and Age Levels
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "LIM",]))
# check the data
head(PRIS_LIM_EDU)
# check the proportions / perentages add up
sum(PRIS_LIM_EDU$Prcnt)

# (2) Midlands Prison
PRIS_MIDGEN_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED, AGE_MIDGEN) %>%
  # filter out the unknown ISCED level and Midlands Prison
  filter(SITE == "MID", ISCED != "Unknown") %>%
  # group by the ISCED education Levels and Age Levels
  group_by(ISCED, AGE_MIDGEN) %>%
  # summarise over these ISCED levels and Age Levels
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "MID",]))
# check column name to facilitate table merge
colnames(PRIS_MIDGEN_EDU)[2] <- "Age"
# check the data
head(PRIS_MIDGEN_EDU)
# check the proportions / perentages add up
sum(PRIS_MIDGEN_EDU$Prcnt)

# (3) Wheatfield Prison
PRIS_WHTGEN_EDU <-
  PRIS_COM %>%
  # select the relevant features
  select(SITE, ISCED, AGE_WHTGEN) %>%
  # filter out the unknown ISCED level and Wheatfield Prison
  filter(SITE == "WHT", ISCED != "Unknown") %>%
  # group by the ISCED education Levels
  group_by(ISCED, AGE_WHTGEN) %>%
  # summarise over these ISCED levels and Age Levels
  summarise(Total = n(),
            Prcnt = Total/nrow(PRIS_COM[PRIS_COM$SITE == "WHT",]))
# check column name to facilitate table merge
colnames(PRIS_WHTGEN_EDU)[2] <- "Age"
# check the data
head(PRIS_WHTGEN_EDU)
# check the proportions / perentages add up
sum(PRIS_WHTGEN_EDU$Prcnt)

# (4) CSOdata related to Limerick
CSO_LIM_EDU <- 
  CSO_LIM %>% 
  filter(ISCED_lvls != "Unknown") %>%
  group_by(ISCED_lvls, Age_LIM) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_LIM$Total))
colnames(CSO_LIM_EDU)[1] <- "ISCED"
colnames(CSO_LIM_EDU)[2] <- "Age"
head(CSO_LIM_EDU)

# (5) CSO data related to Midlands
CSO_MIDGEN_EDU <- 
  CSO_MIDGEN %>% 
  filter(ISCED_lvls != "Unknown") %>%
  group_by(ISCED_lvls, AGE_MIDGEN) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_MIDGEN$Total))
colnames(CSO_MIDGEN_EDU)[1] <- "ISCED"
colnames(CSO_MIDGEN_EDU)[2] <- "Age"
head(CSO_MIDGEN_EDU)

# (6) CSO data related to Wheatfield
CSO_WHTGEN_EDU <- 
  CSO_WHTGEN %>% 
  filter(ISCED_lvls != "Unknown") %>%
  group_by(ISCED_lvls, AGE_WHTGEN) %>%
  # summarise over age data to get totals 
  summarise(Total = sum(Total),
            Prcnt = Total / sum(CSO_WHTGEN$Total))
colnames(CSO_WHTGEN_EDU)[1] <- "ISCED"
colnames(CSO_WHTGEN_EDU)[2] <- "Age"
head(CSO_WHTGEN_EDU)

# Merge the datasets together
# Create a site identifier for prison data
PRIS_LIM_EDU$SITE  <- "LIM"
PRIS_MIDGEN_EDU$SITE  <- "MID"
PRIS_WHTGEN_EDU$SITE  <- "WHT"
# check the datasets
head(PRIS_MIDGEN_EDU)
head(PRIS_WHTGEN_EDU)
# Create a general identifier for CSO data
CSO_LIM_EDU$SITE  <- "General"
CSO_MIDGEN_EDU$SITE  <- "General"
CSO_WHTGEN_EDU$SITE  <- "General"
# check the datasets
head(CSO_MIDGEN_EDU)
head(CSO_WHTGEN_EDU)
# Merge the Datasets
COM_LIM_EDU <- rbind(PRIS_LIM_EDU, CSO_LIM_EDU)
COM_MIDGEN_EDU <- rbind(PRIS_MIDGEN_EDU, CSO_MIDGEN_EDU)
COM_WHTGEN_EDU <- rbind(PRIS_WHTGEN_EDU, CSO_WHTGEN_EDU)
# check the datasets
head(COM_MIDGEN_EDU)
head(COM_MIDGEN_EDU)

#-- Visualisations --#

# (1) Limerick
ggplot(COM_LIM_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.3)) +
  # divide the bar chart into seperate charts based on the variable age
  facet_wrap(~Age) + 
  # give the bar chart a title
  ggtitle("Limerick Prison vs General Population:  Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  # Incorporate datakind theme
  dk_theme   +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))
# Save the Plot
ggsave("EduAtt_LIMGenPop_by_Age.pdf",
       width = 8, height = 6, units = c("in"))

# (2) Midlands
ggplot(COM_MIDGEN_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.2)) +
  # divide the bar chart into seperate charts based on the variable age
  facet_wrap(~Age) + 
  # give the bar chart a title
  ggtitle("Midlands Prison vs General Population:  Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  # incorporate the datakind theme
  dk_theme   +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))
# Save the Plot
ggsave("EduAtt_MIDVGenPop_by_Age.pdf",
       width = 8, height = 6, units = c("in"))

# (3) Wheatfield
ggplot(COM_WHTGEN_EDU, aes(ISCED, Prcnt, fill = SITE)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  # add data lables to each bar
  geom_text(aes(label = percent(round(Prcnt, 2))), position = position_dodge(width = 1),
            vjust = -0.8, colour = "black", size = 4) +
  expand_limits(y = c(0.0, 0.25)) +
  # divide the bar chart into seperate charts based on the variable age
  facet_wrap(~Age) + 
  # give the barchart name
  ggtitle("Wheatfield Prison vs General Population: Highest level of education completed") +
  # label the x axis
  xlab("Education Level") +
  # label the y axis
  ylab("Portion of Population") +
  # incorporate the datakind theme
  dk_theme   +
  # format text
  theme(plot.title = element_text(size = 12, hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14))
# Save the Plot
ggsave("EduAtt_WHTVGenPop_by_Age.pdf",
       width = 8, height = 6, units = c("in"))

#-- Difference of Proportions Test

# I shall now perform a diffeence of proportions test
# to test whether there is a differnce in the level of education achieved 
# between the general population and the total prison population
# check that each PRIS data is proportional with the CSO data
# (1) Limerick
length(PRIS_LIM_EDU$Total)
length(CSO_LIM_EDU$Total)
# (2) Midlands
length(PRIS_MIDGEN_EDU$Total)
length(CSO_MIDGEN_EDU$Total)
# (3) Wheatfield
length(PRIS_WHTGEN_EDU$Total)
length(CSO_WHTGEN_EDU$Total)
# The prison datasets are not proportional do not have corresponding totals
# (1) Limerick Prison does not have any prisoners over 51 with upper secondary education
# (2) Midlands Prison does not have any prisoners over 65 with lower secondary education
# (3) Wheatfield does not have any prisoners aged 22-25 or 17-21 with third level education
# To solve this issue I shall remove the corresponding proportion for each of the above issue
COM_LIM_EDUpt <- COM_LIM_EDU[-27,]
COM_WHTGEN_EDUpt <- COM_WHTGEN_EDU[-28,]


# Create Data Frame to hold the proportion tests
proptest3ii <- as.data.frame(matrix(nrow = 46, ncol = 6))
# Set column names
colnames(proptest3ii) <- c("Age Level", "Education Level", "Prison", "Proportion 1: General",
                           "Proportion 2: Prison", "P-Value")
# (1) Limerick and General Population
for(i in 1:(nrow(COM_LIM_EDUpt)/2)) {
  # select the appropiate counts to be tested
  X <- c(COM_LIM_EDUpt$Total[i], COM_LIM_EDUpt$Total[i + 15])
  # select the appropiate population totals to be tested
  N <- c(sum(COM_LIM_EDUpt$Total[1:14]), sum(COM_LIM_EDUpt$Total[15:30]))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in age level
  proptest3ii$`Age Level`[i] <- COM_LIM_EDUpt$Age[i]
  # Fill in education level
  proptest3ii$`Education Level`[i] <- levels(COM_LIM_EDUpt$ISCED)[COM_LIM_EDUpt$ISCED[i]]
  # Fill in Prison
  proptest3ii$Prison[i] <- "Limerick"
  # Fill in the second proportion
  proptest3ii$`Proportion 1: General`[i] <- round(proptest[[4]][2], digits = 3)
  # Fill in the first proportion
  proptest3ii$`Proportion 2: Prison`[i] <- round(proptest[[4]][1], digits = 3)
  # Fill in the P-Value
  proptest3ii$`P-Value`[i] <- round(proptest[[3]], digits = 3)
}
# (2) Midlands and General Population
for(i in 1:nrow(PRIS_MIDGEN_EDU)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_MIDGEN_EDU$Total[i], CSO_MIDGEN_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_MIDGEN_EDU$Total), sum(CSO_MIDGEN_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in age level
  proptest3ii$`Age Level`[i + 15] <- levels(PRIS_MIDGEN_EDU$Age)[PRIS_MIDGEN_EDU$Age[i]]
  # Fill in education level
  proptest3ii$`Education Level`[i + 15] <- levels(PRIS_MIDGEN_EDU$ISCED)[PRIS_MIDGEN_EDU$ISCED[i]]
  # Fill in Prison
  proptest3ii$Prison[i + 15] <- "Midlands"
  # Fill in the second proportion
  proptest3ii$`Proportion 1: General`[i + 15] <- round(proptest[[4]][2], digits = 3)
  # Fill in the first proportion
  proptest3ii$`Proportion 2: Prison`[i + 15] <- round(proptest[[4]][1], digits = 3)
  # Fill in the P-Value
  proptest3ii$`P-Value`[i + 15] <- round(proptest[[3]], digits = 3)
}
# (3) Wheatfield and General Population
for(i in 1:nrow(PRIS_WHTGEN_EDU)) {
  # select the appropiate counts to be tested
  X <- c(PRIS_WHTGEN_EDU$Total[i], CSO_WHTGEN_EDU$Total[i])
  # select the appropiate population totals to be tested
  N <- c(sum(PRIS_WHTGEN_EDU$Total), sum(CSO_WHTGEN_EDU$Total))
  # Proportion Test
  proptest <- prop.test(x = X, n = N)
  # Fill in age level
  proptest3ii$`Age Level`[i + 31] <- levels(PRIS_WHTGEN_EDU$Age)[PRIS_WHTGEN_EDU$Age[i]]
  # Fill in education level
  proptest3ii$`Education Level`[i + 31] <- levels(PRIS_WHTGEN_EDU$ISCED)[PRIS_WHTGEN_EDU$ISCED[i]]
  # Fill in Prison
  proptest3ii$Prison[i + 31] <- "Wheatfield"
  # Fill in the second proportion
  proptest3ii$`Proportion 1: General`[i + 31] <- round(proptest[[4]][2], digits = 3)
  # Fill in the first proportion
  proptest3ii$`Proportion 2: Prison`[i + 31] <- round(proptest[[4]][1], digits = 3)
  # Fill in the P-Value
  proptest3ii$`P-Value`[i + 31] <- round(proptest[[3]], digits = 3)
}
# Write Prortion Test 6: Each Prison vs General Population by Age to a csv file
write.csv(x = as.matrix(proptest3ii), file = "prop.test3ii.csv", row.names = F, quote = F)

# NOTE: the errors with the approxmation of the test statistic
# comes from the lack of the data
COM_LIM_EDUpt[COM_LIM_EDU$Total < 5,]
# There are 6 observations in the ISCED 0-1 category in the 36-50 age bracket in LIM
# There are 1 observations in the ISCED 0-1 category in the 51+ age bracket in LIM
# There are 9 observations in the ISCED 2 category in the 36-50 age bracket in LIM
# There are 2 observations in the ISCED 2 category in the 51+ age bracket in LIM
# There are 2 observations in the ISCED 3 category in the 18-25 age bracket in LIM
# There are 1 observations in the ISCED 3 category in the 26-35 age bracket in LIM
COM_WHTGEN_EDU[COM_WHTGEN_EDU$Total < 5,]
# There are 3 observations in the ISCED 0-1 category in the 36-50 age bracket in WHT
# There are 2 observations in the ISCED 2 category in the 51+ age bracket in WHT
# There are 4 observations in the ISCED 3 category in the 36-50 age bracket in WHT
# There are 5 observations in the ISCED 3 category in the 51+ age bracket in WHT
# There are 2 observations in the ISCED 3 category in the 18-25 age bracket in WHT
# There are 3 observations in the ISCED 4-8 category in the 26-35 age bracket in WHT
PRIS_MIDGEN_EDU[PRIS_MIDGEN_EDU$Total < 5,]
