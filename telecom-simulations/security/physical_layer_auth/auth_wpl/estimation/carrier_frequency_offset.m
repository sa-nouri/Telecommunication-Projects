% Carrier Frequency Offset Estimation
% This script estimates the carrier frequency offset (CFO) in a received signal.

function [cfoCorrection , coarseFreqOffset ] = CarrierFrequencyOffset()


%% Waveform Transmission

%VHT link parameters

cfgVHTTx = wlanVHTConfig( ...
    'ChannelBandwidth',    'CBW20', ...
    'NumTransmitAntennas', 3, ...
    'NumSpaceTimeStreams', 2, ...
    'SpatialMapping',      'Hadamard', ...
    'STBC',                true, ...
    'MCS',                 5, ...
    'GuardInterval',       'Long', ...
    'APEPLength',          1050);


% Propagation channel
numRx = 3;                  % Number of receive antennas
delayProfile = 'Model-C';   % TGac channel delay profil

% Impairments
noisePower = -30;  % Noise power to apply in dBW
cfo = 62e3;        % Carrier frequency offset (Hz)

% Generated waveform parameters
numTxPkt = 1;      % Number of transmitted packets
idleTime = 20e-6;  % Idle time before and after each packet


% Generate waveform
rx = vhtSigRecGenerateWaveform(cfgVHTTx, numRx, ...
    delayProfile, noisePower, cfo, numTxPkt, idleTime);

%%  Packet Recovery 


cfgVHTRx = wlanVHTConfig('ChannelBandwidth', cfgVHTTx.ChannelBandwidth);
idxLSTF = wlanFieldIndices(cfgVHTRx, 'L-STF');
idxLLTF = wlanFieldIndices(cfgVHTRx, 'L-LTF');
idxLSIG = wlanFieldIndices(cfgVHTRx, 'L-SIG');
idxSIGA = wlanFieldIndices(cfgVHTRx, 'VHT-SIG-A');


% configure objects and variables for processing

chanBW = cfgVHTTx.ChannelBandwidth;
sr = wlanSampleRate(cfgVHTTx);

% Setup plots for example
[spectrumAnalyzer, timeScope, constellationDiagram] = vhtSigRecSetupPlots(sr);

% Minimum packet length is 10 OFDM symbols
lstfLen = double(idxLSTF(2)); % Number of samples in L-STF
minPktLen = lstfLen*5;

rxWaveLen = size(rx, 1);


%% Front-End Processing


searchOffset = 0; % Offset from start of waveform in samples
while (searchOffset + minPktLen) <= rxWaveLen
    % Packet detection
    pktOffset = wlanPacketDetect(rx, chanBW, searchOffset);

    % Adjust packet offset
    pktOffset = searchOffset + pktOffset;
    if isempty(pktOffset) || (pktOffset + idxLSIG(2) > rxWaveLen)
        error('** No packet detected **');
    end

    % Coarse frequency offset estimation using L-STF
    LSTF = rx(pktOffset + (idxLSTF(1):idxLSTF(2)), :);
    coarseFreqOffset = wlanCoarseCFOEstimate(LSTF, chanBW);

    % Coarse frequency offset compensation
    rx = helperFrequencyOffset(rx,sr,-coarseFreqOffset);

    % Symbol timing synchronization
    LLTFSearchBuffer = rx(pktOffset+(idxLSTF(1):idxLSIG(2)),:);
    pktOffset = pktOffset+wlanSymbolTimingEstimate(LLTFSearchBuffer,chanBW);
    if (pktOffset + minPktLen) > rxWaveLen
        fprintf('** Not enough samples to recover packet **\n\n');
        break;
    end

    % Timing synchronization complete: packet detected
    fprintf('Packet detected at index %d\n\n', pktOffset + 1);

    % Fine frequency offset estimation using L-LTF
    LLTF = rx(pktOffset + (idxLLTF(1):idxLLTF(2)), :);
    fineFreqOffset = wlanFineCFOEstimate(LLTF, chanBW);

    % Fine frequency offset compensation
    rx = helperFrequencyOffset(rx, sr, -fineFreqOffset);

    % Display estimated carrier frequency offset
    cfoCorrection = coarseFreqOffset + fineFreqOffset; % Total CFO
    fprintf('Estimated CFO: %5.1f Hz\n\n', cfoCorrection);

    break; % Front-end processing complete, stop searching for a packet
end

end
