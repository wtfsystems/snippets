#!/bin/bash
##################################################
#  Filename:  comment_updater.sh
#  By:  Matthew Evans
#  See LICENSE.md for copyright information.
##################################################
#
#  Script to update top comment in source code files.
#  Checks current working directory for a BACKUP_CONFIG_FILE.
#
#  WARNING:  Back up your code before running this!
#
##################################################
#
#  Configuration file format:
#
#  PROJECT_LOCATION - Location of soruce files.
#  SOURCE_EXTENSION - Source file extension.
#  COMMENT_START - Start of comment block.
#  COMMENT_END - End of comment block.
#  LINE_DELIMITER - Comment block line delimiter.
#  COMMENT_TEXT - Comment text to use as an array.  Each element is a line.
#
#  Special variables for COMMENT_TEXT:
#  $CURRENT_FILENAME - Filename of current source file. (fixing)
#  SYEAR - Current year.
#
##################################################

##################################################
#  Script variables
##################################################
#  Configuration filename
BACKUP_CONFIG_FILE="comment_updater.config"
#  Store current year YYYY format
YEAR="$(date +%Y)"

##################################################
#  Function to update all source files recursively
##################################################
process_update()
{
    echo ""
    echo "Entering $1"
    for i in "$1"/*; do
        #  If it's a file and ends in SOURCE_EXTENSION, process
        if [ -f "$i" ] && [[ "$i" =~ "$SOURCE_EXTENSION" ]]; then
            echo -n "Updating $i... "
            CURRENT_FILENAME="$(basename $i)" # Store short filename for comments

            #  First find the top comment block and remove it
            FIRST_LINE=$(grep -Fn -m 1 -h "$COMMENT_START" "$i")
            FIRST_LINE=${FIRST_LINE%:*}
            LAST_LINE=$(grep -Fn -m 1 -h "$COMMENT_END" "$i")
            LAST_LINE=${LAST_LINE%:*}
            sed -i "${FIRST_LINE},${LAST_LINE}d" "$i"

            #  Now create the new comment block at the top, writing backwards
            printf "%s\n" "$COMMENT_END" | cat - "$i" > temp && mv temp "$i"
            for ((curline=${#COMMENT_TEXT[@]}-1; curline>=0; curline--)); do
                printf "%s\n" "$LINE_DELIMITER${COMMENT_TEXT[curline]}" | cat - "$i" > temp && mv temp "$i"
            done
            printf "%s\n" "$COMMENT_START" | cat - "$i" > temp && mv temp "$i"

            echo "Done"
            #echo "$CURRENT_FILENAME"
        fi
        #  If a directory, enter and process
        if [ -d "$i" ]; then
            process_update "$i"
        fi
    done
}

##################################################
#  Start main script
##################################################
echo
echo "*** RUNNING COMMENT UPDATER ***"
echo

#  Make sure the BACKUP_CONFIG_FILE is in the working directory
if [ ! -e "$PWD/$BACKUP_CONFIG_FILE" ]; then
    echo "Cannot find $BACKUP_CONFIG_FILE, exiting..."
    echo
    exit 1
fi

#  Load config file from current folder
source "$PWD/$BACKUP_CONFIG_FILE"

#  Verify proper variables loaded from config
if [ -z ${PROJECT_LOCATION+x} ] && \
   [ -z ${SOURCE_EXTENSION+x} ] && \
   [ -z ${COMMENT_START+x} ] && \
   [ -z ${COMMENT_END+x} ] && \
   [ -z ${LINE_DELIMITER+x} ] && \
   [ -z ${COMMENT_TEXT+x} ]
then
    echo "You must configure the Comment Updater!  See script for details."
    echo "Nothing has been updated.  Exiting..."
    echo
    exit 1
fi

#  Run the update
process_update "$PROJECT_LOCATION"

echo
echo "Comment Updater script done!"
echo
