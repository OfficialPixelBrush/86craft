
<p align="center">
  <img src="https://img.shields.io/github/issues-raw/OfficialPixelBrush/86craft"/>
  <img src="https://img.shields.io/github/last-commit/OfficialPixelBrush/86craft"/>
  <img src="https://img.shields.io/github/milestones/closed/OfficialPixelBrush/86craft"/>
</p>
<p align="center">
  <img src="https://img.shields.io/twitter/follow/pixel_brush?style=social"/>
</p>

86craft
=======
An 8086 Emulator for the Minecraft ComputerCraft Mod.
This Emulator has the goal to bring x86 based Software to ComputerCraft/Minecraft!

(I hereby also acknowledge the existance of lunatic86, so this'll just be a one-file based, worse, still maintained alternative.)

<p align="center">
  <img src="https://img.shields.io/badge/Written%20in-Lua-blue"/>
  <img src="https://img.shields.io/badge/Made%20for-ComputerCraft-lightgrey"/>
</p>
<p align="center">
  <img src="https://img.shields.io/github/languages/code-size/OfficialPixelBrush/86craft"/>
  <img src="https://img.shields.io/tokei/lines/github/OfficialPixelBrush/86craft"/>
</p>

Running
--------
`86craft` should be able to run both in-game and using any ComputerCraft Emulator.
I personally use [CCEmuX](https://emux.cc/).

Progress
--------
My progress can be viewed on [this Google Sheets Page](https://docs.google.com/spreadsheets/d/1eepaNIrG2MulV-X3MGXVQjvNjwEKsK_xqnjEliVDz-g/edit?usp=sharing) which I'll try to update semi-regularly.
A bit more than 20 instructions have been added thus far, out of the 225 the 8086/8088 actually uses.

Functions
---------
Right now the program can't handle more than a few basic MOV and ADD commands, this'll hopefully be changed with time.

Goals
---------
- Ability to fully emulate most 8086/8088 CPU instructions with decent accuracy
- Run text-based 8086/8088 Software
- Function at a decent speed, ideally at the same speed (or faster) as an 8086/8088
