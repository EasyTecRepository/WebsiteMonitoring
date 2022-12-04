#!/bin/bash
# Copyright 2022, Easy Tec.
# export data to .txt file
# onBATTERY_run_immediately
# Please change the $filelocation, the $bash_script_location and the $php_script_location!

### BEGIN OF EDIT ###

# Location of .txt (log) file
filelocation="/mnt/user/add_your_share_name/CURRENT_UPS_STATUS.txt"

# Location of php order script
php_script_location="/mnt/user/add_your_share_name/statuspage_log_order.php"

# Location of bash script
bash_script_location="/boot/config/plugins/user.scripts/scripts/statuspage_automation_power/script"

# Run bash script for statuspage update
sudo bash "$bash_script_location"

# Write status to file
echo -e "On Battery" >> "$filelocation"

# Run php script to keep log in order
php "$php_script_location"

### END OF EDIT ###
