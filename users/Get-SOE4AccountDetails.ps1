#Written by Radia Lyon in 2023 for use on the DoE SOE4 network.
#This script uses the adsisearcher type accelerator, so it will run on client PCs and doesn't need the AD modules to be used.
#Verbose mode will return the search results for each domain as it tries them, and will tell you if it found the user or if it didn't, and return an error if it wasn't found in any of them
#Running without the -Verbose flag will just return the user and their details if it was found, and return an error if there was no user found

class Staff
{
    [string]$Username = $SearchResult.properties.samaccountname
    [string]$Name = $SearchResult.properties.givenname
    [string]$Surname = $SearchResult.properties.sn
    [string]$MainSite = $SearchResult.properties.department
    [string]$LastLogonTime = (Get-Date ([datetime]::fromfiletime($($SearchResult.properties.lastlogontimestamp))) -format D)
    [string]$StaffFolderPathway = $SearchResult.properties.homedirectory
    [string]$Domain = $domain
    [string]$AccountType = $SearchResult.properties.company
}


#This function does a search for domains in AD, and then builds a list of the subdomains (the coloured domain names) by saving the subrefs property from the schools.internal domain that the search finds as a list
#The function then returns only the colour domains, which are items 0 through 7 of the search to omit the DnsZone and Configuration domains, which won't contain users.

Function Get-SOE4Domains 
{
    $DomainSearch = New-Object adsisearcher
    $DomainSearch.Filter="(objectCategory=domain)"
    $DomainSearch.SearchRoot = "LDAP://dc=schools,dc=internal"
    $DomainSearch.SearchScope = "Subtree"
    $DomainList = ($DomainSearch.FindAll()).Properties.subrefs
    return $DomainList[0..7]
}

#This is the main function, and it takes one parameter, $Username.
#Once you type or pipe it a username, it starts running an adsisearcher query for each of the domain colours until it finds a result, then it writes said result as an output.
#This means (in theory) it should work for staff that are added to schools across multiple domains.
function Get-SOE4AccountDetails 
{
    [CmdletBinding()]
        Param
            (
            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true)]
            [string]
            $Username
            )
        foreach($domain in Get-SOE4Domains)
        {
         $ADSearcher = New-Object adsisearcher
         $ADSearcher.Filter="(&(objectClass=User)(name=$Username))"
         $ADSearcher.SearchRoot = "LDAP://"+$domain+""
         $ADSearcher.SearchScope = "Subtree"
         $SearchResult = $ADSearcher.FindOne()
            if($SearchResult.count -eq 1)
                {
                Write-Verbose "User $($Username) found in $($domain)."
                [Staff]$account1 = [Staff]::new()
                [string]$Username = $SearchResult.properties.samaccountname
                [string]$Name = $SearchResult.properties.givenname
                [string]$Surname = $SearchResult.properties.sn
                [string]$MainSite = $SearchResult.properties.department
                [string]$LastLogonTime = Get-Date ([datetime]::fromfiletime($($SearchResult.properties.lastlogontimestamp))) -format D
                [string]$StaffFolderPathway = $SearchResult.properties.homefolder
                [string]$Domain = $domain
                [string]$AccountType = $SearchResult.properties.company
                Write-Output $account1
                }
            else
                {
                write-Verbose "No user with username $($Username) could be found in $($domain)."
                }
        }
        if($account1 -eq $null)
            {
            Write-Error "No user with username $($Username) found in any domains." -Category ObjectNotFound
            }
}
