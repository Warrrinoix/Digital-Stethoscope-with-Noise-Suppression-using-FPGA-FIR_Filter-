
clc
close 
clear all

rawData = readcell('iladata.csv');

hex_filtered   = string(rawData(3:end, 4));
hex_unfiltered = string(rawData(3:end, 5));
unsigned_filtered   = uint16(hex2dec(hex_filtered));
unsigned_unfiltered = uint16(hex2dec(hex_unfiltered));

audio_filtered   = double(typecast(unsigned_filtered, 'int16'));
audio_unfiltered = double(typecast(unsigned_unfiltered, 'int16'));

figure('Name', 'Time Domain Comparison');


plot(audio_filtered, 'r');
title('Filtered Audio (FIR Output: filtered\_pcm)');
xlabel('Samples');
ylabel('Amplitude');
grid on;

% 5. Calculate Frequency Response (FFT)
Fs = 37500; % Decimation sample rate
L = length(audio_filtered);
f = Fs*(0:floor(L/2))/L;


% FFT for Filtered
Y_fil = fft(audio_filtered);
P2_fil = abs(Y_fil/10000/L);
P1_fil = P2_fil(1:floor(L/2)+1);
P1_fil(2:end-1) = 2*P1_fil(2:end-1);


plot(f, P1_fil, 'r', 'LineWidth', 1.5, 'DisplayName', 'Filtered (FIR)');
hold off;

title('Single-Sided Amplitude Spectrum Comparison');
xlabel('Frequency (Hz)');
ylabel('Magnitude |P1(f)|');
legend('show');
grid on;
xlim([0,1000]);
