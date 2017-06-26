import pandas as pd
import scipy
import numpy as np
from scipy.stats import ttest_ind

'''
This code searches for any significant differences in attitudes between the prisoners with child in certain age groups
and all other prisons (including those with prisoners in difference age groups)
'''

df = pd.read_excel('survey_results_clean.csv.xlsx') # give the path to the survey here
cols = df.columns.values
df['cu5'] = np.where(df['children_aged_under_5'] >0, True, False) # make groups
df['c5_12'] = np.where(df['children_aged_5_12'] >0, True, False)
df['cadult'] = np.where(df['adult_children'] >0, True, False)
df['c12_18'] = np.where((df['boys_under_18'] + df['girls_under_18'] - df['children_aged_5_12'] - df['children_aged_under_5']) > 0, True, False)

df.describe()

for childgroup in ['cu5','c5_12','c12_18','cadult']:
    for col in cols:
        if len(str(col)) > 40: # get only the prison service cols
            tsample = df.loc[df[childgroup], col].values # group where value is true
            fsample = df.loc[np.invert(df[childgroup]), col].values # group where value is false
            tstat, pval = ttest_ind(tsample, fsample) # is there a significant difference in the distributions?
            if pval < 0.05:
                gdf = df.groupby(childgroup) # group by true and false
                means = gdf.mean()
                counts = gdf.count()
                print('Pvalue = '+str(pval)) # print significance, numbers and groups
                print('Tstat = '+str(tstat))
                print(means[col])
                print('Percentage less satisfied than other: '+str(100.0*(means[col][0]-means[col][1])/means[col][1]))

