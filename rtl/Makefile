# generate a vhdl string with actual time stamp
# 
# Copyright (c) 2018 by Bert Lange
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


DATE = $(shell LANG=C date +"%F %R")
VERSION = "v2018.02"


all: init_message_pkg.vhd

init_message_pkg.vhd:
	@rm -f $@
	@echo "package init_message_pkg is"                                         		>> $@
	@echo ""                                                                        	>> $@
	@echo "    constant init_message : string := \" Z1013.64  $(VERSION), $(DATE)\";" 	>> $@
	@echo "    constant version      : string := \"$(VERSION)\";"						>> $@
	@echo ""                                                                        	>> $@
	@echo "end package init_message_pkg;"                                           	>> $@


.PHONY: init_message_pkg.vhd
