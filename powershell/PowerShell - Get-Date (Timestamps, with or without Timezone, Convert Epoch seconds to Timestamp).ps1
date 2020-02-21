# ------------------------------------------------------------
# 
# PowerShell - Get-Date (Timestamps, with or without Timezone)
# 
# ------------------------------------------------------------
# Timestamp (WITH Timezone)
# 

Get-Date -UFormat '%Y%m%d%H%M%S%Z';

# Timestamp, Timezone-included (and with as few characters as possible)
$Timestamp_TZ = (Get-Date -UFormat '%Y%m%d%H%M%S%Z'); Write-Host ${Timestamp_TZ};

# Timestamp, RFC3339-Compliant
$Timestamp_RFC3339 = (Get-Date -UFormat '%Y:%m:%dT%H:%M:%S%Z'); Write-Host ${Timestamp_RFC3339};


# ------------------------------------------------------------
# Timestamp (NO Timezone)
# 

Get-Date -UFormat '%Y%m%d%H%M%S';

# Timestamp, No-Timezone (and with as few characters as possible)
$Timestamp = (Get-Date -UFormat '%Y%m%d%H%M%S'); Write-Host ${Timestamp};

# Timestamp, Filename-compatible
$TimestampFilename = (Get-Date -UFormat '%Y%m%d-%H%M%S'); Write-Host ${TimestampFilename};
  # Example filename usage
	New-Item -ItemType "Directory" -Path ("${Home}\Desktop\ExampleDirectory_$(Get-Date -UFormat '%Y%m%d-%H%M%S')") -Force | Out-Null;

