$users= Get-ADUser -SearchBase '' -Filter {Enabled -EQ $false}  -Properties name, Enabled, LastlogonDate | where  {( ($_.lastlogonDate) -LT  ((Get-Date).AddDays(-90)))} 


$smtpServer="" 
$from = ""  
$emailaddress = "" 
# 

 



# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
 
# Email Subject Set Here 
 $subject="Raport Account Disabled more than 90 days" 
   
 # Email Body Set Here, Note You can use HTML, including Images.
 
 if ($users -eq $NULL ) 
    {
        $body_fill = "No accounts"
        
    }
    else {$body_fill = $users }
 

 $body = "$body_fill"
    
 
 # Send Email Message 
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject -body $body -BodyAsHtml -priority High  -Encoding $textEncoding    
 
  
 
# End
