
$smtpServer="nrksrv02.eu.mcc-hvac.in" 
$expireindays = 30
$from = "Administrator IT <it@mcc-hvac.com>" 
$emailaddress1 = "wojciech.konikiewicz@mcc-hvac.com"
$emailaddress2 = "dawid.koziol@mcc-hvac.com" 
$subject="Account Last logged " 
################################################################

# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 

# End System Settings 

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired 
Import-Module ActiveDirectory 
$users = get-aduser -filter * -SearchBase "OU=Users,OU=Olawa,DC=eu,DC=mcc-hvac,DC=in"  -properties Name, lastLogon |where {$_.Enabled -eq "True"} 
$today = [DateTime]::Now 
$time = 20
$clear="  "
$clear > C:\scripts\test.txt
$i=0

	foreach ($user in $users) 
	{
		$name = $user.Name
		$last =  $user.lastLogon
		$dt = [DateTime]::FromFileTime($last)
		$daylast=((Get-Date) - $dt).Days
		
		if($daylast -gt $time) 
		{
		 $i=$i+1
		 $suma= $name +" ---Last logged: "+ $dt + "<br>"
		 $suma >> C:\scripts\test.txt
		  
		
		  
		}	
	
	}
$suma = Get-Content C:\scripts\test.txt

# Email Body Set Here, Note You can use HTML, including Images. 

$body =" 
    Dear Administrator, 
    <p  style='font-family:calibri'> These accouts were used 30 day ago <br> </p>
	<p  style='font-family:calibri'> $suma <br> 	</p>
	<br>
	<p  style='font-family:calibri'>Administrator IT, <br> Thanks, <br>  </p>
	"

if ( $i -gt 0) 
    { 
        # Send Email Message 
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress1, $emailaddress2 -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding    
 
    } # End Send Message 
	
	
	
	
	

 
 