# BuckshotRouletteMods
More mods for Buckshot Roulette by Mike Klubnika, based on AGO061's BRML.

* BugFixes:
  * Slow motion persists when resetting after winning a round.
  * Paper towel dispenser has profanity. ;)
  * Double or Nothing score is random.
  * Final Double or Nothing score displays before lerping.
* FullCustomizer: Adds a full suite of multi-round customization options (see guide).
* KeyboardShortcuts: Adds ESC (pause), F2/F3 (volume down/up), F4 (fullscreen), and all available waiver signature keys as shortcuts.
* SplashScreen: Increases the resolution of the splash screen.
* VirtualReality Adds VR support.

ModLoader: https://github.com/AGO061/BuckshotRouletteModLoader/releases/tag/1.1.1

Mods are confirmed to work with the latest version of the BRML.

## Compatibility
All MSLaFaver mods are compatible with each other. Below is a chart of other mods tested for compatibility.
| Mod | [ITR-SmarterDealer-1.1.0](https://github.com/ITR13/BuckshotRouletteMods/releases/latest) | [EmK530-NativeResolution-2.1.0](https://github.com/EmK530/BRMods/tree/main/BRML/NativeResolution/Release) | [StarPanda-ChallengePack-1.3.0](https://github.com/StarPandaBeg/ChallengePack/tree/main) | [AGO061-OpenGL3Fix-1.1.0](https://github.com/AGO061/BuckshotRouletteModLoader/blob/main/mods/OpenGL3Fix.md) |
| --- |:---:|:---:|:---:|:---:|
| [MSLaFaver-BugFixes-1.2.1](https://github.com/MSLaFaver/BuckshotRouletteMods/releases/latest) | ✅ | ✅ | ❓ | ❓ |
| [MSLaFaver-FullCustomizer-1.0.0](https://github.com/MSLaFaver/BuckshotRouletteMods/releases/latest) | ℹ️ | ✅ | ❓ | ❓ |
| [MSLaFaver-KeyboardShortcuts-1.2.2](https://github.com/MSLaFaver/BuckshotRouletteMods/releases/latest) | ✅ | ✅ | ❓ | ❓ |
| [MSLaFaver-SplashScreen-1.0.0](https://github.com/MSLaFaver/BuckshotRouletteMods/releases/latest) | ✅ | ✅ | ❓ | ❓ |
| [MSLaFaver-VirtualReality-0.0.1](https://github.com/MSLaFaver/BuckshotRouletteMods/releases/latest) | ✅ | ✅ | ❓ | ❓ |

## VirtualReality Setup
The VirtualReality mod uses an OpenXR runtime such as SteamVR to run Buckshot Roulette in full VR. To use the mod, download `override.cfg` and place it in the same folder as the patched .exe file. The game should then be able to work with an OpenXR compatible HMD (head-mounted display). The main menu can be skipped with spacebar, and the base game uses the mouse for interaction.

This mod was tested on a Quest 2 with a link cable connecting to SteamVR. For endless mode, either use the FullCustomizer mod or click to the left after the pill bottle is selected Please report any issues encountered.

## FullCustomizer Setup
The FullCustomizer mod can be configured using the file located at `C:\Users\Username\AppData\Roaming\Godot\app_userdata\Buckshot Roulette - BRML 1.1.1\configs\MSLaFaver-FullCustomizer\user.json`. In-game configuration is planned for a future version.

The following values can be adjusted:
* `main`: Settings that cannot be customized per round.
  * `carryover` (int): Binary representation of carryover round behavior. Default: `4`
  * `don` (bool): Automatically activate Double-or-Nothing (endless) mode. Default: `false`
  * `enable` (bool): Turn on customizer. Affects every option except `main.swap_dealer_mesh`. Default: `false`
  * `multi_round_config` (bool): Determine behavior of rounds 2 and 3. If false, use round 1 customization; otherwise, use unique customization. Default: `false`
  * `name` (String): Pre-enter the player’s name. Default: `""`
  * `swap_dealer_mesh` (bool): Return the Dealer’s friendly face between rounds. Default: `true`
* `customizer`: Parent for individual round customization settings.
  * `round1`, `round2`, and `round3`: Individual round customization settings. `round2` and `round3` are only used if `main.multi_round_config` is set to `true`.
    * `items_on` (bool): Turn items on or off for the round. Default: `true`
    * `items_even` (bool): Dealer and player get the same items if possible. Default: `false`
    * `items_item_enabled` (bool): Enables specific item. Replace `item` in the property name with the appropriate item name.
    * `items_item_weight` (int): Changes the probability of the item to appear. Default: `10`
    * `items_total_min` and `items_total_max` (int): Minimum and maximum number of items. Defaults: `1` and `4`
    * `items_visible` (bool): Hides the Dealer’s items. Default: `false`
    * `shells_live_percentage_min` and `shells_live_percentage_max` (float): Minimum and maximum percentage total shells that are live shells, rounding up (rounding down when both set to `0.5`). Defaults: `0.5` and `0.5`
    * `shells_scripted` (bool): Uses the non-endless mode scripted rounds. Default: `false`
    * `start_load` (int): Determines who starts each load. Default: `0`
      * `0`: Whoever started the round starts every load.
      * `1`: Loads alternate between the player and the Dealer.
      * `2`: Load is started by whoever’s turn was not last.
    * `start_round` (int): Determines who starts the round. Default: `0`
      * `0`: Player
      * `1`: Dealer
      * `2`: Random
