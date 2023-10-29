#!/bin/bash
# ENGLISH VERSION
# SCRIPT - MALFUNCTION
# PLEASE DO NOT ADJUST THESE FIVE VARIABLES
SMTPFROM="$1"
SMTPTO="$2"
SMTPSERVER="$3"
SMTPUSER="$4"
SMTPPASS="$5"
# ADJUSTMENTS CAN BE MADE FROM HERE
MESSAGEBODY=$(cat <<EOF
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
    <td colspan="2" style="text-align: center; font-size: 20px; font-weight: 800; color: #F5B041">INCIDENT</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Dear Sir or Madam,</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">we would like to inform you that there is currently a failure in our Easy Tec services. Our technicians are already working at full speed to identify and fix the problem in order to restore smooth operation as soon as possible.</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">We are sorry for any possible trouble this may cause you and thank you for your understanding.</td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">We would like to point out that you can view the current status of all faults on our status page at any time.</td>
  </tr>
  <tr>
    <td class="p1" colspan="2"><a id="status_link" href="https://status.statuspage.io/" target="_blank">View current status</a></td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Thank you for your patience and cooperation.</td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="p1" colspan="2">Yours sincerely,<br>Your Easy Tec Services Team</td>
  </tr>
  <tr>
    <td class="p2" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" style="color: grey">
      <p class="p1">This email was sent automatically.<br>Please do not reply to this email.<br>For questions, use this email: <a id="mail_link" href="mailto:mail@example.com" target="_blank">mail@example.com</a></p>
    </td>
  </tr>
</table>
<div style="padding: 5px; text-align:center; color: grey; font-size: 10px">© 2023 Easy Tec</div>
</body>
</html>
EOF
)

SUBJECT="Current malfunction of Easy Tec services"

# SEND E-MAIL(s)
for recipient in "${SMTPTO[@]}"; do
    sendEmail -f "$SMTPFROM" -t "$recipient" -u "$SUBJECT" -m "$MESSAGEBODY" -s "$SMTPSERVER" -xu "$SMTPUSER" -xp "$SMTPPASS"
done
