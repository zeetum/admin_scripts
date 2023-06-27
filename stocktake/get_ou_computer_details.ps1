Import-Module .\Choose-ADOrganizationalUnit.psm1
Import-Module .\GetLoginCredentials.psm1

#Get Login Details
$LoginCredentials = GetCredentials
$DCAddress = $LoginCredentials['DCAddress'].split(".")
$SiteCode = $DCAddress[0].substring(1, 4)
$Dom = $DCAddress[1]
$FullDomNme = $DCAddress[1..3] -join "."
$username = $LoginCredentials['username']
$password = $LoginCredentials['password']
$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $Dom\$username, (ConvertTo-SecureString $password -AsPlainText -Force)

# Choose OU
$LocalOU = "OU=School Managed,OU=Computers,OU=E"+$SiteCode+"S01,OU=Schools,DC="+$Dom+",DC=schools,DC=internal"
$OU = $(Choose-ADOrganizationalUnit -HideNewOUFeature -Domain $FullDomNme -Credential $creds -RootOU $LocalOU).DistinguishedName
Write-Host "OU: "$OU

# Find all computers in the OU
$ouEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$OU", $username, $password)
$searcher = New-Object System.DirectoryServices.DirectorySearcher($ouEntry)
$searcher.Filter = "(objectClass=computer)"
$results = $searcher.FindAll()

# Write computer details to console
Write-Host "Number of Computers: "$results.Count`n
foreach ($result in $results) {
    $computerName = $result.Properties["name"][0]
    Write-Host "Computer Name: $computerName"

    $serial = (Get-WmiObject -ComputerName $computerName win32_bios).Serialnumber
    $model = (Get-WmiObject -ComputerName $computerName win32_computersystem).Model

    # A switch to map computer model's to leases/owned etc
    switch ($model) {
        "20Q6S3N800" {
            Write-Host "Model: Lenovo Lease 15/16"
        }
        "20X2S3T200" {
            Write-Host "Model: Lenovo 2022 School Owned"
        }
        default {
            Write-Host "Model: "$model
        }
    }
    
    Write-Host "Serial: "$serial`n
}
