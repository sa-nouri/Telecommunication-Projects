# Project Report: Activity Detection Using Monte Carlo Algorithm

In this report, we first introduce the dataset used for this experiment, followed by an explanation of the Monte Carlo algorithm and the process of predicting the performed activities. Finally, based on the dataset file that includes activities over a 24-hour period, we start learning and estimating these activities. Ultimately, the accuracy and error rate for each hour can be determined.

## Dataset Description

The dataset comprises traffic activities of individuals over a 24-hour period. This includes various types of traffic such as email, chat, etc. Each activity is labeled with numbers like 0, 1, 2, and so on.

## Methodology

1. Labeling Activities: Initially, each type of activity is assigned a unique label (e.g., 0 for email, 1 for chat).

2. Generating Episodes: We generate an episode of these activities for one hour of the day.

3. Learning with Monte Carlo Algorithm:
   - Since the environment for this model is not a Markov Decision Process (MDP), traditional Q-learning algorithms cannot be used. Instead, we use the Monte Carlo algorithm, which is suitable for non-Markovian environments.
   - In the Monte Carlo algorithm, we define state, action, and reward and implement the algorithm based on these definitions.
   - State: Each activity is considered a state.
   - Action: The next activity performed, represented by a corresponding label.
   - Reward: For each episode, if the chosen action matches the expected activity, we assign a maximum reward. Otherwise, a negative or zero reward is given.

## Implementation

1. State Representation: Each activity is considered a state.
2. Action Representation: The subsequent activity performed, represented by the respective label.
3. Reward Structure: If the action matches the expected activity in the episode, a maximum reward is given; otherwise, a negative or zero reward is assigned.

We begin by learning from the generated episode and attempt to produce episodes based on the activities learned by the agent.

## Output

The output of a generated episode, which has been produced after learning through the above algorithm, is as follows:

Each label corresponds to a specific performed activity, illustrating the model’s predictions and learning.

This approach allows us to determine the accuracy and error rate for each activity prediction across different hours, thereby validating the model’s performance.
