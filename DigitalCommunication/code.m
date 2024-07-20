%% Computer Assignment ---- Analog Modulation

close all; clear; clc;

%% Implementing Hilber Transform with MATLAB Hilbert Function

fs = 1e4;
t = 0:1/fs:1; 
x = 2.5 + cos(2*pi*203*t) + sin(2*pi*721*t) + cos(2*pi*1001*t);
y = hilbert(x);

figure
plot(t,real(y),t,imag(y))
xlim([0.01 0.03])
grid on
legend('real','imaginary')
title('Hilbert Function')

figure
pwelch([x;y].',256,0,[],fs,'centered')
legend('Original','hilbert')

%% Implementing Hilbert Function (From Scratch)
	
t = 0:0.001:0.5-0.001;
x = sin(2*pi*10*t); %real-valued f = 10 Hz
figure
subplot(2,1,1); plot(t,x);  %plot the original signal
title('x[n] - original signal'); xlabel('n'); ylabel('x[n]');
 
z = analytic_signal(x); %construct analytic signal
subplot(2,1,2); plot(t, real(z), 'k'); hold on; grid on;
plot(t, imag(z), 'r');
title('Components of Analytic signal');
xlabel('n'); ylabel('z_r[n] and z_i[n]');
legend('Real(z[n])','Imag(z[n])');

% Loading message file

[x_message, fs] = audioread('message.wav');
z = analytic_signal(x_message); %construct analytic signal
Ta = 1/fs;
t = linspace(Ta, 6*Ta, numel(x_message)).'; % Total time for simulation
figure
subplot(2,1,1); plot(t,x_message);  %plot the original signal
title('x[n] - message signal'); xlabel('n'); ylabel('x[n]');
subplot(2,1,2); plot(t, real(z), 'k'); hold on; grid on;
plot(t, imag(z), 'r');
title('Components of Analytic signal');
xlabel('n'); ylabel('z_r[n] and z_i[n]');
legend('Real(z[n])','Imag(z[n])');

%% Implementing AM Conventional

Ac = 10; mu = 1; fc = fs; % [Hz]
% x_message = sin(2*pi*10*t);  fs = 1e4;
y = am_conven(x_message, Ac, mu, fc, fs);

Ta = 1/fs;
t = linspace(Ta, 6*Ta, numel(x_message)).'; % Total time for simulation

figure
plot(t, y)
grid on
xlabel('time')
ylabel('output')
title('Conventional AM output in the time domain')

xFft = linspace(0, fs/2, numel(y));
yFft = fft(y);
yFft = fftshift(yFft);
yFft = abs(yFft);

figure
plot(xFft, yFft)
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Fourier Transform of Audiofile')

% Applying Lowpass Filter
y_fil = 2 * y .* cos( 2 * pi* t * fc);
y_out = lowpass(y_fil, fc, fs);

% Error
MSE = norm(y - y_out, 2);

% Modulation Index Effect
mu_par = -4:0.5:4;

for i = 1: length(mu_par)
    y = am_conven(x_message, Ac, mu_par(i), fc, fs);
    y_out = lowpass(y, fc, fs);
    MSE_er(i) = norm( y - y_out, 2);
end

figure
plot(mu_par, MSE_er)
grid on
xlabel('Modulation Index')
ylabel('Mean Square Error')

%% Implementation of DSB 

Ac = 10; fc = 2000; % [Hz]
% x_message = sin(2*pi*10*t);  fs = 1e4;
y = dsb(x_message, Ac, fc, fs);

figure
plot(t, y)
grid on
xlabel('time')
ylabel('output')
title('DSB output in the time domain')

xFft = linspace(100, fs/2, numel(y));
yFft = fft(y);
yFft = fftshift(yFft);
yFft = abs(yFft);

figure
plot(xFft, yFft)
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Fourier Transform of Audiofile')

% Applying Lowpass Filter
y_fil = 2 * Ac * 2 * y .* cos( 2 * pi* t * fc);
y_out = lowpass(y_fil, fc, fs);

% Error
MSE = abs(y - y_out);
l1 = norm( y- y_out);

figure
plot(MSE)
grid on
title('Mean Squre Error DSB');

%% Implementation Upper Single Side-Band

Ac = 10; fc = 2000; % [Hz]
% x_message = sin(2*pi*10*t);  fs = 1e4;
y = up_ssb(x_message, Ac, fc, fs);

figure
plot(t, y)
grid on
xlabel('time')
ylabel('output')
title('DSB output in the time domain')

xFft = linspace(100, fs/2, numel(y));
yFft = fft(y);
yFft = fftshift(yFft);
yFft = abs(yFft);

figure
plot(xFft, yFft)
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Fourier Transform of Audiofile')

% Applying Lowpass Filter
y_fil = 2 * Ac * 2* y .* cos( 2 * pi* t * fc);
y_out = lowpass(y_fil, fc, fs);

% Error
MSE = abs(y - y_out);
l1 = norm( y- y_out);

figure
plot(MSE)
grid on
title('Mean Squre Error Upper SSB');
%% Implementation Lower Single Side-Band

Ac = 10; fc = 2000; % [Hz]
% x_message = sin(2*pi*10*t);  fs = 1e4;
y = low_ssb(x_message, Ac, fc, fs);

figure
plot(t, y)
grid on
xlabel('time')
ylabel('output')
title('DSB output in the time domain')

xFft = linspace(100, fs/2, numel(y));
yFft = fft(y);
yFft = fftshift(yFft);
yFft = abs(yFft);

figure
plot(xFft, yFft)
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Fourier Transform of Audiofile')

% Applying Lowpass Filter
y_fil = 2 * Ac * y .* cos( 2 * pi* t * fc);
y_out = lowpass(y_fil, fc, fs);

% Error
MSE = abs(y - y_out);
l1 = norm( y- y_out);

figure
plot(MSE)
grid on
title('Mean Squre Error Lower SSB');

%% Alising

fc = -fs/2 : fs/2;

for i = 1: length(fc)
    y = low_ssb(x_message, Ac, fc, fs);
    y_fil = 2 * Ac * y .* cos( 2 * pi* t * fc);
    y_out = lowpass(y_fil, fc, fs);
    MSE(i) = norm(y - y_out, 2);
end

figure 
plot(MSE)
grid on
title('MSE for Alising');
%% Function for Computing Analytic Signal

function z = analytic_signal(x)
%x is a real-valued record of length N, where N is even %returns the analytic signal z[n]
x = x(:); %serialize
N = length(x);
X = fft(x,N);
z = ifft([X(1); 2*X(2:N/2); X(N/2+1); zeros(N/2-1,1)],N);
end

%% Function for Computing - Conventional AM

function y = am_conven(x_message, Ac, mu, fc, fs)
% Ac: Amplitude of modulating signal,   % fs: Sampling Frequency
% fc: Carrier Frequency,    % mu: Modulation Index
% x_message: Message Signal % y: Conventioanl AM Output

Ta = 1/fs;
t = linspace(Ta, 6*Ta, numel(x_message)); % Total time for simulation
y = Ac * (1 + (mu * x_message)).' .* cos(2*pi*fc*t); % Equation of Amplitude modulated signa

end

%% DSB Modulation

function y = dsb(x_message, Ac, fc, fs)
% Ac: Amplitude of modulating signal,   % fs: Sampling Frequency
% fc: Carrier Frequency
% x_message: Message Signal % y: Conventioanl AM Output

Ta = 1/fs;
t = linspace(Ta, 6*Ta, numel(x_message)).'; % Total time for simulation
y = Ac * x_message .* cos(2*pi*fc*t); % Equation of Amplitude modulated signa

end

%% Upper Side-Band

function y = up_ssb(x_message, Ac, fc, fs)
% Ac: Amplitude of modulating signal,   % fs: Sampling Frequency
% fc: Carrier Frequency
% x_message: Message Signal % y: Conventioanl AM Output

Ta = 1/fs;
t = linspace(Ta, 6*Ta, numel(x_message)).'; % Total time for simulation
y = 0.5 * Ac * ( (x_message .* cos(2*pi*fc*t))  - (hilbert(x_message) .* sin(2 * pi * fc * t)) ); % Equation of Amplitude modulated signa

end

%% Lower Side-Band

function y = low_ssb(x_message, Ac, fc, fs)
% Ac: Amplitude of modulating signal,   % fs: Sampling Frequency
% fc: Carrier Frequency
% x_message: Message Signal % y: Conventioanl AM Output

Ta = 1/fs;
t = linspace(Ta, 6*Ta, numel(x_message)).'; % Total time for simulation
y = 0.5 * Ac * ( (x_message .* cos(2*pi*fc*t))  + (hilbert(x_message) .* sin(2 * pi * fc * t)) ); % Equation of Amplitude modulated signa

end

%


