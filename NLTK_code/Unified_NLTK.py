
# coding: utf-8

# # Here I have combined the three codes from Colm, Irene and Grainne on the text analysis
# 
# I have only included the weigthed bigrams and trigrams. Irene has a method of taking the most commong bigrams and trigrams which give slightly different results. 
# 

# In[1]:

# import all of the necessary modules

import pandas as pd
import numpy as np
import seaborn as sns
import nltk
from nltk.corpus import stopwords
from nltk import word_tokenize
from nltk.tokenize import wordpunct_tokenize
from nltk.stem.snowball import SnowballStemmer
from nltk.stem import PorterStemmer
from nltk import ngrams
from nltk import FreqDist
from nltk.collocations import *

from autocorrect import spell
from wordcloud import WordCloud
from matplotlib import pyplot as plt
from PIL import Image
from collections import Counter

import string
import random


# # Functions

# In[2]:

#Functions from Colm's Code. 

# define a function that will make a wordcloud
# optionally, it can use a masked image to make a particular shape, or use bigrams instead of words
def make_wordcloud(df, column_name, title, output_name, mask = False):
    stop_words = set(stopwords.words('english'))  # these are nonsense words that don't belong in the wordcloud ('a','the' etc.)
    stemmer = SnowballStemmer("english")# this stemmer will clip the end of words so that begins and begin etc. look the same
    
    stop_words.update(['.', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}']) # add some characters to the stopwords
    
    # for every entry in the column, get the list of words and stem them. remove stop words
    word_list = [stemmer.stem(i.lower()) for i in wordpunct_tokenize(" ".join(df[column_name].dropna())) if i.lower() not in stop_words]
    
    # correct any spelling mistakes introduced by the stemmer
    word_list = [spell(i) for i in word_list]
    
    #print(Counter(word_list).most_common(100))
    # if a mask has been provided, use it. Otherwise just make a normal wordcloud
    try:
        np.shape(mask)
        wordcloud = WordCloud(background_color="white", max_words = 200, min_font_size = 10, max_font_size=40, mask = mask).generate(' '.join(word_list))
    except:
        wordcloud = WordCloud(background_color="white", max_words = 100, min_font_size = 10, max_font_size=40).generate(' '.join(word_list))
        
    # now that the wordcloud has been generated, plot it.
    plt.figure() # make a new figure
    plt.imshow(wordcloud) # show the wordcloud
    plt.axis("off") # remove the axes
    plt.title(title) # give it a title
    plt.show() # show the image
    #plt.savefig(output_name, dpi = 300) # optionally, save it to the working directory
    
    
    


# In[3]:

## Functions from Grainne's code. 

#Function from Colm C. 
def make_tkn_text(df, column_name):
    stop_words = set(stopwords.words('english'))
    stemmer = SnowballStemmer("english")
    
    stop_words.update(['.', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}'])
    
    #remove stop words and punctuation from text. Make into one long string. 
    #reduce words to their 'stem' so we do not get repetitions of same form  i.e. say and saying. 
    word_list = [stemmer.stem(i.lower()) for i in wordpunct_tokenize(" ".join(df[column_name].dropna())) if i.lower() not in stop_words]
    word_list = [spell(i) for i in word_list]
    workable_text = ' '.join(word_list)
        
    tokenized_text = nltk.tokenize.word_tokenize(workable_text)
        
    return tokenized_text

# Ten most common words are found given table and column name. 
def Ten_most_common(table,column_name):
    #Make a full string of text column and split into words
    field_Tkn = make_tkn_text(table,column_name)
    #Find frequency distribution
    fdist_field = FreqDist(field_Tkn)
    #return top 10 words. 
    return fdist_field.most_common(10)


# In[4]:

def Field_bigrams(table,column_name,filter_freq,no2return):
    #A pandas dataframe is given with the column name, the filter frequency to be applied to the bigram or trigram, and the number of results to be returned. 
    #The field is converted to a string, and tokenized before being passed ot the bigram fn. 
   
    field_Tkn = make_tkn_text(table,column_name)    
    bigram_measures = nltk.collocations.BigramAssocMeasures()
    finder = BigramCollocationFinder.from_words(field_Tkn)

    #Words can be highly collocated but the expressions are also very infrequent. 
    #Therefore it is useful to apply filters, such as ignoring all bigrams which occur 
    #less than three times in the corpus.
    #PMI: Pointwise Mutual Information
    finder.apply_freq_filter(filter_freq)
    finder1 = BigramCollocationFinder.from_words(field_Tkn)
    finder1.score_ngrams(bigram_measures.pmi)
    return finder.nbest(bigram_measures.pmi, no2return)


# In[5]:

def Field_trigrams(table,column_name,filter_freq, no2return):
    field_Tkn = make_tkn_text(table,column_name)    
    trigram_measures = nltk.collocations.TrigramAssocMeasures()
    finder = TrigramCollocationFinder.from_words(field_Tkn)
    
    #A different way to filter the results for how often they occur. 
    #scored = finder.score_ngrams(trigram_measures.raw_freq)
    #set(trigram for trigram, score in scored) == set(nltk.trigrams(field_Tkn))
    #return sorted(finder.nbest(trigram_measures.raw_freq,filter_freq))
    
    finder.apply_freq_filter(filter_freq)
    return finder.nbest(trigram_measures.pmi, no2return)


# # Reading in survey

# In[6]:

df = pd.read_csv('survey_results_clean.csv', na_values=['nan'])

#Analysis of both free text fields together. 
df['thoughts'] = df['prison_service_facilities_other_thoughts'] + df['improve_contact_family_other_suggestions']



# In[7]:

# From Irene's code. 

# Weigthed Bigrams and common words. 
common_words = {}
bigrams_phrases = {}
trigrams_phrases = {}

# Selection of columns over which we will split the analysis
for col in ['sentence_length', 'age', 'prison_wing_main','children']:
    common_temp = {}
    bigrams_temp = {}
    trigrams_temp = {}
    
    for idx, grp in df.groupby(col):
        #Tokenise text and find 10 most common words in each column. 
        field_Tkn = make_tkn_text(grp,'thoughts')    
        common_temp[idx]= Counter(field_Tkn).most_common(10)
        
        #Return bigrams and trigrams from each column
        #Up to 10 are returned. Only those that occur three times or more are returned. 
        bigrams_temp[idx] = Field_bigrams(grp,'thoughts',3,10)
        trigrams_temp[idx] = Field_trigrams(grp,'thoughts',3,10)


    common_words[col] = common_temp
    bigrams_phrases[col] = bigrams_temp
    trigrams_phrases[col] = trigrams_temp



# # Analysis

# In[17]:

#pd.DataFrame(common_words['children'])
#pd.DataFrame(common_words['prison_wing_main'])
#pd.DataFrame(common_words['age'])
#pd.DataFrame(common_words['sentence_length'])
pd.DataFrame(common_words['children'])


# In[18]:

pd.DataFrame(common_words['age'])


# In[19]:

pd.DataFrame(common_words['sentence_length'])


# In[22]:

print('Wing A',common_words['prison_wing_main']['A'])
print('Wing A',common_words['prison_wing_main']['A'])
print('Wing B',common_words['prison_wing_main']['B'])
print('Wing C',common_words['prison_wing_main']['C'])
print('Wing D',common_words['prison_wing_main']['D'])
print('Wing E',common_words['prison_wing_main']['E'])
common_words['prison_wing_main']


# #  Bigrams and trigrams 

# ## Children

# In[23]:

print(bigrams_phrases['children']['No'])
print(bigrams_phrases['children']['Yes'])


# In[44]:

print(trigrams_phrases['children']['No'])
print(trigrams_phrases['children']['Yes'])


# ## Prison Wing

# In[25]:

# Problem with the wings. In wing E there are only 3 bigrams that occur more that 3 times. 
# Therefore we cannot print out all together as above. 

print('Wing A',bigrams_phrases['prison_wing_main']['A'])
print('Wing A',bigrams_phrases['prison_wing_main']['A'])
print('Wing B',bigrams_phrases['prison_wing_main']['B'])
print('Wing C',bigrams_phrases['prison_wing_main']['C'])
print('Wing D',bigrams_phrases['prison_wing_main']['D'])
print('Wing E',bigrams_phrases['prison_wing_main']['E'])


# In[45]:

# Problem with the wings. In wing E there are only 3 bigrams that occur more that 3 times. 
# Therefore we cannot print out all together as above. 

print('Wing A',trigrams_phrases['prison_wing_main']['A'])
print('Wing A',trigrams_phrases['prison_wing_main']['A'])
print('Wing B',trigrams_phrases['prison_wing_main']['B'])
print('Wing C',trigrams_phrases['prison_wing_main']['C'])
print('Wing D',trigrams_phrases['prison_wing_main']['D'])
print('Wing E',trigrams_phrases['prison_wing_main']['E'])


# ## Sentence Length

# In[26]:

print('1 - 3 years',pd.DataFrame(bigrams_phrases['sentence_length']['1 - 3 years']))
print('3-5 years',pd.DataFrame(bigrams_phrases['sentence_length']['3 - 5 years']))
print('5-10 years',pd.DataFrame(bigrams_phrases['sentence_length']['5 - 10 years']))
print('Life',pd.DataFrame(bigrams_phrases['sentence_length']['Life']))

#'6 - 12 months', 'Im on remand.': only 1 result. 'Under 6 months': all with less than 2 results. 


# In[42]:

print('1 - 3 years',pd.DataFrame(trigrams_phrases['sentence_length']['1 - 3 years']))
print('3-5 years',pd.DataFrame(trigrams_phrases['sentence_length']['3 - 5 years']))
print('5-10 years',pd.DataFrame(trigrams_phrases['sentence_length']['5 - 10 years']))
print('Life',pd.DataFrame(trigrams_phrases['sentence_length']['Life']))


# ## Age

# In[63]:


print('18 - 21 years',pd.DataFrame(bigrams_phrases['age']['18-21']))
print('22 - 25 years',pd.DataFrame(bigrams_phrases['age']['22-25']))
print('26 - 35 years',pd.DataFrame(bigrams_phrases['age']['26-35']))
print('36 - 49 years',pd.DataFrame(bigrams_phrases['age']['36-49']))
print('50 - 64',pd.DataFrame(bigrams_phrases['age']['50-64']))

#No results for 65+



# In[64]:

print('18 - 21 years',pd.DataFrame(trigrams_phrases['age']['18-21']))
print('22 - 25 years',pd.DataFrame(trigrams_phrases['age']['22-25']))
print('26 - 35 years',pd.DataFrame(trigrams_phrases['age']['26-35']))
print('36 - 49 years',pd.DataFrame(trigrams_phrases['age']['36-49']))
print('50 - 64',pd.DataFrame(trigrams_phrases['age']['50-64']))


# # Word Cloud

# In[41]:

mask = np.array(Image.open("children_bw.jpg")) # get the children binary image for making

# now call the function to actually make the clouds - once for each combination of free text columns and options

# simple
make_wordcloud(df, 'thoughts', 'Thoughts', 'Thoughts.png', False)
#make_wordcloud(df, 'improve_contact_family_other_suggestions', 'Suggestions to improve contact with family', 'improve_contact_suggestions.png', False)

# with mask
make_wordcloud(df, 'thoughts', 'Thoughts', 'other_thoughts.png', mask)
#make_wordcloud(df, 'improve_contact_family_other_suggestions', 'Suggestions to improve contact with family', 'improve_contact_suggestions.png', mask)

# bigrams
######## This needs to be redone for the new bigrams above. 
######## We were talking about doing similar to what Colm had done and join the top 10 or so with an _ and printing that. 
#make_wordcloud(df, 'prison_service_facilities_other_thoughts', 'Other thoughts (bigrams)', 'other_thoughts.png', False)
#make_wordcloud(df, 'improve_contact_family_other_suggestions', 'Suggestions to improve contact with family (bigrams)', 'improve_contact_suggestions.png', False)


# In[73]:

# Making word cloud with some bigrams
bigram_list = []
for i in range(0,9):
     bigram_list += bigrams_phrases['children']['Yes'][i][0]+' '+bigrams_phrases['children']['Yes'][i][1]+'.'
## This does not work. 


# In[ ]:



