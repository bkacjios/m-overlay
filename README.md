[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VS3S4WHQMZEP6&currency_code=USD&source=url)

# m-overlay

![Image of M'Overlay](https://thumbs.gfycat.com/GraciousAlarmingAntbear-size_restricted.gif)

### Downloads

Latest downloads can be found in [releases](https://github.com/bkacjios/m-overlay/releases)

### Slippi replays

In order to view the inputs of a player when watching a slippi replay or mirring a game from a Wii, please enable "Slippi Replay" in the options menu!

### Usage

- **You can change which controller port is displayed by using the scrollwheel or pressing 1-4 on the keyboard.**
- Access a settings menu by pressing the escape key
- Set what port is selected when opening with the launch command (--port=N or --port N)

![Port Commandline](https://i.imgur.com/f9AkS2q.png)

To use with OBS, add a "Game Capture" source and use "capture specific window" select "[M'Overlay.exe]"
and be sure to check "Allow Transparency"

![OBS Settings](https://i.imgur.com/n6xrM3b.png)

If you encounter the overlay freezing when adding it to OBS, try enabling "SLI/Crossfire Capture Mode (Slow)"

### Linux Users

If you want to run this on linux, install [love2d 11.3](https://love2d.org/) via your package manager or with their provided [AppImage](https://github.com/love2d/love/releases/download/11.3/love-11.3-x86_64.AppImage). You will then be able to run the latest .love file under [releases](https://github.com/bkacjios/m-overlay/releases).

NOTE: In order for the love to read dolphins memory, you will need to either run the .love file as root, or set the love binary file to have ptrace access with `sudo setcap cap_sys_ptrace=eip /usr/bin/love`

### How?

This program hooks into Dolphin and reads from memory to show a players inputs. This could be an alternative to Nintendo-Spy for those who don't have the technical prowess of setting up an Arduino.

Currently this program will work on Melee (NTSC v1.02, PAL), 20XX, UnclePunch Training Mode, Brawl, Project M/P+, Need for Speed Underground 1/2, The Legend of Zelda: The Wind Waker, and Metroid Prime.

More games can be supported upon request!

### Why?

This is the start of a bigger project to make a fully customizable stream overlay. I plan on making an overlay system to show different elements of the game, like percents, stocks, game time, an off camera minimap (like Smash Ultimate), APM meters, controller inputs, and much more. The plan is to have a plugin system for people to script their own overlay elements.

Example..

![M'Overlay Future Plans](https://i.imgur.com/wzRoxcD.png)
