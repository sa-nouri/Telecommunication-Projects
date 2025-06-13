%% SDR Receiver ----
 clc ; close all ; clear ;
  
% ***********


 if isempty(ver('wlan'))
    error('Please install WLAN System Toolbox to run this example.');
 end
 
Config.RadioInfo = getRadioInfoWLANBeacon();
disp(Config.RadioInfo);

Config.SimInfo = getUserInputWLANBeacon();

% Get channel number
 reply = '2';
if strcmp(reply,'1')
    bandToScan = 5;
    validChannels = [...
        '  7-16    (5.035-5.080 GHz)\n' ...
        '  34-64   (5.170-5.320 GHz)\n' ...
        '  100-144 (5.550-5.720 GHz)\n' ...
        '  149-165 (5.745-5.825 GHz)\n' ...
    ];
    defaultChannels = '[153 157]';
else
    bandToScan = 2.4;
    validChannels = [...
        '  1-13    (2.412-2.472 GHz)\n'...
        '  14      (2.484 GHz)\n'...
    ];
    defaultChannels = '[7]';
end

% Get channels to scan
 reply=defaultChannels;
channelsToScan = reshape(str2num(reply),[],1); %#ok<ST2NM>

for channel= 1:length(channelsToScan)
    % Calculate center frequency for channel
    WiFiCenterFrequency = helperWLANChannelFrequency(channelsToScan(channel),bandToScan);

    % Run receiver
    fprintf('Running receiver at channel %d (%1.3f GHz)\n',...
        channelsToScan(channel),WiFiCenterFrequency/1e9);
       Data=runWLANNonHTReceiver(WiFiCenterFrequency,Config);
end
% Run complete
fprintf('Desired channel(s) scanned\n');

