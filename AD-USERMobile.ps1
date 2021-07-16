$dest=Get-ADUser -SearchBase 'OU=Users,OU=Olawa,DC=eu,DC=mcc-hvac,DC=in' -Filter *  -Properties * | select name, mobile, OfficePhone |sort -Property name
$dest | Export-Csv  -Path C:\PS1\mobile.csv  






