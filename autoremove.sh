#!/bin/bash

# autoremove.sh: Autoremove unused packages using `dnf`, `flatpak`, and `snap`.
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

# AUTOREMOVE FLATPAKS
function ar_flatpaks
{
	if [[ ! $(which flatpak) ]]
	then
		echo "flatpak is not installed."
		exit 1
	else
		echo "REMOVING UNUSED FLATPAKS:"
		flatpak remove --unused
	fi
}

# AUTOREMOVE SNAPS
function ar_snaps
{
	if [[ ! $(which snap) ]]
	then
		echo "snap is not installed."
		exit 1
	else
		echo "REMOVING DISABLED SNAPS:"
		# No built in option.
		snap list --all | awk '$6 ~ /disabled/ {print $1, $3}' |
    		while read snapname revision; do
        		snap remove "$snapname" --revision="$revision"
    		done
	fi
}

# AUTOREMOVE RPMS
function ar_rpms
{
	if [[ ! $(which dnf) ]]
	then
		echo "dnf is not installed. Trying yum..."
		if [[ ! $(which yum) ]]
		then
			echo "yum is not installed."
			exit 1
		else
			echo "REMOVING UNUSED RPMS WITH YUM:"
			yum autoremove
		fi
	else
		echo "REMOVING UNUSED RPMS WITH DNF:"
		dnf autoremove
	fi
}

# USAGE
function usage
{
	cat <<-EOF
	  Usage: autoremove [-fsra]

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
		f) CMDS[0]="ar_flatpaks"
			;;
		s) CMDS[1]="ar_snaps"
			;;
		r) CMDS[2]="ar_rpms"
			;;
		a) CMDS=([0]="ar_flatpaks" [1]="ar_snaps" [2]="ar_rpms")
			;;
		?) usage; exit 1
			;;
	esac
done

# no options does all
if [ $OPTIND -eq 1 ]
then
	CMDS=([0]="ar_flatpaks" [1]="ar_snaps" [2]="ar_rpms")
fi

shift "$(($OPTIND -1))" # convention, not needed here

# Parse ${CMDS} array
for CMD in "${CMDS[@]}"
do
	$CMD
	echo
done

exit 0
