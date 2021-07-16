 Import-Module C:\Users\adminpol\Documents\WindowsPowerShell\PSWindowsUpdate
$body_fill = "Wszytskie komputery zgodne"
$OU="OU=Olawa,DC=eu,DC=mcc-hvac,DC=in"

$computers = Get-ADComputer -Filter *  -SearchBase $OU |sort -Descending | select -ExpandProperty Name 
$computers= 'OLANB023'
Foreach($computer in $computers)
    {
        $wsus = 'NULL'
        $wsus = Get-WUSettings  -ComputerName $computer
        If ($wsus.WUServer -notlike "http://192.168.85.31:8530" ) {write-host $wsus.ComputerName
        $body_fill = $body_fill + $wsus.ComputerName}
    }

      #send e-mail 

    ####################################################################################################
    ####################################################################################################
    ######################################################################################################
    ##################################################################################################

    
$smtpServer="mcchvac-com0i.mail.protection.outlook.com" 
$from = "Administrator IT <mcc-eu-wsr01@mcc-hvac.com>"  
 $emailaddress = "wojciech.konikiewicz@mcc-hvac.com" 




# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
 
 # Email Subject Set Here 
 $subject="Raport WSUS" 
   
 # Email Body Set Here, Note You can use HTML, including Images.
 


 $body = "$body_fill"
    
 
 # Send Email Message 
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject -body $body -BodyAsHtml -priority High  -Encoding $textEncoding    
 
  
 
# End