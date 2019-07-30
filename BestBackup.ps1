$ErrorActionPreference ="Stop" #we dont want to our lose data if someting goes wrong
#$date = (Get-Date).ToString("MM-dd-yy")   ##Output: mm-dd-yy
#$DateStamp = Get-Date -Format "MM-dd-yy"  ##Output: mm-dd-yy
$weekofthemonth =(Get-WmiObject Win32_LocalTime).weekinmonth  #Week number
$DateStamp = Get-Date -Format "ddMMMyyyy"
$WeekStamp= Get-Date -Format week$weekofthemonth
#$WeekStamp= Get-Date -Format week$weekofthemonth"inMMMyyyy"
$MonthStamp = Get-Date -Format "MMMyyyy"
$YearStamp = Get-Date -Format "yyyy"

$today = get-date
$Datetoday = (Get-Date).Date
$weekdaytoday=(Get-Date).DayofWeek

$lastDay = [DateTime]::DaysInMonth($today.Year, $today.Month)
$monthfirstDate = [DateTime]::new($today.Year, $today.Month, 1)
$monthlastDate  = [DateTime]::new($today.Year, $today.Month, $lastDay)
 
$firstdayofweek=$today.AddDays(-($today).DayOfWeek)
$lastdayofweek= $today.AddDays(6-($today).DayOfWeek)


$sourcelocation ="C:\Users\profile\Desktop\Randome"

$backuplocation ="C:\Users\profile\Desktop\Backup\"
$daybackuplocation ="C:\Users\profile\Desktop\Backup\Daily\"
$weekbackuplocation ="C:\Users\profile\Desktop\Backup\Weekly\"
$monthbackuplocation ="C:\Users\profile\Desktop\Backup\Monthly\"

$templocation = "C:\Users\profile\Desktop\Backup\temp\"

$daytargetlocation =$daybackuplocation + $DateStamp+"_backup.zip"
$weektargetlocation=$weekbackuplocation + $WeekStamp+"_backup.zip"
$monthtargetlocation=$monthbackuplocation + $MonthStamp+"_backup.zip"

#$targetlocation =$backuplocation + $(Get-Date -Format MM-dd-yy)+"_backup.zip"
#$targetlocation =$backuplocation + $Datestamp+"_backup.zip"

If(!(Test-Path "$backuplocation"))
{
    New-Item -ItemType Directory -Path $backuplocation
    If(!(Test-Path "$daybackuplocation"))
    {
     New-Item -ItemType Directory -Path $daybackuplocation
    }
    If(!(Test-Path "$weekbackuplocation"))
    {
     New-Item -ItemType Directory -Path $weekbackuplocation
    }
    If(!(Test-Path "$monthbackuplocation"))
    {
     New-Item -ItemType Directory -Path $monthbackuplocation
    }
}
New-Item -ItemType Directory -Path $templocation
If(!(Test-Path "$daytargetlocation"))
{
    Robocopy $sourcelocation $templocation /E | Out-Null
    Compress-Archive -Path $templocation\* -DestinationPath $daytargetlocation -Force    
}
Get-ChildItem -Path $daybackuplocation -Recurse |Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-6))}  | Remove-Item

If($weekdaytoday -eq ($lastdayofweek).DayOfWeek)
{
    If(!(Test-Path "$weektargetlocation"))
    {
        Robocopy $daybackuplocation $weektargetlocation  /E | Out-Null
    }
    Get-ChildItem -Path $weekbackuplocation -Recurse |Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-$lastDay))}  | Remove-Item
}

If($Datetoday -eq ($monthlastDate).Date)
{
    If(!(Test-Path "$monthtargetlocation"))
    {
        Robocopy $weekbackuplocation $monthtargetlocation  /E | Out-Null
    }
    Get-ChildItem -Path $monthbackuplocation -Recurse |Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-365))}  | Remove-Item
}
Remove-Item -Path $templocation -Recurse -Force