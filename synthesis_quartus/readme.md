to start a Quartus synthesis run yust call:
make

this will generate a new 'z1013.rbf' file

if you have a working Altera Blaster you can reprogram FPGA with:
make program


<file>                  <remarks>
-------------------     ---------
Makefile                all commands for synthesis
pin_assignments.tcl     pin descriptions of mist-board
top_mist_z1013.qsf      the Quartus project file
top_mist_z1013.sdc      timing constraints
z1013.rbf               resulting core file for sd card
