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
    $day_of_week = @{
        "Sunday" = 0
        "Monday" = 1;
        "Tuesday" = 2;
        "Wednesday" = 3;
        "Thursday" = 4;
        "Friday" = 5;
        "Saturday" = 6
    }

    $current_date =  Get-Date -Format "yyyy/MM/dd"
 
    # Prune all but last shadowcopy of every other day
    $days = @{}
    $shadow_stack = @{}
    foreach ($shadow in $shadows) {
        Write-Host $shadow.creation_time
        $shadow_date = $shadow.creation_time.split(" ")[0]
        $shadow_time = $shadow.creation_time.split(" ")[1]
        if ($shadow_date -ne $current_date) {
            if ($days.contains($shadow_date)) {
                if ((get-date $days[$shadow_date]) -lt (get-date $shadow_time)) {
                    #$(vssadmin delete shadows /shadow $shadows[$shadow_date])
                    Write-Host "Pruning Day: "$shadow_stack[$shadow_date]
                    $days[$shadow_date] = $shadow_time
                    $shadow_stack[$shadow_date] = $shadow.shadow_id
                }
            } else {
                $days[$shadow_date] = $shadow_time
                $shadow_stack[$shadow_date] = $shadow.shadow_id
            }
            
        }
    }
    
    # Prune all but last shadowcopy of other every week
    $weeks = @{}
    $shadow_stack = @{}
    foreach ($shadow in $shadows) {
        $shadow_date = $shadow.creation_time.split(" ")[0]
        $shadow_month = $shadow_date.split("/")[1]
        $shadow_week = Get-Date $shadow_date -UFormat %V
        $shadow_day = $day_of_week.[string]([datetime]$shadow_date).DayOfWeek
        if ($shadow_month -eq $current_date.split("/")[1]) {
            #Write-Host "shadow_week: "$shadow_week
            #Write-Host "current_week: "$(Get-Date $current_date -UFormat %V)
            if ($shadow_week -ne $(Get-Date $current_date -UFormat %V)) {
                if ($weeks.contains($shadow_week)) {
                    if ((get-date $weeks[$shadow_week]) -lt (get-date $shadow_day)) {
                        #$(vssadmin delete shadows /shadow $shadows[$shadow_date])
                        Write-Host "Pruning week: "$shadow_stack[$shadow_date]
                        $weeks[$shadow_date] = $shadow_time
                        $shadow_stack[$shadow_date] = $shadow.shadow_id
                    }
                } else {
                    $weeks[$shadow_date] = $shadow_day
                    $shadow_stack[$shadow_date] = $shadow.shadow_id
                }
            }
        }
    }
    
    # Prune all but last day of every other month
    $months = @{}
    $shadow_stack = @{}
    foreach ($shadow in $shadows) {
        $shadow_date = $shadow.creation_time.split(" ")[0]
        $shadow_month = $shadow_date.split("/")[1]
        $shadow_week = Get-Date $shadow_date -UFormat %V
        if ($shadow_month -ne $current_date.split("/")[1]) {
            if ($months.contains($shadow_week)) {
                if ((get-date $months[$shadow_month]) -lt (get-date $shadow_week)) {
                    #$(vssadmin delete shadows /shadow $shadows[$shadow_date])
                    Write-Host "Pruning month: "$shadow_stack[$shadow_date]
                    $months[$shadow_date] = $shadow_week
                    $shadow_stack[$shadow_date] = $shadow.shadow_id
                }
            } else {
                $months[$shadow_date] = $shadow_week
                $shadow_stack[$shadow_date] = $shadow.shadow_id
            }
            
        }
    }
}

$shadows = Convert-VSSShadows $(vssadmin list shadows)
#foreach ($shadow in $shadows) {
#    $shadow.'creation_time' = ConvertTime($shadow.'creation_time')
#}
PruneShadows $shadows
