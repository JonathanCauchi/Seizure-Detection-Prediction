function f = wave(signal)
% 5 level wavelet decomposition
[c,l] = wavedec(signal,5,'db4');
% approximation coef
ap5 = appcoef(c,l,'db4');
% detail coef
[cd3,cd4,cd5] = detcoef(c,l,[3 4 5]);

% mean of coef
f1 = mean(ap5);
f2 = mean(cd3);
f3 = mean(cd4);
f4 = mean(cd5);
% max of coef
f5 = max(ap5);
f6 = max(cd3);
f7 = max(cd4);
f8 = max(cd5);
% std of coef
f9 = std(ap5);
f10 = std(cd3);
f11 = std(cd4);
f12 = std(cd5);
% energy
f13 = rms(ap5);
f14 = rms(cd3);
f15 = rms(cd4);
f16 = rms(cd5);
% all features
f = [f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16];