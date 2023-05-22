$serial = $(Get-WmiObject win32_bios | select -ExpandProperty Serialnumber)
$Model = (Get-WmiObject -Class win32_computersystem).Model

switch ($Model) {
    "Something" {
        Write-Host "Lease 15/16"
    }
    "Something else" {
        Write-Host "2022 School Owned"
    }
    default {
        Write-Host "Model Not Found"
    }
}

Write-Host "Serial: "$serial
