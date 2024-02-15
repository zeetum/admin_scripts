Import-Module .\Choose-ADOrganizationalUnit.psm1

# Site Details
$SiteCode = Read-Host "Site Code"
$Colour = "indigo"
$FullDomainName = $Colour + ".schools.internal"

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

# Write computer details to CSV with selected OU as the filename
Set-Content $FileName "Hostname, Model, Serial"
foreach ($result in $results) {
    $computerName = $result.Properties["name"][0]
    $serial = (Get-WmiObject -ComputerName $computerName win32_bios).Serialnumber
    $model = (Get-WmiObject -ComputerName $computerName win32_computersystem).Model
    $tpm = (Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm -ComputerName $computerName -ErrorAction Stop)

    if ($tpm) {
        $tpm_enablled = "true"
    } else {
        $tpm_enablled = "false"
    }

    Write-Host `n"Computer Name: $computerName"
    Write-Host "Model: "$model
    Write-Host "Serial: "$serial
    Write-Host "TPM Enabled: "$tpm_enablled
    Add-Content $FileName $computerName","$model","$serial
}
