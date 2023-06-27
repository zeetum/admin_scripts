Import-Module ActiveDirectory
Import-Module .\GetLoginCredentials.psm1
Import-Module .\Choose-ADOrganizationalUnit.psm1

# Get Credentials
$LoginCredentials = GetCredentials
$DCAddress = $LoginCredentials['DCAddress'].split(".")
$SiteCode = $DCAddress[0].substring(1, 4)
$Dom = $DCAddress[1]
$FullDomNme = $DCAddress[1..3] -join "."
$username = $LoginCredentials['username']
$password = $LoginCredentials['password']
$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $Dom\$username, (ConvertTo-SecureString $password -AsPlainText -Force)
Write-Host "Got credentials, trying to join domain"

# Choose OU
$LocalOU = "OU=School Managed,OU=Computers,OU=E"+$SiteCode+"S01,OU=Schools,DC="+$Dom+",DC=schools,DC=internal"
$OU = Choose-ADOrganizationalUnit -HideNewOUFeature -Domain $FullDomNme -Credential $creds -RootOU $LocalOU

# Retrieve all computer objects from the specified OU
$computers = Get-ADComputer -Filter * -SearchBase $OU
foreach ($computer in $computers) {
    $serial = (Get-WmiObject -ComputerName $computer.Name win32_bios).Serialnumber
    $model = (Get-WmiObject -ComputerName $computer.Name win32_computersystem).Model

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
    
    Write-Host "Serial: "$serial
}


