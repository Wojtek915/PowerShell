$dest=Get-ADUser -SearchBase '' -Filter *  -Properties * | select name, mobile, OfficePhone |sort -Property name
$dest | Export-Csv  -Path C:\PS1\mobile.csv  






