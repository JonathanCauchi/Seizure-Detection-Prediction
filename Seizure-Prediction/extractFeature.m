function f = extractFeature(signal)
f = [];
for i = 1:length(signal(1,:))
    s = signal(:,i);
    % time features
    t1 = mean(s);
    t2 = std(s);
    t3 = kurtosis(s);
    t4 = skewness(s);
    % time-frequency features
    f1 = wave(s);
    f = [f t1 t2 t3 t4 f1];
end