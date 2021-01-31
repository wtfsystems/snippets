#!/bin/sh
##################################################
#  Filename:  motd.sh
#  By:  Matthew Evans
#  See LICENSE.md for copyright information.
##################################################
#  MOTD Script
##################################################

#  Define some colors
FG_GREEN="\033[0;32m"
FG_RED="\033[0;31m"
FG_YELLOW="\033[0;33m"
BG_BLACK="\033[40m"
RESET="\033[0m"

#  Run neofetch, https://github.com/dylanaraps/neofetch
neofetch

#  Display last time backup was ran
if [ -e $HOME/.config/sysbak/lastrun ]; then
    LASTRUN=$( cat $HOME/.config/sysbak/lastrun )
    CURRENT_TIME=$( date +"%s" )
    BACKUP_TIME=$( date --date="$LASTRUN" +"%s" )
    ELAPSED_TIME=$( expr "$CURRENT_TIME" - "$BACKUP_TIME" )
    NUM_DAYS=$( expr "$ELAPSED_TIME" \/ 86400 )

    #  Format output
    if [ "$NUM_DAYS" -le 3 ]; then
        DISPLAY_COLOR="${FG_GREEN}"  # 1 - 3 days shows green
    elif [ "$NUM_DAYS" -gt 3 ] && [ "$NUM_DAYS" -lt 7 ]; then
        DISPLAY_COLOR="${FG_YELLOW}" # 4 - 6 days show yellow
    else
        DISPLAY_COLOR="${FG_RED}"    # 7+ days show red
    fi

    echo -e "${DISPLAY_COLOR}${BG_BLACK}System backup last ran on:  $LASTRUN${RESET}"
else
    echo "${FG_RED}${BG_BLACK}Warning! Could not determine when the last backup was executed!${RESET}"
fi
