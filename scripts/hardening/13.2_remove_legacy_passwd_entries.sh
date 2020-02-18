#!/bin/bash

#
# harbian audit 7/8/9  Hardening
#

#
# 13.2 Verify No Legacy "+" Entries Exist in /etc/passwd File (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

FILE='/etc/passwd'
RESULT=''

# This function will be called if the script status is on enabled / audit mode
audit () {
    info "Checking if accounts have a legacy password entry"
    if grep '^+:' $FILE -q; then
        RESULT=$(grep '^+:' $FILE)
        crit "Some accounts have a legacy password entry"
        crit $RESULT
    else
        ok "All accounts have a valid password entry format"
    fi
}

# This function will be called if the script status is on enabled mode
apply () {
    if grep '^+:' $FILE -q; then
        RESULT=$(grep '^+:' $FILE)
        warn "Some accounts have a legacy password entry"
        for LINE in $RESULT; do
            info "Removing $LINE from $FILE"
            delete_line_in_file $FILE $LINE
        done
    else
        ok "All accounts have a valid password entry format"
    fi
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_ROOT_DIR" ]; then
     echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
     echo "Cannot source CIS_ROOT_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r $CIS_ROOT_DIR/lib/main.sh ]; then
    . $CIS_ROOT_DIR/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
