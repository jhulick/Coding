# ------------------------------------------------------------
# 
# PowerShell - Get-Date (Timestamps, with or without Timezone)
# 
# ------------------------------------------------------------
# Timestamp (WITHOUT Timezone)
# 

Get-Date -UFormat "%Y%m%d%H%M%S"

$Timestamp = (Get-Date -UFormat "%Y%m%d%H%M%S");
Write-Host ${Timestamp};


# ------------------------------------------------------------
# Timestamp (WITH Timezone)
# 

$Timestamp_UTC = (Get-Date -UFormat "%Y%m%d%H%M%S%Z");
Write-Host ${Timestamp_UTC};



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
#		REM
#		REM Citation(s)
#		REM
#		REM		Get-Date  :::  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-6
#		
