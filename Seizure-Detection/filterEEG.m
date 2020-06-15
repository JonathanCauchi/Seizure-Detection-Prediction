function y = filterEEG(x)
persistent Hd;

if isempty(Hd)
    
    % The following code was used to design the filter coefficients:
    %
    % N     = 2;    % Order
    % F3dB1 = 0.5;  % First
    % F3dB2 = 40;   % Second
    % Fs    = 256;  % Sampling Frequency
    %
    % h = fdesign.bandpass('n,f3db1,f3db2', N, F3dB1, F3dB2, Fs);
    %
    % Hd = design(h, 'butter', ...
    %     'SystemObject', true);
    
    Hd = dsp.BiquadFilter( ...
        'Structure', 'Direct form II', ...
        'SOSMatrix', [1 0 -1 1 -1.30149453646959 0.310059809032142], ...
        'ScaleValues', [0.344970095483929; 1]);
end

s = double(x);
for i = 1:23
    y(:,i) = step(Hd,s(:,i));
end

