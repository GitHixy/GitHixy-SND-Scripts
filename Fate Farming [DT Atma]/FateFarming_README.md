# Fate Farming Script with Dawntrail Demiatma Integration

## Version: 3.2.5
### Author: GitHixy (based on pot0to's 3.0.9)

This FATE farming script has been developed starting from pot0to's 3.0.9 logic, with significant improvements and complete integration of automatic Dawntrail Demiatma farming.

## Main Features

### New in v3.2.5 - Food/Potion System Fix
- **Improved stability**: Script no longer crashes when food or potions run out
- **Error handling**: Uses pcall (protected call) to catch exceptions from /item commands
- **Warning messages**: Displays clear warnings when consumables are not found or finished
- **Continues farming**: Script keeps running indefinitely even without food/potion buffs

### New in v3.2.4 - Forlorn Maiden Buff Control
- **Configurable buff waiting**: New "Wait for Forlorn Maiden Buff?" option in metadata
- **Strategic flexibility**: Choose whether to wait in zone when you have Twist of Fate buff
- **Default behavior preserved**: Enabled by default to maintain existing farming strategy
- **User choice**: Disable to ignore the buff and continue normal zone/instance switching

### In v3.2.0 - Multi Zone Farming
- **Multi Zone Farming mode**: Automatically cycles through configured zones when no eligible FATEs found
- **Zone list customization**: Configure which zones to cycle through (comma-separated list)
- **Mutual exclusivity**: Atma and Multi Zone modes are mutually exclusive for clarity
- **Improved navigation**: Enhanced aetheryte navigation logic with better fallback handling

### In v3.1.0 - Dawntrail Demiatma Integration
- **Automatic Demiatma farming**: Fully integrated system for farming all 6 Dawntrail Demiatma
- **Automatic zone switching**: Script automatically changes zones when reaching target Demiatma count
- **Progress visualization**: Atma progress displayed in status messages (gem count, moving to fate)
- **Smart initialization**: On first start, automatically teleports to the first incomplete zone
- **SND v2 compatibility**: Uses SND v2 APIs for inventory checks and zone detection

### Supported Dawntrail Zones
1. **Urqopacha** - Azurite Demiatma (Aetheryte: Wachunpelo)
2. **Kozama'uka** - Verdigris Demiatma (Aetheryte: Ok' Zundu)
3. **Yak T'el** - Malachite Demiatma (Aetheryte: Iq Br'aax)
4. **Shaaloani** - Realgar Demiatma (Aetheryte: Hhusatahwi)
5. **Heritage Found** - Caput Mortuum Demiatma (Aetheryte: The Outskirts)
6. **Living Memory** - Orpiment Demiatma (Aetheryte: Leynode Mnemo)

### Core FATE Farming Features
- **Advanced priority system**: Distance w/ teleport > most progress > is bonus fate > least time left > distance
- **Automatic voucher purchasing**: Can purchase Bicolor Gemstone Vouchers when your gemstones are almost capped
- **Forlorn management**: Automatically prioritizes Forlorns when they show up during FATE
- **Collection FATEs**: Full support for all FATE types, including NPC collection FATEs
- **Auto resurrection**: Automatically revives upon death and gets back to fate farming
- **Instance changing**: Attempts to change instances when there are no fates left in the zone
- **Retainer management**: Can process your retainers and Grand Company turn ins, then get back to fate farming
- **Auto purchasing**: Automatically buys gysahl greens and grade 8 dark matter when you run out

### 🛠 Available Configurations

#### Farming Modes (Mutually Exclusive)
- **Enable Atma Farming**: Enable/disable automatic Demiatma farming. When enabled, script farms specific Demiatma count per zone.
- **Target Atma per Zone**: Number of Demiatma to farm per zone before moving to next (default: 3)
- **Enable Multi Zone Farming**: Enable/disable automatic zone cycling when no FATEs found. When enabled, immediately switches to next zone.
- **Multi Zone List**: Comma-separated list of zones to cycle through (default: all 6 DT zones)

#### General Settings
- **Food/Potion**: Food and potion configuration (supports HQ with `<hq>` tag)
- **Chocobo Companion**: Chocobo companion stance (Follow, Free, Defender, Healer, Attacker, None)
- **FATE filters**: Progress percentages and minimum duration to ignore FATEs
- **Combat distances**: Maximum distances for melee and ranged combat
- **Rotation plugin**: Support for Any, Wrath, RotationSolver, BossMod, BossModReborn
- **Change instances if no FATEs**: Enable/disable automatic instance changing when no FATEs available
- **Wait for Forlorn Maiden Buff**: When enabled, stays in same zone/instance if you have Twist of Fate buff (from Forlorn Maidens). When disabled, ignores buff and proceeds with zone/instance switching normally.
- **Echo logs**: Log message control (All, Gems, None)

## Installation and Usage

### Required Plugins
- **Something Need Doing [Expanded Edition]**: Main plugin
- **VNavmesh**: For pathfinding and movement
- **Rotation plugin** (one of):
  - RotationSolver Reborn
  - BossMod Reborn  
  - Veyn's BossMod
  - Wrath Combo
- **Dodging plugin** (one of):
  - BossMod Reborn
  - Veyn's BossMod
- **TextAdvance**: For interacting with FATE NPCs
- **Lifestream**: For changing instances and exchange

### Optional Plugins
- **AutoRetainer**: For retainer management
- **Deliveroo**: For Grand Company turn-ins
- **YesAlready**: For materia extraction

### Instructions
1. Import the script into SND (Something Need Doing)
2. Configure parameters according to your preferences
3. If you want to use Demiatma farming, enable "Enable Atma Farming" and set "Target Atma per Zone"
4. Start the script - it will automatically teleport to the appropriate zone
5. The script will automatically handle everything: FATE farming, zone switching, purchases, resurrections

## How Atma Integration Works

1. **Initial check**: Script checks your inventory to determine which Demiatma you already have
2. **Zone selection**: Teleports to the first zone where you haven't reached the target Demiatma count
3. **Farming**: Performs FATEs in the current zone
4. **Progress monitoring**: After each FATE checks if you've obtained new Demiatma
5. **Automatic zone switching**: When you reach the target for current zone, automatically moves to the next
6. **Completion**: When all zones are completed, continues normal FATE farming

---

**Happy Farming!**