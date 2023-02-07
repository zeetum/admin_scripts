# Get all available software
$allApps = Get-WmiObject -query "select * from CCM_Application" -namespace "root\ccm\clientsdk"| Select Name, Id, Revision

# Uncomment to find the app you want
# $allApps | Format-Table -AutoSize

# Select the app
$NAPBrowser = $allApps | Where-Object -Property Name -Like "*NAPLAN Locked Down Browser*"

# Install the app
([wmiclass]'ROOT\ccm\ClientSdk:CCM_Application').Install($($NAPBrowser.Id), $($NAPBrowser.Revision), 1, 0, 'Normal', $False)
