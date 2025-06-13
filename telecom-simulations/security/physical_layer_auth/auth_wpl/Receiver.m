function s = Receiver(WiFiChannelCenterFreq,Config,Data)

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
l=0;
s=0;
for frame = 1:FramesToCollect
    l=80*frame;
    % Get data from radio
    data =Data(l-79:l);
    % WLANFrontEnd will internally buffer input symbols in-order to build
    % full packets.  The flag valid will be true when a complete packet is
    % captured.
    %[valid, cfgNonHT, rxNonHTData, chanEst, noiseVar] = WLANFrontEnd(data);    
    [valid, cfgNonHT, rxNonHTData, chanEst, noiseVar,~,z] = WLANFrontEnd(data);
    if Config.SimInfo.EnableScopes
        step(InputSpectrum,complex(data));
    end
   if(z~=0)
       s=cat(1,s,z);
   end
    % Decode when we have captured a full packet
    if valid        
        % Decode payload to bits
        [bits,eqSym] = wlanNonHTDataRecover(...
            rxNonHTData,...
            chanEst,...
            noiseVar,...
            cfgNonHT,...
            cfgRec);
        
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

end










