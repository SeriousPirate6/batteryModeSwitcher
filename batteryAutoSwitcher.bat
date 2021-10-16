@echo off

:repeat
if not [%interval%] == [] timeout /t "%interval%" /nobreak>nul

ENDLOCAL
set startingSaving=70
set interval=5
set logPath=C:\Users\%USERNAME%\batterySwitcherLogs

for /F "tokens=1" %%i in ('date /t') do set mydate=%%i
set dd=%mydate:~6,4%-%mydate:~3,2%-%mydate:~0,2%

if not exist "%logPath%" mkdir "%logPath%"

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
	goto end
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
	echo Activating battery saving... Battery lasting: %batteryRem% Start saving at: %startingSaving%
	REM powercfg -S SCHEME_MAX
	ECHO %date%-%time%: Switch to saving battery profile>>"%logPath%\%dd%.log"
	goto repeat
) else (
	if not [%startingSaving%] == [] (
		echo Battery more than %startingSaving%%%.
		ECHO %date%-%time%: Battery more than %startingSaving%%%>>"%logPath%\%dd%.log"
	)
	goto repeat
)

:end

if "%chargingType%"=="2" (
	echo Battery on charge.
	if not [%startingSaving%] == [] ECHO %date%-%time%: Battery on charge>>"%logPath%\%dd%.log"
	goto repeat
)

timeout /t 2 /nobreak>nul

exit