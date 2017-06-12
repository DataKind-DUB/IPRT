
# coding: utf-8

'''
This code finds common bigrams (two words in a row that aren't nonsense words like "the" etc.) for the free text fields in the survey
To run, just execute this code after making sure that the path below is correct
To see the plots generated, copy the entire code to a jupyter notebook and run
Note - this code seems to be python 2 compatible only
'''

import pandas as pd
import numpy as np
# import nltk
# from nltk.tokenize import word_tokenize
# from collections import Counter
# from nltk.corpus import stopwords
# import string
# from nltk.stem import PorterStemmer
# from nltk import ngrams
import seaborn as sns
from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import nltk
from nltk.tokenize import word_tokenize
from collections import Counter
from nltk.corpus import stopwords
import string
from nltk.stem import PorterStemmer
from nltk import ngrams

get_ipython().magic('matplotlib inline')


# In[5]:





# In[7]:

df = pd.read_csv('survey_results_clean.csv', na_values=['nan']) # this is the path to the file


# Note: Population distribution is not normal, therefore certain groups will appear as having a stronger signal than others. It might be a good idea to correct this if each age group is to be considered equal. Alternatively, if the majority of the population is to be considered only, then can leave the data as is.
# 

# In[8]:

df['age'].value_counts()


# The results for improving family visits and facilities seem to suggest the same common theme. First, run each column individually, then combine the two.

# ### Binary Fields:
# 
# Count the filled in binary fields.

# #### Family contact: 

# In[9]:

contact_cols = [col for col in df.columns if 'improve_contact_family' in col] #find all the contact family cols
contact_cols.extend(['age', 'sentence_length', 'prison_wing_main']) # interested in breaking out the results using these cols
contact_clean_data = df[contact_cols].fillna(0)


# In[6]:

#split_cols = to_plot.columns.map(lambda x: x.split('_')[3:])


# Mean normalize:

# In[7]:

# Leaving this out as it might not be suitable to give equal weight to each population group.
#pop_max = df.groupby('age')['Unnamed: 0'].count().max()
#pop_min = df.groupby('age')['Unnamed: 0'].count().min()


# By Age:

# In[10]:

#tp_scaled = to_plot.T.apply(lambda x: (x - pop_min)/(pop_max - pop_min))

to_plot = contact_clean_data.groupby('age').sum()

sns.heatmap(to_plot.T)


# By sentence length:

# In[11]:

to_plot = contact_clean_data.groupby('sentence_length').sum()

sns.heatmap(to_plot.T)


# By prison wing:

# In[12]:

to_plot = contact_clean_data.groupby('prison_wing_main').sum()

sns.heatmap(to_plot.T)


#  #### Facilities improvement binary fields

# In[13]:

fac_cols = [col for col in df.columns if 'prison_service_facilities' in col]
fac_cols.extend(['age', 'sentence_length', 'prison_wing_main'])
fac_clean_data = df[fac_cols].fillna(0)


# By age:

# In[14]:

to_plot_fac = fac_clean_data.groupby('age').sum()
tp_fac = to_plot_fac.copy()
#tp_fac = tp_fac.T.apply(lambda x: (x - pop_min)/(pop_max - pop_min))

sns.heatmap(tp_fac.T)


# By sentence length:

# In[15]:

to_plot_fac = fac_clean_data.groupby('sentence_length').sum()
tp_fac = to_plot_fac.copy()
#tp_fac = tp_fac.T.apply(lambda x: (x - pop_min)/(pop_max - pop_min))

sns.heatmap(tp_fac.T)


# By prison wing:

# In[14]:

to_plot_fac = fac_clean_data.groupby('prison_wing_main').sum()
tp_fac = to_plot_fac.copy()
#tp_fac = tp_fac.T.apply(lambda x: (x - pop_min)/(pop_max - pop_min))

sns.heatmap(tp_fac.T)


# ### Free Text Analysis:

# Combine the free text thought fields, these yield similar results individually. Combined together they can send a stronger message for the desired improvements within the facility.

# In[16]:

df['thoughts_facs'] = df['prison_service_facilities_other_thoughts'] + df['improve_contact_family_other_suggestions']


# In[19]:

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


# In[18]:

pd.DataFrame(sentence_ngrams['sentence_length'])


# In[18]:

pd.DataFrame(sentence_ngrams['age'])


# In[19]:

# need to remove wing J as it has no free text values
sentence_ngrams['prison_wing_main'].pop('J')


# In[20]:

pd.DataFrame(sentence_ngrams['prison_wing_main'])


# Regardless of any age, sentence or prison wing detail, it appears there is a theme for desired improvements:

# In[21]:

words1 = df[pd.notnull(df['thoughts_facs'])]['thoughts_facs'].tolist()
w1 = ' '.join(words1)
all_tokens = [t for t in word_tokenize(w1)]
tokens_no_stop = lower_no_stops(all_tokens)
Counter(ngrams(stem_all(all_tokens), 2)).most_common(10)


# #### Misc work

# Is there a connection between whent he survey was taken and the responses?

# In[22]:

df['survey_time'] = pd.to_datetime(df['survey_time'])
clean_data_time = df.set_index('survey_time')


# Break out by day:

# In[23]:

by_day = {}
for idx, grp in clean_data_time.groupby(pd.Grouper(freq='D')):
    print idx, len(grp)
    words1 = grp[pd.notnull(grp['thoughts_facs'])]['thoughts_facs'].tolist()
    w1 = ' '.join(words1)
    all_tokens = [t for t in word_tokenize(w1)]
    tokens_no_stop = lower_no_stops(all_tokens)
    by_day[idx]= Counter(ngrams(stem_all(all_tokens), 2)).most_common(5)



# Potentially should not be surprising to see common responses on common days. 

# In[24]:

count_nulls = df.replace(np.NaN, -1)


# Count the number of nan's per age group

# In[25]:

print groups[0]
count_nulls[count_nulls[groups[0]] == -1].groupby('age')[groups[0]].count()


# In[26]:


print groups[1]
count_nulls[count_nulls[groups[1]] == -1].groupby('age')[groups[1]].count()


# Can do the above for sentence length, prison wing

# In[27]:

df['children_number'].value_counts()


# In[28]:

print groups[1]
count_nulls[count_nulls[groups[1]] == -1].groupby('children_number')[groups[1]].count()


# Does not look like there is any connection between the number of children and leaving free text comments in the thoughts fields.

# In[29]:

adf = df['age'].value_counts()
fig, ax = plt.subplots(figsize=(10,8))
#ax.set_facecolor('w')
ax.grid(color=(0.5,0.5,0.5),lw=0.25)
# df['age'].value_counts().plot(kind='bar')
# plt.plot(x=df['age']data=df['age'].value_counts)
x_pos = np.arange(len(adf.index))
ax.bar(x_pos, adf.values, width=0.25)

ax.set_xticks(x_pos)
ax.set_xticklabels(adf.index)
print



# In[ ]:



