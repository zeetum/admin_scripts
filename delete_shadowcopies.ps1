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
function ConvertTime ($timestring) {
    $datetime_details = $timestring.split(" ")
    
    # Get and convert day time
    $time_details = $datetime_details[1].split(":")
    if ($datetime_details[2] -eq "PM") {
        [int]$time_details[0] += 12
    }
    
    $date_details = $datetime_details[0].split("/")
    $output_string = $date_details[2] + "/" + $date_details[1] + "/" + $date_details[0] + " " + $($time_details -join ":") 

    return $output_string
}


$shadows = Convert-VSSShadows $(vssadmin list shadows)
foreach ($shadow in $shadows) {
    $shadow.'Contained 1 shadow copies at creation time' = ConvertTime($shadow.'Contained 1 shadow copies at creation time')
}
