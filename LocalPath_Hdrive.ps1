$users=Get-ADUser -SearchBase 'OU=Users,OU=Olawa,DC=eu,DC=mcc-hvac,DC=in' -Filter *  -Properties *
foreach ($user in $users) {
if ($user.homeDirectory){
$user.name, 
$user.homeDirectory
$user | Set-ADUser -Clear homeDirectory
Write-host " -------"}


}
 