function [setPredLabelsAll] = LinearRR(setTrainX, setTestX, setTrainLabelsAll, inGamma)

% We use this piece of code for finding the baseline:
%if (1==1)
%    setPredLabelsAll = repmat(mean(setTrainLabelsAll), size(setTestX,1),1);
%    return;
%end;

% We add a constant factor to the training and test sets to account for slope.
setTrainX = [setTrainX, ones(size(setTrainX,1),1)];
setTestX = [setTestX, ones(size(setTestX,1),1)];

setPredLabelsAll = zeros(size(setTestX,1), size(setTrainLabelsAll,2));
gamma = inGamma;

for (i = 1:size(setTestX, 1))
    % We calculate w asterisk, i.e. the w in y = wx
    w_asterisk = (setTrainX'*setTrainX + gamma * size(setTrainX,1) * eye(size(setTrainX, 2))) \ (setTrainX' * setTrainLabelsAll(:,i));
    
    % We obtain the predictions
    setPredLabelsAll(:,i) = setTestX*w_asterisk;
end
