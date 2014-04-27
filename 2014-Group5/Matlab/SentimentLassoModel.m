% We build the linear lasso regression model based on tweet sentiments.
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

modelname = 'Linear Sentiment Model';
stockname = 'GE'; % Change this to 'IBM', 'Intel' or 'GE'

TwitterFeatures = load(strcat('TwitterFeatures/TwitterFeatures', stockname, '.mat'));
TwitterFeatures = eval(strcat('TwitterFeatures.TwitterFeatures', stockname));

TwitterFeatureNames = {'Friends x Tweets,Stock Symbol, All Sentiments' ...
   'Friends x Tweets,Company Name,Negative', ...
   'Friends x Tweets,Company Name,Neutral', ...
   'Friends x Tweets,Company Name,Positive'};

ExtractedTwitterFeatures = [TwitterFeatures(:, 13) + TwitterFeatures(:, 19) +  TwitterFeatures(:, 14) + TwitterFeatures(:, 20) ...
    + TwitterFeatures(:, 15) + TwitterFeatures(:, 21), TwitterFeatures(:, 16) + TwitterFeatures(:, 22), TwitterFeatures(:, 17) + TwitterFeatures(:, 23) ...
    , TwitterFeatures(:, 18) + TwitterFeatures(:, 24)];

% Features: Y --> pos1: volume traded, pos2: closing price, pos3: daily change price
StockFeatures = load(strcat('InterpolatedStockFeatures/', stockname, 'Features.mat'));
StockFeatures = StockFeatures.StockFeatures;

% Normalize all features to have zero mean and standard deviation one
ExtractedTwitterFeatures = zscore(ExtractedTwitterFeatures);
StockFeatures = zscore(StockFeatures);


% Build linear model separately for each dependent variable
PredictedTables = zeros(TestDataSize, 4);
TwitterDaysUsed = zeros(TestDataSize, 4);
for j = 1:4
    % For each test sample, we use leave-one-out cross-validation to pick
    % the optimal m (0-3) and n (0-3) and use the best model to predict the
    % next future value.
    for i = (TotalDataSize-TestDataSize+1):TotalDataSize
        i
        % We use leave-one-out cross-validation on the previous 10 samples to find the optimal m and n
        CrossValidationResults=zeros(3,4);
        
        OptimalSquaredError = 10000000;
        Optimalm = 1;
        Optimaln = 0;
        % We vary the number of previous stock feature inputs
        for m=1:3
            % We vary the number of previous Twitter feature inputs
            for n=0:3
                for l=(i-10):i
                    TrainingInput = [];
                    ValidationInput = [];
                    
                    for k=1:m
                        TrainingInput = [TrainingInput, StockFeatures((4-k):(l-k-1),:)];
                        ValidationInput = [ValidationInput, StockFeatures((l-k),:)];
                    end;
                    
                    for k=1:n
                        TrainingInput = [TrainingInput, ExtractedTwitterFeatures((4-k):(l-k-1),:)];
                        ValidationInput = [ValidationInput, ExtractedTwitterFeatures((l-k),:)];
                    end;
                    
                    TrainingOutput = StockFeatures(4:(l-1),j);
                    ValidationOutput = StockFeatures(l,j);
                    
                    CrossValidationPrediction = LinearLasso(TrainingInput, ValidationInput, TrainingOutput);
                    
                    %CrossValidationResults(l-(i-10)+1,m,n+1) = (ValidationOutput-CrossValidationPrediction).^2;
                    CrossValidationResults(m,n+1) = CrossValidationResults(m,n+1) + (ValidationOutput-CrossValidationPrediction).^2;
                end;
                
                if (OptimalSquaredError > CrossValidationResults(m,n+1))
                    OptimalSquaredError = CrossValidationResults(m,n+1);
                    Optimalm = m;
                    Optimaln = n;
                end;
            end;
        end;
        
        % We use the optimal n and m found from cross-validation to build a
        % new linear regression model based on all the previous data
        % samples, and use it to predict the next sample.
        TrainingInput = [];
        TestInput = [];

        for k=1:Optimalm
            TrainingInput = [TrainingInput, StockFeatures((4-k):(i-k-1),:)];
            TestInput = [TestInput, StockFeatures((l-k),:)];
        end;

        for k=1:Optimaln
            TrainingInput = [TrainingInput, ExtractedTwitterFeatures((4-k):(i-k-1),:)];
            TestInput = [TestInput, ExtractedTwitterFeatures((i-k),:)];
        end;
        
        TrainingOutput = StockFeatures(4:(i-1),j);
        
        PredictedTables(i-(TotalDataSize-TestDataSize),j) = LinearLasso(TrainingInput, TestInput, TrainingOutput);        
        
        TwitterDaysUsed(i-(TotalDataSize-TestDataSize),j) = Optimaln;
    end;
