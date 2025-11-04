# Chocobo Race Script

## Version: 1.0.0
### Author: GitHixy

This is an automated Chocobo Racing script for Final Fantasy XIV. The script handles basic Chocobo Race operations including accessing the Gold Saucer menu and retrieving Chocobo information.

## Main Features

### 🎯 Basic Functionality
- **Gold Saucer Menu Access**: Automatically opens the Gold Saucer menu
- **Chocobo Section Navigation**: Navigates to the Chocobo racing section
- **Chocobo Information Retrieval**: Gets current Chocobo name and rank
- **Rank Tracking**: Monitors current rank progression

## 🛠 Available Configurations

### Racing Settings
- **Rank to reach**: Target rank to achieve (default: 40, maximum rank)
- **Key to go forward**: Movement key for racing (default: W)

## Installation and Usage

### Required Plugins
- **Something Need Doing [Expanded Edition]**: Main plugin
- **TextAdvance**: For interacting with menus

### Required Scripts
- **vac_functions.lua**: Must be loaded separately in SND before running this script

### Instructions
1. Load `vac_functions.lua` as a separate script in SND first
2. Import the Chocobo Race script into SND
3. Configure the target rank and movement key if desired
4. Start the script - it will automatically access the Gold Saucer and retrieve Chocobo information

## Development Status

This is the initial version with basic menu navigation and information retrieval. Future versions will include:
- Automatic race participation
- Optimal racing strategies
- Race course analysis
- Performance optimization

---

**Happy Racing! 🐔**</content>
<parameter name="filePath">d:\GitHixy Repos\GitHixy-SND-Scripts\Chocobo Race\ChocoboRace_README.md