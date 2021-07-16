# Install required modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module pswindowsupdate -force
Import-Module PSWindowsUpdate -force
# End installing required modules
# SMTP Email Configuration Settings
$from = "PDQ@mcc-hvac.com"
$to = "wojciech.konikiewicz@mcchvac.com"
$smtp = "mcchvac-com0i.mail.protection.outlook.com"
$sub = "$($env:COMPUTERNAME): Windows Updates Installed and Rebooted"
$sub1 = "$($env:COMPUTERNAME): No Updates Needed"
$body = "Server Windows Update Report"
$body1 = "No new updates found."

# Define the email attachment report
$attachement = "c:\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log"

# Start WSUS updates
$updates = Get-wulist -verbose
$updatenumber = ($updates.kb).count
if ($updates -ne $null) {
Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot 
# Now let's send the email report
Send-MailMessage -To $to -From $from -Subject $sub -Body $body   -SmtpServer $smtp  -BodyAsHtml 
}
else
{ 
Send-MailMessage -To $to -From $from -Subject $sub1 -Body $body1  -SmtpServer $smtp  -BodyAsHtml  
}