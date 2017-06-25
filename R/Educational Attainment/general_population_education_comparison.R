## ----setup, echo = F, include = F----------------------------------------
# If you're new to R, this RMarkdown document is a combination between chunks of R code and standard markdown, much like a Jupyter notebook. The header above simply defines what kind of output to make, whether to make a TOC etc.

# This setup code chunk simply sets some 

library(tidyverse)
# Tidyverse is a wrapper package for a suite of *essential* R packages that
# basically acts like a completely different API inside R, who's base API
# is famously/notoriously concise/impenetrable.
#
# The constituent packages were primarily conceived and built over years 
# by a complete legend of a New Zealander called Hadly Wickham, who is 
# as close to a celbrity as you can get among stats programmers.
# I highly (HIGHLY!) recommend using this API as your starting point in
# R if you're new to it.
#
# The tidyverse includes:
#   - dplyr for data pre-processing & cleaning
#   - ggplot2 for general plotting, far superior to the base R graphics.
#   - readr for importing data conveniently
#   - tidyr for putting data into "tidy" form. Often used in combo with dplyr.
#   - etc
#   - get the full list with: tidyverse::tidyverse_packages()

# Knitr is used to create documents from this RMarkdown.
# I'm using it here to set default options for how this document will "knit"
library(knitr) 


opts_chunk$set(fig.width=8, fig.height=8)
opts_chunk$set(echo = F, warning = F, error = F, message = F)

# This just runs another file which puts a consistent palette and
# ggplot2 theme into memory for later plotting.
source('../Utilities/create_theme.R')

## ----read & clean--------------------------------------------------------

# First i'm using readr to import the survey data
survey <- 
  readr::read_csv("../../../Data/survey_results_clean.csv")

# Now I'm using dplyr to clean the data up a bit.
# %>% is a pipe, that puts the output of one function as the first 
# argument of the next function, much like a Unix pipe. It is VERY handy.
survey_education <-
  survey %>% 
  select(X1, gender, age, school_experience, # select the relevant columns 
         prison_wing, prison, school_experience_level) %>% 
  mutate(gender = as.factor(gender), # mutate changes columns or creates new ones
         age = as.factor(age),
         school_experience = 
           ordered(school_experience, 
                   levels = c("I didnt go to secondary school.",
                              "I left school before the Junior/Inter Cert.",
                              "I left school after the Junior/ Inter Cert.",
                              "I left school after the Leaving Cert.",
                              'I have gone to college/ university.',
                              "Unclear")), # google "R factors" to understand 
         prison_wing = as.factor(prison_wing),
         prison = as.factor(prison),
         school_experience_level = as.factor(school_experience_level))




## ----explore survey------------------------------------------------------

# Our first plot using ggplot2. The syntax is a bit weird before you get 
# used to it, but basically we put our data frame as the first argument
# and the second argument is an aesthetic (aes) that tells ggplot which
# columns to use in plotting data and also how to colour encode.
# In this case we want to plot the school_experience_level and we use
# fill signify that we want the bars to be filled with 
# colours based on on the school_experience variable.
# We then build our plot, layer by layer with the + operator used to 
# add the layers or modify previous layers.
# Geoms are the main "controllers" of the type of plot, in this case a bar.
# The iprt_theme is a pre-baked theme I imported earlier and
# the iprt_palette is used to dedice the colour of the fill in the bar plot.

ggplot(survey_education, aes(school_experience_level, 
                             fill = school_experience)) +
  geom_bar() + # automatically sums up over the bins to create the bars
  iprt_theme +
  scale_fill_manual(values = iprt_palette[-1])




## ----explore general population------------------------------------------

# Data retrieved from: http://www.cso.ie/en/statistics/education/principalstatistics/
# Date: 2011
# Retrieved: 19/02/2017

# Now i'm importing the basic census data on educational attainment.
# Notice how I use the pipes to add a new variable in the same statement
# as the import. This can make the code far more concise & natural
general_pop_education <-
  read_csv("../../../Data/External Data/educational_attainment_2011.csv") %>% 
  mutate(school_experience_level = c(NA, NA, 1, 2, 3, 4, 5, 6, NA, NA))
  
# A similar plot to above.
ggplot(general_pop_education %>% filter(category_type == "ceased"),
       aes(x = reorder(category, school_experience_level), y = male,
           fill = category)) +
  geom_bar(stat="identity") + #stat="identity" is used since we have the totals
  iprt_theme +
  scale_fill_manual(values = iprt_palette[-1])



## ----map between general and survey--------------------------------------

# Using mutate to create a new variable to map the census data to ISCED
general_pop_education <-
  general_pop_education %>% 
  mutate(ISCED_2011 = c(NA, NA, "0-1", "2", "3", 
                        "4-8", "4-8", "unknown",
                        NA, NA))

