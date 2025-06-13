%% SDR Receiver ----

 clc ; close all ; clear ;
  
%%% *************************** %%%

%% checking for presence of WLAN ******

if isempty(ver('wlan'))
    error('Please install WLAN System Toolbox to run this example.');
end
 
%%  Discover Software Radio

Config.RadioInfo = getRadioInfoWLANBeacon();
disp(Config.RadioInfo);
Config.SimInfo = getUserInputWLANBeacon();
disp(Config.SimInfo);

%% Simulation Parameters 
% USRP is working at 2.4 [GHz] ;

bandToScan = 2.4;

% Channels were scanned ;

Channels = '[1]' ; % All channels were scannded
channelsToScan = reshape(str2num(Channels),[],1); %#ok<ST2NM>
channelStartingFreq = str2double('2.462e9');
%% Capture and Decode OFDM

 channel= 1;
    % Calculate center frequency for channel
    WiFiCenterFrequency = channelStartingFreq ; %+ 5e6*channelsToScan(channel);
%%
    % Run receiver
    fprintf('Running receiver at channel %d (%1.3f GHz)\n',...
        channelsToScan(channel),WiFiCenterFrequency/1e9);
   % CfoCapturing(WiFiCenterFrequency,Config);
 CfoCapturing(WiFiCenterFrequency,Config);
% Run complete
fprintf('Desired channel(s) scanned\n');

% USRP Receiving
% This script implements a receiver for USRP hardware.

function [output] = usrp_receiving(signal, fs)
    % USRP_RECEIVING Processes the received signal from USRP hardware.
    %
    % Args:
    %     signal (array): Received signal.
    %     fs (float): Sampling frequency.
    %
    % Returns:
    %     array: Processed output signal.

    % Apply a simple low-pass filter
    output = lowpass(signal, fs/4, fs);
end




 

