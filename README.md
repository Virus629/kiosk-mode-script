# Kiosk Browser Script

## What and why?

Turn Google Chrome (enterprise) to kiosk browser!

This script was made at time when Microsoft didn't have support for kiosk mode in new edge browser!

This has quite a lot of problems compared to old edge kiosk mode, example you can access **chrome://** -sites, no ability to go back to home site (without closing browser or waiting restart timer).

---

## How to use?

**NOTE: USE EDGE KIOSK OVER THIS! This is more like piece of concept script!**

If you want to experiment with this (USE WITH AT YOUR OWN RISK):

- Run powershell via admin privileges
- Change settings in ```config.psd1```
- Run ```.\SetKioskMode.ps1``` (may need to change execution policy)

---

## How to customize?

- Change website and windows login name in **config.psd1**
- Edit other files how you like

---

## File structure

- **modules**: Contains needed functions
- **resources**: Contains auto (re)start files for task sequence and chrome binary
- **scripts**: Contains function like creating new user and installing chrome
- **tools**: Contains dev tool to revert all changes made by this script
- **SetKioskMode.ps1** main file
- **config.psd1** config file

---

## TODO

- Fix xml string replace to use config file (like ChromeSessionRestart.xml)