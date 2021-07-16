$dest=Get-ADUser -SearchBase '' -Filter {Mobile -like '+48*'}  -Properties *
$dest
$groups= ""
foreach ($group in $groups) {

$group

Add-ADGroupMember -Identity $group -Members $dest

Write-host " -------"}

