# Z1013-mist                                                                                                                                                                         
The robotron Z1013 port for the mist board.


## Overview
This project emulates a robotron Z 1013 computer from 1984.
The original Z 1013 was sold as a kit (without case and power supply).

Contrary to the original 1 or 2 MHz we have 4 MHz clock frequency.
The emulation is equipped with 16 kByte RAM (0000 - 3FFF).
The second limit is the missing sound output.


## Getting started with Z1013.16

Just load the core (core_z1013.rbf) on your SD card and start the mist device.

### Overview of OSD options
| feature           | values
| ---               | ---
| Load *.Z80        | load from SD card
| scanlines         | on/off
| keyboard layout   | de/en
| online help       | on/off
| color scheme      | black&white or blue&yellow

When the Z1013 is running, you can load .z80-files via the OSD direct into the memory.
Name, type, load address, end address and start address of the loaded file is show on top of screen.
To start a loaded progem use *J <start address>*.
The original keyboard layout is a littlebit strange, so expect unusal keys to control the games.

The Z1013 core was developed and sucessfully tested with ARM firmware version ATH160123.



## Project structure

| Directory              | remark 
| ---                    | ---    
| contrib                | code used from other projects
| cores                  | stuff generated with MegaWizard
| library                | helper source code
| ROMs                   | monitor ROMs for Z1013
| rtl                    | source code
| rtl_tb                 | testbench source code
| simulation_modelsim    | simulation scripts
| synthesis_quartus      | synthesis scripts
| vhdl_files.txt         | list of used files (for simulation and synthesis)


to start a simulation switch to *simulation_modelsim* directory and do
**make**
**make simulate**

to generate *core_z1013.rbf* switch to *synthesis_quartus* directory and call
**make all**

to reprogram the FPGA (JTAG-Blaster required) just do
**make program**


## Known problems

- sometimes the keyboard hang, no idee why
  solution: reset core

- somtime keyboard start in hexadecimal mode, result in wired inputs
  solution: switch to alphanumeric mode with *A*

- top two pixel lines are not shown
  solution: use your illusion to complete the chars

- dowmload to memory work not with clock frequncy below 3 MHz
  solution: use 4 MHz core frequency


## Project history

original project by FPGAkuechle published 2012/2013 at mikrocontroller.net:
(https://www.mikrocontroller.net/articles/Retrocomputing_auf_FPGA)
https://www.mikrocontroller.net/articles/Retrocomputing_auf_FPGA

ported by abnomane to Altera, April 2013:
(http://abnoname.blogspot.de/2013/07/z1013-auf-fpga-portierung-fur-altera-de1.html)
http://abnoname.blogspot.de/2013/07/z1013-auf-fpga-portierung-fur-altera-de1.html

adapted to mist platform by Boert, released December 2017:
(https://github.com/boert/Z1013-mist)
https://github.com/boert/Z1013-mist
