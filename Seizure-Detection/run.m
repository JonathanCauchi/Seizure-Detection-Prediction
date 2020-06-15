clc; clear all; close all;
%% read and extract features
% read record names from text file
fileID = fopen('records.txt');
temp = textscan(fileID, '%s');
records = temp{1};
% create table containing features and class
dataTable = table();
for i = 1:length(records)
    fprintf('Record %d is being processed out of %d records\n',i,length(records));
    dataTable = [dataTable; read_data(records{i})];    
end
save("dataTable.mat", "dataTable");
%% data division
rng default
c = cvpartition(dataTable.class,'HoldOut',0.2);
% training data
dataTrain = dataTable(c.training,:);
% test data
dataTest = dataTable(c.test,:);
%% train classifiers
% knn
clfKnn = fitcknn(dataTrain.feature, dataTrain.class,'NumNeighbors',3,...
    'Standardize',false);
% svm
clfSvm = fitcsvm(dataTrain.feature, dataTrain.class,'Standardize',false,...
    'KernelFunction','RBF','KernelScale',10000, 'BoxConstraint',100000);
% ensemble
clfEns = fitcensemble(dataTrain.feature, dataTrain.class,...
    'Method', 'AdaBoostM1', 'LearnRate', 0.7, 'Learners', templateTree('MaxNumSplits', 20));
%% make predictions
% knn
[classPredKnn, scoreKnn] = predict(clfKnn, dataTest.feature);
% svm
[classPredSvm, scoreSvm] = predict(clfSvm, dataTest.feature);
% ensemble
[classPredEns, scoreEns] = predict(clfEns, dataTest.feature);
%% calculate metrics
% knn
c = confusionmat(dataTest.class,classPredKnn)
tn = c(1,1);
fp = c(1,2);
fn = c(2,1);
tp = c(2,2);

fprintf('Accuracy for kNN    : %0.2f\n',(tp+tn)/(tp+fp+tn+fn)*100);
fprintf('Sensitivity  for kNN: %0.2f\n',tp/(tp + fn)*100);
fprintf('specificity  for kNN: %0.2f\n\n',tn/(tn + fp)*100);
figure
% confusionchart(dataTest.class,classPredKnn);
title('Confusion Matrix for kNN')

% Svm
c = confusionmat(dataTest.class,classPredSvm)
tn = c(1,1);
fp = c(1,2);
fn = c(2,1);
tp = c(2,2);

fprintf('Accuracy for Svm    : %0.2f\n',(tp+tn)/(tp+fp+tn+fn)*100);
fprintf('Sensitivity  for Svm: %0.2f\n',tp/(tp + fn)*100);
fprintf('specificity  for Svm: %0.2f\n\n',tn/(tn + fp)*100);
figure
% confusionchart(dataTest.class,classPredSvm);
title('Confusion Matrix for SVM')

% Ens
c = confusionmat(dataTest.class,classPredEns)
tn = c(1,1);
fp = c(1,2);
fn = c(2,1);
tp = c(2,2);

fprintf('Accuracy for Ens    : %0.2f\n',(tp+tn)/(tp+fp+tn+fn)*100);
fprintf('Sensitivity  for Ens: %0.2f\n',tp/(tp + fn)*100);
fprintf('specificity  for Ens: %0.2f\n\n',tn/(tn + fp)*100);
figure
% confusionchart(dataTest.class,classPredEns);
title('Confusion Matrix for Ensemble Classifier')

%% plot ROC
figure
[x1,y1] = perfcurve(dataTest.class,scoreKnn(:,2), categorical("Seizure"));
[x2,y2] = perfcurve(dataTest.class,scoreSvm(:,2),categorical("Seizure"));
[x3,y3] = perfcurve(dataTest.class,scoreEns(:,2),categorical("Seizure"));

plot(x1, y1);
hold on
plot(x2, y2);
plot(x3, y3);
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title('ROC Curve')
legend("kNN", "SVM", "Ensemble")




