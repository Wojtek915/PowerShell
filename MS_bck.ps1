$smtpServer="mcchvac-com0i.mail.protection.outlook.com" 
$from = "Administrator IT <mcc-eu-wsr01@mcc-hvac.com>"  
 $emailaddress = "wojciech.konikiewicz@mcc-hvac.com" 
# 


# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
 
 # Email Subject Set Here 
 $subject="Backup MS" 
   
 # Email Body Set Here, Note You can use HTML, including Images.
 
 
   
 $body_fill = "Backup done"
        

 $body = "$body_fill"
    
 
 # Send Email Message 
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject -body $body -BodyAsHtml -priority High  -Encoding $textEncoding    
 
  
 
# End