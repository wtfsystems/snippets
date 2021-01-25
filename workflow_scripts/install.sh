#!/bin/sh
##################################################
#  Filename:  install.sh
#  By:  Matthew Evans
#  See LICENSE.md for copyright information.
##################################################
#  Script to manage other workflow scripts
#
#  Creates symbolic links to workflow scripts
#  Run with --uninstall to remove links instead
#  Run with --ask to confirm each file
##################################################

##################################################
#  Script variables
##################################################
DEFAULT_INSTALL_LOCATION="/usr/local/bin"
SCRIPT_FILE_NAMES=("makebak.sh" "makedoc.sh")
RUN_UNINSTALL=false
ASK_EACH_FILE=false
##################################################

##################################################
#  Function to create a confirmation prompt
#  First argument used as display text
#  Accepts ENTER, "Y" or "y" then returns 1 (true)
#  All other input returns 0 (false)
##################################################
confirm_prompt()
{
    read -p "$1 [Y/n]? " CONFIRM_RESULT
    CONFIRM_RESULT=${CONFIRM_RESULT:-true}
    if [ "$CONFIRM_RESULT" = true -o "$CONFIRM_RESULT" = "Y" -o "$CONFIRM_RESULT" = "y" ]; then
        return 1
    fi
    return 0
}
##################################################

##################################################
#  Parse arguments
##################################################
for ARGS in "$@"; do
    #  Check if uninstall flag passed
    if [ "$ARGS" = "--uninstall" ]; then
        RUN_UNINSTALL=true
    fi
    #  Check if ask flag passed
    if [ "$ARGS" = "--ask" ]; then
        ASK_EACH_FILE=true
    fi
done
##################################################

##################################################
#  Start main script
##################################################
echo
echo "*** Workflow script management ***"
echo

#  Get install location
read -p "Install location [$DEFAULT_INSTALL_LOCATION]: " INSTALL_LOCATION
#  If install location null, use default
INSTALL_LOCATION=${INSTALL_LOCATION:-$DEFAULT_INSTALL_LOCATION}
echo

#  Get the scripts' location
CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$RUN_UNINSTALL" = true ]; then  #  Run uninstall
    echo "Removing scripts from '$INSTALL_LOCATION'..."

    #  Iterate over script filenames, deleting symlinks
    for FILENAME in "${SCRIPT_FILE_NAMES[@]}"; do
        if [ "$ASK_EACH_FILE" = true ]; then
            confirm_prompt "Do you want to remove '${FILENAME%.*}' from '$INSTALL_LOCATION'"
            CONFIRM_PROMPT_RESULT=$?
            if [ "$CONFIRM_PROMPT_RESULT" -eq 0 ]; then
                continue
            fi
        fi
        rm $INSTALL_LOCATION/${FILENAME%.*}
    done
else  #  Run install
    echo "Installing scripts to '$INSTALL_LOCATION'..."

    #  Iterate over script filenames, creating symlinks for each
    for FILENAME in "${SCRIPT_FILE_NAMES[@]}"; do
        if [ "$ASK_EACH_FILE" = true ]; then
            confirm_prompt "Do you want to install '${FILENAME%.*}' to '$INSTALL_LOCATION'"
            CONFIRM_PROMPT_RESULT=$?
            if [ "$CONFIRM_PROMPT_RESULT" -eq 0 ]; then
                continue
            fi
        fi
        ln -s $CURRENT_DIR/$FILENAME $INSTALL_LOCATION/${FILENAME%.*}
        chmod u+x $INSTALL_LOCATION/${FILENAME%.*}
    done
fi

echo "Done!"
echo