# Similarly for the survey data but using case_when() to define the map
survey_education <- 
  survey_education %>% 
  mutate(ISCED_2011 = 
           case_when(.$school_experience_level %in% c("A", "B") ~ "0-1",
                     .$school_experience_level == "C" ~ "2",
                     .$school_experience_level == "D" ~ "3",
                     .$school_experience_level == "E" ~ "4-8",
                     .$school_experience_level == "Unclear" ~ "unknown"))
# Btw the $ operator accesses the columns of a data frame, and the . (dot)
# is used to reference the data frame that has been passed in by the pipe %>%

## ----ISCED 2011 Inmates--------------------------------------------------
 
ggplot(survey_education, aes(ISCED_2011, 
                             fill = ISCED_2011)) +
  geom_bar() +
  iprt_theme +
  scale_fill_manual(values = iprt_palette[-1]) +
  labs(title = "Educational Attainment of Inmates Using\nISCED 2011 Standard",
       x = "ISCED 2011 Level of Attainment", y = "Inmates") 

## ----ISCED 2011 General--------------------------------------------------

# here I'm using dplyr to filter (like the "WHERE" in SQL) the data as I plot it.
# This means I don't need to keep multiple similar copies of a dataset.
ggplot(general_pop_education %>% filter(category_type == "ceased"),
       aes(x = ISCED_2011, y = male,
           fill = ISCED_2011)) +
  geom_bar(stat="identity") +
  iprt_theme +
  scale_fill_manual(values = iprt_palette[-1]) +
  labs(title = 
         "Educational Attainment of Male General Population\nUsing ISCED 2011 Standard",
       x = "ISCED 2011 Level of Attainment", y = "Male General Population")

## ----survey education summary--------------------------------------------

# More dplyr, this time to create summaries based on groups.
# group_by is similar to the SQL statement but only defines the group,
# what you do with it comes in the subsequent statements which are usually
# a tally() or summarise().

survey_education_summary <-
  survey_education %>% 
  group_by(ISCED_2011) %>% 
  tally() %>% # does a sum across each category
  mutate(proportion = n/sum(n)) # use mutate to create a new proportion variable

survey_education_summary

survey_education_summary$n %>% sum()
  

## ----general education summary-------------------------------------------
general_education_summary <-
  general_pop_education  %>% 
  filter(category_type == "ceased") %>% 
  group_by(ISCED_2011) %>% 
  # this time we use summarise as we already have totals
  summarise(n = sum(male)) %>%  
  mutate(proportion = n / sum(n))


general_education_summary

general_education_summary$n %>%  sum()


## ----Parametric Z-Test---------------------------------------------------

# First create an empty list to which we'll insert an arbitrary results object.
# This pattern is quite commonly used in R, with a large set of  objects 
# it is often best to pre-define the length of this list because R is bad at 
# memory, but in this case we can get away with it.
ztest_results = list() 

# Here I'm running a proportional z-test on each category between the 
# survey and census data and storing the results in ztest_results.
# I'm also printing a human-readable output.
# This should probably be captured in a function or two...
for (i in 1:nrow(general_education_summary)){
  # [] in R means you're using indexed accessing of an object.
  # [[]] means you don't want the list element itself but that you want
  # to access the inner object. Otherwise you'll often get the 
  # "toString()" equivalent of the object rather than the object itself.
  ztest_results[[i]] <-
    (prop.test(x = c(general_education_summary$n[i],
                     survey_education_summary$n[i]),
               n = c(sum(general_education_summary$n),
                     sum(survey_education_summary$n)),
               correct = FALSE))
  
  paste("P Value for ISCED categoy:", 
        general_education_summary$ISCED_2011[i],
        "    ",
        ztest_results[[i]]$p.value) %>% # notce the [[]] notation again
    print()
  
}

# The strength of this approach is we can then access the entire results object
# at a later point with ease.



## ------------------------------------------------------------------------

# Next I found the educational attainment census data broken down by age.
# It wasn't quite in "tidy" form, the age variable was split out among multiple
# columns,  so i used gather to create a single variable of age and a key 
# variable created from the names of the columns that I'm "gathering" into
# a key-value pairing of columns.

general_age_education_raw <- 
  read_csv("../../../Data/External Data/general_population_age_educational_attainment.csv") %>% 
  rename(educational_attainment = X1) %>% 
  tidyr::gather(age, general_pop_count, c(2:16)) %>%
  select(-2)

# Just taking a look at the distinct values of the age categories in the
# two datasets.
survey_education %>% 
  distinct(age) %>% # returns only distinct values
  arrange(age) # arrange sorts them alphanumerically.

general_age_education_raw %>% 
  distinct(age) %>% 
  arrange(age)
  


## ------------------------------------------------------------------------

# Create new variables to map the educational attainment and age for 
# the census data. The mappings don't match up exactly unfortunately.
#
# Note that the 15-19 age category has been filtered from the census 
# data as these can't really be compared with the prison population which
# are all 18+.

