# StatuspageAutomation
# Automation script of current website statuses using statuspage.io API

Welcome to this repository!
This repository contains a script with which you can query the current status of your websites.
These are loaded directly into the statuspage.io overview via API, so you can see from anywhere if one of your services has errors or even crashed completely.

If you need a detailed tutorial on setting it up, feel free to [check out this video on YouTube](https://youtube.com/EasyTec100)!

## Install
Install git tool
```
sudo apt install git
```

If you also want to use Discord Notifications, this tool must also be installed (otherwise this tool is not needed):
```
sudo apt install jq
```

## Run
Change to folder
```
cd StatuspageAutomation
```

Run any script ("network_status.sh" or "statuspage_extended.sh")
```
bash statuspage_extended.sh
```
or
```
bash network_status.sh
```
or
```
bash statuspage_discord_extended.sh
```

## Discord.sh setup (optional)
1. Enter the following in the (Unraid) terminal: 
```
cd /boot/config/plugins/user.scripts/scripts
```
2. Use the following command to create the discord.sh file:
```
nano discord.sh
```
3. Copy this [script from ChaoticWeg](https://github.com/ChaoticWeg/discord.sh/blob/master/discord.sh) and paste it into the discord.sh file.
4. Save it and exit the editor with:
   - ```control+O``` & ```control+X``` (macOS)
   - ```STRG+O``` & ```STRG+X``` (Windows)
5. Ready. Now the status page script should be able to send a notification via a Discord webhook (If you set the variables in the script correctly).

## Automation
This can also be automated with the Cron service, I recommend running this every 5 minutes.
And this is how it works:
Install (In most cases this two commands are not needed)
```
sudo apt-get update
```
and
```
sudo apt-get install cron
```

Start Crontab
```
crontab -e
```
Select ```1```

Go to the very bottom of the open file and paste the following:
```
*/5 * * * * /example/path/script.sh
```
(At ```/example/path/script.sh``` you have to enter the **_entire_** path! You can find out the whole path for example with the command ```pwd```)

After the correct command is in the crontab, the file can be saved and exited with ```control+O``` & ```Enter``` and ```control+X``` (Mac). (Under Windows: ```CTRL+O``` & Enter and ```CTRL+X```)
