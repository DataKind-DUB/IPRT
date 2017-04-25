
# coding: utf-8

# In[6]:

get_ipython().magic('matplotlib inline')
import pandas as pd
import scikits.bootstrap as bootstrap
import scipy
import numpy as np
from matplotlib import pyplot as plt

df = pd.read_excel('survey_results_clean.csv.xlsx')
df['children_aged_12_18']=df['boys_under_18'].values + df['girls_under_18'].values - df['children_aged_5_12'].values - df['children_aged_under_5'].values


# In[10]:

df.describe()


# In[2]:

num_children, conf_ints_children = scipy.sum(df['children_number']), bootstrap.ci(data=df['children_number'], statfunction=scipy.sum)
num_children_u5, conf_ints_children_u5 = scipy.sum(df['children_aged_under_5']), bootstrap.ci(data=df['children_aged_under_5'], statfunction=scipy.sum)
num_children_5to12, conf_ints_children_5to12 = scipy.sum(df['children_aged_5_12']), bootstrap.ci(data=df['children_aged_5_12'], statfunction=scipy.sum)
num_children_12to18, conf_ints_children_12to18 = scipy.sum(df['children_aged_12_18']), bootstrap.ci(data=df['children_aged_12_18'], statfunction=scipy.sum)
num_adult_children, conf_ints_adult_children = scipy.sum(df['adult_children']), bootstrap.ci(data=df['adult_children'], statfunction=scipy.sum)


# In[21]:

print('Number of children with parent in Midlands Prison: '+str(conf_ints_children[0])+' to '+str(conf_ints_children[1]))
print('Number of children under 5 with parent in Midlands Prison: '+str(conf_ints_children_u5[0])+' to '+str(conf_ints_children_u5[1]))
print('Number of children between 5 and 12 with parent in Midlands Prison: '+str(conf_ints_children_5to12[0])+' to '+str(conf_ints_children_5to12[1]))
print('Number of children between 12 and 18 with parent in Midlands Prison: '+str(conf_ints_children_12to18[0])+' to '+str(conf_ints_children_12to18[1]))
print('Number of adult children with parent in Midlands Prison: '+str(conf_ints_adult_children[0])+' to '+str(conf_ints_adult_children[1]))


# In[22]:

total_num_prisoners = 3674 # http://www.iprt.ie/prison-facts-2
survey_population = 383
irish_conf_ints_children = scipy.multiply(conf_ints_children, total_num_prisoners/survey_population)
irish_conf_ints_children_u5 = scipy.multiply(conf_ints_children_u5, total_num_prisoners/survey_population)
irish_conf_ints_children_5to12 = scipy.multiply(conf_ints_children_5to12, total_num_prisoners/survey_population)
irish_conf_ints_children_12to18 = scipy.multiply(conf_ints_children_12to18, total_num_prisoners/survey_population)
irish_conf_ints_adult_children = scipy.multiply(conf_ints_adult_children, total_num_prisoners/survey_population)


# In[24]:

print('Assuming a total Irish prison population of '+str(total_num_prisoners) + ' and a survey sample of '+str(survey_population)+':')
print('Number of children with parent in an Irish Prison: '+str(int(np.ceil(irish_conf_ints_children[0])))+' to '+str(int(np.ceil(irish_conf_ints_children[1]))))
print('Number of children under 5 with parent in an Irish Prison: '+str(int(np.ceil(irish_conf_ints_children_u5[0])))+' to '+str(int(np.ceil(irish_conf_ints_children_u5[1]))))
print('Number of children between 5 and 12 with parent in an Irish Prison: '+str(int(np.ceil(irish_conf_ints_children_5to12[0])))+' to '+str(int(np.ceil(irish_conf_ints_children_5to12[1]))))
print('Number of children between 12 and 18 with parent in an Irish Prison: '+str(int(np.ceil(irish_conf_ints_children_12to18[0])))+' to '+str(int(np.ceil(irish_conf_ints_children_12to18[1]))))
print('Number of adult children with parent in an Irish Prison: '+str(int(np.ceil(irish_conf_ints_adult_children[0])))+' to '+str(int(np.ceil(irish_conf_ints_adult_children[1]))))


# In[25]:

bins = ['0-5','5-12','12-18','Over 18']
ind = np.arange(len(bins))
vals = [num_children_u5, num_children_5to12,num_children_12to18,num_adult_children]
plt.figure()
plt.bar(ind, vals)
plt.xticks(ind+0.35,bins)
plt.xlabel('Age of Children')
plt.ylabel('Total Children')
plt.title('Age distribution of children with a parent in Midlands\' prison')
#plt.show()
plt.savefig('children_ages.png',dpi=300)


# In[ ]:



