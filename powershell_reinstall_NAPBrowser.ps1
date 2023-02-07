#### Remove from computer  ####
$computer = $env:computername
$UninstallRegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"

foreach ($regArch in @('Registry32', 'Registry64')) {
    $HKLM = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer,$regArch)
    $UninstallRef = $HKLM.OpenSubKey($UninstallRegKey)
    $Applications = $UninstallRef.GetSubKeyNames()

    foreach ($App in $Applications) {
        $AppRegistryKey = $UninstallRegKey + "\\" + $App
        $AppDetails = $HKLM.OpenSubKey($AppRegistryKey)
        $AppDisplayName = $($AppDetails.GetValue("DisplayName"))
        $AppUninstall = $($AppDetails.GetValue("UninstallString"))
        
        if($AppDisplayName -like "NAP Locked down browser") { 
            $start = $AppUninstall.IndexOf("{")
            $stop = $AppUninstall.IndexOf("}")
            $UninstallString = $AppUninstall.substring($start, $stop - $start + 1)
            $arguments = " /x " + "'" + $UninstallString + "'"
            $command = "msiexec" + $arguments
            Invoke-Expression $command
        }
    }
}

#### Install from Software Centre ####
# Get all available software
$allApps = Get-WmiObject -query "select * from CCM_Application" -namespace "root\ccm\clientsdk"| Select Name, Id, Revision

# Select the app
$NAPBrowser = $allApps | Where-Object -Property Name -Like "*NAPLAN Locked Down Browser*"

# Install the app
([wmiclass]'ROOT\ccm\ClientSdk:CCM_Application').Install($($NAPBrowser.Id), $($NAPBrowser.Revision), 1, 0, 'Normal', $False)
