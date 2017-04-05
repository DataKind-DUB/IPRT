
# coding: utf-8

# In[ ]:

# import all of the necessary modules

import pandas as pd
import numpy as np
from nltk.corpus import stopwords
from nltk.tokenize import wordpunct_tokenize
from nltk.stem.snowball import SnowballStemmer
from autocorrect import spell
from wordcloud import WordCloud
from matplotlib import pyplot as plt
from PIL import Image
from collections import Counter
from nltk import word_tokenize
from nltk.util import ngrams

# define a function that will make a wordcloud
# optionally, it can use a masked image to make a particular shape, or use bigrams instead of words
def make_wordcloud(df, column_name, title, output_name, mask = False, bigram_mode = False):
    stop_words = set(stopwords.words('english'))  # these are nonsense words that don't belong in the wordcloud ('a','the' etc.)
    stemmer = SnowballStemmer("english")# this stemmer will clip the end of words so that begins and begin etc. look the same
    
    stop_words.update(['.', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}']) # add some characters to the stopwords
    
    # for every entry in the column, get the list of words and stem them. remove stop words
    word_list = [stemmer.stem(i.lower()) for i in wordpunct_tokenize(" ".join(df[column_name].dropna())) if i.lower() not in stop_words]
    
    # correct any spelling mistakes introduced by the stemmer
    word_list = [spell(i) for i in word_list]
    
    # if making bigrams, join together every successive word with an _ => fat cat -> fat_cat
    if bigram_mode:
        tokens = word_tokenize(' '.join(word_list))
        bigrams=list(ngrams(tokens,2))
        word_list = [bigram[0]+'_'+bigram[1] for bigram in bigrams]
        #print(word_list)
    
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


# In[ ]:

fn = 'survey_results_clean.csv.xlsx' # the survey file

df = pd.read_excel(fn, delimiter = '\t') # load the file into a pandas data frame

mask = np.array(Image.open("children_bw.jpg")) # get the children binary image for making

# now call the function to actually make the clouds - once for each combination of free text columns and options

# simple
make_wordcloud(df, 'prison_service_facilities_other_thoughts', 'Other thoughts', 'other_thoughts.png', False, False)
make_wordcloud(df, 'improve_contact_family_other_suggestions', 'Suggestions to improve contact with family', 'improve_contact_suggestions.png', False, False)

# with mask
make_wordcloud(df, 'prison_service_facilities_other_thoughts', 'Other thoughts', 'other_thoughts.png', mask, False)
make_wordcloud(df, 'improve_contact_family_other_suggestions', 'Suggestions to improve contact with family', 'improve_contact_suggestions.png', mask, False)

# bigrams
make_wordcloud(df, 'prison_service_facilities_other_thoughts', 'Other thoughts (bigrams)', 'other_thoughts.png', False, True)
make_wordcloud(df, 'improve_contact_family_other_suggestions', 'Suggestions to improve contact with family (bigrams)', 'improve_contact_suggestions.png', False, True)


# In[ ]:



