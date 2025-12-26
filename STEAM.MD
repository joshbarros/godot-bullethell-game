# Steam Integration Guide 🎮

**STATUS:** Not Yet - Implement in Phase 5 (Month 6+)

**PREREQUISITES BEFORE IMPLEMENTING:**
- ✅ Health system complete
- ✅ Boss battles implemented
- ✅ Score/stats tracking working
- ✅ Wave system functioning
- ✅ Multiple enemy types
- ✅ Meta-progression system
- ✅ Core gameplay polished
- 💰 $100 USD for Steam Direct fee ready
- 📄 Business entity setup (LLC recommended)

---

## When To Implement

### ❌ DO NOT implement Steam integration until:
1. You have **30+ hours of gameplay testing** completed
2. You have **stats worth tracking** (kills, deaths, waves survived, bosses defeated)
3. You have **achievements worth unlocking** (first boss kill, 100 enemies killed, etc.)
4. You're **ready to pay** the $100 Steam Direct fee
5. You have a **Steam app ID** (requires Steam Direct registration)

### ✅ Implement Steam integration when:
- Core game is feature-complete
- You're 1-2 months from commercial launch
- Beta testing is underway
- You have meaningful achievements/stats to track

---

## GodotSteam Plugin Setup

### Installation Steps:

1. **Download GodotSteam:**
   - Visit: https://godotsteam.com/
   - **Latest Version:** v4.17 (for Godot 4.5.1 with Steamworks SDK 1.63)
   - **Repository:** https://codeberg.org/godotsteam/godotsteam (moved from GitHub Dec 2025)
   - Download the GDExtension version for plug-and-play usage
   - Extract to `addons/godotsteam/` in your project folder

2. **Steamworks SDK Files:**
   - Download Steamworks SDK 1.63 from https://partner.steamgames.com/
   - Copy `steam_api64.dll` (Windows) to `addons/godotsteam/win64/`
   - Copy `libsteam_api.so` (Linux) to `addons/godotsteam/linux64/`
   - Copy `libsteam_api.dylib` (Mac) to `addons/godotsteam/osx/`

3. **Configure Steam App ID (4 Methods):**
   
   **Method 1 - Project Settings (Recommended for Godot 4.x):**
   - Go to Project > Project Settings > Steam > Initialization
   - Set "App ID" field
   - Enable "Auto-initialize" if desired
   
   **Method 2 - steam_appid.txt (Classic Method):**
   - Create `steam_appid.txt` in project root
   - Add your Steam App ID: `480` (use 480 for testing, your real ID later)
   - Valve recommends NOT shipping this file with your game
   
   **Method 3 - Environment Variables:**
   - Set in your autoload script's `_init()`:
   ```gdscript
   OS.set_environment("SteamAppId", str(480))
   OS.set_environment("SteamGameId", str(480))
   ```
   
   **Method 4 - Pass to steamInitEx():**
   - Pass App ID as first argument to initialization function

4. **Enable Logging (Recommended):**
   - Project > Project Settings > Logging > File Logging
   - Check "Enable File Logging"
   - Helps debug Steam initialization issues

5. **Test Without Real App ID:**
   - Use App ID `480` (Valve's SpaceWar example game) for development
   - Switch to your real App ID before release

---

## Steam Controller Implementation

### steam_controller.gd
**Location:** `/Scripts/Steam/steam_controller.gd`

This is your main Steam integration singleton. It handles:
- Steam initialization
- Achievement tracking
- Statistics tracking
- User data sync

```gdscript
extends Node

var achievements : Dictionary = {
	"ACH_WIN_ONE_GAME": false,
	"ACH_WIN_100_GAMES": false,
	"ACH_TRAVEL_FAR_ACCUM": false,
	"ACH_TRAVEL_FAR_SINGLE": false
}

var stats : Dictionary = {
	"NumGames": 0,
	"NumWins": 0,
	"NumLosses": 0,
	"FeetTraveled": 0,
	"AverageSpeed": 0,
	"MaxFeetTraveled": 0
}

func _init():
	# Initialize and connect to Steam (NEW in GodotSteam 4.14+)
	# Option 1: Auto-initialize in Project Settings (recommended)
	# Option 2: Manual initialization with error checking
	var response: Dictionary = Steam.steamInitEx(true, 480)
	print("Steam Init Response: ", response)
	
	# Check initialization status (NEW in SDK 1.61+)
	if response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		push_error("Failed to initialize Steam: %s" % response['verbal'])
		# Could disable Steam features or quit game
		return
	
	print("Steam initialized successfully!")
	
	# Fetch our Steam username
	var username: String = Steam.getPersonaName()
	print("Steam Username: ", username)
	
	# Fetch our Steam ID - used to access other stuff later
	var steam_id: int = Steam.getSteamID()
	
	# do we own this game on Steam?
	var is_owned: bool = Steam.isSubscribed()
	
	# are we logged into Steam?
	var is_online: bool = Steam.loggedOn()
	
	# returns the game's launch options
	var launch_cmd_line: String = Steam.getLaunchCommandLine()
	
	# is the game running on a Steam Deck?
	var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	
	# is the game running in VR?
	var is_on_vr: bool = Steam.isSteamRunningInVR()
	
	# is the player VAC banned?
	var is_vac_banned: bool = Steam.isVACBanned()
	
	# language of the game - e.g. "english", "french"
	var game_language: String = Steam.getCurrentGameLanguage()
	
	# language of the UI - e.g. "english", "spanish"
	var ui_language: String = Steam.getSteamUILanguage()
	
	# IMPORTANT: SDK 1.61+ auto-syncs stats/achievements
	# No need to call requestCurrentStats() anymore!
	# Data is available immediately after initialization
	_load_achievements()
	_load_stats()

func _process(delta):
	# CRITICAL: Must call Steam.run_callbacks() every frame
	# Alternative: Enable "Embed Callbacks" in Project Settings
	Steam.run_callbacks()

# Store the Steam achievements locally in the "achievements" dictionary
func _load_achievements():
	for a in achievements.keys():
		var steam_ach: Dictionary = Steam.getAchievement(a)
		
		# Check if achievement exists in Steamworks back-end
		if not steam_ach["ret"]:
			push_warning("Achievement not found in Steam: %s" % a)
			continue
			
		achievements[a] = steam_ach["achieved"]

# Unlock the given achievement
func set_achievement(achievement: String):
	if not achievements.has(achievement):
		push_error("Achievement not defined locally: %s" % achievement)
		return
		
	achievements[achievement] = true
	
	if not Steam.setAchievement(achievement):
		push_error("Failed to set achievement: " + achievement)
		return
	
	print("Achievement unlocked: ", achievement)
	
	if not Steam.storeStats():
		print("Failed to store data on Steam.")

# Lock all achievements (useful for testing)
func reset_achievements():
	for a in achievements.keys():
		if not Steam.clearAchievement(a):
			push_error("Failed to clear achievement: %s" % a)
	
	if not Steam.storeStats():
		print("Failed to store reset data on Steam.")

# Store the Steam stats locally in the "stats" dictionary
func _load_stats():
	for stat in stats.keys():
		var steam_stat: int = Steam.getStatInt(stat)
		stats[stat] = steam_stat
		print("Loaded stat %s: %s" % [stat, steam_stat])

# Update the value of a stat, saving it to Steam
func set_stat(stat_name: String, value: int):
	if not stats.has(stat_name):
		push_error("Stat not defined locally: %s" % stat_name)
		return
		
	stats[stat_name] = value
	
	if not Steam.setStatInt(stat_name, value):
		push_error("Failed to set stat: %s" % stat_name)
		return
	
	print("Stat updated: %s = %s" % [stat_name, value])
	
	if not Steam.storeStats():
		push_error("Failed to store data on Steam.")
		return
	
	print("Stats stored successfully")
```

**Key Changes from GodotSteam 3.x → 4.x:**
- **SDK 1.61+** auto-syncs stats/achievements at boot
- No more `requestCurrentStats()` or `current_stats_received` callback
- Stats and achievements are immediately available after `steamInitEx()`
- `steamInitEx()` returns detailed error dictionary with `status` and `verbal` keys
- First argument is now `app_id`, second is `embed_callbacks` (boolean removed)

---

## Achievement UI Implementation

### achievements_screen.gd
**Location:** `/Scripts/Steam/achievements_screen.gd`

Manages the achievements UI display.

```gdscript
extends Control

@onready var list_container : VBoxContainer = $AchievementList
var boxes : Array = []

func _ready ():
	boxes = list_container.get_children()
	_update_list()
	Steam.user_stats_stored.connect(_on_user_stats_stored)

# Called when we have uploaded/saved our stats to the Steam servers
func _on_user_stats_stored (game_id : int, result : int):
	_update_list()

func _update_list ():
	# Convert our dictionary of achievements to a string array
	# The elements of the array are the dictionary's keys
	var achs = SteamController.achievements.keys()
	
	for i in len(boxes):
		# Hide the box if we don't need it
		if i >= len(achs):
			boxes[i].visible = false
			continue
		
		boxes[i].visible = true
		boxes[i].set_achievement(achs[i])
```

### achievement_box.gd
**Location:** `/Scripts/Steam/achievement_box.gd`

Individual achievement display widget.

```gdscript
extends Panel

@onready var icon : TextureRect = $Icon
@onready var display_name : Label = $DisplayName
@onready var description : Label = $Description

var current_achievement : String

func set_achievement (achievement : String):
	current_achievement = achievement
	
	# Get the display name from "name" attribute
	display_name.text = Steam.getAchievementDisplayAttribute(current_achievement, "name")
	
	# Get the description from "desc" attribute
	description.text = Steam.getAchievementDisplayAttribute(current_achievement, "desc")
	icon.texture = _get_icon()

func _get_icon () -> ImageTexture:
	# Get the icon handle which we can use to access other data about it
	var icon_handle : int = Steam.getAchievementIcon(current_achievement)
	
	# Get the icon size - "width" and "height" values
	var icon_size : Dictionary = Steam.getImageSize(icon_handle)
	
	# Get the icon raw image data
	var icon_buffer : Dictionary = Steam.getImageRGBA(icon_handle)
	
	# Convert the raw data into an Image
	var image : Image = Image.create_from_data(icon_size.width, icon_size.height, false, Image.FORMAT_RGBA8, icon_buffer.buffer)
	
	# Convert the Image into an ImageTexture and return it
	return ImageTexture.create_from_image(image)

# When we click the "Unlock" button, unlock the achievement
func _on_unlock_button_pressed():
	SteamController.set_achievement(current_achievement)
```

---

## Statistics Tracking UI

### stat_box.gd
**Location:** `/Scripts/Steam/stat_box.gd`

Displays and manages individual stat tracking.

```gdscript
extends Panel

@export var stat : String
@onready var stat_text : Label = $StatText

func _ready ():
	Steam.user_stats_received.connect(_on_user_stats_received)

# Called when we receive our stats from Steam
func _on_user_stats_received (game_id : int, result : int, user_id : int):
	_update_text()

func _update_text ():
	var stat_value : int = SteamController.stats[stat]
	stat_text.text = stat + " = " + str(stat_value)

func _on_decrease_button_pressed():
	var cur_value : int = SteamController.stats[stat]
	cur_value -= 1
	SteamController.set_stat(stat, cur_value)
	_update_text()

func _on_increase_button_pressed():
	var cur_value : int = SteamController.stats[stat]
	cur_value += 1
	SteamController.set_stat(stat, cur_value)
	_update_text()
```

---

## Steam Avatar Display

### steam_avatar.gd
**Location:** `/Scripts/Steam/steam_avatar.gd`

Downloads and displays user's Steam avatar.

```gdscript
extends TextureRect

# (1) Steam.AVATAR_SMALL = 32x32
# (2) Steam.AVATAR_MEDIUM = 64x64
# (3) Steam.AVATAR_LARGE = 128x128

func _ready ():
	# It takes time to download the image, so we connect to the signal
	# which emits once the avatar download has been completed
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	
	# To begin downloading an avatar, we call this function
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, Steam.getSteamID())

# Called once we have downloaded a user's avatar
func _on_avatar_loaded (user_id : int, avatar_size : int, avatar_buffer : PackedByteArray):
	# Convert the raw data into an Image
	var image : Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	
	# Convert the Image into an ImageTexture, then apply it
	var image_tex : ImageTexture = ImageTexture.create_from_image(image)
	texture = image_tex
```

---

## Recommended Achievements for Bullet Hell Game

When you're ready to implement, consider these achievement ideas:

### Combat Achievements:
- **"First Blood"** - Kill your first enemy
- **"Exterminator"** - Kill 100 enemies
- **"Genocidal"** - Kill 1,000 enemies
- **"Sharpshooter"** - Achieve 90% accuracy in a run
- **"Pacifist"** (joke) - Die without firing a shot

### Survival Achievements:
- **"Survivor"** - Survive 5 minutes
- **"Hell Survivor"** - Survive 10 minutes
- **"Immortal"** - Complete a run without taking damage
- **"Dodging Bullets"** - Dodge roll 100 times
- **"Bomb Squad"** - Use 50 bombs

### Boss Achievements:
- **"Boss Slayer"** - Defeat your first boss
- **"Boss Rush"** - Defeat all bosses in one run
- **"Flawless Victory"** - Defeat a boss without taking damage

### Progression Achievements:
- **"Getting Started"** - Unlock your first weapon
- **"Arsenal"** - Unlock all weapons
- **"Fully Loaded"** - Max out all upgrades
- **"Wave Master"** - Reach wave 50

### Skill Achievements:
- **"Close Call"** - Activate graze bonus 100 times
- **"Speed Demon"** - Complete a run in under 10 minutes
- **"High Roller"** - Score 1,000,000 points

---

## Statistics to Track

### Basic Stats:
- **Total Enemies Killed** - Lifetime kill count
- **Total Deaths** - How many times player died
- **Total Playtime** - Hours played
- **Highest Wave Reached** - Best wave number
- **Highest Score** - All-time high score

### Combat Stats:
- **Total Shots Fired** - Bullets shot
- **Total Hits** - Bullets that hit
- **Accuracy** - Hit rate percentage
- **Total Damage Dealt** - Cumulative damage
- **Bombs Used** - Screen clears activated

### Boss Stats:
- **Bosses Defeated** - Total boss kills
- **Fastest Boss Kill** - Speed record

### Progression Stats:
- **Weapons Unlocked** - Collection progress
- **Upgrades Purchased** - Meta-progression
- **Runs Completed** - Successful runs

---

## Integration Timeline

### Month 6-7: Preparation
- Finalize achievement list (20-30 achievements)
- Design achievement icons (64x64 PNG)
- Set up stat tracking hooks in code
- Test achievement triggers locally

### Month 8: Steamworks Setup
- Pay $100 Steam Direct fee
- Register game on Steamworks Partner portal
- Get Steam App ID
- Configure achievement/stat schemas in Steamworks

### Month 9: Implementation
- Install GodotSteam plugin
- Implement steam_controller.gd as singleton
- Hook up achievement unlocks throughout game
- Connect stat tracking to gameplay events
- Test with real Steam App ID

### Month 10-11: Testing & Polish
- Beta test Steam features
- Verify all achievements unlock correctly
- Test stat tracking accuracy
- Ensure Steam Deck compatibility
- Test offline mode behavior

### Month 12: Launch Ready
- All Steam features verified
- Achievement icons uploaded
- Store page ready with Steam features highlighted
- Press materials mention Steam achievements

---

## Resources

**Official Documentation:**
- GodotSteam: https://godotsteam.com/
- GodotSteam Repository: https://codeberg.org/godotsteam/godotsteam (moved Dec 2025)
- GodotSteam Tutorials: https://godotsteam.com/tutorials/initializing/
- Steamworks API: https://partner.steamgames.com/doc/api
- Achievement Best Practices: https://partner.steamgames.com/doc/features/achievements
- Skillet Demo Project: https://codeberg.org/godotsteam/skillet (Free-to-play example)

**Video Tutorials:**
- "Godot + Steam tutorial" by BluePhoenixGames: https://www.youtube.com/watch?v=J0GrG-AffCI
- "Integrating Steamworks" by FinePointCGI: https://www.youtube.com/watch?v=VCwNxfYZ8Cw
- "Godot 4 Steam Integration" by Gwizz: https://www.youtube.com/watch?v=l0b5mh2HjyE

**Community:**
- GodotSteam Discord: https://discord.gg/SJRSq6K
- r/godot subreddit
- Steamworks Developer forums

---

## Important Notes

### 🚫 Common Mistakes to Avoid:
1. **Don't implement Steam too early** - Build the game first
2. **Don't use real App ID in source control** - Use 480 for development
3. **Don't forget to call `Steam.run_callbacks()`** - Required every frame (or enable embed callbacks)
4. **Don't call `requestCurrentStats()`** - Removed in SDK 1.61+ (auto-syncs now)
5. **Don't make achievement grinding tedious** - Keep them fun and achievable
6. **Don't ignore Steam Deck** - Test on Steam Deck or with Steam Deck mode
7. **Don't ship `steam_appid.txt`** - Valve recommends excluding from final build
8. **Don't assume Steam is always running** - Handle offline gracefully

### ✅ Best Practices:
1. **Always test with App ID 480 first** - Free testing app
2. **Enable logging in Project Settings** - Helps debug initialization issues
3. **Check initialization status code** - Handle Steam client not running gracefully
4. **Use Project Settings for App ID** - Cleaner than steam_appid.txt for Godot 4.x
5. **Make achievements visible** - Players should know what to unlock
6. **Balance difficulty** - Mix easy, medium, and hard achievements
7. **Track everything** - Stats are cheap, add lots of them
8. **Test offline mode** - Game should work without Steam connection
9. **Publish achievements in Steamworks** - They must be live to work with API
10. **Use `push_error()` for failures** - Better debugging than `print()`

---

## Final Checklist Before Launch

- [ ] All achievements tested and working
- [ ] Achievement icons uploaded (64x64 PNG)
- [ ] Statistics tracking verified
- [ ] Steam Deck compatibility tested
- [ ] Offline mode works gracefully
- [ ] Achievement descriptions are clear
- [ ] No placeholder App ID in shipping build
- [ ] Steam overlay works in-game
- [ ] Leaderboards configured (if applicable)
- [ ] Trading cards designed (optional, Phase 6)

---

**REMEMBER:** Focus on making the game fun first. Steam features are the polish on an already-great game, not a substitute for solid gameplay.

---

## Appendix: GodotSteam Version Changes

### GodotSteam 4.17 (Latest - Dec 2025)
- **For:** Godot 4.5.1
- **SDK:** Steamworks 1.63
- **Repository:** Moved to Codeberg (https://codeberg.org/godotsteam/godotsteam)
- **Changes:** MinGW compilation fixes, improved error handling

### GodotSteam 4.14 (Breaking Changes)
- **New:** Project Settings integration (App ID, auto-init, embed callbacks)
- **New:** Embedded callbacks support (set in Project Settings or pass to init)
- **Removed:** First boolean argument in `steamInit()/steamInitEx()` (auto-sync)
- **Removed:** `requestCurrentStats()` function (auto-syncs in SDK 1.61+)
- **Removed:** `current_stats_received` callback (stats available immediately)
- **Changed:** `steamInitEx()` first argument is now `app_id`, second is `embed_callbacks`

### Migrating from GodotSteam 3.27/4.13 or Earlier:
1. Remove `requestCurrentStats()` calls
2. Remove `current_stats_received` callback connections
3. Call `_load_achievements()` and `_load_stats()` directly after init
4. Update `steamInitEx()` call signature (no sync boolean, app_id first)
5. Add status code checking to initialization

---

**Last Updated:** December 25, 2025  
**GodotSteam Version:** 4.17 (Godot 4.5.1, SDK 1.63)  
**Status:** Reference Only - Implement in Phase 5
