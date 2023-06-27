Import-Module .\Choose-ADOrganizationalUnit.psm1

# Site Details
$SiteCode = "5070"
$Colour = "indigo"
$FullDomainName = "indigo.schools.internal"

# Choose OU
$LocalOU = "OU=School Managed,OU=Computers,OU=E"+$SiteCode+"S01,OU=Schools,DC="+$Colour+",DC=schools,DC=internal"
$OUDetails = Choose-ADOrganizationalUnit -HideNewOUFeature -Domain $FullDomainName -RootOU $LocalOU
$OU = $OUDetails.DistinguishedName
$FileName = $OUDetails.Name + ".csv"
Write-Host `n"OU: "$OU

# Find all computers in the OU
$ouEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$OU")
$searcher = New-Object System.DirectoryServices.DirectorySearcher($ouEntry)
$searcher.Filter = "(objectClass=computer)"
$results = $searcher.FindAll()
Write-Host "Number of Computers: "$results.Count`n

# Write computer details to console
Set-Content $FileName "Hostname, Model, Serial"
foreach ($result in $results) {
    $computerName = $result.Properties["name"][0]
    $serial = (Get-WmiObject -ComputerName $computerName win32_bios).Serialnumber
    $model = (Get-WmiObject -ComputerName $computerName win32_computersystem).Model

    Write-Host `n"Computer Name: $computerName"
    Write-Host "Model: "$model
    Write-Host "Serial: "$serial

    Add-Content $FileName $computerName","$model","$serial
}
