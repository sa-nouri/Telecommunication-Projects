"""
Tests for the wiretap channel implementation.
"""

import unittest
import numpy as np
from ..wiretap_channel import WiretapChannel, ChannelParameters

class TestWiretapChannel(unittest.TestCase):
    """Test cases for the WiretapChannel class."""
    
    def setUp(self):
        """Set up test parameters."""
        self.params = ChannelParameters(
            snr_main=10.0,
            snr_eve=5.0,
            num_symbols=1000,
            modulation='BPSK'
        )
        self.channel = WiretapChannel(self.params)
    
    def test_signal_generation(self):
        """Test signal generation for different modulation schemes."""
        # Test BPSK
        signal = self.channel.generate_signal()
        self.assertEqual(signal.shape, (self.params.num_symbols,))
        self.assertTrue(np.all(np.isin(signal, [-1, 1])))
        
        # Test QPSK
        self.params.modulation = 'QPSK'
        channel = WiretapChannel(self.params)
        signal = channel.generate_signal()
        self.assertEqual(signal.shape, (self.params.num_symbols,))
        valid_symbols = [1+1j, 1-1j, -1+1j, -1-1j]
        self.assertTrue(np.all(np.isin(signal, valid_symbols)))
    
    def test_noise_addition(self):
        """Test noise addition to signals."""
        signal = np.ones(1000)
        noisy_signal = self.channel.add_noise(signal, 10.0)
        self.assertEqual(noisy_signal.shape, signal.shape)
        self.assertFalse(np.array_equal(noisy_signal, signal))
    
    def test_simulation(self):
        """Test channel simulation."""
        main_signal, eve_signal = self.channel.simulate()
        self.assertEqual(main_signal.shape, (self.params.num_symbols,))
        self.assertEqual(eve_signal.shape, (self.params.num_symbols,))
        self.assertFalse(np.array_equal(main_signal, eve_signal))
    
    def test_invalid_modulation(self):
        """Test handling of invalid modulation scheme."""
        self.params.modulation = 'INVALID'
        with self.assertRaises(ValueError):
            WiretapChannel(self.params)

if __name__ == '__main__':
    unittest.main() 
