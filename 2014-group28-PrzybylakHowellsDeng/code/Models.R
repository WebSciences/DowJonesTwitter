#____________________ Decision Trees


controls <- rpart.control(minsplit = 1, minbucket = 5, cp = 0.001) #tree parameters
parms <- list(split = 'gini') #splitting methodology


CreateClassificationTree <- function(ch_discrDependentVariable, df_learnAttributes, df_learnDependentVariable, controls, parms)
{
  df_data <- cbind(df_learnDependentVariable, df_learnAttributes)
  df_data <- data.frame(df_data)
  
  colnames(df_data) <- make.names(c(ch_discrDependentVariable,colnames(df_learnAttributes)), unique = TRUE, allow_ = TRUE)
  
  ch_explanatoryVariable <- paste(colnames(df_data[,-1]), "+", collapse = "", sep="")
  formula <- paste(ch_discrDependentVariable," ~ ", ch_explanatoryVariable, sep="")
  formula <- substr(formula, 1, nchar(formula) - 1)
  tree <- rpart(eval(parse(t = formula)), data = df_data, 
                parms = parms, control = controls, method = "class")
  
  return(tree)
}


CPoptimal <- function(tree)  #Pruning the tree to optimal size by complexity parameter (not used)
{
  
  minpos <- min(seq_along(tree$cptable[,4])[tree$cptable[,4] == min(tree$cptable[,4])])
  minline <- tree$cptable[minpos,4] + tree$cptable[minpos,5]
  xerror_min <- tree$cptable[,4] - minline
  optimalCP_index <- min(seq_along(xerror_min)[xerror_min < 0])
  optimalCP <- tree$cptable[optimalCP_index,1]
  
  prunedTree <- prune(tree, optimalCP)
  
  return(prunedTree)
}


#____________________ RFs


CreateRF <- function(ch_discrDependentVariable, df_learnAttributes, df_learnDependentVariable, ntrees,
                     mtrys, nodesizes)
{
  df_data <- cbind(df_learnDependentVariable, df_learnAttributes)
  df_data <- data.frame(df_data)
  
  colnames(df_data) <- make.names(c(ch_discrDependentVariable,colnames(df_learnAttributes)), unique = TRUE, allow_ = TRUE)
  
  ch_explanatoryVariable <- paste(colnames(df_data[,-1]), "+", collapse = "", sep="")
  formula <- paste(ch_discrDependentVariable," ~ ", ch_explanatoryVariable, sep="")
  formula <- substr(formula, 1, nchar(formula) - 1)
  rf <- randomForest(eval(parse(t = formula)), na.action = na.omit,importance=TRUE, data = df_data, ntree = ntrees,
                     mtry = mtrys, nodesize = nodesizes)
  
  return(rf)
}


#____________________ LogisticRegresion


CreateLogistic <- function(ch_discrDependentVariable, df_learnAttributes, df_learnDependentVariable)
{
  
  
  df_data <- cbind(df_learnDependentVariable, df_learnAttributes)
  df_data <- data.frame(df_data)
  
  colnames(df_data) <- make.names(c(ch_discrDependentVariable,colnames(df_learnAttributes)), unique = TRUE, allow_ = TRUE)
  
  ch_explanatoryVariable <- paste(colnames(df_data[,-1]), "+", collapse = "", sep="")
  formula <- paste(ch_discrDependentVariable," ~ ", ch_explanatoryVariable, sep="")
  formula <- substr(formula, 1, nchar(formula) - 1)
  logistic <- glm(eval(parse(t = formula)), data = df_data, family=binomial(logit))
  
  return(logistic)
}


#logistic <- CreateLogistic(colnames(labels), training_features, training_labels) #training labels haveto be {0,1} for logistic regression!
#tree <- CreateClassificationTree(colnames(MMM_label)[2], MMM_daily_features[1:20,c(2,3,4)], MMM_label[1:20,2], controls, parms)
#plot(tree); text(tree,use.n=T,cex=.5)




#table(prediction = class_predict , correct = MMM_label[21:32,2]) # Hitratio Matrix