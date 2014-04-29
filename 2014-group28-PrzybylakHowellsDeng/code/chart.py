import statsmodels
import os
import numpy as np
import pandas as pd

import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import datetime as dt

from sklearn.preprocessing import scale
from sklearn.preprocessing import Imputer
from sklearn.preprocessing import normalize

def nan_helper(y):
    """Helper to handle indices and logical indices of NaNs.

    Input:
        - y, 1d numpy array with possible NaNs
    Output:
        - nans, logical indices of NaNs
        - index, a function, with signature indices= index(logical_indices),
          to convert logical indices of NaNs to 'equivalent' indices
    Example:
        >>> # linear interpolation of NaNs
        >>> nans, x= nan_helper(y)
        >>> y[nans]= np.interp(x(nans), x(~nans), y[~nans])
    """

    return np.isnan(y), lambda z: z.nonzero()[0]

os.chdir('/Users/jonathanhowells/Dropbox/IRDM-Twitter/alg1/')

companies = ['boeing', '3m', 'caterpillar']

for company in companies:
    folder = 'data/' + company + '/'
    data = pd.read_csv(folder + company + 'share.csv')
    y=data['Adj Close'].values
    date = data['Date'].values


    negative = data['Negative'].values
    neutral = data['Neutral'].values
    positive = data['Positive'].values

    nans, x= nan_helper(negative)
    negative[nans]= np.interp(x(nans), x(~nans), negative[~nans])

    nans, x= nan_helper(neutral)
    neutral[nans]= np.interp(x(nans), x(~nans), neutral[~nans])

    nans, x= nan_helper(positive)
    positive[nans]= np.interp(x(nans), x(~nans), positive[~nans])

    nans, x= nan_helper(y)
    y[nans]= np.interp(x(nans), x(~nans), y[~nans])


    sentiment = np.column_stack((negative,neutral,positive))

    sentiment

    sentiment_score = []

    for i in range(sentiment.shape[0]):
        score = (sentiment[i,2] - sentiment[i,0])/(sum(sentiment[i,:]))
        sentiment_score.append(score)

    sentiment_score


    x = [dt.datetime.strptime(d,'%d/%m/%Y').date() for d in date]

    fig, ax1 = plt.subplots()
    y_norm = scale(y)

    plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%d/%m/%Y'))
    plt.gca().xaxis.set_major_locator(mdates.AutoDateLocator())
    
    ax1.plot(x,sentiment_score,'r-')
    ax1.set_xlabel('Date')
    ax1.set_ylabel('Sentiment', color='b')
    
    for tl in ax1.get_yticklabels():
        tl.set_color('b')
    
    ax2 = ax1.twinx()
    ax2.plot(x, y, 'b-')
    ax2.set_ylabel('Share Price', color='r')
    for tl in ax2.get_yticklabels():
        tl.set_color('r')
        
    title = company + ' Share Price and Sentiment'
    plt.title(title)
    plt.legend()
    plt.grid()
    plt.gcf().autofmt_xdate()
    plt.savefig(company + "graph")
    plt.show()