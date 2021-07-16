$ous = 'OU=Users,OU=Olawa,DC=eu,DC=mcc-hvac,DC=in'

Import-Module ActiveDirectory 

ForEach ($ou in $ous) {
 
$Users = Get-ADUser -SearchBase $ou -Filter {(GivenName -Like "*") -And (Surname -Like "*") }  -Properties mobile, telephoneNumber
ForEach ($User In $Users)
{
   #mobile phone
   # if ( $User.mobile -like "+48*") {write-host $User.mobile, $User.Name}
   

   #phone
   if ( $User.telephoneNumber -like "+*") {write-host $User.telephoneNumber,',', $User.Name}

   }
   }