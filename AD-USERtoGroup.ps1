$dest=Get-ADUser -SearchBase '' -Filter {Mobile -like '+48*'}  -Properties *
$dest
$groups= "MCC-EU-APP-Intune-Mobile-Users-Allow"
foreach ($group in $groups) {

$group

Add-ADGroupMember -Identity $group -Members $dest

Write-host " -------"}

