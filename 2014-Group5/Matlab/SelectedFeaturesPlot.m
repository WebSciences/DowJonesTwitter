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

modelname = 'Linear Sentiment Model';
stockname = 'GE'; % Change this to 'IBM', 'Intel' or 'GE'

TwitterFeatures = load(strcat('TwitterFeatures/TwitterFeatures', stockname, '.mat'));
TwitterFeatures = eval(strcat('TwitterFeatures.TwitterFeatures', stockname));

%TwitterFeatureNames = {'Friends x Tweets,Stock Symbol, All Sentiments' ...
%   'Friends x Tweets,Company Name,Negative', ...
%   'Friends x Tweets,Company Name,Neutral', ...
%   'Friends x Tweets,Company Name,Positive'};

TwitterFeatureNames = {'Stock Symbol, All' ...
   'Company Name,Negative', ...
   'Company Name,Neutral', ...
   'Company Name,Positive'};


ExtractedTwitterFeatures = [TwitterFeatures(:, 13) + TwitterFeatures(:, 19) +  TwitterFeatures(:, 14) + TwitterFeatures(:, 20) ...
    + TwitterFeatures(:, 15) + TwitterFeatures(:, 21), TwitterFeatures(:, 16) + TwitterFeatures(:, 22), TwitterFeatures(:, 17) + TwitterFeatures(:, 23) ...
    , TwitterFeatures(:, 18) + TwitterFeatures(:, 24)];


% Features: Y --> pos1: volume traded, pos2: closing price, pos3: daily change price
StockFeatures = load(strcat('InterpolatedStockFeatures/', stockname, 'Features.mat'));
StockFeatures = StockFeatures.StockFeatures;

% Normalize all features to have zero mean and standard deviation one
ExtractedTwitterFeatures = zscore(ExtractedTwitterFeatures);
StockFeatures = zscore(StockFeatures);


TrainingDataIndices = 2:(TotalDataSize-TestDataSize);
scatter3(ExtractedTwitterFeatures(TrainingDataIndices-1, 1), StockFeatures(TrainingDataIndices-1, 3), StockFeatures(TrainingDataIndices, 3));

StockFeatureNames = {'Trading Volume', 'Closing Price', 'Price Change', 'Abs Price Change'};
   

h=figure;
c = 1;
for i=1:4
    for j=1:4
        subplot(4,4,c);
        scatter(ExtractedTwitterFeatures(TrainingDataIndices-1, i), StockFeatures(TrainingDataIndices, j));
        ylabel(StockFeatureNames{j});
        xlabel(TwitterFeatureNames{i});
        c = c+1;
    end;
end;

ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title(horzcat('Twitter Features vs. Stock Features: ', stockname), 'FontSize', 16, 'FontWeight', 'Bold');

savefig(h, strcat('SelectedFeatures_', stockname, ''));
saveas(h,strcat('SelectedFeatures_', stockname, ''),'png');

h=figure;
scatter3(ExtractedTwitterFeatures(TrainingDataIndices-1, 1), ExtractedTwitterFeatures(TrainingDataIndices-1, 1), StockFeatures(TrainingDataIndices, 1));
set(gca, 'FontSize', 13)
title(horzcat('Twitter Features vs. Stock Features: ', stockname), 'FontSize', 16, 'FontWeight', 'Bold');
xlabel(horzcat(TwitterFeatureNames{1}, ', time t-1'));
ylabel(horzcat(TwitterFeatureNames{2}, ' , time t-1'));
zlabel(horzcat(StockFeatureNames{1}, ', time t'));


h=figure;
scatter3(ExtractedTwitterFeatures(TrainingDataIndices-1, 1), StockFeatures(TrainingDataIndices-1, 1), StockFeatures(TrainingDataIndices, 1));
set(gca, 'FontSize', 13)
title(horzcat('Twitter Features vs. Stock Features: ', stockname), 'FontSize', 16, 'FontWeight', 'Bold');
xlabel(horzcat(TwitterFeatureNames{1}, ', time t-1'));
ylabel(horzcat(StockFeatureNames{1}, ' , time t-1'));
zlabel(horzcat(StockFeatureNames{1}, ', time t'));

h=figure;StockFeatures
scatter3(ExtractedTwitterFeatures(TrainingDataIndices-1, 1), StockFeatures(TrainingDataIndices-1, 1), StockFeatures(TrainingDataIndices, 3));
set(gca, 'FontSize', 13)
title(horzcat('Twitter Features vs. Stock Features: ', stockname), 'FontSize', 16, 'FontWeight', 'Bold');
xlabel(horzcat(TwitterFeatureNames{1}, ', time t-1'));
ylabel(horzcat(StockFeatureNames{1}, ' , time t-1'));
zlabel(horzcat(StockFeatureNames{3}, ', time t'));

h=figure;
scatter3(ExtractedTwitterFeatures(TrainingDataIndices-1, 3), StockFeatures(TrainingDataIndices-1, 1), StockFeatures(TrainingDataIndices, 3));
set(gca, 'FontSize', 13)
title(horzcat('Twitter Features vs. Stock Features: ', stockname), 'FontSize', 16, 'FontWeight', 'Bold');
xlabel(horzcat(TwitterFeatureNames{3}, ', time t-1'));
ylabel(horzcat(StockFeatureNames{1}, ' , time t-1'));
zlabel(horzcat(StockFeatureNames{3}, ', time t'));2:(TotalDataSize-TestDataSize);



PolynomialFeatures = PolynomialFeatureMap(ExtractedTwitterFeatures(1:TrainingDataSize, :), StockFeatures(1:TrainingDataSize, :));
%[COEFF,SCORE] = princomp(zscore(PolynomialFeatures));
[COEFF,SCORE] = ppca(zscore(PolynomialFeatures), 4);

h=figure;
c = 1;
for i=1:4
    for j=1:4
        subplot(4,4,c);
        scatter(SCORE(TrainingDataIndices-1, i), StockFeatures(TrainingDataIndices, j));
        ylabel(StockFeatureNames{j})
        xlabel(horzcat('Component ', num2str(i)));
        c = c+1;
    end;
end;

ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title(horzcat('Polynomial Features (PPCA) vs. Stock Features: ', stockname), 'FontSize', 16, 'FontWeight', 'Bold');

savefig(h, strcat('PolynomialFeatures_', stockname, ''));
saveas(h,strcat('PolynomialFeatures_', stockname, ''),'png');