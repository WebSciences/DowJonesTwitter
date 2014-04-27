% We load in file CSV file. It has columns Company Index, Month, Day,
% Features.

stockname = 'GE';
stockfilename = 'StockPrices/GE.csv';

A = importdata(stockfilename,',');

StockPrices = A.data(:,1:5);
StockDates = A.textdata(2:end,1);
StockDays = zeros(size(StockDates, 1), 1);

RealStockDays=[];

for i=1:size(StockDates,1);
    DifferenceBetweenDays = datenum(StockDates(i), 'yyyy-mm-dd') - datenum('01/12/2014');
    StockDays(i) = DifferenceBetweenDays;
    
    if (i > 2) && (StockDays(i-1) - StockDays(i) == 1)
        RealStockDays = [RealStockDays, StockDays(i)];
    end;
end;

% Sort by day
[~, OrderedIndices] = sort(StockDays);
StockDays = StockDays(OrderedIndices);
StockPrices = StockPrices(OrderedIndices,:);

% Build AR model based on first 4 points
%ModelOne = ar(StockPrices(1:4,1),2);
%ModelTwo = ar(StockPrices(1:4,2),2);
%ModelThree = ar(StockPrices(1:4,3),2);
%ModelFour = ar(StockPrices(1:4,4),2);
%ModelFive = ar(StockPrices(1:4,5),2);
%coeff = polydata(m);

% Extrapolate whenever data is missing
ExtrapolationCompleted = false;
while (ExtrapolationCompleted==false)
    ExtrapolationCompleted = true;
    for i=3:size(StockDays,1);
        i
        if round(StockDays(i) - StockDays(i-1)) > 1
            ExtrapolationCompleted = false;
            
            % Extrapolate one day forward
            NewRow = zeros(1,5);
            for j=1:5;
            	model = ar(iddata(StockPrices(1:i,j), [], 1),2);
                predictions = predict(model, iddata(StockPrices(1:i,j), [], 1));
                NewRow(j) = predictions.OutputData(end);
            end;
            
            % Substitute in extrapolation
            StockDays = [StockDays(1:(i-1)); StockDays(i-1)+1; StockDays(i:end)];
            StockPrices = [StockPrices(1:(i-1),:); NewRow; StockPrices(i:end,:)];
            
            break;
        end;
    end;
end;

% Features: Y --> pos1: volume traded, pos2: closing price, pos3: daily change price
StockFeatures = zeros(size(StockPrices,1)-1, size(StockPrices,2)-1);
StockFeatures(:,1) = StockPrices(2:end,5);
StockFeatures(:,2) = StockPrices(2:end,4);
StockFeatures(:,3) = diff(StockPrices(:,4));
StockFeatures(:,4) = abs(diff(StockPrices(:,4)));

% Save stock features
save(strcat(stockname, 'Features.mat'),'StockFeatures');

