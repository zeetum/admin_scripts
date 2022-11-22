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
                'creation_time'                              = $Shadows[3]
                'shadow_id'                             = [guid]$Shadows[5]
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

# Converts to the format:
# 2022/11/21 3:53:24 PM
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

# Prune's shadow copies to have the following backups:
# - Every hour of the current day
# - Every day of the current week
# - Every month after that
function PruneShadows ($shadows) {
    $current_date =  Get-Date -Format "yyyy/MM/dd"
 
    # Prune all but last shadowcopy of every other day
    $days = @{}
    foreach ($shadow in $shadows) {
        $shadow_date = $shadow.creation_time.split(" ")[0]
        $shadow_time = $shadow.creation_time.split(" ")[1]
        if ($shadow_date -ne $current_date) {
            if ($days.contains($shadow_date)) {
                if ($days[$shadow_date] < $shadow_time) {
                    $days[$shadow_date] = $shadow_time
                    $(vssadmin delete shadows /shadow $shadow.shadow_id)
                }
            } else {
                $days[$shadow_date] = $shadow_time
            }
            
        }
    }
    
    # Prune all but last shadowcopy of other every week
    $weeks = @{}
    foreach ($shadow in $shadows) {
        $shadow_date = $shadow.creation_time.split(" ")[0]
        $shadow_month = $shadow_date.split("/")[1]
        $shadow_week = ([Datetime]$shadow_month).DayOfWeek.value__
        $shadow_day = $shadow_date.split("/")[1]
        if ($shadow_month -eq $current_date.split("/")[1]) {
            if ($weeks.contains($shadow_week))
                if ($weeks[$shadow_week] < $shadow_day
                if ( -ne $current_date.DayOfWeek.value__) {
                    $months[$shadow_date]
            }
        }
    }
    
    # Prune all but last day of every other month
    $months = @{}
    foreach ($shadow in $shadows) {
        $shadow_date = $shadow.creation_time.split(" ")[0]
        $shadow_month = $shadow_date.split("/")[1]
        $shadow_day = $shadow_date.split("/")[1]
        if ($shadow_month -ne $current_date.split("/")[1]) {
            if ($weeks[$shadow_month] < $shadow_time) {
        }
    }
}

$shadows = Convert-VSSShadows $(vssadmin list shadows)
foreach ($shadow in $shadows) {
    $shadow.'creation_time' = ConvertTime($shadow.'creation_time')
}
