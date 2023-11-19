#### Get latest available from Software Centre ####
# Get all available software
$allApps = Get-WmiObject -query "select * from CCM_Application" -namespace "root\ccm\clientsdk"| Select Name, Id, Revision, IsMachineTarget

# Select the app
$Minecraft = $allApps | Where-Object -Property Name -Like "Minecraft Education"

#### Remove old version from computer  ####
$computer = $env:computername
$UninstallRegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"

# Search the currently installed apps and remove the NAP Locked down browser
foreach ($regArch in @('Registry32', 'Registry64')) {
    $HKLM = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer,$regArch)
    $UninstallRef = $HKLM.OpenSubKey($UninstallRegKey)
    $Applications = $UninstallRef.GetSubKeyNames()

    foreach ($App in $Applications) {
        $AppRegistryKey = $UninstallRegKey + "\\" + $App
        $AppDetails = $HKLM.OpenSubKey($AppRegistryKey)
        $AppDisplayName = $($AppDetails.GetValue("DisplayName"))
        $AppUninstall = $($AppDetails.GetValue("UninstallString"))
        
        # Find the NAP Browser to uninstall
        if($AppDisplayName -like "Minecraft Education") { 
            # If the current version isn't the same as the available, remove it
            if ($AppDetails.GetValue("DisplayVersion") -ne  $Minecraft.Revision) {
                Write-Host "Current Version:" $AppDetails.GetValue("DisplayVersion")
                Write-Host "Available Version" $Minecraft.Revision
                break

                $start = $AppUninstall.IndexOf("{")
                $stop = $AppUninstall.IndexOf("}")
                $UninstallString = $AppUninstall.substring($start, $stop - $start + 1)
                $arguments = " /qn /x " + "'" + $UninstallString + "'"
                $command = "msiexec" + $arguments
                Invoke-Expression "$($command) | Out-Null"
    
                Write-Host "Removed: "$AppDisplayName
            }
        }
    }
}

### Install the latest version ###
([wmiclass]'ROOT\ccm\ClientSdk:CCM_Application').Install($($Minecraft.Id), $($Minecraft.Revision), $($Minecraft.IsMachineTarget), 0, 'Normal', $False)

if ($Minecraft) {
    Write-Host "Installed: " $Minecraft.Name
}
pause
