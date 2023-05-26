$serial = (Get-WmiObject win32_bios).Serialnumber
$model = (Get-WmiObject win32_computersystem).Model

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
