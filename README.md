# Website Monitoring script 🖥️
![](https://img.shields.io/badge/Status-Finished-green)
![](https://img.shields.io/badge/Version-BETA-orange)

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
git clone https://github.com/EasyTecRepository/StatuspageAutomation.git
```

Change to folder
```
cd WebsiteMonitoring
```

Adjust all variables

| General Variables            | Description                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------ |
|UNRAID_ENVIRONMENT            | Specifys which system you are using - This is important for the colored display      |
|storage_file_path             | Specifies where your txt file is located (and what it is called)                     |
|statuspage_q                  | Specifies whether you want to use the function of Statuspage or not                  |
|discord_q                     | Specifies whether you want to use the function of Discord-Webhook or not             |
|email_q                       | Specifies whether you want to use the function of E-Mail-Notification or not         |
|DOMAIN_ARRAY                  | Here are all your website URL's                                                      |

| Statuspage.io Variables      | Description                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------ |
|AUTHKEY                       | Specifies which authentication token to use for statuspage                           |
|PAGEID                        | Specifies which pageid to use for statuspage                                         |
|SERVICE_ARRAY                 | Here are all your website names (You can choose what you call them)                  |
|COMPONENTID_ARRAY             | Specifies which ComponentID's on statuspage are affected                             |

| Discord Variables            | Description                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------ | 
|WEBHOOK                       | Specifies which webhook to use for discord                                           |
|DISCORD_USERNAME              | Specifies which username to use for your discord webhook                             |
|DISCORD_AVATAR_URL            | Specifies which URL to use for your discord webhook avatar                           |
|DISCORD_ERROR_TITLE           | Specifies which title you use for an error message                                   |
|DISCORD_OKAY_TITLE            | Specifies which title you use for an okay message                                    |
|DISCORD_FAILURE_TITLE         | Specifies which title you use for an failure message                                 |
|DISCORD_DEGRADED_TITLE        | Specifies which title you use for an degraded performance message                    |
|DISCORD_MAINTENANCE_TITLE     | Specifies which title you use for an maintenance message                             |
|DISCORD_ERROR_COLOR           | Specifies which color (html) you use for an error message                            |
|DISCORD_FAILURE_COLOR         | Specifies which color (html) you use for an failure message                          |
|DISCORD_OKAY_COLOR            | Specifies which color (html) you use for an okay message                             |
|DISCORD_DEGRADED_COLOR        | Specifies which color (html) you use for an degraded performance message             |
|DISCORD_MAINTENANCE_COLOR     | Specifies which color (html) you use for an maintenance message                      |
|DISCORD_AUTHOR                | Specifies which Author name you use for your discord webhook message                 |
|DISCORD_AUTHOR_URL            | Specifies which Author URL you use for your discord webhook message                  |
|DISCORD_AUTHOR_ICON           | Specifies which Author ICON (URL) you use for your discord webhook message           |
|DISCORD_ERROR_THUMBNAIL       | Specifies which Thumbnail (URL) you use for your discord webhook error message       |
|DISCORD_OKAY_THUMBNAIL        | Specifies which Thumbnail (URL) you use for your discord webhook okay message        |
|DISCORD_MAINTENANCE_THUMBNAIL | Specifies which Thumbnail (URL) you use for your discord webhook maintenance message |
|DISCORD_FAILURE_THUMBNAIL     | Specifies which Thumbnail (URL) you use for your discord webhook failure message     |
|DISCORD_SH_LOCATION           | Specifies under which path the discord.sh script is located                          |

| E-Mail Variables             | Description                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------ |
|SMTPFORM                      | Specifies which e-mail address is used as the sender address                         |
|SMTPTO                        | Specifies which e-mail addresses are used as recipient addresses                     |
|SMTPSERVER                    | Specifies which e-mail server with port is used                                      |
|SMTPUSER                      | Specifies which user is used as the sender (usually the sender email address)        |
|SMTPPASS                      | Specifies which SMTP password is used                                                |
|mailscript_path               | Specifies under which path your mail script is stored                                |

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
