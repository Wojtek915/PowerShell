$ListFilesolderthat5yerasFI = Get-ChildItem -Recurse -Path P:\Public\FINANCE -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasHAS = Get-ChildItem -Recurse -Path 'P:\Public\HEALTH AND SAFETY' -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasHR = Get-ChildItem -Recurse -Path 'P:\Public\HUMAN RESOURCES' -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasIT = Get-ChildItem -Recurse -Path P:\Public\IT -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasUR = Get-ChildItem -Recurse -Path P:\Public\MAINTENANCE -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasMGT = Get-ChildItem -Recurse -Path P:\Public\MANAGEMENT -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasPRO = Get-ChildItem -Recurse -Path P:\Public\PRODUCTION -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasENG = Get-ChildItem -Recurse -Path 'P:\Public\PRODUCTION ENGINEERING' -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasPRJ = Get-ChildItem -Recurse -Path P:\Public\PROJECTS -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasPUR = Get-ChildItem -Recurse -Path P:\Public\PURCHASING -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasQU = Get-ChildItem -Recurse -Path P:\Public\QUALITY -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasSS = Get-ChildItem -Recurse -Path P:\Public\SALES -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasSOU = Get-ChildItem -Recurse -Path P:\Public\SOURCING -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name
$ListFilesolderthat5yerasWR = Get-ChildItem -Recurse -Path P:\Public\WAREHOUSE -File -Filter *  | ? {$_.LastAccessTime -lt (Get-Date).AddYears(-5) } | select -Property LastAccessTime, directory, name

out-string -InputObject $ListFilesolderthat5yerasFI -Width 100

$smtpServer="mcchvac-com0i.mail.protection.outlook.com" 
$expireindays = 15
$from = "Administrator IT <it@mcc-hvac.com>" 
$testing = "Enabled" # Set to Disabled to Email Users 
$testRecipient = "wojciech.konikiewicz@mcc-hvac.com" 
# 
################################################################################################################### 
 
# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 

# End System Settings 

 
# Email Subject Set Here 
$subject="Alert!" 
   
# Email Body Set Here, Note You can use HTML, including Images. 
$body = $ListFilesolderthat5yerasFI

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
 Send-Mailmessage -smtpServer $smtpServer -from $from -to $testRecipient  -subject "Raport! File" -body $body  -priority High -Encoding $textEncoding     
 
# End