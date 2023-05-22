$serial = (Get-WmiObject win32_bios).Serialnumber
$model = (Get-WmiObject -Class win32_computersystem).Model

switch ($model) {
    "Something" {
        Write-Host "Model: Lease 15/16"
    }
    "Something else" {
        Write-Host "Model: 2022 School Owned"
    }
    default {
        Write-Host "Model: No Match"
    }
}

Write-Host "Serial: "$serial
