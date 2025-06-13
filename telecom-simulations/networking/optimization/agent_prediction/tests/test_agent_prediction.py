"""
Tests for the agent prediction implementation.
"""

import unittest
import numpy as np
from pathlib import Path
import tempfile
from ..agent_prediction import AgentPrediction, AgentParameters

class TestAgentPrediction(unittest.TestCase):
    """Test cases for the AgentPrediction class."""
    
    def setUp(self):
        """Set up test parameters."""
        self.params = AgentParameters(
            num_agents=5,
            num_states=10,
            num_actions=3,
            learning_rate=0.1,
            discount_factor=0.9,
            exploration_rate=0.1
        )
        self.model = AgentPrediction(self.params)
    
    def test_initialization(self):
        """Test model initialization."""
        self.assertEqual(self.model.q_table.shape, (self.params.num_states, self.params.num_actions))
        self.assertTrue(np.all(self.model.q_table == 0))
    
    def test_action_selection(self):
        """Test action selection."""
        state = 0
        action = self.model.select_action(state)
        self.assertIn(action, range(self.params.num_actions))
    
    def test_q_table_update(self):
        """Test Q-table update."""
        state = 0
        action = 1
        reward = 1.0
        next_state = 2
        
        old_value = self.model.q_table[state, action]
        self.model.update_q_table(state, action, reward, next_state)
        new_value = self.model.q_table[state, action]
        
        self.assertNotEqual(old_value, new_value)
    
    def test_training(self):
        """Test model training."""
        rewards = self.model.train(num_episodes=10)
        self.assertEqual(len(rewards), 10)
        self.assertTrue(all(isinstance(r, float) for r in rewards))
    
    def test_model_save_load(self):
        """Test model saving and loading."""
        with tempfile.TemporaryDirectory() as temp_dir:
            # Train the model
            self.model.train(num_episodes=10)
            
            # Save the model
            save_path = Path(temp_dir) / "model.json"
            self.model.save_model(save_path)
            
            # Load the model
            loaded_model = AgentPrediction.load_model(save_path)
            
            # Check if parameters match
            self.assertEqual(loaded_model.params.num_agents, self.params.num_agents)
            self.assertEqual(loaded_model.params.num_states, self.params.num_states)
            self.assertEqual(loaded_model.params.num_actions, self.params.num_actions)
            
            # Check if Q-table matches
            np.testing.assert_array_equal(loaded_model.q_table, self.model.q_table)

if __name__ == '__main__':
    unittest.main() 
