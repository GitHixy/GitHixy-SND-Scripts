
# Auto Chocobo Train & Race Script

## Version: 2.0.0
### Author: GitHixy

This script automates Chocobo training and racing in Final Fantasy XIV, adding convenience for players looking to level up their ranks through the Gold Saucer's Chocobo Racing feature.

### Features:
- **SND v2 Support**: Fully updated for Something Need Doing v2 with metadata configuration
- Automatically train Chocobo if training sessions are available before racing
- Purchase training food automatically based on user selection (Grade 1 only)
- Continuous training and racing until the desired rank is reached
- Supports multiple feed types: Speed, Acceleration, Endurance, Stamina, and Balance
- Integrates Chocobo Dash ability during races and improves targeting logic for Chocobo Trainer NPC
- **Easy Configuration**: All settings now configurable through SND settings UI

### Installation and Usage:
1. Place the script in your SND (Something Need Doing)
2. Configure settings through the SND settings UI:
   - **Feed Type**: Choose which stat to train (Speed, Acceleration, Endurance, Stamina, Balance)
   - **Move Forward Key**: Set your move forward key (default: W)
   - **Target Rank**: Set the target rank to achieve (default: 40)
3. Run the script, and it will handle the rest, including teleportation to the Gold Saucer, targeting NPCs, training your Chocobo, and starting races

### Requirements:
- Something Need Doing (Expanded Edition) v2.0+
- VNavmesh: For pathfinding and movement
- Lifestream: Use Aethernet in Gold Saucer
- TextAdvance: Skip Race Cutscenes and skip dialogue if Chocobo cannot be fed anymore

### Optional:  
You can create a macro in-game using: `/snd run "Your_script_name_here"`

### Script Parameters (Now in SND Settings):
- **Feed Type**: Choose from "Speed", "Acceleration", "Endurance", "Stamina", or "Balance"
- **Move Forward Key**: Key for moving forward during the race. Default is `W`
- **Target Rank**: The rank your Chocobo will aim to achieve before the script stops. Default is 40

### How It Works:
1. The script first checks if your Chocobo can be trained. If so, it will teleport to the Gold Saucer and interact with the NPC to purchase the required feed and train your Chocobo
2. If no training sessions are available or after training is completed, the script starts the Chocobo race using the Duty Finder
3. During the race, it automates the movement and abilities of your Chocobo
4. After the race, it checks your Chocobo's new rank and repeats the process until the target rank is reached

### Updates:

- **2.0.0**: **MAJOR UPDATE** - Updated for SND v2 with full metadata support. All settings now configurable through SND UI. Replaced all deprecated API calls with new SND v2 functions. Added proper plugin dependency management.
- **1.30**: Added functionality to automatically train Chocobo if training sessions are available before racing
- **1.29**: Refactored pathing logic and improved targeting robustness for Chocobo Trainer
- **1.28**: Added automatic purchasing of training food based on user selection
- **1.27**: Integrated race logic and allowed for continuous training and racing
- **1.26**: Fixed Chocobo rank retrieval from Gold Saucer tab
- **1.25**: Refined inventory selection for feed item and NPC interactions
- **1.24**: Minor bug fixes and improvements to duty finder selection logic
- **1.23**: Improved error handling for missing feed and failed NPC targeting
- **1.22**: Added KEY_2 pressing on counter = 10 to use Chocobo Dash ability
- **1.21**: Automatic handling of Chocobo parameters tab

### Notes:
- This script is intended for convenience and may not guarantee first-place finishes in every race
- All configuration is now done through the SND settings UI - no need to edit the script!
- Make sure you have all required plugins installed and updated


Happy Levelling!
