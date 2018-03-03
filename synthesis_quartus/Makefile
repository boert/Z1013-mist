# makefile for command line driven synthesis with quartus
#
# Copyright (c) 2017 by Bert Lange
# https://github.com/boert/Z1013-mist
#
# This source file is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This source file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# necessary files:
#
# $(PROJECT).qsf		quartus project settings
# $(PROJECT).sdc		timing constraints
# pin_assignments.tcl	pin definitions for project
# verilog_files.tcl		manually maintained list for verilog files
# vhdl_files.tcl		automatically generated from vhdl_files.txt


PROJECT = top_mist_z1013
BLASTER_IDENT = "USB-Blaster(Altera)"

# for synthesis log
DATE = $(shell date +"%Y-%m-%d__%H_%M")
LOGFILE = synthesis_log_$(DATE).txt
export SYN_LOGFILE := $(LOGFILE)


all: 
	time --portability $(MAKE) timestamp vhdl_files.tcl map fit asm  catch     2>&1 | tee $(SYN_LOGFILE)

timestamp:
	##############################
	#
	# time stamp
	#
	test ! -f ../rtl/Makefile || make --directory ../rtl


vhdl_files.tcl: ../vhdl_files.txt
	##############################
	#
	# generate VHDL file list
	#
	grep --invert rtl_tb ../vhdl_files.txt | grep --invert "\#" | grep --invert "^$$" | awk '{printf "set_global_assignment -name VHDL_FILE ../%s  -library %s\n",$$2,$$1}' > vhdl_files.tcl




map:
	##############################
	#
	# mapper
	#
	quartus_map $(PROJECT)


fit:
	##############################
	#
	# fitter
	#
	quartus_fit $(PROJECT)


asm:
	##############################
	#
	# assembler
	#
	quartus_asm $(PROJECT)


tan:
	##############################
	#
	# timing analyzer
	#
	quartus_tan $(PROJECT)


catch:
	##############################
	#
	# catch generate core file
	#
	cp  output_files/$(PROJECT).rbf  core_z1013_64.rbf
	#
	# ready!
	#
	# copy you core to sd card or use
	# 'make program' if you have a Blaster cable
	#


program: 
	##############################
	#
	# program FPGA
	#
	quartus_pgm  -c $(BLASTER_IDENT)  -m jtag  -o "p;output_files/$(PROJECT).sof"


clean:
	##############################
	#
	# clean up
	#
	rm -rf ./output_files/
	rm -rf ./db/
	rm -rf ./incremental_db/
	rm -f vhdl_files.tcl
	rm -f $(PROJECT).qpf

.phony: all clean
