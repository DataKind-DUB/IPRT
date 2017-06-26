
education_category_diff_test <- 
  function(summary, age_cat1, age_cat2, education_cat, pop_cat) {
  
  # For testing
  # age_cat1 <- "< 26"
  # age_cat2 <- "36-49"
  # education_cat <- "4-8"
  
   summary1 <- 
    combined_age_education_summary %>% 
     filter(common_age_category == age_cat1 &
              pop_type == pop_cat) %>% 
     ungroup()
   
    
   summary2 <-
     combined_age_education_summary %>% 
     filter(common_age_category == age_cat2 &
              pop_type == pop_cat) %>% 
     ungroup()
  
  prop.test(x = c((summary1 %>% 
                    filter(ISCED_2011 == education_cat) %>% 
                    select(pop_count))[[1]],
                  (summary2 %>% 
                    filter(ISCED_2011 == education_cat) %>% 
                    select(pop_count))[[1]]),
            n = c(sum(summary1$pop_count),
                  sum(summary2$pop_count)),
            correct = FALSE)  
  
}


# For testing
# education_category_diff_test(summary = combined_age_education_summary, 
#                              age_cat1 = "26-35", 
#                              age_cat2 = "36-49", 
#                              education_cat = "4-8", 
#                              pop_cat = "prison_pop_count")