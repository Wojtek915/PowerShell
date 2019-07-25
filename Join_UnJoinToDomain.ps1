Add-Computer -DomainName eu.mcc-hvac.in -Credential EU\poladmin
shutdown -r

Remove-Computer -UnjoinDomainCredential EU\poladmin
shutdown -r