function   CfoCapturing(WiFiChannelCenterFreq,Config)

%   Copyright 2015-2016 The MathWorks, Inc.

%#codegen
coder.extrinsic('printPayloadInfoWLANBeacon');

%% Set up system
% Instantiate and configure all objects and structures for packet
% synchronization and decoding

% System info
SampleRate = 20e6; % Hz
SymbolLength = 80; % Samples in 20MHz OFDM Symbol (FFT+CP)
FramesToCollect =...
    floor(SampleRate*Config.SimInfo.CaptureDuration/SymbolLength);

% Set up USRP
Radio = ...
    SetupUSRP(Config,WiFiChannelCenterFreq,SymbolLength,FramesToCollect);

% Set up Front-End Packet Synchronizer
WLANFrontEnd = htfo('ChannelBandwidth', 'CBW20');  

if strcmp(Config.RadioInfo.Platform, 'N200/N210/USRP2')
    needRateConversion = true;
    rateConverter = dsp.FIRRateConverter('InterpolationFactor', 4,...
                                         'DecimationFactor', 5);
    SymbolLength = SymbolLength*25/20; % adjust SymbolLength for GetUSRPFrame
else
    needRateConversion = false;
end

% Set up Scopes
if Config.SimInfo.EnableScopes
    [PostEq,InputSpectrum,ArrayEqTaps] = ...
        SetupScopes(Config.SimInfo.FigurePositions,SampleRate);
end

% Set up decoder parameters
cfgRec = wlanRecoveryConfig('EqualizationMethod', 'ZF');

%% Collect symbols and search for packets
% Collect data from the radio one symbol at a time, constructing the packet
% out of these symbols.  Once a valid packet is captured, try to decode it.

for frame = 1:FramesToCollect
    
    % Get data from radio
    if needRateConversion
        data = step(rateConverter, GetUSRPFrame(Radio,SymbolLength));
    else
        data = GetUSRPFrame(Radio,SymbolLength);
    end
    % WLANFrontEnd will internally buffer input symbols in-order to build
    % full packets.  The flag valid will be true when a complete packet is
    % captured.
    [valid, cfgNonHT, rxNonHTData, chanEst, noiseVar,z] = WLANFrontEnd(data); 
    if Config.SimInfo.EnableScopes
        step(InputSpectrum,complex(data));
    end
    
    % Decode when we have captured a full packet?
    if valid        
        % Decode payload to bits
        [bits,eqSym] = wlanNonHTDataRecover(...
            rxNonHTData,...
            chanEst,...
            noiseVar,...
            cfgNonHT,...
            cfgRec);
        x = data ;
        
        % View post equalized symbols and equalizer taps
        if Config.SimInfo.EnableScopes
            step(ArrayEqTaps,chanEst);
            % Animate
            for symbol = 1:size(eqSym,2)
                step(PostEq,eqSym(:,symbol));
            end
        end
        
        % Decode bits
        [validPacket,mpdu] = mpduDecodeWLANBeacon(bits);
        if validPacket
            % Print payload data
            printPayloadInfoWLANBeacon(mpdu,...
                Config.SimInfo.ShowPacketInfo, length(bits),...
                cfgNonHT.MCS, Config.SimInfo.ValidOUI);
        end
    end
    
    if rem(frame, 20e6/80*0.1) == 0
        % Each frame has 80 samples at 20MHz
        % Show progress after processing 100 ms of received data
        fprintf('### Processed %d milliseconds of received data ...\n', ...
                int32(100*frame/(20e6/80*0.1)));
    end
end
%% Run complete
% Cleanup objects
release(Radio); release(WLANFrontEnd);
if Config.SimInfo.EnableScopes
    release(PostEq); release(InputSpectrum); release(ArrayEqTaps);
end

end

%% Blocking USRP Function
function data = GetUSRPFrame(Radio,SymbolLength)
    % Keep accessing the SDRu System object output until it is valid
    len = uint32(0);
    data = coder.nullcopy(complex(zeros(SymbolLength,1)));
    while len <= 0
        [data,len] = step(Radio);
    end
end

%% Setup USRP
function Radio = SetupUSRP(Config,WiFiChannelCenterFreq,SymbolLength,FramesToCollect)

switch Config.RadioInfo.Platform
    case {'B200','B210'}
        Radio = comm.SDRuReceiver(...
            'Platform',             Config.RadioInfo.Platform, ...
            'SerialNum',            Config.RadioInfo.Address, ...
            'MasterClockRate',      Config.RadioInfo.MasterClockRate, ...
            'CenterFrequency',      WiFiChannelCenterFreq, ...
            'Gain',                 Config.RadioInfo.USRPGain, ...
            'DecimationFactor',     Config.RadioInfo.USRPDecimationFactor, ...
            'SamplesPerFrame',      SymbolLength, ...
            'EnableBurstMode',      true,...
            'NumFramesInBurst',     FramesToCollect,...
            'TransportDataType',    'int8', ...
            'OutputDataType',       'double');
    case {'X300','X310'}
        Radio = comm.SDRuReceiver(...
            'Platform',             Config.RadioInfo.Platform, ...
            'IPAddress',            Config.RadioInfo.Address, ...
            'MasterClockRate',      Config.RadioInfo.MasterClockRate, ...
            'CenterFrequency',      WiFiChannelCenterFreq, ...
            'Gain',                 Config.RadioInfo.USRPGain, ...
            'DecimationFactor',     Config.RadioInfo.USRPDecimationFactor, ...
            'SamplesPerFrame',      SymbolLength, ...
            'EnableBurstMode',      true,...
            'NumFramesInBurst',     FramesToCollect,...
            'OutputDataType',       'double');
    case {'N200/N210/USRP2'}
        % Radio's sample rate is 25 Msps rather than 20 Msps
        % because clock rate is 100 MHz and decimation factor is 4.
        % SamplesPerFrame needs to be adjusted.
        Radio = comm.SDRuReceiver(...
            'Platform',             Config.RadioInfo.Platform, ...
            'IPAddress',            Config.RadioInfo.Address, ...
            'CenterFrequency',      WiFiChannelCenterFreq, ...
            'Gain',                 Config.RadioInfo.USRPGain, ...
            'DecimationFactor',     Config.RadioInfo.USRPDecimationFactor, ...
            'SamplesPerFrame',      SymbolLength*25/20, ...
            'EnableBurstMode',      true,...
            'NumFramesInBurst',     FramesToCollect,...
            'OutputDataType',       'double');
end

end

%% Setup Scopes
function [PostEq,InputSpectrum,ArrayEqTaps] = SetupScopes(FigurePositions,SamplesRate)

coder.extrinsic('comm.ConstellationDiagram',...
    'dsp.SpectrumAnalyzer',...
    'dsp.ArrayPlot');

PostEq = comm.ConstellationDiagram('Name','Post Equalized Symbols',...
    'ReferenceConstellation',[-1,1],...
    'Position',FigurePositions(1,:));
InputSpectrum = dsp.SpectrumAnalyzer('Title','Input PSD',...
    'SampleRate',SamplesRate,...
    'YLimits', [-90 10],...
    'Position',FigurePositions(2,:));
ArrayEqTaps = dsp.ArrayPlot('Title','Equalizer Taps',...
    'XLabel', 'Filter Tap', ...
    'YLabel', 'Filter Weight',...
    'ShowLegend', true,...
    'Position',FigurePositions(3,:));

end

%%










