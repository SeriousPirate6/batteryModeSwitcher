@echo off

:repeat
if not [%interval%] == [] timeout /t "%interval%" /nobreak>nul

ENDLOCAL
set startingSaving=70
set interval=5
set logPath=C:\Users\%USERNAME%\batterySwitcherLogs

set powerSaving=a1841308-3541-4fab-bc81-f71556f20b4a
set maxPerformance=9df557d5-8a11-42bf-88e4-c9737e89d41d

for /F "tokens=1" %%i in ('date /t') do set mydate=%%i
set dd=%mydate:~6,4%-%mydate:~3,2%-%mydate:~0,2%

if not exist "%logPath%" mkdir "%logPath%"

FOR /F "tokens=* USEBACKQ" %%F IN (`powercfg /GETACTIVESCHEME`) DO (
SET var=%%F
)
set currentBatteryScheme=%var%

SETLOCAL ENABLEDELAYEDEXPANSION

SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`WMIC Path Win32_Battery Get BatteryStatus`) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)

set /a chargingType="%var2%"

@REM forcing variable to 2, simulating "in charging" case, comment next row for a default usage
@REM forcing variable to 1, simulating "battery mode" case, comment next row for a default usage
@REM set /a chargingType="1"

if "%chargingType%"=="1" (
	goto proceed
) else (
	goto maxperf
)

:proceed

SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`WMIC Path Win32_Battery Get EstimatedChargeRemaining`) DO (
SET var!count!=%%F
SET /a count=!count!+1
)

set /a batteryRem="%var2%"

@REM forcing variable to "startingSaving", simulating "sufficient charge" case, comment next row for a default usage
@REM set /a batteryRem=%startingSaving%

if %batteryRem% LSS %startingSaving% (
	goto saving
) else (
	echo Battery more than %startingSaving%%%.
	ECHO %date%-%time%: Battery more than %startingSaving%%%>>"%logPath%\%dd%.log"
	goto repeat
)

:saving

echo %currentBatteryScheme%|find "%powerSaving%" >nul
if errorlevel 1 (
	echo Activating battery saving... Battery lasting: %batteryRem% Start saving at: %startingSaving%
	powercfg -S %powerSaving%
	ECHO %date%-%time%: Switch to saving battery profile>>"%logPath%\%dd%.log"
) else (
	echo Battery saving already activated... Battery lasting: %batteryRem%
	ECHO %date%-%time%: MODE: battery saving. Battery lasting: %batteryRem% >>"%logPath%\%dd%.log"
)
goto repeat

:maxperf

echo %currentBatteryScheme%|find "%maxPerformance%" >nul
if errorlevel 1 (
	echo Activating max performance...
	powercfg -S %maxPerformance%
	ECHO %date%-%time%: Switch to max performance profile>>"%logPath%\%dd%.log"
) else (
	echo Battery on charge.
	ECHO %date%-%time%: MODE: max performace. Battery on charge.>>"%logPath%\%dd%.log"
)
goto repeat


timeout /t 2 /nobreak>nul

exit