# This next couple of dplyr chunks brings what I did before all into 
# one place, so take some time to understand what's going on here.
general_age_education <-
  general_age_education_raw %>% 
  mutate(ISCED_2011 = 
           case_when(.$educational_attainment ==
                       "Primary (incl. no formal education)" ~ "0-1",
                     .$educational_attainment == "Lower secondary" ~ "2",
                     .$educational_attainment == "Upper secondary" ~ "3",
                     .$educational_attainment %in% 
                       c("Third level non-degree",
                         "Third level degree or higher") ~ "4-8",
                     .$educational_attainment == "Not stated" ~ "unknown"))%>% 
  filter(age != '15 - 19 years') %>% 
  mutate(common_age_category = 
           case_when(.$age == "20 - 24 years" ~ "< 26",
                     .$age %in% c("25 - 29 years",
                                  "30 - 34 years") ~ "26-35",
                     .$age %in%  c("35 - 39 years",
                                   "40 - 44 years",
                                   "45 - 49 years") ~ "36-49",
                     .$age %in%  c("50 - 54 years",
                                   "55 - 59 years",
                                   "60 - 64 years") ~ "50-64",
                     .$age %in%  c("65 - 69 years",
                                   "70 - 74 years",
                                   "75 - 79 years",
                                   "80 - 84 years",
                                   "85 years and over") ~ "65+")) %>% 
  group_by(common_age_category, ISCED_2011) %>% 
  summarise(general_pop_count = sum(general_pop_count)) 

survey_age_education <-
  survey_education %>% 
  mutate(common_age_category = 
           case_when(.$age %in%
                       c("18-21", "22-25") ~ "< 26",
                     .$age == "26-35" ~ "26-35",
                     .$age == "36-49" ~ "36-49",
                     .$age == "50-64" ~ "50-64",
                     .$age == "65+" ~ "65+")) %>%
  group_by(common_age_category, ISCED_2011) %>% 
  tally() %>% 
  rename(prison_pop_count = n)

combined_age_education <-
  survey_age_education %>% 
  # left join does exactly what you think it does. Really useful statement.
  left_join(general_age_education,
            by = c("common_age_category", "ISCED_2011")) %>% 
  tidyr::gather(pop_type, pop_count, c(3:4))
# We used gather() as again we had a variable (count) spread out in 2 
# columns (survey count and census count), so we combined them
# into a key column (census or survey) and value column (count).

print("Combined Prison & General Population Dataset:")
combined_age_education



## ------------------------------------------------------------------------

ggplot(general_age_education %>% 
         filter(!(common_age_category %in% c("50-64","65+"))),
       aes(x = ISCED_2011, y = general_pop_count,
           fill = ISCED_2011)) +
  geom_bar(stat="identity") +
  # facets split the plots into a multiplot based on the variable you pass in
  facet_wrap(~common_age_category) + 
  iprt_theme +
  scale_fill_manual(values = iprt_palette[-1]) +
  labs(title = 
         "Educational Attainment of Male General\nPopulation by Age (2011)",
       x = "ISCED 2011 Level of Attainment", y = "Male General Population")

ggplot(survey_age_education %>% 
         filter(!(common_age_category %in% c("50-64","65+"))),
       aes(x = ISCED_2011, y = prison_pop_count,
           fill = ISCED_2011)) +
  geom_bar(stat="identity") +
  facet_wrap(~common_age_category) +
  iprt_theme +
  scale_fill_manual(values = iprt_palette[-1]) +
  labs(title = 
         "Educational Attainment of Prison Population by Age",
       x = "ISCED 2011 Level of Attainment", y = "Prison Population")




## ------------------------------------------------------------------------

ggplot(combined_age_education %>% 
         filter(!(common_age_category %in% c("50-64","65+"))),
       aes(x = common_age_category, y = pop_count,
           fill = ISCED_2011)) +
  geom_bar(stat="identity", position = "fill") +
  iprt_theme +
  scale_fill_manual(values = iprt_palette[-1]) +
  facet_wrap(~pop_type) +
  labs(title = 
         "Educational Attainment of Prison &\nGeneral Population by Age",
       x = "ISCED 2011 Level of Attainment", y = "Proportion")


## ------------------------------------------------------------------------

# Here I'm replicating the calculations done by ggplot to make the above plots
# in dplyr. It's quite straight-forward to do when you get the hang of it 
# and is an example of how these two packages work together very well.
combined_age_education_summary <-
  combined_age_education %>% 
  group_by(common_age_category, pop_type) %>% 
  mutate(proportion_of_age = pop_count / sum(pop_count),
         percentage_of_age = scales::percent(proportion_of_age))

# combined_age_education_summary %>% 
#   write.csv(file = "education_attainment_age_prison_vs_general_pop.csv")

# Setting the tibble (fancy data frame) to print all rows/columns
options(tibble.print_max = Inf)
options(tibble.width = Inf)



