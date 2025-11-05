# Chocobo Racing Automation Script

## Overview
Fully automated chocobo racing script for Final Fantasy XIV using SomethingNeedDoing (SND) addon. Automatically farms chocobo races until your target rank is reached.

## Version
**1.0.0** - Initial Release

## Features
- ✅ Reads chocobo name and current rank from Gold Saucer menu
- ✅ Opens Duty Finder and selects Chocobo Race (Random)
- ✅ Queues for races and automatically accepts duty pop
- ✅ Executes races with forward movement and ability rotation
- ✅ Detects race completion via results screen
- ✅ Leaves duty and returns to Gold Saucer
- ✅ Loops automatically until target rank is reached
- ✅ Tracks race count and displays progress

## Requirements

### Required Plugins
None! The script is fully self-contained.

## Configuration

### Rank (Required)
- **Type:** Integer (1-40)
- **Default:** 40
- **Description:** Target rank for your chocobo to reach

### Forward Key (Required)
- **Type:** String
- **Default:** "w"
- **Description:** Keyboard key used to move forward during races
- Script uses `/hold` and `/release` commands to maintain forward movement

## How It Works

### Full Automation Loop
The script executes the following steps for each race:

1. **Read Chocobo Info:**
   - Opens Gold Saucer menu (`/goldsaucer`)
   - Navigates to Chocobo Racing tab
   - Reads chocobo name (AtkValue 6)
   - Reads current rank (AtkValue 8)
   - Compares with target rank

2. **Queue for Race:**
   - Opens Duty Finder (`/dutyfinder`)
   - Navigates to Gold Saucer tab (tab 9)
   - Selects Chocobo Race (Random) via callback
   - Checks if duty is already selected (prevents deselection)
   - Queues for the duty

3. **Race Execution:**
   - Waits for queue pop and accepts via ContentsFinderConfirm addon
   - Waits for duty loading and zone transition
   - Holds forward key down (`/hold`)
   - Uses abilities 1-5 in rotation with 1 second delays
   - Detects race end via RaceChocoboResult addon appearance
   - Releases forward key (`/release`)

4. **Complete and Repeat:**
   - Waits for race results screen
   - Leaves duty via callback
   - Waits for return to Gold Saucer
   - Increments race counter
   - Loops back to step 1

## Logging

The script uses a structured logging system:

- `[CHOCOBO]` prefix for all messages
- **LogInfo** - General information and status updates
- **LogDebug** - Detailed operation information
- **yield("/echo")** - Important messages visible in game chat

## Technical Details

### Addon API Usage
The script uses Dalamud's Addon API with AtkValues:
```lua
-- GoldSaucerInfo addon
GetAtkValue(6)   -- Chocobo Name (ValueString)
GetAtkValue(8)   -- Chocobo Rank (ValueString)

-- ContentsFinder addon
GetAtkValue(18)  -- Currently selected duty name (ValueString)

-- Addons used for detection
IsAddonVisible("GoldSaucerInfo")        -- Gold Saucer menu
IsAddonVisible("ContentsFinder")         -- Duty Finder
IsAddonVisible("ContentsFinderConfirm")  -- Queue pop confirmation
IsAddonVisible("RaceChocoboResult")      -- Race results screen
```

### Callbacks Used
```lua
-- Gold Saucer Menu
/callback GoldSaucerInfo true 0 1 119 0 0  -- Open Chocobo Racing tab
/callback GoldSaucerInfo true -1            -- Close menu

-- Duty Finder
/callback ContentsFinder true 1 9          -- Navigate to Gold Saucer tab
/callback ContentsFinder true 3 10         -- Select Chocobo Race (Random)
/callback ContentsFinder true 12 0         -- Queue for selected duty

-- Queue and Results
/callback ContentsFinderConfirm true 8     -- Accept duty pop
/callback RaceChocoboResult true 1         -- Leave duty after race
```

### Key Commands
```lua
/hold w          -- Hold forward key down
/release w       -- Release forward key
/send 1          -- Press ability key 1
/send 2-5        -- Abilities 2 through 5
```

## Development Roadmap

### Version 1.0.0 (Current - Complete ✅)
- [x] Script structure and metadata
- [x] Basic utility functions
- [x] Gold Saucer menu interaction
- [x] Chocobo info reading via AtkValues
- [x] Rank validation and target checking
- [x] Duty Finder registration
- [x] Race queue and duty pop acceptance
- [x] Race start detection and loading
- [x] Forward movement with key hold
- [x] Ability rotation (1-5)
- [x] Race completion detection
- [x] Automated loop until target rank
- [x] Race counter and progress tracking

## Known Limitations

1. **Race Strategy:** Uses basic forward movement + ability spam, no advanced racing tactics
2. **Race Type:** Only supports Chocobo Race (Random), no specific track selection
3. **Queue Times:** Will wait indefinitely for queue pop
4. **No Training:** Does not automate training sessions between races
5. **Results Analysis:** Does not track race placement or performance metrics

## Support

For issues, suggestions, or contributions:
- GitHub: [GitHixy/GitHixy-SND-Scripts](https://github.com/GitHixy/GitHixy-SND-Scripts)
- Check existing issues before creating new ones
- Include log output when reporting bugs

## Credits

- **Author:** GitHixy

## License

Part of the GitHixy-SND-Scripts collection.
