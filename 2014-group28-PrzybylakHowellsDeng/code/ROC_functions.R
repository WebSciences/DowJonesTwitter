# CODE adapted from : http://web.expasy.org/pROC/screenshots.html
install.packages("pROC")
library(pROC)

#data(aSAH)




#_____________________________


pROC_AUC <- function(test_DV, pred, c_partial){

  plot.roc(test_DV, pred, # data # (response, predictor)
           
           percent=TRUE, # show all values in percent
           
           partial.auc=c_partial, partial.auc.correct=TRUE, # define a partial AUC (pAUC)
           
           print.auc=TRUE, #display pAUC value on the plot with following options:
           
           print.auc.pattern=paste("Corrected pAUC (", c_partial[1],"-",c_partial[2]," %% SP):\n%.1f%%"), print.auc.col="#1c61b6",
           
           auc.polygon=TRUE, auc.polygon.col="#1c61b6", # show pAUC as a polygon
           
           max.auc.polygon=TRUE, max.auc.polygon.col="#1c61b622", # also show the 100% polygon
           
           main="Partial AUC (pAUC)")
  
  plot.roc(test_DV, pred,
           
           percent=TRUE, add=TRUE, type="n", # add to plot, but don't re-add the ROC itself (useless)
           
           partial.auc=c_partial, partial.auc.correct=TRUE, # define a partial AUC (pAUC)
           
           partial.auc.focus="se", # focus pAUC on the sensitivity
           
           print.auc=TRUE, print.auc.pattern=paste("Corrected pAUC (", c_partial[1],"-",c_partial[2]," %% SE):\n%.1f%%"), print.auc.col="#008600", #display pAUC value with options:
           
           print.auc.y=40, # do not print auc over the previous one
           
           auc.polygon=TRUE, auc.polygon.col="#008600", # show pAUC as a polygon
           
           max.auc.polygon=TRUE, max.auc.polygon.col="#00860022") # also show the 100% polygon

}
#pROC_AUC(aSAH$outcome, aSAH$s100b,c(100,80)) # c(response,predictor)

#____________________________

pROC_singlek <- function(test_DV, pred, th, method) {  

  plot.roc(test_DV, pred,
         
         #main="Confidence interval of a threshold", percent=TRUE,
           
         main=method, percent=TRUE,
         
         ci=TRUE, of="thresholds", # compute AUC (of threshold)
         
         thresholds=th, # select the (best) threshold
         
         print.thres=th, # also highlight this threshold on the plot
           
         grid = TRUE,
         
         auc.polygon = TRUE) 
  
}


#pROC_singlek(aSAH$outcome, aSAH$s100b,"best")

#____________________________

# ci.sp i ce.se w przedziale (0:100) zwracaja stochastycznie ten sam wykres. S¹ jednozancznie wyznacozne
# zacieniowany obszar rozjezdza sie troche z CI dla best boROC czase mjest sta³¹! w tym miejscu akurat jest. Czy tylko dlatego?


pROC_CI <- function(test_DV, pred) {

  rocobj <- plot.roc(test_DV, pred,
                   
                   main="Confidence intervals", percent=TRUE,
                   
                   ci=TRUE, # compute AUC (of AUC by default)
                   
                   print.auc=TRUE)

  ciobj <- ci.se(rocobj, # CI of sensitivity
               
               specificities=seq(0, 100, 5)) # over a select set of specificities

  plot(ciobj, type="shape", col="#1c61b6AA") # plot as a blue shape


  plot(ci(rocobj, of="thresholds", thresholds="best")) # add one threshold

}

#pROC_CI(aSAH$outcome, aSAH$s100b)
