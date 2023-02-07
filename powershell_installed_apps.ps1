
$computer = $env:computername
$UninstallRegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"

foreach ($regArch in @('Registry32', 'Registry64')) {
    $HKLM = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer,$regArch)
    $UninstallRef = $HKLM.OpenSubKey($UninstallRegKey)
    $Applications = $UninstallRef.GetSubKeyNames()

    foreach ($App in $Applications) {
        $AppRegistryKey = $UninstallRegKey + "\\" + $App
        $AppDetails = $HKLM.OpenSubKey($AppRegistryKey)
        $AppGUID = $App
        $AppDisplayName = $($AppDetails.GetValue("DisplayName"))
        $AppVersion = $($AppDetails.GetValue("DisplayVersion"))
        $AppPublisher = $($AppDetails.GetValue("Publisher"))
        $AppInstalledDate = $($AppDetails.GetValue("InstallDate"))
        $AppUninstall = $($AppDetails.GetValue("UninstallString"))
        if(!$AppDisplayName) { continue }
        $OutputObj = New-Object -TypeName PSobject
        $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
        $OutputObj | Add-Member -MemberType NoteProperty -Name AppName -Value $AppDisplayName
        $OutputObj | Add-Member -MemberType NoteProperty -Name AppVersion -Value $AppVersion
        $OutputObj | Add-Member -MemberType NoteProperty -Name AppVendor -Value $AppPublisher
        $OutputObj | Add-Member -MemberType NoteProperty -Name InstalledDate -Value $AppInstalledDate
        $OutputObj | Add-Member -MemberType NoteProperty -Name UninstallKey -Value $AppUninstall
        $OutputObj | Add-Member -MemberType NoteProperty -Name AppGUID -Value $AppGUID
        if ($RegistryView -eq 'Registry32') {
            $OutputObj | Add-Member -MemberType NoteProperty -Name Arch -Value '32'
        } else {
            $OutputObj | Add-Member -MemberType NoteProperty -Name Arch -Value '64'
        }
        $OutputObj | Format-Table -AutoSize
    }
}