# Timestamp, Filename-compatible w/ decimal-seconds
$EpochDate = ([Decimal](Get-Date -UFormat ("%s"))); `
$EpochToDateTime = (New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0).AddSeconds([Math]::Floor($EpochDate)); `
$DecimalTimestampLong = ( ([String](Get-Date -Date ("${EpochToDateTime}") -UFormat ("%Y-%m-%d_%H-%M-%S"))) + (([String]((${EpochDate}%1))).Substring(1).PadRight(6,"0")) ); `
$DecimalTimestampShort = ( ([String](Get-Date -Date ("${EpochToDateTime}") -UFormat ("%Y%m%d-%H%M%S"))) + (([String]((${EpochDate}%1))).Substring(1).PadRight(6,"0")) ); `
Write-Host "`n`n"; `
Write-Host "`$EpochDate = [ ${EpochDate} ]"; `
Write-Host "`$EpochToDateTime = [ ${EpochToDateTime} ]"; `
Write-Host "`$DecimalTimestampLong = [ ${DecimalTimestampLong} ]"; `
Write-Host "`$DecimalTimestampShort = [ ${DecimalTimestampShort} ]"; `
Write-Host "`n`n";


# ------------------------------------------------------------

#
# Method 1 of obtaining (milli-/micro-) seconds past the decimal
#
$DecimalSec_Split = [Decimal]"0.$($(Get-Date -UFormat ('%s')).Split('.')[1].Trim())";


#
# Method 2 of obtaining (milli-/micro-) seconds past the decimal
#
$DecimalSec_Mod = (([Decimal](Get-Date -UFormat ('%s')))%1);


# ------------------------------------------------------------
# Relative DateTime Queries (Common English Statements)
#   |
#   |--> Phrases such as "this Monday" become muddled & hard to identify when "today" is a Saturday/Sunday (weekend day).             For example's sake, let's say today is Saturday - From the Saturday perspective, saying "this Monday" could equally refer to the next Monday OR the previous Monday, which, respectively, is 2 days in the future vs. 5 days in the past.             The weekend prevents simple arithmetic such as "2 days is less than 5 so 'this Monday' must refer to the next Monday" from being correct, as Saturday appears much closer to the previous week's row-of-days on a paper calendar (lending to "this" referring to "previous" - keeping both Mondays plausibly in the picture).             The outcome: The date of "this Monday" ends up referring to a date in the future while also simultaneously referring to a date in the past - Monday has now become a paradox. Monday must be resolved.             This is where the English phrases "this last Monday" and "this upcoming Monday" neatly iron-out the confusion and restore polite, colloquial conversation to a level far from paradoxical Mondays.             (Should the week begin on Saturday on paper calendars?)
# 

$GetDate_LastMonday = (Get-Date 0:0).AddDays(1 + ([Int](Get-Date).DayOfWeek * -1));
$LastMondaysDate = (Get-Date 0:0).AddDays(1 + ([Int](Get-Date).DayOfWeek * -1));

Write-Host (Get-Date $LastMondaysDate -UFormat "%Y-%m-%d");


# ------------------------------------------------------------
#
#	CMD/Batch-File:
#
#		@ECHO OFF
#		
#		SET HoursElapsed=8.5
#		
#		REM Note: Uses Powershell's Get-Date (See citations, below for docs)
#		
#		REM Get the Day-of-Week (Monday, Tuesday, etc.)
#		FOR /f "delims=" %%G IN ('powershell "(Get-Date %time% -UFormat %%A);"') DO SET DayOfWeek_Current=%%G
#		
#		REM Get the Current Time
#		FOR /f "delims=" %%G IN ('powershell "(Get-Date %time% -UFormat %%I:%%M:%%S);"') DO SET DateTime_Current=%%G
#		FOR /f "delims=" %%G IN ('powershell "(Get-Date %time% -UFormat %%p);"') DO SET AM_PM_Current=%%G
#		
#		REM Get the Day-of-Week after (%HoursElapsed%) Hours have elapsed
#		FOR /f "delims=" %%G IN ('powershell "((Get-Date %time%).AddHours(%HoursElapsed%) | Get-Date -UFormat %%A);"') DO SET DayOfWeek_Elapsed=%%G
#		REM Get the Time after (%HoursElapsed%) Hours have elapsed
#		FOR /f "delims=" %%G IN ('powershell "((Get-Date %time%).AddHours(%HoursElapsed%) | Get-Date -UFormat %%I:%%M:%%S);"') DO SET DateTime_Elapsed=%%G
#		FOR /f "delims=" %%G IN ('powershell "((Get-Date %time%).AddHours(%HoursElapsed%) | Get-Date -UFormat %%p);"') DO SET AM_PM_Elapsed=%%G
#		
#		ECHO.
#		ECHO   Datetime currently is:   %DayOfWeek_Current% @ %DateTime_Current% %AM_PM_Current%
#		ECHO   Datetime after [ %HoursElapsed% ] hours have elapsed:   %DayOfWeek_Elapsed% @ %DateTime_Elapsed% %AM_PM_Elapsed%
#		ECHO.
#		
#		REM Debugging Timeout (to view output while testing)
#		TIMEOUT -T 30
#		
#		EXIT
# 
# 
# ------------------------------------------------------------
#
# Citation(s)
#
#		devblogs.microsoft.com  |  "PowerTip: Remove First Two Letters of String | Scripting Blog"  |  https://devblogs.microsoft.com/scripting/powertip-remove-first-two-letters-of-string/
#
#		docs.microsoft.com  |  "Get-Date - Gets the current date and time"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date
#
#		docs.microsoft.com  |  "Math.Floor Method (System) | Microsoft Docs"  |  https://docs.microsoft.com/en-us/dotnet/api/system.math.floor
#
#		docs.microsoft.com  |  "String.PadRight Method (System) | Microsoft Docs"  |  https://docs.microsoft.com/en-us/dotnet/api/system.string.padright
#
#		stackoverflow.com  |  "Midnight last Monday in Powershell"  |  https://stackoverflow.com/a/42578179
#
#		stackoverflow.com  |  "Powershell - Round down to nearest whole number - Stack Overflow"  |  https://stackoverflow.com/a/5864061
#
# ------------------------------------------------------------