#!/bin/sh
##################################################
#  Filename:  makedoc.sh
#  By:  Matthew Evans
#  See LICENSE.md for copyright information.
##################################################
#  Script to build project documentation and
#  update the main doc location.
##################################################

##################################################
#  Script variables
##################################################
PROJECTS_LOCATION="$HOME/Projects"
PROJECTS_LIST_FILE=".projectlist"
LOG_FILE=".makedoc_log"
DOC_GENERATOR="doxygen"
DOC_FOLDER="docs/html"
DOC_EXTENSION=".doxyfile"
SYNC_TOOL="rsync"
SYNC_PARAMETERS="-a"
DESTINATION_FOLDER="$HOME/Projects/wtfsystems.github.io/docs"
##################################################

##################################################
#  Start main script
##################################################
echo
echo "*** BUILDING PROJECT DOCUMENTATION ***"
echo

#  Check if an old log exists and remove
if [ -e "$PROJECTS_LOCATION/$LOG_FILE" ]; then
    echo "Deleting old log..."
    rm "$PROJECTS_LOCATION/$LOG_FILE"
fi

echo "Logging to $PROJECTS_LOCATION/$LOG_FILE"

#  Switch logging to file, redirect stdout and stderr
exec 3>&1 4>&2 &> "$PROJECTS_LOCATION/$LOG_FILE"

#  Read in the list of projects and process each
for PROJECT in $(cat "$PROJECTS_LOCATION/$PROJECTS_LIST_FILE"); do
    #  Run documentation generation for each project
    pushd $PROJECTS_LOCATION/$PROJECT
    "$DOC_GENERATOR" "$(find $PROJECTS_LOCATION/$PROJECT -maxdepth 1 -type f -name "*$DOC_EXTENSION")"
    popd
    #  Now copy over the files
    "$SYNC_TOOL" "$SYNC_PARAMETERS" "$PROJECTS_LOCATION/$PROJECT/$DOC_FOLDER/" "$DESTINATION_FOLDER/$PROJECT"
done

exec 1>&3 2>&4  #  Restore stdout and stderr
echo "Done!"
echo
