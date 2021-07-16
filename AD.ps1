# Change users DisplayName

function Remove-StringLatinCharacters
{
    PARAM ([string]$String)
    [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String))
}

Import-Module ActiveDirectory 

$ous = ''

ForEach ($ou in $ous) {
 
$Users = Get-ADUser -SearchBase $ou -Filter {(GivenName -Like "*") -And (Surname -Like "*")} -Properties Enabled, DisplayName, GivenName, Surname, Name, DistinguishedName, ProxyAddresses, SamAccountName, userPrincipalName, StreetAddress,City,co,MobilePhone,mobile, company, extensionAttribute15 | Sort DisplayName
ForEach ($User In $Users)
{
    $DN = $User.DistinguishedName
    $First = $User.GivenName
    $Last = $User.Surname
    $CN = $User.Name
    $Display = $User.DisplayName
    $NewName = "$Last, $First"
	$SAM = $User.SamAccountName	
    $logonName = $User.UserPrincipalName.Substring(0,$User.UserPrincipalName.IndexOf("@"))
	$vbg = Remove-StringLatinCharacters("$logonName@")
	$mcc = Remove-StringLatinCharacters("$logonName@")
	$correctVBG = $false
	$correctMCC = $false
	$correctSIP = $false
	$proxyArray = @()
	$sipArray = @()
    
    $Phone=$User.MobilePhone
    $MPhone=$User.mobile
    $E15=$User.extensionAttribute15
    
    #Account Disabled
    If ($USer.enabled -eq $false) 
    {
        If ($ou.Contains("Disabled")) {
        Set-ADUser -Identity $SAM -office "ww"
        
        #Remove all group membership for user pawel.janowicz and ask for confirmation
        Get-ADUser -Identity $SAM -Properties MemberOf | ForEach-Object {
          $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false }
        #Remove manager
         Get-ADUser -Identity $SAM -Properties manager 
         Set-ADUser -Identity $DN -Manager $null
               

        Write-host $SAM
        }
    }
    else{


    # LastName, Name 
    If ($Display -ne $NewName) {Set-ADUser -Identity $DN -DisplayName $NewName
                                Write-Host "Old Name: $Display NewName: $NewName"}
   
   #EXTENSION ATTRIBUT 15
    If ($E15 -ne 'azureadsync') {Set-ADUser -Identity $DN -Replace @{extensionAttribute15="azureadsync"}
                                Write-Host "AzureSync: Updated "}
    # If ($CN -ne $NewName) {Rename-ADObject -Identity $DN -NewName $NewName}
    

    #Regional properiteis, depend on the location
    If ($ou.Contains("Olawa")) {
        Set-ADUser -Identity $SAM  -Replace @{c="PL";co="Poland";countryCode=616}
        Write-Host "$Display $mcc $vbg"
    }
    
    } 

    #If ($Last -eq "Winter") {

    #If ($logonName -ne $mcc) {
    #    Write-Host "$logonName  $mcc $logonName.SubString(0,5)"
    #}
	

#Proxy server
	ForEach ($proxy in $User.ProxyAddresses) {

If ($ou.Contains("Olawa")) {
        Write-Host "     $proxy"
    }
	
		If ($proxy.StartsWith("SMTP:") -AND $proxy -eq "SMTP:$($mcc)") {
                $correctMCC = $true
            }
		If ($proxy.StartsWith("smtp:") -AND $proxy -eq "smtp:$($vbg)") {
                $correctVBG = $true
            }
		If ($proxy.StartsWith("SIP:") -AND $proxy -eq "SIP:$($mcc)") {
                $correctSIP = $true
            }
		If ($proxy.StartsWith("SIP:","CurrentCultureIgnoreCase") -AND $proxy -cne "SIP:$($mcc)") {
                $correctSIP = $false
            }		
    }

	if (($correctMCC -eq $false) -or ($correctVBG -eq $false)){
		Write-Host "$($NewName): Need to be corrected"
		ForEach ($proxy in $User.ProxyAddresses) {
			If ($proxy.StartsWith("SMTP:") -OR $proxy.StartsWith("smtp:")) {
				#Write-Host $proxy
				$proxyArray += $proxy
				
			}
		}
		
		ForEach ($element in $proxyArray) {
			#Write-Host "    $element"
			$User.ProxyAddresses.remove($element)
			Set-ADUser -Identity $SAM -Remove @{proxyAddresses=$element}
		}
		
		Set-ADUser -Identity $SAM -Add @{proxyAddresses="SMTP:$($mcc)"}
		Set-ADUser -Identity $SAM -Add @{proxyAddresses="smtp:$($vbg)"}
	}
	
	if (($correctSIP -eq $false)){
		Write-Host "$($NewName): SIP need to be corrected"
		ForEach ($proxy in $User.ProxyAddresses) {
			If ($proxy.StartsWith("SIP:","CurrentCultureIgnoreCase")) {
				#Write-Host $proxy
				$sipArray += $proxy
				
			}
		}
		
		ForEach ($element in $sipArray) {
			Write-Host "    $element"
			#$User.ProxyAddresses.remove($element)
			Set-ADUser -Identity $SAM -Remove @{proxyAddresses=$element}
		}
		
		Set-ADUser -Identity $SAM -Add @{proxyAddresses="SIP:$($mcc)"}
	#}
	
	}

}
}
}
