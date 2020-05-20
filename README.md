# m-overlay

![Image of M'Overlay](https://giant.gfycat.com/GraciousAlarmingAntbear.gif)

### Downloads

Latest downloads can be found in ![releases](https://github.com/bkacjios/m-overlay/releases)

### Usage

**You can change which controller port is displayed by using the scrollwheel.**

Extra game clones can be defined in "%APPDATA%/m-overlay/clones.lua"
If you are running from source via *run64*, it will load from "%APPDATA%/LOVE/m-overlay/clones.lua" instead..
To see an example of the clones.lua file format, please ![click here.](https://github.com/bkacjios/m-overlay/blob/master/source/modules/games/clones.lua)

This program hooks into Dolphin and reads from memory to show a players inputs. This could be an alternative to Nintendo-Spy for those who don't have the technical prowess of setting up an Arduino.

Currently this program will work on Melee (NTSC v1.02, PAL), 20XX, UnclePunch Training Mode, Brawl, Project M/P+, Need for Speed Underground 1/2, and The Legend of Zelda: The Wind Waker.

More games can be supported upon request!

To use with OBS, add a "Game Capture" source and use "capture specific window" select "[M'Overlay.exe]"
and be sure to check "Allow Transparency"

### Why?

This is the start of a bigger project to make a fully customizable stream overlay. I plan on making a overlay system to show different elements of the game, like percents, stocks, game time, an off camera minimap (like Smash Ultimate), APM meters, controller inputs, and much more. The plan is to have a plugin system for people to script their own overlay elements.

Example..

![M'Overlay Future Plans](https://i.imgur.com/wzRoxcD.png)
