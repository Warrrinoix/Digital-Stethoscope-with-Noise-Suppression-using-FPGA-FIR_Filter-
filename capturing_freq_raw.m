
clc
clear
close all

% 1. System Parameters
filename = 'iladata_raw.csv'; 
fs = 100e6;                    
audio_band_limit = 24000;      

% 2. Load the Data
fprintf('Loading data from %s...\n', filename);
data = readmatrix(filename);

pdm_raw = data(:, end); 

pdm_signal = double(pdm_raw) * 2 - 1;

% 4. Calculate the Frequency Spectrum using FFT
N = length(pdm_signal);
Y = fft(pdm_signal);

% Calculate the two-sided spectrum P2, then compute the single-sided spectrum P1
P2 = abs(Y / N);
P1 = P2(1:floor(N/2)+1);
P1(2:end-1) = 2 * P1(2:end-1);

% Create the frequency axis
f = fs * (0:(N/2)) / N;
figure('Name', 'PDM Frequency Response (Linear)', 'Position', [100, 100, 1000, 400]);

plot(f / 1e6, P1, 'r'); 
title('Full PDM Spectrum (Noise Shaping)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (Linear)');
grid on;
xlim([0 (fs/2)/1e6]);
fprintf('Analysis complete. Number of samples processed: %d\n', N);