# Kiosk Browser Script

## What is this and why?

<p>
Turn Google Chrome (enterprise) to kiosk browser!<br>This script was made at time when Microsoft didnt have support for kiosk mode in new edge browser!<br>This has quite a lot of problems compared to old edge kiosk mode, example you can access <b>chrome://</b> -sites, no ability to go back to home site (without closing browser or waiting restart timer).
</p>

---

## How to use?

<p>
<b>NOTE: USE EDGE KIOSK OVER THIS, this more like piece of concept!</b>

If you want to experiment with this (USE THIS WITH OWN AT YOUR OWN RISK):
- Run powershell via admin privileges
- Run <code>.\SetKioskMode.ps1</code> (may need to change execution policy)
</p>

---

## How to customize?

<p>

- Change website and windows login name in <b>config.psd1</b>
- Edit other files how you like

</p>

---

## File structure

<p>

- <b>modules</b>: Contains needed functions
- <b>resources</b>: Contains auto (re)start files for task sequence and chrome binary
- <b>scripts</b>: Contains function like creating new user and installing chrome
- <b>tools</b>: Contains dev tool to revert all changes made by this script
- <b>SetKioskMode.ps1</b> main file
- <b>config.psd1</b> config file
</p>