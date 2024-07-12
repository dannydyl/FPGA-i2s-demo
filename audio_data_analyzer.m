% Audio Data Analyzer for Integer Data
clear;
clc;
close all;

% File selection
[file, path] = uigetfile('*.csv', 'Select the audio data file');
if isequal(file, 0)
    disp('File selection canceled');
    return;
end
fullPath = fullfile(path, file);

% Read the data
data = readmatrix(fullPath);

% Display some information about the data
disp(['Number of samples: ', num2str(length(data))]);
disp(['Minimum value: ', num2str(min(data))]);
disp(['Maximum value: ', num2str(max(data))]);

% Normalize the data to the range [-1, 1]
audioFloat = double(data) / max(abs(data));

% Calculate time array (assuming 44.1 kHz sample rate, adjust if different)
Fs = 44100;  % Sample rate in Hz
t = (0:length(audioFloat)-1) / Fs;

% Plot time domain signal
figure;
plot(t, audioFloat);
title('Audio Signal in Time Domain');
xlabel('Time (seconds)');
ylabel('Normalized Amplitude');
ylim([-1 1]);

% Plot spectrogram
figure;
spectrogram(audioFloat, 1024, 512, 1024, Fs, 'yaxis');
title('Spectrogram of Audio Signal');

% Plot frequency spectrum
figure;
n = length(audioFloat);
f = (0:n-1)*(Fs/n);
Y = fft(audioFloat);
P2 = abs(Y/n);
P1 = P2(1:n/2+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f(1:n/2+1), P1);
title('Single-Sided Amplitude Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Calculate and display some statistics
disp(['Mean value: ', num2str(mean(data))]);
disp(['Standard deviation: ', num2str(std(double(data)))]);

% Optional: Histogram of the data
figure;
histogram(data, 100);
title('Histogram of Audio Data');
xlabel('Value');
ylabel('Frequency');
% Create the plot
% Apply a moving average filter to smooth the data
smoothed_data = movmean(data, 100);  % Adjust the window size based on your data

% Create a large, detailed plot
figure('Position', [100, 100, 2000, 600]);  % Adjust figure size
plot(t, smoothed_data, 'b');  % Plot smoothed data
title('Smoothed Audio Signal in Time Domain');
xlabel('Time (seconds)');
ylabel('Amplitude');
xlim([0 t(end)]);  % Adjust x-axis to show entire range
grid on;  % Enable grid

% Interactively explore data
zoom xon;  % Enable horizontal zoom
pan xon;   % Enable panning