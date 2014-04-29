"""
Parse json formated hourly-tweets file.
"""

import re
import os, time, subprocess, shlex
import json

def parseByHour():
    """
    Extract twitter text and date. Then write into tweetshourinfo.txt.
    """
    fileName = 'data/newtweets0.txt'
    fp = open(fileName)
    lines = fp.readlines()
    fp.close()

    outFile = 'data/tweetshourinfo.txt'
    fp = open(outFile, 'w')
    print len(lines);
    for i in xrange(0,len(lines)):
        try:
            data = json.loads(lines[i])
            text = data['text'].encode('utf8')
            text = re.sub(r'\n', r' ', text)
            date = data['created_at'].encode('utf8')
            currTime = time.strptime(date, "%a %b %d %H:%M:%S +0000 %Y")
            date = str(currTime.tm_mon) + '-' + str(currTime.tm_mday) + "-" + str(currTime.tm_hour)
            if i < len(lines)-1:
                fp.write(date + " " + text + "\n")
            else:
                fp.write(date + " " + text)
        except UnicodeDecodeError:
            print i
    fp.close()

def splitByCorp(company):
    """
    Splits tweetsinfo.txt by company name.
    """
    # create a folder
    folder = 'data/' + company
    if not os.path.exists(folder):
        os.makedirs(folder)

    fp = open('data/tweetshourinfo.txt')
    infoLines = fp.readlines()
    fp.close()

    outFile = 'data/' + company + '/' + company + 'tweetshour.txt'
    fp = open(outFile, 'w')
    for i in xrange(0, len(infoLines)):
        if re.search(r"%s" % company, infoLines[i], re.I):
            fp.write(infoLines[i])
    fp.close()

def splityByDate(company):
    """
    Split tweets file of each company into smaller files by date.
    """
    folder = 'data/' + company + '/splithour/'
    if not os.path.exists(folder):
        os.makedirs(folder)

    prefix = 'data/' + company + '/' + company
    fp = open(prefix + 'tweetshour.txt')
    lines = fp.readlines()
    fp.close()

    date = '1-13-20'
    fp = open(folder + date + '.txt', 'w')
    for i in xrange(0,len(lines)):
        temp = lines[i].split()
        if temp[0] != date:
            fp.close()
            date = temp[0]
            fp = open(folder + date + '.txt', 'w')
        fp.write(lines[i])
    fp.close()

def preprocess():
    """
    1. Extract 'created_at' and 'text' from tweets json file newtweets0.txt,
    and write into a smaller file tweetsinfo.txt.
    2. Split tweetsinfo.txt into three files: boeingtweets.txt, caterpillartweets.txt 
    and 3mtweets.txt. Each file contains only information of that company.
    3. Split the above three files into smaller files by date.
    """
    parseByHour()
    companies = ['boeing', 'caterpillar', '3m']
    for company in companies:
        splitByCorp(company)
        splityByDate(company)

def sentiment(tweet):
    """
    Perform sentiment analysis for some given text, using opinionfinder v2.0.
    Input:
        tweet -- text to be analysed.
    Output:
        negative -- number of negative words.
        neutral -- number of neutral words.
        positive -- number of positive words.
    """
    os.chdir('opinionfinderv2.0')
    fp = open('tweet/singletweet.txt', 'w')
    fp.write(tweet)
    fp.close()

    ofCmd = "java -Xmx1g -classpath ./lib/weka.jar:"\
            "./lib/stanford-postagger.jar:opinionfinder.jar "\
            "opin.main.RunOpinionFinder tweet.doclist -d "\
            "-r preprocessor,cluefinder,polarityclass"
    subprocess.call(shlex.split(ofCmd), stdout=None)

    fp = open('tweet/singletweet.txt_auto_anns/exp_polarity.txt')
    content = fp.read();
    fp.close()
    negative = len(re.findall(r"negative", content))
    neutral = len(re.findall(r"neutral", content))
    positive = len(re.findall(r"positive", content))

    os.chdir('..')

    return (negative, neutral, positive) 

def getFeatures(company):
    """
    Apply sentiment analysis for all the tweets concerning that company,
    find the number of negative, neutral and positive words on each day,
    i.e., the features. And write the features into a file, such as,
    data/boeing/boeinghourfeatures.txt.
    """
    folder = 'data/' + company + '/'
    fp = open(folder + company + 'hourfeatures.txt', 'w')
    fp.close()

    dates = [[13,14,15,16,20,21,22,23,26,27,28,29,30], \
                [2,3,4,5,6,9,10,11,12,13,17,18,19,20,23,24,25,26,27], [2]]
    hours = [15,16,17,18,19,20,21]                
    fefp = open(folder + company + 'hourfeatures.txt', 'w+')
    for month in xrange(1,4):
        for day in dates[month-1]:
            for hour in hours:
                tweetFile = str(month) + '-' + str(day) + '-' + str(hour) + '.txt'
                try:
                    fp = open(folder + 'splithour/' + tweetFile)
                    content = fp.read()
                    fp.close()
                    (neg, neu, pos) = sentiment(content)    
                    line = str(month) + "-" + str(day) + '-' + str(hour) + " " + str(neg) + " " \
                        + str(neu) + " " + str(pos)        
                    if month != 3 or day != dates[2][-1]:
                        line = line + '\n'
                    fefp.write(line)
                except:
                    print tweetFile
                    pass
    fefp.close()

def compareTime(time1, time2):
    (month1, day1, hour1) = time1.split('-')
    (month1, day1, hour1) = (int(month1), int(day1), int(hour1))
    (month2, day2, hour2) = time2.split('-')
    (month2, day2, hour2) = (int(month2), int(day2), int(hour2))
    if month1 < month2:
        return -1
    elif month1 == month2:
        if day1 < day2:
            return -1
        elif day1 == day2:
            if hour1 < hour2-1:
                return -1
            elif hour1 == hour2-1:
                return 0
            else:
                return 1
        else:
            return 1
    else:
        return 1

def match(company):
    """
    Match the hour feature and trend by time, because some data is missing.
    """
    folder = 'data/' + company + '/'

    fp = open(folder + company + 'hourfeatures.txt')
    featureLine = fp.readlines()
    fp.close()

    fp = open(folder + company + 'hourtrend.txt')
    trendLine = fp.readlines()
    fp.close()

    fp1 = open(folder + company + 'hourfeaturesmatched.txt', 'w')
    fp2 = open(folder + company + 'hourtrendmatched.txt', 'w')

    index1 = 0
    index2 = 0
    while index1 < len(featureLine) and index2 < len(trendLine):
        feature = featureLine[index1]
        trend = trendLine[index2]
        comp = compareTime(feature.split()[0], trend.split()[0])
        if comp == 0:
            fp1.write(feature)
            fp2.write(trend)
            index1 += 1
            index2 += 1
        elif comp < 0:
            index1 += 1
        else:
            index2 += 1

    fp1.close()
    fp2.close()

if __name__ == '__main__':
    start = time.time()
    # preprocess()
    # for company in ['boeing', '3m', 'caterpillar']:
        # getFeatures(company)
    for company in ['3m', 'caterpillar']:
        match(company)
    end = time.time()
    print 'running time: %fs' % (end - start)
