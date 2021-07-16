$ou = 'OU=Olawa,DC=eu,DC=mcc-hvac,DC=in'

Import-Module ActiveDirectory 


 
Get-ADComputer -SearchBase $ou -Filter * | select Name | sort -Property Name
