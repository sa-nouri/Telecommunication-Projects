"""
Communication Module

This module contains implementations of various communication systems and protocols,
including wireless communication and wiretap channels.
"""

from .wireless.wiretap import WiretapChannel, ChannelParameters

__all__ = ['WiretapChannel', 'ChannelParameters'] 
