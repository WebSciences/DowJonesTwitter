The src document applies the source codes for the coursework such as analysis the raw twitter data and the sentiment analysis platforms, Stanford and Lingpipe.


- BasicLassoModel.m
Code for the linear regression model based on tweet counts only and stock features with LASSO regularization.

- BasicLinearModel.m
Code for the linear regression model based on tweet counts only and stock features with no regularization.

- commands.txt
Misc commands used to edit raw Twitter data.

- complete.csv
72 extracted Twitter features.

- ConstantModel.m
Code for the Constant Model.

- ExtrapolateStockData.m
Uses an AR(2) model to extrapolate the stock data over weekends and holidays. This gives us a total of 50 training days.

- FeatureAnalysis.m
Performs the feature analysis described in the report.

- LinearLasso.m
Performs a linear regression with LASSO regularization on arbitrary input data.

- LinearLasso.m
Performs a linear regression with LASSO regularization on arbitrary input data.

- LinearRR.m
Performs a linear ridge regression on arbitrary input data. We set the alpha parameter strictly positive but close to zero to achieve unique solution.

- Load_3_stocks.m
Initial code not used anymore.

- PolynomialFeatureMap.m
Polynomial feature function which transforms (X,Y) input into (X,Y, X_1 Y_1, X_2 Y_2 etc.) inputs.

- PolynomialFeaturesLassoModel.m
Code for the linear regression model based on PPCA features and stock features with LASSO regularization.

- PolynomialFeaturesLinearModel.m
Code for the linear regression model based on PPCA features and stock features with no regularization.

- ProcessTwitterCSVFile.m
Converts Twitter features into Matlab matrices for further processing.

- RandomSimulations.m
Simulates the N(0,1) Random Model and gives its MAE, MSE and Accuracy

- SelectedFeaturesPlot.m
Plots the four selected features as discussed in the report.

- SentimentLassoModel.m
Code for the linear regression model based on four selected Twitter features and stock features with LASSO regularization.

- SentimentLinearModel.m
Code for the linear regression model based on four selected Twitter features and stock features with no regularization.

