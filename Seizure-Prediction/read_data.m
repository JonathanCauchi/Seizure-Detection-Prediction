function sampleTable = read_data(recordName)
% add toolbox to path
addpath([pwd '/physio_pack']);
% record path from physionet.org
recordPath = ['chbmit/' recordName];
% read annotation
ann = rdann(recordPath, 'seizures');
% beginning and end of seizures
annStart = [];
annEnd = [];
for i = 1:2:length(ann)-1
    annStart = [annStart; ann(i)];
    annEnd = [annEnd; ann(i+1)];
end
% calculate total length of preictal segments
% 300 seconds for preictal 
oneSegLen = 120*256;
totalSegLen = oneSegLen*length(annStart);
% common channels
commonChannels = ["FP1-F7" "F7-T7" "T7-P7" "P7-O1" "FP1-F3" "F3-C3"...
    "C3-P3" "P3-O1" "FZ-CZ" "CZ-PZ" "FP2-F4" "F4-C4" "C4-P4" "P4-O2"...
    "FP2-F8" "F8-T8" "T8-P8" "P8-O2" "P7-T7" "T7-FT9" "FT9-FT10" "FT10-T8"];
%% read EEG segments
% read description
info = wfdbdesc(recordPath);
% extract channel names
for i = 1:length(info)
    channels(i) = string(info(i).Description);
end
% common channel index
idx = [];
for i = 1:length(commonChannels)
    idx = [idx find(commonChannels(i) == channels)];
end
% sort index
idx = sort(idx);

% length of signal
signalLen = info(1).LengthSamples*256;

% read preictal segments
preictal = [];
for i = 1:length(annStart)
    preictal = [preictal; rdsamp(recordPath, idx, annStart(i)-1, annStart(i)-oneSegLen)];
end
if annStart(1)-oneSegLen > totalSegLen+256*60*10 % read from beginning
    interictal = rdsamp(recordPath, idx, totalSegLen);
else % read to the end
    interictal = rdsamp(recordPath, idx, [], signalLen-totalSegLen+1);
    fprintf('Read from end\n\n')
end

%% filter signals
preictal = filterEEG(preictal);
interictal = filterEEG(interictal);
% create 2 seconds segment
sampleTable = table();
% segment lenght
segLen = 512;
% number of segments
numSegment = floor(length(interictal)/segLen);
for i = 1:numSegment
    % normal signal
    class = categorical("Interictal");
    signal = interictal(segLen*(i-1)+1:segLen*i,:);
    feature = extractFeature(signal);
    temp = table(feature, class);
    sampleTable = [sampleTable; temp];
    % seizure
    class = categorical("Preictal");
    signal = preictal(segLen*(i-1)+1:segLen*i,:);
    feature = extractFeature(signal);
    temp = table(feature, class);
    sampleTable = [sampleTable; temp];
end
    