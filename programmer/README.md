# Breadboard EEPROM Programmer

- [Breadboard EEPROM Programmer](#breadboard-eeprom-programmer)
- [Introduction](#introduction)
- [Credits](#credits)
- [Datasheets](#datasheets)
- [References](#references)

![](../programmer/schematics/EEPROM-Programmer.png)

# Introduction

This subproject is an EEPROM Programmer on a breadboard using:
- a Sparkfun Arduino Pro Micro
- two SN74HC595 Serial-In Parallel-Out (SIPO) Shift Registers, to minimize the pin needed on the Arduino.
- a AT28C256 Parallel EEPROM

# Credits

Here are some awesome projects from which I have taken inspiration and code:

- [Build an Arduino EEPROM programmer](https://www.youtube.com/watch?v=K88pgWhEb1M) by Ben Eaters
  - [Source code](https://github.com/beneater/eeprom-programmer#arduino-eeprom-programmer)

# Datasheets

- [SNx4HC595 8-Bit Shift Registers With 3-State Output Registers](../datasheets/SN74HC595.pdf)

# References

- [Pro Micro & Fio V3 Hookup Guide - learn.sparkfun.com](https://learn.sparkfun.com/tutorials/pro-micro--fio-v3-hookup-guide/hardware-overview-pro-micro)