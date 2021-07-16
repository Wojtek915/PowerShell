
$smtpServer="mcchvac-com0i.mail.protection.outlook.com" 
$expireindays = 15
$from = "Administrator IT <it@mcc-hvac.com>" 
$testing = "Disabled" # Set to Disabled to Email Users 
$testRecipient = "wojciech.konikiewicz@mcc-hvac.com" 
# 
################################################################################################################### 
 
# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
$date = Get-Date -format ddMMyyyy 
# End System Settings 
$users_count =" "   
# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired 
Import-Module ActiveDirectory 
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false } 
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge 
 
# Process Each User for Password Expiry 
foreach ($user in $users) 
{ 
    $Name = $user.Name 
    $emailaddress = $user.emailaddress 
    $passwordSetDate = $user.PasswordLastSet 
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user) 
    $sent = "" # Reset Sent Flag 
    # Check for Fine Grained Password 
    if (($PasswordPol) -ne $null) 
    { 
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge 
    } 
    else 
    { 
        # No FGP set to Domain Default 
        $maxPasswordAge = $DefaultmaxPasswordAge 
    } 
 
   
    $expireson = $passwordsetdate + $maxPasswordAge 
    $today = (get-date) 
    $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days 
         
    # Set Greeting based on Number of Days to Expiry. 
 
    # Check Number of Days to Expiry 
    $messageDays = $daystoexpire 
 
    if (($messageDays) -gt "1") 
    { 
        $messageDays = "$daystoexpire"
    } 
    else 
    { 
        $messageDays = "0" 
    } 
 
    # Email Subject Set Here 
    $subject="Alert! Your password will expire in $messageDays days" 
   
    # Email Body Set Here, Note You can use HTML, including Images. 
    $body =" 
    Dear $name, 
    <p  style='font-family:calibri'> Your Password will expire in $messageDays days.<br> 
    To change your password press CTRL ALT Delete and chose Change Password <br>

	<p style='font-family:calibri'>Requirements for the password:</p>
	<ul style='font-family:calibri'>
	<li>Must not contain the user's account name or parts of the user's full name </li>
	<li>Must not be one of your last passwords</li>
	<li>Contain characters from three of the following four categories:
	<ul style='font-family:calibri'>
		<li>Uppercase characters (A through Z)</li>
		<li>Lowercase characters (a through z)</li>
		<li>Base 10 digits (0 through 9)</li>
		<li>Non-alphabetic characters (for example, !, $, #, %)</li>
	</ul></li>	
	</ul>

	
	Drogi $name, 
    <p  style='font-family:calibri'> Twoje hasło wygaśnie za $messageDays dni<br> 
    Aby zmienić hasło na komputerze naciśnij  CTRL ALT Delete i wybierz Zmień Hasło <br>

	<p style='font-family:calibri'>Wymagania do hasła:</p>
	<ul style='font-family:calibri'>
	<li>Nie może zawierać Twojej nazwy użytkownika, imienia lub nazwiska </li>
	<li>Nie może być jednym z Twoich ostatnich haseł</li>
	<li>Musi zawierać znaki z poniższych kategorii:
	<ul style='font-family:calibri'>
		<li>Wielka litera (A -Z)</li>
		<li>Mała litera (a - z)</li>
		<li>Cyfra (0 - 9)</li>
		<li>Znak specjalny (np., !, $, #, %)</li>
	</ul></li>
	</ul>
	
	
	
	
	
    <p  style='font-family:calibri'>Administrator IT, <br> Thanks, <br>  
    </P>" 
 
    
    # If Testing Is Enabled - Email Administrator 
    if (($testing) -eq "Enabled") 
    { 
        $emailaddress = $testRecipient 
    } # End Testing 
 
    # If a user has no email address listed 
    if (($emailaddress) -eq $null) 
    { 
        $emailaddress = $testRecipient     
    }# End No Valid Email 
 
    # Send Email Message 
    if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays)) 
    { 
        # Send Email Message 
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding    
        $users_count = $users_count + $emailaddress + "`n"
    } # End Send Message 
    
     
} # End User Processing 
 
Send-Mailmessage -smtpServer $smtpServer -from $from -to $testRecipient  -subject "Raport! Your password will expire" -body $users_count  -priority High -Encoding $textEncoding     
 
# End