% We build the baselinle / benchmark linear model here. This is the same
% as the one proposed by Mao et al.

% We have 72 features for each stock. Imagine them as a tree:

% - Weighting Factor (x1, x number of friends, x log2(number of friends), x1, x number of followers, x log2(number of followers)
% - - Contains url (no url in text, url in text)
% - - - Tweet type (mentions stock symbol, mentions company name)
% - - - - Sentiment (negative, neutral, positive)

% We create an 72x1 array which describes each feature index
WeightDescriptions = {'1 x ', 'Friends x ', 'log2(Friends + 1) x ', '1 x ', 'Followers x ', 'log2(Followers + 1) x '};
ContainsUrl = {'No URL', 'URL'};
TweetType = {'Stock Symbol', 'Company Name'};
Sentiment = {'Negative', 'Neutral', 'Positive'};

FeatureNameDescription = cell(72,1);
c = 1;
for i=1:6 % Weight factor
    for j=1:2 % Contains url
        for k=1:2 % Tweet type
            for l=1:3 % sentiment
                FeatureNameDescription{c} = strcat(WeightDescriptions{i}, ' Tweets, ', ContainsUrl{j}, ', ', TweetType{k}, ', ', Sentiment{l});                
                c = c+1;
            end;
        end;
    end;
end;

% The tree has just been folded out to one long vector from the top. 
% Starting with (Weight x1, no url, mentions stock symbol, negative), 
% (Weight x1, no url, mentions stock symbol, neutral), (Weight x1, no url, mentions stock symbol, positive) etc.

% Set training and test data size ssets
TotalDataSize = 50;
TrainingDataSize = 35;
TestDataSize = 15;

stockname = 'GE'; % Change this to 'IBM', 'Intel' or 'GE'

TwitterFeatures = load(strcat('TwitterFeatures/TwitterFeatures', stockname, '.mat'));
TwitterFeatures = eval(strcat('TwitterFeatures.TwitterFeatures', stockname));

% Features: Y --> pos1: volume traded, pos2: closing price, pos3: daily change price
StockFeatures = load(strcat('InterpolatedStockFeatures/', stockname, 'Features.mat'));
StockFeatures = StockFeatures.StockFeatures;

% Normalize all features to have zero mean and standard deviation one
TotalTweetsCount = zscore(TotalTweetsCount);
StockFeatures = zscore(StockFeatures);

% As a benchmark model we will have a constant model. That is, we predict
% the previous indicator with the current indicator. As this requires only
% a single previous data point, we will use this as our prediction.

fprintf('Constant Model \n');
fprintf('Trading Volume (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,1) - StockFeatures(2:end,1))), std(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1))));
fprintf('Squared Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,1) - StockFeatures(2:end,1)).^2), std(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1)).^2));
fprintf('Accuracy (Pos vs. Neg)   %8.3f  n/a \n \n', length(find(StockFeatures(1:end-1,1).*StockFeatures(2:end,1) >= 0))/(TotalDataSize-1));


fprintf('Closing Price (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,2) - StockFeatures(2:end,2))), std(abs(PredictedTables(:,2) - StockFeatures(TrainingDataSize+1:end,2))));
fprintf('Squared Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,2) - StockFeatures(2:end,2)).^2), std(abs(PredictedTables(:,2) - StockFeatures(TrainingDataSize+1:end,2)).^2));
fprintf('Accuracy (Pos vs. Neg)   %8.3f  n/a \n\n', length(find(StockFeatures(1:end-1,2).*StockFeatures(2:end,2) >= 0))/(TotalDataSize-1));

fprintf('Price Change (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,3) - StockFeatures(2:end,3))), std(abs(PredictedTables(:,3) - StockFeatures(TrainingDataSize+1:end,3))));
fprintf('Squared Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,3) - StockFeatures(2:end,3)).^2), std(abs(PredictedTables(:,3) - StockFeatures(TrainingDataSize+1:end,3)).^2));
fprintf('Accuracy (Pos vs. Neg)   %8.3f  n/a \n\n', length(find(StockFeatures(1:end-1,3).*StockFeatures(2:end,3) >= 0))/(TotalDataSize-1));

fprintf('Abs Price Change (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,4) - StockFeatures(2:end,4))), std(abs(PredictedTables(:,4) - StockFeatures(TrainingDataSize+1:end,4))));
fprintf('Squared Error   %8.3f  %8.3f \n', mean(abs(StockFeatures(1:end-1,4) - StockFeatures(2:end,4)).^2), std(abs(PredictedTables(:,4) - StockFeatures(TrainingDataSize+1:end,4)).^2));
fprintf('Accuracy (Pos vs. Neg)   %8.3f  n/a \n\n', length(find(StockFeatures(1:end-1,4).*StockFeatures(2:end,4) >= 0))/(TotalDataSize-1));