end;

% Plot the results. This is good for the report and will make it easy to
% interpret the model performance.

h=figure;
%suptitle('Predictions for General Electric', 'FontType', 'Times');
subplot(2,2,1);
set(gca, 'FontSize', 13)
plot(1:TestDataSize, PredictedTables(:,1), 1:TestDataSize, StockFeatures(TrainingDataSize+1:end,1), 'LineWidth', 2);
ylabel('Volume (Normalized)');
xlabel('Test Day');
legend(modelname, 'Ground Truth');

subplot(2,2,2);
set(gca, 'FontSize', 13)
plot(1:TestDataSize, PredictedTables(:,2), 1:TestDataSize, StockFeatures(TrainingDataSize+1:end,2), 'LineWidth', 2);
ylabel('Closing Price (Normalized)');
xlabel('Test Day');
legend(modelname, 'Ground Truth');

subplot(2,2,3);
set(gca, 'FontSize', 13)
plot(1:TestDataSize, PredictedTables(:,3), 1:TestDataSize, StockFeatures(TrainingDataSize+1:end,3), 'LineWidth', 2);
ylabel('Price Change (Normalized)');
xlabel('Test Day');
legend(modelname, 'Ground Truth');

subplot(2,2,4);
set(gca, 'FontSize', 13)
plot(1:TestDataSize, PredictedTables(:,4), 1:TestDataSize, StockFeatures(TrainingDataSize+1:end,4), 'LineWidth', 2);
ylabel('Abs Price Change (Normalized)');
xlabel('Test Day');
legend(modelname, 'Ground Truth');

ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title(horzcat('Predictions for ', stockname), 'FontSize', 16, 'FontWeight', 'Bold');

savefig(h, strcat('Predictions_', modelname, '_', stockname, ''));
saveas(h,strcat('Predictions_', modelname, '_', stockname, ''),'png');

% Calculate mean absolute error, squared error and accuracy (positive versus negative)
fprintf('Trading Volume (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1))), std(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1))));
fprintf('Squared Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1)).^2), std(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1)).^2));

p = length(find(PredictedTables(:,4).*StockFeatures(TrainingDataSize+1:end,1) >= 0))/TestDataSize;
fprintf('Accuracy (Pos vs. Neg) %8.3f +/-  %8.3f \n\n', p, sqrt((p*(1-p))/TestDataSize));


fprintf('Closing Price (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,2) - StockFeatures(TrainingDataSize+1:end,2))), std(abs(PredictedTables(:,2) - StockFeatures(TrainingDataSize+1:end,2))));
fprintf('Squared Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,2) - StockFeatures(TrainingDataSize+1:end,2)).^2), std(abs(PredictedTables(:,2) - StockFeatures(TrainingDataSize+1:end,2)).^2));

p = length(find(PredictedTables(:,4).*StockFeatures(TrainingDataSize+1:end,2) >= 0))/TestDataSize;
fprintf('Accuracy (Pos vs. Neg) %8.3f +/-  %8.3f \n\n', p, sqrt((p*(1-p))/TestDataSize));

fprintf('Price Change (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,3) - StockFeatures(TrainingDataSize+1:end,3))), std(abs(PredictedTables(:,3) - StockFeatures(TrainingDataSize+1:end,3))));
fprintf('Squared Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,3) - StockFeatures(TrainingDataSize+1:end,3)).^2), std(abs(PredictedTables(:,3) - StockFeatures(TrainingDataSize+1:end,3)).^2));

p = length(find(PredictedTables(:,4).*StockFeatures(TrainingDataSize+1:end,3) >= 0))/TestDataSize;
fprintf('Accuracy (Pos vs. Neg) %8.3f +/-  %8.3f \n\n', p, sqrt((p*(1-p))/TestDataSize));

fprintf('Abs Price Change (Normalized): \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,4) - StockFeatures(TrainingDataSize+1:end,4))), std(abs(PredictedTables(:,4) - StockFeatures(TrainingDataSize+1:end,4))));
fprintf('Squared Error   %8.3f +/- %8.3f \n', mean(abs(PredictedTables(:,4) - StockFeatures(TrainingDataSize+1:end,4)).^2), std(abs(PredictedTables(:,4) - StockFeatures(TrainingDataSize+1:end,4)).^2));

p = length(find(PredictedTables(:,4).*StockFeatures(TrainingDataSize+1:end,4) >= 0))/TestDataSize;
fprintf('Accuracy (Pos vs. Neg) %8.3f +/-  %8.3f \n\n', p, sqrt((p*(1-p))/TestDataSize));
