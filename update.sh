#!/bin/bash

# update.sh: Run updates using `dnf`, `flatpak`, and `snap`.
# Copyright (C) 2020  Fred Oaks

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
# details.

# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <https://www.gnu.org/licenses/>.

# SHELL OPTIONS ################################################################

set -e # exit on error
set -u # exit on undefined variable

# FUNCTIONS ####################################################################

# UPDATE FLATPAKS
function up_flatpaks
{
	if [[ ! $(which flatpak) ]]
	then
		echo "flatpak is not installed."
		exit 1
	else
		echo "UPDATING FLATPAKS:"
		flatpak update
	fi
}

# UPDATE SNAPS
function up_snaps
{
	if [[ ! $(which snap) ]]
	then
		echo "snap is not installed."
		exit 1
	else
		echo "UPDATING SNAPS:"
		snap refresh
	fi
}

# UPDATE RPMS
function up_rpms
{
	if [[ ! $(which dnf) ]]
	then
		echo "dnf is not installed. Trying yum..."
		if [[ ! $(which yum) ]]
		then
			echo "yum is not installed."
			exit 1
		else
			echo "UPDATING RPMS WITH YUM:"
			yum update
		fi
	else
		echo "UPDATING RPMS WITH DNF:"
		dnf update
	fi
}

# USAGE
function usage
{
	cat <<-EOF
	  Usage: update [-fsra]

	  -f : flatpaks
	  -s : snaps
	  -r : rpms
	  -a : all (default)
	EOF
}

# SCRIPT #######################################################################

# Fedora only
source /etc/os-release
if [[ $ID != "fedora" ]]
then
	echo "Only run this script on Fedora."
	exit 1
fi

# RUN AS ROOT
if [[ $EUID -ne 0 ]]
then
	echo "This script needs to be run as root."
	exit 1
fi

# Parse options 
# https://linuxconfig.org/how-to-use-getopts-to-parse-a-script-options
while getopts "fsrah" OPTION
do
	case $OPTION in
		f) CMDS[0]="up_flatpaks"
			;;
		s) CMDS[1]="up_snaps"
			;;
		r) CMDS[2]="up_rpms"
			;;
		a) CMDS=([0]="up_flatpaks" [1]="up_snaps" [2]="up_rpms")
			;;
		?) usage; exit 1
			;;
	esac
done

# no options does all
if [ $OPTIND -eq 1 ]
then
	CMDS=([0]="up_flatpaks" [1]="up_snaps" [2]="up_rpms")
fi

shift "$(($OPTIND -1))" # convention, not needed here

# Parse ${CMDS} array
for CMD in "${CMDS[@]}"
do
	$CMD
	echo
done

exit 0
