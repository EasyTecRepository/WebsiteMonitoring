#!/bin/bash
# Copyright 2022, Easy Tec.
# export data to .txt file
# onBATTERY
# Please change the $filelocation and the $php_script_location!

### BEGIN OF EDIT ###

# Location of .txt (log) file
filelocation="/mnt/user/add_your_share_name/CURRENT_UPS_STATUS.txt"

# Location of php order script
php_script_location="/mnt/user/add_your_share_name/statuspage_log_order.php"

# Write status to file
echo -e "On Battery \n" >> $"filelocation"

# Run php script to keep log in order
php $"php_script_location"

### END OF EDIT ###
