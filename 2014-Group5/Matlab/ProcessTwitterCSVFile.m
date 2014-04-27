% We load in file CSV file. It has columns Company Index, Month, Day,
% Features.

A = importdata('complete.csv',',');

Features = A(:,4:end);
CompanyDateIndex = [A(:,3), A(:,2), A(:,1)];

StillNeedToSum = true;

% We sum up all entries for same company and dates
while (StillNeedToSum==true)
    StillNeedToSum = false;
    for i=1:size(CompanyDateIndex,1);
        IndicesSameCompanySameDate = find(CompanyDateIndex(:,1) == CompanyDateIndex(i,1) & CompanyDateIndex(:,2) == CompanyDateIndex(i,2) & CompanyDateIndex(:,3) == CompanyDateIndex(i,3));
        IndicesSameCompanySameDate = sort(IndicesSameCompanySameDate);

        if (length(IndicesSameCompanySameDate) > 1)
            % Sum up
            Features(IndicesSameCompanySameDate(1),:) = sum(Features(IndicesSameCompanySameDate,:));

            % Remove all other entries
            Features(IndicesSameCompanySameDate(2:end),:) = [];
            CompanyDateIndex(IndicesSameCompanySameDate(2:end),:) = [];
            
            StillNeedToSum = true;
            
            break;
        end;
    end;

end;

% We change our dates into indices. We count January 13th as the first day.
CompanyDay = zeros(size(CompanyDateIndex,1), 2);
for i=1:size(CompanyDateIndex,1);
    CompanyDay(i,1) = CompanyDateIndex(i,1);
    
    numdays = datenum(strcat(num2str(CompanyDateIndex(i,2)), '/', num2str(CompanyDateIndex(i,3)), '/2014')) - datenum('01/12/2014');
    CompanyDay(i,2) = numdays;    
end;

% Add zeros to days with missing entries
for i=1:50;
    for j=1:3;
        if length(find(CompanyDay(:,1) == j & CompanyDay(:,2) == i)) == 0
            CompanyDay = [CompanyDay; [j,i]];
            Features = [Features; zeros(1,size(Features,2))];
        end;
    end;
end;


% Finally we sort them in chronological order
[~, SortedIndices] = sort(CompanyDay(:,2));
CompanyDay(:,1:2) = CompanyDay(SortedIndices,1:2);
Features(:,1:end) = Features(SortedIndices,1:end);

TwitterFeaturesIBM = Features(find(CompanyDay(:,1) == 1),:);
TwitterFeaturesIntel = Features(find(CompanyDay(:,1) == 2),:);
TwitterFeaturesGE = Features(find(CompanyDay(:,1) == 3),:);

save('TwitterFeaturesIBM.mat', 'TwitterFeaturesIBM');
save('TwitterFeaturesIntel.mat', 'TwitterFeaturesIntel');
save('TwitterFeaturesGE.mat', 'TwitterFeaturesGE');


%CompanyOneIndices = find(CompanyDay(:,1) == 1);
%CompanyTwoIndices = find(CompanyDay(:,1) == 2);
%CompanyThreeIndices = find(CompanyDay(:,1) == 3);
%plot(CompanyDay(CompanyOneIndices,2), Features(CompanyOneIndices, 1), CompanyDay(CompanyOneIndices,2), Features(CompanyOneIndices, 2), CompanyDay(CompanyOneIndices,2), Features(CompanyOneIndices, 3));
%legend('Negative', 'Neutral', 'Positive');

% To count the total number of tweets we need to sum features 1-3 and 7-9
%TotalTweetsCount = zeros(49,3);
%TotalTweetsCount(:,1) = sum(Features(CompanyOneIndices, [1,2,3,7,8,9])');
%TotalTweetsCount(:,2) = sum(Features(CompanyTwoIndices, [1,2,3,7,8,9])');
%TotalTweetsCount(:,3) = sum(Features(CompanyThreeIndices, [1,2,3,7,8,9])');

%plot(1:size(TotalTweetsCount,1), TotalTweetsCount(:,1), 1:size(TotalTweetsCount,1), TotalTweetsCount(:,2), 1:size(TotalTweetsCount,1), TotalTweetsCount(:,3));
%legend('IBM', 'Intel', 'General Electric');
%xlabel('Day');
%ylabel('Total Tweets');

%

% Let's load the stock data. 
% Stock features: (volume traded, closing price, daily change price, abs
% daily change price)
%[IBM, Intel, GE] = load_3_stocks;

%TotalTweetsCount = [TotalTweetsCount(1:11,:); zeros(1,3); TotalTweetsCount(12:end,:)];

%scatter(zscore(TotalTweetsCount(:,2)), zscore(Intel(:,1)));
%scatter(zscore(TotalTweetsCount(1:49,2)), zscore(Intel(2:end,1)));
%xlabel('Intel Tweets Count');
%ylabel('Intel Change in closing price');

%hold on;
%bar(1:50,zscore(TotalTweetsCount(:,2)));
%plot(1:50, zscore(Intel(:,1)), 'r');
%legend('Intel Tweets Count', 'Intel Volume');
%xlabel('Day');


%hold off;

% Calculate correlation coefficients
%corrcoef(zscore(TotalTweetsCount(:,1)), zscore(Intel(:,1)))

