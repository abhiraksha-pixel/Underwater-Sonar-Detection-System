
%% UNDERWATER OBJECT DETECTION AND DISTANCE ESTIMATION USING SONAR
% Simulation-based mini project for Digital Signal Processing.
% Detect underwater objects and estimate their distances using sonar.

clear;
close all;
clc;

set(0,'DefaultFigureWindowStyle','docked');
rng(7);                  % Reproducible noise

%% 1. SONAR AND SIMULATION PARAMETERS

c = 1500;                 % Speed of sound in seawater (m/s)
fs = 200e3;               % Sampling frequency (Hz)
fc = 30e3;                % Sonar carrier frequency (Hz)
B = 8e3;                  % LFM bandwidth (Hz)
Tp = 2e-3;                % Pulse duration (s)

targetRanges_m = [120 185 260]; 
targetAmplitudes = [1.00 0.72 0.55];

maxRange_m = 400;
recordDuration = 2*maxRange_m/c + Tp + 0.03;

N = round(recordDuration*fs);
t = (0:N-1)/fs;

%% 2. GENERATE TRANSMITTED LFM SONAR PULSE

Ns = round(Tp*fs);
tp = (0:Ns-1)/fs;

f0 = fc - B/2;
f1 = fc + B/2;

tx = chirp(tp, f0, Tp, f1, 'linear');

tx = tx .* hann(Ns).';
tx = tx / max(abs(tx));

%% 3. SIMULATE RECEIVED SONAR ECHOES

rx = zeros(1,N);

trueDelays_s = 2*targetRanges_m/c;

for k = 1:numel(targetRanges_m)

    delaySamples = round(trueDelays_s(k)*fs);

    echoAmplitude = targetAmplitudes(k) * ...
        (100/targetRanges_m(k))^1.15;

    firstIndex = delaySamples + 1;
    lastIndex = firstIndex + Ns - 1;

    if lastIndex <= N
        rx(firstIndex:lastIndex) = ...
            rx(firstIndex:lastIndex) + echoAmplitude*tx;
    end

end

%% ADD NOISE AND REVERBERATION

noiseSigma = 0.012;

rx = rx + noiseSigma*randn(size(rx));

reverb = filter(1, [1 -0.88], ...
    0.002*randn(size(rx)));

rx = rx + reverb;

%% 4. MATCHED FILTERING

matchedFilter = fliplr(tx);

mf = conv(rx, matchedFilter, 'full');

mfTime = (0:numel(mf)-1)/fs;

mfEnvelope = abs(hilbert(mf));

% Valid search region

validStart = Ns + 1;

validEnd = min(numel(mfEnvelope), ...
    round((2*maxRange_m/c)*fs) + Ns);

searchSignal = mfEnvelope(validStart:validEnd);
searchTime = mfTime(validStart:validEnd);

%% PEAK DETECTION

detectionThreshold = 0.13*max(searchSignal);

minPeakSeparation_s = 0.025;

minPeakDistance = round(minPeakSeparation_s*fs);

[peakValues, peakLocations] = findpeaks(searchSignal, ...
    'MinPeakHeight', detectionThreshold, ...
    'MinPeakDistance', minPeakDistance);

%% 5. DISTANCE ESTIMATION

detectedTimes_s = searchTime(peakLocations) - (Ns-1)/fs;

detectedTimes_s(detectedTimes_s < 0) = [];

detectedRanges_m = (c*detectedTimes_s)/2;

%% 6. PRINT DETECTION RESULTS

fprintf('\nUNDERWATER SONAR OBJECT DETECTION RESULTS\n');

fprintf('Assumed sound speed: %.1f m/s\n', c);
fprintf('Sampling frequency: %.0f Hz\n', fs);
fprintf('Detection threshold: %.4f\n\n', detectionThreshold);

if isempty(detectedRanges_m)

    fprintf('No object detected. Adjust threshold or signal parameters.\n');

else

    fprintf('Detected objects:\n');
    fprintf('Object\tEstimated range (m)\n');

    for k = 1:numel(detectedRanges_m)
        fprintf('%d\t%.2f\n', k, detectedRanges_m(k));
    end

end

%% 7. RANGE ERROR CALCULATION

fprintf('\nKnown target ranges and nearest detected estimates:\n');

fprintf('True range (m)\tEstimated range (m)\tAbsolute error (m)\n');

for k = 1:numel(targetRanges_m)

    if isempty(detectedRanges_m)

        estimate = NaN;
        err = NaN;

    else

        [~, idx] = min(abs(detectedRanges_m-targetRanges_m(k)));

        estimate = detectedRanges_m(idx);

        err = abs(estimate-targetRanges_m(k));

    end

    fprintf('%.2f\t\t%.2f\t\t\t%.2f\n', ...
        targetRanges_m(k), estimate, err);

end

%% 8. PLOTS

% Plot 1: Transmitted sonar pulse

figure('Name','Transmitted sonar pulse');

plot(tp*1e3, tx, 'LineWidth', 1.1);

xlabel('Time (ms)');
ylabel('Amplitude');

title('Transmitted LFM Sonar Pulse');

grid on;

% Plot 2: Received sonar signal

figure('Name','Received sonar signal');

plot(t, rx, 'LineWidth', 0.8);

xlabel('Time (s)');
ylabel('Amplitude');

title('Received Signal with Simulated Echoes and Noise');

grid on;

xlim([0 recordDuration]);

% Plot 3: Matched filter range profile

figure('Name','Matched filter range profile');

rangeAxis_m = (c/2)*(mfTime - (Ns-1)/fs);

plot(rangeAxis_m, mfEnvelope, 'LineWidth', 1.0);

hold on;

yline(detectionThreshold, '--r', 'Detection threshold');

if ~isempty(detectedRanges_m)

    plot(detectedRanges_m, ...
        peakValues(1:min(end,numel(detectedRanges_m))), ...
        'rv', 'MarkerFaceColor','r');

end

xlabel('Estimated range (m)');
ylabel('Matched-filter magnitude');

title('Matched-Filter Output and Detected Objects');

grid on;

xlim([0 maxRange_m]);

% Plot 4: Received signal spectrum

figure('Name','Received signal spectrum');

nfft = 2^nextpow2(numel(rx));

RX = fft(rx,nfft);

f = (0:nfft-1)*(fs/nfft);

plot(f(1:floor(nfft/2))/1e3, ...
    20*log10(abs(RX(1:floor(nfft/2)))+eps), ...
    'LineWidth', 1.0);

xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

title('Magnitude Spectrum of Received Signal');

grid on;

%% 9. SUMMARY

fprintf('\nProcessing completed.\n');

fprintf('Range is calculated using R = c*tau/2.\n');

fprintf(['This is a numerical simulation, ' ...
    'not a measurement from real sonar hardware.\n']);
