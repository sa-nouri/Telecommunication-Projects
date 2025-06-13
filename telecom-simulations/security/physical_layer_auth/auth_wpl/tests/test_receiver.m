function tests = test_receiver
%TEST_RECEIVER Test cases for receiver implementation
%
%   This function contains test cases for the receiver implementation,
%   including basic receiver, SDR receiver, and USRP receiver.

tests = functiontests(localfunctions);

end

function test_basic_receiver(testCase)
% Test basic receiver implementation
    fs = 1000;
    t = 0:1/fs:1;
    signal = sin(2*pi*100*t);
    
    output = receiver(signal, fs);
    
    verifyEqual(testCase, length(output), length(signal));
    verifyClass(testCase, output, 'double');
    verifyGreaterThan(testCase, max(abs(output)), 0);
end

function test_sdr_receiver(testCase)
% Test SDR receiver implementation
    fs = 1000;
    t = 0:1/fs:1;
    signal = sin(2*pi*100*t);
    
    output = sdr_receiver(signal, fs);
    
    verifyEqual(testCase, length(output), length(signal));
    verifyClass(testCase, output, 'double');
    verifyGreaterThan(testCase, max(abs(output)), 0);
end

function test_usrp_receiver(testCase)
% Test USRP receiver implementation
    fs = 1000;
    t = 0:1/fs:1;
    signal = sin(2*pi*100*t);
    
    output = usrp_receiving(signal, fs);
    
    verifyEqual(testCase, length(output), length(signal));
    verifyClass(testCase, output, 'double');
    verifyGreaterThan(testCase, max(abs(output)), 0);
end

function test_invalid_inputs(testCase)
% Test invalid input handling
    fs = 1000;
    t = 0:1/fs:1;
    signal = sin(2*pi*100*t);
    
    % Test invalid sampling frequency
    verifyError(testCase, @() receiver(signal, -1), 'MATLAB:validateattributes:expectedPositive');
    verifyError(testCase, @() receiver(signal, 0), 'MATLAB:validateattributes:expectedPositive');
    
    % Test invalid signal
    verifyError(testCase, @() receiver([], fs), 'MATLAB:validateattributes:expectedVector');
    verifyError(testCase, @() receiver(NaN, fs), 'MATLAB:validateattributes:expectedFinite');
end 
