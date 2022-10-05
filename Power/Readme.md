## Detect power failure
### With this script a power failure can be detected and saved to a .txt file.
**Please read these instructions carefully before running!**

## Preconditions
- [x] You have a Unraid server
- [x] You have a UPS (no matter which one)
- [x] You use the default setting to view the status of your UPS (-> SETTINGS; UPS Settings)

## Customize files
1. Go to the terminal of Unraid.
2. Change the directory with the following command: ```cd /usr/local/emhttp/plugins/dynamix.apcupsd/```
3. Create here with the following command the file, in which later the current status is written: ```nano CURRENT_UPS_STATUS.txt```
4. After the editor opens, copy and paste [this script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/CURRENT_UPS_STATUS.txt).
5. Now save the file with:
   - ```control+O``` & ```control+X``` (macOS)
   - ```STRG+O``` & ```STRG+X``` (Windows)
6. Now go to the ```/include``` directory with the following command: ```cd /include```
7. Open here the php file ```UPSstatus.php``` with: ```nano UPSstatus.php```
8. Go to line 52 here and paste [this script](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/raw_php.php). (Also look at the picture to complete the paragraph correctly!)
   - ⚠️: Please do not forget to adjust the placeholder "PLEASE_EDIT_ME.txt"!
   - ⚠️: This should normally be -if you haven't changed anything in your system paths- the following path: ```/usr/local/emhttp/plugins/dynamix.apcupsd/CURRENT_UPS_STATUS.txt```
![PICTURE UPSstatus_php](https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/images/UPSstatus.png)
9. This script must also be saved as before:
   - ```control+O``` & ```control+X``` (macOS)
   - ```STRG+O``` & ```STRG+X``` (Windows)
10. Now the setup of the process is complete. Now every (approx.) 2 seconds the current status of the UPS should be displayed in the file (See point 4).

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
