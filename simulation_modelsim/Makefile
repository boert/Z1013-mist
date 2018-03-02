# simulation makefile
# set the simulation target here
#
#
# Copyright (c) 2017, 2018 by Bert Lange
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


TARGET=top_mist_tb
#TARGET=top_mist_sdram_tb
#TARGET=online_help_tb
#TARGET=osd_tb
#TARGET=scancode_tb
#TARGET=keyboard_matrix_tb
#TARGET=auto_start_tb
#TARGET=user_io_tb
#TARGET=addr_decode_tb
#TARGET=sdram_tb


LIBS = $(shell grep --invert "\#" ../vhdl_files.txt | cut --field=1 --delimiter=" " | sort | uniq)

compile: Makefile.msim 
	export ANAFLAGS="-quiet -2008 -bindAtCompile"; make -f Makefile.msim
	@echo "start simulation with make simulate"

simulate:
	export top=$(TARGET); \
	vsim -gui work.$(TARGET) -do run.do -l transcript.log

Makefile.msim: ../vhdl_files.txt
	@for LIB in $(LIBS); do vlib $$LIB; done
	vmk -t modelsim -O -w work -F ../vhdl_files.txt

clean:
	make -f Makefile.msim clean
	rm -f Makefile.msim
	rm -rf work
	rm -rf mist
	@for LIB in $(LIBS); do rm -rf $$LIB; done
	rm -f transcript.log
	rm -f vsim.wlf

show_libs:
	@echo $(LIBS)
