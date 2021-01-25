#!/bin/sh
##################################################
#  Filename:  makebak.sh
#  By:  Matthew Evans
#  See LICENSE.md for copyright information.
##################################################
#  Script to create a local backup of the
#  current directory.
#
#  Will ignore files or folders listed in a
#  local .bakignore file
#  Note that only top level items will be ignored
##################################################

##################################################
#  Script variables
##################################################
BACKUP_FOLDER="bak"
IGNORE_FILE=".bakignore"
##################################################

##################################################
#  Function to check if a file or folder is listed
#  in the IGNORE_FILE
#
#  First argument is the file or folder to check for
#  Returns 1 (true) if found
#  Returns 0 (false) if not found
##################################################
skip_check()
{
    #  See if the IGNORE_FILE exists
    if [ ! -e "$IGNORE_FILE" ]; then
        return 0
    fi
    #  Now check the file
    for IGNOREME in $(cat "$IGNORE_FILE"); do
        if [ "$IGNOREME" = "$1" ]; then
            return 1
        fi
    done
    return 0
}
##################################################

##################################################
#  Start main script
##################################################
echo
echo "*** RUNNING FOLDER BACKUP ***"
echo

#  Get current working path
CURRENT_PATH="$PWD"

if [ -d "$BACKUP_FOLDER" ]; then
    echo "Deleting old backup..."
    rm -rf "$BACKUP_FOLDER"
fi

echo "Creating backup..."
mkdir "$BACKUP_FOLDER"

shopt -s dotglob
for BACKUP_ITEM in "$CURRENT_PATH"/*; do
    skip_check "${BACKUP_ITEM#$CURRENT_PATH/}"
    SKIP_CHECK_RESULT=$?
    #  Skip the item if it's either the backup folder itself or in the IGNORE_FILE
    if [ "$SKIP_CHECK_RESULT" -eq 1 -o "$BACKUP_ITEM" = "$CURRENT_PATH/$BACKUP_FOLDER" ]; then
        continue
    fi
    cp -r "${BACKUP_ITEM#$CURRENT_PATH/}" "$BACKUP_FOLDER/${BACKUP_ITEM#$CURRENT_PATH/}"
done

echo "Done!"
echo
