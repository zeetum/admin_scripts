# Wireless network information
$creds = Get-Credential
$SSID = "WIRELESS-5"
$Username = $creds.username
$Password = $creds.GetNetworkCredential().Password
$ProfileName = "DoEWireless-5"

# Create an XML string for the profile
$xmlProfile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$ProfileName</name>
    <SSIDConfig>
        <SSID>
            <name>$SSID</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>true</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$Password</keyMaterial>
            </sharedKey>
        </security>
        <OneX>
            <cacheUserData>true</cacheUserData>
            <maxDelayUntilReauth>0</maxDelayUntilReauth>
        </OneX>
        <AuthMethod>
            <EAP>
                <type>PEAP</type>
                <EAPType>
                    <Type>25</Type>
                    <VendorId>0</VendorId>
                    <VendorType>0</VendorType>
                </EAPType>
                <InnerEAP>
                    <Type>26</Type>
                    <VendorId>0</VendorId>
                    <VendorType>0</VendorType>
                </InnerEAP>
                <Credentials>
                    <Username>$Username</Username>
                    <Password>$Password</Password>
                </Credentials>
            </EAP>
        </AuthMethod>
    </MSM>
</WLANProfile>
"@

# Save XML string to a temporary file
$tempFilePath = "$env:TEMP\$SSID.xml"
$xmlProfile | Out-File -FilePath $tempFilePath -Force

Write-Output $tempFilePath

# Create a wireless network profile using netsh
netsh wlan add profile filename=$tempFilePath interface="WiFi" user=current

Write-Output "1"

# Set the profile order to prioritize the added profile
netsh wlan set profileorder name=$ProfileName interface="WiFi" priority=1

Write-Output "2"

# Connect to the wireless network using the specified profile
netsh wlan connect name=$ProfileName

Write-Output "3"

# Wait for a few seconds to allow the connection to establish
Start-Sleep -Seconds 10

# Check if the connection was successful
$connectedNetwork = Get-NetConnectionProfile | Where-Object {$_.Name -eq $SSID}

if ($connectedNetwork) {
    Write-Host "Connected to $($connectedNetwork.Name)"
} else {
    Write-Host "Failed to connect to the network"
}

# Remove the temporary file
# Remove-Item -Path $tempFilePath -Force
