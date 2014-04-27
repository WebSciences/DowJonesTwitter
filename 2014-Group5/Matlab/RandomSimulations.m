
t = randn(10000,1);
p = randn(10000,1);


fprintf('Random Model \n');
fprintf('Metric   Mean   Std \n');
fprintf('Abs Error   %8.3f  %8.3f \n', mean(abs(t - p)), std(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1))));
fprintf('Squared Error   %8.3f  %8.3f \n', mean((t - p).^2), std(abs(PredictedTables(:,1) - StockFeatures(TrainingDataSize+1:end,1)).^2));
fprintf('Accuracy (Pos vs. Neg)   %8.3f  n/a \n \n', length(find(t.*p >= 0))/10000);

