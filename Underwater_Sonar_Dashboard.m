
%% INTERACTIVE UNDERWATER SONAR DASHBOARD
% LFM Sonar + Matched Filtering + CFAR Detection
% No additional toolbox required

clc;
clear;
close all;

sonarDashboard();

%% MAIN DASHBOARD FUNCTION

function sonarDashboard()

    %% SONAR PARAMETERS

    c = 1500;
    fs = 200000;
    fc = 30000;
    B = 8000;
    Tp = 0.002;

    maxRange = 350;

    targetRanges = [120 185 260];
    targetAmplitudes = [1.0 0.72 0.55];

    noiseLevel = 0.12;

    detectedRanges = [];
    scanAngle = 0;
    running = false;

    bg = [0.03 0.07 0.05];
    panelColor = [0.07 0.13 0.10];
    green = [0.2 1 0.4];

    %% CREATE DASHBOARD WINDOW

    fig = uifigure( ...
        'Name','Underwater Sonar Dashboard', ...
        'Position',[100 100 1200 700], ...
        'Color',bg);

    fig.CloseRequestFcn = @closeDashboard;

    %% DASHBOARD TITLE

    uilabel(fig, ...
        'Position',[20 650 1160 35], ...
        'Text','INTERACTIVE UNDERWATER SONAR SYSTEM', ...
        'FontSize',25, ...
        'FontWeight','bold', ...
        'FontColor',green, ...
        'HorizontalAlignment','center');

    uilabel(fig, ...
        'Position',[20 620 1160 25], ...
        'Text','LFM Sonar | Matched Filtering | Adaptive CFAR', ...
        'FontSize',14, ...
        'FontColor',[0.7 0.9 0.8], ...
        'HorizontalAlignment','center');

    %% LEFT CONTROL PANEL

    controlPanel = uipanel(fig, ...
        'Title','SONAR CONTROLS', ...
        'Position',[20 20 250 580], ...
        'BackgroundColor',panelColor, ...
        'ForegroundColor',green, ...
        'FontSize',15, ...
        'FontWeight','bold');

    %% START BUTTON

    startButton = uibutton(controlPanel, ...
        'push', ...
        'Text','START SCANNING', ...
        'Position',[20 485 210 45], ...
        'BackgroundColor',[0.1 0.6 0.25], ...
        'FontColor',[1 1 1], ...
        'FontSize',15, ...
        'FontWeight','bold', ...
        'ButtonPushedFcn',@startScanning);

    %% STOP BUTTON

    stopButton = uibutton(controlPanel, ...
        'push', ...
        'Text','STOP SCANNING', ...
        'Position',[20 425 210 45], ...
        'BackgroundColor',[0.7 0.15 0.15], ...
        'FontColor',[1 1 1], ...
        'FontSize',15, ...
        'FontWeight','bold', ...
        'ButtonPushedFcn',@stopScanning);

    stopButton.Enable = 'off';

    %% RESET BUTTON

    uibutton(controlPanel, ...
        'push', ...
        'Text','RESET SYSTEM', ...
        'Position',[20 365 210 45], ...
        'BackgroundColor',[0.2 0.3 0.5], ...
        'FontColor',[1 1 1], ...
        'FontSize',15, ...
        'ButtonPushedFcn',@resetSystem);

    %% NOISE SLIDER

    noiseLabel = uilabel(controlPanel, ...
        'Position',[20 315 210 30], ...
        'Text','Noise Level: 0.12', ...
        'FontColor',green, ...
        'FontSize',14);

    noiseSlider = uislider(controlPanel, ...
        'Position',[25 295 200 3], ...
        'Limits',[0 1], ...
        'Value',0.12, ...
        'MajorTicks',[0 0.25 0.5 0.75 1], ...
        'FontColor',[1 1 1], ...
        'ValueChangedFcn',@changeNoise);

    %% SYSTEM INFORMATION

    uilabel(controlPanel, ...
        'Position',[20 215 210 35], ...
        'Text','SYSTEM PARAMETERS', ...
        'FontColor',green, ...
        'FontWeight','bold', ...
        'FontSize',14);

    uilabel(controlPanel, ...
        'Position',[20 185 210 25], ...
        'Text','Sound Speed: 1500 m/s', ...
        'FontColor',[1 1 1]);

    uilabel(controlPanel, ...
        'Position',[20 155 210 25], ...
        'Text','Frequency: 30 kHz', ...
        'FontColor',[1 1 1]);

    uilabel(controlPanel, ...
        'Position',[20 125 210 25], ...
        'Text','Bandwidth: 8 kHz', ...
        'FontColor',[1 1 1]);

    uilabel(controlPanel, ...
        'Position',[20 95 210 25], ...
        'Text','Maximum Range: 350 m', ...
        'FontColor',[1 1 1]);

    statusLabel = uilabel(controlPanel, ...
        'Position',[20 25 210 45], ...
        'Text','STATUS: READY', ...
        'FontColor',green, ...
        'FontSize',15, ...
        'FontWeight','bold');

    %% CENTRAL SONAR DISPLAY

    sonarPanel = uipanel(fig, ...
        'Title','LIVE SONAR DISPLAY', ...
        'Position',[285 20 590 580], ...
        'BackgroundColor',[0 0 0], ...
        'ForegroundColor',green, ...
        'FontSize',15, ...
        'FontWeight','bold');

    ax = uiaxes(sonarPanel, ...
        'Position',[15 35 555 510], ...
        'Color',[0 0 0]);

    ax.XColor = green;
    ax.YColor = green;

    axis(ax,'equal');

    xlim(ax,[-380 380]);
    ylim(ax,[-380 380]);

    ax.XTick = [];
    ax.YTick = [];

    hold(ax,'on');

    %% DRAW SONAR RANGE CIRCLES

    theta = linspace(0,2*pi,361);

    for r = 50:50:maxRange

        plot(ax,r*cos(theta), ...
            r*sin(theta), ...
            'Color',[0 0.35 0.12]);

        text(ax,5,r, ...
            sprintf('%d m',r), ...
            'Color',green, ...
            'FontSize',10);

    end

    %% DRAW ANGULAR GRID

    for a = 0:30:330

        angle = a*pi/180;

        plot(ax, ...
            [0 maxRange*sin(angle)], ...
            [0 maxRange*cos(angle)], ...
            'Color',[0 0.3 0.1]);

        text(ax, ...
            365*sin(angle), ...
            365*cos(angle), ...
            sprintf('%d%c',a,char(176)), ...
            'Color',green, ...
            'HorizontalAlignment','center');

    end

    %% SONAR CENTER

    plot(ax,0,0,'go', ...
        'MarkerFaceColor','g', ...
        'MarkerSize',5);

    %% ROTATING SCANNING LINE

    scanLine = plot(ax, ...
        [0 0],[0 maxRange], ...
        'Color',green, ...
        'LineWidth',2);

    %% DETECTED TARGET MARKERS

    targetPlot = plot(ax,nan,nan, ...
        'go', ...
        'MarkerFaceColor','g', ...
        'MarkerSize',9, ...
        'LineStyle','none');

    targetLabels = gobjects(0);

    uilabel(sonarPanel, ...
        'Position',[20 5 550 25], ...
        'Text','Simulated display - illustrative target angles', ...
        'FontColor',[0.6 0.8 0.6], ...
        'HorizontalAlignment','center');

    %% RIGHT RESULTS PANEL

    resultPanel = uipanel(fig, ...
        'Title','DETECTION RESULTS', ...
        'Position',[890 20 290 580], ...
        'BackgroundColor',panelColor, ...
        'ForegroundColor',green, ...
        'FontSize',15, ...
        'FontWeight','bold');

    %% OBJECT COUNTER

    countLabel = uilabel(resultPanel, ...
        'Position',[15 490 260 45], ...
        'Text','Objects Detected: 0', ...
        'FontColor',green, ...
        'FontSize',21, ...
        'FontWeight','bold');

    %% DETECTION RATE

    rateLabel = uilabel(resultPanel, ...
        'Position',[15 445 260 35], ...
        'Text','Detection Rate: --', ...
        'FontColor',[1 1 1], ...
        'FontSize',15);

    %% FALSE DETECTIONS

    falseLabel = uilabel(resultPanel, ...
        'Position',[15 405 260 35], ...
        'Text','False Detections: --', ...
        'FontColor',[1 1 1], ...
        'FontSize',15);

    %% DISTANCE ERROR

    errorLabel = uilabel(resultPanel, ...
        'Position',[15 365 260 35], ...
        'Text','Mean Error: --', ...
        'FontColor',[1 1 1], ...
        'FontSize',15);

    %% TARGET DISTANCE TABLE

    targetTable = uitable(resultPanel, ...
        'Position',[15 155 260 190], ...
        'ColumnName',{'Object','Distance (m)'}, ...
        'ColumnWidth',{90 140}, ...
        'Data',zeros(0,2));

    %% SCAN ANGLE INDICATOR

    angleLabel = uilabel(resultPanel, ...
        'Position',[15 100 260 35], ...
        'Text','Scan Angle: 0 degrees', ...
        'FontColor',green, ...
        'FontSize',15);

    %% RANGE RESOLUTION

    uilabel(resultPanel, ...
        'Position',[15 50 260 35], ...
        'Text',sprintf('Nominal Resolution: %.3f m', ...
        c/(2*B)), ...
        'FontColor',[1 1 1], ...
        'FontSize',13);

    %% CREATE ANIMATION TIMER

    scanTimer = timer( ...
        'ExecutionMode','fixedSpacing', ...
        'Period',0.05, ...
        'TimerFcn',@animateScan);

    %% START SCANNING FUNCTION

    function startScanning(~,~)

        if running
            return;
        end

        statusLabel.Text = 'STATUS: PROCESSING';

        drawnow;

        runDetection();

        running = true;

        startButton.Enable = 'off';
        stopButton.Enable = 'on';

        statusLabel.Text = 'STATUS: SCANNING';
        statusLabel.FontColor = green;

        start(scanTimer);

    end

    %% STOP SCANNING FUNCTION

    function stopScanning(~,~)

        running = false;

        if strcmp(scanTimer.Running,'on')
            stop(scanTimer);
        end

        startButton.Enable = 'on';
        stopButton.Enable = 'off';

        statusLabel.Text = 'STATUS: STOPPED';
        statusLabel.FontColor = [1 0.4 0.4];

    end

    %% ANIMATION FUNCTION

    function animateScan(~,~)

        if ~isvalid(fig) || ~running
            return;
        end

        scanAngle = mod(scanAngle+3,360);

        angle = scanAngle*pi/180;

        scanLine.XData = ...
            [0 maxRange*sin(angle)];

        scanLine.YData = ...
            [0 maxRange*cos(angle)];

        angleLabel.Text = sprintf( ...
            'Scan Angle: %d degrees',scanAngle);

        drawnow limitrate nocallbacks;

    end

    %% NOISE CONTROL FUNCTION

    function changeNoise(~,event)

        noiseLevel = event.Value;

        noiseLabel.Text = sprintf( ...
            'Noise Level: %.2f',noiseLevel);

        runDetection();

    end

    %% RESET FUNCTION

    function resetSystem(~,~)

        stopScanning([],[]);

        noiseLevel = 0.12;
        noiseSlider.Value = 0.12;

        noiseLabel.Text = 'Noise Level: 0.12';

        scanAngle = 0;

        scanLine.XData = [0 0];
        scanLine.YData = [0 maxRange];

        targetPlot.XData = nan;
        targetPlot.YData = nan;

        delete(targetLabels);
        targetLabels = gobjects(0);

        detectedRanges = [];

        targetTable.Data = zeros(0,2);

        countLabel.Text = 'Objects Detected: 0';

        rateLabel.Text = 'Detection Rate: --';

        falseLabel.Text = 'False Detections: --';

        errorLabel.Text = 'Mean Error: --';

        angleLabel.Text = 'Scan Angle: 0 degrees';

        statusLabel.Text = 'STATUS: READY';
        statusLabel.FontColor = green;

    end

    %% SONAR SIGNAL PROCESSING FUNCTION

    function runDetection()

        rng(1);

        % Generate LFM signal

        t = 0:1/fs:Tp-1/fs;

        f0 = fc-B/2;
        k = B/Tp;

        tx = cos(2*pi*(f0*t+0.5*k*t.^2));

        Ns = length(tx);

        n = 0:Ns-1;

        window = 0.5-0.5*cos(2*pi*n/(Ns-1));

        tx = tx.*window;

        % Simulate underwater echoes

        signalLength = ...
            ceil(2*maxRange*fs/c)+Ns;

        rxClean = zeros(1,signalLength);

        delaySamples = round( ...
            2*targetRanges*fs/c);

        for i = 1:length(targetRanges)

            startIndex = delaySamples(i)+1;

            endIndex = startIndex+Ns-1;

            rxClean(startIndex:endIndex) = ...
                rxClean(startIndex:endIndex)+ ...
                targetAmplitudes(i)*tx;

        end

        % Add noise and reverberation

        noise = noiseLevel* ...
            randn(1,signalLength);

        reverb = 0.08*conv( ...
            randn(1,signalLength), ...
            ones(1,100)/100,'same');

        rx = rxClean+noise+reverb;

        % Matched filtering

        matchedOutput = conv(rx,fliplr(tx));

        % FFT-based analytic signal

        L = length(matchedOutput);

        H = zeros(1,L);
        H(1) = 1;

        if mod(L,2)==0

            H(2:L/2) = 2;
            H(L/2+1) = 1;

        else

            H(2:(L+1)/2) = 2;

        end

        analyticSignal = ifft( ...
            fft(matchedOutput).*H);

        rangeProfile = abs(analyticSignal).^2;

        rangeAxis = c*((0:L-1)-(Ns-1))/(2*fs);

        valid = rangeAxis>=0 & ...
                rangeAxis<=maxRange;

        rangeAxis = rangeAxis(valid);
        rangeProfile = rangeProfile(valid);

        %% CFAR DETECTION

        numTraining = 200;
        numGuard = 100;

        Pfa = 1e-5;

        Ntraining = 2*numTraining;

        alpha = Ntraining* ...
            (Pfa^(-1/Ntraining)-1);

        powerSum = [0 cumsum(rangeProfile)];

        idx = numTraining+numGuard+1 : ...
            length(rangeProfile)- ...
            numTraining-numGuard;

        leftStart = idx-numGuard-numTraining;
        leftEnd = idx-numGuard-1;

        rightStart = idx+numGuard+1;
        rightEnd = idx+numGuard+numTraining;

        leftPower = powerSum(leftEnd+1) ...
            -powerSum(leftStart);

        rightPower = powerSum(rightEnd+1) ...
            -powerSum(rightStart);

        noiseEstimate = ...
            (leftPower+rightPower)/Ntraining;

        threshold = alpha*noiseEstimate;

        detection = false(size(rangeProfile));

        detection(idx) = ...
            rangeProfile(idx)>threshold;

        %% PEAK DETECTION

        candidates = find( ...
            detection(2:end-1) & ...
            rangeProfile(2:end-1)>= ...
            rangeProfile(1:end-2) & ...
            rangeProfile(2:end-1)> ...
            rangeProfile(3:end))+1;

        [~,order] = sort( ...
            rangeProfile(candidates),'descend');

        candidates = candidates(order);

        minDistance = 3.0;

        minSeparation = round( ...
            2*minDistance*fs/c);

        peaks = [];

        for i = 1:length(candidates)

            currentPeak = candidates(i);

            if isempty(peaks) || ...
               all(abs(currentPeak-peaks) ...
               >=minSeparation)

                peaks(end+1) = currentPeak;

            end

        end

        peaks = sort(peaks);

        detectedRanges = rangeAxis(peaks);

        %% UPDATE SONAR DISPLAY

        numDetected = length(detectedRanges);

        % Illustrative angles, not measured bearings

        angles = linspace(40,280,numDetected);

        theta = angles*pi/180;

        x = detectedRanges.*sin(theta);
        y = detectedRanges.*cos(theta);

        targetPlot.XData = x;
        targetPlot.YData = y;

        delete(targetLabels);

        targetLabels = gobjects(numDetected,1);

        for i = 1:numDetected

            targetLabels(i) = text(ax, ...
                x(i)+8,y(i)+8, ...
                sprintf('%.2f m', ...
                detectedRanges(i)), ...
                'Color',green, ...
                'FontSize',12, ...
                'FontWeight','bold');

        end

        %% UPDATE DISTANCE TABLE

        targetTable.Data = ...
            [(1:numDetected)' ...
             round(detectedRanges(:),2)];

        countLabel.Text = sprintf( ...
            'Objects Detected: %d',numDetected);

        %% PERFORMANCE EVALUATION

        used = false(size(detectedRanges));

        errors = [];

        for i = 1:length(targetRanges)

            available = find(~used);

            if isempty(available)
                break;
            end

            [err,index] = min(abs( ...
                detectedRanges(available) ...
                -targetRanges(i)));

            if err<=1

                used(available(index)) = true;

                errors(end+1) = err;

            end

        end

        correct = length(errors);

        detectionRate = ...
            100*correct/length(targetRanges);

        falseDetections = sum(~used);

        rateLabel.Text = sprintf( ...
            'Detection Rate: %.1f %%', ...
            detectionRate);

        falseLabel.Text = sprintf( ...
            'False Detections: %d', ...
            falseDetections);

        if isempty(errors)

            errorLabel.Text = 'Mean Error: N/A';

        else

            errorLabel.Text = sprintf( ...
                'Mean Error: %.4f m', ...
                mean(errors));

        end

        drawnow limitrate nocallbacks;

    end

    %% CLOSE DASHBOARD SAFELY

    function closeDashboard(~,~)

        running = false;

        if isvalid(scanTimer)

            stop(scanTimer);
            delete(scanTimer);

        end

        delete(fig);

    end

end
