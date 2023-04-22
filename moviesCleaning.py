#!/usr/bin/env python
# coding: utf-8

# In[3]:


# import libraries

import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8) # Adjust the configuration of the plots we will create

# READ IN THE DATA ***************************************************************************************************

df = pd.read_csv(r"C:\Users\Gus\Desktop\Data Analytics\movies\movies.csv")


# In[4]:


# LET'S LOOK AT THE DATA *********************************************************************************************
df.head()


# In[5]:


# LET'S SEE IF THERE IS ANY MISSING DATA **************************************************************************** 
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, pct_missing))


# In[7]:


# DATA TYPES FOR OUR COLUMNS ****************************************************************************************
df.dtypes


# In[13]:


# LET'S FILL NAN CELLS FOR 0 (ZERO)
df = df.fillna(0)
print(df)


# In[20]:


# CHANGE DATA TYPE OF COLUMNS **************************************************************************************
df['budget'] = df['budget'].astype('int64')
df['gross'] = df['gross'].astype('int64')
df['runtime'] = df['runtime'].astype('int64')
df['votes'] = df['votes'].astype('int64')


# In[54]:


# CREATE CORRECT YEAR COLUMN FORM RELEASED COLUMN
df['yearcorrect'] = df['released'].astype(str)
test = []
for row in df['yearcorrect']:
    start = row.find(',')
    test.append(row[start+2:start+6])
df['yearcorrect'] = test
df


# In[ ]:




