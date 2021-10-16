@echo off

goto start

:repeat
if not [%interval%] == [] timeout /t "%interval%" /nobreak>nul

ENDLOCAL
set startingSaving=70
set interval=5
set logPath=C:\Users\%USERNAME%\batterySwitcherLogs

for /F "tokens=1" %%i in ('date /t') do set mydate=%%i
set dd=%mydate:~6,4%-%mydate:~3,2%-%mydate:~0,2%

if not exist "%logPath%" mkdir "%logPath%"

:start

SETLOCAL ENABLEDELAYEDEXPANSION
SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`WMIC Path Win32_Battery Get BatteryStatus`) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)

set /a chargingType="%var2%"

SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`WMIC Path Win32_Battery Get EstimatedChargeRemaining`) DO (
SET var!count!=%%F
SET /a count=!count!+1
)

set /a batteryRem="%var2%"

if "%chargingType%"=="1" (
	if "%batteryRem%" LSS "%startingSaving%" (
		echo Activating battery saving... Battery lasting: %batteryRem% Start saving at: %startingSaving%
		@REM powercfg -S SCHEME_MAX
		ECHO %date%-%time%: Switch to saving battery profile>>"%logPath%\%dd%.log"
		goto repeat
	) else (
		if not [%startingSaving%] == [] (
			echo Battery more than %startingSaving%%%.
			ECHO %date%-%time%: Battery more than %startingSaving%%%>>"%logPath%\%dd%.log"
		)
		goto repeat
	)
)

if "%chargingType%"=="2" (
	echo Battery on charge.
	ECHO %date%-%time%: Battery on charge>>"%logPath%\%dd%.log"
	goto repeat
)

timeout /t 2 /nobreak>nul

exit