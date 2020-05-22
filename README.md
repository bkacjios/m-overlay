# m-overlay

![Image of M'Overlay](https://giant.gfycat.com/GraciousAlarmingAntbear.gif)

### Downloads

Latest downloads can be found in ![releases](https://github.com/bkacjios/m-overlay/releases)

### Slippi replays

By default, this program will NOT work with project Slippi replays or Wii to Dolphin game mirroring, since all controller data is stripped out of memory. However, using a modified version of the program will allow it to work.

You can download that ![here](https://github.com/bkacjios/m-overlay/releases/tag/slippi-test-v1.2)

### Usage

**You can change which controller port is displayed by using the scrollwheel.**

To use with OBS, add a "Game Capture" source and use "capture specific window" select "[M'Overlay.exe]"
and be sure to check "Allow Transparency"

If you encounter the overlay freezing when adding it to OBS, try enabling "SLI/Crossfire Capture Mode (Slow)"

### How?

This program hooks into Dolphin and reads from memory to show a players inputs. This could be an alternative to Nintendo-Spy for those who don't have the technical prowess of setting up an Arduino.

Currently this program will work on Melee (NTSC v1.02, PAL), 20XX, UnclePunch Training Mode, Brawl, Project M/P+, Need for Speed Underground 1/2, The Legend of Zelda: The Wind Waker, and Metroid Prime.

More games can be supported upon request!

### Why?

This is the start of a bigger project to make a fully customizable stream overlay. I plan on making an overlay system to show different elements of the game, like percents, stocks, game time, an off camera minimap (like Smash Ultimate), APM meters, controller inputs, and much more. The plan is to have a plugin system for people to script their own overlay elements.

Example..

![M'Overlay Future Plans](https://i.imgur.com/wzRoxcD.png)
