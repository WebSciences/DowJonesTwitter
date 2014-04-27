function [setPredLabelsAll] = LinearLasso(setTrainX, setTestX, setTrainLabelsAll)

%addpath('glmnet_matlab');

% We add a constant factor to the training and test sets to account for slope.
setTrainX = [setTrainX, ones(size(setTrainX,1),1)];
setTestX = [setTestX, ones(size(setTestX,1),1)];

setPredLabelsAll = zeros(size(setTestX,1), size(setTrainLabelsAll,2));

%[B, FitInfo] = lasso(setTrainX, setTrainLabelsAll,'CV',2, 'NumLambda', 10, 'UseParallel', true);
%[~, i] = find(FitInfo.Lambda == FitInfo.LambdaMinMSE);

%options = glmnetSet();
%options.nlambda = 10;
%options.standardize = true;
%options.lambda=0:0.1:1;
%options.alpha = 1;

%'nlambda', '10', 'standardize', 'false', 'lambda', 0:0.1:1);

%cvfit = cvglmnet(setTrainX, setTrainLabelsAll, 'gaussian', options, 'mse', 5);
cvfit = cvglmnet(setTrainX, setTrainLabelsAll, 'gaussian', ['alpha', 1, 'nlambda', 10]);
%w = cvglmnetPredict(cvfit,[],cvfit.lambda_min,'coef');
%cvfit.lambda_min
%w = B(:,i);
for (i = 1:size(setTestX, 1))
    %setPredLabelsAll(:,i) = glmnetPredict(cvfit,setTestX,[0.01,0.005]')
    setPredLabelsAll(:,i) = cvglmnetPredict(cvfit,setTestX,'lambda_min');
    
    %setPredLabelsAll(:,i)
    %setPredLabelsAll(:,i) = setTestX*w;
    
    
    % We calculate w asterisk, i.e. the w in y = wx
   % w_asterisk = (setTrainX'*setTrainX + gamma * size(setTrainX,1) * eye(size(setTrainX, 2))) \ (setTrainX' * setTrainLabelsAll(:,i));
    
    % We obtain the predictions
    %setPredLabelsAll(:,i) = setTestX*w_asterisk;
end
