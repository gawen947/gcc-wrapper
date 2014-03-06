#!/bin/sh
# File: gcc-wrapper.sh
#  Time-stamp: <2012-09-13 20:10:01 gawen>
#
#  Copyright (C) 2011, 2012 David Hauweele <david@hauweele.net>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.

# GCC Wrapper so it always disable debug (and other things)

# No profil environment means we switch back to the default environment
[ -n "$GCC_PROFIL" ] || GCC_PROFIL="default"

# Load the selected profile from the two available configuration directories
path="$HOME/.config/gcc-wrapper/$GCC_PROFIL"
[ -r "$path" ] || path="/etc/gcc-wrapper/$GCC_PROFIL"
if [ ! -r "$path" ]
then
    echo "Cannot read $GCC_PROFIL profile..."
    exit 1
fi
. "$path"

# Replace arguments
newcmd="$GCC"
for arg in $*
do
    case $arg in
        --wrapper)
            echo "gcc-wrapper 0.3"
            echo "Copyright (C) 2011, 2012 David Hauweele <david@hauweele.net>"
            echo ""
            echo "Profil ($GCC_PROFIL) :"
            [ -z "$DESCRIPTION" ] || echo " $DESCRIPTION\n"

            if [ -x "$GCC" ]
            then
                gcc="$GCC"
            else
                gcc="$GCC (error)"
            fi
            echo " * GCC path      : $gcc"

            if [ -z "$MARCH" ]
            then
                march="*"
            else
                march="$MARCH"
            fi
            if [ -z "$MTUNE" ]
            then
                mtune="*"
            else
                mtune="$MTUNE"
            fi

            echo " * march/mtune   : $march/$mtune"

            if [ -z "$OLEVEL" ]
            then
                olevel="*"
            else
                olevel="$OLEVEL"
            fi
            echo " * OLevel        : $olevel"

            case $FRAME_POINTER in
                yes|true|1)
                    frame_pointer="yes";;
                no|false|0)
                    frame_pointer="no";;
                *)
                    frame_pointer="*";;
            esac
            echo " * Frame pointer : $frame_pointer"

            case $DEBUG in
                yes|true|1)
                    debug="yes";;
                no|false|0)
                    debug="no";;
                *)
                    debug="*";;
            esac
            if [ -z "$DEBUG_LEVEL" ]
            then
                debug="$debug"
            else
                debug="$debug ($DEBUG_LEVEL)"
            fi
            echo " * Debug         : $debug"

            if [ -n "$EXTRA" ]
            then
                echo " * Extra         : $EXTRA"
            fi

            exit 0
            ;;
        -march=*)
            if [ -z "$MARCH" ]
            then
                newcmd="$newcmd $arg"
            fi
            ;;
        -mtune=*)
            if [ -z "$MTUNE" ]
            then
                newcmd="$newcmd $arg"
            fi
            ;;
        O*)
            if [ -z "$OLEVEL" ]
            then
                newcmd="$newcmd $arg"
            fi
            ;;
        -fomit-frame-pointer)
            if [ -z "$FRAME_POINTER" ]
            then
                newcmd="$newcmd $arg"
            fi
            ;;
        -g*)
            if [ -z "$DEBUG" ]
            then
                newcmd="$newcmd $arg"
            fi
            ;;
        *)
            newcmd="$newcmd $arg";;
    esac
done

if [ -n "$MARCH" ]
then
    newcmd="$newcmd -march=$MARCH"
fi
if [ -n "$MTUNE" ]
then
    newcmd="$newcmd -mtune=$MTUNE"
fi
if [ -n "$OLEVEL" ]
then
    newcmd="$newcmd -$OLEVEL"
fi
if [ -n "$FRAME_POINTER" ]
then
    newcmd="$newcmd -fomit-frame-pointer"
fi
if [ -n "$DEBUG_LEVEL" ]
then
    debug_level="$DEBUG_LEVEL"
else
    debug_level="-g3 -ggdb"
fi
if [ -n "$DEBUG" ]
then
    case "$DEBUG" in
        yes|true|1)
            newcmd="$newcmd $debug_level";;
        no|false|0)
            newcmd="$newcmd -g0";;
        *)
            ;;
    esac
fi
if [ -n "$EXTRA" ]
then
    newcmd="$newcmd $EXTRA"
fi

# Finally execute the new command
exec $newcmd
