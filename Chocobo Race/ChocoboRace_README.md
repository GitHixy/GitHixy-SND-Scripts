
# Auto Chocobo Train & Race Script

## Version: 1.30
### Author: GitHixy

This script automates Chocobo training and racing in Final Fantasy XIV, adding convenience for players looking to level up their ranks through the Gold Saucer's Chocobo Racing feature.

### Features:
- Automatically train Chocobo if training sessions are available before racing.
- Purchase training food automatically based on user selection (Grade 1 only atm).
- Continuous training and racing until the desired rank is reached.
- Supports multiple feed types: Speed, Acceleration, Endurance, Stamina, and Balance.
- Integrates Chocobo Dash ability during races (adjust counter as needed) and improves targeting logic for Chocobo Trainer NPC.

### Installation and Usage:
1. Place the script in your SND (Something Need Doing).
2. Customize the script to suit your needs, including changing the move forward key, target rank, feed type, wait timers and counter.
4. Run the script, and it will handle the rest, including teleportation to the Gold Saucer, targeting NPCs, training your Chocobo, and starting races.

### Requirements:
- Something Need Doing (Expanded Edition).
- Lifestream: Use Aethernet in Gold Saucer.
- TextAdvance: Skip Race Cutscenes and skip dialogue if Chocobo cannot be feeded anymore.

### Optional:  
You can create a macro in-game using: `/snd run "Your_script_name_here"`

### Script Parameters:
- `feed_type`: Choose from "Speed", "Acceleration", "Endurance", "Stamina", or "Balance".
- `move_forward_key`: Key for moving forward during the race. Default is `W`.
- `target_rank`: The rank your Chocobo will aim to achieve before the script stops. Default is 40.

### How It Works:
1. The script first checks if your Chocobo can be trained. If so, it will teleport to the Gold Saucer and interact with the NPC to purchase the required feed and train your Chocobo.
2. If no training sessions are available or after training is completed, the script starts the Chocobo race using the Duty Finder.
3. During the race, it automates the movement and abilities of your Chocobo.
4. After the race, it checks your Chocobo's new rank and repeats the process until the target rank is reached.

### Updates:

- **1.30**: Added functionality to automatically train Chocobo if training sessions are available before racing.
- **1.29**: Refactored pathing logic and improved targeting robustness for Chocobo Trainer.
- **1.28**: Added automatic purchasing of training food based on user selection.
- **1.27**: Integrated race logic and allowed for continuous training and racing.
- **1.26**: Fixed Chocobo rank retrieval from Gold Saucer tab.
- **1.25**: Refined inventory selection for feed item and NPC interactions.
- **1.24**: Minor bug fixes and improvements to duty finder selection logic.
- **1.23**: Improved error handling for missing feed and failed NPC targeting.
- **1.22**: Added KEY_2 pressing on counter = 10 to use Chocobo Dash ability.
- **1.21**: Automatic handling of Chocobo parameters tab.

### Notes:
- This script is intended for convenience and may not guarantee first-place finishes in every race.
- Make sure to customize the move forward key if you use a different setup.


Happy Levelling!
