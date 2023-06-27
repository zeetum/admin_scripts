# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the distinguished name (DN) of the OU
$ouDN = "OU=YourOUName,DC=YourDomain,DC=com"

# Retrieve all computer objects from the specified OU
$computers = Get-ADComputer -Filter * -SearchBase $ouDN

# Iterate through each computer and display its name
foreach ($computer in $computers) {
    Write-Host "Computer Name: $($computer.Name)"
}
