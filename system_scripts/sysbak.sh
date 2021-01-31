#!/bin/sh
##################################################
#  Filename:  sysbak.sh
#  By:  Matthew Evans
#  See LICENSE.md for copyright information.
##################################################
#  System backup script
#
#  Requires:
#  https://www.passwordstore.org/
#  https://rclone.org/
##################################################

##################################################
#  Script variables
##################################################
#  Location to store backup config file (see below)
BACKUP_CONFIG_LOCATION="$HOME/.config/sysbak"
#  Name of backup config file
BACKUP_CONFIG_FILE="sysbak.config"
#  Root location to run backup from (should be home)
BACKUP_ROOT_LOCATION="$HOME"
#  Log for packages
PACKAGE_LOG_FILE="installed_packages.list"
#  Logging level (see rclone docs)
LOGGING_LEVEL="INFO"

##################################################
#  Import config
##################################################
#
#  Example:
#  BACKUP_NAME="backup" - rclone backup name to use
#  BACKUP_LIST=("test1" "test2") - list of folders to copy
#  RCLONE_PASSWORD_COMMAND="pass rclone/config" - passwordstore command
source "$BACKUP_CONFIG_LOCATION/$BACKUP_CONFIG_FILE"

#  If the proper variables were not configured, fail
CONFIG_FAILED="false"
if [ -z ${BACKUP_NAME+x} ] && [ -z ${BACKUP_LIST+x} ] && [ -z ${RCLONE_PASSWORD_COMMAND+x} ]; then
    echo "You must configure a backup to run!  See script for details."
    echo "Nothing has been backed up.  Exiting..."
    echo
    exit 1
fi

##################################################
#  Parse arguments
##################################################
DO_BACKUP_PACKAGE_LIST="false"
for ARGS in "$@"; do
    if [[ $ARGS =~ ^-.* ]]; then
        for i in $(seq 1 ${#ARGS}); do
            if [ "${ARGS:i-1:1}" = "p" ]; then
                DO_BACKUP_PACKAGE_LIST="true"
            fi
        done
    fi
done
##################################################

##################################################
#  Start main script
##################################################
echo
echo "*** RUNNING SYSTEM BACKUP ***"

#
if [ "$DO_BACKUP_PACKAGE_LIST" = true ]; then
    echo
    echo "Creating installed package list..."
    if [ -e "$BACKUP_CONFIG_LOCATION/$PACKAGE_LOG_FILE" ]; then
        echo "Deleting old list..."
        rm "$BACKUP_CONFIG_LOCATION/$PACKAGE_LOG_FILE"
    fi
    pacman -Q | awk '{print $1}' > "$BACKUP_CONFIG_LOCATION/$PACKAGE_LOG_FILE"
    echo "Installed package list created."
fi

#
echo
echo "Backing up user data..."
for ITEM in "${BACKUP_LIST[@]}"; do
    #  Saftey check for folder
    if [ -d "$BACKUP_ROOT_LOCATION/$ITEM" ]; then
        rclone --log-file="$BACKUP_CONFIG_LOCATION/$ITEM.log" --log-level "$LOGGING_LEVEL" --skip-links --ask-password=false --password-command "$RCLONE_PASSWORD_COMMAND" sync "$BACKUP_ROOT_LOCATION/$ITEM" "$BACKUP_NAME:$ITEM" &
    fi
done
echo "User data backup started.  Results will be written in the logs."

#  Record time script last executed
date > "$BACKUP_CONFIG_LOCATION"/lastrun

echo "System Backup Script Done!"
echo
