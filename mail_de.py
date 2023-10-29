#!/usr/bin/env python3
# GERMAN VERSION
# SCRIPT - MAINTENANCE

import sys
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# auto-configuration
# PLEASE DO NOT ADJUST THESE FIVE VARIABLES
sender_email = sys.argv[1] # SMTP E-mail sender
recipient_emails = sys.argv[2].split(',') # List of all recipients of the email
smtp_server = sys.argv[3] # SMTP Server
smtp_port = sys.argv[4] # SMTP Server Port
smtp_username = sys.argv[5] # SMTP E-mail sender
smtp_password = sys.argv[6] # SMTP App-Passwort
# ADJUSTMENTS CAN BE MADE FROM HERE

subject = 'Lorem ipsum'  # Email subject
# HTML message
html_content = """
<!DOCTYPE html>
<html>
<head>
<style>
table.top {
  padding: 25px;
  border: 1px solid black;
  background-color: #F4F6F7;
  margin: 0;
  border-radius: 10px;
  text-align: left;
  align-items: center;
  justify-content: center;
  width: 85%;
  margin-left: auto;
  margin-right: auto;
}

#status_link:link {
  color: #1F618D;
}

#status_link:visited {
  color: #1F618D;
}

#status_link:hover {
  color: red;
}

#status_link:active {
  color: green;
}

#mail_link:link {
  text-decoration: none;
  color: grey;
}

#mail_link:visited {
  text-decoration: none;
  color: grey;
}

#mail_link:hover {
  text-decoration: underline;
  color: blue;
}

#mail_link:active {
  text-decoration: underline;
  color: blue;
}
</style>
</head>
<body>
<table class="top">
  <tr>
    <td colspan="2" style="text-align: center; font-size: 25px; font-weight: 900; color: #229954">Easy Tec Services</td>
  </tr>
  <tr>
    <td colspan="2" style="text-align: center; font-size: 20px; font-weight: 800; color: #F5B041">STÖRUNG</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Sehr geehrte Damen und Herren,</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">wir möchten Sie darüber informieren, dass es derzeit zu einer Störung unserer Easy Tec Dienste gekommen ist. Unsere Techniker arbeiten bereits mit Hochdruck daran, das Problem zu identifizieren und zu beheben, um den reibungslosen Betrieb so schnell wie möglich wiederherzustellen.</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Wir bedauern die Unannehmlichkeiten, die Ihnen dadurch entstehen, und danken Ihnen für Ihr Verständnis.</td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Wir möchten Sie darauf hinweisen, dass Sie jederzeit den aktuellen Status zu sämtlichen Störungen auf unserer Statusseite einsehen können.</td>
  </tr>
  <tr>
    <td class="p1" colspan="2"><a id="status_link" href="https://status.statuspage.io/" target="_blank">Aktuelle Störungsinformationen anzeigen</a></td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Vielen Dank für Ihre Geduld und Kooperation.</td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Mit freundlichen Grüßen,<br>Ihr Easy Tec Services Team</td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" style="color: grey">
      <p class="p1">Diese E-Mail wurde automatisch versandt.<br>Bitte nicht auf diese E-Mail antworten.<br>Verwenden Sie für Fragen diese E-Mail: <a id="mail_link" href="mailto:mail@examle.com" target="_blank">mail@example.com</a></p>
    </td>
  </tr>
</table>
<div style="padding: 5px; text-align:center; color: grey; font-size: 10px">© 2023 Easy Tec</div>
</body>
</html>
"""

# Connect to the SMTP server
server = smtplib.SMTP(smtp_server, smtp_port)
server.starttls()
server.login(smtp_username, smtp_password)

for recipient_email in recipient_emails:
    # Create the MIME message
    msg = MIMEMultipart('alternative')
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = subject

    # Adding the HTML content to the message
    html_part = MIMEText(html_content, 'html')
    msg.attach(html_part)

    # Sending the e-mail
    server.sendmail(sender_email, recipient_email, msg.as_string())

# Close connection to SMTP server
server.quit()
