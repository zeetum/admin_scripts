# https://devblogs.microsoft.com/scripting/create-custom-date-formats-with-powershell/
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

# Prune's shadow copies to have the following backups:
# - Every hour of the current day
# - Every day of the current week
# - Every week of the current month
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
 
    # Prune all but last shadowcopy of every other day
    $days = @{}
    $shadow_stack = @{}
    foreach ($shadow in $shadows) {

        $shadow_date = get-date $shadow.creation_time -Format "yyyy/MM/dd"
        $shadow_time = get-date $shadow.creation_time -UFormat %R
        if ($shadow_date -ne (Get-Date -Format "yyyy/MM/dd")) {
            if ($days.contains($shadow_date)) {
                if ((get-date $days[$shadow_date]) -lt (get-date $shadow_time)) {
                    $(vssadmin delete shadows /shadow=$shadows[$shadow_date])
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

        $shadow_date = get-date $shadow.creation_time -Format "yyyy/MM/dd"
        $shadow_month = get-date $shadow.creation_time -Format "yyyy/MM"
        $shadow_week = get-date $shadow.creation_time -UFormat %V
        $shadow_day = $day_of_week.[string](get-date $shadow.creation_time).DayOfWeek
        if ($shadow_month -eq (get-date -Format "yyyy/MM")) {
            if ($shadow_week -ne (Get-Date -UFormat %V)) {
                if ($weeks.contains($shadow_week)) {
                    if ((get-date $weeks[$shadow_week]) -lt (get-date $shadow_day)) {
                        $(vssadmin delete shadows /shadow=$shadows[$shadow_date])
                        Write-Host "Pruning week: "$shadow_stack[$shadow_date]
                        $weeks[$shadow_week] = $shadow_time
                        $shadow_stack[$shadow_week] = $shadow.shadow_id
                    }
                } else {
                    $weeks[$shadow_week] = $shadow_day
                    $shadow_stack[$shadow_week] = $shadow.shadow_id
                }
            }
        }
    }
    
    # Prune all but last day of every other month older than 2 weeks
    $months = @{}
    $shadow_stack = @{}
    foreach ($shadow in $shadows) {

        $shadow_date = get-date $shadow.creation_time -Format "yyyy/MM/dd"
        $shadow_month = get-date $shadow.creation_time -Format "yyyy/MM"
        $shadow_week = Get-Date $shadow_date -UFormat %V
        if (($shadow_month -ne (get-date -Format "yyyy/MM")) -and ($shadow_month -lt  ((Get-Date).adddays(-14)))) {
            if ($months.contains($shadow_month)) {
                if ((get-date $months[$shadow_month]) -lt (get-date $shadow_week)) {
                    $(vssadmin delete shadows /shadow=$shadows[$shadow_date])
                    Write-Host "Pruning month: "$shadow_stack[$shadow_date]
                    $months[$shadow_month] = $shadow_week
                    $shadow_stack[$shadow_month] = $shadow.shadow_id
                }
            } else {
                $months[$shadow_month] = $shadow_week
                $shadow_stack[$shadow_month] = $shadow.shadow_id
            }
        }
    }
}

$shadows = Convert-VSSShadows $(vssadmin list shadows)
PruneShadows $shadows
