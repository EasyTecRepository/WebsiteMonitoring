## Detect power failure
### With this script a power failure can be detected and saved to a .txt file.
**Please read these instructions carefully before running!**
**If you need help, check out this [YouTube video](https://www.youtube.com/EasyTec100).**

## Preconditions
- [x] You have a Unraid server
- [x] You have a UPS (no matter which one)
- [x] You use the default setting to view the status of your UPS (-> SETTINGS; UPS Settings)

**:warning: Note, however, that this adjustment in the system files is reset after EVERY UPDATE OF UNRAID!**

## Customize files
1. Go to the Unraid web interface. 
2. Go to ```ADD SHARE``` under ```SHARES```.
3. Enter a name of your choice. For example: ```statuspage_power```.
4. Enter a description of your choice. For example: ```Update files for status page power section```.
5. Click on ```DONE```.
6. Scroll down and select under ```SMB Security Settings``` ```Private``` from the ```Security``` drop-down menu.
7. click ```DONE``` again.
8. now open the terminal of Unraid.
9. Enter: ```cd /mnt/user/statuspage_power``` (instead of ```statuspage_power``` enter your chosen share name)
10. Enter now: ```nano CURRENT_UPS_STATUS.txt```.
11. After the editor opens, copy and paste [this script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/CURRENT_UPS_STATUS.txt).
12. Now save the file with:
   - ```control+O``` & ```control+X``` (macOS)
   - ```STRG+O``` & ```STRG+X``` (Windows)

13. Repeat the process with the following script:
   - Enter: ```nano keep_order_in_log.php``` and paste [this script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/keep_order_in_log.php).
   - Now save the file with:
      - ⚠️ Please do not forget to adjust the placeholder "$filelocation"!
      - ```control+O``` & ```control+X``` (macOS)
      - ```STRG+O``` & ```STRG+X``` (Windows)
14. Now change the path with ```cd``` and ```cd /etc/apcupsd/```.
15. Enter: ```nano onbattery```.
16. Add [this script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/insert_onbattery.sh) to line 18.
17. Save the script with:
   - ```control+O``` & ```control+X``` (macOS)
   - ```STRG+O``` & ```STRG+X``` (Windows)
   - ⚠️ Please do not forget to adjust the placeholder "$filelocation" and "$php_script_location"!
   - Note that you only need to insert the part between ```### BEGIN OF EDIT ###``` and ```### END OF EDIT ###```. (Also see picture) ![PICTURE Unraid_shell_onbattery_insert](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/images/Unraid_shell_onbattery_insert.png)
18. Enter: ```nano offbattery```.
19. Add [this script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/insert_offbattery.sh) to line 18.
20. Save the script with:
   - ```control+O``` & ```control+X``` (macOS)
   - ```STRG+O``` & ```STRG+X``` (Windows)
   - ⚠️ Please do not forget to adjust the placeholder "$filelocation" and "$php_script_location"!
   - Note that you only need to insert the part between ```### BEGIN OF EDIT ###``` and ```### END OF EDIT ###```. (Also see picture) ![PICTURE Unraid_shell_offbattery_insert](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/images/Unraid_shell_offbattery_insert.png)
   - 
21. Ready. Every time the power goes out, or when it comes back, one of the scripts (onbattery or offbattery) is executed and thus the new part that writes the current status to the log (See point 11).

## Include statuspage (with script)
After the files have been adjusted, the script can now be set up, which will later flow out the file created above and report the status to Statuspage if necessary.
1. Go under Unraid to: (-> SETTINGS; User Scripts; ADD NEW SCRIPT)
2. Give the script a name (example: ```statuspage_automation``` )
3. Click ```Enter``` or go to ```OK```.
4. Now click on the ```cogwheel``` above the script you just created and select ```EDIT SCRIPT```.
5. In the editor, paste [this script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/poweroutage_check.sh).
6. Adjust **all variables!** In total you have to adjust **11** variables!
7. Then click on ```SAVE CHANGES```.
8. Now we just need to define how often the script should be executed. 
   - **I recommend running the script at least every 15 minutes and at most every 5 minutes.**
   - To do this, go to the ```Schedule Disabled``` dropdown field (in user scripts) under the script you just created. Select ```custom``` here.
      - Enter here now:
      - ```*/5 * * * *``` (all 5 minutes)
      - ```*/15 * * * *``` (all 15 minutes)
9. After these steps, an error should now be reported on the statuspage every time the power fails. (Provided that an internet connection is available).
10. If you want the script to start immediately when a power failure is detected, replace the [previously inserted script part](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/insert_onbattery.sh) in ```onbattery``` with [this one](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/insert_onbattery_run_immediately.sh) (see also picture). ![PICTURE Unraid_shell_onbattery_insert_new](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/images/Unraid_shell_onbattery_insert_new.png)
11. Do the same with the ```offbattery``` [script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/insert_offbattery_run_immediately.sh). (See also picture) ![PICTURE Unraid_shell_offbattery_insert_new](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/images/Unraid_shell_offbattery_insert_new.png)
12. The automatic query via cron does not have to be set up, nevertheless the [poweroutage_check](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/poweroutage_check.sh) script must be created as just described in point [Include statuspage (with script)](https://github.com/EasyTecRepository/StatuspageAutomation/edit/main/Power/Readme.md#include-statuspage-with-script).
Don't forget to adjust all variables! The variable ```bash_script_location``` is the path that is in the description of a created userscript in Unraid. Don't forget to write ```/script``` behind this variable, otherwise the script can't be executed! (Example see picture)
