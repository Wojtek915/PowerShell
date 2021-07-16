$OU="OU=Norrtalje,DC=eu,DC=mcc-hvac,DC=in"
$computers = Get-ADComputer -Filter *  -SearchBase $OU | select -ExpandProperty Name 
foreach ($computer in $computers)
{
Invoke-Command -ComputerName $computer -ScriptBlock { Get-ComputerInfo | select WindowsVersion }
}