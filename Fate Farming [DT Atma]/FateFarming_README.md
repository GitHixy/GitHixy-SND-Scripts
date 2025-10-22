# Fate Farming Script with Dawntrail Demiatma Integration

## Version: 3.1.0
### Author: GitHixy (based on pot0to's 3.0.9)

This FATE farming script has been developed starting from pot0to's 3.0.9 logic, with significant improvements and complete integration of automatic Dawntrail Demiatma farming.

## Main Features

### 🔥 New in v3.1.0 - Dawntrail Demiatma Integration
- **Automatic Demiatma farming**: Fully integrated system for farming all 6 Dawntrail Demiatma
- **Automatic zone switching**: Script automatically changes zones when reaching target Demiatma count
- **Progress visualization**: Atma progress displayed in status messages (gem count, moving to fate)
- **Smart initialization**: On first start, automatically teleports to the first incomplete zone
- **SND v2 compatibility**: Uses SND v2 APIs for inventory checks and zone detection

### 📋 Supported Dawntrail Zones
1. **Urqopacha** - Azurite Demiatma (Aetheryte: Wachunpelo)
2. **Kozama'uka** - Verdigris Demiatma (Aetheryte: Ok' Zundu)
3. **Yak T'el** - Malachite Demiatma (Aetheryte: Iq Br'aax)
4. **Shaaloani** - Realgar Demiatma (Aetheryte: Hhusatahwi)
5. **Heritage Found** - Caput Mortuum Demiatma (Aetheryte: The Outskirts)
6. **Living Memory** - Orpiment Demiatma (Aetheryte: Leynode Mnemo)

### 🎯 Core FATE Farming Features
- **Advanced priority system**: Distance w/ teleport > most progress > is bonus fate > least time left > distance
- **Automatic voucher purchasing**: Can purchase Bicolor Gemstone Vouchers when your gemstones are almost capped
- **Forlorn management**: Automatically prioritizes Forlorns when they show up during FATE
- **Collection FATEs**: Full support for all FATE types, including NPC collection FATEs
- **Auto resurrection**: Automatically revives upon death and gets back to fate farming
- **Instance changing**: Attempts to change instances when there are no fates left in the zone
- **Retainer management**: Can process your retainers and Grand Company turn ins, then get back to fate farming
- **Auto purchasing**: Automatically buys gysahl greens and grade 8 dark matter when you run out

### 🛠 Available Configurations
- **Enable Atma Farming**: Enable/disable automatic Demiatma farming
- **Target Atma per Zone**: Number of Demiatma to farm per zone before moving to next (default: 3)
- **Food/Potion**: Food and potion configuration (supports HQ with `<hq>` tag)
- **Chocobo Companion**: Chocobo companion stance (Follow, Free, Defender, Healer, Attacker, None)
- **FATE filters**: Progress percentages and minimum duration to ignore FATEs
- **Combat distances**: Maximum distances for melee and ranged combat
- **Rotation plugin**: Support for Any, Wrath, RotationSolver, BossMod, BossModReborn
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

## Development Notes

This script represents a significant evolution of pot0to's original version. The main modifications include:

- Complete rewrite of the Atma management system
- Native integration with Dawntrail zones
- New helper functions for tracking and progression
- Improvements to status visualization
- Optimizations for SND v2 APIs

The code maintains compatibility with all original features while adding a completely new layer for automatic Dawntrail Demiatma management.

---

**Happy Farming! 🎮**