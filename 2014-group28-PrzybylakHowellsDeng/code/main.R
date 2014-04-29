# think about MLinterfaces, Ipred, carret

library(rpart)
library(randomForest)
library(party)
library(lattice)
library(snowfall) # paralel multicore computations: http://journal.r-project.org/archive/2009-1/RJournal_2009-1_Knaus+et+al.pdf
library(TTR)

setwd("C:\\Users\\user\\Desktop\\Information_Retrieval_and_Data_Mining\\IRDM")

source("Rcode\\ROC_functions.R")
source("Rcode\\Models.R")


#______________ Data Preparation

#____DAILY DATA


features <- read.table(c("Data//3mfeatures.txt"), header=FALSE, sep = "", quote = "'") #this is alreadydelay by 1 comparing to the label
features <- read.table(c("Data//caterpillarfeatures.txt"), header=FALSE, sep = "", quote = "'") #this is alreadydelay by 1 comparing to the label
features <- read.table(c("Data//boeingfeatures.txt"), header=FALSE, sep = "", quote = "'") #this is alreadydelay by 1 comparing to the label

labels <- read.table(c("Data//3mtrend.txt"), header=FALSE, sep = "", quote = "'")[-1,2] #drop first observationto make it divisable for the CV procedure
labels <- read.table(c("Data//caterpillartrend.txt"), header=FALSE, sep = "", quote = "'")[-1,2]
labels <- read.table(c("Data//boeingtrend.txt"), header=FALSE, sep = "", quote = "'")[-1,2]

labels <- as.data.frame(labels)
features <- features[-1,-1] #dropthe first observation to make the set divisable by 8 and drop thedate column

features1 <- features
features1[,1] <- features[,1]/rowSums(features[,c(1:3)]) #positive ratio
features1[,2] <- features[,3]/rowSums(features[,c(1:3)]) #negative ratio
features1[,3] <- features[,2]/rowSums(features[,c(1:3)]) #neutral ratio
features1[,4] <- features[,1]/rowSums(features[,c(1,3)]) #positive to negative ratio
features1[,5] <-SMA(features1[,1],3) # 3 period moveing average of positiveratio
features1[,6] <-SMA(features1[,1],7) # 7 period moveing average of positiveratio
features1[,7] <-SMA(features1[,3],3) # 3 period moveing average of negative ratio
features1[,8] <-SMA(features1[,3],7) # 7 period moveing average of negative ratio
features1[,9] <- SMA(sign(c(0,diff(features1[,4]))),3) #guards against 1 very highjump, checks if the ratio of pos/neg is growing or declining recently

features <- features1
colnames(features) <- c("positive_ratio","negative_ratio","neutral_ratio","pos_neg","sma_pos3","sma_pos7","sma_neg3","sma_neg7","trend")

#____HOURLY DATA

features <- read.table(c("Data//3mhourfeaturesmatched.txt"), header=FALSE, sep = "", quote = "'") #this is alreadydelay by 1 comparing to the label
features <- read.table(c("Data//caterpillarhourfeaturesmatched.txt"), header=FALSE, sep = "", quote = "'") #this is alreadydelay by 1 comparing to the label
features <- read.table(c("Data//boeinghourfeaturesmatched.txt"), header=FALSE, sep = "", quote = "'") #this is alreadydelay by 1 comparing to the label

features <- features[,2:4]

labels <- read.table(c("Data//3mhourtrendmatched.txt"), header=FALSE, sep = "", quote = "'")[1:160,2] #drop first observationto make it divisable for the CV procedure
labels <- read.table(c("Data//caterpillarhourtrendmatched.txt"), header=FALSE, sep = "", quote = "'")[1:160,2]
labels <- read.table(c("Data//boeinghourtrendmatched.txt"), header=FALSE, sep = "", quote = "'")[,2]

labels[labels== 0] <- 1 #treat no return as positive return
labels <- as.data.frame(labels)


####________ MODELS


RandomizedCV <- function(labels, features, method)
{
  c_remaining <- c(1:nrow(labels))
  predicted_prob <- numeric()
  predicted_class <- numeric()
  reordered_labels <- numeric()
  
  while(length(c_remaining) > 0)
  {
      c_hold_out <- sample(c_remaining, 4)
      c_remaining <- c_remaining[! c_remaining %in% c_hold_out]
      
      training_labels <- labels[-c_hold_out,]
      test_labels <- labels[c_hold_out,]
      training_features <- features[-c_hold_out,]
      test_features <- features[c_hold_out,]
      reordered_labels <- c(reordered_labels, test_labels)
      
      
      if(method=="tree") {model <- CreateClassificationTree(colnames(labels), training_features, training_labels, controls, parms)
      } else if(method =="forest"){model <- CreateRF(colnames(labels), training_features, as.factor(training_labels), ntrees=2000, mtrys=2, nodesize = 1)
      } else if(method =="logistic")
          {
            training_labels[training_labels == -1] <- 0
            model <- CreateLogistic(colnames(labels), training_features, training_labels)
          }
      
      
      if(method != "logistic") {
      class_predict <- as.numeric(as.character(predict(model, test_features, type = 'class')))
      predicted_class <- c(predicted_class, class_predict)}
      
      if(method != "logistic"){prob_predict <- predict(model, test_features, type = 'prob')[,2]} else {prob_predict <- predict(model, test_features, type = 'response')}      
      predicted_prob <- c(predicted_prob, prob_predict) # append predictions from current iteration
      
  }
  
  
  if(method != "logistic") {print(table(prediction = predicted_class , correct = reordered_labels))} # Hitratio Matrix
  #pROC_AUC(reordered_labels, predicted_prob,c(0,0))
  pROC_singlek(reordered_labels, predicted_prob, "best", method)
  
}

#the optimal threshold is the average optimal threshold over all the cross-validations

par(mfrow=c(1,3), pty="s", mar = c(0,0,0,0), oma=c(0.15,0.15,0.15,0.15))
ktree <- RandomizedCV(labels, features, c("tree"))
kf0rest <- RandomizedCV(labels, features, c("forest")) #na.omit action is spurious!
klogistic <- RandomizedCV(labels, features, c("logistic"))
title( "3m hourly Results", outer = TRUE )

#RF1 <- CreateRF(colnames(MMM_label), training_features, as.factor(training_labels), ntrees=1000, mtrys=4, nodesize = 15)
#prob_predict <- predict(RF1, test_features,type = 'prob')

###______VARIABLE IMPORTANCE FOR BEST MODEL

bestrf <- CreateRF(colnames(labels), features, as.factor(labels[,1]), ntrees=2000, mtrys=3, nodesize = 1)
importance(bestrf,type=2,scale=FALSE)

features1 <- features[,c(1,2,3,4,5,6,7)]

labels1 <- labels
labels1[labels1 == -1] <- 0
bestlog <- CreateLogistic(colnames(labels1), features1, labels1)

#sentiment can not be expressed in one variable,therefor we create multiplevariables and let thepredictive models choosewhich
#variables bestdescribethe sentiment thatinfluences the market.

table(prediction = predicted_class , correct = reordered_labels)
anova(bestlog,test="Chisq")