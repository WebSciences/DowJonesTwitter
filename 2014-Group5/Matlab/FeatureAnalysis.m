% We build the basic linear model here

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

stockname = 'Intel'; % Change this to 'IBM', 'Intel' or 'GE'

TwitterFeatures = load(strcat('TwitterFeatures/TwitterFeatures', stockname, '.mat'));
TwitterFeatures = eval(strcat('TwitterFeatures.TwitterFeatures', stockname));

% Features: Y --> pos1: volume traded, pos2: closing price, pos3: daily change price
StockFeatures = load(strcat('InterpolatedStockFeatures/', stockname, 'Features.mat'));
StockFeatures = StockFeatures.StockFeatures;

% Extract total Tweets count related to the stock
TotalTweetsCount = sum(TwitterFeatures(:, [1,2,3,7,8,9])')';

% Calculate correlation coefficient statistics w.r.t. tweet counts for
% entire data set
TweetCountCorrCoefficient = zeros(size(StockFeatures,2), 2);
for j = 1:size(StockFeatures,2)
    [r,p] = corrcoef(zscore(TotalTweetsCount), zscore(StockFeatures(:,j)));
    TweetCountCorrCoefficient(j,1) = r(1,2);
    TweetCountCorrCoefficient(j,2) = p(1,2);
end;

TweetCountCorrCoefficient

% Calculate correlation coefficient statistics w.r.t. all features for
% training data
AllFeaturesCorrCoefficientValues = zeros(size(TwitterFeatures,2), size(StockFeatures,2));
AllFeaturesCorrCoefficientPValues = zeros(size(TwitterFeatures,2), size(StockFeatures,2));
for i=1:size(TwitterFeatures,2)
    i
    for j = 1:size(StockFeatures,2)
        [r,p] = corrcoef(zscore(TwitterFeatures(1:TrainingDataSize,i)), zscore(StockFeatures(1:TrainingDataSize,j)));
        AllFeaturesCorrCoefficientValues(i,j) = r(1,2);
        AllFeaturesCorrCoefficientPValues(i,j) = p(1,2);
        
    end;
end;

h=figure;
subplot(2,1,1);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientValues(:,1));
ylabel('Correlation Coefficient');
xlabel('Feature Index');
title('Trading Volume', 'FontWeight', 'bold', 'FontSize', 15);

subplot(2,1,2);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientPValues(:,1));
ylabel('Correlation Coefficient P-Value');
xlabel('Feature Index');
savefig(h, strcat('CorrCoeff_TradingVolume_', stockname, ''));
saveas(h,strcat('CorrCoeff_TradingVolume_', stockname, ''),'png');
close(h);

h=figure;
subplot(2,1,1);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientValues(:,2));
ylabel('Correlation Coefficient');
xlabel('Feature Index');
title('Closing Price', 'FontWeight', 'bold', 'FontSize', 15);

subplot(2,1,2);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientPValues(:,2));
ylabel('Correlation Coefficient P-Value');
xlabel('Feature Index');
savefig(h, strcat('CorrCoeff_ClosingPrice_', stockname, ''));
saveas(h,strcat('CorrCoeff_ClosingPrice_', stockname, ''),'png');
close(h);

h=figure;
subplot(2,1,1);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientValues(:,3));
ylabel('Correlation Coefficient');
xlabel('Feature Index');
title('Daily Price Price', 'FontWeight', 'bold', 'FontSize', 15);

subplot(2,1,2);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientPValues(:,3));
ylabel('Correlation Coefficient P-Value');
xlabel('Feature Index');
savefig(h, strcat('CorrCoeff_PriceChange_', stockname, ''));
saveas(h,strcat('CorrCoeff_PriceChange_', stockname, ''),'png');
close(h);


h=figure;
subplot(2,1,1);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientValues(:,4));
ylabel('Correlation Coefficient');
xlabel('Feature Index');
title('Abs Daily Price Price', 'FontWeight', 'bold', 'FontSize', 15);

subplot(2,1,2);
set(gca, 'FontSize', 13)
bar(AllFeaturesCorrCoefficientPValues(:,4));
ylabel('Correlation Coefficient P-Value');
xlabel('Feature Index');
savefig(h, strcat('CorrCoeff_AbsPriceChange_', stockname, ''));
saveas(h,strcat('CorrCoeff_AbsPriceChange_', stockname, ''),'png');
close(h);



% Find significant features. As we observe from the above plots, almost no features correlate well with the
% the closing price, so we will only the subset of features which correlate
% well with closing price.
%SignificantFeaturesIndices = find(AllFeaturesCorrCoefficientPValues(:,1) < 0.05 | AllFeaturesCorrCoefficientPValues(:,3) < 0.05 | AllFeaturesCorrCoefficientPValues(:,4) < 0.05);
SignificantFeaturesIndices = find(AllFeaturesCorrCoefficientPValues(:,1) < 0.20 | AllFeaturesCorrCoefficientPValues(:,3) < 0.20 | AllFeaturesCorrCoefficientPValues(:,4) < 0.20);

[~, SignificantFeatureIndicesSorted] = sort(abs(AllFeaturesCorrCoefficientValues(SignificantFeaturesIndices, 3)))
SignificantFeaturesIndices = SignificantFeaturesIndices(SignificantFeatureIndicesSorted);

fprintf('Significant features at 95% confidence level are: \n');
for i=1:length(SignificantFeaturesIndices);
    fprintf(strcat('   %4.2d >  ', strcat(' ', FeatureNameDescription{i}), '\n'), round(AllFeaturesCorrCoefficientValues(SignificantFeaturesIndices(i), 3)*100)/100);
end;