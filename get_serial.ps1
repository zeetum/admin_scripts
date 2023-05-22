$serial = (Get-WmiObject win32_bios).Serialnumber
$model = (Get-WmiObject win32_computersystem).Model

switch ($model) {
    "Something" {
        Write-Host "Model: Lease 15/16"
    }
    "Something else" {
        Write-Host "Model: 2022 School Owned"
    }
    default {
        Write-Host "Model: "$model
    }
}

Write-Host "Serial: "$serial
