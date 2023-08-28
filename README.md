# Website Monitoring script 🖥️

This is an **easy way** to see the current status of your services, **no matter** where you are.

Welcome to this repository!
This repository contains a script with which you can query the current status of your websites.
You can choose which functions you want to have.

Available features: **statuspage.io** , **Discord Webhook** , **E-Mail-Notification**

If you need a detailed tutorial on setting it up, feel free to [check out this video on YouTube](https://youtube.com/EasyTec100)!

## Requirements
This git tool is needed to bring this repository to your system.
```
sudo apt install git
```

This tool can parse, filter and transform JSON data. Mostly already preinstalled.
```
sudo apt install jq
```

## Get started
Run the following command
```
https://github.com/EasyTecRepository/StatuspageAutomation.git
```

Change to folder
```
cd WebsiteMonitoring
```

Run script
```
bash statuscheck.sh
```
or (if you use my other scripts in this repository (e.g. network_status.sh))
```
bash network_status.sh
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
