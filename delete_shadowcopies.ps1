function Convert-VSSShadows {
    [CmdletBinding()]
    param(
        [parameter()]
        $InputObject
    )
    process {
        $InputObject | Select-String -Pattern "^$" -Context 0,10 |
        Select-Object -SkipLast 1 | 
        ForEach-Object {
            $Shadows = ($_.Context.PostContext -Split':\s').Trim(" '")
            [PsCustomObject] @{
                'Contents of shadow copy set ID'             = [guid]$Shadows[1]
                'Contained 1 shadow copies at creation time' = $Shadows[3]
                'Shadow Copy ID'                             = [guid]$Shadows[5]
                'Original Volume'                            = $Shadows[7]
                'Shadow Copy Volume'                         = $Shadows[9]
                'Originating Machine'                        = $Shadows[11]
                'Service Machine'                            = $Shadows[13]
                'Provider'                                   = $Shadows[15]
                'Type'                                       = $Shadows[17]
                'Attributes'                                 = $Shadows[19]
            }
        }
    }
}

# 21/11/2022 3:53:24 PM
function ConvertTime (timestring) {
    $datetime_details = $time.split(" ")
    
    # Get and convert day time
    $time_details = $datetime_details[1].split(":")
    if ($datetime_details[2] == "PM") {
        $time_details[0] += 12
    }
    
    $date_details = $datetime_details[0].split("/")
    
    return $date_details[2] + "/" + $date_details[1] + "/" + $date_details[0] + "/" + time_details.join(":")
}


$shadows = Convert-VSSShadows $(vssadmin list shadows)
$shadows['Contained 1 shadow copies at creation time'] = ConvertTime($shadows['Contained 1 shadow copies at creation time'])
Write-Host $shadows
