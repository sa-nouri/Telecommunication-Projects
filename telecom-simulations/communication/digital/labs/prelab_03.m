%% PreLab ___ #3

clear ; close all ; clc 

%% Part 3-1 : Frequency Domain Analysis 

    Fs = 250e6 ;
    Ts = 1/Fs ;
    F0 = ( 250*51/256 ) * 1e6 ;
    A = 2 ;
    
    n_psd = 512 ; 
    t = [ 0 : n_psd - 1] * Ts ;
    freq = [ 0 : n_psd - 1] /n_psd * Fs - Fs/2 ;
    
    x = A * exp( 1i * 2 * pi * F0 / Fs * t ) ;
    
    X_fft = fftshift(fft(x,n_psd)) ;
    %%
    X = corr_spctrm(x, n_psd ) ;
    
    figure
    subplot(2,1,1);
    plot(freq ,10 * log10( abs(X_fft) + 30 ) .^ 2 , 'b' ) ;
    legend('X_fft');
    hold on ;
    subplot(2,1,2);
    plot(freq , 10 * log10(abs(X)) , 'r' ) ;
    legend(' X')
    grid on ;
    title(' Energy spectral desities of input' ) ;
    xlabel( ' Frequency ( Hz ) ' ) ;
    ylabel( ' Spectral ') ;
    
%% Calculating Random Spectral Signal with using Correlation

function [X] = corr_spctrm(x , n_psd) 
    % n_psd : Number of Spectral
    % x : Input Signal
    
    Fs = 250e6 ;
    Ts = 1/Fs ;
    Rx = xcorr(x) ;
    
    t = [0:n_psd - 1] * Ts ;
    freq = [0 : n_psd - 1] /n_psd * Fs - Fs/2 ;
    
    temp = repmat(Rx.' , 1 , n_psd) .* freq  ;
    temp = sum(temp,1);
    X = -1 * temp ;
end
