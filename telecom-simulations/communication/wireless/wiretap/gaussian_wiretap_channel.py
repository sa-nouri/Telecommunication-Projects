#!/usr/bin/env python3
"""
Gaussian Wiretap Channel Simulation

This script simulates the Gaussian wiretap channel and calculates mutual information and bit error rate (BER).
"""

import numpy as np
import matplotlib.pyplot as plt

def simulate_channel(snr_db, num_bits=1000):
    """
    Simulate the Gaussian wiretap channel for a given SNR in dB.

    Args:
        snr_db (float): Signal-to-noise ratio in dB.
        num_bits (int, optional): Number of bits to simulate. Defaults to 1000.

    Returns:
        tuple: (received_signal, noise_power)
    """
    # Generate random binary data
    data = np.random.randint(0, 2, num_bits)
    # Convert to BPSK symbols
    symbols = 2 * data - 1
    # Calculate noise power based on SNR
    noise_power = 10 ** (-snr_db / 10)
    # Generate noise
    noise = np.sqrt(noise_power) * np.random.randn(num_bits)
    # Simulate received signal
    received_signal = symbols + noise
    return received_signal, noise_power

def calculate_ber(received_signal, data):
    """
    Calculate the bit error rate (BER) from the received signal and original data.

    Args:
        received_signal (numpy.ndarray): Received signal after channel simulation.
        data (numpy.ndarray): Original binary data.

    Returns:
        float: Bit error rate.
    """
    # Demodulate received signal
    demodulated = np.sign(received_signal)
    # Convert back to binary
    received_bits = (demodulated + 1) / 2
    # Calculate BER
    ber = np.sum(received_bits != data) / len(data)
    return ber

def main():
    """
    Main function to run the simulation and plot results.
    """
    snr_values = np.linspace(0, 10, 11)
    ber_values = []

    for snr in snr_values:
        received, _ = simulate_channel(snr)
        data = np.random.randint(0, 2, len(received))
        ber = calculate_ber(received, data)
        ber_values.append(ber)

    plt.figure()
    plt.semilogy(snr_values, ber_values, 'o-')
    plt.xlabel('SNR (dB)')
    plt.ylabel('Bit Error Rate (BER)')
    plt.title('BER vs SNR for Gaussian Wiretap Channel')
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    main()
