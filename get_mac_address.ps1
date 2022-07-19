#https://www.microsoft.com/en-us/download/details.aspx?id=45520
#Import-Module ServerManager
#Import-Module activedirectory

$computers = Get-ADComputer -Filter * -SearchBase "OU=School Managed,OU=Computers,OU=E5070S01,OU=Schools,DC=indigo,DC=schools,DC=internal"

foreach ($comp in $computers) {
    #Add-Content C:\temp\test.txt 
    
    $adaptors = Get-NetAdapter -Name * -CimSession $comp.name
    Write-Host ($adaptors | Format-Table | Out-String)
    $info = $comp.name + "," + $adaptors.MacAddress
    Write-Host $info
}