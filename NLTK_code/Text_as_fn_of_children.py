
# coding: utf-8

# # Analysis of text fields as a function of having children or not. 
# - Text is read in as a panda data frame. 
# - It is then split dependent on whether the person has children or not. (There should be a better way to do this but I just used kids_present = survey[survey['children'] == 'Yes'] )
# - 10 most common words, bigrams and trigrams are then found for children or no children selection. 
# - See below for more information on how bigrams and trigrams are found. 

'''
To run, make sure the path is correct (fn = 'survey_results_clean.csv.xlsx')
The easiest way to execute this is probably in a jupyter notebook - some of the plots are not saved to a file
'''

import pandas as pd
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import wordpunct_tokenize
from nltk.stem.snowball import SnowballStemmer
from nltk import FreqDist
from nltk.collocations import *

from autocorrect import spell
from wordcloud import WordCloud
from matplotlib import pyplot as plt
import random


#Function from Colm C. 
def make_text_string(df, column_name):
    
    
    stop_words = set(stopwords.words('english'))
    stemmer = SnowballStemmer("english")
    
    stop_words.update(['.', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}'])
    
    #remove stop words and punctuation from text. Make into one long string. 
    #reduce words to their 'stem' so we do not get repetitions of same form  i.e. say and saying. 
    word_list = [stemmer.stem(i.lower()) for i in wordpunct_tokenize(" ".join(df[column_name].dropna())) if i.lower() not in stop_words]
    word_list = [spell(i) for i in word_list]
    workable_text = ' '.join(word_list)
        
    return workable_text

# Ten most common words are found given table and column name. 
def Ten_most_common(table,column_name):
    #Make a full string of text column
    field_txt = make_text_string(table,column_name)
    #Split into words. 
    field_Tkn = nltk.tokenize.word_tokenize(field_txt)
    #Find frequency distribution
    fdist_field = FreqDist(field_Tkn)
    #return top 10 words. 
    return fdist_field.most_common(10)


# Here we are searching for bigrams and trigrams. 
# 
# I apply a frequency filter to show only those bigrams that appear more than 3 times in the text.
# WRT the measures. PMI measures the association of two words by calculating the log ( p(x|y) / p(x) ), so it's not only about the frequency of a word occurrence or a set of words concurring together. To achieve high PMI, you need both:
# High p(x|y)
# low p(x)
# So unusual words occuring with the same word will get a higher rank than other bigrams.
# 
# Note: I found it useful to look at the scores of the bigrams and trigrams to understand what was going on. 
# 
# 

# In[16]:

def Field_bigrams(table,column_name,filter_freq,no2return):
    #A pandas dataframe is given with the column name, the filter frequency to be applied to the bigram or trigram, and the number of results to be returned. 
    #The field is converted to a string, and tokenized before being passed ot the bigram fn. 
    
    field_txt = make_text_string(table,column_name)
    field_Tkn = nltk.tokenize.word_tokenize(field_txt)
    
    bigram_measures = nltk.collocations.BigramAssocMeasures()
    finder = BigramCollocationFinder.from_words(field_Tkn)

    #Words can be highly collocated but the expressions are also very infrequent. 
    #Therefore it is useful to apply filters, such as ignoring all bigrams which occur 
    #less than three times in the corpus:
    finder.apply_freq_filter(filter_freq)
    return finder.nbest(bigram_measures.pmi, no2return)


def Field_trigrams(table,column_name,filter_freq, no2return):
    field_txt = make_text_string(table,column_name)
    field_Tkn = nltk.tokenize.word_tokenize(field_txt)
    
    trigram_measures = nltk.collocations.TrigramAssocMeasures()
    finder = TrigramCollocationFinder.from_words(field_Tkn)
    
    #A different way to filter the results for how often they occur. 
    #scored = finder.score_ngrams(trigram_measures.raw_freq)
    #set(trigram for trigram, score in scored) == set(nltk.trigrams(field_Tkn))
    #return sorted(finder.nbest(trigram_measures.raw_freq,filter_freq))
    
    finder.apply_freq_filter(filter_freq)
    return finder.nbest(trigram_measures.pmi, no2return)


# In[17]:

## Read in survey results. 
fn = 'survey_results_clean.csv.xlsx'
#survey = pd.read_excel(fn, delimiter = '\t')
survey = pd.read_excel(fn)


# In[18]:

## Seperating those with and without kids. 
## There should be a better way to do this: pandas groupby
kids_present = survey[survey['children'] == 'Yes']
print('No people with kids',len(kids_present))
no_kids = survey[survey['children'] == 'No']
print('No of people without kids',len(no_kids))


# In[19]:

#Return the top 10 words within this text field
Ten_most_common(kids_present,'improve_contact_family_other_suggestions')


# In[20]:

# Searcing for bigrams but ignoring all bigrams which occur less than 3 times in the corpus:
Field_bigrams(kids_present,'improve_contact_family_other_suggestions',3,10)


# In[9]:

# Searcing for bigrams but ignoring all bigrams which occur less than 5 times in the corpus:
Field_bigrams(kids_present,'improve_contact_family_other_suggestions',5,5)

#Check context of some words....
#noK_improve_txt.concordance('fail')
#noK_improve_txt.concordance('meal')

# It was useful for me to look at the scorings of these bigrams to see how they were working. 
# scored = finder.score_ngrams(bigram_measures.raw_freq)
# set(trigram for trigram, score in scored) == set(nltk.trigrams(K_improve_Tkn))
# select only the top n results:


# In[38]:

#Showing the top three trigrams for this text field. 
Field_trigrams(kids_present,'improve_contact_family_other_suggestions',6,3)


# In[10]:

#Return the top 10 words within this text field
Ten_most_common(no_kids,'improve_contact_family_other_suggestions')


# In[41]:

#Showing the top three trigrams for this text field. 
Field_trigrams(no_kids,'improve_contact_family_other_suggestions',3,3)


# Analysis of *prison_service_facilities_other_thoughts* **with** kids. 

# In[43]:

#Top 10 most common words. 
Ten_most_common(kids_present,'prison_service_facilities_other_thoughts')


# In[44]:

####ignoring all bigrams which occur less than 3 times in the corpus:
Field_bigrams(kids_present,'prison_service_facilities_other_thoughts',3,10)


# In[45]:

####ignoring all bigrams which occur less than 5 times in the corpus:
Field_bigrams(kids_present,'prison_service_facilities_other_thoughts',5,5)


# In[47]:

#Showing the top three trigrams for this text field. 
Field_trigrams(kids_present,'prison_service_facilities_other_thoughts',6,3)


# Analysis of *"prison_service_facilities_other_thoughts"* **without kids**

# In[48]:

#Top 10 most common words. 
Ten_most_common(no_kids,'prison_service_facilities_other_thoughts')


# In[49]:

####ignoring all bigrams which occur less than 3 times in the corpus:
Field_bigrams(no_kids,'prison_service_facilities_other_thoughts',3,10)


# In[50]:

####ignoring all bigrams which occur less than 5 times in the corpus:
Field_bigrams(no_kids,'prison_service_facilities_other_thoughts',5,5)


# In[54]:

#Showing the top three trigrams for this text field. 
Field_trigrams(no_kids,'prison_service_facilities_other_thoughts',3,3)


# ----------------------------------------------------------------
# See if there are any changes when you select by childrens age. 

# In[66]:

adult_kids = survey[survey['adult_children'] == 0]
print('No people with adult kids',len(adult_kids))


# Only 4 people have adult children. Not much point in looking for differences. 

# ----------------------------------------------------------------
# See where the empty fields lie. 

# In[81]:

empty_fields = survey['prison_service_facilities_other_thoughts'].isnull()

#Need to look further into how to manipulate pandas tables in this way. 


# In[ ]:




# # Test on Irene's code. 

# In[10]:

survey['thoughts_facts'] = survey['prison_service_facilities_other_thoughts'] + survey['improve_contact_family_other_suggestions']


# In[11]:

#survey['thoughts_facts'].most_common()
Ten_most_common(survey,'thoughts_facts')


# In[12]:

Field_bigrams(survey,'thoughts_facts',3,10)


# In[ ]:

sentence_ngrams = {}
stop_list = stopwords.words('english') + list(string.punctuation)
groups = ['prison_service_facilities_other_thoughts', 'improve_contact_family_other_suggestions']

for col in ['sentence_length', 'age', 'prison_wing_main']:
    temp = {}
    for idx, grp in df.groupby(col):
        words1 = grp[pd.notnull(grp['thoughts_facs'])]['thoughts_facs'].tolist()
        w1 = ' '.join(words1)
        all_tokens = [t for t in word_tokenize(w1)]
        tokens_no_stop = lower_no_stops(all_tokens)
        temp[idx]= Counter(ngrams(stem_all(all_tokens), 2)).most_common(5)
    
    sentence_ngrams[col] = temp

