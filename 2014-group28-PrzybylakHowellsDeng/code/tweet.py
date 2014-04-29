"""
Parse json formated tweets file.
"""

import re
import os, time, subprocess, shlex
import json

def modifyFormat():
    """
    The original tweets json file is exampletweets_0.txt. It is in ill format.
    Breaking each tweet into a single line and write to newtweets0.txt.
    """
    fileName = 'data/exampletweets_0.txt'
    fp = open(fileName)
    content = fp.readline()
    fp.close()

    pattern = r'}{"created_at":'
    newContent = re.sub(pattern, '}\n{"created_at":', content)

    outFile = 'data/newtweets0.txt'
    fp = open(outFile, 'w')
    fp.write(newContent)
    fp.close()

def parseJson():
    """
    The original tweets json file (newtweets0.txt) is too large to read. So we extract
    useful information and write into a small file (tweetsinfo.txt).
    """
    fileName = 'data/newtweets0.txt'
    fp = open(fileName)
    lines = fp.readlines()
    fp.close()

    outFile = 'data/tweetsinfo.txt'
    fp = open(outFile, 'w')
    print len(lines);
    for i in xrange(0,len(lines)):
        try:
            data = json.loads(lines[i])
            text = data['text'].encode('utf8')
            text = re.sub(r'\n', r' ', text)
            date = data['created_at'].encode('utf8')
            currTime = time.strptime(date, "%a %b %d %H:%M:%S +0000 %Y")
            date = str(currTime.tm_mon) + '-' + str(currTime.tm_mday)
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

    fp = open('data/tweetsinfo.txt')
    infoLines = fp.readlines()
    fp.close()

    outFile = 'data/' + company + '/' + company + 'tweets.txt'
    fp = open(outFile, 'w')
    for i in xrange(0, len(infoLines)):
        if re.search(r"%s" % company, infoLines[i], re.I):
            fp.write(infoLines[i])
    fp.close()

def splityByDate(company):
    """
    Split tweets file of each company into smaller files by date.
    """
    folder = 'data/' + company + '/split/'
    if not os.path.exists(folder):
        os.makedirs(folder)

    prefix = 'data/' + company + '/' + company
    fp = open(prefix + 'tweets.txt')
    lines = fp.readlines()
    fp.close()

    date = '1-13'
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
    1. Modify the format of the original tweets json file, which is in bad format.
    2. Extract 'created_at' and 'text' from tweets json file newtweets0.txt,
    and write into a smaller file tweetsinfo.txt.
    3. Split tweetsinfo.txt into three files: boeingtweets.txt, caterpillartweets.txt 
    and 3mtweets.txt. Each file contains only information of that company.
    4. Split the above three files into smaller files by date.
    """
    modifyFormat()
    parseJson()
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
    data/boeing/boeingfeatures.txt.
    """
    folder = 'data/' + company + '/'
    fp = open(folder + company + 'features.txt', 'w')
    fp.close()

    dates = [[13,14,15,16,20,21,22,23,26,27,28,29,30], \
                [2,3,4,5,6,9,10,11,12,13,17,18,19,20,23,24,25,26,27], [2]]
    fefp = open(folder + company + 'features.txt', 'w+')
    for month in xrange(1,4):
        for day in dates[month-1]:
            tweetFile = str(month) + '-' + str(day) + '.txt'
            fp = open(folder + 'split/' + tweetFile)
            content = fp.read()
            fp.close()
            (neg, neu, pos) = sentiment(content)    
            line = str(month) + "-" + str(day) + " " + str(neg) + " " \
                + str(neu) + " " + str(pos)        
            if month != 3 or day != dates[2][-1]:
                line = line + '\n'
            fefp.write(line)
    fefp.close()

if __name__ == '__main__':
    start = time.time()
    preprocess()
    for company in ['boeing', '3m', 'caterpillar']:
        getFeatures(company)
    end = time.time()
    print 'running time: %fs' % (end - start)
