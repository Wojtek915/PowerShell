
$smtpServer="mcchvac-com0i.mail.protection.outlook.com" 
$from = "Administrator IT <mcc-eu-wsr01@mcc-hvac.com>"  
#$emailaddres = "wojciech.konikiewicz@mcc-hvac.com"
$files= 'files.txt'
# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
 
# Email Subject Set Here 
 $subject="Alert! Drive H. Your files will be deleted in 3 days" 
 
 
  

$path = 'P:\Home\'
$dirs = dir $path

foreach ($dir in $dirs){
$name = $dir.name
$pathusers = $path + $name 


#del 'WINDOWS'
$content = dir $pathusers


if ($content -eq $NULL) 
    {

write-host $name 'empty'
del $pathusers
 }
    else { write-host $name 'sent email'
$user = Get-aduser -Identity $name -Properties name,emailaddress 
$emailaddress = $user.emailaddress 
$nameuser = $user.name
$content  > $files 
# Email Body Set Here, Note You can use HTML, including Images. 
    $body =" 
    Dear $nameuser, 
    <p  style='font-family:calibri'> Alert! Drive H. Your files will be deleted in 3 days<br> 
    

	<p style='font-family:calibri'>On you drive H are some files, check that you have safe copy of files on your OneDrive<br>
        The files will be deleted in 3 days. List of the files in attachment. 
    </p>
	

	
	Drogi $nameuser, 
    <p  style='font-family:calibri'> Uwaga! Twoje pliki z dysku H zostaną usunietę w ciągu 3 dni<br> 
    Na twoim dysku H znajdują się pliki, upewnij się, że masz kopię plików na swoim OneDrivie. Lista plików w załączniku. 


    
	
	
    <p  style='font-family:calibri'>Administrator IT, <br> Thanks, <br>
    
      
    </P>" 
    
 
 # Send Email Message 
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject -body $body -BodyAsHtml -priority High  -Encoding $textEncoding   -Attachments $files  
 
  
 
# End


}
}