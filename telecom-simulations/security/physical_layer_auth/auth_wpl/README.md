# Physical Layer Authentication Module

This module implements physical layer authentication techniques for wireless communication systems, focusing on carrier frequency offset (CFO) and high-throughput frequency estimation (HTFE).

## Directory Structure

```
auth_wpl/
├── receivers/           # Receiver implementations
│   ├── receiver.m      # Basic receiver
│   ├── sdr_receiver.m  # SDR receiver
│   ├── sdru_receiver.m # SDR-USRP receiver
│   └── usrp_receiving.m # USRP receiver
├── estimation/         # Frequency estimation
│   ├── cfo_capturing.m # CFO estimation
│   ├── htfe.m         # High-throughput frequency estimation
│   └── carrier_frequency_offset.m # Carrier frequency offset
└── simulation/        # Simulation files
    └── run_wlan_nonht_receiver.m # WLAN receiver simulation
```

## Usage

### Receiver Implementation

```matlab
% Basic receiver
fs = 1000;
signal = your_signal;
output = receiver(signal, fs);

% SDR receiver
output = sdr_receiver(signal, fs);

% USRP receiver
output = usrp_receiving(signal, fs);
```

### Frequency Estimation

```matlab
% CFO estimation
cfo = cfo_capturing(signal, fs);

% High-throughput frequency estimation
freq = htfe(signal, fs);
```

## Requirements

- MATLAB R2019b or later
- Signal Processing Toolbox
- Communications Toolbox (for SDR functionality)
- USRP Support Package (for USRP functionality)

## Testing

Each function includes input validation and example usage in its documentation. To run the tests:

```matlab
% Run all tests
runtests('tests')

% Run specific test
runtests('tests/test_receiver')
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
